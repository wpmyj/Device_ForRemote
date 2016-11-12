//
//  XBCircularSlider.h
//  MiHome
//
//  Created by Lynn on 8/3/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>

/** Parameters **/
#define XB_SLIDER_SIZE [UIScreen mainScreen].bounds.size.width                          //The width and the heigth of the slider
#define XB_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define XB_BACKGROUND_WIDTH 1.5                     //The width of the dark background
#define XB_LINE_WIDTH 1.5                            //The width of the active area (the gradient) and the width of the handle

#define XB_FONTFAMILY @"Futura-CondensedExtraBold"  //The font family of the textfield font
#define XB_HANDSIZE 20

#define XB_RADIUSOFFSIZE 50./375.*XB_SLIDER_SIZE

@class XBCircularSlider;
typedef void(^XBCircularSliderCallbackBlock)(int value);


@interface XBCircularSlider : UIControl
@property (nonatomic,assign) int initialValue;  //初始值
@property (nonatomic,assign) int callBackResult; // 0 ~ 270度的范围 返回值
@property (nonatomic,copy) XBCircularSliderCallbackBlock callbackBlock; //最终触摸的值，修改返回调用方法
@end
