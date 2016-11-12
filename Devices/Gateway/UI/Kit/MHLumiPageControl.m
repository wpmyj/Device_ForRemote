//
//  MHLumiPageControl.m
//  MiHome
//
//  Created by Lynn on 3/1/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLumiPageControl.h"
#import <QuartzCore/QuartzCore.h>

#define ImageSize 7.f
#define DotWidth  12.f

@interface MHLumiPageControl ()

@property (nonatomic,strong) UIImageView* activeImageView;

@end

@implementation MHLumiPageControl
{
    NSMutableArray      *_dotArray;
    
    CABasicAnimation    *_leftDisappearAnimation;
    CABasicAnimation    *_rightDisappearAnimation;
    CABasicAnimation    *_leftAppearAnimation;
    CABasicAnimation    *_rightAppearAnimation;

    CABasicAnimation    *_currentAnimation;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        UIImage *activeImage = [self drawPointImage:1.0f];
        self.activeImageView = [[UIImageView alloc] initWithImage:activeImage];
        self.activeImageView.frame = CGRectMake(0, 0, ImageSize, ImageSize);
        [self createAnimation];
    }
    return self;
}

- (UIImage *)drawPointImage:(CGFloat)alpha {

    UIView *point = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ImageSize * 2, ImageSize * 2)];
    point.backgroundColor = [UIColor clearColor];
    UIView *pointView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ImageSize * 2, ImageSize * 2)];
    pointView.backgroundColor = [UIColor colorWithWhite:1.f alpha:alpha];
    pointView.layer.cornerRadius = ImageSize;
    [point addSubview:pointView];
    
    UIGraphicsBeginImageContext(pointView.bounds.size);
    [point.layer renderInContext:UIGraphicsGetCurrentContext()];

    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    _numberOfPages = numberOfPages;
    if(numberOfPages > 1){
        [self buildSubview];
    }
}

- (void)buildSubview {
    _dotArray = [NSMutableArray new];
    CGFloat totalDotWidth = DotWidth * (_numberOfPages - 1) + ImageSize * _numberOfPages;
    
    for(int i = 0 ; i < _numberOfPages ; i ++ ){
        UIView *dot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 7.f, 7.f)];
        dot.clipsToBounds = YES;
        dot.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.3];
        CGFloat x = (WIN_WIDTH * 0.5 - totalDotWidth * 0.5) + (DotWidth + 7) * i + 3.5;
        CGFloat y = self.frame.size.height * 0.5;
        dot.center = CGPointMake(x, y);
        dot.layer.cornerRadius = 3.5;
        [self addSubview:dot];
        [_dotArray addObject:dot];
    }
}

- (void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage;
    [self updatePoint:currentPage];
}

- (void)updatePoint:(NSInteger)currentPage {
    [self relocateActivePointAt:currentPage];
}

- (void)relocateActivePointAt:(NSInteger)index {
    [self.activeImageView removeFromSuperview];
    self.activeImageView.hidden = NO;
    self.activeImageView.frame = CGRectMake(0.f, 0.f, ImageSize, ImageSize);
    UIView *dot = _dotArray[index];
    [dot addSubview:self.activeImageView];
}

- (void)animationActiveImage:(CGFloat)progress
                   direction:(PageDirection)direction {
    if(progress <= 0.5) {
        [self disappearAnimation:direction withProgress:progress * 2];
    }
    else {
        [self appearAnimation:direction withProgress:(progress - 0.5) * 2];
    }
}

- (void)disappearAnimation:(PageDirection)direction withProgress:(CGFloat)progress {
    CABasicAnimation *animation ;
    if(direction == Page_Left) animation = _leftDisappearAnimation;
    else animation = _rightDisappearAnimation;

    if(_currentAnimation != animation){
        [self.activeImageView.layer removeAnimationForKey:@"trans animation"];
        [self.activeImageView.layer addAnimation:animation forKey:@"trans animation"];
        self.activeImageView.layer.speed = 0.0;
        _currentAnimation = animation;
    }
    self.activeImageView.layer.timeOffset = progress;
}

- (void)appearAnimation:(PageDirection)direction withProgress:(CGFloat)progress {
    CABasicAnimation *animation ;
    if(direction == Page_Left) animation = _leftAppearAnimation;
    else animation = _rightAppearAnimation;

    if(_currentAnimation != animation){
        NSInteger total = _dotArray.count;
        NSInteger next = (_currentPage + 1) % total;
        NSInteger last = (_currentPage + total - 1) % total;
        if(direction == Page_Left) {
            [self relocateActivePointAt:next];
        }
        else if (direction == Page_Right) {
            [self relocateActivePointAt:last];
        }
        
        [self.activeImageView.layer removeAnimationForKey:@"trans animation"];
        [self.activeImageView.layer addAnimation:animation forKey:@"trans animation"];
        self.activeImageView.layer.speed = 0.0;
        _currentAnimation = animation;
    }
    self.activeImageView.layer.timeOffset = progress;
}

- (void)createAnimation {

    _leftDisappearAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    _leftDisappearAnimation.fromValue = @(0.0f);
    _leftDisappearAnimation.toValue = @(ImageSize);
    _leftDisappearAnimation.duration = 1;
    _leftDisappearAnimation.removedOnCompletion = NO;
    _leftDisappearAnimation.fillMode = kCAFillModeForwards;
    
    _rightDisappearAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    _rightDisappearAnimation.fromValue = @(0.0f);
    _rightDisappearAnimation.toValue = @(-ImageSize);
    _rightDisappearAnimation.duration = 1;
    _rightDisappearAnimation.removedOnCompletion = NO;
    _rightDisappearAnimation.fillMode = kCAFillModeForwards;

    _leftAppearAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    _leftAppearAnimation.fromValue = @(-ImageSize);
    _leftAppearAnimation.toValue = @(0.0f);
    _leftAppearAnimation.duration = 1;
    _leftAppearAnimation.removedOnCompletion = NO;
    _leftAppearAnimation.fillMode = kCAFillModeForwards;
    
    _rightAppearAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    _rightAppearAnimation.fromValue = @(ImageSize);
    _rightAppearAnimation.toValue = @(0.0f);
    _rightAppearAnimation.duration = 1;
    _rightAppearAnimation.removedOnCompletion = NO;
    _rightAppearAnimation.fillMode = kCAFillModeForwards;
}

@end
