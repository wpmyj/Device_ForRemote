//
//  MHGatewayLightTimerView.h
//  MiHome
//
//  Created by guhao on 16/1/15.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MiHomeKit/MiHomeKit.h>
#import "EGORefreshTableHeaderView.h"

@interface MHGatewayLightTimerView : UIView <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIScrollViewDelegate,  EGORefreshTableHeaderDelegate>
@property (nonatomic, assign) BOOL needBlankCup;
@property (nonatomic, copy) NSString* timerIdentify;
@property (nonatomic, copy) void(^refreshTimerList)(void);
@property (nonatomic, copy) void(^onAddTimer)(void);
@property (nonatomic, copy) void(^onModifyTimer)(MHDataDeviceTimer* timer, BOOL isNeedOpenEditPage);
@property (nonatomic, copy) void(^onDelTimer)(MHDataDeviceTimer* timer);
@property (nonatomic, copy) void(^onNewDelTimer)(NSInteger index);

- (id)initWithDevice:(MHDevice*)device timerList:(NSArray* )timerList parentVC:(UIViewController* )parentVC;
- (void)onRefreshTimerListDone:(BOOL)succeed timerList:(NSArray* )timerList;

@end
