//
//  MHGatewayHumitureRefreshView.h
//  MiHome
//
//  Created by guhao on 16/1/5.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum{
    EGOOPullRefreshPulling = 0,
    EGOOPullRefreshNormal,
    EGOOPullRefreshLoading,
} EGOPullRefreshState;

@protocol MHGatewayHumitureRefreshViewDelegate;
@interface MHGatewayHumitureRefreshView : UIView {
    EGOPullRefreshState _state;
    UILabel *_lastUpdatedLabel;
    CALayer *_arrowImage;


}

@property(nonatomic,assign) NSInteger refreshTriggerValue;
@property(nonatomic,retain) UILabel *statusLabel;
@property(nonatomic,retain) UIActivityIndicatorView *activityView;
@property(nonatomic,weak) id <MHGatewayHumitureRefreshViewDelegate> delegate;


/**
 *  @brief 使用AutoLayout初始化Refresh
 */
- (instancetype)initByUseAutoLayout;

- (void)refreshLastUpdatedDate;
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;

@end
@protocol MHGatewayHumitureRefreshViewDelegate <NSObject>
- (void)egoRefreshTableHeaderDidTriggerRefresh:(MHGatewayHumitureRefreshView *)view;
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(MHGatewayHumitureRefreshView *)view;
@optional
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(MHGatewayHumitureRefreshView *)view;
@end
