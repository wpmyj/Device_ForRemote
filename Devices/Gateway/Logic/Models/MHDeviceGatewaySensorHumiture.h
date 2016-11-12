//
//  MHDeviceGatewaySensorHumiture.h
//  MiHome
//
//  Created by Lynn on 11/9/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewayBase.h"

#define LUMI_HUMITURE_TEMP_PROP         @"temperature"
#define LUMI_HUMITURE_HUMIDITY_PROP     @"humidity"


//温湿度传感器
@interface MHDeviceGatewaySensorHumiture : MHDeviceGatewayBase

@property (nonatomic, assign) float temperature;
@property (nonatomic, assign) float humidity;
@property (nonatomic, retain) NSDate *time;
@property (nonatomic, strong) NSString *advice;
@property (nonatomic, strong) NSString *lastTime;

//网关
- (void)getDeviceProp:(NSArray<NSString*>*)propNames
              success:(void (^)(id))success
              failure:(void (^)(NSError *))failure;
//云端
- (void)getHTProp:(NSString *)prop
              success:(void (^)(id))success
              failure:(void (^)(NSError *))failure;

- (NSString* )getStatusText;
- (void)saveStatus;
//读取缓存
- (void)readStatus;


@end





