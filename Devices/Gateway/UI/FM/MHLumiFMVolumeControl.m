//
//  MHLumiFMVolumeControl.m
//  MiHome
//
//  Created by Lynn on 12/24/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLumiFMVolumeControl.h"
#import "AppDelegate.h"
#import "MHTipsViewController.h"
#import "MHGatewayNumberSliderView.h"

static MHLumiFMVolumeControl* gTipsView = nil;

@interface MHLumiFMVolumeControl () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,strong) UIWindow *window;
@property (nonatomic, strong) MHGatewayNumberSliderView *sliderView;

@end

@implementation MHLumiFMVolumeControl
{
    UIView *            _backgroundView;
    UIView *            _backView;
    UIView *            _wholeBack;
    
    UITableView *       _tableView;
    NSArray *           _dataSource;
}

+ (MHLumiFMVolumeControl *)shareInstance
{
    @synchronized(@"MHLumiFMVolumeControl_sharedInstance")
    {
        if (gTipsView == nil)
        {
            gTipsView = [[MHLumiFMVolumeControl alloc] initFMPlayerVolume];
        }
    }
    return gTipsView;
}

- (MHLumiFMVolumeControl *)initFMPlayerVolume
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
    for (UIView *obj in delegate.window.subviews) {
        if ([obj isKindOfClass:[MHGatewayPopupView class]]) {
            [delegate.window bringSubviewToFront:obj];
        }
    }
}

#pragma mark - volume control
- (void)showVolumeControl:(CGFloat)yPosition withVolumeValue:(NSInteger)volumeValue {
    self.frame = _window.frame;
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    self.isHide = NO;

    CGRect playerFrame = CGRectMake(0, yPosition, ScreenWidth, VolumePlayerHeight);
    if(!_wholeBack){
        _wholeBack = [[UIView alloc] initWithFrame:self.frame];
        _wholeBack.backgroundColor = [UIColor clearColor];
        [self addSubview:_wholeBack];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [_wholeBack addGestureRecognizer:tap];
    }
    
    if(!_backView){
        _backView = [[UIView alloc] initWithFrame:playerFrame];
        _backView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_backView];
    }
    
    [self firstConstruct:volumeValue withYPosition:yPosition];
    
    NSInteger oldVolumeValue = volumeValue;
    XM_WS(weakself);
    [self.gateway fetchRadioDeviceStatusWithSuccess:^(id obj) {
        if(obj && weakself.gateway.fm_volume != oldVolumeValue){
            [weakself.sliderView configureConstruct:weakself.gateway.fm_volume];
        }
    } andFailure:nil];
    
    _window.hidden = NO;
    [self performSelectorOnMainThread:@selector(showFMOnMainTread)
                           withObject:nil
                        waitUntilDone:NO];
}

#pragma mark - 数值控制
- (void)showNumberControl:(CGFloat)yPosition withNewValue:(NSInteger)newValue WithNumberType:(NSInteger)numberType {
    self.frame = _window.frame;
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    self.isHide = NO;
    
    CGRect playerFrame = CGRectMake(0, yPosition, ScreenWidth, VolumePlayerHeight);
    if(!_wholeBack){
        _wholeBack = [[UIView alloc] initWithFrame:self.frame];
        _wholeBack.backgroundColor = [UIColor clearColor];
        [self addSubview:_wholeBack];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [_wholeBack addGestureRecognizer:tap];
    }
    
    if(!_backView){
        _backView = [[UIView alloc] initWithFrame:playerFrame];
        _backView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_backView];
    }
    
    [self firstConstruct:newValue withYPosition:yPosition WithNumberType:numberType];
    
    NSInteger oldVolumeValue = newValue;
    XM_WS(weakself);
    switch (numberType) {
        case NumberType_Brightness: {
            [self.gateway fetchRadioDeviceStatusWithSuccess:^(id obj) {
                if(obj && (weakself.gateway.night_light_rgb >> 24) != oldVolumeValue){
                    [weakself.sliderView configureConstruct:(weakself.gateway.night_light_rgb >> 24)];
                }
            } andFailure:nil];

            break;
        }
        default:
            break;
    }
    _window.hidden = NO;
    [self performSelectorOnMainThread:@selector(showFMOnMainTread)
                           withObject:nil
                        waitUntilDone:NO];

}

