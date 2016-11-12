//
//  MHGatewayAlarmTriggerViewController.h
//  MiHome
//
//  Created by Woody on 15/4/9.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceGateway.h"

@interface MHGatewayAlarmTriggerViewController : MHLuViewController

- (id)initWithAlarmFromSensorId:(NSString* )sid toDevice:(MHDeviceGateway*)device event:(NSString* )event time:(NSDate *)time;
@end
