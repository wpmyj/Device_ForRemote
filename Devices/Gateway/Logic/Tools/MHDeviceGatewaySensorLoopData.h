//
//  MHDeviceGatewaySensorXBulbLoop.h
//  MiHome
//
//  Created by Lynn on 8/8/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewayBase.h"

@interface MHDeviceGatewaySensorLoopData : MHDeviceGatewayBase

@property (nonatomic,weak) MHDevice *device;

- (void)startWatchingNewData:(NSString *)propName WithParams:(id)params;
- (void)stopWatching;

@property (nonatomic,strong) void (^fetchNewDataCallBack)(id propNewData);

@end
