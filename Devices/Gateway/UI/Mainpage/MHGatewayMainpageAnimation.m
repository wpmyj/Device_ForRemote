//
//  MHGatewayMainpageAnimation.m
//  MiHome
//
//  Created by Lynn on 2/24/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayMainpageAnimation.h"

@implementation MHGatewayMainpageAnimation
{
    //view animation
    CATransition *              _animation;
    //color animation
    CABasicAnimation *          _currentAnimation;
    NSMutableArray *            _colorAnimationArray;
    NSMutableArray *            _reversColorAnimationArray;
}

#pragma mark - view animation Gesture Recognizer
- (void)homeVCAddGestureRecognizer {
    _swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    [_swipeRight setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.homeVC.view addGestureRecognizer:_swipeRight];
    _swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    [_swipeLeft setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.homeVC.view addGestureRecognizer:_swipeLeft];
}

- (void)homeVCRemovewGestureRecognizer {
    [self.homeVC.view removeGestureRecognizer:_swipeLeft];
    [self.homeVC.view removeGestureRecognizer:_swipeRight];

}
- (void)swiped:(UISwipeGestureRecognizer *)sender {
    NSInteger total = _subViewArray.count;
    NSInteger current = self.currentIndex;
    NSInteger next = 0;
    
    AnimationDirection direction = Direction_Left;
    if(sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        next = current + 1;
        direction = Direction_Left;
    }
    else if(sender.direction == UISwipeGestureRecognizerDirectionRight) {
        next = current - 1;
        direction = Direction_Right;
    }
    
    if (next < total && next >= 0){
        self.currentIndex = next;
        [self animateViewChange:direction withIndex:next];
        if(self.onClickCurrentIndex) self.onClickCurrentIndex(next);
    }
    else if(next == -1){
        if(self.leftAnimationEndCallBack) self.leftAnimationEndCallBack();
    }
}

#pragma mark : animation
- (void)animateViewChange:(AnimationDirection)direction withIndex:(NSInteger)index {
    _animation = [[CATransition alloc] init];
    _animation.duration = TransTime;
    _animation.timingFunction = [CAMediaTimingFunction  functionWithName: kCAMediaTimingFunctionEaseOut ];
    _animation.type = kCATransitionPush;

    NSInteger total = _subViewArray.count;
    
    if (direction == Direction_Left) {
        _animation.subtype = kCATransitionFromRight;
        for(int i = 0 ; i < total ; i ++){
            if(index == i){
                [[self.subViewArray[i - 1] layer] addAnimation:_animation forKey:nil];
                [[self.subViewArray[i] layer] addAnimation:_animation forKey:nil];
            }
        }
    }
    else if (direction == Direction_Right){
        _animation.subtype = kCATransitionFromLeft;
        for(int i = 0 ; i < total ; i ++){
            if(index == i){
                [[self.subViewArray[i] layer] addAnimation:_animation forKey:nil];
                [[self.subViewArray[i + 1] layer] addAnimation:_animation forKey:nil];
            }
        }
    }
}

#pragma mark - color animation 
- (void)headerViewBackgroundColorAnimation:(AnimationDirection)direction progress:(CGFloat)progress{
    if (direction == Direction_Left){
        [self fetchColorAnimation:_currentPage];
    }
    else if (direction == Direction_Right) {
        [self fetchReverseAnimation:_currentPage];
    }
    self.headerView.layer.timeOffset = progress;
    self.headerBufferView.layer.timeOffset = progress;
}

- (void)fetchColorAnimation:(NSInteger)index {
    CABasicAnimation *colorAnimation = _colorAnimationArray[index];
    if(_currentAnimation != colorAnimation){
        [self.headerView.layer removeAllAnimations];
        [self.headerBufferView.layer removeAllAnimations];
        [self.headerView.layer addAnimation:colorAnimation forKey:@"color animation"];
        [self.headerBufferView.layer addAnimation:colorAnimation forKey:@"color animation"];
        self.headerView.layer.speed = 0.0;
        self.headerBufferView.layer.speed = 0.0;
        _currentAnimation = colorAnimation;
    }
}

- (void)fetchReverseAnimation:(NSInteger)index {
    CABasicAnimation *colorAnimation = _reversColorAnimationArray[index];
    if(_currentAnimation != colorAnimation){
        [self.headerView.layer removeAllAnimations];
        [self.headerBufferView.layer removeAllAnimations];
        [self.headerView.layer addAnimation:colorAnimation forKey:@"color animation"];
        [self.headerBufferView.layer addAnimation:colorAnimation forKey:@"color animation"];
        self.headerView.layer.speed = 0.0;
        self.headerBufferView.layer.speed = 0.0;
        _currentAnimation = colorAnimation;
    }
}

- (void)setColorsArray:(NSArray *)colorsArray {
    _colorsArray = colorsArray;
    NSInteger total = colorsArray.count;
    for(NSInteger i = 0 ; i < total ; i ++){
        {
            if(!_colorAnimationArray) _colorAnimationArray = [NSMutableArray new];
            
            NSInteger next = (i + 1) % total;
            id fromValue = (id)[MHColorUtils colorWithRGB:[self.colorsArray[i] unsignedIntegerValue]].CGColor;
            id toValue   = (id)[MHColorUtils colorWithRGB:[self.colorsArray[next] unsignedIntegerValue]].CGColor;

            CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
            colorAnimation.fromValue = fromValue;
            colorAnimation.toValue   = toValue;
            colorAnimation.duration  = 1;
            colorAnimation.removedOnCompletion = NO;
            colorAnimation.fillMode = kCAFillModeForwards;
            [_colorAnimationArray addObject:colorAnimation];
        }
        
        {
            if(!_reversColorAnimationArray) _reversColorAnimationArray = [NSMutableArray new];
            
            NSInteger last = (i + total - 1) % total;
            id fromValue = (id)[MHColorUtils colorWithRGB:[self.colorsArray[i] unsignedIntegerValue]].CGColor;
            id toValue   = (id)[MHColorUtils colorWithRGB:[self.colorsArray[last] unsignedIntegerValue]].CGColor;
            
            CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
            colorAnimation.fromValue = fromValue;
            colorAnimation.toValue   = toValue;
            colorAnimation.duration  = 1;
            colorAnimation.removedOnCompletion = NO;
            colorAnimation.fillMode = kCAFillModeForwards;
            [_reversColorAnimationArray addObject:colorAnimation];
        }
    }
}

@end
