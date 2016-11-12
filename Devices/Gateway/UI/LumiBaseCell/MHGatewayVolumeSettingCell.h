//
//  MHGatewayVolumeSettingCell.h
//  MiHome
//
//  Created by guhao on 16/2/1.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewaySettingCell.h"

#define MinValue    @"minValue"
#define MaxValue    @"maxValue"
#define CurValue    @"curValue"

@interface MHGatewayVolumeSettingCell : MHGatewaySettingCell

@property (nonatomic, assign) NSInteger accessType;
@property (nonatomic,strong) void (^volumeControlCallBack)(NSInteger value, NSString *type, MHGatewayVolumeSettingCell *cell);
- (void)configureConstruct:(NSInteger)value andType:(NSString *)type;
- (void)configureConstruct:(NSInteger)value andType:(NSString *)type imageType:(MHGatewaySettingItemType)imageType;


@end
