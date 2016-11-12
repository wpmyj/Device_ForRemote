//
//  MHGatewayOfflineManager.m
//  MiHome
//
//  Created by guhao on 16/5/13.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayOfflineManager.h"

@implementation MHGatewayOfflineManager
+ (id)sharedInstance {
    static MHGatewayOfflineManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[MHGatewayOfflineManager alloc] init];
        }
    });
    return manager;
}

- (void)showTipsWithGateway:(MHDeviceGateway *)gateway {
    if (!gateway.isOnline) {
        [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"mydevice.offlineview.title",@"plugin_gateway", "网关已离线,请检查连接") duration:1.5 modal:NO];
        return;
    }
}

@end
