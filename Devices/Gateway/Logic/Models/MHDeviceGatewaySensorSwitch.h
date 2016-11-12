//
//  MHDeviceGatewaySensorSwitch.h
//  MiHome
//
//  Created by Woody on 15/4/2.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewayBase.h"

//无线开关
@interface MHDeviceGatewaySensorSwitch : MHDeviceGatewayBase

//是否设置了"按键一次"的门铃
- (BOOL)isSetDoorBell;

//是否设置了"按键两次"的门铃
- (BOOL)isSetDoorBellForDoubleClick;

//检查switch是否设置了冲突绑定
-(BOOL)bindSwitchAlarmAndDoorbellConfictSearch;
-(BOOL)bindAlarmCheck;
-(BOOL)bindDoorBellCheck;
@end
