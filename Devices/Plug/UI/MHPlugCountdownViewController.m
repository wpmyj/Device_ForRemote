//
//  MHPlugCountdownViewController.m
//  MiHome
//
//  Created by hanyunhui on 15/9/28.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//

#import "MHPlugCountdownViewController.h"
#import "DragCircularSlider.h"
#import "LineProgressView.h"
#import "MHPlugCountdownTableView.h"
#import "MHTimerPicker.h"
#import <MiHomeKit/XMCoreMacros.h>

#define TableHeight     (270 * ScaleHeight)
#define ProgressHeight  (WIN_HEIGHT - TableHeight)

#define kHOUR NSLocalizedString(@"mydevice.plug.hour", @"小时")
#define kMINUTE NSLocalizedString(@"mydevice.plug.minute", @"分钟")
#define kREAR NSLocalizedString(@"mydevice.plug.rear", @"后")
#define kON NSLocalizedString(@"mydevice.plug.on", @"开启")
#define kOFF NSLocalizedString(@"mydevice.plug.off", @"关闭")

@interface MHPlugCountdownViewController () <MHTimerPickerDelegate>

@end

@implementation MHPlugCountdownViewController {
    DragCircularSlider* _dragCircular;
    LineProgressView *_lineProgressView;
    UILabel* _countdownLabel;
    UIButton*  _startBtn; // 启动
    UIButton*  _startLeftBtn; // 右侧启动
    UIButton*  _stopBtn; // 停止
    UIButton*  _cancelBtn; // 取消
    
    UIImageView*    _backgroundImageView;
    MHPlugCountdownTableView*    _countdownTableView;
    NSArray*    _countdownArray;
    NSArray*    _countdownArrayValue;

    BOOL        _isFirstCountdownTimer;
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
    [_backgroundImageView setImage:[UIImage imageNamed:@"plug_background_on"]];
    [self.view addSubview:_backgroundImageView];
    [self.view sendSubviewToBack:_backgroundImageView]; //   将图片转化为背景
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [MHColorUtils colorWithRGB:0xffffff], NSFontAttributeName : [UIFont systemFontOfSize:18.0f]}];
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
    [_startBtn setTitle:NSLocalizedString(@"mydevice.plug.start",@"启动") forState:UIControlStateNormal];
    [_startBtn.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    [_startBtn setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:UIControlStateNormal];
    [_startBtn addTarget:self action:@selector(startCountdown) forControlEvents:UIControlEventTouchUpInside];
    _startBtn.hidden = YES;
    [self.view addSubview:_startBtn];
    
    // 倒计时取消按钮
    _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake((WIN_WIDTH-startWidth)/2.0, WIN_HEIGHT-startHeight-11*ScaleHeight, startWidth/2.0, startHeight)];
    [_cancelBtn setBackgroundImage:[UIImage imageNamed:@"time_button_left_normal"] forState:UIControlStateNormal];
    [_cancelBtn setBackgroundImage:[UIImage imageNamed:@"time_button_left_press"] forState:UIControlStateHighlighted];
    [_cancelBtn setTitle:NSLocalizedString(@"profile.alert.logout.cancel",@"取消") forState:UIControlStateNormal];
    [_cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    [_cancelBtn setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(cancelCountdown) forControlEvents:UIControlEventTouchUpInside];
    _cancelBtn.hidden = YES;
    [self.view addSubview:_cancelBtn];
    
    // 倒计时停止按钮
    _stopBtn = [[UIButton alloc] initWithFrame:CGRectMake((WIN_WIDTH)/2.0, WIN_HEIGHT-startHeight-11*ScaleHeight, startWidth/2.0, startHeight)];
    [_stopBtn setBackgroundImage:[UIImage imageNamed:@"time_button_right_normal"] forState:UIControlStateNormal];
    [_stopBtn setBackgroundImage:[UIImage imageNamed:@"time_button_right_press"] forState:UIControlStateHighlighted];
    [_stopBtn setTitle:NSLocalizedString(@"mydevice.plug.stop",@"停止") forState:UIControlStateNormal];
    [_stopBtn.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    [_stopBtn setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:UIControlStateNormal];
    [_stopBtn addTarget:self action:@selector(stopCountdown) forControlEvents:UIControlEventTouchUpInside];
    _stopBtn.hidden = YES;
    [self.view addSubview:_stopBtn];
    
    // 再次启动 倒计时启动右侧按钮
    _startLeftBtn = [[UIButton alloc] initWithFrame:CGRectMake((WIN_WIDTH)/2.0, WIN_HEIGHT-startHeight-11*ScaleHeight, startWidth/2.0, startHeight)];
    [_startLeftBtn setBackgroundImage:[UIImage imageNamed:@"time_button_right_normal"] forState:UIControlStateNormal];
    [_startLeftBtn setBackgroundImage:[UIImage imageNamed:@"time_button_right_press"] forState:UIControlStateHighlighted];
    [_startLeftBtn setTitle:NSLocalizedString(@"mydevice.plug.start",@"启动") forState:UIControlStateNormal];
    [_startLeftBtn.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    [_startLeftBtn setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:UIControlStateNormal];
    [_startLeftBtn addTarget:self action:@selector(reStartCountdown) forControlEvents:UIControlEventTouchUpInside];
    _startLeftBtn.hidden = YES;
    [self.view addSubview:_startLeftBtn];
    
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
    NSString* minute_1 = [NSString stringWithFormat:@"1%@", kMINUTE];
    NSString* minute_3 = [NSString stringWithFormat:@"3%@", kMINUTE];
    NSString* minute_5 = [NSString stringWithFormat:@"5%@", kMINUTE];
    NSString* custom = NSLocalizedString(@"mydevice.plug.custom", @"自定义");
    _countdownArray = [NSArray arrayWithObjects:minute_1, minute_3, minute_5, custom, nil];
    _countdownArrayValue = [NSArray arrayWithObjects:@(1), @(3), @(5), @(50), nil];
    float cellHeigth = 54*ScaleHeight;
    CGRect rect = CGRectMake(0, ProgressHeight, WIN_WIDTH, cellHeigth*_countdownArray.count);
    
    _countdownTableView = [[MHPlugCountdownTableView alloc] initWithTableView:_countdownArray rectFrame:rect];
    
    // 表格选中的回调
    __weak typeof(self) weakSelf = self;
    _countdownTableView.selectedCountdownTable = ^(int index){
        XM_SS(strongself, weakSelf);
        strongself->_dragCircular.isInverse = NO;
        if (index==3) {
            // 弹出MHTimerPicker
            MHTimerPicker* timerPicker = [[MHTimerPicker alloc] initWithTitle:NSLocalizedString(@"mydevice.plug.countdown",@"倒计时") delegate:weakSelf];
            [timerPicker showInView:weakSelf.view.window];
        } else { // 显示倒计时动画
            [weakSelf resetLineCircular:index];
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
    
    // 重新选择新的时间，有按钮并且停止
    if (_countdownTimer) {
        _stopBtn.hidden = YES;
        _startLeftBtn.hidden = NO;
    }
}

// 改变圆的动画:1,3,5分钟
- (void)resetLineCircular:(int)index {
    _dragCircular.hourValue = _hour = 0;
    _dragCircular.currentValue = _minute = [_countdownArrayValue[index] integerValue];
    
    [self updateTimerLabelAndDragCircular];
    
    // 改变拖拽按钮位置和角度
    [self updateDragCircularBtnImage:@"plug_countdown_button_off"];
    
    // 重新选择新的时间，有按钮并且停止
    if (_countdownTimer) {
        _stopBtn.hidden = YES;
        _startLeftBtn.hidden = NO;
    }
}

// 启动倒计时
- (void)startCountdown {
    // 未设置定时时间
    if (_hour==0 && _minute==0) {
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedString(@"mydevice.plug.countdown.tips", "请选择倒计时时长") duration:1.5f modal:YES];
    } else if ([self.delegate respondsToSelector:@selector(countdownDidStart:plugItem:)]) {
        // 组装出倒计时timer
        [self getNewCountdownTimer];
        
        [self.delegate countdownDidStart:_countdownTimer plugItem:_plugItem];
        
        // 改变拖拽按钮位置和角度
        [self updateDragCircularBtnImage:@"plug_countdown_button_on"];
        _dragCircular.isInverse = NO;
    }
}

// 再次启动倒计时
- (void)reStartCountdown {
    if ([self.delegate respondsToSelector:@selector(countdownDidReStart:plugItem:)]) {
        // 组装出带修改的倒计时timer
        [self getModifyCountdownTimer];
        
        [self.delegate countdownDidReStart:_countdownTimer plugItem:_plugItem];
        
        // 改变拖拽按钮位置和角度
        [self updateDragCircularBtnImage:@"plug_countdown_button_on"];
        _dragCircular.isInverse = NO;
    }
}

// 停止倒计时
- (void)stopCountdown {
    if ([self.delegate respondsToSelector:@selector(countdownDidStop:plugItem:)]) {
        _countdownTimer.isEnabled = NO;
        
        [self.delegate countdownDidStop:_countdownTimer plugItem:_plugItem];
        
        // 改变拖拽按钮位置和角度
        [self updateDragCircularBtnImage:@"plug_countdown_button_off"];
    }
}

// 取消倒计时
- (void)cancelCountdown {
    if ([self.delegate respondsToSelector:@selector(countdownDidDelete:plugItem:)]) {
        
        [self.delegate countdownDidDelete:_countdownTimer plugItem:_plugItem];
        _countdownTimer = nil;
        _hour = _minute = 0;
        
        [self updateTimerLabelAndDragCircular];
        // 改变拖拽按钮位置和角度
        [self updateDragCircularBtnImage:@"plug_countdown_button_off"];
    }
}

#pragma mark - MHTimerPickerDelegate <NSObject>
-(void)onSelect:(MHTimerPicker *)sender {
    NSInteger hourRow = [sender.picker selectedRowInComponent:0];
    NSInteger minRow = [sender.picker selectedRowInComponent:1];

    _dragCircular.hourValue = _hour = hourRow % 24;
    _dragCircular.currentValue = _minute = minRow % 60;
    
    [self updateTimerLabelAndDragCircular];
    // 改变拖拽按钮位置和角度
    [self updateDragCircularBtnImage:@"plug_countdown_button_off"];
    
    // 重新选择新的时间，有按钮并且停止
    if (_countdownTimer) {
        _stopBtn.hidden = YES;
        _startLeftBtn.hidden = NO;
    }
}


// 更新倒计时数字和拖拽按钮
- (void)updateTimerLabelAndDragCircular {
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
    if (_countdownTimer) { // 只要有时间，就显示取消按钮
        _cancelBtn.hidden = NO;
        _startBtn.hidden = YES;
        if (_countdownTimer.isEnabled) { // 有按钮并且启动
            _stopBtn.hidden = NO;
            _startLeftBtn.hidden = YES;
        } else { // 有按钮并且停止
            _stopBtn.hidden = YES;
            _startLeftBtn.hidden = NO;
        }
    } else {
        _cancelBtn.hidden = YES;
        _startBtn.hidden = NO;
        _startLeftBtn.hidden = YES;
        _stopBtn.hidden = YES;
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

    if (_isOn) { // 关闭时间
        _countdownTimer.isOnOpen = NO;
        _countdownTimer.offRepeatType = MHDeviceTimerRepeat_Once;
        _countdownTimer.offHour = [comps hour] + _hour;
        _countdownTimer.offMinute = [comps minute] + _minute;
    } else { // 开启时间
        _countdownTimer.isOffOpen = NO;
        _countdownTimer.onRepeatType = MHDeviceTimerRepeat_Once;
        _countdownTimer.onHour = [comps hour] + _hour;
        _countdownTimer.onMinute = [comps minute] + _minute;
    }
    
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
    
    if (_isOn) { // 关闭时间
        _countdownTimer.offHour = [comps hour] + _hour;
        _countdownTimer.offMinute = [comps minute] + _minute;
    } else { // 开启时间
        _countdownTimer.onHour = [comps hour] + _hour;
        _countdownTimer.onMinute = [comps minute] + _minute;
    }
    _countdownTimer.isEnabled = YES;
    
    // 处理分钟大于1小时的时间
    [_countdownTimer greaterOneHourWithMinute];
    
    [_countdownTimer updateTimerMonthAndDayForRepeatOnceType];
}
@end
