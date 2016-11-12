//
//  MHACPartnerCountdownViewController.m
//  MiHome
//
//  Created by ayanami on 16/7/8.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerCountdownViewController.h"
#import "DragCircularSlider.h"
#import "LineProgressView.h"
#import "MHPlugCountdownTableView.h"
#import "MHTimerPicker.h"
#import "XMCoreMacros.h"

#define TableHeight     (270 * ScaleHeight)
#define ProgressHeight  (WIN_HEIGHT - TableHeight)

#define kHOUR NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.countdown.hour", @"plugin_gateway",@"小时")
#define kMINUTE NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.countdown.minute", @"plugin_gateway",@"分钟")
#define kREAR NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.countdown.rear",@"plugin_gateway", @"后")
#define kON NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.countdown.on",@"plugin_gateway", @"开启")
#define kOFF NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.countdown.off", @"plugin_gateway",@"关闭")


@interface MHACPartnerCountdownViewController ()
@property (nonatomic,strong) DragCircularSlider *dragCircular;
@property (nonatomic, strong) MHDeviceAcpartner *acpartner;
@property (nonatomic, strong) UILabel *countdownLabel;


@end

@implementation MHACPartnerCountdownViewController {
    LineProgressView *                  _lineProgressView;
    
    UIButton*                           _startBtn; // 启动
    UIButton*                           _cancelBtn; // 取消
    
    UIImageView*                        _backgroundImageView;
    MHPlugCountdownTableView*           _countdownTableView;
    NSArray*                            _countdownArray;
    NSArray*                            _countdownArrayValue;
    BOOL                                _isFirstCountdownTimer;
}

- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner
{
    self = [super init];
    if (self) {
        self.acpartner = acpartner;
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isNavBarTranslucent = YES;
    self.isTabBarHidden = YES;
    _isFirstCountdownTimer = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // 设置背景图片
    _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, ProgressHeight)];
    _backgroundImageView.backgroundColor = [MHColorUtils colorWithRGB:0x202f3b];
    [self.view addSubview:_backgroundImageView];
    [self.view sendSubviewToBack:_backgroundImageView]; //   将图片转化为背景
    
    [self countDelayTIme];
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.footer.delayoff",@"plugin_gateway","延时关");

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{ NSForegroundColorAttributeName : [MHColorUtils colorWithRGB:0xffffff],
                               NSFontAttributeName            : [UIFont systemFontOfSize:18.0f]
                               }];
}

