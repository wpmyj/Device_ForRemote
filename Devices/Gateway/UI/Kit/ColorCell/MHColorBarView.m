//
//  MHColorBarView.m
//  MiHome
//
//  Created by Lynn on 7/28/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHColorBarView.h"
#import "MHIndicatorView.h"
#import "InfHSBSupport.h"

@implementation MHColorBarView

//---------------------------------------------------------------------
/*!
 *  @author Zechen Liu, 15-07-28 19:07:08
 *
 *  @brief  彩虹条
 */
static CGImageRef createContentImage()
{
    float hsv[] = { 0.0f, 1.0f, 1.0f };
    return createHSVBarContentImage( InfComponentIndexHue, hsv );
}

- (void) drawRect: (CGRect) rect
{
    CGImageRef image = createContentImage();
    
    if( image ) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawImage( context, self.bounds, image );
        CGImageRelease(image);
    }
}
@end

//---------------------------------------------------------------------

@implementation MHGatewayPickColorView
{
    CGFloat _curValue;
    MHIndicatorView* _indicator;
    MHColorBarView * _colorBar;
}
@synthesize value = _value;

-(void)setValue:(CGFloat)value
{
    if (_value != value){
        _value = value;
        [self sendActionsForControlEvents: UIControlEventValueChanged];
        [self setNeedsLayout ];
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    if (_colorBar == nil){
        _colorBar = [[MHColorBarView alloc] initWithFrame:CGRectMake(self.barStartXPoint, self.frame.size.height / 2, self.frame.size.width - self.barStartXPoint * 2 - 10, 2)];
        _colorBar.layer.masksToBounds = YES;
        _colorBar.layer.cornerRadius = 1.0;
        [self addSubview:_colorBar];
    }
    
    UIImage *indicatorImage = [UIImage imageNamed:@"gateway_slider_thumb"];
    CGFloat kIndicatorSize = indicatorImage.size.width;
    if( _indicator == nil ) {
        _indicator = [[MHIndicatorView alloc] initWithFrame:CGRectMake(0, 0, kIndicatorSize, kIndicatorSize)];
        [self addSubview: _indicator];
    }
    
    CGFloat indicatorLoc = kIndicatorSize + (self.value * (_colorBar.frame.size.width - kIndicatorSize/2));
    _indicator.center = CGPointMake(indicatorLoc, CGRectGetMidY(self.bounds));
    _indicator.color = [self setupRGBColor];
}

- (UIColor *)setupRGBColor
{
    UIColor *c = [UIColor clearColor];
    
    //处理人为添加的白色区域（含过度区域）
    if( self.value * 256.0 > 44.0 && self.value * 256.0 <= 54.0 ){
        c = [UIColor colorWithHue:self.value saturation: self.value
                       brightness: 1.0f alpha: 1.0f ];
    }
    else if(self.value > 54.0 / 256.0 && self.value < 60.0 / 256.0) {
        c = [UIColor whiteColor];
    }
    else if ( self.value * 256.0 >= 60.0 && self.value * 256.0 < 70.0 ){
        c = [UIColor colorWithHue:self.value saturation: self.value
                       brightness: 1.0f alpha: 1.0f ];
    }
    else{
        c = [UIColor colorWithHue:self.value saturation: 1.0f
                   brightness: 1.0f alpha: 1.0f ];
    }
    
    return c;
}

-(NSInteger)fetchColorFromRGB:(UIColor *)color
{
    return [MHColorUtils rgbFromColor:color];
}

#pragma mark - Tracking
- (void) trackIndicatorWithTouch: (UITouch*) touch
{
    float percent = ( [ touch locationInView: self ].x - self.barStartXPoint)
    / _colorBar.bounds.size.width;
    
    self.value = pin( 0.0f, percent, 1.0f );
}


- (BOOL) beginTrackingWithTouch: (UITouch*) touch
                      withEvent: (UIEvent*) event
{
    [self trackIndicatorWithTouch: touch ];
    return YES;
}

- (BOOL) continueTrackingWithTouch: (UITouch*) touch
                         withEvent: (UIEvent*) event
{
    [ self trackIndicatorWithTouch: touch ];
    return YES;
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    NSInteger rgbValue = [self fetchColorFromRGB:[self setupRGBColor]];
    if (self.callbackBlock) {
        self.callbackBlock(rgbValue);
    }
}

@end
