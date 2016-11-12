//
//  TBCircularSlider.m
//  MiHome
//
//  Created by Lynn on 8/3/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "XBCircularSlider.h"

/** Helper Functions **/
#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )

/** Parameters **/
#define XB_SAFEAREA_PADDING (XB_RADIUSOFFSIZE + 11)


#pragma mark - Private -

@interface XBCircularSlider(){
//    UITextField *_textField;
    int radius;
}
@property (nonatomic,assign) int angle;
@end


#pragma mark - Implementation -

@implementation XBCircularSlider
@synthesize initialValue = _initialValue;

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if(self){
        self.opaque = NO;
        
        //Define the circle radius taking into account the safe area
        radius = self.frame.size.width/2 - XB_SAFEAREA_PADDING;
        self.angle = 225;
    }
    
    return self;
}

-(void)setInitialValue:(int)initialValue
{
    _initialValue = initialValue;
    
    //Initialize angle
    float tmp = self.initialValue / 100.0 * 271 - 1;
    if(self.initialValue == 1 || self.initialValue == 0)
        self.angle = 225;
    
    if ( tmp >= 0 && tmp <= 225){
        self.angle = 360 - tmp - 135;
    }
    else if (tmp > 225 && tmp <=270){
        self.angle = 360 - tmp + 225;
    }
    
    //Redraw
    [self setNeedsDisplay];
}

#pragma mark - UIControl Override -

/** Tracking is started **/
-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super beginTrackingWithTouch:touch withEvent:event];
    
    //We need to track continuously
    return YES;
}

/** Track continuos touch event (like drag) **/
-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super continueTrackingWithTouch:touch withEvent:event];

    //Get touch location
    CGPoint lastPoint = [touch locationInView:self];

    //Use the location to design the Handle
    [self movehandle:lastPoint];
    
    //Control value has changed, let's notify that   
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    return YES;
}

/** Track is finished **/
-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
    
    //设置最终值的返回调用
    if (self.callbackBlock) {
        self.callbackBlock(self.callBackResult);
    }
}


#pragma mark - Drawing Functions - 

//Use the draw rect to draw the Background, the Circle and the Handle 
-(void)drawRect:(CGRect)rect{
    
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
/** Draw the Background **/
    
    //Create the path
//    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, M_PI, M_PI *2, 0);
    CGContextAddArc(ctx, self.frame.size.width/2 - XB_RADIUSOFFSIZE, self.frame.size.height/2 - XB_RADIUSOFFSIZE, radius, M_PI_2 + M_PI_4, M_PI_4, 0);
    
    //Set the stroke color
    [[UIColor colorWithWhite:1.0 alpha:.2] setStroke];
    
    //Define line width and cap
    CGContextSetLineWidth(ctx, XB_BACKGROUND_WIDTH);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    
    //draw it!
    CGContextDrawPath(ctx, kCGPathStroke);
    
   
//** Draw the circle (using a clipped gradient) **/
    
    /** Create THE MASK Image **/
    UIGraphicsBeginImageContext(CGSizeMake(XB_SLIDER_SIZE,XB_SLIDER_SIZE));
    CGContextRef imageCtx = UIGraphicsGetCurrentContext();

    CGContextAddArc(imageCtx, self.frame.size.width/2 - XB_RADIUSOFFSIZE , self.frame.size.height/2+XB_RADIUSOFFSIZE, radius, ToRad(self.angle), M_PI_4 - M_PI,0);
    [[UIColor redColor]set];
    
    //Use shadow to create the Blur effect
//    CGContextSetShadowWithColor(imageCtx, CGSizeMake(0, 0), self.angle/20, [UIColor blackColor].CGColor);
    
    //define the path
    CGContextSetLineWidth(imageCtx, XB_LINE_WIDTH);
    CGContextDrawPath(imageCtx, kCGPathStroke);
    
    //save the context content into the image mask
    CGImageRef mask = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
    UIGraphicsEndImageContext();
    
    
    /** Clip Context to the mask **/
    CGContextSaveGState(ctx);
    
    CGContextClipToMask(ctx, self.bounds, mask);
    CGImageRelease(mask);
    
    
    /** THE GRADIENT **/
//    
//    //list of components
//    CGFloat components[8] = {
//        0.0, 0.0, 1.0, 1.0,     // Start color - Blue
//        1.0, 0.0, 1.0, 1.0 };   // End color - Violet
//  都用白色啦
    CGFloat components[8] = {
        1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0, 1.0 };
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, components, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    //Gradient direction
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    //Draw the gradient
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
    
    CGContextRestoreGState(ctx);
    
/** Draw the handle **/
    [self drawTheHandle:ctx];
}

/** Draw a white knob over the circle **/
-(void) drawTheHandle:(CGContextRef)ctx{
    
    CGContextSaveGState(ctx);
    
    //I Love shadows
//    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 1, [UIColor lightGrayColor].CGColor);
    
    //Get the handle position
    CGPoint handleCenter =  [self pointFromAngle: self.angle];
    
    //Draw It!
    [[UIColor colorWithWhite:1.0 alpha:1]set];
    CGContextFillEllipseInRect(ctx, CGRectMake(handleCenter.x - XB_HANDSIZE/2, handleCenter.y - XB_HANDSIZE/2, XB_HANDSIZE, XB_HANDSIZE));
    
    CGContextRestoreGState(ctx);
}

#pragma mark - Math -

/** Move the Handle **/
-(void)movehandle:(CGPoint)lastPoint{
    
    //Get the center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    //Calculate the direction from a center point and a arbitrary position.
    float currentAngle = AngleFromNorth(centerPoint, lastPoint, NO);
    int angleInt = floor(currentAngle);
    
    if(angleInt <= 45 || angleInt >= 135){
        //Store the new angle
        self.angle = 360 - angleInt;
        
//        NSLog(@"angleInt = %d",angleInt);

        self.callBackResult = self.angle;
        if (angleInt >= 135){
            self.callBackResult = 225 - self.angle;
        }
        else if (angleInt <= 45){
            self.callBackResult = 225 + angleInt;
        }
        self.callBackResult = (self.callBackResult + 1) / 271.0 * 100.0;
        if (self.callBackResult == 0) self.callBackResult = 1;
                
        //Redraw
        [self setNeedsDisplay];
    }
}

/** Given the angle, get the point position on circumference **/
-(CGPoint)pointFromAngle:(int)angleInt{
    
    //Circle center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2 - XB_RADIUSOFFSIZE - XB_LINE_WIDTH/2, self.frame.size.height/2 - XB_RADIUSOFFSIZE - XB_LINE_WIDTH/2);
    
    //The point position on the circumference
    CGPoint result;
    result.y = round(centerPoint.y + radius * sin(ToRad(-angleInt))) ;
    result.x = round(centerPoint.x + radius * cos(ToRad(-angleInt)));
    
    return result;
}

//Sourcecode from Apple example clockControl 
//Calculate the direction in degrees from a center point to an arbitrary position.
static inline float AngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y,v.x);
    result = ToDeg(radians);
    return (result >=0  ? result : result + 360.0);
}

@end


