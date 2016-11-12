//
//  MHDeviceGatewaySensorCurtain.h
//  MiHome
//
//  Created by guhao on 15/12/24.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewayBase.h"

#define Gateway_Level_Curtain_100           100
#define Gateway_Level_Curtain_90            90
#define Gateway_Level_Curtain_80            80
#define Gateway_Level_Curtain_70            70
#define Gateway_Level_Curtain_60            60
#define Gateway_Level_Curtain_50            50
#define Gateway_Level_Curtain_40            40

#define LumiCurtainTimerIdentify @"lumi_curtain_timer_onOff"

typedef enum : NSInteger {
    POSLIMITSTATE_INDEX,
    POLARITY_INDEX,
    MANUALENABLED_INDEX,
    MOTORSTATUS_INDEX,
} WriteMask_Prop_Id;


//智能窗帘
@interface MHDeviceGatewaySensorCurtain : MHDeviceGatewayBase



@property (nonatomic, assign) int curtain_level;
@property (nonatomic, strong) NSString *curtain_status;
@property (nonatomic, assign) int present;

@property (nonatomic, assign) int writeMask;// 标志要写的成员是哪一个，需要写的成员的对应为置位1
@property (nonatomic, assign) BOOL posLimitState;//电机是否已经设置了行程
@property (nonatomic, assign) BOOL polarity;//电机旋转的极性
@property (nonatomic, assign) int motorStatus;//电机当前的状态
@property (nonatomic, assign) BOOL manualEnabled;//电机是否使能了手拉功能
@property (nonatomic, assign) int totalTime;//窗帘从起点运行到终点使用的时间

/*
 0x00: 电机正常停止   0x01：电机打开 0x02：电机关闭 0x03: 电机处于设置状态  0x04:电机遇阻停止
 */


#pragma mark - curtain payload
- (void)setCurtainProperty:(NSInteger)value
                andSuccess:(SucceedBlock)success
                   failure:(FailedBlock)failure;
- (void)getCurtainPropertyStatusWithSuccess:(SucceedBlock)success failure:(FailedBlock)failure;

#pragma mark - 私有属性
- (void)getPrivatePropertySuccess:(SucceedBlock)success failure:(FailedBlock)failure;
- (void)setPrivateProperty:(WriteMask_Prop_Id)propid value:(id)value success:(SucceedBlock)success failure:(FailedBlock)failure;

#pragma mark - control
- (void)openCurtainSuccess:(void (^)(id obj))success
                     andFailure:(void (^)(NSError *))failure;

- (void)stopCurtainSuccess:(void (^)(id obj))success
                     andFailure:(void (^)(NSError *))failure;

- (void)closeCurtainSuccess:(void (^)(id obj))success
                     andFailure:(void (^)(NSError *))failure;

@end
