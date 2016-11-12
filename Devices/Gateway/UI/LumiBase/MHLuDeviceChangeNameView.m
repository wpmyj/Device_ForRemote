//
//  MHLuDeviceChangeNameView.m
//  MiHome
//
//  Created by guhao on 3/11/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLuDeviceChangeNameView.h"
#import "MHTextField.h"


@interface MHLuDeviceChangeNameView ()<UITextFieldDelegate>

@end

@implementation MHLuDeviceChangeNameView {
    UILabel*        _labelTitle;
    MHTextField*    _deviceNameInput;
    UIButton*       _btnCancel;
    UIButton*       _btnOk;
}

- (void)setLabelTitleText:(NSString *)labelTitleText {
    _labelTitleText = labelTitleText;
    _labelTitle.text = labelTitleText;
}

- (void)buildSubViews {
    [super buildSubViews];
    
    [self.panelView.layer setCornerRadius:8.0];
    
    _labelTitle = [[UILabel alloc] init];
    _labelTitle.translatesAutoresizingMaskIntoConstraints = NO;
    _labelTitle.font = [UIFont systemFontOfSize:18];
    _labelTitle.textColor = [MHColorUtils colorWithRGB:0x333333];
    _labelTitle.alpha = 0.7f;
    _labelTitle.textAlignment = NSTextAlignmentCenter;
    _labelTitle.text = NSLocalizedStringFromTable(@"mydevice.changename.title", @"plugin_gateway","修改设备名称");
    [self.panelView addSubview:_labelTitle];
    
    _deviceNameInput = [[MHTextField alloc] init];
    _deviceNameInput.translatesAutoresizingMaskIntoConstraints = NO;
    _deviceNameInput.textColor = [MHColorUtils colorWithRGB:0x333333];
    _deviceNameInput.font = [UIFont systemFontOfSize:19];
    _deviceNameInput.editingLeftDx = 15;
    _deviceNameInput.editingRightDx = 20;
    _deviceNameInput.clearButtonMode = UITextFieldViewModeWhileEditing;
    _deviceNameInput.delegate = self;
    _deviceNameInput.backgroundColor = [MHColorUtils colorWithRGB:0xffffff];
    _deviceNameInput.borderStyle = UITextBorderStyleRoundedRect;
    _deviceNameInput.layer.borderColor = [[MHColorUtils colorWithRGB:0xBCBCBC] CGColor];
    [self.panelView addSubview:_deviceNameInput];
    
    _btnCancel = [[UIButton alloc] init];
    _btnCancel.translatesAutoresizingMaskIntoConstraints = NO;
    [_btnCancel setTitle:NSLocalizedStringFromTable(@"Cancel", @"plugin_gateway","取消") forState:(UIControlStateNormal)];
    [_btnCancel setTitleColor:[MHColorUtils colorWithRGB:0x666666] forState:(UIControlStateNormal)];
    [_btnCancel setBackgroundColor:[UIColor whiteColor]];
    [_btnCancel.layer setCornerRadius:5.0];
    _btnCancel.layer.borderColor = [MHColorUtils colorWithRGB:0xcccccc].CGColor;
    _btnCancel.layer.borderWidth = 0.5f;
    _btnCancel.titleLabel.font = [UIFont systemFontOfSize:18];
    [_btnCancel addTarget:self action:@selector(onCancel:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.panelView addSubview:_btnCancel];
    
    _btnOk = [[UIButton alloc] init];
    _btnOk.translatesAutoresizingMaskIntoConstraints = NO;
    [_btnOk setTitle:NSLocalizedStringFromTable(@"Ok", @"plugin_gateway","确定") forState:(UIControlStateNormal)];
    [_btnOk setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    
    [_btnOk.layer setCornerRadius:5.0];
    _btnOk.layer.borderColor = [MHColorUtils colorWithRGB:0xcccccc].CGColor;
    _btnOk.layer.borderWidth = 0.5f;
    _btnOk.titleLabel.font = [UIFont systemFontOfSize:18];
    [_btnOk addTarget:self action:@selector(onOk:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.panelView addSubview:_btnOk];
    
    [_deviceNameInput becomeFirstResponder];
}

- (void)buildConstraints {
    CGFloat ratio = self.panelView.frame.size.width / 375.0f;
    CGFloat btnWidth = 153 * ratio;
    NSDictionary* metrics = @{@"vleadSpacing" : @(21 * ratio),
                              @"vSpacing1" : @(19.5f * ratio),
                              @"vTrailSpacing" : @(33 * ratio),
                              @"hLeadSpacing" : @(25.5),
                              @"hLeadSpacing2" : @(25.5),
                              @"nameHeight" : @(45 * ratio),
                              @"btnWidth" : @(btnWidth)};
    NSDictionary* views = @{@"title" : _labelTitle,
                            @"name" : _deviceNameInput,
                            @"cancel" : _btnCancel,
                            @"ok" : _btnOk};
    
    NSLayoutConstraint* titleCenterX = [NSLayoutConstraint constraintWithItem:_labelTitle
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.panelView
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1.f constant:0.f];
    NSArray* titleNameV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vleadSpacing-[title]-vSpacing1-[name(nameHeight)]"
                                                                  options:0
                                                                  metrics:metrics
                                                                    views:views];
    NSArray* nameH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hLeadSpacing-[name]-hLeadSpacing-|"
                                                             options:0
                                                             metrics:metrics
                                                               views:views];
    NSArray* cancelH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hLeadSpacing2-[cancel(btnWidth)]"
                                                               options:0
                                                               metrics:metrics
                                                                 views:views];
    NSArray* cancelV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[cancel]-vTrailSpacing-|"
                                                               options:0
                                                               metrics:metrics
                                                                 views:views];
    NSArray* okH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[ok(btnWidth)]-hLeadSpacing2-|"
                                                           options:NSLayoutFormatAlignAllBottom
                                                           metrics:metrics
                                                             views:views];
    NSArray* okV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[ok]-vTrailSpacing-|"
                                                           options:0
                                                           metrics:metrics
                                                             views:views];
    [self.panelView addConstraint:titleCenterX];
    [self.panelView addConstraints:titleNameV];
    [self.panelView addConstraints:nameH];
    [self.panelView addConstraints:cancelH];
    [self.panelView addConstraints:cancelV];
    [self.panelView addConstraints:okH];
    [self.panelView addConstraints:okV];
}

