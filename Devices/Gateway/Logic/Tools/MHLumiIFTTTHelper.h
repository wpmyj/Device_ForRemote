//
//  MHLumiIFTTTHelper.h
//  MiHome
//
//  Created by LM21Mac002 on 16/10/9.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHDeviceGatewayBase.h"

@interface MHLumiIFTTTHelper : NSObject
//2016年的双11一次性接口，添加默认自定义自动化
//无线开关的单击trigerId： 4
//网关的警戒切换actionId：138
+ (void)addCustomIFTTTAtDouble11WithGateway:(MHDeviceGatewayBase *)gateway
                                   actionId:(NSString *)actionId
                             subDeviceClass:(Class) subDeviceClass
                                   trigerId:(NSString *)trigerId
                                 customName:(NSString *)customName
                          completionHandler:(void(^)(bool flag))completionHandler;

+ (void)addCustomIFTTTAtDouble11WithGateway:(MHDeviceGatewayBase *)gateway
                                   actionId:(NSString *)actionId
                          actionDeviceClass:(Class) actionDeviceClass
                                   trigerId:(NSString *)trigerId
                          trigerDeviceClass:(Class) trigerDeviceClass
                                 customName:(NSString *)customName
                          completionHandler:(void (^)(bool flag))completionHandler;
@end
