//
//  MHGatewayMigrationLoadingController.h
//  MiHome
//
//  Created by Lynn on 5/25/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceGateway.h"

@interface MHGatewayMigrationLoadingController : MHLuViewController

@property (nonatomic,strong) MHDeviceGateway *outGateway;
@property (nonatomic,strong) MHDeviceGateway *inGateway;

@end
