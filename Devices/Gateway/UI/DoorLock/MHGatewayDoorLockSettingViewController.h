//
//  MHGatewayDoorLockSettingViewController.h
//  MiHome
//
//  Created by LM21Mac002 on 16/10/15.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHGatewayBaseSettingViewController.h"
#import "MHDeviceGatewaySensorDoorLock.h"
@class MHGatewayDoorLockSettingViewController;
@protocol MHGatewayDoorLockSettingViewControllerDelegate <NSObject>

- (void)changeDeviceName:(MHGatewayDoorLockSettingViewController *)doorLockSettingViewController;
- (void)FAQ:(MHGatewayDoorLockSettingViewController *)doorLockSettingViewController;
- (void)feedback:(MHGatewayDoorLockSettingViewController *)doorLockSettingViewController;
@end

@interface MHGatewayDoorLockSettingViewController : MHGatewayBaseSettingViewController
@property (strong, nonatomic) MHDeviceGatewaySensorDoorLock *sensorDoorLock;
@property (weak, nonatomic) id<MHGatewayDoorLockSettingViewControllerDelegate> delegate;
@end
