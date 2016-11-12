//
//  MHGatewayAlarmClockCell.m
//  MiHome
//
//  Created by Lynn on 8/11/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayAlarmClockCell.h"

@implementation MHGatewayAlarmClockCell
{
    UISwitch *_switchBtn;
    
    UILabel *_titleLabel;
    UILabel *_detailLabel;
    UILabel *_timeSpaceLabel;
    
    UIView *_seperatorLine;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:[self cellStyle] reuseIdentifier:reuseIdentifier];
    if (self) {
        [self buildSubViews];
    }
    return self;
}

- (UITableViewCellStyle)cellStyle
{
    return UITableViewCellStyleDefault;
}

- (void)buildSubViews
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = self.gatewayItem.caption;
    _detailLabel.font = [UIFont systemFontOfSize:17.f];
    [self.contentView addSubview:_titleLabel];
    
    _detailLabel = [[UILabel alloc] init];
    _detailLabel.text = self.gatewayItem.comment;
    _detailLabel.font = [UIFont systemFontOfSize:14.f];
    _detailLabel.textColor = [MHColorUtils colorWithRGB:0x888888];
    [_detailLabel setTextAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:_detailLabel];
    
    _timeSpaceLabel = [[UILabel alloc] init];
    _timeSpaceLabel.text = self.gatewayItem.identifier;
    _timeSpaceLabel.font = [UIFont systemFontOfSize:12.f];
    _timeSpaceLabel.textColor = [MHColorUtils colorWithRGB:0x888888];
    [_timeSpaceLabel setTextAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:_timeSpaceLabel];
    
    _seperatorLine = [[UIView alloc] init];
    _seperatorLine.backgroundColor = [MHColorUtils colorWithRGB:0xE1E1E1];
    _seperatorLine.alpha = 0.7;
    [self.contentView addSubview:_seperatorLine];

    _switchBtn = [[UISwitch alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_switchBtn];
    [_switchBtn addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventTouchUpInside];
//    [self.detailTextLabel setTextColor:[MHColorUtils colorWithRGB:0x888888]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_titleLabel setFrame:CGRectMake(8, 0, 90, 40)];
    _titleLabel.center = CGPointMake(60, self.contentView.center.y);
    
    [_seperatorLine setFrame:CGRectMake(0, 0, 1, self.contentView.frame.size.height - 14)];
    _seperatorLine.center = CGPointMake(105, self.contentView.center.y);
    
    [_detailLabel setFrame:CGRectMake(_seperatorLine.center.x + 10, 0, 150, 25)];
    _detailLabel.center = CGPointMake(_seperatorLine.center.x + 85, self.contentView.center.y/2.0 + 3);
    
    [_timeSpaceLabel setFrame:CGRectMake(_detailLabel.center.x, 0, 180, 25)];
    _timeSpaceLabel.center = CGPointMake(_seperatorLine.center.x + 100, self.contentView.center.y/2 * 3.0 - 3);
    
    [_switchBtn setFrame:CGRectMake(0, 0, 50.0f, 25.0f)];
    [_switchBtn setCenter:CGPointMake(self.bounds.size.width - 25.0f - _switchBtn.bounds.size.width / 2, self.bounds.size.height / 2)];
}

- (void)fillWithItem:(MHDeviceSettingItem *)item
{
    [super fillWithItem:item];
    [_switchBtn setEnabled:item.enabled];
    [_switchBtn setOn:item.isOn];
    
    
    _titleLabel.text = item.caption;
    _detailLabel.text = item.comment;
    _timeSpaceLabel.text = item.identifier;
    NSLog(@"%@", _titleLabel.text);

}

//- (void)onSwitch:(id)sender
//{
//    if (!self.item.callbackBlock)
//    {
//        return;
//    }
//    [_switchBtn setEnabled:NO];
//    BOOL isOn = _switchBtn.isOn;
//    self.item.isOn = isOn;
//    if (isOn)
//    {
//        self.item.callbackBlock(self);
//    }
//    else
//    {
//        self.item.callbackBlock(self);
//    }
//}
- (void)onSwitch:(id)sender {
    if (_onSwitch) {
        _onSwitch();
    }
    if (self.item.callbackBlock) {
        self.item.callbackBlock(self);
        self.item.isOn = _switchBtn.isOn;
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

- (void)setGatewayItem:(MHGatewaySettingCellItem *)gatewayItem {
    [_switchBtn setEnabled:gatewayItem.enabled];
    [_switchBtn setOn:gatewayItem.isOn];
    _titleLabel.text = gatewayItem.caption;
    _detailLabel.text = gatewayItem.comment;
    _timeSpaceLabel.text = gatewayItem.identifier;
    if (gatewayItem.hasAcIndicator) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (gatewayItem.customUI) {
        CGFloat captionFontSize = [[gatewayItem.accessories valueForKey:SettingAccessoryKey_CaptionFontSize class:[NSNumber class]] floatValue];
        if (captionFontSize > 0) {
            self.textLabel.font = [UIFont systemFontOfSize:captionFontSize];
        }
        UIColor* captionFontColor = [gatewayItem.accessories valueForKey:SettingAccessoryKey_CaptionFontColor class:[UIColor class]];
        if (captionFontColor) {
            [self.textLabel setTextColor:captionFontColor];
        }
        CGFloat commentFontSize = [[gatewayItem.accessories valueForKey:SettingAccessoryKey_CommentFontSize class:[NSNumber class]] floatValue];
        if (commentFontSize > 0) {
            self.detailTextLabel.font = [UIFont systemFontOfSize:commentFontSize];
        }
        UIColor* commentFontColor = [gatewayItem.accessories valueForKey:SettingAccessoryKey_CommentFontColor class:[UIColor class]];
        if (commentFontColor) {
            [self.detailTextLabel setTextColor:commentFontColor];
        }
        
    }
    
}
@end
