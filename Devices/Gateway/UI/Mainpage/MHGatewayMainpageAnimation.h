//
//  MHGatewayMainpageAnimation.h
//  MiHome
//
//  Created by Lynn on 2/24/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TransTime   0.4f

typedef enum : NSInteger{
    Direction_Left,
    Direction_Right,
} AnimationDirection;

@interface MHGatewayMainpageAnimation : NSObject

//处理首页三个view转场动画
@property (nonatomic,weak) UIViewController *homeVC;
@property (nonatomic,strong) NSArray *subViewArray;
@property (nonatomic,assign) NSInteger currentIndex;
@property (nonatomic,copy) void (^leftAnimationEndCallBack)();
@property (nonatomic,copy) void (^onClickCurrentIndex)(NSInteger index);

@property (nonatomic,strong,readonly) UISwipeGestureRecognizer *swipeRight;
@property (nonatomic,strong,readonly) UISwipeGestureRecognizer *swipeLeft;

- (void)homeVCAddGestureRecognizer ;
- (void)homeVCRemovewGestureRecognizer ;
- (void)swiped:(UISwipeGestureRecognizer *)sender;

//处理首页headerview的颜色渐变动画
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) UIView *headerBufferView;
@property (nonatomic,strong) NSArray *colorsArray;
@property (nonatomic,assign) AnimationDirection currentDirection;
@property (nonatomic,assign) NSInteger currentPage;
- (void)headerViewBackgroundColorAnimation:(AnimationDirection)direction progress:(CGFloat)progress;

@end
