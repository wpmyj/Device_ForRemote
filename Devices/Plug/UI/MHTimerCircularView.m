//
//  MHTimerCircularView.m
//  MiHome
//
//  Created by hanyunhui on 15/10/14.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//

#import "MHTimerCircularView.h"

#define raduis self.frame.size.width/2

@implementation MHTimerCircularView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 2);
    float endAngle = (_countdownTimer.onHour*60 + _countdownTimer.onMinute)/ (24*60.0) * 2*M_PI;
    CGContextAddArc(context, raduis, raduis, raduis-1, -M_PI_2, endAngle-M_PI_2, 0);
    CGContextStrokePath(context);
}

@end