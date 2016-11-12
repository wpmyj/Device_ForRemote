//
//  MHPlugMiniViewController.m
//  MiHome
//
//  Created by Woody on 14/11/18.
//  Copyright (c) 2014年 小米移动软件. All rights reserved.
//

#import "MHPlugMiniViewController.h"
#import "MHDevicePlugMini.h"
#import "MHPlugView.h"
#import <MiHomeKit/MHDataDeviceTimer.h>
#import "MHDeviceTimerSettingNewViewController.h" // 小插座的定时新接口
#import "MHPlugCountdownViewController.h"
#import <MiHomeKit/XMCoreMacros.h>
#import "MHDisclaimerView.h"
#import "MHWebViewController.h"
#import "MHTimerSettingManager.h"

#define LimitPlugMiniCount 20

@interface MHPlugMiniViewController() <CountdownDelegate>
@property (nonatomic, assign) BOOL isShowingDisclaimer;   //是否正在显示“免责声明”的view
@property (nonatomic, retain) MHDisclaimerView* disclaimerView;
@end

@implementation MHPlugMiniViewController {
    MHDevicePlugMini*       _plug;
    BOOL                _isOn; // 电源或USB是否开启
    MHPlugItem          _plugItem; // 类型是电源或USB
    MHPlugView*         plugView;
    
    NSMutableArray*     _powerTimerListCopy;
    
    NSMutableArray*     _timerAllPointslist; // 所有的时间点
    NSMutableArray*     _timerAllLineslist; // 所有的时间线
    
    MHDataDeviceTimer*  _countdownPowerTimer; // 显示倒计时时间
    MHDataDeviceTimer*  _countdownPowerTimerModify; // 倒计时页修改的倒计时
    
    int                 powerHour;
    int                 powerMinute;
    MHTimerSettingManager* _timerManager;
}

- (void)resetPowerTimerList {
    _powerTimerListCopy = [[NSMutableArray alloc] init];
    _countdownPowerTimer = [[MHDataDeviceTimer alloc] init];
    _countdownPowerTimerModify = nil;
    powerHour = powerMinute = 0;
    for (id timer in _plug.powerTimerList) {
        [_powerTimerListCopy addObject:[timer copy]];
    }
}

- (id)initWithDevice:(MHDevice*)device {
    if (self = [super initWithDevice:device]) {
        _plug = (MHDevicePlugMini*)device;
        _timerManager = [MHTimerSettingManager sharedInstance];
        _timerManager.device = _plug;
        [self resetPowerTimerList];
        [_plug subscribe:60 completion:^(BOOL success) {
            NSLog(@"subscribe success=%d", success);
        }];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isNavBarTranslucent = YES;
    
    //先读取缓存
    [_timerManager restoreTimerListWithFinish:^(id obj) {
        [self resetPowerTimerList];
        
        //然后从云端拉取
        [self getPlugTimers];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 弹出免责申明，每个账号只弹一次
    if (![self isDisclaimerShown]){
        [self showDisclaimer];
        return;
    }
    
    [self getPlugTimers];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [MHColorUtils colorWithRGB:0xffffff], NSFontAttributeName : [UIFont systemFontOfSize:18.0f]}];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_timerManager saveTimerList:_plug];
}

- (void)addScrollerItems {
    __weak typeof(self) weakSelf = self;
    if (!plugView) {
        plugView = [[MHPlugView alloc] initWithPlugItem:MHPlugItemPlug clickCallback:^(MHPlugView* view){
            [weakSelf powerOnDevice:view];
        }];
        [self.view addSubview:plugView];
    }
    CGRect plugFrame = CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT);
    plugView.frame = plugFrame;
    plugView.isOn = _plug.isOpen;
    plugView.temperature = _plug.temperature;
    
    // 开关定时列表
    [plugView timerCallback:^(MHPlugView *v) {
        [weakSelf openTimerPage:MHPlugItemPlug];
    }];
    
    // 打开倒计时页面
    plugView.countdown = ^(BOOL isOn,MHPlugItem plugItem) {
        [weakSelf openCountPage:isOn plugItem:plugItem];
    };
}

