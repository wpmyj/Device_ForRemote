//
//  MHDeviceGatewaySensorPlug.h
//  MiHome
//
//  Created by Lynn on 9/2/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewayBase.h"

#define TimerIdentify           @"plug.timer.name"
#define CountDownIdentify       @"lumi_gateway_plug_countdown"

static NSDictionary *logoNames;

//智能插座zigbee版
@interface MHDeviceGatewaySensorPlug : MHDeviceGatewayBase

@property (nonatomic,strong) NSString *neutral_0;
@property (nonatomic,assign) CGFloat load_voltage;
@property (nonatomic,assign) CGFloat sload_power;
@property (nonatomic,strong) MHDataDeviceTimer *countDownTimer;
@property (nonatomic,assign) CGFloat pw_day;
@property (nonatomic,assign) CGFloat pw_month;

- (NSString *)eventNameOfStatusChange;
- (NSArray *)getLogoNames;
- (NSString *)getLogoName:(NSString *)name;

#pragma mark - 根据countdown timer 计算倒计时的时间长度－－ timer是按照时间执行的，倒计时显示距离现在的时间差
- (void)fetchCountDownTime:(void (^)(NSInteger hour, NSInteger minute))countDownTimer;

#pragma mark - plug load all data
- (void)loadStatus;

#pragma mark - plug data
- (void)fetchPlugDataWithSuccess:(SucceedBlock)success failure:(FailedBlock)failure;

- (void)savePlugData:(id)value andGroupType:(NSString *)groupType;

- (id)restorePlugData:(NSString *)groupType;

#pragma mark - plug RPC
- (void)getPropertyWithSuccess:(SucceedBlock)success andFailure:(FailedBlock)failure;

- (void)switchPlugWithToggle:(NSString *)toggle Success:(SucceedBlock)success andFailure:(FailedBlock)failure;

- (void)getTimerListWithID:(NSString *)identify Success:(SucceedBlock)success failure:(FailedBlock)failure;

#pragma mark - plug protect
- (void)setPlugProtect:(NSString *)methodName
             withValue:(NSInteger)value
            andSuccess:(SucceedBlock)success
               failure:(FailedBlock)failure ;

- (void)fetchPlugProtectStatusWithSuccess:(SucceedBlock)success failure:(FailedBlock)failure;

@end
