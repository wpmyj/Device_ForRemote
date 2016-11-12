//
//  MHACPartnerWindsSettingViewController.h
//  MiHome
//
//  Created by ayanami on 16/5/19.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayBaseSettingViewController.h"
#import "MHDeviceAcpartner.h"

@interface MHACPartnerWindsSettingViewController : MHGatewayBaseSettingViewController

@property (nonatomic, copy) void (^chooseWinds)(int winds);
//- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner;

- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner currentWinds:(int)winds;

@end