- (void)buildSubviews {
    
    [super buildSubviews];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self addScrollerItems];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.view layoutSubviews];
}

- (void)buildConstraints {
    
    [super buildConstraints];
}

#pragma mark - 插座控制
- (void)onGetStatusSucceed:(id)response {
    [plugView setIsOn:_plug.isOpen];
    [self getPlugTimers];
}

- (void)getPlugTimers {
    XM_WS(ws);
    [_timerManager getTimerListWithSuccess:^(id obj) {
        XM_SS(ss, ws);
        [self resetPowerTimerList];
        // 数据获取成功,更新时间进度数据
        [ss->plugView updateTimerProgressView:[ws setTimeLineData:MHPlugItemPlug] countdownTimer:ss->_countdownPowerTimer];
    } failure:^(NSError *v) {
    }];
}

- (void)powerOnDevice:(id)sender {
    if(_plug.isShareReadonly) {
        [[MHTipsView shareInstance] showFinishTips:NSLocalizedString(@"profile.devshare.device.viewContrller.readonly", @"当前权限下不支持控制操作") duration:1.0 modal:YES];
        return;
    }
    [self pauseGetDeviceStatus];
    XM_WS(ws);
    [_plug powerOnDevice:!_plug.isOpen success:^(id obj) {
        XM_SS(ss, ws);
        [(MHPlugView*)sender setIsOn:ss->_plug.isOpen];
        [self getPlugTimers];
        [self resumeGetDeviceStatus];
    } failure:^(NSError *v) {
        [self resumeGetDeviceStatus];
    }];
}

// 打开定时页面
- (void)openTimerPage:(MHPlugItem)item {
    if(_plug.isShareReadonly) {
        [[MHTipsView shareInstance] showFinishTips:NSLocalizedString(@"profile.devshare.device.viewContrller.readonly", @"当前权限下不支持控制操作") duration:1.0 modal:YES];
        return;
    }
    // 小插座，定时新接口
    MHTimerSettingBaseViewController* timerVC = [MHTimerSettingManager getTimerSettingViewController:_plug];
    timerVC.limitCount = LimitPlugMiniCount;
    timerVC.title = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"mydevice.plug.device.title","插座电源"),NSLocalizedString(@"mydevice.plug.timer", @"定时")];
    _plugItem = item;
    [self.navigationController pushViewController:timerVC animated:YES];
}

// 打开倒计时页面
- (void)openCountPage:(BOOL)isOn plugItem:(MHPlugItem)plugItem {
    if(_plug.isShareReadonly) {
        [[MHTipsView shareInstance] showFinishTips:NSLocalizedString(@"profile.devshare.device.viewContrller.readonly", @"当前权限下不支持控制操作") duration:1.0 modal:YES];
        return;
    }
    MHPlugCountdownViewController* countdownVC = [[MHPlugCountdownViewController alloc] init];
    countdownVC.plugItem = _plugItem = plugItem;
    countdownVC.isOn = _isOn = isOn;
    if (plugItem == MHPlugItemPlug) {
        countdownVC.title = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"mydevice.plug.device.title","插座电源"),NSLocalizedString(@"mydevice.plug.countdown", @"倒计时")];
        countdownVC.countdownTimer = _countdownPowerTimerModify;
        countdownVC.hour = powerHour;
        countdownVC.minute = powerMinute;
    }
    
    countdownVC.delegate = self;
    [self.navigationController pushViewController:countdownVC animated:YES];
}


#pragma mark - CountDownDelegate
- (void)countdownDidStart:(MHDataDeviceTimer*)countdownTimer plugItem:(MHPlugItem)item {
    MHTimerSettingBaseViewController* timerVC = [MHTimerSettingManager getTimerSettingViewController:_plug];
    
    // 将倒计时添加到列表中
    if (item == MHPlugItemPlug) {
        [timerVC addTimer:countdownTimer];
        _countdownPowerTimerModify = countdownTimer;
    }
}

