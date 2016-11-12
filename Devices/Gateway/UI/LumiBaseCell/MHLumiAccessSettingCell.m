//
//  MHLumiAccessSettingCell.m
//  MiHome
//
//  Created by guhao on 4/12/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLumiAccessSettingCell.h"

@interface MHLumiAccessSettingCell ()

@property (nonatomic, strong) UILabel *accessLabel;

@end

@implementation MHLumiAccessSettingCell

- (UITableViewCellStyle)cellStyle
{
    return UITableViewCellStyleSubtitle;
}

- (void)buildSubViews
{
    [super buildSubViews];
    self.accessLabel = [[UILabel alloc] init];
    self.accessLabel.font = [UIFont systemFontOfSize:13.0f];
    self.accessLabel.textColor = [MHColorUtils colorWithRGB:0x888888];
    self.accessLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.accessLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    XM_WS(weakself);
    [self.accessLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakself.contentView);
        make.right.mas_equalTo(weakself.contentView.mas_right);
    }];
    
    CGRect detailFrame = self.detailTextLabel.frame;
    detailFrame.size.width = WIN_WIDTH - 150;
    self.detailTextLabel.frame = detailFrame;
}

- (void)fillWithItem:(MHDeviceSettingItem *)item {
    [super fillWithItem:item];
    [self.textLabel setText:self.lumiItem.caption];
    [self.detailTextLabel setText:self.lumiItem.accessText];
    [self.accessLabel setText:self.lumiItem.comment];
    NSLog(@"%@", self.lumiItem.comment);
    NSLog(@"%@", self.accessLabel);
    if (self.item.hasAcIndicator) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (item.customUI) {
        CGFloat captionFontSize = [[item.accessories valueForKey:SettingAccessoryKey_CaptionFontSize class:[NSNumber class]] floatValue];
        if (captionFontSize > 0) {
            self.textLabel.font = [UIFont systemFontOfSize:captionFontSize];
        }
        UIColor* captionFontColor = [item.accessories valueForKey:SettingAccessoryKey_CaptionFontColor class:[UIColor class]];
        if (captionFontColor) {
            [self.textLabel setTextColor:captionFontColor];
        }
        CGFloat commentFontSize = [[item.accessories valueForKey:SettingAccessoryKey_CommentFontSize class:[NSNumber class]] floatValue];
        if (commentFontSize > 0) {
            self.detailTextLabel.font = [UIFont systemFontOfSize:commentFontSize];
            self.accessLabel.font = [UIFont systemFontOfSize:commentFontSize];
        }
        UIColor* commentFontColor = [item.accessories valueForKey:SettingAccessoryKey_CommentFontColor class:[UIColor class]];
        if (commentFontColor) {
            [self.detailTextLabel setTextColor:commentFontColor];
            [self.accessLabel setTextColor:commentFontColor];
        }
        
    }

}

@end
