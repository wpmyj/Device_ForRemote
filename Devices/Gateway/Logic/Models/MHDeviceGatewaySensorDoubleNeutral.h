//
//  MHDeviceGatewaySensorNeutral2.h
//  MiHome
//
//  Created by guhao on 15/12/9.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewayBase.h"

#define Gateway_Event_Neutral_Change       @"neutral_changed"

#define TimerIdentifyNeutral0       @"lumi_neutral0_onOff.timer.name"
#define TimerIdentifyNeutral1       @"lumi_neutral1_onOff.timer.name"

//墙壁开关双键
@interface MHDeviceGatewaySensorDoubleNeutral : MHDeviceGatewayBase

@property (nonatomic, strong) NSString *neutral_0;
@property (nonatomic, strong) NSString *neutral_1;

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


@end
