//
//  MHLumiVolumeSettingCell.h
//  MiHome
//
//  Created by ayanami on 16/5/20.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiSettingCell.h"
#define MinValue    @"minValue"
#define MaxValue    @"maxValue"
#define CurValue    @"curValue"

@interface MHLumiVolumeSettingCell : MHLumiSettingCell

@property (nonatomic, assign) NSInteger accessType;
@property (nonatomic,strong) void (^volumeControlCallBack)(NSInteger value, NSString *type, MHLumiVolumeSettingCell *cell);

- (void)configureConstruct:(NSInteger)value andType:(NSString *)type imageType:(MHLumiSettingItemType)imageType;

@end
