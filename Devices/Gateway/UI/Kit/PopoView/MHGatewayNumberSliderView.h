//
//  MHGatewayNumberSliderView.h
//  MiHome
//
//  Created by guhao on 2/24/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHLumiPopoverSlider.h"

@interface MHGatewayNumberSliderView : UIView

@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIFont  *titleFont;
@property (nonatomic, assign) float MinimumValue;
@property (nonatomic, assign) float maximumValue;
@property (nonatomic, assign) float sliderValue;
@property (nonatomic, copy) NSString *plusImageName;
@property (nonatomic, copy) NSString *minusImageName;
@property (nonatomic,strong) void (^numberControlCallBack)(NSInteger value, NSString *type);
- (void)configureConstruct:(NSInteger)value;

@end
