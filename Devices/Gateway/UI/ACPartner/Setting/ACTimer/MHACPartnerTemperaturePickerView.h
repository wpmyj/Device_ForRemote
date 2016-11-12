//
//  MHACPartnerTemperaturePickerView.h
//  MiHome
//
//  Created by ayanami on 16/5/19.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^MHACTemperaturePicker)(NSUInteger temperature);
//实现UIPickerView循环用
#define TimerPickerMultiply         200
#define TimerPickerInitPosition     100

@interface MHACPartnerTemperaturePickerView : UIView<UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) UIPickerView *picker;
@property (nonatomic, assign) NSUInteger temperature;
- (instancetype)initWithTitle:(NSString *)title temperaturePicked:(MHACTemperaturePicker)temperaturePicked;

- (void)showInView:(UIView *)view;
- (void)hideView;
@end
