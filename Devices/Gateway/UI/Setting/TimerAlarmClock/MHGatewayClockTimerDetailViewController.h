//
//  MHGatewayClockTimerDetailViewController.h
//  MiHome
//
//  Created by guhao on 4/8/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import <MiHomeKit/MHDataDeviceTimer.h>
#import "MHDeviceGateway.h"

@interface MHGatewayClockTimerDetailViewController : MHLuViewController<UIActionSheetDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>

- (id)initWithTimer:(MHDataDeviceTimer* )timer andGatewayDevice:(MHDeviceGateway *)device;

@property (nonatomic, copy) void(^onDone)(MHDataDeviceTimer*);

@end
