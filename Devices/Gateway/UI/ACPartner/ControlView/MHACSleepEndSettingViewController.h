//
//  MHACSleepEndSettingViewController.h
//  MiHome
//
//  Created by ayanami on 8/30/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLuDeviceSettingViewController.h"
#import "MHDeviceAcpartner.h"

@interface MHACSleepEndSettingViewController : MHLuDeviceSettingViewController

@property (nonatomic, copy) void(^endSetBlock)(NSUInteger type, NSUInteger delayOffTime);
- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner endType:(NSUInteger)type;

@end
