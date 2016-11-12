//
//  MHGatewaySettingViewController.h
//  MiHome
//
//  Created by Woody on 15/4/7.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import "MHLuDeviceSettingViewController.h"
#import "MHDeviceGateway.h"

@interface MHGatewaySettingViewController : MHLuDeviceSettingViewController
-(id)initWithDevice:(MHDeviceGateway *)gateway;
@end
