//
//  MHGatewayNightLogicView.h
//  MiHome
//
//  Created by guhao on 2/29/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHDeviceGateway.h"
#import "MHGatewayNightLightDefine.h"
#import "MHGatewayOfflineManager.h"

typedef void (^MHGatewayNightLogicViewCallback)(NSInteger brightness);
@interface MHGatewayNightLogicView : UIView

@property (nonatomic, strong) UIButton *nightControlBtn;
@property (nonatomic, strong) UIButton *brightnessBtn;
@property (nonatomic, strong) UIView *colorView;
@property (nonatomic, strong) UIButton *logoBtn;
@property (nonatomic, assign) NSInteger oldRGB;
@property (nonatomic, assign) NSInteger oldLumin;
@property (nonatomic, assign) NSInteger newRGB;
@property (nonatomic, assign) NSInteger newLumin;
@property (nonatomic, copy) MHGatewayNightLogicViewCallback brightnessCallback;

- (void)setIntegerColor:(NSNumber *)rgbValue lumin:(NSNumber *)lumin;
- (void)controlNightIsOn:(BOOL)isOn;
-(id)initWithFrame:(CGRect)frame sensor:(MHDeviceGateway *)gateway;

@end
