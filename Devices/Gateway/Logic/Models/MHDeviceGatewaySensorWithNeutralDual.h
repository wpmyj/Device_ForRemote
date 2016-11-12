//
//  MHDeviceGatewaySensorCtrlLn2.h
//  MiHome
//
//  Created by ayanami on 9/5/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewayBase.h"

#define Gateway_Event_CtrlLn2_Change       @"neutral_changed"

#define TimerIdentifyCtrlLn2Neutral0       @"lumi_ln_neutral0_onOff.timer.name"
#define TimerIdentifyCtrlLn2Neutral1       @"lumi_ln_neutral1_onOff.timer.name"

//零火双键
@interface MHDeviceGatewaySensorWithNeutralDual : MHDeviceGatewayBase

@property (nonatomic, strong) NSString *channel_0;
@property (nonatomic, strong) NSString *channel_1;

@property (nonatomic,assign) CGFloat sload_power;
@property (nonatomic,assign) CGFloat pw_day;
@property (nonatomic,assign) CGFloat pw_month;

- (NSString *)eventNameOfStatusChange;


#pragma mark - neutral payload
- (void)getPropertyWithSuccess:(SucceedBlock)success andFailure:(FailedBlock)failure ;

- (void)switchNeutralWithNeutral:(NSString *)neutral
                           Param:(NSString *)status
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
