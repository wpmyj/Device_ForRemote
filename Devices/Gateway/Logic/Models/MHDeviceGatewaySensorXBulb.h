//
//  MHDeviceGatewaySensorXBulb.h
//  MiHome_gateway
//
//  Created by Lynn on 7/25/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewayBase.h"

@interface MHDeviceGatewaySensorXBulb : MHDeviceGatewayBase

@property (nonatomic,assign) NSUInteger bright;

- (void)getPropertyWithSuccess:(SucceedBlock)success andFailure:(FailedBlock)failure;

- (void)getDeviceProp:(NSString *)propName success:(void (^)(id))success failure:(void (^)(NSError *))failure;
- (void)setDeviceBrightness:(void (^)(id))success failure:(void (^)(NSError *))failure propvalue:(int)value;
- (void)setToggleLight:(void (^)(id))success failure:(void (^)(NSError *))failure;

@end
