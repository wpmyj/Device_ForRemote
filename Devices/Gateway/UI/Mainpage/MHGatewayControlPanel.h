//
//  MHGatewayControlPanel.h
//  MiHome
//
//  Created by Lynn on 2/16/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHDeviceGateway.h"
#import "MHDeviceGatewayBaseService.h"

@interface MHGatewayControlPanel : UIView

@property (nonatomic,copy) void (^chooseServiceIcon)(MHDeviceGatewayBaseService *service);
@property (nonatomic,copy) void (^openDevicePageCallback)(MHDeviceGatewayBaseService *service);

- (void)startWatchingDeviceStatus ;
- (void)stopWatchingDeviceStatus ;

- (id)initWithFrame:(CGRect)frame sensor:(MHDeviceGateway* )gateway subDevices:(NSArray *)subDevices;

@end
