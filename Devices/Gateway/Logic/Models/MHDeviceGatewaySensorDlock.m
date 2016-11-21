//
//  MHDeviceGatewayDlock.m
//  MiHome
//
//  Created by ayanami on 16/5/30.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewaySensorDlock.h"

@implementation MHDeviceGatewaySensorDlock

- (id)initWithData:(MHDataDevice* )data {
    if (self = [super initWithData:data]) {
    }
    return self;
}

+ (void)load {
//    [MHDevListManager registerDeviceModelId:DeviceModelgateWaySensorDlockV1
//                                  className:NSStringFromClass([MHDeviceGatewaySensorDlock class])
//                             isRegisterBase:YES];
}

+ (NSUInteger)getDeviceType {
    return MHDeviceType_GatewaySensorSwitch;
}


- (NSString* )eventNameOfSetAlarming {
    return Gateway_Event_Switch_Click;
}


+ (NSString* )largeIconNameOfStatus:(MHDeviceStatus)status {
    return @"device_icon_gateway_switcher";
}

+ (NSString* )getBatteryCategory {
    return @"CR2032";
}

+ (NSString* )getBatteryChangeGuideUrl {
    return Battery_Change_Guide_Switch;
}

+ (NSString* )offlineTips {
    return NSLocalizedStringFromTable(@"mydevice.gateway.switch.offlineview.tips",@"plugin_gateway","请尝试");
}

+ (BOOL)isDeviceAllowedToShown {
    return YES;
}

- (NSInteger)category
{
    return MHDeviceCategoryZigbee;
}

- (NSString*)defaultName {
    return NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.switch", @"plugin_gateway", nil);
}


+ (NSString* )getViewControllerClassName {
    return @"MHGatewaySensorViewController";
}

//是否在主app快联页显示
- (BOOL)isShownInQuickConnectList {
    return NO;
}

#pragma mark - 获取首页展示图片
- (UIImage *)updateMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    UIImage *custom = [super updateMainPageSensorIconWithService:service];
    if(!custom){
        return [UIImage imageNamed:@"gateway_switch_click"];
    }
    return custom;
}

- (UIImage *)getMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    UIImage *custom = [super getMainPageSensorIconWithService:service];
    if(!custom){
        return [UIImage imageNamed:@"gateway_switch_click"];
    }
    return custom;
}
@end