- (void)countdownDidReStart:(MHDataDeviceTimer *)countdownTimer plugItem:(MHPlugItem)item {
    
    // 将倒计时添加到列表中
    if (item == MHPlugItemPlug) {
        [_powerTimerListCopy removeObject:_countdownPowerTimerModify];
        [_powerTimerListCopy addObject:countdownTimer];
        _plug.powerTimerList = _powerTimerListCopy;
        _countdownPowerTimerModify = countdownTimer;
        
        MHTimerSettingBaseViewController* timerVC = [MHTimerSettingManager getTimerSettingViewController:_plug];
        [timerVC modifyTimer:countdownTimer];
    }
}

- (void)countdownDidStop:(MHDataDeviceTimer *)countdownTimer plugItem:(MHPlugItem)item {

    // 将倒计时添加到列表中
    if (item == MHPlugItemPlug) {
        [_powerTimerListCopy removeObject:_countdownPowerTimerModify];
        [_powerTimerListCopy addObject:countdownTimer];
        _plug.powerTimerList = _powerTimerListCopy;
        _countdownPowerTimerModify = countdownTimer;
        
        MHTimerSettingBaseViewController* timerVC = [MHTimerSettingManager getTimerSettingViewController:_plug];
        [timerVC modifyTimer:countdownTimer];
    }
    
}

- (void)countdownDidDelete:(MHDataDeviceTimer *)countdownTimer plugItem:(MHPlugItem)item {
    
    // 将倒计时添加到列表中
    if (item == MHPlugItemPlug) {
        [_powerTimerListCopy removeObject:_countdownPowerTimerModify];
        _plug.powerTimerList = _powerTimerListCopy;
        
        MHTimerSettingBaseViewController* timerVC = [MHTimerSettingManager getTimerSettingViewController:_plug];
        [timerVC deleteTimer:countdownTimer];
    }
}

// 提取出今天的定时,用于显示线条进度
- (NSMutableArray*)setTimeLineData:(int)plugItem {
    
    NSMutableArray* _tempPowerTimerlist = [[NSMutableArray alloc] init];
    NSMutableArray* timerValidlist = [[NSMutableArray alloc] init]; // 满足当天显示的进度时间
    NSMutableArray* timerCountdownValidlist = [[NSMutableArray alloc] init]; // 满足当天的倒计时
    _timerAllPointslist = [[NSMutableArray alloc] init];
    _timerAllLineslist = [[NSMutableArray alloc] init];
    
    if(plugItem == MHPlugItemPlug) {
        _tempPowerTimerlist = _powerTimerListCopy;
    }
    
    // 1.取出满足条件的timer
    if (_tempPowerTimerlist == nil || _tempPowerTimerlist.count == 0) {
        NSLog(@"nothing");
    }
    
    // 当前时间
    MHDataDeviceTimer* now = [[MHDataDeviceTimer alloc] init];
    [now nowChangeFormatTimer];
    
    // A 过滤进度时间
    for (MHDataDeviceTimer* timer in _tempPowerTimerlist) {
        if (!timer.isEnabled || (!timer.isOnOpen && !timer.isOffOpen)) {
            continue;
        }
        [self filterValidList:timerValidlist timer:timer now:now isTomorrow:NO];
        
    }
    
    // B 过滤倒计时的时间
    for (MHDataDeviceTimer* timer in _tempPowerTimerlist) {
        if ((timer.isOnOpen == timer.isOffOpen)) { // 单个时间的
            continue;
        }
        [self filterValidList:timerCountdownValidlist timer:timer now:now isTomorrow:YES];
    }
    [self countdownTimerModify:timerCountdownValidlist now:now plugItem:plugItem];
    
    // 2.将时间list打散成所有的时间点_timerAllPointslist,所有点用onTime存放，区分isOnOpen : YES－开始  NO－结束
    [self changeValidTimerToAllPoints:timerValidlist];
    
    // 3.将所有的时间点排序_timerAllPointslist
    [self orderTimerAllPointslist];
    
    // 4.1 计算距离最近的时间
    [self getNextDiffTimer:now plugItem:plugItem];
    
    // 4.2 根据isOnOpen : YES－开始  NO－结束起始/结束 计算时间线
    int lineCount = 1;// 奇数表示找开始点，偶数表示找结束点
    for (MHDataDeviceTimer* timer in _timerAllPointslist) {
        if (timer.onRepeatType == MHDeviceTimerRepeat_Once && ![self isOnSameDay:now timer:timer]){
            continue;
        }
            
        if(timer.isOnOpen) { // 开始点
            if (lineCount%2 == 0) { // 偶数
                continue;
            }
            lineCount++;
            [_timerAllLineslist addObject:timer];
        }
        
        if(!timer.isOnOpen) { // 结束点
            if (lineCount%2 == 1) { // 奇数
                continue;
            }
            lineCount++;
            [_timerAllLineslist addObject:timer];
        }
        
    }
    
    // 循环结束还没有找到结束点
    if (lineCount>=2 && lineCount%2 == 0) {
        MHDataDeviceTimer* tempTimer = [[MHDataDeviceTimer alloc] init];
        tempTimer.isOnOpen = NO;
        tempTimer.onHour = 24;
        tempTimer.onMinute = 0;
        [_timerAllLineslist addObject:tempTimer];
    }
    return _timerAllLineslist;
}

