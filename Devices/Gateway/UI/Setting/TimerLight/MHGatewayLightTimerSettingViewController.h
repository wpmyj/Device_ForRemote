//
//  MHGatewayLightTimerSettingViewController.h
//  MiHome
//
//  Created by guhao on 16/1/15.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import <MiHomeKit/MHDevice.h>
#import "MHDeviceGateway.h"

@interface MHGatewayLightTimerSettingViewController : MHLuViewController
- (id)initWithDevice:(MHDeviceGateway *)device andIdentifier:(NSString *)identifier;

/*
 * 按键事件的响应，子类可定制
 */
- (void)onAddTimer;
//- (void)onModifyTimer:(MHDataDeviceTimer*) timer;
- (void)onDeleteTimer:(MHDataDeviceTimer*) timer;

/*
 * 定时控制
 */
- (void)addTimer:(MHDataDeviceTimer*) newTimer;
- (void)modifyTimer:(MHDataDeviceTimer*) timer;
- (void)deleteTimer:(MHDataDeviceTimer*) timer;

//@property (nonatomic, copy) void(^onAddNewTimer)(MHDataDeviceTimer*, NSNumber *nightColor);
@end
