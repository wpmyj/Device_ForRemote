//
//  MHGatewayDurationSettingViewController.h
//  MiHome
//
//  Created by guhao on 4/11/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLuDeviceSettingViewController.h"
#import "MHDeviceGateway.h"
typedef void (^selectTimeCallBack)(NSNumber *time);
@interface MHGatewayDurationSettingViewController : MHLuDeviceSettingViewController

@property (nonatomic, copy) selectTimeCallBack selectTime;
- (id)initWithGatewayDevice:(MHDeviceGateway *)gateway identifier:(NSString *)identifier currentTime:(NSInteger)currentTime;

@end
