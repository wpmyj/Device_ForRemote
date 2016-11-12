//
//  MHAlarmClockTimerViewController.h
//  MiHome
//
//  Created by Lynn on 8/11/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import <MiHomeKit/MHDataDeviceTimer.h>
#import "MHDeviceGateway.h"
#import "MHGatewayDurationController.h"

@interface MHAlarmClockTimerViewController : MHLuViewController <UIActionSheetDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>
- (id)initWithTimer:(MHDataDeviceTimer* )timer;
@property (nonatomic, copy) void(^onDone)(id);
@property (nonatomic,strong) MHDeviceGateway *device;
@property (nonatomic,assign) DurationType duraType;

@end
