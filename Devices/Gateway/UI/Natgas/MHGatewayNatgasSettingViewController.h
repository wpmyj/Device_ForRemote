//
//  MHGatewayNatgasSettingViewController.h
//  MiHome
//
//  Created by ayanami on 16/7/6.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayBaseSettingViewController.h"
#import "MHDeviceGatewaySensorNatgas.h"

@interface MHGatewayNatgasSettingViewController : MHGatewayBaseSettingViewController

- (id)initWithDeviceNatgas:(MHDeviceGatewaySensorNatgas *)deviceNatgas natgasController:(UIViewController *)natgasVC;

@end
