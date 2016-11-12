//
//  MHLMChartCommon.h
//  MiHome
//
//  Created by Lynn on 12/14/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height

#define ScrollViewBuffer  30.f  //其中20.f 为留下的坐标字体，10.f为零点位移

typedef enum : NSUInteger{
    MHLMBarChart,
    MHLMLineChart
} MHLMChartType;
