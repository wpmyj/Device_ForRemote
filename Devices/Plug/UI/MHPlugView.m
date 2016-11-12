//
//  MHPlugView.m
//  MiHome
//
//  Created by Woody on 14/11/21.
//  Copyright (c) 2014年 小米移动软件. All rights reserved.
//

#import "MHPlugView.h"
#import "MHWaveAnimation.h"
#import "MHTimerLinesView.h"
#import "MHTimerCircularView.h"
#import <MiHomeKit/MHDeviceUtil.h>
#import <MiHomeKit/XMCoreMacros.h>

#define PlugOnColor     0x41b4e9
#define PlugOffColor    0x939393

#define kHOUR NSLocalizedString(@"mydevice.plug.hour", @"小时")
#define kMINUTE NSLocalizedString(@"mydevice.plug.minute", @"分钟")
#define kREAR NSLocalizedString(@"mydevice.plug.rear", @"后")
#define kALEADY NSLocalizedString(@"mydevice.plug.already", @"已")
#define kON NSLocalizedString(@"mydevice.plug.on", @"开启")
#define kOFF NSLocalizedString(@"mydevice.plug.off", @"关闭")

// 插座高温预警值
#define High_Temperature_Warn   78

@implementation MHPlugView {
    MHPlugItem      _plugItem;
    UIImageView*    _statusImageView;
    UILabel*        _labelStatus; // 插座电源/USB插座 已开启
    UILabel*        _labelCountdownStatus; // 显示2小时20分钟后关闭
    
    UIButton*       _btnPower;
    UIButton*       _btnTimer;
    UIButton*       _btnCountdown;
    
    UILabel*        _labelPower;
    UILabel*        _labelTimer;
    UILabel*        _labelCountdown;
    
    MHTimerLinesView* _timerLines; // 开启时间进度线
    MHTimerCircularView* _timerCircular; // 距离下一状态进度圆
    
    MHDataDeviceTimer* _countdownTimer;
    
    UIImageView*    _backgroundImageView;
    
    UIView*         _shadeView; // 遮罩层
    UIView*         _temperatureFloatView; // 高温弹出的view
    
    void(^_clickCallback)(MHPlugView* );
    void(^_timerCallback)(MHPlugView* );
    
    MHWaveAnimation*    _waveAnimation;
}

- (instancetype)initWithPlugItem:(MHPlugItem)item clickCallback:(void(^)(MHPlugView*))callback{
    if (self = [super init]) {
        _plugItem = item;
        _clickCallback = callback;
        [self buildSubviews];
        [self buildConstraints];
    }
    return self;
}

- (void)timerCallback:(void (^)(MHPlugView *))callback{
    _timerCallback=callback;
}

