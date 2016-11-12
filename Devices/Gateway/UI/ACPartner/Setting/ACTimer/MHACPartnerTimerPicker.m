//
//  MHACPartnerTimerPicker.m
//  MiHome
//
//  Created by ayanami on 16/6/27.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerTimerPicker.h"

@interface MHACPartnerTimerPicker ()


@end

@implementation MHACPartnerTimerPicker {
    UIButton *                       _cancelButton;
    UIButton *                       _retryButton;
}
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
    
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancelButton.frame = CGRectMake(30, WIN_HEIGHT - 56, (WIN_WIDTH - 60) / 2, 46);
//    [_cancelButton setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.about.migration.cancel",@"plugin_gateway","")
//                   forState:UIControlStateNormal];

    [_cancelButton addTarget:self action:@selector(clickClear:) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_cancelButton setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:UIControlStateNormal];
    [_cancelButton setBackgroundImage:[UIImage imageNamed:@"acpartner_btn_left"] forState:UIControlStateNormal];
    [_cancelButton setTitle:NSLocalizedStringFromTable(@"sharemsg:alert.clear.confirm",@"plugin_gateway","清除")
                   forState:UIControlStateNormal];
    
//    [_retryButton setImage:[UIImage imageNamed:@"acpartner_btn_left"] forState:UIControlStateNormal];

    [self addSubview:_cancelButton];
    
    _retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _retryButton.frame = CGRectMake(30 + (WIN_WIDTH - 60) / 2, WIN_HEIGHT - 56, (WIN_WIDTH - 60) / 2, 46);
//    [_retryButton setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.about.migration.retry",@"plugin_gateway","")
//                  forState:UIControlStateNormal];

    [_retryButton addTarget:self action:@selector(clickOk:) forControlEvents:UIControlEventTouchUpInside];
    _retryButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_retryButton setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:UIControlStateNormal];
    [_retryButton setBackgroundImage:[UIImage imageNamed:@"acpartner_btn_right"] forState:UIControlStateNormal];
    [_retryButton setTitle:NSLocalizedStringFromTable(@"Ok",@"plugin_gateway","确定")
                  forState:UIControlStateNormal];
//    [_retryButton setImage:[UIImage imageNamed:@"acpartner_btn_right"] forState:UIControlStateNormal];
    [self addSubview:_retryButton];
}

- (void)clickOk:(id)sender {
    if (self.onOk) {
        self.onOk();
    }
    [self hideView];
}

- (void)clickClear:(id)sender {
    if (self.onClear) {
        self.onClear();
    }
    [self hideView];
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
