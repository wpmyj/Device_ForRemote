//
//  MHGatewayBellChooseViewController.h
//  MiHome
//
//  Created by Woody on 15/4/8.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceGateway.h"

@interface MHGatewayBellChooseViewController : MHLuViewController
@property (nonatomic, copy) void(^onSelectMusic)(NSString* musicName);
@property (nonatomic, copy) void(^onSelectIndex)(NSInteger index);
- (id)initWithGateway:(MHDeviceGateway*)gateway musicGroup:(NSInteger)group;
@end