// 构建子视图
- (void)buildSubviews {
    
    // 设置背景图片
    _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT)];
    [_backgroundImageView setImage:[UIImage imageNamed:@"plug_background_on"]];
    [self addSubview:_backgroundImageView];
    [self sendSubviewToBack:_backgroundImageView];
    
    // 插座显示图标
    _statusImageView = [[UIImageView alloc] init];
    _statusImageView.translatesAutoresizingMaskIntoConstraints = NO;
    if (_plugItem == MHPlugItemPlug) {
        [_statusImageView setImage:[UIImage imageNamed:@"plug_off"]];
    } else {
        [_statusImageView setImage:[UIImage imageNamed:@"plug_usb_off"]];
    }
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(powerOn:)];
    [_statusImageView addGestureRecognizer:tap];
    [self addSubview:_statusImageView];
    
    _waveAnimation = [[MHWaveAnimation alloc] init];
    _waveAnimation.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_waveAnimation];
    
    // 插座显示状态提示 插座电源/USB插座 已开启
    _labelStatus = [[UILabel alloc] init];
    _labelStatus.translatesAutoresizingMaskIntoConstraints = NO;
    _labelStatus.textColor = [MHColorUtils colorWithRGB:0xffffff];
    _labelStatus.font = [UIFont systemFontOfSize:16];
    if (_plugItem == MHPlugItemPlug) {
        _labelStatus.text = [NSString stringWithFormat:@"%@%@%@",NSLocalizedString(@"mydevice.plug.device.title","插座电源"), kALEADY, _isOn?kON:kOFF];
    } else {
        _labelStatus.text = [NSString stringWithFormat:@"%@%@%@",NSLocalizedString(@"mydevice.plug.plugUsb.title","插座USB"), kALEADY,_isOn?kON:kOFF];
    }
    [self addSubview:_labelStatus];
    
    // 显示2小时20分钟后关闭
    _labelCountdownStatus = [[UILabel alloc] init];
    _labelCountdownStatus.translatesAutoresizingMaskIntoConstraints = NO;
    _labelCountdownStatus.textColor = [MHColorUtils colorWithRGB:0xffffff alpha:0.5];
    _labelCountdownStatus.font = [UIFont systemFontOfSize:13.0];
    [self addSubview:_labelCountdownStatus];
    
    
    // 开关按钮
    _btnPower = [[UIButton alloc] init];
    [_btnPower setBackgroundImage:[UIImage imageNamed:@"power_on"] forState:UIControlStateNormal];
    [_btnPower setBackgroundImage:[UIImage imageNamed:@"power_pressed"] forState:UIControlStateHighlighted];
    [_btnPower addTarget:self action:@selector(powerOn:) forControlEvents:UIControlEventTouchUpInside];
    _btnPower.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_btnPower];
    
    _labelPower = [[UILabel alloc] init];
    _labelPower.text = NSLocalizedString(@"mydevice.plug.power", @"开关");
    _labelPower.font = [UIFont systemFontOfSize:13.0];
    [_labelPower setTextColor:[MHColorUtils colorWithRGB:0xffffff alpha:0.8]];
    _labelPower.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_labelPower];
    
    // 定时按钮
    _btnTimer = [[UIButton alloc] init];
    [_btnTimer setBackgroundImage:[UIImage imageNamed:@"timer_on"] forState:UIControlStateNormal];
    [_btnTimer setBackgroundImage:[UIImage imageNamed:@"timer_pressed"] forState:UIControlStateHighlighted];
    [_btnTimer addTarget:self action:@selector(timerOn:) forControlEvents:UIControlEventTouchUpInside];
    _btnTimer.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_btnTimer];
    
    _labelTimer = [[UILabel alloc] init];
    _labelTimer.text = NSLocalizedString(@"mydevice.plug.timer", @"定时");
    _labelTimer.font = [UIFont systemFontOfSize:13.0];
    [_labelTimer setTextColor:[MHColorUtils colorWithRGB:0xffffff alpha:0.8]];
    _labelTimer.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_labelTimer];
    
    // 倒计时按钮
    _btnCountdown = [[UIButton alloc] init];
    [_btnCountdown setBackgroundImage:[UIImage imageNamed:@"countdown_on"] forState:UIControlStateNormal];
    [_btnCountdown setBackgroundImage:[UIImage imageNamed:@"countdown_pressed"] forState:UIControlStateHighlighted];
    [_btnCountdown addTarget:self action:@selector(countdownOn:) forControlEvents:UIControlEventTouchUpInside];
    _btnCountdown.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_btnCountdown];
    
    _labelCountdown = [[UILabel alloc] init];
    _labelCountdown.text = NSLocalizedString(@"mydevice.plug.countdown", @"倒计时");
    _labelCountdown.font = [UIFont systemFontOfSize:13.0];
    [_labelCountdown setTextColor:[MHColorUtils colorWithRGB:0xffffff alpha:0.8]];
    _labelCountdown.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_labelCountdown];
    
    // 定时进度线条
    _timerLines = [[MHTimerLinesView alloc] initWithFrame:CGRectMake(0, 600 * ScaleHeight, WIN_WIDTH, 20)];
    [self addSubview:_timerLines];
    
    // 距离下一状态进度圆
    _timerCircular = [[MHTimerCircularView alloc] init];
    _timerCircular.translatesAutoresizingMaskIntoConstraints = NO;
    _timerCircular.userInteractionEnabled = NO;
    [self addSubview:_timerCircular];
    
    // 遮罩层view
    _shadeView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT)];
    _shadeView.hidden = YES;
    [_shadeView setBackgroundColor:[MHColorUtils colorWithRGB:0x000000 alpha:0.5]];
    [self addSubview:_shadeView];
    
    // 高温的警告view
    _temperatureFloatView = [[UIView alloc] initWithFrame:CGRectMake(0, WIN_HEIGHT, WIN_WIDTH, 239*ScaleHeight)];
    _temperatureFloatView.backgroundColor = [MHColorUtils colorWithRGB:0xffffff];
    
    float labelTitleX = 30*ScaleWidth;
    float labelTitleY = 20*ScaleHeight;
    float labelTitleW = WIN_WIDTH-labelTitleX*2;
    float labelTitleH = 30;
    UILabel* labelTempTitle = [[UILabel alloc] initWithFrame:CGRectMake(labelTitleX, labelTitleY,labelTitleW, labelTitleH)];
    labelTempTitle.text = @"插座温度过高，请检查原因后使用！";
    labelTempTitle.font = [UIFont systemFontOfSize:16.0];
    [labelTempTitle setTextColor:[MHColorUtils colorWithRGB:0x333333]];
    [_temperatureFloatView addSubview:labelTempTitle];
    
    float btnWidth = 333*ScaleWidth;
    float btnHeight = 39*ScaleHeight;
    float btnX = (WIN_WIDTH-btnWidth)/2.0;
    float btnY = (239-20)*ScaleHeight-btnHeight;
    
    float labelContentY = labelTitleY+labelTitleH;
    float labelContentH = (239-20-20)*ScaleHeight - btnHeight - labelTitleH;
    UILabel* labelTempContent = [[UILabel alloc] initWithFrame:CGRectMake(labelTitleX, labelContentY, labelTitleW,labelContentH)];
    labelTempContent.text = @"1. 用电设备功率可能超过最大限值\n2. 与智能插座插头连接的交流电插孔内部可能存在\n   生锈松动等情况\n3. 用电设备的插头可能存在老化生锈等情况\n4. 智能插座所处环境的温度可能过高";
    labelTempContent.font = [UIFont systemFontOfSize:13.0];
    labelTempContent.numberOfLines = 0;
    labelTempContent.contentMode = UIViewContentModeTop;
    [labelTempContent setTextColor:[MHColorUtils colorWithRGB:0x666666]];
    [_temperatureFloatView addSubview:labelTempContent];
    
    UIButton* btnTemp = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnWidth, btnHeight)];
    [btnTemp setBackgroundImage:[UIImage imageNamed:@"countdown_button_normal"] forState:UIControlStateNormal];
    [btnTemp setBackgroundImage:[UIImage imageNamed:@"countdown_button_press"] forState:UIControlStateHighlighted];
    [btnTemp setTitle:@"我知道了" forState:UIControlStateNormal];
    [btnTemp.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [btnTemp setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:UIControlStateNormal];
    [btnTemp addTarget:self action:@selector(temperatureAlertClose) forControlEvents:UIControlEventTouchUpInside];
    [_temperatureFloatView addSubview:btnTemp];
    
    [self addSubview:_temperatureFloatView];
}

