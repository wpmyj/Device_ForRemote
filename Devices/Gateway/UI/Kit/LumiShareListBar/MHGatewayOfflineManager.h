//
//  MHGatewayOfflineManager.h
//  MiHome
//
//  Created by guhao on 16/5/13.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHDeviceGateway.h"

@interface MHGatewayOfflineManager : NSObject

+ (id)sharedInstance;

- (void)showTipsWithGateway:(MHDeviceGateway *)gateway;

@end
