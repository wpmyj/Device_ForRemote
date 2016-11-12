//
//  MHGatewayWebViewController.m
//  MiHome
//
//  Created by Lynn on 9/28/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayWebViewController.h"
#import "MHLMShareListBar.h"
#import <MiHomeKit/MiHomeKit.h>
#import "MHOpenInMiHomeManager.h"
#import "MHShareListBar.h"
#import "MHGatewayMainViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MHLumiJavascriptObjectBridge.h"
#import "MHGatewayAddSubDeviceViewController.h"

#define kHumiture self.isHumiture




@interface MHGatewayWebViewController ()

@property (nonatomic, copy) NSString* strCurrentURL;
@property (nonatomic, assign) BOOL isNavagition;

@property (nonatomic, strong) NSString* productTitle;
@property (nonatomic, strong) NSString* descrip;
@property (nonatomic, strong) UIImage* thumbnail;
@property (nonatomic, strong) UIImage* shareImage;
@property (nonatomic, strong) NSString* shareURL;

@property (nonatomic, strong) UIButton *rotationBtn;//图标类旋转屏幕
@property (nonatomic, assign) BOOL isPortrait;
@property (nonatomic, assign) BOOL rechargeBack;

@end

@implementation MHGatewayWebViewController
#pragma mark - navigaitonbar样式
- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.graphFlag) {
        return UIStatusBarStyleLightContent;
    }
    else {
        return UIStatusBarStyleDefault;
    }

}
#pragma mark - 注册微信微博回调
- (id)initWithURL:(NSURL *)URL
{
    self = [super initWithURL:URL];
    if (self) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getWxShareResultNotification:) name:MHNotification_ShareToWx_Rsp object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getWbShareResultNotification:) name:MHNotification_ShareToWb_Rsp object:nil];
    }
    return self;
}

- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:MHNotification_ShareToWx_Rsp object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:MHNotification_ShareToWb_Rsp object:nil];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.webView.scalesPageToFit = [self.controllerIdentifier isEqualToString:@"mydevice.actionsheet.tutorial"];
    self.webView.scrollView.bounces = NO;
    self.webView.scrollView.showsHorizontalScrollIndicator = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:@"lumi_plug_logochoose_clicked"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}


- (void)onBack:(id)sender {
    
    if (![self rechargeBack]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        if ([self.webView canGoBack]) {
            [self.webView goBack];
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
   
}


#pragma mark - 按钮
- (void)buildSubviews {
    [super buildSubviews];
    if (self.hasShare) {
        //创建分享按钮
        [self createRightBarButtonItem];
    }

    if (self.graphFlag) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.layer.borderWidth = 1.0f;
        btn.layer.borderColor = [UIColor whiteColor].CGColor;
        [btn setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.Horizontal",@"plugin_gateway","横屏") forState:UIControlStateNormal];
        btn.layer.cornerRadius = 5.0f;

        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onRotation) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(0, 0, 50, 30);
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        self.navigationItem.rightBarButtonItem = rightItem;
        
        self.rotationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.rotationBtn setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.Portrait",@"plugin_gateway","竖屏") forState:UIControlStateNormal];
        self.rotationBtn.layer.cornerRadius = 5.0f;
        self.rotationBtn.layer.borderWidth = 1.0f;
        self.rotationBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.rotationBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.rotationBtn addTarget:self action:@selector(onRotation) forControlEvents:UIControlEventTouchUpInside];
        switch (self.deviceType) {
            case MHGATEWAYGRAPH_PLUG:
            case MHGATEWAYGRAPH_NATGAS:
            case MHGATEWAYGRAPH_SMOKE:
            case MHGATEWAYGRAPH_HUMITURE:
            case MHGATEWAYGRAPH_ACPARTNER:
                self.view.backgroundColor = [MHColorUtils colorWithRGB:0x22333f];
                break;
            default:
                break;
        }
        self.rotationBtn.hidden = YES;
        self.isNavBarTranslucent = YES;
        [self.view addSubview:self.rotationBtn];
    }
}

- (void)buildConstraints {
    [super buildConstraints];
    if (self.graphFlag) {
        XM_WS(weakself);
        [self.rotationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakself.view).with.offset(10);
            make.centerX.equalTo(weakself.view);
            make.size.mas_equalTo(CGSizeMake(50, 30));
        }];
    }
}



