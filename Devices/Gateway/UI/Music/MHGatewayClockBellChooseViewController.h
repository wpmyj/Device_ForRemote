//
//  MHGatewayClockBellChooseViewController.h
//  MiHome
//
//  Created by guhao on 16/4/27.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceGateway.h"

@interface MHGatewayClockBellChooseViewController : MHLuViewController

@property (nonatomic, copy) void(^onSelectMusic)(NSString* musicName);
@property (nonatomic, copy) void(^onSelectIndex)(NSInteger index);

- (id)initWithGateway:(MHDeviceGateway*)gateway mid:(NSInteger)mid;

@end
