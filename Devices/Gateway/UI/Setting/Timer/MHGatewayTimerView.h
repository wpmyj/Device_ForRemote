//
//  MHGatewayTimerView.h
//  MiHome
//
//  Created by Lynn on 11/13/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHDeviceTimerView.h"

@interface MHGatewayTimerView : MHDeviceTimerView

@property (nonatomic, copy) void(^onNewDelTimer)(NSInteger index);

@property (nonatomic, strong) NSString *customName;

@end
