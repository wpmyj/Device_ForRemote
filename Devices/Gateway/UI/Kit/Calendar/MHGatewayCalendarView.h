//
//  MHGatewayCalendarView.h
//  MiHome
//
//  Created by guhao on 16/5/17.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHGatewayCalendarView : UIView

@property (nonatomic, copy) void (^selectDateCallBack)(NSDate *date);


- (instancetype)initWithCurrentDate:(NSDate *)date;


- (void)showViewInView:(UIView*)view;

- (void)hideView;

@end
