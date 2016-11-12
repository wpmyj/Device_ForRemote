//
//  MHGatewayNamingSpeedViewController.h
//  MiHome
//
//  Created by guhao on 4/16/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceGateway.h"

@interface MHGatewayNamingSpeedViewController : MHLuViewController

- (id)initWithSubDevice:(MHDeviceGatewayBase *)subDevice gatewayDevice:(MHDeviceGateway *)gateway shareIdentifier:(BOOL)isShare serviceIndex:(NSInteger)index;

@property (nonatomic, copy) NSString *leftName;

@end
