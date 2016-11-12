//
//  MHACCoolSpeedHtBindViewController.h
//  MiHome
//
//  Created by ayanami on 16/7/27.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLuDeviceSettingViewController.h"
#import "MHDeviceAcpartner.h"

#define kCoolNotBindHt @"lumi.notAssociated"

@interface MHACCoolSpeedHtBindViewController : MHLuDeviceSettingViewController
@property (nonatomic, copy) void(^htSelect)(NSString *);

- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner htDid:(NSString *)did timeSpan:(NSInteger)timeSpan;

@end
