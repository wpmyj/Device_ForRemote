//
//  MHDeviceGatewaySensorMotion.m
//  MiHome
//
//  Created by Woody on 15/4/2.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewaySensorMotion.h"
#define kFAQEN @"https://app-ui.aqara.cn/faq/ios-en/mp3HumanSensor.html "
#define kFAQCN @"https://app-ui.aqara.cn/faq/ios-cn/mp3HumanSensor.html"

@implementation MHDeviceGatewaySensorMotion
- (id)initWithData:(MHDataDevice* )data {
    if (self = [super initWithData:data]) {
    }
    return self;
}

+ (void)load {
    [MHDevListManager registerDeviceModelId:DeviceModelgateWaySensorMotionV1
                                  className:NSStringFromClass([MHDeviceGatewaySensorMotion class])
                             isRegisterBase:YES];
}

+ (NSUInteger)getDeviceType {
    return MHDeviceType_GatewaySensorMotion;
}

- (BOOL)isSetAlarming {
    if ([self.bindList count] <= 0) {
        return NO;
    }
    
    for (MHLumiBindItem* item in self.bindList) {
        if ([item.from_sid isEqualToString:self.did] &&
            [item.method isEqualToString:Method_Alarm] &&
            [item.event isEqualToString:Gateway_Event_Motion_Motion]
            ) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isSetAlarmClock {
    if ([self.bindList count] <= 0) {
        return NO;
    }
    
    for (MHLumiBindItem* item in self.bindList) {
        if ([item.from_sid isEqualToString:self.did] &&
            [item.method isEqualToString:Method_StopClockMusic] &&
            [item.event isEqualToString:Gateway_Event_Motion_Motion]
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
        if ([item.from_sid isEqualToString:self.did] &&
            [item.method isEqualToString:Method_Door_Bell] &&
            [item.event isEqualToString:Gateway_Event_Motion_Motion]
            ) {
            return YES;
        }
    }
    
    return NO;
}

- (NSString* )eventNameOfSetAlarming {
    return Gateway_Event_Motion_Motion;
}



+ (NSString* )largeIconNameOfStatus:(MHDeviceStatus)status {
    return @"device_icon_gateway_motion";
}

+ (NSString* )getBatteryCategory {
    return @"CR2450";
}

+ (NSString* )getBatteryChangeGuideUrl {
    return Battery_Change_Guide_Motion;
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

- (BOOL)isSetOpenNightLight {
    if ([self.bindList count] <= 0) {
        return NO;
    }
    
    for (MHLumiBindItem* item in self.bindList) {
        if ([item.from_sid isEqualToString:self.did] &&
            [item.method isEqualToString:Method_OpenNightLight] &&
            [item.event isEqualToString:Gateway_Event_Motion_Motion]
            ) {
            return YES;
        }
    }
    return NO;
}



#pragma mark - 感应夜灯开关(时段)
- (void)setOpenNightLightWithTime:(NSArray *)time Success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    MHLumiBindItem* item = [[MHLumiBindItem alloc] init];
    item.event = Gateway_Event_Motion_Motion;
    item.from_sid = self.did;
    item.to_sid = SID_Gateway;
    item.method = Method_OpenNightLight;
    if (time.count > 3) {
        
    }
    item.params =  @[ @{ @"from": @{ @"hour":time[LightTimeOnHour], @"min": time[LightTimeOnMin]}, @"to":@{ @"hour":time[LightTimeOffHour]  ? time[LightTimeOffHour] : @(24), @"min":time[LightTimeOffMin]}, @"wday": @[ @(0),@(1),@(2),@(3),@(4),@(5),@(6)]}];
    [self addBind:item success:success failure:failure];

}

- (void)removesetOpenNightLightWithTime:(NSArray *)time Success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    MHLumiBindItem* item = [[MHLumiBindItem alloc] init];
    item.event = Gateway_Event_Motion_Motion;
    item.from_sid = self.did;
    item.to_sid = SID_Gateway;
    item.method = Method_OpenNightLight;
    item.params =  @[ @{ @"from": @{ @"hour":time[LightTimeOnHour] , @"min": time[LightTimeOnMin]}, @"to":@{ @"hour":time[LightTimeOffHour] ? time[LightTimeOffHour] : @(24), @"min":time[LightTimeOffMin] }, @"wday": @[ @(0),@(1),@(2),@(3),@(4),@(5),@(6)]}];
    
    [self removeBind:item success:success failure:failure];

}

- (void)updateNightLightWithTime:(NSArray *)time Success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    XM_WS(weakself);
    //先移除旧的绑定
    [self removesetOpenNightLightWithTime:time  Success:^(id obj) {
        //创建新的绑定
        [weakself setOpenNightLightWithTime:time Success:^(id obj) {
            if (success) {
                success(obj);
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
 
}


+ (NSString* )offlineTips {
    return NSLocalizedStringFromTable(@"mydevice.gateway.motion.offlineview.tips",@"plugin_gateway","请尝试");
}

+ (BOOL)isDeviceAllowedToShown {
    return YES;
}

- (NSInteger)category
{
    return MHDeviceCategoryZigbee;
}

- (NSString*)defaultName {
    return NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.motion", @"plugin_gateway", nil);
}

#pragma mark - 获取首页展示图片
- (UIImage *)updateMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    UIImage *custom = [super updateMainPageSensorIconWithService:service];
    if(!custom){
        return [UIImage imageNamed:@"gateway_motion_nobody"];
    }
    return custom;
}

- (UIImage *)getMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    UIImage *custom = [super getMainPageSensorIconWithService:service];
    if(!custom){
        return [UIImage imageNamed:@"gateway_motion_nobody"];
    }
    return custom;
}

@end
