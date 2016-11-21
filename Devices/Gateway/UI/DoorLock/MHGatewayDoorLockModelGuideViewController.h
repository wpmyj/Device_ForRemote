//
//  MHGatewayDoorLockModelGuideViewController.h
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/7.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHLuViewController.h"
#import "MHDeviceGatewaySensorDoorLock.h"
@class MHGatewayDoorLockModelGuideViewController;
@protocol MHGatewayDoorLockModelGuideViewControllerDelegate <NSObject>

- (void)doorLockModelGuideViewController:(MHGatewayDoorLockModelGuideViewController *)doorLockModelGuideViewController
                       handlerWithResult:(BOOL)result;

@end

@interface MHGatewayDoorLockModelGuideViewController : MHLuViewController
@property (nonatomic, strong) MHDeviceGatewaySensorDoorLock *sensorDoorLock;
@property (nonatomic, weak) id<MHGatewayDoorLockModelGuideViewControllerDelegate> delegate;
@end
