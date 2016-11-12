//
//  MHACPartnerModeSettingViewController.h
//  MiHome
//
//  Created by ayanami on 16/5/19.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayBaseSettingViewController.h"
#import "MHDeviceAcpartner.h"

@interface MHACPartnerModeSettingViewController : MHGatewayBaseSettingViewController


@property (nonatomic, assign) BOOL isSleep;

@property (nonatomic, copy) void (^chooseMode)(int mode);
- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner currentMode:(int)mode;

@end
