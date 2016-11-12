//
//  MHGatewayDeviceListViewController.h
//  MiHome
//
//  Created by Lynn on 2/16/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceGateway.h"
#import "MHDeviceGatewayBase.h"


@interface MHGatewayDeviceListViewController : MHLuViewController

@property (nonatomic, copy) void (^clickAddDeviceBtn)();
@property (nonatomic, copy) void (^clickDeviceCell)(MHDeviceGatewayBase *device);
@property (nonatomic, copy) void (^clickChangeBattery)(MHDeviceGatewayBase *device);
@property (nonatomic, copy) void (^deviceCountChange)();

- (void)startRefresh;
- (id)initWithFrame:(CGRect)frame sensor:(MHDeviceGateway* )gateway;

@end
