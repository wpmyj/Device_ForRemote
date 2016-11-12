//
//  MHDeviceGatewaySensorDoubleSwitch.m
//  MiHome
//
//  Created by guhao on 15/12/29.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewaySensorDoubleSwitch.h"

@implementation MHDeviceGatewaySensorDoubleSwitch
- (instancetype)initWithData:(MHDataDevice *)data
{
    self = [super initWithData:data];
    if (self) {
        
    }
    return self;
}

+ (void)load {
    [MHDeviceListManager registerDeviceModelId:DeviceModelgateWaySensor86Switch2V1 className:(NSStringFromClass([MHDeviceGatewaySensorDoubleSwitch class])) isRegisterBase:YES];
}

- (NSUInteger)getDeviceType {
    return MHDeviceType_GatewaySensor86Switch2;
}

+ (BOOL)isDeviceAllowedToShown {
    return YES;
}



+ (NSString* )largeIconNameOfStatus:(MHDeviceStatus)status {

    return @"device_icon_gateway_86switch2";
}

+ (NSString* )getBatteryCategory {
    return @"CR2032";
}

+ (NSString* )getBatteryChangeGuideUrl {
    return Battery_Change_Guide_Switch;
}

+ (NSString *)getViewControllerClassName {
    return @"MHGatewaySensorViewController";
}

- (NSInteger)category
{
    return MHDeviceCategoryZigbee;
}

- (NSString*)defaultName {
    return NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.doubleswitch", @"plugin_gateway", nil);
}
+ (NSString* )offlineTips {
    return NSLocalizedStringFromTable(@"mydevice.gateway.86switch.offlineview.tips",@"plugin_gateway","请尝试");
}

- (NSString* )eventNameOfStatusChange:(DoubleSwitchEvent)status {
    switch (status) {
        case DoubleSwitch_click_ch0:
            return Gateway_Event_DoubleSwitch_click_ch0;
            break;
        case DoubleSwitch_double_click_ch0:
            return Gateway_Event_DoubleSwitch_double_click_ch0;
            break;
        case DoubleSwitch_click_ch1:
            return Gateway_Event_DoubleSwitch_click_ch1;
            break;
        case DoubleSwitch_double_click_ch1:
            return Gateway_Event_DoubleSwitch_double_click_ch1;
            break;
        case DoubleSwitch_both_click:
            return Gateway_Event_DoubleSwitch_both_click;
            break;
             default:
            break;
    }
    return nil;
}

#pragma mark - 获取首页展示图片
- (UIImage *)updateMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    UIImage *custom = [super updateMainPageSensorIconWithService:service];
    if(!custom){
        return [UIImage imageNamed:@"home_86_double"];
    }
    return custom;
}
- (UIImage *)getMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    UIImage *custom = [super getMainPageSensorIconWithService:service];
    if(!custom){
        return [UIImage imageNamed:@"home_86_double"];
    }
    return custom;
}

@end
