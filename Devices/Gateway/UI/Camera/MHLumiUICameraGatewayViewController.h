//
//  MHLumiUICameraGatewayViewController.h
//  MiHome
//
//  Created by LM21Mac002 on 2016/10/31.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//
#import "MHLuViewController.h"
#import "MHLuDeviceViewControllerBase.h"
#define HeaderViewLastIndexKey @"lumi_homepage_headerview_index"

typedef void (^navigationCallback)(UIViewController *destinationVC);

/**
 *  主要代码都是从MHGatewayControlViewController复制过来，有时间再重构
 */
@interface MHLumiUICameraGatewayViewController : MHLuDeviceViewControllerBase

@property (nonatomic, copy) void (^openDevicePageCallback)(MHDeviceGatewayBase *sensor);
@property (nonatomic, copy) void (^openDeviceLogPageCallback)(MHDeviceGatewayBase *sensor);
@property (nonatomic, copy) void (^chooseServiceIcon)(MHDeviceGatewayBaseService *service);

@property (nonatomic, copy) navigationCallback navigationClick;

- (id)initWithSensor:(MHDeviceGateway* )gateway ;

- (void)reBuildSubviews;

@end