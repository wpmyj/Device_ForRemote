//
//  MHDeviceGatewaySensorDoubleSwitch.h
//  MiHome
//
//  Created by guhao on 15/12/29.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewayBase.h"

typedef enum{
    DoubleSwitch_click_ch0,
    DoubleSwitch_double_click_ch0,
    DoubleSwitch_click_ch1,
    DoubleSwitch_double_click_ch1,
    DoubleSwitch_both_click,
}DoubleSwitchEvent;

//无线开关贴墙双键
@interface MHDeviceGatewaySensorDoubleSwitch : MHDeviceGatewayBase

- (NSString* )eventNameOfStatusChange:(DoubleSwitchEvent)status;


@end
