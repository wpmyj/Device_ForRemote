//
//  MHLMChartCanvasView.h
//  MiHome
//
//  Created by Lynn on 12/9/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHLMLineChartView.h"
#import "MHLMChartCommon.h"
#import "MHLMBarChartView.h"

@interface MHLMChartCanvasView : UIView

/**
 *  根据数据数组，画连续曲线图
 *
 *  @param frame            view的frame，设置宽度和当前屏幕一样款（画一屏）
 *  @param dataSource       dataSource，纵坐标数据
 *
 *  @return 图标
 */
- (id)initWithFrame:(CGRect)frame
         DataSource:(NSMutableArray *)dataSource
     DateLineSource:(NSMutableArray *)dateLineSource
        LargestData:(CGFloat)largestData
      ScreenSpotCnt:(NSInteger)screenSpotCnt
          ChartType:(MHLMChartType)chartType ;

@property (nonatomic,strong) NSArray *switchBtnTitleGroup;
@property (nonatomic,strong) NSArray *switchBtnBlockGroup;
@property (nonatomic,strong) NSMutableArray *switchButtonGroup;

//线条颜色
@property (nonatomic,strong) UIColor *strokeColor;
@property (nonatomic,strong) UIColor *hightLightColor;

//数据源（一组纵坐标对应数据）
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) NSMutableArray *dateLineSource;
@property (nonatomic,assign) CGFloat largestData;

//一屏点数/bar数量
@property (nonatomic,strong) NSString *dateType;    //day || month
@property (nonatomic,assign) NSInteger screenSpotNum;

//对当前数据，方便下一次获取数据的定位点
@property (nonatomic,strong) void (^updateCurrent)(CGFloat currentDataIdentifier);

//获取更多，回调函数
@property (nonatomic,strong) void (^getMoreBlock)(NSString *firstData);


- (void)btnClicked:(UIButton *)btn;

@end
