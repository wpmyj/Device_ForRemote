//
//  MHLMChartView.m
//  MiHome
//
//  Created by Lynn on 12/8/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLMLineChartView.h"

#define kHillSegmentWidth   2
#define BigScaleDuration    0.3
#define SmallScaleDuration  0.3

@interface MHLMLineChartView ()

@property (nonatomic,assign) CGFloat vTotalSpace;
//点之间的间隔距离
@property (nonatomic,assign,readonly) CGFloat hSpace;
//点数量
@property (nonatomic,assign) NSInteger hPoints;

@end

@implementation MHLMLineChartView
{
    CAShapeLayer *  _animatDot;
}

- (id)initWithFrame:(CGRect)frame chartDataArray:(NSArray *)chartDataArray {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _dataSource = [chartDataArray mutableCopy];
        _hPoints = chartDataArray.count;
        _vTotalSpace = CGRectGetHeight(frame);
    }
    return self;
}

- (void)setDataSource:(NSMutableArray *)dataSource {
    if(_dataSource != dataSource){
        _dataSource = dataSource;
        _hPoints = dataSource.count;
        if(_dataSource && _dataSource.count){
            [self setNeedsDisplay];
        }
    }
}

- (void)drawRect:(CGRect)rect {
    XM_WS(weakself);
    
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    if(!self.strokeColor){
        self.strokeColor = [UIColor colorWithRed:0.f green:1.f blue:1.f alpha:1.f];
    }

    //将坐标横向平分
    _hSpace = Screen_Width / _hPoints;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
    CGContextSetShouldAntialias(context, YES);
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSetFlatness(context, 0.1f);

    CGContextBeginPath(context);
    
    __block void (^foundFirstPointBlock)(CGPoint point0);
    foundFirstPointBlock = ^(CGPoint point0){
        //连续图像的上一个点
        if(weakself.lastPoint) point0 = CGPointMake(-0.5 * weakself.hSpace ,
                                                    weakself.vTotalSpace - weakself.lastPoint.doubleValue) ;
        CGContextMoveToPoint(context, point0.x, point0.y);
        
        //当前图像上的坐标点
        for (NSInteger i = 1; i < weakself.dataSource.count; i ++ ) {
            if(![weakself.dataSource[i-1] integerValue]){
                continue;
            }
            //转换纵向坐标
            CGPoint p0 = CGPointMake((i - 1) *  weakself.hSpace + weakself.hSpace * 0.5 ,
                                     weakself.vTotalSpace - [weakself.dataSource[i-1] doubleValue]) ;
            CGPoint p1 = CGPointMake(i *  weakself.hSpace + weakself.hSpace * 0.5 , weakself.vTotalSpace - [weakself.dataSource[i] doubleValue]);
            [weakself addLineToContext:context point1:p0 point2:p1];
            
            NSLog(@"p0 = (%f %f)",p0.x,p0.y);        NSLog(@"p1 = (%f %f)",p1.x,p1.y);
        }
        
        //为连续图像的下一个点
        if(weakself.nextPoint){
            CGPoint p0 = CGPointMake((weakself.hPoints - 0.5) * weakself.hSpace,
                                     weakself.vTotalSpace - [weakself.dataSource[weakself.hPoints - 1] doubleValue]) ;
            CGPoint p1 = CGPointMake((weakself.hPoints + 0.5) * weakself.hSpace,
                                     weakself.vTotalSpace - weakself.nextPoint.doubleValue);
            [weakself addLineToContext:context point1:p0 point2:p1];
        }
        CGContextStrokePath(context);
    };
    
    //获取第一个不为零的点，做为原点
    [_dataSource enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        if([obj integerValue]){
            CGPoint p0 = CGPointMake(idx *  weakself.hSpace + weakself.hSpace * 0.5 ,
                                     weakself.vTotalSpace - [weakself.dataSource[idx] doubleValue]) ;
            if (foundFirstPointBlock) foundFirstPointBlock(p0);
            *stop = YES;
        }
    }];
    
    //将节点画圆
    if(!_spotSize) _spotSize = 5.f;
    for (int i = 1; i <= _dataSource.count; i ++ ) {
        if([_dataSource[i-1] integerValue]){
            CGPoint pt = CGPointMake((i - 1) *  _hSpace + _hSpace * 0.5, _vTotalSpace - [_dataSource[i-1] doubleValue]) ;
            
            CAShapeLayer *dot = [[CAShapeLayer alloc] init];
            dot.frame = CGRectMake(pt.x - _spotSize * 0.5, pt.y - _spotSize * 0.5, _spotSize, _spotSize);
            dot.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, _spotSize, _spotSize)].CGPath;
            dot.fillColor = self.strokeColor.CGColor;
            [self.layer addSublayer:dot];
        }
    }
    [super drawRect:rect];
}

