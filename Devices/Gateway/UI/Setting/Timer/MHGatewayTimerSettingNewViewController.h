//
//  MHGatewayTimerSettingNewViewController.h
//  MiHome
//
//  Created by Lynn on 7/30/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import <MiHomeKit/MHDevice.h>
#import "MHDeviceGateway.h"

@interface MHGatewayTimerSettingNewViewController : MHLuViewController

@property (nonatomic,strong) NSString *customName;
- (id)initWithDevice:(MHDevice *)device andIdentifier:(NSString *)identifier;

/*
 * 按键事件的响应，子类可定制
 */
- (void)onAddTimer;
- (void)onModifyTimer:(MHDataDeviceTimer*) timer;
- (void)onDeleteTimer:(MHDataDeviceTimer*) timer;

/*
 * 定时控制
 */
- (void)addTimer:(MHDataDeviceTimer*) newTimer;
- (void)modifyTimer:(MHDataDeviceTimer*) timer;
- (void)deleteTimer:(MHDataDeviceTimer*) timer;

@property (nonatomic, copy) void(^onAddNewTimer)(MHDataDeviceTimer*);

@end
