//
//  MHLuWebViewController.m
//  MiHome
//
//  Created by Lynn on 10/16/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLuWebViewController.h"
#import "MHFeedbackViewController.h"
#ifndef kAppNotSupportWebHandler
#import "MHMiHomeWebSchemeHandler.h"
#import "MHSchemeHandlerCenter.h"
#define kMiHomeWebScheme @"mihome"
#endif


@implementation MHLuWebViewController
{
    NJKWebViewProgress *_progressProxy;
}
- (id)initWithURL:(NSURL *)URL
{
    self = [super init];
    if (self) {
        self.URL = URL;
    }
    return self;
}

- (void)dealloc {
    
}

- (void)onBack:(id)sender
{
    if ([self goBack])
    {
        return;
    }
    
    [super onBack:sender];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    XM_WS(weakself);
    self.automaticallyAdjustsScrollViewInsets = NO; //or webview will have top inset unexpectedly
    
    self.isTabBarHidden = YES;
#ifndef kAppNotSupportWebHandler
    MHMiHomeWebSchemeHandler *handler = [[MHMiHomeWebSchemeHandler alloc] init];
    [handler registerMessageType:@"finishPage" block:^id(MHSafeDictionary *body) {
        [weakself.navigationController popViewControllerAnimated:YES];
        return nil;
    }];
    [handler registerMessageType:@"goBack" block:^id(MHSafeDictionary *body) {
        [weakself goBack];
        return nil;
    }];
    [handler registerMessageType:@"setTitle" block:^id(MHSafeDictionary *body) {
        NSString *title = [body objectForKey:@"title" class:[NSString class]];
        weakself.title = title;
        return nil;
    }];
    [handler registerMessageType:@"onBackPressed" block:^id(MHSafeDictionary *body) {
        BOOL handled = [[body objectForKey:@"handled" class:[NSNumber class]] boolValue];
        if (!handled)
        {
            [weakself goBack];
        }
        return nil;
    }];
    [handler registerMessageType:@"startPage" block:^id(MHSafeDictionary *body) {
        NSString *pageName = [body objectForKey:@"pageName" class:[NSString class]];
        NSString *pageParam = [body objectForKey:@"pageParam" class:[NSDictionary class]];
        if ([pageName isEqualToString:@"mihome.feedback"])
        {
            MHFeedbackViewController* feedbackVC = [[MHFeedbackViewController alloc] init];
            [weakself.navigationController pushViewController:feedbackVC animated:YES];
        }
        else
        {
            NSLog(@"not support page jump now: %@ %@", pageName, pageParam);
        }
        return nil;
    }];
    
    [[MHSchemeHandlerCenter sharedInstance] registerWebScheme:kMiHomeWebScheme handler:handler];
#endif
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    swipeRight.delegate = self;
    [swipeRight setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:swipeRight];
}


- (void)swiped:(UISwipeGestureRecognizer *)gesture {
    [_webView stopLoading];
    if(self.willBack) self.willBack();
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - 保证一样的响应的区域
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.view];
    CGRect respondFrame = CGRectMake(0, 0, 80, 66);
    if (CGRectContainsPoint(respondFrame, point)) {
        return YES;
    }
    return NO;
}


- (void)buildSubviews
{
    XM_WS(weakself);
    _webView = [[UIWebView alloc] init];
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    _webView.backgroundColor = [UIColor clearColor];
//    _webView.delegate = self;
    [self loadRequest];
    [self.view addSubview:_webView];
    
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:CGRectMake(0, 44, WIN_WIDTH, 3)];
    _progressView.fadeOutDelay = 0.27;
    _progressView.barAnimationDuration = 0.27;
    _progressView.fadeAnimationDuration = 0.5;
    
    _progressProxy = [[NJKWebViewProgress alloc] init]; // instance variable
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressBlock = ^(float progress) {
        [weakself.progressView setProgress:progress animated:YES];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_progressView removeFromSuperview];

}

- (void)loadRequest
{
    [_webView stopLoading];
    [_webView loadRequest:[NSURLRequest requestWithURL:self.URL]];
}

- (void)buildConstraints
{
    NSDictionary* views = @{ @"webView"     : _webView,
                             @"topGuide"    : self.topLayoutGuide,
                             @"bottomGuide" : self.bottomLayoutGuide };
    NSArray* layout_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|"
                                                                options:0 metrics:nil views:views];
    NSArray* layout_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide][webView][bottomGuide]"
                                                                options:0 metrics:nil views:views];
    [self.view addConstraints:layout_H];
    [self.view addConstraints:layout_V];
}

- (BOOL)goBack
{
#ifndef kAppNotSupportWebHandler
    return [(MHMiHomeWebSchemeHandler *)[[MHSchemeHandlerCenter sharedInstance] handlerForScheme:kMiHomeWebScheme] goBack];
#else
    return YES;
#endif
}

-(void)addCookie:(NSString *)name value:(NSString *)value domains:(NSArray *)domains
{
    XM_WS(weakself)
    [domains enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [weakself addCookie:name value:value domain:obj];
    }];
}

-(void)addCookie:(NSString *)name value:(NSString *)value domain:(NSString *)domain
{
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setValue:name forKey:NSHTTPCookieName];
    [cookieProperties setValue:value forKey:NSHTTPCookieValue];
    
    [cookieProperties setValue:domain forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
    /* 因为用户可能在webview中操作很长时候，所以不方便设置cookie的有效期 */
    //    [cookieProperties setValue:[NSDate dateWithTimeIntervalSinceNow:10000] forKey:NSHTTPCookieExpires];
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
}

-(void)clearCookie:(NSString *)name domains:(NSArray *)domains
{
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    [cookies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSHTTPCookie* item = obj;
        if ( NSOrderedSame == [[item name] caseInsensitiveCompare:name] && (!domains || [domains containsObject:[item domain]])) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:item];
        }
    }];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString* title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = title;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
#ifndef kAppNotSupportWebHandler
    //这里本来是调用父类UIWebView的dealWithRequest
    //现在处理的逻辑统一挪到MHSchemeHandlerCenter中
    //Woody 2015/8/20
    BOOL deal = [[MHSchemeHandlerCenter sharedInstance] dealWithURL:[[request URL] absoluteString]];
    if (deal)
    {
        if ([[request.URL scheme] hasPrefix:@"http"] ||
            [[request.URL scheme] hasPrefix:@"mihome"])
        {
            return NO;
        }
        return YES;
    }
#endif
    return YES;
}


@end
