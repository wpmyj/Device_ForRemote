//
//  MHACPartnerDeviceListViewController.h
//  MiHome
//
//  Created by ayanami on 16/5/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceAcpartner.h"

@interface MHACPartnerDeviceListViewController : MHLuViewController

@property (nonatomic, copy) void (^clickAddDeviceBtn)();
@property (nonatomic, copy) void (^clickDeviceCell)(MHDeviceGatewayBase *device);
@property (nonatomic, copy) void (^clickChangeBattery)(MHDeviceGatewayBase *device);
@property (nonatomic, copy) void (^deviceCountChange)();

- (void)startRefresh ;
- (id)initWithFrame:(CGRect)frame sensor:(MHDeviceAcpartner* )acpartner;

@end
