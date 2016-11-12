//
//  MHLumiSettingCell.h
//  MiHome
//
//  Created by guhao on 4/12/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHDeviceSettingCell.h"

@class MHLumiSettingCell;
typedef void(^MHLumiCallbackBlock)(MHLumiSettingCell *cell);

typedef enum : NSUInteger {
    MHLumiSettingItemTypeDefault,
    MHLumiSettingItemTypeSwitch, //开关
    MHLumiSettingItemTypeDetailSwitch,   //闹钟自定义cell
    MHLumiSettingItemTypeDetailLines,    //detail两行的自定义cell
    MHLumiSettingItemTypeVolume, //音量
    MHLumiSettingItemTypeBrightness, //亮度
    MHLumiSettingItemTypeAccess,            //选择信息
} MHLumiSettingItemType;

@interface MHLumiSettingCellItem : MHDeviceSettingItem

@property (nonatomic, assign) MHLumiSettingItemType lumiType;

@property (nonatomic, copy) MHLumiCallbackBlock lumiCallbackBlock;

@property (nonatomic, copy) NSString *accessText;//左下角描述信息
@property (nonatomic, strong) UIColor *backGroundRGB;
@property (nonatomic, assign) BOOL selected;
@end


@interface MHLumiSettingCell : MHDeviceSettingCell

@property (nonatomic, strong) MHLumiSettingCellItem *lumiItem;

@end
