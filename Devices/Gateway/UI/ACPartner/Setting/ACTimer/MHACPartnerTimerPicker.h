//
//  MHACPartnerTimerPicker.h
//  MiHome
//
//  Created by ayanami on 16/6/27.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHTimerPicker.h"
//实现UIPickerView循环用
#define TimerPickerMultiply         200
#define TimerPickerInitPosition     100

@interface MHACPartnerTimerPicker : MHTimerPicker

@property (nonatomic, strong) UILabel *pickerTitle;
@property (nonatomic, copy) void(^onClear)(void);
@property (nonatomic, copy) void(^onOk)(void);

@end
