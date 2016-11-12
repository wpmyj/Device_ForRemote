//
//  MHACPartnerCircleView.m
//  MiHome
//
//  Created by ayanami on 16/5/19.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerCircleView.h"
#define kGap (M_PI/16)
#define kArrowOffset (120.0f)

@implementation MHACPartnerCircleView
{
    BOOL _isScaledUp;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.radius = frame.size.width / 2;
        self.circle = [CAShapeLayer layer];
        self.circle.fillColor = nil;
        self.circle.strokeColor = [MHColorUtils colorWithRGB:0xffffff alpha:0.4].CGColor;
        self.circle.lineWidth = 1;
        self.circle.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        UIBezierPath *path = [UIBezierPath  bezierPathWithArcCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2) radius:self.radius startAngle:(-M_PI/2 + kGap) endAngle:(M_PI/2 - kGap) clockwise:YES];
        [path appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2) radius:self.radius startAngle:(M_PI/2 + kGap) endAngle:(3*M_PI/2 - kGap) clockwise:YES]];
        UIBezierPath *triangle = [UIBezierPath bezierPath];
        [triangle moveToPoint:CGPointMake(self.frame.size.width / 2 + 0.5, 0)];
        [triangle addLineToPoint:CGPointMake(self.frame.size.width / 2 - 10.0f,  10.0f)];
        [triangle moveToPoint:CGPointMake(self.frame.size.width / 2 - 0.5, 0)];
        [triangle addLineToPoint:CGPointMake(self.frame.size.width / 2 + 10.0f,  10.0f)];
        [path appendPath:triangle];
        
        UIBezierPath *triangle2 = [UIBezierPath bezierPath];
        [triangle2 moveToPoint:CGPointMake(self.frame.size.width / 2 + 0.5, self.frame.size.height)];
        [triangle2 addLineToPoint:CGPointMake(self.frame.size.width / 2 - 10.0f,  self.frame.size.height - 10.0f)];
        [triangle2 moveToPoint:CGPointMake(self.frame.size.width / 2 - 0.5, self.frame.size.height)];
        [triangle2 addLineToPoint:CGPointMake(self.frame.size.width / 2 + 10.0f,  self.frame.size.height - 10.0f)];
        [path appendPath:triangle2];
        
        self.circle.path = path.CGPath;
        [self.layer addSublayer:self.circle];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (CAAnimation*)pathAnimation:(float) newRadius;
{
    UIBezierPath *newPath = [UIBezierPath  bezierPathWithArcCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2) radius:newRadius startAngle:(-M_PI/2 + kGap) endAngle:(M_PI/2 - kGap) clockwise:YES];
    [newPath appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2) radius:newRadius startAngle:(M_PI/2 + kGap) endAngle:(3*M_PI/2 - kGap) clockwise:YES]];
    UIBezierPath *triangle = [UIBezierPath bezierPath];
    [triangle moveToPoint:CGPointMake(self.frame.size.width / 2 + 0.5, kArrowOffset - newRadius / self.radius * kArrowOffset)];
    [triangle addLineToPoint:CGPointMake(self.frame.size.width / 2 - 10.0f,  10.0f + kArrowOffset - newRadius / self.radius * kArrowOffset)];
    [triangle moveToPoint:CGPointMake(self.frame.size.width / 2 - 0.5, kArrowOffset - newRadius / self.radius * kArrowOffset)];
    [triangle addLineToPoint:CGPointMake(self.frame.size.width / 2 + 10.0f,  10.0f + kArrowOffset - newRadius / self.radius * kArrowOffset)];
    [newPath appendPath:triangle];
    
    UIBezierPath *triangle2 = [UIBezierPath bezierPath];
    [triangle2 moveToPoint:CGPointMake(self.frame.size.width / 2 + 0.5, self.frame.size.height - kArrowOffset + newRadius / self.radius * kArrowOffset)];
    [triangle2 addLineToPoint:CGPointMake(self.frame.size.width / 2 - 10.0f,  self.frame.size.height - 10.0f - kArrowOffset + newRadius / self.radius * kArrowOffset)];
    [triangle2 moveToPoint:CGPointMake(self.frame.size.width / 2 - 0.5, self.frame.size.height - kArrowOffset + newRadius / self.radius * kArrowOffset)];
    [triangle2 addLineToPoint:CGPointMake(self.frame.size.width / 2 + 10.0f,  self.frame.size.height - 10.0f - kArrowOffset + newRadius / self.radius * kArrowOffset)];
    [newPath appendPath:triangle2];
    
    CGRect newBounds = CGRectMake(0, 0, self.frame.size.width, 2 * self.frame.size.height);
    
    CABasicAnimation* pathAnim = [CABasicAnimation animationWithKeyPath: @"path"];
    pathAnim.toValue = (id)newPath.CGPath;
    
    CABasicAnimation* boundsAnim = [CABasicAnimation animationWithKeyPath: @"frame"];
    boundsAnim.toValue = [NSValue valueWithCGRect:newBounds];
    
    CAAnimationGroup *anims = [CAAnimationGroup animation];
    anims.animations = [NSArray arrayWithObjects:pathAnim, boundsAnim, nil];
    anims.removedOnCompletion = NO;
    anims.duration = 0.3f;
    anims.fillMode  = kCAFillModeForwards;
    anims.delegate = self;
    return anims;
}

- (void)animScaleUp
{
    if (_isScaledUp)
    {
        return;
    }
    _isScaledUp = YES;
    [self.circle addAnimation:[self pathAnimation:self.frame.size.width * ([UIScreen mainScreen].bounds.size.height > 600 ? 0.8f : 0.6f)] forKey:@"scaleup"];
}

- (void)animScaleDown
{
    _isScaledUp = NO;
    CAAnimation *group = [self pathAnimation:self.frame.size.width / 2];
    [self.circle addAnimation:group  forKey:@"scaledown"];
}

@end
