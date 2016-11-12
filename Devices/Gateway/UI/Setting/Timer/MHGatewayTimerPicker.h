//
//  MHGatewayTimerPicker.h
//  MiHome
//
//  Created by guhao on 3/29/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHTimerPicker.h"
//实现UIPickerView循环用
#define TimerPickerMultiply         200
#define TimerPickerInitPosition     100

@interface MHGatewayTimerPicker : MHTimerPicker

@property (nonatomic, strong) UILabel *pickerTitle;

@end
