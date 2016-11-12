//
//  MHDeviceGatewaySensorNatgas.h
//  MiHome
//
//  Created by ayanami on 16/5/30.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewayBase.h"
typedef enum : NSInteger {
    HIGH_INDEX = 1,//报警灵敏度高
    MIDDLE_INDEX,
    LOW_INDEX,
    SELFTEST_INDEX,//自检
    SELFTEST_ENABLE_INDEX, //设备自检提醒
} Natgas_Prop_Id;

//气体传感器
@interface MHDeviceGatewaySensorNatgas : MHDeviceGatewayBase

@property (nonatomic, assign) uint8_t density;
@property (nonatomic, assign) Natgas_Prop_Id sensitivity;
@property (nonatomic, assign) bool selfcheckEnable;

- (void)setPrivateProperty:(Natgas_Prop_Id)propid value:(id)value success:(SucceedBlock)success failure:(FailedBlock)failure;
- (void)getPrivateProperty:(Natgas_Prop_Id)propid success:(SucceedBlock)success failure:(FailedBlock)failure;

- (void)saveStatus;
//读取缓存
- (void)readStatus;
@end
