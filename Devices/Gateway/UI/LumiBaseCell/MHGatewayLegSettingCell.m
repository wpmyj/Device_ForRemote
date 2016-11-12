//
//  MHGatewayLegSettingCell.m
//  MiHome
//
//  Created by guhao on 3/31/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayLegSettingCell.h"

@implementation MHGatewayLegSettingCell

- (UITableViewCellStyle)cellStyle
{
    return UITableViewCellStyleValue1;
}

- (void)buildSubViews
{
    [self.detailTextLabel setTextColor:[MHColorUtils colorWithRGB:0x888888]];
}

- (void)fillWithItem:(MHDeviceSettingItem *)item
{
    [super fillWithItem:item];
    
    [self.textLabel setText:self.item.caption];
    [self.detailTextLabel setText:self.item.comment];
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

+ (CGFloat)heightWithItem:(MHDeviceSettingItem *)item width:(CGFloat)width
{
    if (item.customUI) {
        CGFloat cellHeight = [[item.accessories valueForKey:SettingAccessoryKey_CellHeight class:[NSNumber class]] floatValue];
        return cellHeight > 0 ? cellHeight : 60.0f;
    }
    return 60.0f;
}



- (void)setGatewayItem:(MHGatewaySettingCellItem *)gatewayItem {
    [self.textLabel setText:gatewayItem.caption];
    [self.detailTextLabel setText:gatewayItem.comment];
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
