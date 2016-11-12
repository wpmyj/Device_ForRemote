//
//  MHACPartnerTimerView.h
//  MiHome
//
//  Created by ayanami on 16/5/20.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MiHomeKit/MiHomeKit.h>
#import "EGORefreshTableHeaderView.h"
#import "MHDeviceAcpartner.h"

@interface MHACPartnerTimerView : UIView<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIScrollViewDelegate,  EGORefreshTableHeaderDelegate>

@property (nonatomic, assign) BOOL needBlankCup;
@property (nonatomic, copy) NSString* timerIdentify;
@property (nonatomic, copy) void(^refreshTimerList)(void);
@property (nonatomic, copy) void(^onAddTimer)(void);
@property (nonatomic, copy) void(^onModifyTimer)(MHDataDeviceTimer* timer, BOOL isNeedOpenEditPage);
@property (nonatomic, copy) void(^onDelTimer)(MHDataDeviceTimer* timer);
@property (nonatomic, copy) void(^onNewDelTimer)(NSInteger index);

- (id)initWithDevice:(MHDeviceAcpartner *)acpartner timerList:(NSArray *)timerList;
- (void)onRefreshTimerListDone:(BOOL)succeed timerList:(NSArray* )timerList;

@end
