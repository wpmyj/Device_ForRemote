//
//  MHDeviceGatewaySensorSingleSwitch.m
//  MiHome
//
//  Created by guhao on 15/12/29.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewaySensorSingleSwitch.h"


@implementation MHDeviceGatewaySensorSingleSwitch
- (instancetype)initWithData:(MHDataDevice *)data
{
    self = [super initWithData:data];
    if (self) {
        
    }
    return self;
}

+ (void)load {
        [MHDeviceListManager registerDeviceModelId:DeviceModelgateWaySensor86Switch1V1 className:(NSStringFromClass([MHDeviceGatewaySensorSingleSwitch class])) isRegisterBase:YES];
}

- (NSUInteger)getDeviceType {
    return MHDeviceType_GatewaySensor86Switch1;
}



+ (NSString* )largeIconNameOfStatus:(MHDeviceStatus)status {
    return @"device_icon_gateway_86switch";
}

+ (NSString* )getBatteryCategory {
    return @"CR2032";
}

+ (NSString* )getBatteryChangeGuideUrl {
    return Battery_Change_Guide_Switch;
}

+ (BOOL)isDeviceAllowedToShown {
    return YES;
}

+ (NSString *)getViewControllerClassName {
    return @"MHGatewaySensorViewController";
}
- (NSInteger)category
{
    return MHDeviceCategoryZigbee;
}

- (NSString*)defaultName {
    return NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.singleswitch", @"plugin_gateway", nil);
}

+ (NSString* )offlineTips {
    return NSLocalizedStringFromTable(@"mydevice.gateway.86switch.offlineview.tips",@"plugin_gateway","请尝试");
}

- (NSString* )eventNameOfStatusChange:(SingleSwitchEvent)status {
    switch (status) {
        case SingleSwitch_click: {
            return Gateway_Event_SingleSwitch_click;
        }
            break;
        case SingleSwitch_double_click: {
            return Gateway_Event_SingleSwitch_double_click;
        }
            break;
        default:
            break;
    }
    return  nil;
}

#pragma mark - 获取首页展示图片
- (UIImage *)updateMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    UIImage *custom = [super updateMainPageSensorIconWithService:service];
    if(!custom){
        return [UIImage imageNamed:@"home_86_single"];
    }
    return custom;
}

- (UIImage *)getMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    UIImage *custom = [super getMainPageSensorIconWithService:service];
    if(!custom){
        return [UIImage imageNamed:@"home_86_single"];
    }
    return custom;
}

@end
