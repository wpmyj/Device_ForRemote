//
//  MHPlugTimerSettingViewController.h
//  MiHome
//
//  Created by hanyunhui on 15/9/24.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//

#import "MHViewController.h"
#import <MiHomeKit/MHDevice.h>

@interface MHPlugTimerSettingViewController : MHViewController
- (id)initWithDevice:(MHDevice*)device plugItem:(int)plugItem;

/*
 * 按键事件的响应，子类可定制
 */
- (void)onAddTimer:(BOOL)isUsb;
- (void)onModifyTimer:(MHDataDeviceTimer*) timer isUsb:(BOOL)isUsb;
- (void)onDeleteTimer:(MHDataDeviceTimer*) timer isUsb:(BOOL)isUsb;

/*
 * 定时控制
 */
- (void)addTimer:(MHDataDeviceTimer*) newTimer isUsb:(BOOL)isUsb;
- (void)modifyTimer:(MHDataDeviceTimer*) timer isUsb:(BOOL)isUsb;
- (void)deleteTimer:(MHDataDeviceTimer*) timer isUsb:(BOOL)isUsb;

@end
