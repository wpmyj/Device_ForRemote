//
//  GatewayProtocolGetter.h
//  MiHome
//
//  Created by LM21Mac002 on 16/9/13.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
//MHDeviceGatewayBase 已实现
@protocol GatewayProtocolGetter <NSObject>
- (void)fetchLumiDpfAesKeyWithSuccess:(void(^)(NSString *passWord,NSDictionary *result))success
                              failure:(void(^)(NSError *error))failure;

- (void)setLumiDpfAesKeyWithPassWord:(NSString *)passWord
                             success:(void(^)(NSDictionary *result))success
                             failure:(void(^)(NSError *error))failure;
@end
