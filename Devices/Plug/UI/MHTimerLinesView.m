//
//  MHTimerLinesView.m
//  MiHome
//
//  Created by hanyunhui on 15/10/10.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//

#import "MHTimerLinesView.h"
#import <MiHomeKit/MHDataDeviceTimer.h>
#import <MiHomeKit/XMCoreMacros.h>

@implementation MHTimerLinesView
{
    UILabel*        labelStart;
    UILabel*        labelEnd;
    UIImageView*    imageV;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    [self labelTag];
    return self;
}

- (void)labelTag {    
    // 开始14  长度38  间隔8  在iphone4上 宽度至少38
    if(!labelStart) {
        labelStart = [[UILabel alloc] initWithFrame:CGRectMake(14*ScaleWidth, 0, 38*ScaleWidth, 20)];
        [self addSubview:labelStart];
    }
    labelStart.textAlignment = NSTextAlignmentCenter;
    labelStart.font = [UIFont systemFontOfSize:11.0];
    [labelStart setTextColor:[MHColorUtils colorWithRGB:0xffffff alpha:0.3]];
    
    if(!labelEnd) {
        labelEnd = [[UILabel alloc] initWithFrame:CGRectMake(WIN_WIDTH-(38+14)*ScaleWidth, 0, 38*ScaleWidth, 20)];
        [self addSubview:labelEnd];
    }
    labelEnd.textAlignment = NSTextAlignmentCenter;
    labelEnd.font = [UIFont systemFontOfSize:11.0];
    [labelEnd setTextColor:[MHColorUtils colorWithRGB:0xffffff alpha:0.3]];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // 背景线条：开始位置x:60  结束:315  length:255
    CGContextRef context1 = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context1, [MHColorUtils colorWithRGB:0xffffff alpha:0.3].CGColor);
    CGContextSetLineWidth(context1, 2.0);
 
    CGContextMoveToPoint(context1, 60*ScaleWidth, 10);
    CGContextAddLineToPoint(context1, 315*ScaleWidth, 10);
    
    // 当前时间
    MHDataDeviceTimer* now = [[MHDataDeviceTimer alloc] init];
    [now nowChangeFormatTimer];
    int width = 10;
    int height = 6;
    float nowX = ((now.onHour*60.0 + now.onMinute) / (24*60.0)) * 255 * ScaleWidth;
    nowX += 60*ScaleWidth-width/2.0;
    if (!imageV) {
        imageV = [[UIImageView alloc] initWithFrame:CGRectMake(nowX, -width/2.0, width, height)];
        [self addSubview:imageV];
    }
    
    // 没有时间段时
    if(!_timerAllLineslist || _timerAllLineslist.count<2){
        labelStart.text = @"";
        labelEnd.text = @"";
        imageV.image = nil;
        CGContextSetLineWidth(context1, 0.0);
    } else {
        labelStart.text = @"00:00";
        labelEnd.text = @"24:00";
        imageV.image = [UIImage imageNamed:@"timer_progress_arrow"];
        CGContextSetLineWidth(context1, 2.0);
    }
    CGContextStrokePath(context1);
    
    // 进度线条
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    
    // 画线
    for (MHDataDeviceTimer* timer in _timerAllLineslist) {
        float pointX = ((timer.onHour*60.0 + timer.onMinute) / (24*60.0)) * 255 * ScaleWidth;
        pointX += 60*ScaleWidth;
        if (timer.isOnOpen) { // 开始点
            CGContextMoveToPoint(context, pointX, 10);
        }
        if (!timer.isOnOpen) {  // 结束点
            CGContextAddLineToPoint(context, pointX, 10);
        }
    }
    CGContextStrokePath(context);
}

@end