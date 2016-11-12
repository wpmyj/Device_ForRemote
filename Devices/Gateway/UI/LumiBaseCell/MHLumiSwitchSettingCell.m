//
//  MHLumiSwitchSettingCell.m
//  MiHome
//
//  Created by guhao on 16/5/14.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiSwitchSettingCell.h"

@implementation MHLumiSwitchSettingCell
{
    UISwitch *_switchBtn;
}

- (void)buildSubViews
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [super buildSubViews];
    _switchBtn = [[UISwitch alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_switchBtn];
    [_switchBtn addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [self.detailTextLabel setTextColor:[MHColorUtils colorWithRGB:0x888888]];
}



- (void)layoutSubviews
{
    [super layoutSubviews];
    [_switchBtn setFrame:CGRectMake(0, 0, 50.0f, 25.0f)];
    [_switchBtn setCenter:CGPointMake(self.bounds.size.width - 25.0f - _switchBtn.bounds.size.width / 2, self.bounds.size.height / 2)];
    
    CGSize labelSize = [self.detailTextLabel.text boundingRectWithSize:CGSizeMake(_switchBtn.frame.origin.x - self.detailTextLabel.frame.origin.x, 100) options:(NSStringDrawingOptions)(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName: [self.detailTextLabel font]} context:nil].size;
    
    [self.detailTextLabel setFrame:CGRectMake(self.detailTextLabel.frame.origin.x, self.detailTextLabel.frame.origin.y, labelSize.width, labelSize.height)];
    self.detailTextLabel.numberOfLines = 0;
    self.detailTextLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
    CGFloat height = self.detailTextLabel.frame.size.height + self.textLabel.frame.size.height + 4.0f;
    CGFloat originY = (self.bounds.size.height - height) / 2.0f;
    CGRect titleRect = self.textLabel.frame;
    titleRect.origin.y = originY;
    [self.textLabel setFrame:titleRect];
    originY = CGRectGetMaxY(titleRect) + 4.0f;
    CGRect detailRect = self.detailTextLabel.frame;
    detailRect.origin.y = originY;
    detailRect.size.width = WIN_WIDTH - 100;
    self.detailTextLabel.frame = detailRect;
}

- (void)fillWithItem:(MHDeviceSettingItem *)item
{
    [super fillWithItem:item];
    [_switchBtn setEnabled:self.lumiItem.enabled];
    [_switchBtn setOn:self.lumiItem.isOn];
}

- (void)onSwitch:(id)sender
{
    if (!self.self.lumiItem.lumiCallbackBlock)
    {
        return;
    }
    [_switchBtn setEnabled:NO];
    BOOL isOn = _switchBtn.isOn;
    self.lumiItem.isOn = isOn;
    if (isOn)
    {
        self.lumiItem.lumiCallbackBlock(self);
    }
    else
    {
        self.lumiItem.lumiCallbackBlock(self);
    }
    
}

- (void)finish
{
    [super finish];
    [_switchBtn setEnabled:YES];
}


+ (CGFloat)heightWithItem:(MHDeviceSettingItem *)item width:(CGFloat)width
{
    CGSize labelSize = [item.comment boundingRectWithSize:CGSizeMake( width - 15.0f - 75.0f, 100) options:(NSStringDrawingOptions)(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.0f]} context:nil].size;
    
    NSInteger line = labelSize.height / 14.0f;
    return 60.0f + ((line > 1) ? (labelSize.height - 10.0f) : 0);
}

@end
