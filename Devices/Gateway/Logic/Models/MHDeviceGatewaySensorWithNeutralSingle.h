//
//  MHDeviceGatewaySensorCtrlLn1.h
//  MiHome
//
//  Created by ayanami on 9/5/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewayBase.h"


#define Gateway_Event_CtrlLn1_Change       @"neutral_changed"
#define LumiCtrlLn1TimerIdentify       @"lumi_ln_neutral_onOff.timer.name"

//零火单键
@interface MHDeviceGatewaySensorWithNeutralSingle : MHDeviceGatewayBase

@property (nonatomic, strong) NSString *channel_0;
@property (nonatomic,assign) CGFloat sload_power;//当前功率

@property (nonatomic,assign) CGFloat pw_day;//当日用电量
@property (nonatomic,assign) CGFloat pw_month;//当月用电量

- (NSString *)eventNameOfStatusChange;


#pragma mark - neutral payload
- (void)getPropertyWithSuccess:(SucceedBlock)success andFailure:(FailedBlock)failure;

- (void)switchNeutralWithParam:(NSString *)status
                       Success:(void (^)(id))success
                    andFailure:(void (^)(NSError *))failure;

- (void)getTimerListWithID:(NSString *)identify
                   Success:(SucceedBlock)success
                andFailure:(FailedBlock)failure;

#pragma mark - 电量统计相关
- (void)fetchPlugDataWithSuccess:(SucceedBlock)success failure:(FailedBlock)failure;

- (void)savePlugData:(id)value andGroupType:(NSString *)groupType;

- (id)restorePlugData:(NSString *)groupType;

@end
