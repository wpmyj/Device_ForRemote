//
//  MHGatewayLightTimerSettingViewController.m
//  MiHome
//
//  Created by guhao on 16/1/15.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayLightTimerSettingViewController.h"
#import "MHGatewayTimerView.h"
#import "MHLuTimerDetailViewController.h"

#import "MHGatewayLightTimerDetailViewController.h"
#import "MHGatewayLightTimerView.h"

@interface MHGatewayLightTimerSettingViewController ()
@property (nonatomic,strong) MHDeviceGateway*  device;
@end

@implementation MHGatewayLightTimerSettingViewController  {
    NSString*           _identifier;
    MHGatewayLightTimerView* _deviceTimerView;
    NSMutableArray*     _powerTimerListCopy;
}

- (id)initWithDevice:(MHDeviceGateway *)device andIdentifier:(NSString *)identifier{
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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isTabBarHidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];

    [_device getTimerListWithSuccess:nil failure:nil];

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
    
    XM_WS(weakself);
    _deviceTimerView = [[MHGatewayLightTimerView alloc] initWithDevice:_device timerList:_powerTimerListCopy parentVC:self];
    _deviceTimerView.needBlankCup = YES;
    _deviceTimerView.timerIdentify = _device.did;
    _deviceTimerView.frame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64) ;
    
    //点击事件的回调
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
    MHGatewayLightTimerDetailViewController* timerVC = [[MHGatewayLightTimerDetailViewController alloc] initWithTimer:nil andGatewayDevice:self.device];
    timerVC.onDone = ^(MHDataDeviceTimer* newTimer, NSNumber *nightColor) {
        
        newTimer.identify = @"lumi_gateway_single_rgb_timer";
        newTimer.onMethod = @"set_night_light_rgb";
        newTimer.onParam = @[ nightColor ? nightColor : @(0x2b9400d3) ];
        newTimer.offMethod = @"toggle_light";
        newTimer.offParam = @[ @"off" ];
        newTimer.isEnabled = YES;
        [weakself addTimer:newTimer];
    };
    [self.navigationController pushViewController:timerVC animated:YES];
}

- (void)onModifyTimer:(MHDataDeviceTimer*) timer isNeedOpenEditPage:(BOOL)isNeedOpenEditPage{
    if (isNeedOpenEditPage) {
        XM_WS(weakself);
        MHGatewayLightTimerDetailViewController* timerVC = [[MHGatewayLightTimerDetailViewController alloc] initWithTimer:timer andGatewayDevice:self.device];
        timerVC.onDone = ^(MHDataDeviceTimer* timer, NSNumber *nightColor) {
            if (!timer.isOnOpen && !timer.isOffOpen) {
                [weakself deleteTimer:timer];
            } else {
                timer.onParam = @[ nightColor ? nightColor : @(0x2b9400d3) ];
//                timer.isOnOpen = YES;
//                timer.isOffOpen = YES;
//                timer.isEnabled = YES;
                [weakself modifyTimer:timer];
            }
        };
        [self.navigationController pushViewController:timerVC animated:YES];
    }
    else{
        if (!timer.isOnOpen && !timer.isOffOpen) {
            [self deleteTimer:timer];
        } else {
//            timer.isEnabled = YES;
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
    
    XM_WS(weakself);
    [_device editTimer:newTimer success:^(id obj) {
        [weakself updatePowerTimerView:YES];
        
        [[MHTipsView shareInstance]showFinishTips:NSLocalizedStringFromTable(@"mydevice.timersetting.add.succeed",@"plugin_gateway", "添加定时成功") duration:1.0 modal:NO];
        
    } failure:^(NSError *v) {
        [weakself resetTimerList];
        
        [[MHTipsView shareInstance]showFailedTips:NSLocalizedStringFromTable(@"mydevice.timersetting.add.failed",@"plugin_gateway", "添加定时失败") duration:1.0 modal:NO];
    }];
}

- (void)modifyTimer:(MHDataDeviceTimer*)timer {
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.timersetting.modifying",@"plugin_gateway","修改定时中，请稍候...") modal:YES];
    
    XM_WS(weakself);
    [_device editTimer:timer success:^(id obj) {
        [weakself updatePowerTimerView:YES];
        [[MHTipsView shareInstance]showFinishTips:NSLocalizedStringFromTable(@"mydevice.timersetting.modify.succeed", @"plugin_gateway","修改定时成功") duration:1.0 modal:NO];
        
    } failure:^(NSError *v) {
        [weakself resetTimerList];
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.timersetting.modify.failed", @"plugin_gateway","修改定时失败") duration:1.0 modal:NO];
    }];
    
}

- (void)deleteTimer:(MHDataDeviceTimer*) timer {
    
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.timersetting.deling",@"plugin_gateway","删除定时中，请稍候...") modal:YES];
    [_powerTimerListCopy removeObject:timer];
    
    XM_WS(weakself);
    [_device deleteTimerId:timer.timerId success:^(id obj) {
        
        [weakself updatePowerTimerView:YES];
        
        [[MHTipsView shareInstance]showFinishTips:NSLocalizedStringFromTable(@"mydevice.timersetting.del.succeed", @"plugin_gateway","修改定时成功") duration:1.0 modal:NO];
    } failure:^(NSError *v) {
        
        [weakself resetTimerList];
        
        [[MHTipsView shareInstance]showFailedTips:NSLocalizedStringFromTable(@"mydevice.timersetting.del.failed",@"plugin_gateway", "修改定时失败") duration:1.0 modal:NO];
    }];
    
}

@end
