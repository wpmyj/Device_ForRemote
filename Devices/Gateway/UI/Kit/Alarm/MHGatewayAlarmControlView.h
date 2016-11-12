//
//  MHGatewayAlarmControlView.h
//  MiHome
//
//  Created by guhao on 2/16/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHDeviceGateway.h"

@interface MHGatewayAlarmControlView : UIControl

@property (nonatomic, assign) CGFloat padding; //线框圆与内圆间距
@property (nonatomic, strong) UIColor* ringColor; //完成后圆环颜色


@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *statusText;
@property (nonatomic, strong) UILabel *tipText;

- (void)setupGateway;
- (instancetype)initWithFrame:(CGRect)frame sensor:(MHDeviceGateway *)gateway;

@end
