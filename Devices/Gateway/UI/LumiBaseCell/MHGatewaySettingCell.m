//
//  MHGatewaySettingCell.m
//  MiHome
//
//  Created by Lynn on 8/11/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHGatewaySettingCell.h"

@implementation MHGatewaySettingCellItem

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

- (void)setType:(MHGatewaySettingItemType)type
{
    _type = type;
    self.callBackOnSelect = [self inferCallbackType:_type];
}

//点击cell是否响应，响应调用callbackBlock
- (BOOL)inferCallbackType:(MHGatewaySettingItemType)type
{
    switch (type) {
        case MHGatewaySettingItemTypeDefault:
            return YES;
            break;
        case MHGatewatSettingItemTypeDetailSwitch:
            return NO;
        case MHGatewatSettingItemTypeDetailLines:
            return YES;
        case MHGatewaySettingItemTypeVolume:
            return YES;
        case MHGatewaySettingItemTypeBrightness:
            return YES;
        case MHGatewaySettingItemTypeLeg:
            return YES;
        default:
            return NO;
            break;
    }
}

@end

@implementation MHGatewaySettingCell
{
    UIView *_bottomLine;
}

- (void)fillWithItem:(MHDeviceSettingItem *)item
{
    [super fillWithItem:item];
    if ([item isKindOfClass:[MHGatewaySettingCellItem class]]){
        self.gatewayItem = (MHGatewaySettingCellItem *)item;
    }
    
    _bottomLine = [[UIView alloc] init];
    _bottomLine.backgroundColor = [MHColorUtils colorWithRGB:0xf1f1f1];
    [self.contentView addSubview:_bottomLine];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_bottomLine setFrame:CGRectMake(20.0f, self.bounds.size.height - 1.0f, self.bounds.size.width - 20.0f * 2, 1.0f)];
}


@end
