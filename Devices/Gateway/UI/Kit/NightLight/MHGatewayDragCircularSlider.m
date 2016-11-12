//
//  MHGatewayDragCircularSlider.m
//  MiHome
//
//  Created by guhao on 2/18/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayDragCircularSlider.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import <MiHomeKit/XMCoreMacros.h>
#import "MHGatewayNightCircleColorView.h"




@interface MHGatewayDragCircularSlider ()
@property (nonatomic, strong) MHDeviceGateway *gateway;
@property (nonatomic, strong) UIImageView *countdownImageView;



@property (nonatomic, strong) UIColor *currentColor;
@property (nonatomic, assign) CGPoint currentPoint;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic) int angle;//初始值
@property (nonatomic, assign) NSInteger currentRGB;//当前角度
@property (nonatomic, assign) CGPoint beginPoint;

@property (nonatomic, assign) BOOL errorBegin;

@end

@implementation MHGatewayDragCircularSlider{
    CGFloat _outRadius;
    CGFloat _radius;
}
@synthesize initialAngleInt = _initialAngleInt;


- (id)initWithFrame:(CGRect)frame sensor:(MHDeviceGateway *)gateway
{
    self = [super initWithFrame:frame];
    if (self) {
        // Defaults
        _gateway = gateway;
        _currentValue = 0.0f;
        _unfilledColor = [UIColor clearColor];
        _angle = 225;
        _outRadius = self.frame.size.height/2;
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

-(void)setInitialAngleInt:(int)initialAngleInt
{
    _initialAngleInt = initialAngleInt;
    
    //Initialize angle
    [self caculateCurrentAngle:_initialAngleInt];
    //Redraw
    [self setNeedsDisplay];
}



#pragma mark - drawing methods
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
  
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //Draw the unfilled circle
    CGContextAddArc(ctx, rect.size.width/2, rect.size.height/2, _outRadius, M_PI_4, M_PI_4 + M_PI_2, 1);
    [_unfilledColor setStroke];
    
    CGContextDrawPath(ctx, kCGPathStroke);
    
    //The draggable part
    [self drawHandle:ctx inRect:rect]; // 拖动的按钮小圆
    
  
}

-(void) drawHandle:(CGContextRef)ctx inRect:(CGRect)rect{
    CGContextSaveGState(ctx);
    CGPoint handleCenter =  [self pointFromAngle: _angle inRect:rect];
    
    [self setArrowDirection:(CGFloat)((_angle /180.0f)* M_PI) center:CGPointMake(handleCenter.x, handleCenter.y) context:(CGContextRef)ctx];
}

// 修改小按钮的旋转方向
- (void)setArrowDirection:(CGFloat)angle center:(CGPoint)center context:(CGContextRef)ctx
{
    int miniRaduis = kThumbRadius;
    if (!_countdownImageView)
    {
        _countdownImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-miniRaduis, -miniRaduis, miniRaduis*2, miniRaduis*2)];
        [self addSubview:_countdownImageView];
    }
    _countdownImageView.contentMode = UIViewContentModeCenter; // 图片不缩放
    _countdownImageView.backgroundColor = [UIColor clearColor];
    _countdownImageView.image = [UIImage imageNamed:_countdownImageName];
    _countdownImageView.center = center;
    _countdownImageView.transform = CGAffineTransformMakeRotation(M_PI - angle);
    
     //去除小拖动圆按钮的中心背景,只去除图片的部分,整体热区比图片稍微大 5 * ScaleWidth
    int imageRaduis = kThumbRadius - kThumbPadding;
    CGContextSetBlendMode(ctx, kCGBlendModeClear);
    CGContextAddEllipseInRect(ctx, CGRectMake(_countdownImageView.center.x - imageRaduis, _countdownImageView.center.y - imageRaduis, imageRaduis * 2, imageRaduis * 2));
    CGContextFillPath(ctx);
}
#if 0

#pragma mark - UIControl functions
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super beginTrackingWithTouch:touch withEvent:event];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];
    CGPoint lastPoint = [touch locationInView:self];
    //响应区域为imageview,减少手势冲突
    if (CGRectContainsPoint(self.countdownImageView.frame, lastPoint)) {
        //Get the center
        CGPoint centerPoint = CGPointMake(self.frame.size.width/2, (self.frame.size.height - kSpacing)/2 + kSpacing);
        //Calculate the direction from a center point and a arbitrary position.
        float currentAngle = AngleFromNorth(centerPoint, lastPoint, NO);
        int angleInt = floor(currentAngle);
        //过滤缺口处的touch事件
        if (angleInt > 45 && angleInt < 135) {
        }
        else {
            [self moveHandle:angleInt];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
    return YES;
    
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
    CGPoint beginPoint = [touch locationInView:self];
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, (self.frame.size.height - kSpacing)/2 + kSpacing);
    //Calculate the direction from a center point and a arbitrary position.
    float currentAngle = AngleFromNorth(centerPoint, beginPoint, NO);
    int angleInt = floor(currentAngle);
    if (angleInt > 45 && angleInt < 135) {
    }
    else {
        if (_lastTouchCallback) {//36351 // 65421
            _lastTouchCallback(_currentRGB);
        }
    }

}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [super cancelTrackingWithEvent:event];
    
}
#endif
#if 1

#pragma mark - UITouch events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
 
    UITouch *touch = [[touches allObjects] lastObject];
//        UITouch *touch = [touches anyObject];
    CGPoint lastPoint = [touch locationInView:self];
    //响应区域为imageview,减少手势冲突
    if (CGRectContainsPoint(self.countdownImageView.frame, lastPoint)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NightTouchesBegan" object:nil];
    }
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, (self.frame.size.height - kSpacing)/2 + kSpacing);
    float currentAngle = AngleFromNorth(centerPoint, lastPoint, NO);
    int angleInt = floor(currentAngle);
    //过滤缺口处的touch事件
    if (angleInt > 45 && angleInt < 135) {
        self.errorBegin = YES;
    }
    else {
        self.errorBegin = NO;
    }

}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[touches allObjects] lastObject];

