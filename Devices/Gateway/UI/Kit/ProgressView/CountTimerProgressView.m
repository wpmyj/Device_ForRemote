//
//  CountTimerProgressView.m
//  MiHome
//
//  Created by Lynn on 8/3/15.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import "CountTimerProgressView.h"

@implementation CountTimerProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat xCenter = rect.size.width * 0.5;
    CGFloat yCenter = rect.size.height * 0.5;
    CGFloat radius = MIN(rect.size.width * 0.5, rect.size.height * 0.5) - SDProgressViewItemMargin * 0.2;
    
    if (self.circleColor){
        // 进度环边框
        [self.circleUnCoverColor set];
        CGFloat mask1W = radius * 2;
        CGFloat mask1H = mask1W;
        CGFloat mask1X = (rect.size.width - mask1W) * 0.5;
        CGFloat mask1Y = (rect.size.height - mask1H) * 0.5;
        CGContextAddEllipseInRect(ctx, CGRectMake(mask1X, mask1Y, mask1W, mask1H));
        CGContextFillPath(ctx);

        
        // 进度环
        [self.circleColor set];
        CGContextMoveToPoint(ctx, xCenter, yCenter);
        CGContextAddLineToPoint(ctx, xCenter, 0);
        CGFloat to = - M_PI * 0.5 + self.progress * M_PI * 2 + 0.001; // 初始值
        CGContextAddArc(ctx, xCenter, yCenter, radius, - M_PI * 0.5, to, 0);
        CGContextClosePath(ctx);
        CGContextFillPath(ctx);
        
        // 遮罩
        [self.backColor set];
        CGFloat maskW = (radius - 4) * 2;
        CGFloat maskH = maskW;
        CGFloat maskX = (rect.size.width - maskW) * 0.5;
        CGFloat maskY = (rect.size.height - maskH) * 0.5;
        CGContextAddEllipseInRect(ctx, CGRectMake(maskX, maskY, maskW, maskH));
        CGContextFillPath(ctx);
        
//        // 遮罩边框
//        [self.circleUnCoverColor set];
//        CGFloat borderW = maskW + 1;
//        CGFloat borderH = borderW;
//        CGFloat borderX = (rect.size.width - borderW) * 0.5;
//        CGFloat borderY = (rect.size.height - borderH) * 0.5;
//        CGContextAddEllipseInRect(ctx, CGRectMake(borderX, borderY, borderW, borderH));
//        CGContextSetLineWidth(ctx, 0.3);
//        CGContextStrokePath(ctx);
    }
    else {
        // 进度环边框
        [SDColorMaker(63, 181, 125, 1) set];
        CGFloat w = radius * 2 + 1;
        CGFloat h = w;
        CGFloat x = (rect.size.width - w) * 0.5;
        CGFloat y = (rect.size.height - h) * 0.5;
        CGContextAddEllipseInRect(ctx, CGRectMake(x, y, w, h));
        CGContextSetLineWidth(ctx, 0.3);
        CGContextStrokePath(ctx);
        
        // 进度环
        [SDColorMaker(63, 181, 125, 1) set];
        CGContextMoveToPoint(ctx, xCenter, yCenter);
        CGContextAddLineToPoint(ctx, xCenter, 0);
        CGFloat to = - M_PI * 0.5 + self.progress * M_PI * 2 + 0.001; // 初始值
        CGContextAddArc(ctx, xCenter, yCenter, radius, - M_PI * 0.5, to, 0);
        CGContextClosePath(ctx);
        CGContextFillPath(ctx);
        
        // 遮罩
        [self.superview.backgroundColor set];
        CGFloat maskW = (radius - 3) * 2;
        CGFloat maskH = maskW;
        CGFloat maskX = (rect.size.width - maskW) * 0.5;
        CGFloat maskY = (rect.size.height - maskH) * 0.5;
        CGContextAddEllipseInRect(ctx, CGRectMake(maskX, maskY, maskW, maskH));
        CGContextFillPath(ctx);
        
        // 遮罩边框
        [SDColorMaker(63, 181, 125, 1) set];
        CGFloat borderW = maskW + 1;
        CGFloat borderH = borderW;
        CGFloat borderX = (rect.size.width - borderW) * 0.5;
        CGFloat borderY = (rect.size.height - borderH) * 0.5;
        CGContextAddEllipseInRect(ctx, CGRectMake(borderX, borderY, borderW, borderH));
        CGContextSetLineWidth(ctx, 0.3);
        CGContextStrokePath(ctx);
        
        // 进度数字
        NSString *progressStr = [NSString stringWithFormat:@"%.0fs", (1.f - self.progress)*self.totalCount];
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        attributes[NSFontAttributeName] = [UIFont boldSystemFontOfSize:20 * SDProgressViewFontScale];
        attributes[NSForegroundColorAttributeName] = [UIColor lightGrayColor];
        [self setCenterProgressText:progressStr withAttributes:attributes];
    }
}

@end