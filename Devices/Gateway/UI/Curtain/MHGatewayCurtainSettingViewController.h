//
//  MHGatewayCurtainSettingViewController.h
//  MiHome
//
//  Created by guhao on 16/5/13.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayBaseSettingViewController.h"
#import "MHDeviceGatewaySensorCurtain.h"

@interface MHGatewayCurtainSettingViewController : MHGatewayBaseSettingViewController

- (id)initWithCurtainDevice:(MHDeviceGatewaySensorCurtain *)curtain curtainController:(UIViewController *)curtainVC;

@end
