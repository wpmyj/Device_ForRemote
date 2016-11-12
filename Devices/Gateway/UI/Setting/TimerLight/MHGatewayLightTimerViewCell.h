//
//  MHGatewayLightTimerViewCell.h
//  MiHome
//
//  Created by guhao on 16/1/15.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHTableViewCell.h"

@interface MHGatewayLightTimerViewCell : MHTableViewCell
@property (nonatomic, retain) UISwitch* switcher;
@property (nonatomic, copy) void(^onSwitch)(void);
@end