- (void)setName:(NSString* )name {
    _deviceNameInput.text = name;
    [self enableOk:[name length] > 0];
}

- (void)onCancel:(id)sender {
    if (_cancelBlock) {
        _cancelBlock(nil);
    }
    
    [self hideWithAnimation:NO];
}
- (void)onOk:(id)sender {
    _deviceNameInput.text = [_deviceNameInput.text stringByReplacingOccurrencesOfString:@"&" withString:@""];
    if ([_deviceNameInput.text length] > 30 || [_deviceNameInput.text length] == 0) {
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.changename.tips.toolong", @"plugin_gateway","设备名称必须在30个字符之内") duration:1.0 modal:NO];
        return;
    }
    
    if (_okBlock) {
        _okBlock(_deviceNameInput.text);
    }
    
    [self hideWithAnimation:NO];
}

- (void)enableOk:(BOOL)enable {
    _btnOk.enabled = enable;
    if (enable) {
        [_btnOk setBackgroundColor:[MHColorUtils colorWithRGB:0x1dc58a]];
    } else {
        [_btnOk setBackgroundColor:[UIColor lightGrayColor]];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([string isEqualToString:@"/"] || [string containsString:@"/"]) {
         [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.changename.tips.invaildsymbol", @"plugin_gateway","设备名称包含非法字符 /") duration:1.5 modal:NO];
        return NO;
    }
    BOOL enable = ([textField.text length] + [string length] - range.length) > 0;
    [self enableOk:enable];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self enableOk:NO];
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


@end