// 过滤出有效的时间list
- (void) filterValidList:(NSMutableArray*)timerValidlist timer:(MHDataDeviceTimer*)timer now:(MHDataDeviceTimer*)now isTomorrow:(BOOL)tomorrow {
    // 工作日可见
    if (timer.onRepeatType == MHDeviceTimerRepeat_Workday) {
        if (now.onRepeatType == MHDeviceTimerRepeat_Sat || now.onRepeatType == MHDeviceTimerRepeat_Sun) {
            //            continue;
            return;
        }
        // 工作日可见
        [timerValidlist addObject:timer];
    } else if (timer.onRepeatType == MHDeviceTimerRepeat_Weekend) {
        if (now.onRepeatType != MHDeviceTimerRepeat_Sat && now.onRepeatType != MHDeviceTimerRepeat_Sun) {
            //            continue;
            return;
        }
        // 周末可见
        [timerValidlist addObject:timer];
    } else if (timer.onRepeatType == MHDeviceTimerRepeat_Once) {
        if (timer.isOnOpen) {
            // 设置了开启时间，并且起始时间在今天，需要添加到时间线
            if (tomorrow) { // 时间点的，同一天必须时间大于now,不是同一天的，时间小于now
                if (([self isOnSameDay:now timer:timer] && [self isTimerGreaterNow:timer timer:now]) || (![self isOnSameDay:now timer:timer] && ![self isTimerGreaterNow:timer timer:now])) {
                    [timerValidlist addObject:timer];
                }
            } else { // 时间段的，必须同一天
                if ([self isOnSameDay:now timer:timer] || (![self isOnSameDay:now timer:timer] && ![self isTimerGreaterNow:timer timer:now])) {
                    [timerValidlist addObject:timer];
                }
            }
        } else if (timer.isOffOpen) {
            // 设置了开启时间，起始时间不在今天。但是因为设置了关闭时间的话，还需要看关闭时间是否今天
            if (tomorrow) { // 时间点的，同一天必须时间大于now,不是同一天的，时间小于now
                if (([self isOffSameDay:now timer:timer] && [self isTimerOffGreaterNow:timer timer:now]) || (![self isOffSameDay:now timer:timer] && ![self isTimerOffGreaterNow:timer timer:now])) {
                    [timerValidlist addObject:timer];
                }
            } else { // 时间段的，必须同一天
                if ([self isOffSameDay:now timer:timer] || (![self isOffSameDay:now timer:timer] && ![self isTimerOffGreaterNow:timer timer:now])) {
                    [timerValidlist addObject:timer];
                }
            }
        }
    } else if (timer.onRepeatType == MHDeviceTimerRepeat_Everyday) {
        // 每天都执行
        [timerValidlist addObject:timer];
    } else {
        // 自定义时间
        if (timer.onRepeatType&now.onRepeatType) {
            [timerValidlist addObject:timer];
        } else if (timer.offRepeatType&now.onRepeatType) {
            [timerValidlist addObject:timer];
        }
    }
}

