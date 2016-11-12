//
//  MHGatewayAlarmProgressView.m
//  MiHome
//
//  Created by guhao on 2/16/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayAlarmProgressView.h"


@interface MHGatewayAlarmProgressView ()

@property (nonatomic, strong) CAShapeLayer *completedLayer;
@property (nonatomic, assign) CGPoint allCenter;

@end

@implementation MHGatewayAlarmProgressView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self _defaultInit];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGFloat totalAngle = _endAngle - _startAngle;
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGFloat x0 = (rect.size.width - 2*_radius)/2.0 + _radius;
    CGFloat y0 = (rect.size.height - 2*_radius)/2.0 + _radius;
    
    CGContextSetLineJoin(contextRef, kCGLineJoinRound);
    CGContextSetFlatness(contextRef, 1.0);
    CGContextSetAllowsAntialiasing(contextRef, true);
    CGContextSetShouldAntialias(contextRef, true);
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationHigh);
    
    CGContextSetLineWidth(contextRef,2.0f);     //设置线条宽度
    
    for (int i = 0; i < _total; i++) {
        CGContextMoveToPoint(contextRef, x0, y0);
        
        CGFloat x = x0 + cosf(_startAngle + totalAngle*i/_total)*_radius;
        CGFloat y = y0 + sinf(_startAngle + totalAngle*i/_total)*_radius;
        
        CGContextAddLineToPoint(contextRef, x, y);
        CGContextSetStrokeColorWithColor(contextRef, _color.CGColor);   //设置颜色
        CGContextSetFillColorWithColor(contextRef, _color.CGColor);
        CGContextDrawPath(contextRef, kCGPathFillStroke);
        
    }
    
    for (int i = 0; i < _completed; i++) {
        
        CGContextMoveToPoint(contextRef, x0, y0);
        
        CGFloat x = x0 + cosf(_startAngle + totalAngle*i/_total)*_radius;
        CGFloat y = y0+ sinf(_startAngle + totalAngle*i/_total)*_radius;
        
        CGContextAddLineToPoint(contextRef, x, y);
        CGContextSetStrokeColorWithColor(contextRef, _completedColor.CGColor);  //设置完成颜色
        CGContextSetFillColorWithColor(contextRef, _completedColor.CGColor);
        CGContextDrawPath(contextRef, kCGPathFillStroke);
        
    }
    
    //画圆覆盖内部线条
    CGPoint centerPoint = CGPointMake(x0, y0);
    CGContextSetBlendMode(contextRef, kCGBlendModeClear);
    CGRect ellipseRect = CGRectMake(centerPoint.x - _innerRadius, centerPoint.y - _innerRadius, _innerRadius * 2, _innerRadius * 2);
    CGContextAddEllipseInRect(contextRef, ellipseRect);
    CGContextFillPath(contextRef);
    
    _allCenter = centerPoint;
    //开启警戒后,用圆环覆盖线条
    if (_completed == _total) {
        [self.layer addSublayer:self.completedLayer];
    }
    if (!_completed) {
        [self.completedLayer removeFromSuperlayer];
    }
}

#pragma mark - getter
- (CAShapeLayer *)completedLayer {
    if (_completedLayer == nil) {
        _completedLayer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:_allCenter radius:_innerRadius + kLineWidth / 2 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
        _completedLayer.fillColor = [UIColor clearColor].CGColor;//layer填充色
        _completedLayer.strokeColor = [UIColor whiteColor].CGColor;//layer边框色
        _completedLayer.lineWidth = kLineWidth + 1;//边框宽度内外等值伸展,+1防止边缘有部分覆盖不到
        _completedLayer.path = path.CGPath;
        
    }
    
    return _completedLayer;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self _defaultInit];
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self _defaultInit];
    }
    
    return self;
}

- (void)_defaultInit
{
    self.backgroundColor = [UIColor grayColor];
    self.opaque = YES;
    
    self.total = 180;
    self.color = [UIColor whiteColor];
    self.completed = 0;
    self.completedColor = [UIColor whiteColor];
    
    self.radius = 30.0;
    self.innerRadius = 20.0;
    self.startAngle = 0;
    self.endAngle = M_PI*2;
}


- (void)setTotal:(int)total
{
    _total = total;
}

- (void)setColor:(UIColor *)color
{
    _color = color;
}

- (void)setCompletedColor:(UIColor *)completedColor
{
    _completedColor = completedColor;
}

- (void)setCompleted:(int)completed
{
    _completed = completed;
    NSLog(@"已经完成的%d", _completed);
    [self setNeedsDisplay];
}


- (void)setRadius:(CGFloat)radius
{
    _radius = radius;
}

- (void)setInnerRadius:(CGFloat)innerRadius
{
    _innerRadius = innerRadius;
}

- (void)setPadding:(CGFloat)padding {
    _padding = padding;
}

- (void)setStartAngle:(CGFloat)startAngle
{
    _startAngle = startAngle;
}

- (void)setEndAngle:(CGFloat)endAngle
{
    _endAngle = endAngle;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *result = [super hitTest:point withEvent:event];
    if (result == self) {
        return nil;
    } else {
        return result;
    }
}


@end
