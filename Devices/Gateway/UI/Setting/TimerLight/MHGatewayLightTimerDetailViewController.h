//
//  MHGatewayLightTimerDetailViewController.h
//  MiHome
//
//  Created by guhao on 16/1/15.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import <MiHomeKit/MHDataDeviceTimer.h>
#import "MHDeviceGateway.h"

@interface MHGatewayLightTimerDetailViewController : MHLuViewController <UIActionSheetDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>
- (id)initWithTimer:(MHDataDeviceTimer* )timer andGatewayDevice:(MHDeviceGateway *)device;
@property (nonatomic, copy) void(^onDone)(MHDataDeviceTimer*, NSNumber *nightColor);

@end
