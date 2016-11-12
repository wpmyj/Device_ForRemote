//
//  MHDeviceGatewaySensorSingleNeutral.h
//  MiHome
//
//  Created by guhao on 15/12/28.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewayBase.h"

#define Gateway_Event_Neutral_Change       @"neutral_changed"
#define LumiNeutral1TimerIdentify       @"lumi_neutral_onOff.timer.name"


//墙壁开关单键
@interface MHDeviceGatewaySensorSingleNeutral : MHDeviceGatewayBase

@property (nonatomic, strong) NSString *neutral_0;

- (NSString *)eventNameOfStatusChange;


#pragma mark - neutral payload
- (void)getPropertyWithSuccess:(SucceedBlock)success andFailure:(FailedBlock)failure;

- (void)switchNeutralWithParam:(NSString *)status
                         Success:(void (^)(id))success
                      andFailure:(void (^)(NSError *))failure;

- (void)getTimerListWithID:(NSString *)identify
                   Success:(SucceedBlock)success
                andFailure:(FailedBlock)failure;

@end
