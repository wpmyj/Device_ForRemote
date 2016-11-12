//
//  MHGatewayClockTimerListViewController.m
//  MiHome
//
//  Created by Lynn on 3/5/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayClockTimerListViewController.h"
#import "MHGatewayClockTimerEditViewController.h"

@interface MHGatewayClockTimerListViewController ()

@end

@implementation MHGatewayClockTimerListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)buildSubviews {
    self.customName = NSLocalizedStringFromTable(@"timer.blank.name.clocktimer", @"plugin_gateway", nil);
    [super buildSubviews];
}

#pragma mark - 按键
- (void)onAddTimer {
    MHGatewayClockTimerEditViewController *alarmClockVC = [[MHGatewayClockTimerEditViewController alloc] init];
    alarmClockVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmclock",@"plugin_gateway", "闹钟设置");
    alarmClockVC.isTabBarHidden = YES;
    alarmClockVC.isGroupStyle = YES;
    [self.navigationController pushViewController:alarmClockVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"openAlarmClockSetting"];
}

- (void)onModifyTimer:(MHDataDeviceTimer *)timer {
    MHGatewayClockTimerEditViewController *alarmClockVC = [[MHGatewayClockTimerEditViewController alloc] init];
    alarmClockVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmclock",@"plugin_gateway", "闹钟设置");
    alarmClockVC.isTabBarHidden = YES;
    alarmClockVC.isGroupStyle = YES;
    [self.navigationController pushViewController:alarmClockVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"openAlarmClockSetting"];
}

@end
