//
//  MHGatewayAlarmDurationPicker.h
//  MiHome
//
//  Created by ayanami on 16/7/7.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    MHLMPickerType_Seconds,
    MHLMPickerType_Minute,
} MHLMPickerType;


typedef void (^MHAlarmDurationPicker)(NSUInteger duration);
//实现UIPickerView循环用
#define TimerPickerMultiply         200
#define TimerPickerInitPosition     100
@interface MHGatewayAlarmDurationPicker : UIView<UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) UIPickerView *picker;
@property (nonatomic, assign) NSUInteger duration;
- (instancetype)initWithTitle:(NSString *)title durationPicked:(MHAlarmDurationPicker)durationPicked;

- (instancetype)initWithTitle:(NSString *)title durationPicked:(MHAlarmDurationPicker)durationPicked pickerType:(MHLMPickerType)type;

- (void)showInView:(UIView *)view;
- (void)hideView;
@end
