//
//  MHLMBarChartView.h
//  MiHome
//
//  Created by Lynn on 12/14/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHLMChartCommon.h"

@interface MHLMBarChartView : UIView

//bar颜色
@property (nonatomic,strong) UIColor *barOriginColor;
@property (nonatomic,strong) UIColor *barHighlightColor;

//数据源，等同于init里面的chartDataArray，这里提出为数据变化时用
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) NSMutableArray *dateLineSource;
@property (nonatomic,strong) NSString *dateType;
@property (nonatomic,assign) CGFloat barHeightScale;

/**
 *  根据数据数组，画连续曲线图
 *
 *  @param frame            view的frame，设置宽度和当前屏幕一样款（画一屏）
 *  @param chartPointsArray 数据数组, 只定纵坐标值，横坐标值均分
 *
 *  @return 图标
 */
- (id)initWithFrame:(CGRect)frame chartDataArray:(NSArray *)chartDataArray ;

//让某个Bar变色
- (void)addBarAnimation:(NSInteger)barIdx ;
- (void)removeBarAnimation ;

@end
