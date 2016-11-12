//
//  MHACPartnerCountdownViewController.h
//  MiHome
//
//  Created by ayanami on 16/7/8.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import <MiHomeKit/MiHomeKit.h>
#import "MHDeviceAcpartner.h"

@protocol ACPartnerCountdownDelegate <NSObject>

@optional
// 启动和修改倒计时
- (void)countdownDidStart:(MHDataDeviceTimer*)countdownTimer;

// 再次启动
//- (void)countdownDidReStart:(MHDataDeviceTimer*)countdownTimer;

// 停止
//- (void)countdownDidStop:(MHDataDeviceTimer*)countdownTimer;

// 删除倒计时
- (void)countdownDidDelete:(MHDataDeviceTimer*)countdownTimer;

@end
@interface MHACPartnerCountdownViewController : MHLuViewController
@property (nonatomic, assign) id<ACPartnerCountdownDelegate> delegate;
@property (nonatomic, assign) BOOL isOn;
@property (nonatomic, strong) MHDataDeviceTimer* countdownTimer; // 需要修改倒计时的时间
@property (nonatomic, assign) NSInteger hour;
@property (nonatomic, assign) NSInteger minute;

- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner;

@end
