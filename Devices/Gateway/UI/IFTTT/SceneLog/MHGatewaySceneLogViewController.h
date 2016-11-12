//
//  MHGatewaySceneLogViewController.h
//  MiHome
//
//  Created by guhao on 16/5/17.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayExpandableTableViewController.h"
#import "MHDeviceGateway.h"

@interface MHGatewaySceneLogViewController : MHGatewayExpandableTableViewController

- (id)initWithGateway:(MHDeviceGateway *)gateway;

@end