- (void)addLineToContext:(CGContextRef)context point1:(CGPoint )p0 point2:(CGPoint)p1 {
    int hSegments = floorf((p1.x - p0.x) / kHillSegmentWidth);
    float dx = (p1.x - p0.x) / hSegments;
    float da = M_PI / hSegments;
    float ymid = (p0.y + p1.y) / 2;
    float ampl = (p0.y - p1.y) / 2;
    
    CGPoint pt0,pt1;
    pt0 = p0;
    for (int j = 0; j < hSegments + 1; ++j) {
        pt1.x = p0.x + j * dx;
        pt1.y = ymid + ampl * cosf(da * j);
        CGContextAddLineToPoint(context, pt0.x, pt0.y);
        CGContextAddLineToPoint(context, pt1.x, pt1.y);
        pt0 = pt1;
    }
}

- (CGPoint)midPointWithPoint1:(CGPoint)p1 Point2:(CGPoint)p2 {
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

- (void)addSpotAnimation:(NSInteger)spotIdx {

    CGFloat biggerSpotSize = _spotSize * 3;
    CGPoint pt = CGPointMake((spotIdx - 0.5 ) * _hSpace, _vTotalSpace - [_dataSource[spotIdx - 1] doubleValue]) ;

    _animatDot = [[CAShapeLayer alloc] init];
    _animatDot.frame = CGRectMake(pt.x - biggerSpotSize * 0.5 , pt.y - biggerSpotSize * 0.5, biggerSpotSize, biggerSpotSize);
    _animatDot.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, biggerSpotSize, biggerSpotSize)].CGPath;
    _animatDot.fillColor = self.bigSpotColor.CGColor;
    [self.layer addSublayer:_animatDot];
    
    [_animatDot addAnimation:[self scaleAnimation:@"big" KeyPath:@"scaleBigAnimation"] forKey:@"scaleBigAnimation"];
}

- (void)removeSpotAnimation {
    if(_animatDot) {
        [_animatDot addAnimation:[self scaleAnimation:@"small" KeyPath:@"scaleSmallAnimation"] forKey:@"scaleSmallAnimation"];
        //因为动画播放完后又会自动回位，等delegate回调会看到返回原图，这里暂时先用这个方法。
        [_animatDot performSelector:@selector(removeFromSuperlayer) withObject:nil afterDelay:SmallScaleDuration - 0.1];
    }
}

//膨胀动画 direction : "big" "small"
-(CABasicAnimation *)scaleAnimation:(NSString *)direction KeyPath:(NSString *)keyPath {
    CABasicAnimation *scaleAnim = [[CABasicAnimation alloc] init];
    scaleAnim.keyPath = @"transform";
//    scaleAnim.delegate = self;
    [scaleAnim setValue:keyPath forKey:@"myAnimationKey"];
    
    CATransform3D t = CATransform3DIdentity;
    CATransform3D t2 = CATransform3DScale(t, 1.0, 1.0, 0.0);
    CATransform3D t3 = CATransform3DScale(t, 0.1, 0.1, 0.0);
    if ([direction isEqualToString:@"big"]){
        scaleAnim.fromValue = [NSValue valueWithCATransform3D: t3];
        scaleAnim.toValue = [NSValue valueWithCATransform3D: t2];
        scaleAnim.duration = BigScaleDuration;
    }
    else if ([direction isEqualToString:@"small"]){
        scaleAnim.fromValue = [NSValue valueWithCATransform3D: t2];
        scaleAnim.toValue = [NSValue valueWithCATransform3D: t3];
        scaleAnim.duration = SmallScaleDuration;
    }
    scaleAnim.autoreverses = false;
    scaleAnim.repeatCount = 0;
    
    return scaleAnim;
}

//- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
//    if ([[anim valueForKey:@"myAnimationKey"] isEqualToString:@"scaleSmallAnimation"] ){
//        _animatDot = nil;
//    }
//}

@end
