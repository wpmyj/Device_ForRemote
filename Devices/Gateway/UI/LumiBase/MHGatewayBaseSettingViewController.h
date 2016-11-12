//
//  MHGatewayBaseSettingViewController.h
//  MiHome
//
//  Created by Lynn on 7/30/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHLuDeviceSettingViewController.h"
#import "MHDeviceGateway.h"

@interface MHGatewaySettingGroup : MHLuDeviceSettingGroup
@property (nonatomic, retain) NSString *tail;
@end

@interface MHGatewayBaseSettingViewController : MHLuDeviceSettingViewController

@property (nonatomic,assign) BOOL isGroupStyle;
- (void)insertNewItem:(MHDeviceSettingItem *)item atIndex:(NSUInteger)idx atSection:(NSUInteger)section;

- (void)removeItemAtIndex:(NSUInteger)idx  atSection:(NSUInteger)section;

@end
