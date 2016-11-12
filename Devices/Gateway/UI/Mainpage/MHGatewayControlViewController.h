//
//  MHGatewayControlViewController.h
//  MiHome
//
//  Created by Lynn on 2/16/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceGateway.h"
#define HeaderViewLastIndexKey @"lumi_homepage_headerview_index"

typedef void (^navigationCallback)(UIViewController *destinationVC);

@interface MHGatewayControlViewController : MHLuViewController

@property (nonatomic, copy) void (^openDevicePageCallback)(MHDeviceGatewayBase *sensor);
@property (nonatomic, copy) void (^openDeviceLogPageCallback)(MHDeviceGatewayBase *sensor);
@property (nonatomic, copy) void (^chooseServiceIcon)(MHDeviceGatewayBaseService *service);

@property (nonatomic, copy) navigationCallback navigationClick;

- (id)initWithFrame:(CGRect)frame sensor:(MHDeviceGateway* )gateway ;

- (void)reBuildSubviews;

@end
