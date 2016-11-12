//
//  MHGatewayNeutralLogoSelectedViewController.h
//  MiHome
//
//  Created by guhao on 3/17/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceGatewayBaseService.h"

@interface MHGatewayNeutralLogoSelectedViewController : MHLuViewController

- (instancetype)initWithDevice:(MHDevice *)device;
@property (nonatomic, strong) MHDeviceGatewayBaseService *service0;
@property (nonatomic, strong) MHDeviceGatewayBaseService *service1;

@end
