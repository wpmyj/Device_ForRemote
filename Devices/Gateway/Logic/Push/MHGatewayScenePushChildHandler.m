//
//  MHGatewayScenePushChildHandler.m
//  MiHome
//
//  Created by guolin on 15/4/9.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import "MHGatewayScenePushChildHandler.h"
#import "MHGatewayAlarmTriggerViewController.h"
#import "MHGatewaySensorViewController.h"
#import "MHDeviceGateway.h"
#import "MHGatewayTempAndHumidityViewController.h"

@implementation MHGatewayScenePushChildHandler

#pragma mark - MHScenePushDelegate
- (NSInteger)deviceType {
    return MHDeviceType_Gateway;
}

- (void)sceneAlertTitle:(NSString **)title forEvent:(NSString *)event {
    
    /*
     "push.gateway.alert.alarm.title" = "報警提示";
     "push.gateway.alert.doorbell.title" = "门铃提示";
     "push.gateway.alert.lowbattery.title" = "低电量提示";
     "push.gateway.alert.action.title" = "自动化通知";
     */
    if([event isEqualToString:@"open_alarm"] ||
       [event isEqualToString:@"motion_alarm"] ||
       [event isEqualToString:@"click_alarm"] ||
       [event isEqualToString:@"alert_alarm"]) {
        *title = NSLocalizedStringFromTable(@"push.gateway.alert.alarm.title",@"plugin_gateway","报警提示");
    }
    else if([event isEqualToString:@"motion_battery_end_alarm"] ||
          [event isEqualToString:@"magnet_battery_end_alarm"] ||
            [event isEqualToString:@"switch_battery_end_alarm"] ||
            [event isEqualToString:@"cube_battery_end_alarm"]) {
        *title = NSLocalizedStringFromTable(@"push.gateway.alert.alarm.title",@"plugin_gateway","低电量提示");
    }
    else if([event isEqualToString:@"doorbell_click"] ||
            [event isEqualToString:@"doorbell_double_click"] ||
            [event isEqualToString:@"doorbell_open"] ||
            [event isEqualToString:@"doorbell_motion"]){
        *title = NSLocalizedStringFromTable(@"push.gateway.alert.alarm.title",@"plugin_gateway","门铃提示");

    }
    else {
        *title = NSLocalizedStringFromTable(@"push.gateway.alert.action.title",@"plugin_gateway","自动化通知");
    }
    
}

- (BOOL)customJump
{
    return NO;
}

- (UIViewController *)viewControllerForDevice:(MHDevice *)device withEvent:(NSString *)event time:(NSDate *)time value:(NSDictionary *)value {

    UIViewController *viewController = nil;
    NSString *childDeviceId = [[value objectForKey:@"value"] objectForKey:@"0"];

    MHDevice* fromDevice = [(MHDeviceGateway*)device getSubDevice:childDeviceId];
    if (!fromDevice || !(fromDevice.deviceType >= MHDeviceType_GatewaySensorMotion && fromDevice.deviceType <= MHDeviceType_GatewaySensorHumiture)) {
        return nil;
    }
    
    if([event isEqualToString:@"open_alarm"] ||
       [event isEqualToString:@"motion_alarm"] ||
       [event isEqualToString:@"click_alarm"] ||
       [event isEqualToString:@"alert_alarm"]) {
        viewController = [[MHGatewayAlarmTriggerViewController alloc] initWithAlarmFromSensorId:childDeviceId toDevice:(MHDeviceGateway*)device event:event time:time];
    } else if([event isEqualToString:@"motion_battery_end_alarm"] ||
              [event isEqualToString:@"magnet_battery_end_alarm"] ||
              [event isEqualToString:@"switch_battery_end_alarm"]) {
//        NSInteger battery = [[value objectForKey:@"1"] integerValue];
        MHGatewaySensorViewController* sensorVC = [[MHGatewaySensorViewController alloc] initWithDevice:(MHDeviceGatewayBase*)fromDevice];
        sensorVC.openedFromPush = YES;
        viewController = sensorVC;
    }
    else if ([event isEqualToString:@"doorbell_click"] ||
             [event isEqualToString:@"doorbell_double_click"] ||
             [event isEqualToString:@"doorbell_open"] ||
             [event isEqualToString:@"doorbell_motion"]) {
        MHGatewaySensorViewController* sensorVC = [[MHGatewaySensorViewController alloc] initWithDevice:(MHDeviceGatewayBase*)fromDevice];
        viewController = sensorVC;
    }
    else if ([event isEqualToString:@"hot"] ||
             [event isEqualToString:@"dry"] ||
             [event isEqualToString:@"humid"] ||
             [event isEqualToString:@"cold"] ||
             [event isEqualToString:@"dry_cold"] ||
             [event isEqualToString:@"humid_cold"] ||
             [event isEqualToString:@"dry_hot"] ||
             [event isEqualToString:@"humid_hot"]) {
        MHGatewayTempAndHumidityViewController* sensorVC = [[MHGatewayTempAndHumidityViewController alloc] initWithDevice:(MHDeviceGatewayBase*)fromDevice];
        viewController = sensorVC;
    }
    
    return viewController;
}

@end
