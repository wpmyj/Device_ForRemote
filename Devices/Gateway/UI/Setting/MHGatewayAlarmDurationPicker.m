//
//  MHGatewayAlarmDurationPicker.m
//  MiHome
//
//  Created by ayanami on 16/7/7.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayAlarmDurationPicker.h"

#define kDuration 0.3
#define PanelHeight 240.f       //操作面板高度
#define TopAreaHeight 44.f

@interface MHGatewayAlarmDurationPicker ()

@property (nonatomic, retain) NSMutableArray *durationArray;
@property (nonatomic, retain) UIButton *retryButton;
@property (nonatomic, assign) MHLMPickerType pickType;

@end

@implementation MHGatewayAlarmDurationPicker
{
    NSString*   _title;
    UIView*     _panel;
    UILabel*    _temperatureLabel;
    UILabel*    _celsiusLabel;
    
    MHAlarmDurationPicker _durationPicked;
}
- (instancetype)initWithTitle:(NSString *)title durationPicked:(MHAlarmDurationPicker)durationPicked
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [self buildTemperatureArray];
        _title = [title copy];
        _durationPicked = [durationPicked copy];
        
        [self buildSubviews];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title durationPicked:(MHAlarmDurationPicker)durationPicked pickerType:(MHLMPickerType)type
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        _title = [title copy];
        _durationPicked = [durationPicked copy];
        _pickType = type;
        [self buildTemperatureArray];
        [self buildSubviews];
    }
    return self;
}


- (void)buildTemperatureArray {
    self.durationArray = [NSMutableArray new];
   
    switch (self.pickType) {
        case MHLMPickerType_Seconds: {
            for (int i = 0; i < 60; i++) {
                [self.durationArray addObject:@(i)];
            }
            break;
        }
        case MHLMPickerType_Minute: {
            for (int i = 1; i < 60; i++) {
                [self.durationArray addObject:@(i)];
            }
            break;
        }
        default:
            break;
    }
    
}

- (void)buildSubviews {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    
    _panel = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - PanelHeight, CGRectGetWidth(self.bounds), PanelHeight)];
    [self addSubview:_panel];
    _panel.frame = CGRectOffset(_panel.frame, 0, _panel.frame.size.height);
    _panel.backgroundColor = [MHColorUtils colorWithRGB:0xf2f2f2];
    
    UIButton* topArea = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_panel.bounds), 0)];
    [topArea setBackgroundImage:[[UIImage imageNamed:@"bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)] forState:UIControlStateNormal];
    [topArea setTitle:_title forState:UIControlStateNormal];
    [topArea setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //    [_panel addSubview:topArea];
    
    self.picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topArea.frame), CGRectGetWidth(_panel.bounds), PanelHeight-TopAreaHeight)];
    self.picker.dataSource = self;
    self.picker.delegate = self;
    [_panel addSubview:self.picker];
    
    _celsiusLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(_panel.bounds) / 2.0f + 13, CGRectGetHeight(self.picker.bounds) / 2.0f - 10, 50, 10)];
    switch (self.pickType) {
        case MHLMPickerType_Seconds: {
            _celsiusLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.second",@"plugin_gateway","秒");
            break;
        }
        case MHLMPickerType_Minute: {
            _celsiusLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.countdown.minute",@"plugin_gateway","分钟");
            break;
        }
        default:
            break;
    }

    _celsiusLabel.font = [UIFont boldSystemFontOfSize:16];
    _celsiusLabel.textColor = [MHColorUtils colorWithRGB:0x3fb57d];
    _celsiusLabel.textAlignment = NSTextAlignmentLeft;
    [self.picker addSubview:_celsiusLabel];
    //
//    _temperatureLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, 80, 30)];
//    _temperatureLabel.text = ;
//    _temperatureLabel.font = [UIFont boldSystemFontOfSize:20];
//    _temperatureLabel.textColor = [MHColorUtils colorWithRGB:0x3fb57d];
//    _temperatureLabel.textAlignment = NSTextAlignmentLeft;
//    [self.picker addSubview:_temperatureLabel];
    
    _retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _retryButton.frame = CGRectMake(30, WIN_HEIGHT - 56, WIN_WIDTH - 60, 46);
    [_retryButton addTarget:self action:@selector(clickOk:) forControlEvents:UIControlEventTouchUpInside];
    _retryButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_retryButton setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:UIControlStateNormal];
    [_retryButton setTitle:NSLocalizedStringFromTable(@"done",@"plugin_gateway","完成")
                  forState:UIControlStateNormal];
    _retryButton.layer.cornerRadius = 20.0f;
    _retryButton.layer.borderWidth = 0.5f;
    _retryButton.layer.borderColor = [[MHColorUtils colorWithRGB:0xBCBCBC] CGColor];
    [self addSubview:_retryButton];

}

- (void)showInView:(UIView *) view
{
    XM_WS(weakself);
    [view addSubview:self];
    [UIView animateWithDuration:kDuration animations:^{
        XM_SS(strongself, weakself);
        strongself->_panel.frame = CGRectOffset(strongself->_panel.frame, 0, -(strongself->_panel.frame.size.height));
        [self setAlpha:1.0f];
    }];
}

- (void)hideView {
    XM_WS(weakself);
    [UIView animateWithDuration:kDuration animations:^{
        XM_SS(strongself, weakself);
        strongself->_panel.frame = CGRectOffset(strongself->_panel.frame, 0, strongself->_panel.frame.size.height);
        [self setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}




- (void)setDuration:(NSUInteger)duration {
    _duration = duration;
    NSInteger starValue = 0;
    if (self.pickType == MHLMPickerType_Seconds) {
        starValue = 0;
    }
    if (self.pickType == MHLMPickerType_Minute) {
        starValue = 1;
    }
    NSInteger temperatureRow = TimerPickerInitPosition * self.durationArray.count + duration - starValue;
    [self.picker selectRow:temperatureRow inComponent:0 animated:NO];

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(_panel.frame, point)) {
        return;
    }
    
    [self hideView];
}
#pragma mark - PickerView lifecycle
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return (self.durationArray.count) * TimerPickerMultiply;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* label = [[UILabel alloc] init];
    label.text = [NSString stringWithFormat:@"%@", self.durationArray[row % self.durationArray.count]];
    label.font = [UIFont systemFontOfSize:22];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

#pragma mark - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 42;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    UILabel* label = (UILabel* )[pickerView viewForRow:row forComponent:component];
    label.textColor = [MHColorUtils colorWithRGB:0x3fb57d];
    
}

- (void)clickOk:(id)sender {
    if (_durationPicked) {
        NSInteger starValue = 0;
        if (self.pickType == MHLMPickerType_Seconds) {
            starValue = 0;
        }
        if (self.pickType == MHLMPickerType_Minute) {
            starValue = 1;
        }
        _durationPicked([self.picker selectedRowInComponent:0] % self.durationArray.count + starValue);
    }
    [self hideView];
}

@end
