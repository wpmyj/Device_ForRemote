//
//  MHGatewayCalendarItemView.h
//  MiHome
//
//  Created by guhao on 16/5/17.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kITEMHEIGHT (WIN_WIDTH - 5 * 2) * 6 / 7

@protocol MHGatewayCalendarItemViewDelegate;

@interface MHGatewayCalendarItemView : UIView

@property (strong, nonatomic) NSDate *date;
@property (weak, nonatomic) id<MHGatewayCalendarItemViewDelegate> delegate;

- (NSDate *)nextMonthDate;
- (NSDate *)previousMonthDate;

@end

@protocol MHGatewayCalendarItemViewDelegate <NSObject>

- (void)calendarItem:(MHGatewayCalendarItemView *)item didSelectedDate:(NSDate *)date;
@end
