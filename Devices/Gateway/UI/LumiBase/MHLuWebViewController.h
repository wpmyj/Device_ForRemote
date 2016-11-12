//
//  MHLuWebViewController.h
//  MiHome
//
//  Created by Lynn on 10/16/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"

@interface MHLuWebViewController : MHLuViewController<UIWebViewDelegate, UIGestureRecognizerDelegate>//


@property (nonatomic, copy) NSURL* URL;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NJKWebViewProgressView *progressView;

- (id)initWithURL:(NSURL *)URL;
- (void)loadRequest;

- (BOOL)goBack;

#pragma mark - cookies
-(void)addCookie:(NSString *)name value:(NSString *)value domains:(NSArray *)domains;

-(void)addCookie:(NSString *)name value:(NSString *)value domain:(NSString *)domain;

-(void)clearCookie:(NSString *)name domains:(NSArray *)domains;

@end