// 开始时间是同一天
- (BOOL)isOnSameDay:(MHDataDeviceTimer*)now timer:(MHDataDeviceTimer*)timer {
    return (now.onMonth==timer.onMonth && now.onDay==timer.onDay);
}

// 关闭时间是同一天
- (BOOL)isOffSameDay:(MHDataDeviceTimer*)now timer:(MHDataDeviceTimer*)timer {
    return (now.onMonth==timer.offMonth && now.onDay==timer.offDay);
}

// timer是否大于当前时间
- (BOOL)isTimerGreaterNow:(MHDataDeviceTimer*)timer timer:(MHDataDeviceTimer*)now {
    return (timer.onHour*60 + timer.onMinute) > (now.onHour*60 + now.onMinute);
}

// timer是否大于当前关闭时间
- (BOOL)isTimerOffGreaterNow:(MHDataDeviceTimer*)timer timer:(MHDataDeviceTimer*)now {
    return (timer.offHour*60 + timer.offMinute) > (now.onHour*60 + now.onMinute);
}

// 第一个时间大于第二个时间YES
- (BOOL)isOnFirstGreater:(MHDataDeviceTimer*)first second:(MHDataDeviceTimer*)second now:(MHDataDeviceTimer*)now {
    if([self isOnSameDay:first timer:second]){ // 同一天
        return [self isTimerGreaterNow:first timer:second];
    } else {
        if (![self isOnSameDay:first timer:now]) { // first第二天
            return YES;
        } else {
            return NO;
        }
    }
}

// 第一个时间大于第二个时间YES
- (BOOL)isOffFirstGreater:(MHDataDeviceTimer*)first second:(MHDataDeviceTimer*)second now:(MHDataDeviceTimer*)now {
    if([self isOffSameDay:first timer:second]){ // 同一天
        return [self isTimerGreaterNow:first timer:second];
    } else {
        if (![self isOffSameDay:first timer:now]) { // first第二天
            return YES;
        } else {
            return NO;
        }
    }
}

// 将时间list打散成所有的时间点,所有点用onTime存放，区分isOnOpen : YES－开始  NO－结束
- (void)changeValidTimerToAllPoints:(NSMutableArray*)timerValidlist {
    for (MHDataDeviceTimer* timer in timerValidlist) {
        if (timer.isOnOpen) { // 有开始时间
            MHDataDeviceTimer* tempTimer = [[MHDataDeviceTimer alloc] init];
            tempTimer.isOnOpen = YES;
            tempTimer.onHour = timer.onHour;
            tempTimer.onMinute = timer.onMinute;
            tempTimer.onDay = timer.onDay;
            tempTimer.onMonth = timer.onMonth;
            tempTimer.onRepeatType = timer.onRepeatType;
            [_timerAllPointslist addObject:tempTimer];
        }
        if (timer.isOffOpen) { // 有关闭时间
            MHDataDeviceTimer* tempTimer = [[MHDataDeviceTimer alloc] init];
            tempTimer.isOnOpen = NO;
            tempTimer.onHour = timer.offHour;
            tempTimer.onMinute = timer.offMinute;
            tempTimer.onDay = timer.offDay;
            tempTimer.onMonth = timer.offMonth;
            tempTimer.onRepeatType = timer.offRepeatType;
            [_timerAllPointslist addObject:tempTimer];
        }
    }
}

