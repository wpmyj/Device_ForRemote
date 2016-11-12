//
//  MHDeviceGatewaySensorLoopDataV2.h
//  MiHome
//
//  Created by LM21Mac002 on 16/9/8.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewayBase.h"

@interface MHDeviceGatewaySensorLoopDataV2 : MHDeviceGatewayBase

@property (nonatomic,weak) MHDevice *device;

- (void)startWatchingNewData:(NSString *)methodName WithParams:(id)params;
- (void)stopWatching;

@property (nonatomic,strong) void (^fetchNewDataCallBack)(id propNewData);

@end
