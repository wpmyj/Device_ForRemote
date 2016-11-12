//
//  MHDeviceGatewaySensorMagnet.m
//  MiHome
//
//  Created by Woody on 15/4/2.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewaySensorMagnet.h"
#define kFAQEN @"https://app-ui.aqara.cn/faq/ios-en/mp4DoorSensor.html"
#define kFAQCN @"https://app-ui.aqara.cn/faq/ios-cn/mp4DoorSensor.html"

@implementation MHDeviceGatewaySensorMagnet

- (id)initWithData:(MHDataDevice* )data {
    if (self = [super initWithData:data]) {
    }
    return self;
}

+ (void)load {
    [MHDevListManager registerDeviceModelId:DeviceModelgateWaySensorMagnetV1
                                  className:NSStringFromClass([MHDeviceGatewaySensorMagnet class])
                             isRegisterBase:YES];
}

+ (NSUInteger)getDeviceType {
    return MHDeviceType_GatewaySensorMagnet;
}

- (BOOL)isSetAlarming {
    if ([self.bindList count] <= 0) {
        return NO;
    }

    for (MHLumiBindItem* item in self.bindList) {
        if ([item.from_sid isEqualToString:self.did] &&
            [item.method isEqualToString:Method_Alarm] &&
            [item.event isEqualToString:Gateway_Event_Magnet_Open]
            ) {
            return YES;
        }
    }
    return NO;
}

-(BOOL)isSetAlarmClock{
    if ([self.bindList count] <= 0) {
        return NO;
    }
    
    for (MHLumiBindItem* item in self.bindList) {
        if ([item.from_sid isEqualToString:self.did] &&
            [item.method isEqualToString:Method_StopClockMusic] &&
            [item.event isEqualToString:Gateway_Event_Magnet_Open]
            ) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isSetDoorBell {
    if ([self.bindList count] <= 0) {
        return NO;
    }
    
    for (MHLumiBindItem* item in self.bindList) {
        NSLog(@"%@", item);
        NSLog(@"item的时间%@", item.event);
        NSLog(@"item的来自对象%@", item.from_sid);
        if ([item.from_sid isEqualToString:self.did] &&
            [item.method isEqualToString:Method_Door_Bell] &&
            [item.event isEqualToString:Gateway_Event_Magnet_Open]
            ) {
            return YES;
        }
    }
    
    return NO;
}

- (NSString* )eventNameOfSetAlarming {
    return Gateway_Event_Magnet_Open;
}


+ (NSString* )largeIconNameOfStatus:(MHDeviceStatus)status {
    return @"device_icon_gateway_magnet";
}

+ (NSString* )getBatteryCategory {
    return @"CR1632";
}

+ (NSString* )getBatteryChangeGuideUrl {
    return Battery_Change_Guide_Magnet;
}

+ (NSString* )offlineTips {
    return NSLocalizedStringFromTable(@"mydevice.gateway.magnet.offlineview.tips",@"plugin_gateway","请尝试");
}

+ (NSString *)getFAQUrl {
    NSString *url = nil;
    NSString *currentLanguage = [[MHLumiHtmlHandleTools sharedInstance] currentLanguage];
    if ([currentLanguage hasPrefix:@"zh-Hans"]) {
        url = kFAQCN;
    }
    else {
        url = kFAQEN;
    }
    return url;
}


+ (BOOL)isDeviceAllowedToShown {
    return YES;
}

- (NSInteger)category
{
    return MHDeviceCategoryZigbee;
}

- (NSString*)defaultName {
    return NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.magnet", @"plugin_gateway", nil);
}

#pragma mark - 获取首页展示图片
- (UIImage *)updateMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    UIImage *custom = [super updateMainPageSensorIconWithService:service];
    if(!custom){
        return [UIImage imageNamed:@"gateway_magnet_close"];
    }
    return custom;
}


- (UIImage *)getMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    UIImage *custom = [super getMainPageSensorIconWithService:service];
    if(!custom){
        return [UIImage imageNamed:@"gateway_magnet_close"];
    }
    return custom;
}

@end