// 将所有的时间点排序_timerAllPointslist
- (void)orderTimerAllPointslist {
    MHDataDeviceTimer* TempTimer = [[MHDataDeviceTimer alloc] init];
    for (int j=0; j<_timerAllPointslist.count; j++) {
        for (int i=0; i<_timerAllPointslist.count-1; i++) {
            MHDataDeviceTimer* timerI = (MHDataDeviceTimer*)(_timerAllPointslist[i]);
            MHDataDeviceTimer* timerIPlus = (MHDataDeviceTimer*)(_timerAllPointslist[i+1]);
            if ((timerI.onHour*60 + timerI.onMinute) > (timerIPlus.onHour*60 + timerIPlus.onMinute)) {
                TempTimer = _timerAllPointslist[i];
                _timerAllPointslist[i] = _timerAllPointslist[i+1];
                _timerAllPointslist[i+1] = TempTimer;
            }
        }
    }
}

// 计算距离最近的时间
- (void)getNextDiffTimer:(MHDataDeviceTimer*)now plugItem:(int)plugItem{
    
    MHDataDeviceTimer*  _tempCountdownPowerTimer; // 倒计时时间
//    MHDataDeviceTimer*  _tempCountdownUsbTimer; // 倒计时时间
    
    for (MHDataDeviceTimer* timer in _timerAllPointslist) {
        // 时间是明天，且大于now的continue
        if ((timer.onRepeatType == MHDeviceTimerRepeat_Once) && (![self isOnSameDay:now timer:timer] && [self isTimerGreaterNow:timer timer:now])) {
            continue;
        }
        
        if(plugItem == MHPlugItemPlug) {
            if (timer.isOnOpen != _plug.isOpen) { // _isOn表示当前开启，isOnOpen表示开始时间
                if (!_tempCountdownPowerTimer) { // 放入时间点的第一个值
                    _tempCountdownPowerTimer = [timer copy];
                }
                
                if ([self isTimerGreaterNow:timer timer:now]) { // 如果timer大于当前时间，结束
                    _tempCountdownPowerTimer = [timer copy];
                    break;
                }
            }
        }
    }
    
    // 判断取出的时间是否是下一天的
    if (_tempCountdownPowerTimer && ![self isTimerGreaterNow:_tempCountdownPowerTimer timer:now]) {
        _tempCountdownPowerTimer.onHour += 24;
    }
    
    // 计算差值分钟
    if(_tempCountdownPowerTimer) {
        NSInteger diffPowerTimer = (_tempCountdownPowerTimer.onHour*60 + _tempCountdownPowerTimer.onMinute) - (now.onHour*60 + now.onMinute);
        _countdownPowerTimer.isOnOpen = _tempCountdownPowerTimer.isOnOpen;
        _countdownPowerTimer.onHour = diffPowerTimer/60;
        _countdownPowerTimer.onMinute = diffPowerTimer%60;
    }
}

