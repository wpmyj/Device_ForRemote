//
//  MHDeviceGatewayBase.h
//  MiHome
//
//  Created by Woody on 15/4/8.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>
#import "MHGatewayLogListManager.h"
#import "MHDevListManager.h"
#import "MHDeviceWlan.h"
#import "MHLumiBindItem.h"
#import "MHDeviceGatewayBaseService.h"
#import "MHLumiHtmlHandleTools.h"
#import "MHPromptKit.h"

#import "MHGatewayInfoViewController.h"


#define DeviceModelGateWay                      @"lumi.gateway.v1"
#define DeviceModelAcpartner                    @"lumi.acpartner.v1"
#define DeviceModelCamera                       @"lumi.camera.v1"
#define DeviceModelgateWaySensorMotionV1        @"lumi.sensor_motion.v1"
#define DeviceModelgateWaySensorMotionV2        @"lumi.sensor_motion.v2"
#define DeviceModelgateWaySensorMagnetV1        @"lumi.sensor_magnet.v1"
#define DeviceModelgateWaySensorMagnetV2        @"lumi.sensor_magnet.v2"
#define DeviceModelgateWaySensorSwitchV1        @"lumi.sensor_switch.v1"
#define DeviceModelgateWaySensorSwitchV2        @"lumi.sensor_switch.v2"
#define DeviceModelgateWaySensorXBulbV1         @"ge.light.mono1"
#define DeviceModelgateWaySensorPlug            @"lumi.plug.v1"
#define DeviceModelgateWaySensorCubeV1          @"lumi.sensor_cube.v1"
#define DeviceModelgateWaySensorLr              @"lumi.sensor_ir.v1"
#define DeviceModelgatewaySensorHt              @"lumi.sensor_ht.v1"
#define DeviceModelgatewaySencorCtrlNeutral1V1  @"lumi.ctrl_neutral1.v1"
#define DeviceModelgatewaySencorCtrlNeutral2V1  @"lumi.ctrl_neutral2.v1"
#define DeviceModelgateWaySensorCurtainV1       @"lumi.curtain.v1"
#define DeviceModelgateWaySensor86Switch1V1     @"lumi.sensor_86sw1.v1"
#define DeviceModelgateWaySensor86Switch2V1     @"lumi.sensor_86sw2.v1"
#define DeviceModelgateWaySensor86PlugV1        @"lumi.ctrl_86plug.v1"
#define DeviceModelgateWaySensorSmokeV1         @"lumi.sensor_smoke.v1"
#define DeviceModelgateWaySensorNatgasV1        @"lumi.sensor_natgas.v1"
#define DeviceModelgateWaySensorDlockV1         @"lumi.sensor_dlock.v1"
#define DeviceModelgateWaySensorCtrlLn1V1       @"lumi.ctrl_ln1.v1"
#define DeviceModelgateWaySensorCtrlLn2V1       @"lumi.ctrl_ln2.v1"


#define SID_Gateway @"lumi.0"

#define Method_Alarm @"alarm"
#define Method_Door_Bell @"door_bell"
#define Method_Welcome @"welcome"
#define Method_ToggleLight @"toggle_light"
#define Method_OpenNightLight @"open_night_light"
#define Method_StopClockMusic @"stop_clock_music"

#define Gateway_Event                             @"event"
#define Gateway_Event_Motion_Motion               @"motion"
#define Gateway_Event_Magnet_Open                 @"open"
#define Gateway_Event_Magnet_Close                @"close"
#define Gateway_Event_Magnet_No_Close             @"no_close"
#define Gateway_Event_Switch_Click                @"click"
#define Gateway_Event_Switch_Double_Click         @"double_click"
#define Gateway_Event_Switch_Long_click_Press     @"long_click_press"

#define Araming_Event_Magnet_Open       @"arming_magnet_open"
#define Araming_Event_Motion_Motion     @"arming_motion_motion"
#define Araming_Event_Switch_Click      @"arming_switch_click"
#define Araming_Event_Cube_Alert        @"arming_cube_alert"


#define Gateway_Event_Cube_flip90           @"flip90"
#define Gateway_Event_Cube_flip180          @"flip180"
#define Gateway_Event_Cube_move             @"move"
#define Gateway_Event_Cube_tap_twice        @"tap_twice"
#define Gateway_Event_Cube_shakeair         @"shake_air"
#define Gateway_Event_Cube_rotate           @"rotate"
#define Gateway_Event_Cube_alert            @"event.lumi.sensor_cube.v1.alert"

#define Gateway_Event_Plug_Change           @"neutral_changed"

#define Gateway_Event_HT_dry_cold           @"dry_cold"
#define Gateway_Event_HT_humid_cold         @"humid_cold"
#define Gateway_Event_HT_cold               @"cold"
#define Gateway_Event_HT_dry                @"dry"
#define Gateway_Event_HT_comfortable        @"comfortable"
#define Gateway_Event_HT_humid              @"humid"
#define Gateway_Event_HT_dry_hot            @"dry_hot"
#define Gateway_Event_HT_humid_hot          @"humid_hot"

#define Gateway_Event_SingleSwitch_click            @"click_ch0"
#define Gateway_Event_SingleSwitch_double_click     @"double_click_ch0"

