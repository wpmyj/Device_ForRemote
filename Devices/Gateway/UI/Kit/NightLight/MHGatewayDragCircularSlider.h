//
//  MHGatewayDragCircularSlider.h
//  MiHome
//
//  Created by guhao on 2/18/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHDeviceGateway.h"
#import "MHGatewayNightLightDefine.h"



typedef void (^MHGatewayDragCircularSliderCallback)(NSInteger lastRGB);
typedef void (^continueTrackingCallback)(NSInteger currentRGB);


@interface MHGatewayDragCircularSlider : UIControl

@property (nonatomic) float currentValue;
@property (nonatomic) int lineWidth;
@property (nonatomic, strong) UIColor *unfilledColor;

@property (nonatomic) int initialAngleInt;//初始值
@property (nonatomic, strong) NSString *countdownImageName;
@property (nonatomic, copy) MHGatewayDragCircularSliderCallback lastTouchCallback; //最终触摸的RGB,设置给网关
@property (nonatomic, copy) continueTrackingCallback currentRGBCallBack;//当前滑块的所指向的RGB
@property (nonatomic,assign) int callBackResult; // 0 ~ 270度的范围 返回值


-(id)initWithFrame:(CGRect)frame sensor:(MHDeviceGateway *)gateway;

@end
