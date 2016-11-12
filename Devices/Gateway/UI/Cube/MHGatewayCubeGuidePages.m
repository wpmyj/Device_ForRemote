//
//  MHGatewayCubeGuidePages.m
//  MiHome
//
//  Created by guhao on 3/11/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayCubeGuidePages.h"
#import "MHColorUtils.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MHGatewayWebViewController.h"
#import "MHLumiHtmlHandleTools.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#define PanelColor  (0xefeff0)
//http://192.168.0.119:8081/web/magicCube.html
#define kFlip90_URL     @"http://files.fds.api.xiaomi.com/lumi-app/icon/flip90.gif"
#define kFlip180_URL    @"http://files.fds.api.xiaomi.com/lumi-app/icon/flip180.gif"
#define kMove_URL       @"http://files.fds.api.xiaomi.com/lumi-app/icon/move.gif"
#define kTap_twice_URL  @"http://files.fds.api.xiaomi.com/lumi-app/icon/tap_twice.gif"
#define kShakeair_URL   @"http://files.fds.api.xiaomi.com/lumi-app/icon/shake_air.gif"
#define kRotate_URL     @"http://files.fds.api.xiaomi.com/lumi-app/icon/rotate.gif"

#define kFlip90_Text     NSLocalizedStringFromTable(@"mydevice.gateway.sensor.cube.flip90",@"plugin_gateway","90")
#define kFlip180_Text    NSLocalizedStringFromTable(@"mydevice.gateway.sensor.cube.flip180",@"plugin_gateway","180")
#define kMove_Text       NSLocalizedStringFromTable(@"mydevice.gateway.sensor.cube.move",@"plugin_gateway","move")
#define kTap_twice_Text  NSLocalizedStringFromTable(@"mydevice.gateway.sensor.cube.tap_twice",@"plugin_gateway","tap")
#define kShakeair_Text   NSLocalizedStringFromTable(@"mydevice.gateway.sensor.cube.shake_air",@"plugin_gateway","shake")
#define kRotate_Text     NSLocalizedStringFromTable(@"mydevice.gateway.sensor.cube.rotate",@"plugin_gateway","rotate")




@interface MHGatewayCubeGuidePages ()<UIWebViewDelegate, NJKWebViewProgressDelegate>
@property (nonatomic, retain) UIView* panelView;
@property (nonatomic, assign) CGRect panelFrame;

@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UIButton *lastBtn;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *pauseBtn;

@property (nonatomic, strong) UILabel *gifLabel;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *gifImageView;
@property (nonatomic, strong) UIImageView *donwload;

@property (nonatomic, strong) UIWebView *imageWebView;

@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) NSArray *tipsArray;

@property (nonatomic, assign) NSUInteger currentPage;

@property (nonatomic, strong) NJKWebViewProgressView *progressView;


@end

@implementation MHGatewayCubeGuidePages{
    BOOL _isAnimation;
    NJKWebViewProgress *_progressProxy;

}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _currentPage = 0;
        _imageArray = @[ kFlip90_URL, kFlip180_URL, kMove_URL, kTap_twice_URL, kRotate_URL ];//, 
        _tipsArray = @[ kFlip90_Text, kFlip180_Text, kMove_Text, kTap_twice_Text,  kRotate_Text ];//kShakeair_Text,
        
        [self buildSubViews];
    }
    return self;
}

- (void)buildSubViews {
    self.backgroundColor = [MHColorUtils colorWithRGB:0 alpha:0.7];
    self.userInteractionEnabled = YES;
    

    
    _imageWebView = [[UIWebView alloc] init];
    _imageWebView.layer.cornerRadius = 5.0f;
    _imageWebView.hidden = YES;
    [self addSubview:_imageWebView];

    _tipsLabel = [[UILabel alloc] init];
    _tipsLabel.font = [UIFont systemFontOfSize:16.0f];
    _tipsLabel.textAlignment = NSTextAlignmentCenter;
    _tipsLabel.textColor = [UIColor whiteColor];
    _tipsLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.cube.actionDemo",@"plugin_gateway","动作演示");
    [self addSubview:_tipsLabel];

    
    _closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_closeBtn setBackgroundImage:[UIImage imageNamed:@"lumi_cube_closeguide"] forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(closeGuidepage:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_closeBtn];
    
    _pauseBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_pauseBtn setBackgroundImage:[UIImage imageNamed:@"lumi_fm_play_big"] forState:UIControlStateNormal];
    [_pauseBtn addTarget:self action:@selector(playGuide:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_pauseBtn];
    
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:CGRectMake(0, 0, 200 * ScaleWidth, 3)];
    _progressView.fadeOutDelay = 0.27;
    _progressView.barAnimationDuration = 0.27;
    _progressView.fadeAnimationDuration = 0.5;
    [self.imageWebView addSubview:_progressView];
    
    XM_WS(weakself);
    _progressProxy = [[NJKWebViewProgress alloc] init]; // instance variable
    _imageWebView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    _progressProxy.progressBlock = ^(float progress) {
        [weakself.progressView setProgress:progress animated:YES];
    };

    
    
}
+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    [self buildConstraints];
    
    [super updateConstraints];
}

