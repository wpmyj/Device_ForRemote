//
//  MHDevicePlug.h
//  MiHome
//
//  Created by Woody on 14/11/14.
//  Copyright (c) 2014年 小米移动软件. All rights reserved.
//

#import "MHDeviceWlan.h"

#define DeviceModelPlug @"chuangmi.plug.v1"

@interface MHDevicePlug : MHDeviceWlan

@property (nonatomic, assign) BOOL isUsbOn;
@property (nonatomic, assign) NSInteger temperature; // 插座的温度
@property (nonatomic, retain) MHDataDeviceTimer* oldPowerTimer; //目前的定时有2套，旧的是Android版本所使用的，新的Ios在用。
                                                                //由于Android还没用上新的定时，ios为了和android兼容，所以保留了旧的定时借口
@property (nonatomic, retain) MHDataDeviceTimer* oldUsbPowerTimer;

@property (nonatomic, retain) NSArray* usbPowerTimerList;   //定时列表,[MHDataDeviceTimer*,...]

/**
 *  设备控制
 */
- (void)bind;

/**
 *  打开/关闭USB插口
 *
 *  @param isOn YES:打开 NO：关闭
 */
- (NSDictionary* )powerOnUsbRequestPayload:(BOOL)on;
- (void)powerOnUsb:(BOOL)isOn success:(void(^)(id))success failure:(void(^)(NSError*))failure;

// set是旧接口，新版定时没有这个接口
- (void)setTimerList:(NSDictionary* )timerList success:(SucceedBlock)success failure:(FailedBlock)failure;
- (void)getTimerListWithSuccess:(SucceedBlock)success failure:(FailedBlock)failure;

- (void)saveTimerList;
- (void)restoreTimerListWithFinish:(void(^)(id))finish;
@end
