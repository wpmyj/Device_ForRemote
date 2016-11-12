//
//  MHLumiSettingCell.m
//  MiHome
//
//  Created by guhao on 4/12/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLumiSettingCell.h"

@implementation MHLumiSettingCellItem

- (instancetype)init
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    self.callBackOnSelect = YES;
    self.enabled = YES;
    return self;
}

- (void)setLumiType:(MHLumiSettingItemType)lumiType {
    _lumiType = lumiType;
    self.callBackOnSelect = [self inferCallbackType:_lumiType];
}
//点击cell是否响应，响应调用callbackBlock
- (BOOL)inferCallbackType:(MHLumiSettingItemType)type
{
    switch (type) {
        case MHLumiSettingItemTypeDefault:
            return YES;
            break;
        case MHLumiSettingItemTypeSwitch:
        case MHLumiSettingItemTypeDetailSwitch:
            return NO;
            break;
        case MHLumiSettingItemTypeDetailLines:
        case MHLumiSettingItemTypeVolume:
        case MHLumiSettingItemTypeBrightness:
        case MHLumiSettingItemTypeAccess:
            return YES;
        default:
            return NO;
            break;
    }
}

@end

@interface MHLumiSettingCell ()


@end

@implementation MHLumiSettingCell
{
    UIView *_bottomLine;
}

- (UITableViewCellStyle)cellStyle
{
    return UITableViewCellStyleDefault;
}

- (void)buildSubViews
{
    _bottomLine = [[UIView alloc] init];
    _bottomLine.backgroundColor = [MHColorUtils colorWithRGB:0xf1f1f1];
    [self.contentView addSubview:_bottomLine];
    
    [self.detailTextLabel setTextColor:[MHColorUtils colorWithRGB:0x888888]];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [_bottomLine setFrame:CGRectMake(20.0f, self.bounds.size.height - 1.0f, self.bounds.size.width - 20.0f * 2, 1.0f)];
    
}

+ (CGFloat)heightWithItem:(MHDeviceSettingItem *)item width:(CGFloat)width
{
    if (item.customUI) {
        CGFloat cellHeight = [[item.accessories valueForKey:SettingAccessoryKey_CellHeight class:[NSNumber class]] floatValue];
        return cellHeight > 0 ? cellHeight : 60.0f;
    }
    return 60.0f;
}

- (void)fillWithItem:(MHDeviceSettingItem *)item
{
    [super fillWithItem:item];
//    _lumiItem = (MHLumiSettingCellItem *)item;
        self.lumiItem = (MHLumiSettingCellItem *)item;
}

@end
