//
//  MHGatewayLinkAlarmViewController.h
//  MiHome
//
//  Created by ayanami on 16/7/5.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLuDeviceSettingViewController.h"
#import "MHDeviceGateway.h"

#define ALARM_IDENTIFY              @"lm_linkage_alarm"
#define DIS_ALARM_IDENTIFY          @"lm_linkage_dis_alarm"
#define DIS_ALARM_ALL_IDENTIFY      @"lm_linkage_dis_all_alarm"

@interface MHGatewayLinkAlarmViewController : MHLuDeviceSettingViewController

- (id)initWithGateway:(MHDeviceGateway *)gateway;


@end
