//
//  MHGatewayDoorBellSettingViewController.h
//  MiHome
//
//  Created by Lynn on 10/16/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayBaseSettingViewController.h"

@interface MHGatewayDoorBellSettingViewController : MHGatewayBaseSettingViewController

@property (nonatomic,strong) MHDeviceGateway* gateway;
- (id)initWithGateway:(MHDeviceGateway*)gateway;

@end
