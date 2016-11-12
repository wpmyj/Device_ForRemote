//
//  MHGatewayAddSubDeviceWithoutVideoViewController.h
//  MiHome
//
//  Created by guhao on 3/7/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceGateway.h"

#define DeviceModelMotionClassName        @"MHDeviceGatewaySensorMotion"
#define DeviceModelMagnetClassName        @"MHDeviceGatewaySensorMagnet"
#define DeviceModelSwitchClassName        @"MHDeviceGatewaySensorSwitch"
#define DeviceModelPlugClassName          @"MHDeviceGatewaySensorPlug"
#define DeviceModelCubeClassName          @"MHDeviceGatewaySensorCube"
#define DeviceModelHtClassName            @"MHDeviceGatewaySensorHumiture"
#define DeviceModelCtrlNeutral1ClassName  @"MHDeviceGatewaySensorSingleNeutral"
#define DeviceModelCtrlNeutral2ClassName  @"MHDeviceGatewaySensorDoubleNeutral"
#define DeviceModelCurtainClassName       @"MHDeviceGatewaySensorCurtain"
#define DeviceModel86Switch1ClassName     @"MHDeviceGatewaySensorSingleSwitch"
#define DeviceModel86Switch2ClassName     @"MHDeviceGatewaySensorDoubleSwitch"
#define DeviceModel86PlugClassName        @"MHDeviceGatewaySensorCassette"
#define DeviceModelSmokeClassName         @"MHDeviceGatewaySensorSmoke"
#define DeviceModelNatgasClassName        @"MHDeviceGatewaySensorNatgas"
#define DeviceModelCameraClassName        @"MHDeviceCamera"

typedef enum : NSInteger {
    Motion_Index,//
    Magnet_Index,//
    Switch_Index,//
    Plug_Index,//
    Cube_Index,//
    HT_Index,//
    SingleNeutral_Index,//
    DoubleNeutral_Index,//
    Curtain_Index,//
    SingleSwitch_Index,//
    DoubleSwitch_Index,
    Cassette_Index,
    Smoke_Index,
    Natgas_Index,
} ADD_SUBDEVICE_TYPE;

@interface MHGatewayAddSubDeviceViewController : MHLuViewController
/**
 *  添加子设备
 *
 *  @param gateway     添加子设备的网关
 *  @param deviceModel 子设备的类名
 *
 *  @return 
 */
- (id)initWithGateway:(MHDeviceGateway*)gateway andDeviceModel:(NSString *)deviceModel;
- (id)initWithGateway:(MHDeviceGateway*)gateway deviceType:(ADD_SUBDEVICE_TYPE)type;

@end
