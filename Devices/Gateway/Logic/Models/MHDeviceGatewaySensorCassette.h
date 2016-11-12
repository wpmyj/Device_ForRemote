//
//  MHDeviceGatewaySensorCassette.h
//  MiHome
//
//  Created by guhao on 16/1/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewaySensorPlug.h"

#define WallPlugTimerIdentify           @"wall_plug.timer.name"
#define WallPlugCountDownIdentify       @"lumi_gateway_wall_plug_countdown"

//墙壁插座

@interface MHDeviceGatewaySensorCassette : MHDeviceGatewaySensorPlug
- (void)setCountDownTimer:(MHDataDeviceTimer *)timer success:(void(^)(void))success failure:(void(^)(void))failure;
- (MHDataDeviceTimer *)fetchCountDownTimer;
@end
