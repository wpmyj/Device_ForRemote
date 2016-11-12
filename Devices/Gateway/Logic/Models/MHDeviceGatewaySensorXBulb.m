//
//  MHDeviceGatewaySensorXBulb.m
//  MiHome_gateway
//
//  Created by Lynn on 7/25/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewaySensorXBulb.h"

@implementation MHDeviceGatewaySensorXBulb

- (id)initWithData:(MHDataDevice* )data {
    if (self = [super initWithData:data]) {
        [self getDeviceProp:@"power" success:nil failure:nil];
    }
    return self;
}

+ (void)load {
    [MHDevListManager registerDeviceModelId:DeviceModelgateWaySensorXBulbV1 className:NSStringFromClass([MHDeviceGatewaySensorXBulb class]) isRegisterBase:YES];
}

#pragma mark -- 获取 xbulb 的设备属性
- (void)getPropertyWithSuccess:(SucceedBlock)success andFailure:(FailedBlock)failure {
    [self getDeviceProp:@"power" success:^(id obj) {
        if(success)success(obj);
    } failure:^(NSError *error) {
        if(failure)failure(error);
    }];
}

- (void)getDeviceProp:(NSString *)propName
              success:(void (^)(id))success
              failure:(void (^)(NSError *))failure {
    XM_WS(weakself);
    NSDictionary *payload = [self requestPayloadWithMethodName:@"get_bright"
                                                         value:propName];
    [self sendPayload:payload success:^(id respObj) {
        [weakself setIsOpen:[[[respObj valueForKey:@"result"] firstObject] integerValue] ? YES : NO];
        weakself.bright = [[[respObj valueForKey:@"result"] firstObject] integerValue];
        if (success) success(respObj);
        
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

- (void)setDeviceBrightness:(void (^)(id))success
                    failure:(void (^)(NSError *))failure
                  propvalue:(int)value {
    XM_WS(weakself);
    NSDictionary *payload = [self requestPayloadWithMethodName:@"set_bright"
                                                         value:@( value )];
    [self sendPayload:payload success:^(id respObj) {
        [weakself setIsOpen:value ? YES : NO];
        weakself.bright = value;
        
        if (success) {
            success(respObj);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)setToggleLight:(void (^)(id))success
               failure:(void (^)(NSError *))failure {
    XM_WS(weakself);
    NSDictionary *payload = [self requestPayloadWithMethodName:@"toggle" value:nil];
    [self sendPayload:payload success:^(id respObj) {
        
        [weakself getDeviceProp:@"birght" success:nil failure:nil];
        if (success) {
            success(respObj);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (NSUInteger)getDeviceType {
    return MHDeviceType_GatewaySensorXBulb;
}



+ (NSString* )largeIconNameOfStatus:(MHDeviceStatus)status {
    switch (status) {
        case MHDeviceStatus_Open:
            return @"ge_light_on_";
        case MHDeviceStatus_Close:
            return @"ge_light_off_";
        case MHDeviceStatus_Offline:
            return @"ge_light_offline_";
        default:
            return @"ge_light_offline_";
    }
}

+ (BOOL)isDeviceAllowedToShown {
    return NO;
}

+ (NSString* )getBatteryChangeGuideUrl {
    return Battery_Change_Guide_Switch;
}

+ (NSString* )getViewControllerClassName {
    return @"MHGatewayXBulbViewController";
}

- (NSInteger)category
{
    return MHDeviceCategoryZigbee;
}

//是否在主app快联页显示
- (BOOL)isShownInQuickConnectList {
    return NO;
}

@end
