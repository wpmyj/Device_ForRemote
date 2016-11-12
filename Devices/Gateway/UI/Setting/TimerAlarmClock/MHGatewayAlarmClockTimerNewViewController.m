//
//  MHGatewayAlarmClockTimerNewViewController.m
//  MiHome
//
//  Created by guhao on 4/8/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayAlarmClockTimerNewViewController.h"
#import "MHGatewayAlarmClockTimerView.h"
#import "MHGatewayClockTimerDetailViewController.h"
#import "MHGatewayClockControlSettingViewController.h"
#import "MHDeviceGateway.h"

@interface MHGatewayAlarmClockTimerNewViewController ()

@property (nonatomic,strong) MHDevice *device;

@end

@implementation MHGatewayAlarmClockTimerNewViewController{
    NSString*           _identifier;
    MHGatewayAlarmClockTimerView * _deviceTimerView;
    NSMutableArray*     _powerTimerListCopy;
}

- (id)initWithDevice:(MHDevice*)device andIdentifier:(NSString *)identifier{
    if (self = [super init]) {
        _device = device;
        _identifier = identifier;
        [self resetTimerList];
    }
    return self;
}

- (void)resetTimerList {
    _powerTimerListCopy = [[NSMutableArray alloc] init];
    for (MHDataDeviceTimer *timer in _device.powerTimerList) {
        if ([timer.identify isEqualToString:_identifier])
            [_powerTimerListCopy addObject:[timer copy]];
    }
}

- (void)dealloc {
    NSLog(@"ddd");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isTabBarHidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    //设置闹钟响铃
    MHDeviceGateway *gateway = (MHDeviceGateway *)self.device;
    [gateway setClockAlarmTimeSpan:60 Success:^(id obj) {
        NSLog(@"%@", obj);
    } andFailure:^(NSError *error) {
        NSLog(@"%@", error);

    }];
    //先读取定时的缓存
    [_device restoreTimerListWithFinish:^(id obj) {
        [self resetTimerList];
        [self updatePowerTimerView:YES];
        
        //然后从云端拉取
        [self getDeviceTimers];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_device saveTimerList];
}

- (void)buildSubviews {
    [super buildSubviews];
    
    _deviceTimerView = [[MHGatewayAlarmClockTimerView alloc] initWithDevice:_device timerList:_powerTimerListCopy parentVC:self];
    _deviceTimerView.needBlankCup = YES;
    _deviceTimerView.timerIdentify = _device.did;
    _deviceTimerView.frame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64) ;
    if(self.customName) _deviceTimerView.customName = self.customName;
    
    //点击事件的回调
    XM_WS(weakself);
    _deviceTimerView.onAddTimer = ^{
        [weakself onAddTimer];
    };
    _deviceTimerView.onSettingTimer = ^{
        [weakself onSettingTimer];
    };
    _deviceTimerView.onModifyTimer = ^(MHDataDeviceTimer* timer, BOOL isNeedOpenEditPage) {
        [weakself onModifyTimer:timer isNeedOpenEditPage:isNeedOpenEditPage];
    };
    _deviceTimerView.onDelTimer = ^(MHDataDeviceTimer* timer) {
        [weakself onDeleteTimer:timer];
    };
    _deviceTimerView.onNewDelTimer = ^(NSInteger index){
        [weakself onNewDeleteTimer:index];
    };
    _deviceTimerView.refreshTimerList = ^{
        [weakself getDeviceTimers];
    };
    [self.view addSubview:_deviceTimerView];
}

- (void)updatePowerTimerView:(BOOL)succeed {
    if (succeed) {
        [_deviceTimerView onRefreshTimerListDone:YES timerList:_powerTimerListCopy];
    } else {
        [_deviceTimerView onRefreshTimerListDone:NO timerList:nil];
    }
}

#pragma mark - 定时控制
//UI 部分
- (void)onAddTimer {
    XM_WS(weakself);
    MHGatewayClockTimerDetailViewController* timerVC = [[MHGatewayClockTimerDetailViewController alloc] initWithTimer:nil andGatewayDevice:(MHDeviceGateway *)_device];
    timerVC.onDone = ^(MHDataDeviceTimer* newTimer) {
        
        if(weakself.onAddNewTimer) weakself.onAddNewTimer(newTimer);
        else [weakself addTimer:newTimer];
    };

    [self gw_clickMethodCountWithStatType:@"openAddClocktimerPage"];

    [self.navigationController pushViewController:timerVC animated:YES];
}

- (void)onModifyTimer:(MHDataDeviceTimer*) timer {
    [self modifyTimer:timer];
}

- (void)onModifyTimer:(MHDataDeviceTimer*) timer isNeedOpenEditPage:(BOOL)isNeedOpenEditPage{
    if (isNeedOpenEditPage) {
        XM_WS(weakself);
        MHGatewayClockTimerDetailViewController* timerVC = [[MHGatewayClockTimerDetailViewController alloc] initWithTimer:timer andGatewayDevice:(MHDeviceGateway *)_device];
        timerVC.onDone = ^(MHDataDeviceTimer* timer) {
            if (!timer.isOnOpen && !timer.isOffOpen) {
                [weakself deleteTimer:timer];
            } else {
                [weakself modifyTimer:timer];
            }
        };
        [self.navigationController pushViewController:timerVC animated:YES];
    }
    else{
        if (!timer.isOnOpen && !timer.isOffOpen) {
            [self deleteTimer:timer];
        } else {
            [self modifyTimer:timer];
        }
    }
}

