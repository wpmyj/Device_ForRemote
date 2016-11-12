//
//  CountTimerProgressView.h
//  MiHome
//
//  Created by Lynn on 8/3/15.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import "SDBaseProgressView.h"

@interface CountTimerProgressView : SDBaseProgressView

@property (nonatomic,assign) CGFloat totalCount;

@property (nonatomic,strong) UIColor *circleColor;
@property (nonatomic,strong) UIColor *backColor;
@property (nonatomic,strong) UIColor *circleUnCoverColor;

@end