- (void)firstConstruct:(NSInteger)value withYPosition:(CGFloat)yPosition{
    XM_WS(weakself);
    if(!_sliderView){
        _sliderView = [[MHGatewayNumberSliderView alloc] initWithFrame:CGRectMake(0, yPosition, WIN_WIDTH, VolumePlayerHeight)];
        _sliderView.minusImageName = @"lumi_fm_plauer_volminus";
        _sliderView.plusImageName = @"lumi_fm_plauer_voladd";
        [self addSubview:_sliderView];
    }
    [_sliderView configureConstruct:value];
    _sliderView.numberControlCallBack = ^(NSInteger value, NSString *type){
        if (weakself.volumeControlCallBack) {
            weakself.volumeControlCallBack(value);
        }
    };
}

- (void)firstConstruct:(NSInteger)value withYPosition:(CGFloat)yPosition WithNumberType:(NSInteger)numberType{
    XM_WS(weakself);
    if(!_sliderView){
        _sliderView = [[MHGatewayNumberSliderView alloc] initWithFrame:CGRectMake(0, yPosition, WIN_WIDTH, VolumePlayerHeight)];
        switch (numberType) {
            case NumberType_Brightness: {
                _sliderView.minusImageName = @"gateway_brightness_minus_icon";
                _sliderView.plusImageName = @"gateway_brightness_plus_icon";
                _sliderView.MinimumValue = 3;
                break;
            }
            default: {
                _sliderView.minusImageName = @"lumi_fm_plauer_volminus";
                _sliderView.plusImageName = @"lumi_fm_plauer_voladd";
                break;
            }
        }

        [self addSubview:_sliderView];
    }
    [_sliderView configureConstruct:value];
    _sliderView.numberControlCallBack = ^(NSInteger value, NSString *type){
        if (weakself.volumeControlCallBack) {
            weakself.volumeControlCallBack(value);
        }
    };

}
#pragma mark - timer control
- (void)showTimerControler:(CGFloat)yPosition withTimerList:(NSArray *)timerList {
    self.frame = _window.frame;
    
    if(!_backView){
        _backView = [[UIView alloc] initWithFrame:self.frame];
        _backView.backgroundColor = [UIColor clearColor];
        [self addSubview:_backView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [_backView addGestureRecognizer:tap];
    }
    
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    self.isHide = NO;
    
    [self firstConstructListView:timerList withYPosition:yPosition];
    
    _window.hidden = NO;
    [self performSelectorOnMainThread:@selector(showFMOnMainTread)
                           withObject:nil
                        waitUntilDone:NO];

}


- (void)firstConstructListView:(NSArray *)valuelist withYPosition:(CGFloat)yPosition {
    _dataSource = valuelist;
    
    CGRect playerFrame = CGRectMake(0, yPosition, ScreenWidth, ListControlHeight);
    _tableView = [[UITableView alloc] initWithFrame:playerFrame style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self addSubview:_tableView];
}

#pragma mark : tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ListCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusedCellIndentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCellIndentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedCellIndentifier];
    }
    
    cell.textLabel.text = _dataSource[indexPath.row];
    cell.textLabel.textColor = [MHColorUtils colorWithRGB:0x333333];
    cell.textLabel.font = [UIFont systemFontOfSize:15.f];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.timerControlCallBack) self.timerControlCallBack(_dataSource[indexPath.row]);
    [self hide];
}

#pragma mark - 通用操作
- (void)hide {
    self.window.hidden = YES;
    self.isHide = YES;
    self.gateway = nil;
    
    [_tableView removeFromSuperview];
    _tableView = nil;
    [self removeFromSuperview];
}
@end