//
//  MHACPartnerControlViewController.h
//  MiHome
//
//  Created by ayanami on 16/5/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceAcpartner.h"

#define ACHeaderViewLastIndexKey @"lumi_gateway_headerview_index"

typedef void (^navigationCallback)(UIViewController *destinationVC);

@interface MHACPartnerControlViewController : MHLuViewController

@property (nonatomic, copy) void (^openDevicePageCallback)(MHDeviceGatewayBase *sensor);
@property (nonatomic, copy) void (^openDeviceLogPageCallback)(MHDeviceGatewayBase *sensor);
@property (nonatomic, copy) void (^chooseServiceIcon)(MHDeviceGatewayBaseService *service);

@property (nonatomic, copy) navigationCallback navigationClick;

- (id)initWithFrame:(CGRect)frame acpartner:(MHDeviceAcpartner *)acpartner;

- (void)startRefresh;
- (void)stopRefresh;
@end
