//
//  MHGatewayDoorLockViewController.h
//  MiHome
//
//  Created by LM21Mac002 on 16/10/15.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHGatewaySensorViewController.h"
#import "MHDeviceGatewaySensorDoorLock.h"

@interface MHGatewayDoorLockViewController : MHGatewaySensorViewController
@property (strong, nonatomic) MHDeviceGatewaySensorDoorLock *sensorDoorLock;
@end
