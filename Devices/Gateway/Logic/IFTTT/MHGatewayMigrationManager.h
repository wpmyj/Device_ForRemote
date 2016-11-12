//
//  MHGatewayMigrationManager.h
//  MiHome
//
//  Created by Lynn on 5/6/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHDeviceGateway.h"

@interface MHGatewayMigrationManager : NSObject

+ (id)sharedInstance;

/**
 *  迁移调用
 *
 *  @param oldGateway 待迁移旧网关
 *  @param newGateway 新网关
 *  @param success    success description
 *  @param failure    failure description
 */
- (void)gatewayMigrationInvoker:(MHDeviceGateway *)oldGateway
                     newGateway:(MHDeviceGateway *)newGateway
                    withSuccess:(SucceedBlock)success
                        failure:(FailedBlock)failure
                       progress:(void (^)(CGFloat))progress;


- (void)gatewayDeleteDeviceData:(MHDeviceGateway *)oldGateway;

@end
