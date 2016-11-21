//
//  MHDeviceGatewaySensorDoorLock.h
//  MiHome
//
//  Created by LM21Mac002 on 16/10/15.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHDeviceGatewayBase.h"
typedef NS_ENUM(NSInteger, MHDeviceGatewaySensorDoorLockModel){
    /**
     *  安防
     */
    MHDeviceGatewaySensorDoorLockModelSafeGuard         =0x00,
    /**
     *  控制
     */
    MHDeviceGatewaySensorDoorLockModelNormal            =0x01,
    /**
     *  关怀
     */
    MHDeviceGatewaySensorDoorLockModelConcern           =0x02,
    /**
     *  未知(未获取)
     */
    MHDeviceGatewaySensorDoorLockModelUnknown           =-1,
};

/**
 *  门锁传感器
 */
@interface MHDeviceGatewaySensorDoorLock : MHDeviceGatewayBase
@property (nonatomic, assign, readonly) MHDeviceGatewaySensorDoorLockModel doorLockModel;
- (void)setDoorLockModel:(MHDeviceGatewaySensorDoorLockModel)doorLockModel
             withSuccess:(void (^)())success
                 failure:(void (^)(NSError *))failure;

- (void)fetchDoorLockModelwithSuccess:(void (^)(MHDeviceGatewaySensorDoorLock *))success
                              failure:(void (^)(NSError *))failure;
@end
