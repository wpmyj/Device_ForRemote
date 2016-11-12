//
//  MHVolumeBarView.m
//  MiHome
//
//  Created by Lynn on 11/3/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHVolumeBarView.h"

#define TotalLevel 7.0f

@implementation MHVolumeBarView
{
    UIColor *               _backgroundColor;
    int                     _barLevel; //共分七个等级，对_barWidth比例等分
}

-(id)initWithFrame:(CGRect)frame andColor:(UIColor *)color Level:(int)level
{
    self = [ super initWithFrame: frame ];
    
    if( self ) {
        if(color) _backgroundColor = color;
        else _backgroundColor = DefaultBarColor;
        _barLevel = level;
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void) drawRect: (CGRect) rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat x = CGRectGetMinX(rect);
    CGFloat y = CGRectGetMaxY(rect);
    CGFloat width = CGRectGetWidth(rect);
    CGFloat heigh = CGRectGetHeight(rect) * 2;
    CGRect frame = CGRectMake(x, y, width, heigh);
    
    //颜色填充:
    CGContextStrokeRect(context,frame);//画方框
    CGContextFillRect(context,frame);//填充框

    CGContextSetLineWidth(context, 7.0);//线的宽度
    CGContextSetFillColorWithColor(context, _backgroundColor.CGColor);//填充颜色
    CGContextSetStrokeColorWithColor(context, _backgroundColor.CGColor);//线框颜色
    CGContextAddRect(context,frame);//画方框
    CGContextDrawPath(context, kCGPathFillStroke);//绘画路径
}
@end

