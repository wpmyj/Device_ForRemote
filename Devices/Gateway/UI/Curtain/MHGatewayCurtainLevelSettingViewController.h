//
//  MHGatewayCurtainLevelSettingViewController.h
//  MiHome
//
//  Created by guhao on 16/1/11.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLuDeviceSettingViewController.h"
#import "MHDeviceGatewaySensorCurtain.h"

@interface MHGatewayCurtainLevelSettingViewController : MHLuDeviceSettingViewController

@property (nonatomic,strong) MHDeviceGatewaySensorCurtain *curtain;

- (id)initWithDevice:(MHDeviceGatewaySensorCurtain *)deviceCurtain;

@end
