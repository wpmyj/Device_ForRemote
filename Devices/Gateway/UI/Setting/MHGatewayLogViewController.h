//
//  MHGatewayLogViewController.h
//  MiHome
//
//  Created by Lynn on 9/30/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import <MiHomeKit/MHDevice.h>

@interface MHGatewayLogViewController : MHLuViewController

@property (nonatomic,copy) void(^onGetLatestLogDescript)(NSString *descript);
- (id)initWithDevice:(MHDevice *)device;
@end
