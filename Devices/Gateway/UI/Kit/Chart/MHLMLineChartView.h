//
//  MHLMChartView.h
//  MiHome
//
//  Created by Lynn on 12/8/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHLMChartCommon.h"

@interface MHLMLineChartView : UIView

//线条颜色
@property (nonatomic,strong) UIColor *strokeColor;
@property (nonatomic,strong) UIColor *bigSpotColor;

//点size
@property (nonatomic,assign) CGFloat spotSize;

//是否有前后两个点，做连续图时需要
@property (nonatomic,strong) NSNumber *lastPoint;
@property (nonatomic,strong) NSNumber *nextPoint;
@property (nonatomic,strong) NSMutableArray *dataSource;

/**
 *  根据数据数组，画连续曲线图
 *
 *  @param frame            view的frame，设置宽度和当前屏幕一样款（画一屏）
 *  @param chartPointsArray 数据数组, 只定纵坐标值，横坐标值均分
 *
 *  @return 图标
 */
- (id)initWithFrame:(CGRect)frame chartDataArray:(NSArray *)chartDataArray ;

//让某个点产生膨胀的动画
- (void)addSpotAnimation:(NSInteger)spotIdx ;
- (void)removeSpotAnimation ;

@end
