//
//  GatewayInfoGetter.h
//  MiHome
//
//  Created by LM21Mac002 on 16/9/13.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
//MHDeviceGatewayBase 已实现
@protocol GatewayInfoGetter <NSObject>

//ZigbeeChannel
- (void)fetchZigbeeChannelWithSuccess:(void(^)(NSString *channel,NSDictionary *result))success
                              failure:(void(^)(NSError *error))failure;

//网关信息
- (void)fetchGatewayInfoWithSuccess:(void(^)(NSString *gatewayInfo,NSDictionary *result))success
                            failure:(void(^)(NSError *error))failure;

- (NSString *)gatewayId;
- (NSString *)subDevicesInfo;
@end