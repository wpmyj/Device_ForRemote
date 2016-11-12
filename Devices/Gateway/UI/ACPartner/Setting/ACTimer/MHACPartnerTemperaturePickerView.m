//
//  MHACPartnerTemperaturePickerView.m
//  MiHome
//
//  Created by ayanami on 16/5/19.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerTemperaturePickerView.h"
#import "IRConstants.h"

#define kDuration 0.3
#define PanelHeight 260.f       //操作面板高度
#define TopAreaHeight 44.f



@interface MHACPartnerTemperaturePickerView ()

@property (nonatomic, retain) NSMutableArray *temperatureArray;

@end

@implementation MHACPartnerTemperaturePickerView
{
    NSString*   _title;
    UIView*     _panel;
    UILabel*    _temperatureLabel;
    UILabel*    _celsiusLabel;
    
    MHACTemperaturePicker _temperaturePicked;
}
- (instancetype)initWithTitle:(NSString *)title temperaturePicked:(MHACTemperaturePicker)temperaturePicked
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [self buildTemperatureArray];
        _title = [title copy];
        _temperaturePicked = [temperaturePicked copy];
        
        [self buildSubviews];
    }
    return self;
}

- (void)buildTemperatureArray {
    self.temperatureArray = [NSMutableArray new];
    for (int i = TEMPERATUREMIN; i < TEMPERATUREMAX + 1; i++) {
        [self.temperatureArray addObject:@(i)];
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
    _celsiusLabel.text = @"℃";
    _celsiusLabel.font = [UIFont boldSystemFontOfSize:16];
    _celsiusLabel.textColor = [MHColorUtils colorWithRGB:0x3fb57d];
    _celsiusLabel.textAlignment = NSTextAlignmentLeft;
    [self.picker addSubview:_celsiusLabel];
//
    _temperatureLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, 80, 30)];
    _temperatureLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.timer.temperature",@"plugin_gateway","温度");
    _temperatureLabel.font = [UIFont boldSystemFontOfSize:20];
    _temperatureLabel.textColor = [MHColorUtils colorWithRGB:0x3fb57d];
    _temperatureLabel.textAlignment = NSTextAlignmentLeft;
    [self.picker addSubview:_temperatureLabel];
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



- (void)setTemperature:(NSUInteger)temperature {
    _temperature = temperature;
    NSInteger temperatureRow = TimerPickerInitPosition * self.temperatureArray.count + temperature - TEMPERATUREMIN;
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
    return self.temperatureArray.count * TimerPickerMultiply;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* label = [[UILabel alloc] init];
    label.text = [NSString stringWithFormat:@"%@", self.temperatureArray[row % self.temperatureArray.count]];
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
    
     if (_temperaturePicked) {
        _temperaturePicked([self.picker selectedRowInComponent:0] % self.temperatureArray.count + TEMPERATUREMIN);
    }
}


@end