- (void)buildSubviews {
    [super buildSubviews];
    
    // 内部竖线粗圆
    float dragDiameter = 248*ScaleWidth; // 拖拽大圆直径 = 260*scaleWidth; // 拖拽大圆直径
    float lineDiameter = 180*ScaleWidth; // 竖线圆直径
    float diffRadius = (dragDiameter - lineDiameter)/2.0;
    _lineProgressView = [[LineProgressView alloc] initWithFrame:CGRectMake((WIN_WIDTH-lineDiameter)/2.0, diffRadius+100*ScaleHeight, lineDiameter, lineDiameter)];
    _lineProgressView.backgroundColor = [UIColor clearColor];
    _lineProgressView.delegate = self;
    _lineProgressView.total = 150; // 线的个数
    _lineProgressView.color = [MHColorUtils colorWithRGB:0xffffff alpha:0.3];
    _lineProgressView.radius = lineDiameter/2.0; // 外圈半径
    _lineProgressView.innerRadius = lineDiameter/2.0-16*ScaleWidth; // 内圈半径
    _lineProgressView.startAngle = -M_PI * 0.5;
    _lineProgressView.endAngle = M_PI * 1.5;
    _lineProgressView.layer.shouldRasterize = NO;
    [self.view addSubview:_lineProgressView];
    
    // 外圈拖拽大圆
    _dragCircular = [[DragCircularSlider alloc] initWithFrame:CGRectMake((WIN_WIDTH-dragDiameter)/2.0, 100*ScaleHeight, dragDiameter, dragDiameter)];
    _dragCircular.unfilledColor = [MHColorUtils colorWithRGB:0xffffff alpha:0.5];
    _dragCircular.lineWidth = 1;
    _dragCircular.minimumValue = 0;
    _dragCircular.maximumValue = 60;
    _dragCircular.countdownImageName = @"plug_countdown_button_off";
    [_dragCircular addTarget:self action:@selector(timeDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_dragCircular];
    
    // 设置倒计时的表格
    [self buildTableSubviews];
    
    // 倒计时启动按钮
    float startHeight = 39*ScaleHeight;
    float startWidth = 333*ScaleWidth;
    _startBtn = [[UIButton alloc] initWithFrame:CGRectMake((WIN_WIDTH-startWidth)/2.0, WIN_HEIGHT-startHeight-11*ScaleHeight, startWidth, startHeight)];
    [_startBtn setBackgroundImage:[UIImage imageNamed:@"countdown_button_normal"] forState:UIControlStateNormal];
    [_startBtn setBackgroundImage:[UIImage imageNamed:@"countdown_button_press"] forState:UIControlStateHighlighted];
    [_startBtn setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.countdown.on",@"plugin_gateway",@"开启") forState:UIControlStateNormal];
    [_startBtn.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    [_startBtn setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:UIControlStateNormal];
    [_startBtn addTarget:self action:@selector(startCountdown) forControlEvents:UIControlEventTouchUpInside];
    _startBtn.hidden = YES;
    [self.view addSubview:_startBtn];
    
    // 倒计时取消按钮
    _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake((WIN_WIDTH-startWidth)/2.0, WIN_HEIGHT-startHeight-11*ScaleHeight, startWidth, startHeight)];
    [_cancelBtn setBackgroundImage:[UIImage imageNamed:@"countdown_button_normal"] forState:UIControlStateNormal];
    [_cancelBtn setBackgroundImage:[UIImage imageNamed:@"countdown_button_press"] forState:UIControlStateHighlighted];
    [_cancelBtn setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.countdown.cancel",@"plugin_gateway",@"取消") forState:UIControlStateNormal];
    [_cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    [_cancelBtn setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(cancelCountdown) forControlEvents:UIControlEventTouchUpInside];
    _cancelBtn.hidden = YES;
    [self.view addSubview:_cancelBtn];
    
    // 显示倒计时数字
    float labelWidth = _lineProgressView.innerRadius*2;
    float labelHeight = 30;
    _countdownLabel = [[UILabel alloc] initWithFrame:CGRectMake((WIN_WIDTH-labelWidth)/2.0, _dragCircular.center.y-labelHeight/2.0, labelWidth, labelHeight)];
    _countdownLabel.textAlignment = NSTextAlignmentCenter;
    float fontSize = 14.0;
    if(WIN_WIDTH<375){ // iphone5等窄屏
        fontSize = 13.0;
    }
    _countdownLabel.font = [UIFont systemFontOfSize:fontSize];
    _countdownLabel.textColor = [UIColor whiteColor];
    if (_hour+_minute>0) {
        [self updateTimerLabelAndDragCircular];
        [self updateDragCircularBtnImage:@"plug_countdown_button_on"];
    } else {
        _countdownLabel.text = [NSString stringWithFormat:@"0%@%@%@", kMINUTE, kREAR,_isOn ? kOFF : kON];
        [self updateDragCircularBtnImage:@"plug_countdown_button_off"];
    }
    
    [self.view addSubview:_countdownLabel];
}

- (void)buildTableSubviews {
    NSString* minute_1 = [NSString stringWithFormat:@"10%@", kMINUTE];
    NSString* minute_3 = [NSString stringWithFormat:@"30%@", kMINUTE];
    NSString* minute_5 = [NSString stringWithFormat:@"50%@", kMINUTE];
    NSString* custom = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.countdown.custom",@"plugin_gateway", @"自定义");
    _countdownArray = [NSArray arrayWithObjects:minute_1, minute_3, minute_5, custom, nil];
    _countdownArrayValue = [NSArray arrayWithObjects:@(10), @(30), @(50), @(500), nil];
    float cellHeigth = 54*ScaleHeight;
    CGRect rect = CGRectMake(0, ProgressHeight, WIN_WIDTH, cellHeigth*_countdownArray.count);
    
    _countdownTableView = [[MHPlugCountdownTableView alloc] initWithTableView:_countdownArray rectFrame:rect];
    
    // 表格选中的回调
    XM_WS(weakself);
    _countdownTableView.selectedCountdownTable = ^(int index){
        if(!weakself.countdownTimer.isEnabled){
            if (index==3) {
                // 弹出MHTimerPicker
                MHTimerPicker* timerPicker = [[MHTimerPicker alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.footer.delayoff",@"plugin_gateway","延时关") timePicked:^(NSUInteger hour, NSUInteger minute){
                    
                    weakself.hour = hour % 24;
                    weakself.minute = minute % 60;
                    weakself.dragCircular.hourValue = (int)weakself.hour;
                    weakself.dragCircular.currentValue = (int)weakself.minute;
                    
                    [weakself updateTimerLabelAndDragCircular];
                    // 改变拖拽按钮位置和角度
                    [weakself updateDragCircularBtnImage:@"plug_countdown_button_off"];
                }];
                [timerPicker showInView:weakself.view.window];
                
            } else { // 显示倒计时动画
                [weakself resetLineCircular:index];
            }
        }
        else{
            [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.countdown.recounttips", @"plugin_gateway", nil) duration:1.5 modal:YES];
        }
    };
    [self.view addSubview:_countdownTableView];
}

- (void)buildConstraints {
    [super buildConstraints];
}

// 外圈拖拽事件
- (void)timeDidChange:(DragCircularSlider* )silder {
    if(_countdownTimer && _isFirstCountdownTimer) {
        _isFirstCountdownTimer = NO;
        silder.currentValue = _minute;
        silder.hourValue = (int)_hour;
    } else { // 无初始值
        _minute = (int)silder.currentValue < silder.maximumValue ? silder.currentValue : 0;
        _hour = silder.hourValue;
    }
    
    [self updateTimerLabelAndDragCircular];
    // 改变拖拽按钮位置和角度
    [self updateDragCircularBtnImage:@"plug_countdown_button_off"];
}

// 改变圆的动画:1,3,5分钟
- (void)resetLineCircular:(int)index {
    _dragCircular.hourValue = _hour = 0;
    _dragCircular.currentValue = _minute = [_countdownArrayValue[index] integerValue];
    
    [self updateTimerLabelAndDragCircular];
    
    // 改变拖拽按钮位置和角度
    [self updateDragCircularBtnImage:@"plug_countdown_button_off"];
}

// 启动倒计时
- (void)startCountdown {
    // 未设置定时时间
    if (_hour==0 && _minute==0) {
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.countdown.failtip",@"plugin_gateway", "请选择倒计时时长") duration:1.5f modal:YES];
    }
    else if ([self.delegate respondsToSelector:@selector(countdownDidStart:)]) {
        // 组装出倒计时timer
        [self getNewCountdownTimer];
        
        [self.delegate countdownDidStart:_countdownTimer];
        
        // 改变拖拽按钮位置和角度
        [self updateDragCircularBtnImage:@"plug_countdown_button_on"];
        [self gw_clickMethodCountWithStatType:@"startCountdown"];
    }
}

// 取消倒计时
- (void)cancelCountdown {
    if ([self.delegate respondsToSelector:@selector(countdownDidDelete:)]) {
        
        [self.delegate countdownDidDelete:_countdownTimer];
        _countdownTimer = nil;
        _hour = _minute = 0;
        
        [self updateTimerLabelAndDragCircular];
        // 改变拖拽按钮位置和角度
        [self updateDragCircularBtnImage:@"plug_countdown_button_off"];
        [self gw_clickMethodCountWithStatType:@"cancelCountdown"];
    }
}

// 更新倒计时数字和拖拽按钮
- (void)updateTimerLabelAndDragCircular {
    
    if(self.countdownTimer.isEnabled) {
        if(self.countdownTimer.isOnOpen) _isOn = NO;
        if(self.countdownTimer.isOffOpen) _isOn = YES;
    }
    
    _dragCircular.isCanTouch = YES; // 按钮可以拖动
    if (_hour<1) {
        _countdownLabel.text = [NSString stringWithFormat:@"%ld%@%@%@",(long)_minute, kMINUTE, kREAR, _isOn ? kOFF : kON];
        // 绘制内部选中加粗的圆
        [_lineProgressView setCompleted:(_lineProgressView.total/60.0)*_minute];
    } else {
        if (_hour==24) {
            _minute = 0;
        }
        if (_minute==0) { // 0分钟，只显示小时
            _countdownLabel.text = [NSString stringWithFormat:@"%ld%@%@%@",(long)_hour, kHOUR, kREAR, _isOn ? kOFF : kON];
        } else {
            _countdownLabel.text = [NSString stringWithFormat:@"%ld%@%ld%@%@%@",(long)_hour, kHOUR, (long)_minute, kMINUTE, kREAR, _isOn ? kOFF : kON];
        }
        [_lineProgressView setCompleted:_lineProgressView.total];
    }
}

// 更新图拽按钮的位置和图片
- (void)updateDragCircularBtnImage:(NSString* )btnName {
    if (_countdownTimer&&_countdownTimer.isEnabled) { // 只要有时间且时间enable，就显示取消按钮
        _cancelBtn.hidden = NO;
        _startBtn.hidden = YES;
        //        if (_countdownTimer.isEnabled) { // 有按钮并且启动
        //            _stopBtn.hidden = NO;
        //            _startLeftBtn.hidden = YES;
        //        } else { // 有按钮并且停止
        //            _stopBtn.hidden = YES;
        //            _startLeftBtn.hidden = NO;
        //        }
    } else {    //没有时间，或者时间disable
        _cancelBtn.hidden = YES;
        _startBtn.hidden = NO;
        //        _startLeftBtn.hidden = YES;
        //        _stopBtn.hidden = YES;
    }
    
    _dragCircular.angle = -_minute/60.0*360;
    _dragCircular.countdownImageName = btnName;
    [_dragCircular setNeedsDisplay];
}

// 新倒计时的时间
- (void)getNewCountdownTimer {
    // 初始化新的倒计时
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents* comps = [calendar components:unitFlags fromDate:[NSDate date]];
    _countdownTimer = [[MHDataDeviceTimer alloc] init];
    
//    if (_isOn) { // 关闭时间
        _countdownTimer.isOnOpen = NO;
        _countdownTimer.offRepeatType = MHDeviceTimerRepeat_Once;
        _countdownTimer.offHour = [comps hour] + _hour;
        _countdownTimer.offMinute = [comps minute] + _minute;
        _countdownTimer.isOffOpen = YES;
    self.acpartner.pwHour = _hour;
    self.acpartner.pwMinute = _minute;
//    }
//    else { // 开启时间
//        _countdownTimer.isOffOpen = NO;
//        _countdownTimer.onRepeatType = MHDeviceTimerRepeat_Once;
//        _countdownTimer.onHour = [comps hour] + _hour;
//        _countdownTimer.onMinute = [comps minute] + _minute;
//        _countdownTimer.isOnOpen = YES;
//    }
    
    // 处理分钟大于1小时的时间
    [_countdownTimer greaterOneHourWithMinute];
    
    [_countdownTimer updateTimerMonthAndDayForRepeatOnceType];
}

// 再次修改倒计时的时间
- (void)getModifyCountdownTimer {
    // 初始化新的倒计时
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents* comps = [calendar components:unitFlags fromDate:[NSDate date]];
    
//    if (_isOn) { // 关闭时间
        _countdownTimer.offHour = [comps hour] + _hour;
        _countdownTimer.offMinute = [comps minute] + _minute;
        _countdownTimer.isOnOpen = NO;
        _countdownTimer.isOffOpen = YES;
    self.acpartner.pwHour = _hour;
    self.acpartner.pwMinute = _minute;
//    }
//    else { // 开启时间
//        _countdownTimer.onHour = [comps hour] + _hour;
//        _countdownTimer.onMinute = [comps minute] + _minute;
//        _countdownTimer.isOnOpen = YES;
//        _countdownTimer.isOffOpen = NO;
//    }
    _countdownTimer.isEnabled = YES;
    
    // 处理分钟大于1小时的时间
    [_countdownTimer greaterOneHourWithMinute];
    
    [_countdownTimer updateTimerMonthAndDayForRepeatOnceType];
}

- (void)countDelayTIme {
        XM_WS(weakself);
    [self.acpartner getTimerListWithID:kACPARTNERCOUNTDOWNTIMERID Success:^(id obj) {
        [weakself.acpartner fetchCountDownTime:^(NSInteger hour, NSInteger minute) {
            weakself.acpartner.pwHour = hour;
            weakself.acpartner.pwMinute = minute;
            if (weakself.acpartner.countDownTimer.isEnabled) {
                weakself.countdownTimer = weakself.acpartner.countDownTimer;
                weakself.hour = hour;
                weakself.minute = minute;
                if (weakself.hour + weakself.minute > 0) {
                    [weakself updateDragCircularBtnImage:@"plug_countdown_button_on"];
                } else {
                    [weakself updateDragCircularBtnImage:@"plug_countdown_button_off"];
                }
                [weakself updateTimerLabelAndDragCircular];
                weakself.countdownLabel.text = [NSString stringWithFormat:@"0%@%@%@", kMINUTE, kREAR,weakself.isOn ? kOFF : kON];
                
            }
        }];

    } failure:^(NSError *v) {
        
    }];

}

@end
