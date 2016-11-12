//
//  MHLumiCameraGatewaySettingViewController.h
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/2.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHDeviceGateway.h"
#import "MHLuDeviceSettingViewController.h"

@interface MHLumiCameraGatewaySettingViewController : MHLuDeviceSettingViewController
-(id)initWithDevice:(MHDeviceGateway *)gateway;
@end
