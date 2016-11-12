//
//  MHDevicePlugMini.h
//  MiHome
//
//  Created by hanyunhui on 15/10/20.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//
#import "MHDeviceWlan.h"

#define DeviceModelPlugMini @"chuangmi.plug.m1"  //mini

@interface MHDevicePlugMini : MHDeviceWlan

@property (nonatomic, assign) NSInteger temperature; // 插座的温度
@property (nonatomic, retain) MHDataDeviceTimer* oldPowerTimer; //目前的定时有2套，旧的是Android版本所使用的，新的Ios在用。

/**
 *  设备控制
 */
- (void)bind;

@end