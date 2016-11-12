//
//  MHGatewayBellChooseNewViewController.h
//  MiHome
//
//  Created by Lynn on 10/29/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceGateway.h"

@interface MHGatewayBellChooseNewViewController : MHLuViewController
@property (nonatomic, copy) void(^onSelectMusic)(NSString* musicName);
@property (nonatomic, copy) void(^onSelectIndex)(NSInteger index);
- (id)initWithGateway:(MHDeviceGateway*)gateway musicGroup:(NSInteger)group;

//闹钟 选铃音初始化此函数
- (id)initWithGateway:(MHDeviceGateway*)gateway mid:(NSInteger)mid;
@end
