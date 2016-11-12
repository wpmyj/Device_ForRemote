//
//  MHGatewayNightLightControlView.h
//  MiHome
//
//  Created by guhao on 2/18/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHDeviceGateway.h"


@interface MHGatewayNightLightControlView : UIView

#pragma mark - 更新彩灯状态
- (void)updateNightLightStatus;

- (instancetype)initWithFrame:(CGRect)frame sensor:(MHDeviceGateway *)gateway;

@end