- (void)buildConstraints {
    XM_WS(weakself);
    CGFloat bgSize = 200 * ScaleWidth;
//    CGFloat verizontalSpacing = 40 * ScaleWidth;
    CGFloat spacing = 100 * ScaleHeight;
    CGFloat tipsSpacing = 50 * ScaleHeight;
//    CGFloat pauseBtnSize = 45.0f;
    CGFloat closeBtnSize = 33.0f;
    
//    CGFloat lastBtnWidth = 15.0f;
//    CGFloat lastBtnHeight = 30.0f;
//    
//    CGFloat nextBtnWidth = 15.0f;
//    CGFloat nextBtnHeight = 30.0f;
//    
//    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(weakself);
//        make.size.mas_equalTo(CGSizeMake(bgSize, bgSize));
//    }];
    
    [_imageWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakself);
        make.size.mas_equalTo(CGSizeMake(bgSize, bgSize));
    }];

    
//    [_gifImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(weakself.bgView);
//                make.size.equalTo(weakself.bgView);
//    }];
//    
//    [_gifLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.mas_equalTo(weakself.imageWebView.mas_bottom);
//        make.right.mas_equalTo(weakself.imageWebView.mas_right);
//    }];
//
    [_tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(weakself.mas_centerY).with.offset(-tipsSpacing);
        make.bottom.equalTo(weakself.imageWebView.mas_top).with.offset(-tipsSpacing);
        make.centerX.equalTo(weakself);
    }];
//
//    [_nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(weakself.bgView);
//        make.size.mas_equalTo(CGSizeMake(nextBtnWidth, nextBtnHeight));
//        make.left.mas_equalTo(weakself.bgView.mas_right).with.offset(verizontalSpacing);
//    }];
//    
//    [_lastBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(weakself.bgView);
//        make.size.mas_equalTo(CGSizeMake(lastBtnWidth, lastBtnHeight));
//        make.right.mas_equalTo(weakself.bgView.mas_left).with.offset(-verizontalSpacing);
//    }];
    
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(closeBtnSize, closeBtnSize));
        make.bottom.mas_equalTo(weakself.mas_bottom).with.offset(-spacing);
        make.centerX.equalTo(weakself);
    }];
//    
//    [_pauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(weakself);
//        make.size.mas_equalTo(CGSizeMake(pauseBtnSize, pauseBtnSize));
//    }];
    
    
}


#pragma mark - touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isExitOnClickBg) {
        return;
    }
    if (_cancelBlock) {
        _cancelBlock(nil);
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

#pragma mark - 控制
- (void)nextImage:(id)sender {
    _bgView.hidden = NO;
    self.pauseBtn.hidden = YES;
    if (_bgView.hidden) {
        _bgView.hidden = NO;
    }
    _currentPage++;
    [self updateCurrentPage:_currentPage];
    if (_currentPage == (_imageArray.count - 1)) {
        self.nextBtn.hidden = YES;
    }
    [self loadRequestWithIndex:_currentPage];    
}

- (void)lastImage:(id)sender {
    _currentPage--;
    [self updateCurrentPage:_currentPage];
    if (_currentPage == 0) {
        self.lastBtn.hidden = YES;
    }
    [self loadRequestWithIndex:_currentPage];

}

#pragma mark - 关闭
- (void)setIsExitOnClickBg:(BOOL)isExitOnClickBg {
    _isExitOnClickBg = isExitOnClickBg;
    [self loadImageRequest];
}

- (void)closeGuidepage:(id)sender {
    [[MHTipsView shareInstance] hide];
    [_imageWebView stopLoading];
    [self removeFromSuperview];
}

- (void)loadImageRequest {
    
    NSString *url = nil;
    NSString *currentLanguage = [[MHLumiHtmlHandleTools sharedInstance] currentLanguage];
    if ([currentLanguage hasPrefix:@"zh-Hans"]) {
        url = kCubeMovieURLCN;
    }
    else {
        url = kCubeMovieURLEN;
    }
    _imageWebView.hidden = NO;
    [_imageWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)playGuide:(id)sender {    
    if (self.okBlock) {
        self.okBlock(nil);
    }
    [self removeFromSuperview];
}

- (void)loadRequestWithIndex:(NSInteger)index {
    if (![[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.imageArray[index]]) {
        [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"loading", @"plugin_gateway", nil) modal:NO];
    }
    XM_WS(weakself);
    [_gifImageView sd_setImageWithURL:[NSURL URLWithString:self.imageArray[index]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MHTipsView shareInstance] hide];
        });
        [weakself downloadImage:index];
    }];
}

- (void)downloadImage:(NSInteger)index {
    XM_WS(weakself);
    if (index != [weakself.imageArray count] - 1) {
        NSString *strURL = weakself.imageArray[index + 1];
        if (![[SDImageCache sharedImageCache] imageFromDiskCacheForKey:strURL]) {
            [weakself.donwload sd_setImageWithURL:[NSURL URLWithString:strURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if ((index + 1) != [weakself.imageArray count] - 1) {
                    [weakself downloadImage:index + 1];
                }
            }];
            
        }
    }

}

- (void)updateCurrentPage:(NSUInteger)currentPage {
    _tipsLabel.text = _tipsArray[currentPage];
    if (currentPage == 0) {
        self.lastBtn.hidden = YES;
    }
    else {
        self.lastBtn.hidden = NO;
    }
    if (currentPage == _imageArray.count - 1) {
        self.nextBtn.hidden = YES;
    }
    else {
        self.nextBtn.hidden = NO;
        
    }

}



@end
