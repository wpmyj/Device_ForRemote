//
//  MHGatewaySettingCell.h
//  MiHome
//
//  Created by Lynn on 8/11/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHDeviceSettingCell.h"

@class MHGatewaySettingCell;
typedef void(^MHGatewayCallbackBlock)(MHGatewaySettingCell *cell);

typedef enum : NSUInteger {
    MHGatewaySettingItemTypeDefault,
    MHGatewatSettingItemTypeDetailSwitch,   //闹钟自定义cell
    MHGatewatSettingItemTypeDetailLines,    //detail两行的自定义cell
    MHGatewaySettingItemTypeVolume,
    MHGatewaySettingItemTypeBrightness,
    MHGatewaySettingItemTypeLeg,            //腿哥式
} MHGatewaySettingItemType;

#define SettingAccessoryKey_CellHeight  @"cellheight"
#define SettingAccessoryKey_CaptionFontSize  @"CaptionFontSize"
#define SettingAccessoryKey_CaptionFontColor  @"CaptionFontColor"
#define SettingAccessoryKey_CommentFontSize  @"CommentFontSize"
#define SettingAccessoryKey_CommentFontColor  @"CommentFontColor"

@interface MHGatewaySettingCellItem : NSObject
@property (nonatomic, assign) NSString *identifier;
@property (nonatomic, assign) MHGatewaySettingItemType type;
@property (nonatomic, copy) NSString *caption;
@property (nonatomic, assign) BOOL hasAcIndicator;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, assign) BOOL isOn;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, copy) MHGatewayCallbackBlock callbackBlock;
@property (nonatomic, assign) BOOL callBackOnSelect;
@property (nonatomic, strong) MHStrongBox *accessories;
@property (nonatomic, assign) BOOL customUI;    //UI定制
@property (nonatomic, strong) NSString *iconName;

@property (nonatomic, strong) UIColor *backGroundRGB;
@property (nonatomic, assign) BOOL selected;
@end


@interface MHGatewaySettingCell : MHDeviceSettingCell
@property (nonatomic, strong) MHGatewaySettingCellItem *gatewayItem;

@end
