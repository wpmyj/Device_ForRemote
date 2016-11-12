//
//  MHLumiTimeGraduatorView.m
//  Lumi_demo_OC
//
//  Created by LM21Mac002 on 16/10/22.
//  Copyright © 2016年 LM21Mac002. All rights reserved.
//

#import "MHLumiTimeGraduatorView.h"


@implementation MHLumiTimeGraduatorView
@synthesize longHeightRatio = _longHeightRatio;
@synthesize stokeColor = _stokeColor;
@synthesize shortHeightRatio = _shortHeightRatio;
@synthesize lineCount = _lineCount;

static CGFloat kLongHeightRatio = 20.0/120.0;
static CGFloat kShortHeightRatio = 10.0/120.0;
static CGFloat kLineCount = 7;
-(void)drawRect:(CGRect)rect{
    CGFloat w = CGRectGetWidth(rect);
    CGFloat h = CGRectGetHeight(rect);
    CGFloat longHeight = h * [self longHeightRatio];
    CGFloat shortHeight = h * [self shortHeightRatio];
    CGFloat lineCount = [self lineCount];
    CGFloat space = w / (lineCount - 1);
    //获得处理的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //设置线的颜色
    CGContextSetStrokeColorWithColor(context, [self strokeColor].CGColor);
    //中间的宽度为1的
    CGContextSetLineWidth(context, 1.0);
    NSInteger midIndex = lineCount / 2;
    CGContextMoveToPoint(context, space*midIndex, 0);
    CGContextAddLineToPoint(context, space*midIndex, longHeight);
    CGContextMoveToPoint(context, space*midIndex, h-longHeight);
    CGContextAddLineToPoint(context, space*midIndex, h);
    
    //两边的宽度也为1的
    for (NSInteger index = 0+1; index < lineCount-1; index ++) {
        if (index == midIndex){
            continue;
        }
        CGContextMoveToPoint(context, space*index, 0);
        CGContextAddLineToPoint(context, space*index, shortHeight);
        CGContextMoveToPoint(context, space*index, h-shortHeight);
        CGContextAddLineToPoint(context, space*index, h);
    }
    CGContextStrokePath(context);

    //首尾的宽度为0.5的
    CGContextSetLineWidth(context, 0.5);
    for (NSInteger index = 0; index < lineCount; index = index + lineCount - 1) {
        CGContextMoveToPoint(context, space*index, 0);
        CGContextAddLineToPoint(context, space*index, shortHeight);
        CGContextMoveToPoint(context, space*index, h-shortHeight);
        CGContextAddLineToPoint(context, space*index, h);
    }
    CGContextStrokePath(context);
}

- (UIColor *)strokeColor{
    if (_stokeColor){
        return _stokeColor;
    }
    return [UIColor whiteColor];
}

-(void)setStokeColor:(UIColor *)stokeColor{
    _stokeColor = stokeColor;
    [self setNeedsDisplay];
}

- (CGFloat)longHeightRatio{
    if (_longHeightRatio > 0){
        return _longHeightRatio;
    }
    return kLongHeightRatio;
}

- (void)setLongHeightRatio:(CGFloat)longHeightRatio{
    if (longHeightRatio == _longHeightRatio){
        return;
    }
    _longHeightRatio = longHeightRatio;
    [self setNeedsDisplay];
}

- (CGFloat)shortHeightRatio{
    if (_shortHeightRatio > 0){
        return _shortHeightRatio;
    }
    return kShortHeightRatio;
}

- (void)setShortHeightRatio:(CGFloat)shortHeightRatio{
    if (shortHeightRatio == _shortHeightRatio){
        return;
    }
    _shortHeightRatio = shortHeightRatio;
    [self setNeedsDisplay];
}

- (CGFloat)lineCount{
    if (_lineCount > 0){
        return _lineCount;
    }
    return kLineCount;
}

- (void)setLineCount:(CGFloat)lineCount{
    _lineCount = lineCount;
    [self setNeedsDisplay];
}
@end
