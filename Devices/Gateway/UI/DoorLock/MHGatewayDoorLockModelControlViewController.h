//
//  MHGatewayDoorLockModelControlViewController.h
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/7.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHGatewayBaseSettingViewController.h"
#import "MHDeviceGatewaySensorDoorLock.h"
@class MHGatewayDoorLockModelControlViewController;
@protocol MHGatewayDoorLockModelControlViewControllerDelegate <NSObject>

- (void)doorLockModelControlViewController:(MHGatewayDoorLockModelControlViewController *)doorLockModelControlViewController
                          didSelectedModel:(MHDeviceGatewaySensorDoorLockModel)model
                               commitOrNor:(BOOL)commitOrNor;

@end

@interface MHGatewayDoorLockModelControlViewController : MHGatewayBaseSettingViewController
@property (nonatomic, strong) MHDeviceGatewaySensorDoorLock *sensorDoorLock;
@property (nonatomic, strong) id<MHGatewayDoorLockModelControlViewControllerDelegate> delegate;
@end
