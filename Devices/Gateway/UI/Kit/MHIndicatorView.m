//
//  MHIndicatorView.m
//  MiHome
//
//  Created by Lynn on 7/28/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHIndicatorView.h"
#import <QuartzCore/QuartzCore.h>

@implementation MHIndicatorView
@synthesize color = _color;
@synthesize title = _title;

- (id) initWithFrame: (CGRect) frame
{
    self = [ super initWithFrame: frame ];
    
    if( self ) {
        self.opaque = YES;
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        self.layer.masksToBounds = NO;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(.1f, .1f);
        self.layer.shadowOpacity = 0.2f;
    }
    
    return self;
}

-(void)setColor:(UIColor*)color{
    if(![_color isEqual:color]){
        _color = color;
        [ self setNeedsDisplay ];
    }
}

-(void)setTitle:(NSString *)title{
    if ([_title isEqual:title]){
        _title = title;
        [self setNeedsDisplay];
    }
}

- (void) drawRect: (CGRect) rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPoint center = { CGRectGetMidX( self.bounds ), CGRectGetMidY( self.bounds ) };
    CGFloat radius = CGRectGetMidX( self.bounds );
    
    //颜色填充:
    CGContextAddArc(context, center.x, center.y, radius - 2.0f, 0.0f, 2.0f * (float) M_PI, YES );
    [self.color setFill];
    CGContextFillPath( context );
    
    //内圈:(填充)
    CGContextAddArc( context, center.x, center.y, radius - 2.0f, 0.0f, 2.0f * (float) M_PI, YES );
    CGContextSetGrayStrokeColor( context, 0.0f, 0.5f );
    CGContextSetLineWidth( context, 2.0f );
    CGContextStrokePath( context );
    
    //外圈:(白色)
    CGContextAddArc( context, center.x, center.y, radius - 2.0f, 0.0f, 2.0f * (float) M_PI, YES );
    CGContextSetGrayStrokeColor( context, 1.f, 1.f );
    CGContextSetLineWidth( context, 2.0f );
    CGContextStrokePath( context );
}

@end