// 倒计时页修改的倒计时
- (void)countdownTimerModify:(NSMutableArray*)timerCountdownValidlist now:(MHDataDeviceTimer*)now plugItem:(int)plugItem {
    for (MHDataDeviceTimer* timer in timerCountdownValidlist) {
        
        if(plugItem == MHPlugItemPlug) {
            if (_plug.isOpen && timer.isOffOpen) { // 插座开启，找关闭时间
                if (!_countdownPowerTimerModify) { // 放入时间点的第一个值
                    _countdownPowerTimerModify = timer;
                }
                if (_countdownPowerTimerModify && [self isOffFirstGreater:_countdownPowerTimerModify second:timer now:now]) {
                    _countdownPowerTimerModify = timer;
                }
            } else if (!_plug.isOpen && timer.isOnOpen){
                if (!_countdownPowerTimerModify) { // 放入时间点的第一个值
                    _countdownPowerTimerModify = timer;
                }
                if (_countdownPowerTimerModify && [self isOnFirstGreater:_countdownPowerTimerModify second:timer now:now]) {
                    _countdownPowerTimerModify = timer;
                }
            }

        }
    }
    
    // 计算时间差值
    // 判断取出的时间是否是下一天的
    if (_countdownPowerTimerModify) {
        if (_plug.isOpen) { // 插座开启，找关闭时间
            powerHour = (int)_countdownPowerTimerModify.offHour;
            powerMinute = (int)_countdownPowerTimerModify.offMinute;
            if (![self isTimerOffGreaterNow:_countdownPowerTimerModify timer:now]) {
                powerHour += 24;
            }
        } else if (!_plug.isOpen) { // 插座关闭，找开启时间
            powerHour = (int)_countdownPowerTimerModify.onHour;
            powerMinute = (int)_countdownPowerTimerModify.onMinute;
            if (![self isTimerGreaterNow:_countdownPowerTimerModify timer:now]) {
                powerHour += 24;
            }
            
        }
    }
    
    // 计算差值分钟
    if(_countdownPowerTimerModify) {
        NSInteger diffPowerTimer = (powerHour*60 + powerMinute) - (now.onHour*60 + now.onMinute);
        //        _countdownPowerTimer.isOnOpen = !_plug.isOpen;
        powerHour = (int)diffPowerTimer/60;
        powerMinute = diffPowerTimer%60;
    }
}

#pragma mark - 免责声明
#define keyForSceneDisclaimer @"keyForSceneDisclaimer"
- (void)openDisclaimerPage {
    XM_WS(ws);
    NSURL* URL = [[NSBundle mainBundle] URLForResource:@"plug_terms" withExtension:@"html"];
    MHWebViewController* termVC = [[MHWebViewController alloc] initWithURL:URL];
    termVC.pageTitle = NSLocalizedString(@"mydevice.plug.disclaimer","《小米智能插座使用须知》");
    termVC.willBack = ^{
        [ws.disclaimerView showPanelWithAnimation:NO];
    };
    [self.navigationController pushViewController:termVC animated:YES];
    [self.disclaimerView hideWithAnimation:NO];
}

-(void)showDisclaimer {
    XM_WS(ws);
    MHDisclaimerView* disclaimerView = [[MHDisclaimerView alloc] initWithFrame:self.view.bounds panelFrame:CGRectMake(0, self.view.bounds.size.height - 200, self.view.bounds.size.width, 200) withCancel:^(id v) {
        [ws.navigationController popViewControllerAnimated:YES];
    } withOk:^(id v) {
        [ws.disclaimerView hideWithAnimation:YES];
        [ws setDisclaimerShown:YES];
        [self setIsShowingDisclaimer:NO];
    }];
    disclaimerView.onOpenDisclaimerPage = ^(void){
        [ws openDisclaimerPage];
    };
    disclaimerView.isExitOnClickBg = NO;
    disclaimerView.disclaimerName = NSLocalizedString(@"mydevice.plug.disclaimer","《小米智能插座使用须知》");
    [[UIApplication sharedApplication].keyWindow addSubview:disclaimerView];
    _disclaimerView = disclaimerView;
}

-(BOOL)isDisclaimerShown {
    NSString* key = [NSString stringWithFormat:@"%@_%@",
                     keyForSceneDisclaimer,
                     [MHPassportManager sharedSingleton].currentAccount.userId];
    NSNumber* flag = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if(flag){
        return [flag boolValue];
    }
    return NO;
}

-(void)setDisclaimerShown:(BOOL)shown {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* key = [NSString stringWithFormat:@"%@_%@",
                     keyForSceneDisclaimer,
                     [MHPassportManager sharedSingleton].currentAccount.userId];
    NSNumber* flag = [NSNumber numberWithBool:shown];
    [defaults setObject:flag forKey:key];
    [defaults synchronize];
}

@end