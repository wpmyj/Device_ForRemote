//
//  MHGatewayHelpDetailCell.m
//  MiHome
//
//  Created by Lynn on 8/27/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayHelpDetailCell.h"

@implementation MHGatewayHelpDetailCell
{
    UILabel *   _titleLabel;
    UILabel *   _detailLabel;
}

- (void)buildSubViews{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    [super buildSubViews];
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = self.gatewayItem.caption;
    _titleLabel.font = [UIFont systemFontOfSize:15.f];
    _titleLabel.textColor = [MHColorUtils colorWithRGB:0x333333];
    [_titleLabel setTextAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:_titleLabel];
    
    _detailLabel = [[UILabel alloc] init];
    _detailLabel.text = self.gatewayItem.comment;
    _detailLabel.font = [UIFont systemFontOfSize:12.f];
    _detailLabel.textColor = [MHColorUtils colorWithRGB:0x888888];
    _detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _detailLabel.numberOfLines = 2;
    [_detailLabel setTextAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:_detailLabel];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat width = self.contentView.bounds.size.width;
    CGFloat height = self.contentView.bounds.size.height;
    
    [_titleLabel setFrame:CGRectMake(0, 0, width - height - 20, 25)];
    _titleLabel.center = CGPointMake(height / 2 + width / 2 + 20, self.contentView.center.y/2.0 + 2);
    
    [_detailLabel setFrame:CGRectMake(0, 0, width - height - 20, 40)];
    _detailLabel.center = CGPointMake(_titleLabel.center.x, self.contentView.center.y/2 * 3.0 - 2);
}

- (void)fillWithItem:(MHDeviceSettingItem *)item
{
    [super fillWithItem:item];
    
    _titleLabel.text = self.gatewayItem.caption;
    _detailLabel.text = self.gatewayItem.comment;
    self.imageView.image = [UIImage imageNamed:self.gatewayItem.iconName];
}

+ (CGFloat)heightWithItem:(MHDeviceSettingItem *)item width:(CGFloat)width
{
    return 65.0f;
}

@end