- (void)onDeleteTimer:(MHDataDeviceTimer*) timer {
    [self deleteTimer:timer];
}

-(void)onNewDeleteTimer:(NSInteger )index{
    MHDataDeviceTimer * timer = _powerTimerListCopy[index];
    [self deleteTimer:timer];
}

- (void)getDeviceTimers {
    XM_WS(weakself);
    [_device getTimerListWithIdentify:_identifier success:^(id obj){
        weakself.device.powerTimerList = obj;
        [weakself.device saveTimerList];
        
        [self resetTimerList];
        [self updatePowerTimerView:YES];
        
    }failure:^(NSError *error){
        [self updatePowerTimerView:NO];
    }];
}

- (void)addTimer:(MHDataDeviceTimer*)newTimer{
    
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.timersetting.adding",@"plugin_gateway","添加定时中，请稍候...") modal:YES];
    if (newTimer.onRepeatType == MHDeviceTimerRepeat_Once) {
        [self updateMonthAndDay:newTimer];
    }

    [_powerTimerListCopy addObject:newTimer];
    newTimer.identify = _identifier;
    
    __weak __typeof(self) weakSelf = self;
    [_device editTimer:newTimer success:^(id obj) {
        [weakSelf updatePowerTimerView:YES];
        
        [[MHTipsView shareInstance]showFinishTips:NSLocalizedStringFromTable(@"mydevice.timersetting.add.succeed",@"plugin_gateway", "添加定时成功") duration:1.0 modal:NO];
        
    } failure:^(NSError *v) {
        [weakSelf resetTimerList];
        
        [[MHTipsView shareInstance]showFailedTips:NSLocalizedStringFromTable(@"mydevice.timersetting.add.failed",@"plugin_gateway", "添加定时失败") duration:1.0 modal:NO];
    }];
}

- (void)modifyTimer:(MHDataDeviceTimer*)timer {
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.timersetting.modifying",@"plugin_gateway","修改定时中，请稍候...") modal:YES];
    
    if (timer.onRepeatType == MHDeviceTimerRepeat_Once) {
        [self updateMonthAndDay:timer];
    }
    
    XM_WS(weakself);
    [_device editTimer:timer success:^(id obj) {
        [weakself updatePowerTimerView:YES];
        NSLog(@"%@, %@", timer.offMethod, timer.offParam);
        [[MHTipsView shareInstance]showFinishTips:NSLocalizedStringFromTable(@"mydevice.timersetting.modify.succeed", @"plugin_gateway","修改定时成功") duration:1.0 modal:NO];
        
    } failure:^(NSError *v) {
        [weakself resetTimerList];
        
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.timersetting.modify.failed", @"plugin_gateway","修改定时失败") duration:1.0 modal:NO];
        
    }];
    [self gw_clickMethodCountWithStatType:@"modifyClocktimerPage"];
    
}

- (void)deleteTimer:(MHDataDeviceTimer*) timer {
    
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.timersetting.deling",@"plugin_gateway","删除定时中，请稍候...") modal:YES];
    
    
    [_powerTimerListCopy removeObject:timer];
    
    __weak __typeof(self) weakSelf = self;
    [_device deleteTimerId:timer.timerId success:^(id obj) {
        
        [weakSelf updatePowerTimerView:YES];
        
        [[MHTipsView shareInstance]showFinishTips:NSLocalizedStringFromTable(@"mydevice.timersetting.del.succeed", @"plugin_gateway","修改定时成功") duration:1.0 modal:NO];
    } failure:^(NSError *v) {
        
        [weakSelf resetTimerList];
        
        [[MHTipsView shareInstance]showFailedTips:NSLocalizedStringFromTable(@"mydevice.timersetting.del.failed",@"plugin_gateway", "修改定时失败") duration:1.0 modal:NO];
    }];
    [self gw_clickMethodCountWithStatType:@"deleteClocktimerPage"];

}
#pragma mark - 开关选项设置
- (void)onSettingTimer{
    MHGatewayClockControlSettingViewController *clockSeting = [[MHGatewayClockControlSettingViewController alloc] initWithDevice:(MHDeviceGateway *)_device];
    clockSeting.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmclock",@"plugin_gateway", "闹钟设置");
    [self.navigationController pushViewController:clockSeting animated:YES];
    [self gw_clickMethodCountWithStatType:@"openClocktimerSwitchSettingPage"];

    
}

- (void)updateMonthAndDay:(MHDataDeviceTimer *)timer {
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | kCFCalendarUnitDay | kCFCalendarUnitMonth;
    NSDateComponents* comps = [calendar components:unitFlags fromDate:[NSDate date]];
    if(timer.onRepeatType == MHDeviceTimerRepeat_Once) {
        if (timer.onHour > [comps hour]) {
            timer.onDay = [comps day];
            timer.onMonth = [comps month];
        }
        if (timer.onHour == [comps hour] && timer.onMinute > [comps minute]) {
            timer.onDay = [comps day];
            timer.onMonth = [comps month];
            NSLog(@"开启的时间天%ld", timer.onDay);
        }
        if (timer.onHour < [comps hour]) {
            timer.onDay = [comps day] + 1;
            timer.onMonth = [comps month];
        }
        if (timer.onHour == [comps hour] && timer.onMinute <= [comps minute]) {
            timer.onDay = [comps day] + 1;
            timer.onMonth = [comps month];
        }
        
    }

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