- (void)createRightBarButtonItem {
    UIImage* imageShare = [[UIImage imageNamed:([self preferredStatusBarStyle] == UIStatusBarStyleDefault ? @"navi_share_black" : @"navi_share_white")] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *rightItemShare = [[UIBarButtonItem alloc] initWithImage:imageShare style:UIBarButtonItemStylePlain target:self action:@selector(onShare:)];
    self.navigationItem.rightBarButtonItem = rightItemShare;
}


- (void)shareWithTitle:(NSString *)title
           description:(NSString *)description
             thumbnail:(UIImage *)thumbnail
                   url:(NSString *)url {
    self.productTitle = title;
    self.descrip = description;
    self.thumbnail = thumbnail;
    self.shareURL = url;
}

- (void)onShare:(id)sender {
    [MHLMShareListBar showFromView:self.view
                  withProductTitle:_productTitle
                       description:_descrip
                         thumbnail:_thumbnail
                               url:_shareURL ? _shareURL : self.strCurrentURL];
}





- (void)openWebVC:(NSString *)strURL identifier:(NSString *)identifier isHasShare:(BOOL)hasShare {
    NSURL *URL = [NSURL URLWithString:strURL];
    
    MHGatewayWebViewController* web = [[MHGatewayWebViewController alloc] initWithURL:URL];
    web.isTabBarHidden = YES;
    web.hasShare = hasShare;
    web.strOriginalURL = strURL;
    web.controllerIdentifier = identifier;
    web.gatewayDevice = self.gatewayDevice;
    [self.navigationController pushViewController:web animated:NO];
}
#pragma mark - js-oc
/**
 *  @brief 创建OC对象供H5调用<MHLumiJavascriptObjectBridgeProtocol>中的方法
 */
- (void)updateJSContext {
//    XM_WS(weakself);
    _jsContext = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    MHLumiJavascriptObjectBridge *jsOCBridge = [[MHLumiJavascriptObjectBridge alloc] initWithJSContext:_jsContext];
    _jsContext[@"MHLMShare"] = jsOCBridge;
    jsOCBridge.gatewayDevice = _gatewayDevice;
    jsOCBridge.deviceDid = _deviceDid;
    jsOCBridge.currentDevice = _currentDevice;

    self.jsContext.exceptionHandler = ^(JSContext *con, JSValue *exception) {
        NSLog(@"%@", exception);
        con.exception = exception;
    };
  
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    [self updateJSContext];
    if ([request.URL.absoluteString isEqualToString:@"http://www.lumiunited.com/nav/service/tutorial-mb.php"]) {
        _strCurrentURL = request.URL.absoluteString;

        [self openURL:@"http://www.lumiunited.com/nav/service/tutorial-mb.php"];
        return NO;
    }
    NSString* rechargeUrl = request.URL.absoluteString;
    NSString* fragment = request.URL.fragment;
//    NSLog(@"url%@", rechargeUrl);
//    NSLog(@"fragment%@", fragment);
    
    //支付成功
    if ([rechargeUrl hasPrefix:@"https://web.recharge.pay.xiaomi.com/web/utility"] && (!fragment || [fragment hasPrefix:@"detail/orderId/"])) {
        self.rechargeBack = NO;
    } else {
        
        self.rechargeBack = YES;
    }
    //添加银行卡
    if ([rechargeUrl hasPrefix:@"https://m.pay.xiaomi.com/payFunc"] && ([fragment isEqualToString:@"/addbank"] || [fragment isEqualToString:@"/success"])) {
        self.rechargeBack = NO;
    }


    
    return YES;
}



- (void)webViewDidStartLoad:(UIWebView *)webView {

}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self updateJSContext];
    NSString* title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = self.title ?: title;
    //[title isEqualToString:@""]
}


-(void)openURL:(NSString *)urlstring
{
    NSURL *URL = [NSURL URLWithString:urlstring];
    [[UIApplication sharedApplication] openURL:URL];
}

+ (MHGatewayWebViewController *)openWebVC:(NSString *)strURL identifier:(NSString *)identifier share:(BOOL)isShare {
    NSURL *URL = nil;
    
    if ([strURL isEqualToString:kNewUserCN]) {
        URL = [NSURL URLWithString:[[MHLumiHtmlHandleTools sharedInstance] currentLanguageIsChinese] ? kNewUserCN : kNewUserEN];
    }
    else {
        URL = [NSURL URLWithString:strURL];
    }
    
    
    MHGatewayWebViewController *web = [[MHGatewayWebViewController alloc] initWithURL:URL];
    //    web.gatewayDevice = self.gateway;
    web.hasShare = isShare;
    NSString *descrp = NSLocalizedStringFromTable(identifier, @"plugin_gateway", nil);
    NSString *title = NSLocalizedStringFromTable(@"mydevice.gateway.about.title", @"plugin_gateway", @"关于 - 小米智能家庭套装");
    web.title = descrp;
    web.strOriginalURL = strURL;
    [web shareWithTitle:title description:descrp thumbnail:nil url:nil];
    web.isTabBarHidden = YES;
    web.controllerIdentifier = identifier;
    return web;
}

#pragma mark - 图形日志页横竖屏
//- (BOOL)shouldAutorotate
//{
//    return NO;
//}
- (void)onRotation {
    if(!self.isPortrait){
        //横屏
        self.navigationController.navigationBarHidden = YES;
        self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
        self.view.bounds = CGRectMake(0, 0, WIN_HEIGHT, WIN_WIDTH);
        self.isPortrait = YES;
        self.rotationBtn.hidden = NO;
//        [self setNeedsStatusBarAppearanceUpdate];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }else {
        //竖屏
        self.navigationController.navigationBarHidden = NO;
        self.rotationBtn.hidden = YES;
        self.navigationController.navigationBar.transform = CGAffineTransformMakeRotation(0);
        self.view.transform = CGAffineTransformMakeRotation(0);
        self.view.bounds = CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT);
        self.isPortrait = NO;
//        [self setNeedsStatusBarAppearanceUpdate];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];

    }
}

//- (BOOL)prefersStatusBarHidden//for iOS7.0
//{
//    return self.isPortrait;
//}

#pragma mark - 分享结果的通知
- (void)getWxShareResultNotification:(NSNotification *)note {
    id obj = note.userInfo[@"MHNotificationKey_Share_Rsp"];
    NSLog(@"%@", note.userInfo[@"MHNotificationKey_Share_Rsp"]);
    JSValue *jsParamFunc = self.jsContext[@"shareResult"];
    [jsParamFunc callWithArguments:@[ obj ]];
    
}
- (void)getWbShareResultNotification:(NSNotification *)note {
    id obj = note.userInfo[@"MHNotificationKey_Share_Rsp"];
    NSLog(@"%@", note.userInfo[@"MHNotificationKey_Share_Rsp"]);
    JSValue *jsParamFunc = self.jsContext[@"shareResult"];
    [jsParamFunc callWithArguments:@[ obj ]];
}
@end
