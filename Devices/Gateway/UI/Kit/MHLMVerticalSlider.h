//
//  MHLMVerticalSlider.h
//  MiHome
//
//  Created by ayanami on 16/7/21.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^sliderCallback)(CGFloat currentValue, CGPoint thumbCenter);

@interface MHLMVerticalSlider : UIView

@property(nonatomic, assign) float value;
@property(nonatomic, assign) float minimumValue;
@property(nonatomic, assign) float maximumValue;

@property(nonatomic,strong) UIColor *minimumTrackTintColor;
@property(nonatomic,strong) UIColor *maximumTrackTintColor;

- (id)initWithFrame:(CGRect)frame thumbImage:(UIImage *)thumb popImage:(UIImage *)image handle:(sliderCallback)handle;
- (void)setSliderValue:(CGFloat)value animated:(BOOL)animated;
@end
