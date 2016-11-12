//
//  MHLumiPopoverSlider.m
//  MiHome
//
//  Created by guhao on 2/26/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLumiPopoverSlider.h"


#define kSpacing 5 //浮标与滑块间距

@implementation MHLumiPopoverSlider
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self constructSlider];
    }
    return self;
}

- (void)dealloc{
    [_windowPopupView removeFromSuperview];
    _windowPopupView = nil;
}

#pragma mark - UIControl touch event tracking
-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    // Fade in and update the popup view
    CGPoint touchPoint = [touch locationInView:self];
    
    // Check if the knob is touched. If so, show the popup view
    if(CGRectContainsPoint(CGRectInset(self.thumbRect, -12.0, -12.0), touchPoint)) {
        [self positionAndUpdatePopupView];
        [self fadePopupViewInAndOut:YES];
    }
    
    return [super beginTrackingWithTouch:touch withEvent:event];
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    // Update the popup view as slider knob is being moved
    [self positionAndUpdatePopupView];
    return [super continueTrackingWithTouch:touch withEvent:event];
}

-(void)cancelTrackingWithEvent:(UIEvent *)event {
    [self fadePopupViewInAndOut:NO];
    [super cancelTrackingWithEvent:event];
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    // Fade out the popup view
    [self fadePopupViewInAndOut:NO];
    [super endTrackingWithTouch:touch withEvent:event];
}

#pragma mark - Helper methods
-(void)constructSlider {
    _popupView = [[MHGatewayPopupView alloc] initWithFrame:CGRectZero];
    _popupView.backgroundColor = [UIColor clearColor];
    _popupView.hidden = YES;
    [self addSubview:_popupView];
    
        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate.window addSubview:self.windowPopupView];
}

- (MHGatewayPopupView *)windowPopupView {
    if (_windowPopupView == nil) {
        _windowPopupView = [[MHGatewayPopupView alloc] initWithFrame:CGRectZero];
        _windowPopupView.backgroundColor = [UIColor clearColor];
        _windowPopupView.alpha = 0.0f;
    }
    return _windowPopupView;
}

-(void)fadePopupViewInAndOut:(BOOL)animated {
    XM_WS(weakself);
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            weakself.windowPopupView.alpha = 1.0;
        }];
    } else {
        weakself.windowPopupView.alpha = 0.0;
    }
}

-(void)positionAndUpdatePopupView {
    CGRect zeThumbRect = self.thumbRect;
    CGRect popupViewRect = CGRectMake(zeThumbRect.origin.x - kPopupWidth / 5, zeThumbRect.origin.y - kPopupHeight - kSpacing, kPopupWidth, kPopupHeight);
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    //坐标转换
    CGRect windowRect = [_popupView convertRect:popupViewRect toView:delegate.window];
    _windowPopupView.frame = windowRect;
    _windowPopupView.value = self.value;
}


#pragma mark - Property accessors
-(CGRect)thumbRect {
    CGRect trackRect = [self trackRectForBounds:self.bounds];
    CGRect thumbR = [self thumbRectForBounds:self.bounds trackRect:trackRect value:self.value];
    return thumbR;
}

@end
