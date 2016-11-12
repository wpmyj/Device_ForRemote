//
//  MHPlugCountdownViewController.h
//  MiHome
//
//  Created by hanyunhui on 15/9/28.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import <MiHomeKit/MiHomeKit.h>

@protocol CountdownDelegate <NSObject>

@optional
// 启动和修改倒计时
- (void)countdownDidStart:(MHDataDeviceTimer*)countdownTimer;

// 再次启动
- (void)countdownDidReStart:(MHDataDeviceTimer*)countdownTimer;

// 停止
- (void)countdownDidStop:(MHDataDeviceTimer*)countdownTimer;

// 启删除倒计时
- (void)countdownDidDelete:(MHDataDeviceTimer*)countdownTimer;

@end

@interface MHGatewayPlugCountdownViewController : MHLuViewController

@property (nonatomic, assign) id<CountdownDelegate> delegate;
@property (nonatomic, assign) BOOL isOn;
@property (nonatomic, strong) MHDataDeviceTimer* countdownTimer; // 需要修改倒计时的时间
@property (nonatomic, assign) NSInteger hour;
@property (nonatomic, assign) NSInteger minute;

@end
