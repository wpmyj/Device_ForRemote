//
//  MHGatewayDisclaimerView.m
//  MiHome
//
//  Created by Woody on 15/5/25.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import "MHGatewayDisclaimerView.h"
#import "NSString+WeiboStringDrawing.h"

@implementation MHGatewayDisclaimerView {
    UILabel*        _labelTitle;
    
    UILabel*        _labelIRead;
    UILabel*        _labelDiscalimerName;

    UIButton*       _btnCancel;
    UIButton*       _btnOk;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    NSMutableAttributedString *disclaimerName = [[NSMutableAttributedString alloc]initWithString:title];
    NSRange contentRange = {0, [disclaimerName length]};
    [disclaimerName addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
    [disclaimerName addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x25bba4] range:contentRange];
    _labelDiscalimerName.attributedText = disclaimerName;
    [self buildConstraints];
}

- (void)buildSubViews {
    [super buildSubViews];
    
    _labelTitle = [[UILabel alloc] init];
    _labelTitle.translatesAutoresizingMaskIntoConstraints = NO;
    _labelTitle.font = [UIFont boldSystemFontOfSize:16];
    _labelTitle.textColor = [MHColorUtils colorWithRGB:0x333333];
    _labelTitle.textAlignment = NSTextAlignmentCenter;
    _labelTitle.text = NSLocalizedStringFromTable(@"mydevice.gateway.disclaimer.title",@"plugin_gateway", "使用须知");
    [self.panelView addSubview:_labelTitle];

    _labelIRead = [[UILabel alloc] init];
    _labelIRead.translatesAutoresizingMaskIntoConstraints = NO;
    _labelIRead.font = [UIFont systemFontOfSize:14];
    _labelIRead.textColor = [MHColorUtils colorWithRGB:0x666666];
    _labelIRead.textAlignment = NSTextAlignmentRight;
    _labelIRead.text = NSLocalizedStringFromTable(@"mydevice.gateway.disclaimer.iread",@"plugin_gateway", "我已阅读");
    [self.panelView addSubview:_labelIRead];

    _labelDiscalimerName = [[UILabel alloc] init];
    _labelDiscalimerName.lineBreakMode = NSLineBreakByWordWrapping;
    _labelDiscalimerName.numberOfLines = 2;
    _labelDiscalimerName.translatesAutoresizingMaskIntoConstraints = NO;
    _labelDiscalimerName.font = [UIFont systemFontOfSize:14];
    _labelDiscalimerName.textColor = [MHColorUtils colorWithRGB:0x666666];
    _labelDiscalimerName.textAlignment = NSTextAlignmentLeft;
    [self.panelView addSubview:_labelDiscalimerName];
    NSString* disclaimerNameString = [NSString stringWithFormat:@"《%@》", NSLocalizedStringFromTable(@"mydevice.gateway.disclaimer.name",@"plugin_gateway", "《小米智能家庭套装使用须知》")];
    if(_title) disclaimerNameString = _title;
    NSMutableAttributedString *disclaimerName = [[NSMutableAttributedString alloc]initWithString:disclaimerNameString];
    NSRange contentRange = {0, [disclaimerName length]};
    [disclaimerName addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
    [disclaimerName addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x25bba4] range:contentRange];
    _labelDiscalimerName.attributedText = disclaimerName;
    _labelDiscalimerName.userInteractionEnabled = YES;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onShowDisclaimerPage:)];
    [_labelDiscalimerName addGestureRecognizer:tap];
    
    _btnCancel = [[UIButton alloc] init];
    _btnCancel.translatesAutoresizingMaskIntoConstraints = NO;
    [_btnCancel setTitle:NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway", "取消") forState:(UIControlStateNormal)];
    [_btnCancel setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:(UIControlStateNormal)];
    [_btnCancel setBackgroundImage:[[UIImage imageNamed:@"gateway_addsub_continue"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 22, 0, 1)] forState:(UIControlStateNormal)];
    _btnCancel.titleLabel.font = [UIFont systemFontOfSize:14];
    [_btnCancel addTarget:self action:@selector(onCancel:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.panelView addSubview:_btnCancel];
    
    _btnOk = [[UIButton alloc] init];
    _btnOk.translatesAutoresizingMaskIntoConstraints = NO;
    [_btnOk setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.disclaimer.agreeandgo",@"plugin_gateway", "同意并继续") forState:(UIControlStateNormal)];
    [_btnOk setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:(UIControlStateNormal)];
    [_btnOk setBackgroundImage:[[UIImage imageNamed:@"gateway_addsub_done"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 22)] forState:(UIControlStateNormal)];
    _btnOk.titleLabel.font = [UIFont systemFontOfSize:14];
    [_btnOk addTarget:self action:@selector(onOk:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.panelView addSubview:_btnOk];
}

- (void)buildConstraints {
    GLfloat hLeadSpacingIRead = (CGRectGetWidth(self.panelFrame) - [_labelIRead.text singleLineSizeWithFont:_labelIRead.font].width - [_labelDiscalimerName.text singleLineSizeWithFont:_labelDiscalimerName.font].width) / 2.f;
    NSDictionary* metrics = @{@"vleadSpacing" : @20,
                              @"vSpacing" : @20,
                              @"vSpacing2" : @40,
                              @"hLeadSpacing" : @20,
                              @"hLeadSpacingIRead" : @(hLeadSpacingIRead)};
    NSDictionary* views = @{@"title" : _labelTitle,
                            @"iread" : _labelIRead,
                            @"disclaimerName" : _labelDiscalimerName,
                            @"cancel" : _btnCancel,
                            @"ok" : _btnOk};

    
    NSLayoutConstraint* titleCenterX = [NSLayoutConstraint constraintWithItem:_labelTitle attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.panelView attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f];
    NSArray* ireadH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hLeadSpacingIRead-[iread][disclaimerName]" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views];
    NSArray* cancelOkH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hLeadSpacing-[cancel][ok(==cancel)]-hLeadSpacing-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views];
    NSArray* constraintV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vleadSpacing-[title]-vSpacing-[iread]-vSpacing2-[cancel(46)]" options:0 metrics:metrics views:views];
    NSLayoutConstraint* okHeight = [NSLayoutConstraint constraintWithItem:_btnOk attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_btnCancel attribute:NSLayoutAttributeHeight multiplier:1.f constant:0.f];
    [self.panelView addConstraint:titleCenterX];
    [self.panelView addConstraints:ireadH];
    [self.panelView addConstraints:cancelOkH];
    [self.panelView addConstraints:constraintV];
    [self.panelView addConstraint:okHeight];
}

- (void)onCancel:(id)sender {
    if (_cancelBlock) {
        _cancelBlock(nil);
    }
    
    [self hideWithAnimation:NO];
}
- (void)onOk:(id)sender {
    if (_okBlock) {
        _okBlock(sender);
    }
    
    [self hideWithAnimation:NO];
}

- (void)onShowDisclaimerPage:(id)sender {
    if (_onOpenDisclaimerPage) {
        _onOpenDisclaimerPage();
    }
}

@end
