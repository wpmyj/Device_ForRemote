//
//  MHGatewayNatgasSensitivityViewController.h
//  MiHome
//
//  Created by ayanami on 16/7/6.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayBaseSettingViewController.h"
#import "MHDeviceGatewaySensorNatgas.h"
#import "MHDeviceGatewaySensorSmoke.h"
@interface MHGatewayNatgasSensitivityViewController : MHGatewayBaseSettingViewController

- (id)initWithDeviceNatgas:(MHDeviceGatewaySensorNatgas *)deviceNatgas;
@end
