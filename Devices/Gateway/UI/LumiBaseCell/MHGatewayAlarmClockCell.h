//
//  MHGatewayAlarmClockCell.h
//  MiHome
//
//  Created by Lynn on 8/11/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHGatewaySettingCell.h"

@interface MHGatewayAlarmClockCell : MHGatewaySettingCell

@property (nonatomic, copy) void(^onSwitch)(void);

@end