// 构建AutoLayout约束
- (void)buildConstraints {
    CGFloat vShortScreen = 0;
    if (![MHDeviceUtil isDeviceLongScreen]) {
        vShortScreen -= 30;
    }
    
    CGFloat vBtnStatusTop = 153 * ScaleHeight + vShortScreen;
    CGFloat vBtnTop = 473 * ScaleHeight;
    CGFloat vBtnStatusBottom = 22 * ScaleHeight;
    CGFloat vLabelStatusBottom = 10 * ScaleHeight;
    CGFloat vBtnBottom = 14 * ScaleHeight;
    
    CGFloat hSpacing = 65 * ScaleWidth;
    
    NSDictionary* metrics = @{@"vBtnStatusTop" : @(vBtnStatusTop),
                              @"vBtnTop" : @(vBtnTop),
                              @"vBtnStatusBottom" : @(vBtnStatusBottom),
                              @"vLabelStatusBottom" : @(vLabelStatusBottom),
                              @"vBtnBottom" : @(vBtnBottom)};
    
    NSDictionary* views = @{@"btnStatus" : _statusImageView,
                            @"waveAnimation" : _waveAnimation,
                            @"timerCircular" : _timerCircular,
                            @"labelStatus" : _labelStatus,
                            @"labelCountdownStatus" : _labelCountdownStatus,
                            @"btnPower" : _btnPower,
                            @"btnTimer" : _btnTimer,
                            @"btnCountdown" : _btnCountdown,
                            @"labelPower" : _labelPower,
                            @"labelTimer" : _labelTimer,
                            @"labelCountdown" : _labelCountdown};
    
    NSLayoutConstraint* btnCenterX = [NSLayoutConstraint constraintWithItem:_statusImageView
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1.f constant:0];
    NSArray* constraintV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vBtnStatusTop-[btnStatus]-vBtnStatusBottom-[labelStatus]-vLabelStatusBottom-[labelCountdownStatus]"
                                                                   options:NSLayoutFormatAlignAllCenterX
                                                                   metrics:metrics
                                                                     views:views];
    [self addConstraint:btnCenterX];
    [self addConstraints:constraintV];
    
    
    NSLayoutConstraint* waveCenterX = [NSLayoutConstraint constraintWithItem:_waveAnimation attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    NSLayoutConstraint* waveTop = [NSLayoutConstraint constraintWithItem:_waveAnimation attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_statusImageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint* waveWidth = [NSLayoutConstraint constraintWithItem:_waveAnimation attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_statusImageView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    NSLayoutConstraint* waveHeight = [NSLayoutConstraint constraintWithItem:_waveAnimation attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_statusImageView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    [self addConstraint:waveCenterX];
    [self addConstraint:waveTop];
    [self addConstraint:waveWidth];
    [self addConstraint:waveHeight];
    
    
    NSLayoutConstraint* timerCircularCenterX = [NSLayoutConstraint constraintWithItem:_timerCircular attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    NSLayoutConstraint* timerCircularTop = [NSLayoutConstraint constraintWithItem:_timerCircular attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_statusImageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint* timerCircularWidth = [NSLayoutConstraint constraintWithItem:_timerCircular attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_statusImageView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    NSLayoutConstraint* timerCircularHeight = [NSLayoutConstraint constraintWithItem:_timerCircular attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_statusImageView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    [self addConstraint:timerCircularCenterX];
    [self addConstraint:timerCircularTop];
    [self addConstraint:timerCircularWidth];
    [self addConstraint:timerCircularHeight];
    
    
    NSArray* constraintV1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vBtnTop-[btnPower]-vBtnBottom-[labelPower]" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:views];
    NSArray* constraintV2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vBtnTop-[btnTimer]-vBtnBottom-[labelTimer]" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:views];
    NSArray* constraintV3 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vBtnTop-[btnCountdown]-vBtnBottom-[labelCountdown]" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:views];
    
    NSLayoutConstraint* powerX = [NSLayoutConstraint constraintWithItem:_btnPower attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:hSpacing];
    NSLayoutConstraint* timerX = [NSLayoutConstraint constraintWithItem:_btnTimer attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    NSLayoutConstraint* countdownX = [NSLayoutConstraint constraintWithItem:_btnCountdown attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-hSpacing];
    [self addConstraints:constraintV1];
    [self addConstraints:constraintV2];
    [self addConstraints:constraintV3];
    [self addConstraint:powerX];
    [self addConstraint:timerX];
    [self addConstraint:countdownX];
}

- (void)setIsOn:(BOOL)isOn {
    _isOn = isOn;
    [_waveAnimation stopAnimation];
    [self showLabelCountdownStatus];
    if (_plugItem == MHPlugItemPlug) {
        if (_isOn) {
            [_statusImageView setImage:[UIImage imageNamed:@"plug_on"]];
            [_backgroundImageView setImage:[UIImage imageNamed:@"plug_background_on"]];
        } else {
            [_statusImageView setImage:[UIImage imageNamed:@"plug_off"]];
            [_backgroundImageView setImage:[UIImage imageNamed:@"plug_background_off"]];
        }
    } else {
        if (_isOn) {
            [_statusImageView setImage:[UIImage imageNamed:@"plug_usb_on"]];
            [_backgroundImageView setImage:[UIImage imageNamed:@"plug_background_on"]];
        } else {
            [_statusImageView setImage:[UIImage imageNamed:@"plug_usb_off"]];
            [_backgroundImageView setImage:[UIImage imageNamed:@"plug_background_off"]];
        }
    }
    _statusImageView.userInteractionEnabled  = YES;
}

// 开关插座
- (void)powerOn:(id)sender {
    if (_temperature>=High_Temperature_Warn && !_isOn) {
        [self temperatureAlertOpen];
        return; 
    }
    
    _waveAnimation.waveColor = _isOn ? ([MHColorUtils colorWithRGB:PlugOnColor]) : ([MHColorUtils colorWithRGB:PlugOffColor]);
    [_waveAnimation startAnimation];
    _statusImageView.userInteractionEnabled  = NO;
    if (_clickCallback) {
        _clickCallback(self);
    }
}

// 定时列表
- (void)timerOn:(id)sender {
    if (_temperature<High_Temperature_Warn && _timerCallback) {
        _timerCallback(self);
    }
    
    if (_temperature>=High_Temperature_Warn) {
        [self temperatureAlertOpen];
    }
}

// 倒计时
- (void)countdownOn:(id)sender {
    if (_temperature<High_Temperature_Warn && self.countdown) {
        self.countdown(_isOn,_plugItem);
    }
    
    if (_temperature>=High_Temperature_Warn) {
        [self temperatureAlertOpen];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_temperature>=High_Temperature_Warn) {
        [self updateHeatUI];
    }
}

// 更新时间进度线条
- (void)updateTimerProgressView:(NSMutableArray*)timerAllLineslist countdownTimer:(MHDataDeviceTimer *)countdownTimer {
    _timerLines.timerAllLineslist = timerAllLineslist;
    _timerCircular.countdownTimer = _countdownTimer = countdownTimer;
    
    [_timerLines setNeedsDisplay];
    [_timerCircular setNeedsDisplay];
    [self showLabelCountdownStatus];
}

// 高温背景显示
- (void)updateHeatUI {
    [_statusImageView setImage:[UIImage imageNamed:@"plug_heat_alert"]];
    [_backgroundImageView setImage:[UIImage imageNamed:@"plug_background_heat"]];
    
    _timerCircular.hidden = YES;
    _labelStatus.text = @"插座温度过高";
    _labelCountdownStatus.text = @"请检查原因后再使用";
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    
    if (_temperature>=High_Temperature_Warn && _temperatureFloatView.frame.origin.y==WIN_HEIGHT) {
        [self temperatureAlertOpen];
    } else {
        [self temperatureAlertClose];
    }
    [UIView commitAnimations];
}

// 插座高温弹出框打开
- (void)temperatureAlertOpen {
    CGRect frame = _temperatureFloatView.frame;
    frame.origin.y = WIN_HEIGHT - _temperatureFloatView.frame.size.height;
    _temperatureFloatView.frame = frame;
    
    _shadeView.hidden = NO;
    _labelStatus.text = @"插座温度过高";
    _labelCountdownStatus.text = @"请检查原因后再使用";
}

// 插座高温弹出框关闭
- (void)temperatureAlertClose {
    CGRect frame = _temperatureFloatView.frame;
    frame.origin.y = WIN_HEIGHT;
    _temperatureFloatView.frame = frame;
    
    _shadeView.hidden = YES;
    
    [self showLabelCountdownStatus];
}

// 显示插座电源的状态和下一状态的倒计时
- (void)showLabelCountdownStatus {
    if (_plugItem == MHPlugItemPlug) {
        _labelStatus.text = [NSString stringWithFormat:@"%@%@%@",NSLocalizedString(@"mydevice.plug.device.title","插座电源"), kALEADY, _isOn?kON:kOFF];
    } else {
        _labelStatus.text = [NSString stringWithFormat:@"%@%@%@",NSLocalizedString(@"mydevice.plug.plugUsb.title","插座USB"), kALEADY,_isOn?kON:kOFF];
    }
    
    int hour = (int)_countdownTimer.onHour;
    int minute = (int)_countdownTimer.onMinute;
    if (hour<1) {
        if (minute == 0) {
            _labelCountdownStatus.text = @"";
        } else {
            _labelCountdownStatus.text = [NSString stringWithFormat:@"%d%@%@%@", minute, kMINUTE, kREAR, !_countdownTimer.isOnOpen ? kOFF : kON];
        }
    } else {
        if (hour==24) {  minute = 0; }
        if (minute==0) { // 0分钟，只显示小时
            _labelCountdownStatus.text = [NSString stringWithFormat:@"%d%@%@%@",hour, kHOUR, kREAR, !_countdownTimer.isOnOpen ? kOFF : kON];
        } else {
            _labelCountdownStatus.text = [NSString stringWithFormat:@"%d%@%d%@%@%@", hour, kHOUR, minute, kMINUTE, kREAR, !_countdownTimer.isOnOpen ? kOFF : kON];
        }
    }
}

@end
