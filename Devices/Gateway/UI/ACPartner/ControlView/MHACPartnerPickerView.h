//
//  MHACPartnerPickerView.h
//  MiHome
//
//  Created by ayanami on 16/5/19.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHDeviceAcpartner.h"

typedef enum : NSUInteger {
    MHACPartnerPickerActionPress,
    MHACPartnerPickerActionRelease
} MHACPartnerPickerAction;

@interface MHACPartnerPickerView : UIView<UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) MHDeviceAcpartner *device;
@property (nonatomic, strong) void(^actionCallback)(MHACPartnerPickerAction);
@property (nonatomic, assign) float temperature;
@property (nonatomic, assign) BOOL isBlinking;
@property (nonatomic, assign) BOOL isTracking;
@property (nonatomic, assign) float minTemp;
@property (nonatomic, assign) float maxTemp;
@property (nonatomic, assign) float stepTemp;

- (void)setTempMin:(float)minTemp max:(float)maxTemp step:(float)step;
- (void)fillWithDevice:(MHDeviceAcpartner *)device;
- (void)show;
- (void)hide;

- (void)startBlinking;
- (void)stopBlinking;

- (void)setDisable:(BOOL)disable;
@end
