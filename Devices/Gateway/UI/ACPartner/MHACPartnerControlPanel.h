//
//  MHACPartnerControlPanel.h
//  MiHome
//
//  Created by ayanami on 16/5/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHDeviceAcpartner.h"
#import "MHDeviceGatewayBaseService.h"

@interface MHACPartnerControlPanel : UIView

@property (nonatomic,assign) BOOL shouldKeepRunning;

@property (nonatomic, copy) void (^chooseServiceIcon)(MHDeviceGatewayBaseService *service);
@property (nonatomic, copy) void (^openDevicePageCallback)(MHDeviceGatewayBaseService *service);

- (void)startWatchingDeviceStatus ;
- (void)stopWatchingDeviceStatus ;

- (id)initWithFrame:(CGRect)frame sensor:(MHDeviceAcpartner* )acpartner subDevices:(NSArray *)subDevices;

@end
