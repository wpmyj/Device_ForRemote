//
//  MHDeviceGatewaySensorSmoke.m
//  MiHome
//
//  Created by guhao on 16/5/9.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewaySensorSmoke.h"

@implementation MHDeviceGatewaySensorSmoke
- (id)initWithData:(MHDataDevice* )data {
    if (self = [super initWithData:data]) {
    }
    return self;
}

+ (void)load {
    [MHDevListManager registerDeviceModelId:DeviceModelgateWaySensorSmokeV1
                                  className:NSStringFromClass([MHDeviceGatewaySensorSmoke class])
                             isRegisterBase:YES];
}

+ (NSUInteger)getDeviceType {
    return MHDeviceType_GatewaySensorSwitch;
}


+ (NSString* )largeIconNameOfStatus:(MHDeviceStatus)status {
    return @"device_icon_smoke";
}

+ (NSString* )getBatteryCategory {
    return @"CR123A";
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
    return @"MHGatewayNatgasViewController";
}

//是否在主app快联页显示
- (BOOL)isShownInQuickConnectList {
    return NO;
}

#pragma mark - 获取首页展示图片
//继承关系先写死
- (UIImage *)updateMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    UIImage *custom = [super updateMainPageSensorIconWithService:service];
    if(custom){
        return [UIImage imageNamed:@"home_smoke_on"];
    }
    return custom;
}


- (UIImage *)getMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    UIImage *custom = [super getMainPageSensorIconWithService:service];
    if(custom){
        return [UIImage imageNamed:@"home_smoke_on"];
    }
    return custom;
}
@end
