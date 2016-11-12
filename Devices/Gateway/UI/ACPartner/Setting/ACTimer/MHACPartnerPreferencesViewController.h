//
//  MHACPartnerPreferencesViewController.h
//  MiHome
//
//  Created by ayanami on 16/5/19.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayBaseSettingViewController.h"
#import "MHDeviceAcpartner.h"

@interface MHACPartnerPreferencesViewController : MHGatewayBaseSettingViewController

- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner;
- (id)initWithTimer:(MHDataDeviceTimer* )timer andAcpartner:(MHDeviceAcpartner *)acpartner;

@property (nonatomic, copy) void(^onDone)(NSArray *);
@property (nonatomic, copy) void (^chooseMode)(id mode);
@property (nonatomic, copy) void (^chooseWinds)(id winds);
@property (nonatomic, copy) void (^chooseTemperature)(id temp);
@property (nonatomic, copy) void (^chooseSwept)(id swept);


@end
