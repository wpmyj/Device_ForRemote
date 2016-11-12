//
//  MHGatewayTimerSettingNewViewController.m
//  MiHome
//
//  Created by Lynn on 7/30/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayTimerSettingNewViewController.h"
#import "MHGatewayTimerView.h"
#import "MHLuTimerDetailViewController.h"

@interface MHGatewayTimerSettingNewViewController ()
@property (nonatomic,strong) MHDevice*  device;
@end

@implementation MHGatewayTimerSettingNewViewController {
    NSString*           _identifier;
    MHGatewayTimerView* _deviceTimerView;
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

    _deviceTimerView = [[MHGatewayTimerView alloc] initWithDevice:_device timerList:_powerTimerListCopy parentVC:self];
    _deviceTimerView.needBlankCup = YES;
    _deviceTimerView.timerIdentify = _device.did;
    _deviceTimerView.frame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64) ;
    if(self.customName) _deviceTimerView.customName = self.customName;
    
    //点击事件的回调
    XM_WS(weakself);
    _deviceTimerView.onAddTimer = ^{
        [weakself onAddTimer];
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
    MHLuTimerDetailViewController* timerVC = [[MHLuTimerDetailViewController alloc] initWithTimer:nil];
    timerVC.onDone = ^(MHDataDeviceTimer* newTimer) {
        
        if(weakself.onAddNewTimer) weakself.onAddNewTimer(newTimer);
        else [weakself addTimer:newTimer];
    };
//    MHLuTimerDetailViewController *timerVC = [[MHLuTimerDetailViewController alloc] initWithTimer:nil andIdentifier:_identifier];
//    timerVC.onDone = ^(MHDataDeviceTimer* newTimer) {
//        
//        if(weakself.onAddNewTimer) weakself.onAddNewTimer(newTimer);
//        else [weakself addTimer:newTimer];
//    };

    [self.navigationController pushViewController:timerVC animated:YES];
}

- (void)onModifyTimer:(MHDataDeviceTimer*) timer {
    [self modifyTimer:timer];
}

- (void)onModifyTimer:(MHDataDeviceTimer*) timer isNeedOpenEditPage:(BOOL)isNeedOpenEditPage{
    if (isNeedOpenEditPage) {
        XM_WS(weakself);
        MHLuTimerDetailViewController* timerVC = [[MHLuTimerDetailViewController alloc] initWithTimer:timer];
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

- (void)addTimer:(MHDataDeviceTimer*) newTimer{
    
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.timersetting.adding",@"plugin_gateway","添加定时中，请稍候...") modal:YES];
    
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
    
    XM_WS(weakself);
    [_device editTimer:timer success:^(id obj) {
        [weakself updatePowerTimerView:YES];
        NSLog(@"%@, %@", timer.offMethod, timer.offParam);
        [[MHTipsView shareInstance]showFinishTips:NSLocalizedStringFromTable(@"mydevice.timersetting.modify.succeed", @"plugin_gateway","修改定时成功") duration:1.0 modal:NO];
        
    } failure:^(NSError *v) {
        [weakself resetTimerList];
        
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.timersetting.modify.failed", @"plugin_gateway","修改定时失败") duration:1.0 modal:NO];
        
    }];
    
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
    
}

@end
