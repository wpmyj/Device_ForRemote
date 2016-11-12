//
//  MHDeviceGatewaySensorCube.m
//  MiHome
//
//  Created by Lynn on 9/9/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewaySensorCube.h"

@implementation MHDeviceGatewaySensorCube

- (id)initWithData:(MHDataDevice* )data {
    if (self = [super initWithData:data]) {
    }
    return self;
}

+ (void)load {
    [MHDevListManager registerDeviceModelId:DeviceModelgateWaySensorCubeV1
                                  className:NSStringFromClass([MHDeviceGatewaySensorCube class])
                             isRegisterBase:YES];
}

- (NSString* )eventNameOfStatusChange:(CubeEvent)status
{
    switch (status) {
        case Cube_flip90:
            return Gateway_Event_Cube_flip90;
            break;
        case Cube_flip180:
            return Gateway_Event_Cube_flip180;
            break;
        case Cube_move:
            return Gateway_Event_Cube_move;
            break;
        case Cube_tap_twice:
            return Gateway_Event_Cube_tap_twice;
            break;
        case Cube_shake_air:
            return Gateway_Event_Cube_shakeair;
            break;
        case Cube_rotate:
            return Gateway_Event_Cube_rotate;
            break;
        default:
            break;
    }
    return nil;
}

+ (NSUInteger)getDeviceType {
    return MHDeviceType_GatewaySensorCube;
}


+ (NSString* )largeIconNameOfStatus:(MHDeviceStatus)status {
    return @"device_icon_gateway_cube";

}

+ (NSString* )getBatteryCategory {
    return @"CR1632";
}

+ (NSString* )getBatteryChangeGuideUrl {
    return Battery_Change_Guide_Magnet;
}

+ (BOOL)isDeviceAllowedToShown {
    return YES;
}

+(NSString *)getViewControllerClassName {
    return @"MHGatewayCubeViewController";
}

- (NSInteger)category
{
    return MHDeviceCategoryZigbee;
}

#pragma mark - 获取首页展示图片
- (UIImage *)updateMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    UIImage *custom = [super updateMainPageSensorIconWithService:service];
    if(!custom){
        return [UIImage imageNamed:@"gateway_cube"];
    }
    return custom;
}

- (UIImage *)getMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    UIImage *custom = [super getMainPageSensorIconWithService:service];
    if(!custom){
        return [UIImage imageNamed:@"gateway_cube"];
    }
    return custom;
}

- (BOOL)isSetAlarming {
    if ([self.bindList count] <= 0) {
        return NO;
    }
    
    for (MHLumiBindItem* item in self.bindList) {
        if ([item.from_sid isEqualToString:self.did] &&
            [item.method isEqualToString:Method_Alarm] &&
            [item.event isEqualToString:Gateway_Event_Cube_alert]
            ) {
            return YES;
        }
    }
    return NO;
}

- (NSString* )eventNameOfSetAlarming {
    return Gateway_Event_Cube_alert;
}

- (NSString*)defaultName {
    return NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.cube", @"plugin_gateway", nil);
}

+ (NSString* )offlineTips {
    return NSLocalizedStringFromTable(@"mydevice.gateway.humiture.offlineview.tips",@"plugin_gateway","请尝试");
}
@end
