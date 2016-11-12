//
//  MHGatewayNightLightControlView.m
//  MiHome
//
//  Created by guhao on 2/18/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayNightLightControlView.h"
#import "MHGatewayDragCircularSlider.h"
#import "MHGatewayNightCircleColorView.h"
#import "MHGatewayNightLogicView.h"
#import <math.h>
@interface MHGatewayNightLightControlView ()

@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGFloat sliderRadius;
@property (nonatomic, assign) CGFloat circleColorRadius;
@property (nonatomic, assign) CGFloat logicRadius;
@property (nonatomic, assign) CGFloat myWidth;
@property (nonatomic, strong) MHDeviceGateway *gateway;
@property (nonatomic, strong) MHGatewayDragCircularSlider *circleSlider;
@property (nonatomic, strong) MHGatewayNightCircleColorView *circleView;
@property (nonatomic, strong) MHGatewayNightLogicView *nightLogicColor;


@property (nonatomic, assign) int currentAngle;//滑块初始值

@end

@implementation MHGatewayNightLightControlView

- (instancetype)initWithFrame:(CGRect)frame sensor:(MHDeviceGateway *)gateway
{
    self = [super initWithFrame:frame];
    if (self) {
        _gateway = gateway;
        [_gateway restoreStatus];
        _currentAngle = 135;
        _radius = self.bounds.size.height;
        _sliderRadius = self.bounds.size.height - 2 * kSpacing;
        _circleColorRadius = _sliderRadius - kPadding/2;
        _logicRadius = _circleColorRadius - PROGRESS_LINE_WIDTH * 2 - 16;
        CGFloat newR = _circleColorRadius - 2*PROGRESS_LINE_WIDTH;
        CGFloat jiaodu = M_PI/2 - (2*PROGRESS_LINE_WIDTH/newR);
        _logicRadius = sin(jiaodu/2) * newR;
        _myWidth = self.bounds.size.width;
        self.backgroundColor = [UIColor clearColor];
        [self buildSubviews];
//        [self setupLumin:_gateway.night_light_rgb ? _gateway.night_light_rgb : 0x64ff0000];
    }
    return self;
}
- (void)buildSubviews {
    
    
    [self addSubview:self.circleView];
    
    
    XM_WS(weakself);
    self.circleSlider.currentRGBCallBack = ^(NSInteger currentRGB){
        
        [[MHGatewayOfflineManager sharedInstance] showTipsWithGateway:weakself.gateway];
        
        weakself.nightLogicColor.colorView.hidden = NO;
        [weakself.nightLogicColor.logoBtn setImage:[[UIImage imageNamed:@"gateway_night_logo"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        weakself.nightLogicColor.colorView.backgroundColor = [MHColorUtils colorWithRGB:currentRGB];
    };
    self.circleSlider.lastTouchCallback = ^(NSInteger currentRGB){
        
        [[MHGatewayOfflineManager sharedInstance] showTipsWithGateway:weakself.gateway];

        
        [weakself.nightLogicColor setIntegerColor:@(currentRGB) lumin:nil];
        NSInteger rgba = currentRGB + (weakself.nightLogicColor.newLumin << 24);
        NSLog(@"%ld", weakself.nightLogicColor.newLumin);
        [weakself.gateway setProperty:RGB_INDEX value:@(rgba) success:^(id resp) {
            NSLog(@"%@", resp);
        } failure:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    };

    [self addSubview:self.circleSlider];
    [self addSubview:self.nightLogicColor];

//    [self bringSubviewToFront:self.nightLogicColor.brightnessBtn];
//    [self bringSubviewToFront:self.nightLogicColor.nightControlBtn];
    
//    self.nightLogicColor.brightnessCallback = ^(NSInteger brightness){
//        weakself.newLumin = brightness;
//    };

}

//滑块
- (MHGatewayDragCircularSlider *)circleSlider {
    if (_circleSlider == nil) {
        _circleSlider = [[MHGatewayDragCircularSlider alloc] initWithFrame:CGRectMake(0, 3.0/2.0*kSpacing, _myWidth, _sliderRadius) sensor:_gateway];
        _circleSlider.unfilledColor = [MHColorUtils colorWithRGB:0xffffff alpha:0.5];
        _circleSlider.lineWidth = 1.0f;
        _circleSlider.countdownImageName = @"plug_countdown_button_off";
        
    }
    return _circleSlider;
}
//彩虹条
- (MHGatewayNightCircleColorView *)circleView {
    if (_circleView == nil) {
        _circleView = [[MHGatewayNightCircleColorView alloc] initWithFrame:CGRectMake((_myWidth - _circleColorRadius) / 2, 3.0/2.0*kSpacing + kPadding/4, _circleColorRadius, _circleColorRadius)];
    }
    return _circleView;
}
//控制逻辑
-  (MHGatewayNightLogicView *)nightLogicColor {
    if (_nightLogicColor == nil) {
        _nightLogicColor = [[MHGatewayNightLogicView alloc] initWithFrame:CGRectMake((_myWidth - _logicRadius) / 2, 3.0/2.0*kSpacing + kPadding/4, _logicRadius, _circleColorRadius) sensor:_gateway];
    }
    return _nightLogicColor;
}

#pragma mark - 初始值
- (void)setupLumin:(NSInteger)color
{
    int r = color >> 16 & 0xff;
    int g = color >> 8 & 0xff;
    int b = color & 0xff;
//    long a = color >> 24;
    //亮度和rgb的初始值
//    NSLog(@"红%d, 绿%d, 蓝%d, 透明度%ld", r, g, b, a);
//    NSLog(@"取值后的透明度%ld", a);
    //滑块指示的位置
    //rgb值255 分成 90份 一共 45°
    if (r == 255 && g == 255 && b <= 255) {
        //白->黄//b递减
        _currentAngle = kRadian * (255 - b) / 255 + 135;
    }
    else if (r == 255 && g <= 255 && b == 0) {
        //黄->红//g递减
        _currentAngle = kRadian * (255 - g) / 255 + 180;
    }
    else if (r == 255 && g == 0 && b <= 255) {
        //红->粉红//b递增
        _currentAngle = kRadian * b / 255 + 225;
    }
    else if (r <= 255 && g == 0 && b == 255) {
        //粉红到蓝色//r递减
        _currentAngle = kRadian * (255 - r) / 255 + 270;
    }
    else if (r == 0 && g <= 255 && b == 255) {
        //蓝色到天蓝//g递增
        _currentAngle = kRadian * g / 255 + 315;
    }
    else if (r == 0 && g == 255 && b <= 255) {
        //天蓝到绿色//b值递减
        _currentAngle = kRadian * (255 - b) / 255.0f;
    }
    NSLog(@"%d", _currentAngle);
    self.circleSlider.initialAngleInt = _currentAngle;
}

#pragma mark - 更新彩灯状态
- (void)updateNightLightStatus {
    NSLog(@"%ld", _gateway.night_light_rgb);
    //更新滑块位置
    [self setupLumin:_gateway.night_light_rgb ? _gateway.night_light_rgb : 0x64ffffff];
    //彩灯开关状态
//    NSLog(@"%d", (_gateway.rgb & 0xffffff) > 0 ? YES : NO);
    [self.nightLogicColor controlNightIsOn:(_gateway.rgb & 0xffffff) > 0 ? YES : NO];
}



@end
