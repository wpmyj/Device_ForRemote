//
//  MHDeviceGatewaySensorSingleSwitch.h
//  MiHome
//
//  Created by guhao on 15/12/29.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewayBase.h"

typedef enum{
    SingleSwitch_click,
    SingleSwitch_double_click,
}SingleSwitchEvent;

//无线开关贴墙单键
@interface MHDeviceGatewaySensorSingleSwitch : MHDeviceGatewayBase

- (NSString* )eventNameOfStatusChange:(SingleSwitchEvent)status;



@end
