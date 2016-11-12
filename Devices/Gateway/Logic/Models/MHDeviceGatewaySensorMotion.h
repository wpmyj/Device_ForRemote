//
//  MHDeviceGatewaySensorMotion.h
//  MiHome
//
//  Created by Woody on 15/4/2.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewayBase.h"

typedef enum{
    LightTimeOnHour,
    LightTimeOnMin,
    LightTimeOffHour,
    LightTimeOffMin
}LightTimeType;

//人体传感器
@interface MHDeviceGatewaySensorMotion : MHDeviceGatewayBase

// 是否设置智能彩灯感应开关
- (BOOL)isSetOpenNightLight;
- (BOOL)isSetDoorBell;


- (void)setOpenNightLightWithTime:(NSArray *)time Success:(void (^)(id obj))success failure:(void (^)(NSError *error))failure;
- (void)removesetOpenNightLightWithTime:(NSArray *)time Success:(void (^)(id obj))success failure:(void (^)(NSError *error))failure;

- (void)updateNightLightWithTime:(NSArray *)time Success:(void (^)(id obj))success failure:(void (^)(NSError *error))failure;


@end
