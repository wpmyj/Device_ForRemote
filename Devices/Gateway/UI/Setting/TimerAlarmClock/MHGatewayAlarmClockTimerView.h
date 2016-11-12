//
//  MHGatewayAlarmClockTimerView.h
//  MiHome
//
//  Created by guhao on 4/8/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHDeviceTimerView.h"

@interface MHGatewayAlarmClockTimerView : MHDeviceTimerView

@property (nonatomic, copy) void(^onNewDelTimer)(NSInteger index);
@property (nonatomic, copy) void(^onSettingTimer)(void);

@property (nonatomic, strong) NSString *customName;

@end
