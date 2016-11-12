//
//  MHDeviceGatewaySensorCube.h
//  MiHome
//
//  Created by Lynn on 9/9/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewayBase.h"

typedef enum{
    Cube_flip90,
    Cube_flip180,
    Cube_move,
    Cube_tap_twice,
    Cube_shake_air,
    Cube_rotate,
}CubeEvent;

//魔方传感器
@interface MHDeviceGatewaySensorCube : MHDeviceGatewayBase

- (NSString* )eventNameOfStatusChange:(CubeEvent)status;

@end