#define Gateway_Event_DoubleSwitch_click_ch0        @"click_ch0"
#define Gateway_Event_DoubleSwitch_double_click_ch0 @"double_click_ch0"
#define Gateway_Event_DoubleSwitch_click_ch1        @"click_ch1"
#define Gateway_Event_DoubleSwitch_double_click_ch1 @"double_click_ch1"
#define Gateway_Event_DoubleSwitch_both_click       @"both_click"


#define Gateway_Event_Smoke_Alarm            @"alarm"
#define Gateway_Event_Smoke_Self_Check       @"self_check"


#define Gateway_Alarm_Hold_Time_0Sec    0
#define Gateway_Alarm_Hold_Time_5Secs   5
#define Gateway_Alarm_Hold_Time_15Secs  15
#define Gateway_Alarm_Hold_Time_30Secs  30
#define Gateway_Alarm_Hold_Time_60Secs  60

#define Gateway_Night_Light_Hold_Time_1Sec  60
#define Gateway_Night_Light_Hold_Time_2Secs  120
#define Gateway_Night_Light_Hold_Time_5Secs  300
#define Gateway_Night_Light_Hold_Time_10Secs  600

#define Gateway_Sensor_Battery_Min  10

#define Battery_Change_Guide_Motion  @"http://www.tudou.com/programs/view/-11JIuoAAtk/"
#define Battery_Change_Guide_Magnet  @"http://www.tudou.com/programs/view/M0jRhY6YCwE/"
#define Battery_Change_Guide_Switch  @"http://www.tudou.com/programs/view/4FTo_z1KSmM/"


#import "GatewayInfoGetter.h"
#import "GatewayProtocolGetter.h"

@class MHDeviceGateway;

/*
 * 网关Sensor基类
 */
@interface MHDeviceGatewayBase : MHDeviceWlan <GatewayInfoGetter,GatewayProtocolGetter>

@property (nonatomic, assign) NSInteger battery;
@property (nonatomic, strong) NSMutableArray* bindList;
@property (nonatomic, assign) BOOL isBindListGot;
@property (nonatomic, retain) MHGatewayLogListManager* logManager;
@property (nonatomic, strong) NSMutableArray *services;
@property (nonatomic, assign) BOOL isNewAdded;
@property (nonatomic, weak) MHDeviceGateway* parent;

- (NSDictionary* )requestPayloadWithMethodName:(NSString* )method
                                         value:(id)value;
- (NSDictionary* )subDevicePayloadWithMethodName:(NSString* )method
                                        deviceId:(NSString *)did
                                           value:(id)value;

- (void)getBatteryWithSuccess:(SucceedBlock)success
                      failure:(FailedBlock)failure;


#pragma mark - 定时status处理

/**
 *  定时回调处理 0:成功  -1:删除未成功 1:关闭场景未删除成功 2:删除旧设备场景失败 3:设置新设备场景失败
 *
 *  @param timer                  timer description
 *  @param success                success description
 *  @param failure                failure description
 */
- (void)lumiEditTimer:(MHDataDeviceTimer *)timer success:(SucceedBlock)success failure:(FailedBlock)failure;

#pragma mark - 获取属性 子类重写才可用
- (void)getPropertyWithSuccess:(SucceedBlock)success andFailure:(FailedBlock)failure;

#pragma mark - 旧bind接口，在V2网关上
- (void)getBindListWithSuccess:(SucceedBlock)success
                       failure:(FailedBlock)failure;
- (void)addBind:(MHLumiBindItem* )item
        success:(SucceedBlock)success
        failure:(FailedBlock)failure;
- (void)removeBind:(MHLumiBindItem* )item
           success:(SucceedBlock)success
           failure:(FailedBlock)failure;

//是否设置了报警
- (BOOL)isSetAlarming;
- (void)setAlarmingWithSuccess:(SucceedBlock)success
                       failure:(FailedBlock)failure;
- (void)removeAlarmingWithSuccess:(SucceedBlock)success
                          failure:(FailedBlock)failure;

//设置闹钟停止响声
-(BOOL)isSetAlarmClock;
-(void)setStopAlarmClockWithSuccess:(SucceedBlock)success
                            failure:(FailedBlock)failure;
-(void)removeStopAlarmClockWithSuccess:(SucceedBlock)success
                               failure:(FailedBlock)failure;

//是否设置了门铃
- (BOOL)isSetDoorBell;


- (void)saveBindItems;
- (void)restoreBindItems;
//去除model的版本号，进行比较，判断是否是同一个model
- (NSString *)modelCutVersionCode:(NSString *)model;

+ (NSString* )getIconImageName;
+ (NSString* )getBatteryCategory;
+ (NSString* )getBatteryChangeGuideUrl;
+ (NSString* )offlineTips;
+ (NSString* )getFAQUrl;//常见问题


//自动化使用，默认名字
- (NSString*)defaultName;

#pragma mark - service , 一个设备可以提供多个service（比如双路开关，可以提供两个service）
- (void)buildServices;
- (UIImage *)updateMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service;
- (UIImage *)fetchNewCustomIcon:(MHDeviceGatewayBaseService *)service;
- (void)updateServices;

#pragma mark - 获取首页展示图片
- (UIImage *)getMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service ;

#pragma mark - service method
- (void)serviceChangeName:(MHDeviceGatewayBaseService *)service ;

@end