//    UITouch *touch = [touches anyObject];
    CGPoint lastPoint = [touch locationInView:self];
    //响应区域为imageview,减少手势冲突
    if (CGRectContainsPoint(self.countdownImageView.frame, lastPoint)) {
        //Get the center
        CGPoint centerPoint = CGPointMake(self.frame.size.width/2, (self.frame.size.height - kSpacing)/2 + kSpacing);
        //Calculate the direction from a center point and a arbitrary position.
        float currentAngle = AngleFromNorth(centerPoint, lastPoint, NO);
        int angleInt = floor(currentAngle);
        //过滤缺口处的touch事件
        if (angleInt > 45 && angleInt < 135) {
        }
        else {
            [self moveHandle:angleInt];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }

}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {


    [[NSNotificationCenter defaultCenter] postNotificationName:@"NightTouchesEnded" object:nil];
    if (!self.errorBegin) {
        if (_lastTouchCallback) {//36351 // 65421
            _lastTouchCallback(_currentRGB);
        }
    }
  
//    UITouch *touch = [[touches allObjects] lastObject];
//    UITouch *touch = [touches anyObject];
//    CGPoint lastPoint = [touch locationInView:self];
//    if (CGRectContainsPoint(self.countdownImageView.frame, lastPoint)) {
    
//    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, (self.frame.size.height - kSpacing)/2 + kSpacing);
    //Calculate the direction from a center point and a arbitrary position.
//    float currentAngle = AngleFromNorth(centerPoint, lastPoint, NO);
//    int angleInt = floor(currentAngle);
//    if (angleInt > 45 && angleInt < 90) {
//        
//    }
//    else if (angleInt >= 90 && angleInt < 135) {
//        
//    }
//    else {
//        if (_lastTouchCallback) {//36351 // 65421
//            _lastTouchCallback(_currentRGB);
//        }
//    }
//    }

}


- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    [[NSNotificationCenter defaultCenter] postNotificationName:@"NightTouchesCancelled" object:nil];

}
#endif

- (void)moveHandle:(int)angleInt {
//       NSLog(@"aefaefaefaefaefaefaefaefaefa>>>>>>>>>>%d", angleInt);
    [self caculateCurrentAngle:angleInt];
    if (_currentRGBCallBack) {
        _currentRGBCallBack(_currentRGB);
    }
}



#pragma mark - helper functions
-(CGPoint)pointFromAngle:(int)angleInt inRect:(CGRect) rect{
    
    //Define the Circle center
    CGPoint centerPoint = CGPointMake(rect.size.width/2, rect.size.height/2);
    
    //Define The point position on the circumference
    CGPoint result;
    result.y = round(centerPoint.y + _outRadius * sin(ToRad(-angleInt))) ;
    result.x = round(centerPoint.x + _outRadius * cos(ToRad(-angleInt)));
    
    return result;
}


static inline float AngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y,v.x);
    result = ToDeg(radians);
    return (result >=0  ? result : result + 360.0);
}

- (void)caculateCurrentAngle:(int)angleInt {
    _currentRGB = [self getRgbWithAngle:angleInt];
    if(angleInt <= 45 || angleInt >= 135){
        //Store the new angle
        self.angle = 360 - angleInt;
        
        //Redraw
        [self setNeedsDisplay];
    }
 
}

#pragma mark - 滑块滑动的位置的颜色
- (NSInteger)getRgbWithAngle:(NSInteger)angle
{
    int r = 0;
    int g = 0;
    int b = 0;
    if ( angle >= 135 && angle < 180) {
        //r == 255 && g == 255 && b <= 255 //白->黄//b递减
        r = 255;
        g = 255;
        b = (int)((180 - angle) * 255 / kRadian);
        
    }
    else if (angle >= 180 && angle < 225) {
        //r == 255 && g <= 255 && b == 0 ////黄->红//g递减
        r = 255;
        g = (int)((225 - angle) * 255 / kRadian);
        b = 0;
    }
    else if (angle > 225 && angle < 270) {
        //r == 255 && g == 0 && b <= 255 //红->粉红//b递增
        r = 255;
        g = 0;
        b = (int)((270 - angle) * 255 / kRadian);
    }
    else if (angle > 270 && angle < 315) {
        //r <= 255 && g == 0 && b == 255 粉红到蓝色//r递减
        r = (int)((315 - angle) * 255 / kRadian);
        g = 0;
        b = 255;
    }
    else if (angle > 315 && angle <= 360) {
       // r == 0 && g <= 255 && b == 255 //蓝色到天蓝//g递增
        r = 0;
        g = (int)((angle - 315) * 255 / kRadian);
        b = 255;
    }
    else if (angle >= 0 && angle <= 45) {
        //r == 0 && g == 255 && b <= 255 //天蓝到绿色//b值递减
        r = 0;
        g = 255;
        b = (int)((45 - angle) * 255 / kRadian);
    }
    if (r == 0 && g == 0  && b == 0) {
        r = 255;
        g = 0;
        b = 255;
    }
    _currentRGB = [MHColorUtils rgbFromR:r g:g b:b];
//    NSLog(@"当前的颜色值%ld, r%d, g%d, b%d", _currentRGB, r, g, b);
    return _currentRGB;
}


//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    UIView *result = [super hitTest:point withEvent:event];
//    if ([result isKindOfClass:[UIImageView class]]) {
//        return nil;
//    } else {
//        return result;
//    }
//}


@end
