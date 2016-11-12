//
//  MHLumiDefaultSettingCell.m
//  MiHome
//
//  Created by guhao on 16/5/14.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiDefaultSettingCell.h"

@implementation MHLumiDefaultSettingCell

- (UITableViewCellStyle)cellStyle
{
    return UITableViewCellStyleSubtitle;
}

- (void)buildSubViews
{
    [super buildSubViews];
    [self.detailTextLabel setTextColor:[MHColorUtils colorWithRGB:0x888888]];
    //    [self setBackgroundColor:[UIColor redColor]];
}

- (void)fillWithItem:(MHDeviceSettingItem *)item
{
    [super fillWithItem:item];
    
    if (item.iconName.length){
        [self.imageView setImage:[UIImage imageNamed:item.iconName]];
    }
    
    [self.textLabel setText:self.lumiItem.caption];
    [self.detailTextLabel setText:self.lumiItem.comment];
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
        }
        UIColor* commentFontColor = [item.accessories valueForKey:SettingAccessoryKey_CommentFontColor class:[UIColor class]];
        if (commentFontColor) {
            [self.detailTextLabel setTextColor:commentFontColor];
        }
        
    }
}



@end
