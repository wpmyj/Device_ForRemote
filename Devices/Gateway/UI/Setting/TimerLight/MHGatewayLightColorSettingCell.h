//
//  MHGatewayLightColorSettingCell.h
//  MiHome
//
//  Created by guhao on 16/1/15.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHTableViewCell.h"

@protocol MHGatewayLightColorSettingCellDelegate <NSObject>

@optional
- (void)didSelectedColorName:(NSString *)colorname;

@end

@interface MHGatewayLightColorSettingCell : MHTableViewCell <MHGatewayLightColorSettingCellDelegate>

@property (nonatomic, weak) id <MHGatewayLightColorSettingCellDelegate> delegate;

@end
