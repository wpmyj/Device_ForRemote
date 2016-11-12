//
//  MHPlugCountdownViewController.h
//  MiHome
//
//  Created by hanyunhui on 15/9/28.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//

#import "MHViewController.h"
#import "MHPlugView.h"

@protocol CountdownDelegate <NSObject>

@optional
// 启动和修改倒计时
- (void)countdownDidStart:(MHDataDeviceTimer*)countdownTimer plugItem:(MHPlugItem)item;

// 再次启动
- (void)countdownDidReStart:(MHDataDeviceTimer*)countdownTimer plugItem:(MHPlugItem)item;

// 停止
- (void)countdownDidStop:(MHDataDeviceTimer*)countdownTimer plugItem:(MHPlugItem)item;

// 启删除倒计时
- (void)countdownDidDelete:(MHDataDeviceTimer*)countdownTimer plugItem:(MHPlugItem)item;

@end

@interface MHPlugCountdownViewController : MHViewController

@property (nonatomic, weak) id<CountdownDelegate> delegate;
@property (nonatomic, assign) MHPlugItem plugItem;
@property (nonatomic, assign) BOOL isOn;
@property (nonatomic, strong) MHDataDeviceTimer* countdownTimer; // 需要修改倒计时的时间
@property (nonatomic, assign) NSInteger hour;
@property (nonatomic, assign) NSInteger minute;

@end
