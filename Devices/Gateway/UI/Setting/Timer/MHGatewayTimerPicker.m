//
//  MHGatewayTimerPicker.m
//  MiHome
//
//  Created by guhao on 3/29/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayTimerPicker.h"

@implementation MHGatewayTimerPicker

- (instancetype)initWithTitle:(NSString *)title timePicked:(MHTimePicked)timePicked
{
    self = [super initWithTitle:title timePicked:timePicked];
    if (self) {
        [self addPickerTitleView];
    }
    return self;
}


- (void)addPickerTitleView {
    CGRect labelRect = CGRectMake(0, self.bounds.size.height - 240.f, self.bounds.size.width, 50.f);
    _pickerTitle = [[UILabel alloc] initWithFrame:labelRect];
    _pickerTitle.textAlignment = NSTextAlignmentCenter;
    _pickerTitle.textColor = [MHColorUtils colorWithRGB:0x3fb57d];
    _pickerTitle.font = [UIFont boldSystemFontOfSize:10];
    _pickerTitle.backgroundColor = [UIColor clearColor];
    _pickerTitle.alpha = 0.0f;
    [self addSubview:_pickerTitle];
}

- (void)showInView:(UIView *)view {
    [super showInView:view];
    XM_WS(weakself);
    [UIView animateWithDuration:0.3 animations:^{
        weakself.pickerTitle.alpha = 1.0f;
    }];
}

- (void)hideView {
    [super hideView];
    XM_WS(weakself);
    [UIView animateWithDuration:0.3 animations:^{
        [weakself.pickerTitle setAlpha:0.0f];
    } completion:^(BOOL finished) {
    }];
    
}


@end
