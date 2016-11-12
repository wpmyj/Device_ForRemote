//
//  MHGatewayCheckUpdateView.m
//  MiHome
//
//  Created by Lynn on 3/11/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayCheckUpdateView.h"
#import "AppDelegate.h"
#import "MHTipsViewController.h"

#define ButtonHeight 46.f

static MHGatewayCheckUpdateView* gTipsView = nil;

@interface MHGatewayCheckUpdateView ()

@property (nonatomic,strong) UIWindow *window;

@end

@implementation MHGatewayCheckUpdateView
{
    UIView *            _backgroundView;
}

+ (MHGatewayCheckUpdateView *)shareInstance
{
    @synchronized(@"MHGatewayCheckUpdateView_sharedInstance")
    {
        if (gTipsView == nil)
        {
            gTipsView = [[MHGatewayCheckUpdateView alloc] initCheckUpdateView];
        }
    }
    return gTipsView;
}

- (MHGatewayCheckUpdateView *)initCheckUpdateView
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self)
    {
        [self setUserInteractionEnabled:YES];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_backgroundView];
        
        AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        _window = [[UIWindow alloc] initWithFrame:delegate.window.frame];
        _window.windowLevel = UIWindowLevelStatusBar;
        _window.rootViewController = [[MHTipsViewController alloc] init];
        
        switch ([[UIApplication sharedApplication] statusBarOrientation]) {
            case UIInterfaceOrientationPortrait:
                self.transform = CGAffineTransformMakeRotation(0);
                break;
                
            case UIInterfaceOrientationPortraitUpsideDown:
                self.transform = CGAffineTransformMakeRotation(M_PI);
                break;
                
            case UIInterfaceOrientationLandscapeLeft:
                self.transform = CGAffineTransformMakeRotation(-M_PI/2);
                break;
                
            case UIInterfaceOrientationLandscapeRight:
                self.transform = CGAffineTransformMakeRotation(M_PI/2);
                break;
                
            default:
                break;
        }
        _window.hidden = YES;
    }
    return self;
}

- (void)showFMOnMainTread {
    //这个特殊处理，不使用顶层窗口
    _window.hidden = YES;
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate.window addSubview:self];
}

#pragma mark - volume control
- (void)showUpdateViewInfoHeight:(CGFloat)infoViewHeight withInfo:(NSString *)info {
    self.frame = _window.frame;
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    self.isHide = NO;
    
    UIView *wholeBack = [[UIView alloc] initWithFrame:self.frame];
    wholeBack.backgroundColor = [UIColor clearColor];
    [self addSubview:wholeBack];
    
    CGRect infoFrame = CGRectMake(0, WIN_HEIGHT - infoViewHeight, WIN_WIDTH, infoViewHeight);
    UIView *infoViewBack = [[UIView alloc] initWithFrame:infoFrame];
    infoViewBack.backgroundColor = [UIColor whiteColor];
    [self addSubview:infoViewBack];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, WIN_WIDTH, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = info;
    label.textColor = [UIColor colorWithWhite:0.1f alpha:.8f];
    [infoViewBack addSubview:label];
    
    UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnDone setTitle:NSLocalizedStringFromTable(@"checkversion.goupdate",@"plugin_gateway","去更新") forState:(UIControlStateNormal)];
    btnDone.titleLabel.font = [UIFont systemFontOfSize:14];
    btnDone.frame = CGRectMake(35, 80, WIN_WIDTH - 70, ButtonHeight);
    [btnDone setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:(UIControlStateNormal)];
    [btnDone.layer setCornerRadius:ButtonHeight / 2.f];
    btnDone.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    btnDone.layer.borderWidth = 0.5;
    [btnDone addTarget:self action:@selector(onDone:) forControlEvents:(UIControlEventTouchUpInside)];
    [infoViewBack addSubview:btnDone];

    _window.hidden = NO;
    [self performSelectorOnMainThread:@selector(showFMOnMainTread)
                           withObject:nil
                        waitUntilDone:NO];
}

#pragma mark - btn
- (void)onDone:(id)sender {
    if(self.onUpdate)self.onUpdate();
}

#pragma mark - 通用操作
- (void)hide {
    self.window.hidden = YES;
    self.isHide = YES;
    self.gateway = nil;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self removeFromSuperview];
}

@end
