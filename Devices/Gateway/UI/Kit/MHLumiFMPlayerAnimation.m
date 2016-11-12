//
//  MHLumiFMPlayerAnimation.m
//  MiHome
//
//  Created by Lynn on 2/1/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLumiFMPlayerAnimation.h"

@implementation MHLumiFMPlayerAnimation

+ (void)addAnimation:(CALayer *)layer duration:(CGFloat)duration {
    //在添加动画之前，先删除之前的动画
    [self removeAnimation:layer];
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0]; // 起始角度
    rotationAnimation.toValue = [NSNumber numberWithFloat: 2 * M_PI]; // 终止角度
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 10000;
    rotationAnimation.duration = duration;
    [layer addAnimation:rotationAnimation forKey:@"rotate-layer"];
}

+ (void)addReverseAnimation:(CALayer *)layer duration:(CGFloat)duration {
    [self removeAnimation:layer];
    CABasicAnimation* halfRotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    halfRotationAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    halfRotationAnimation.toValue = [NSNumber numberWithFloat: -2 * M_PI];
    halfRotationAnimation.cumulative = YES;
    halfRotationAnimation.repeatCount = HUGE;
    halfRotationAnimation.duration = duration;
    [layer addAnimation:halfRotationAnimation forKey:@"rotate-layer"];
}

+ (void)removeAnimation:(CALayer *)layer {
    [layer removeAllAnimations];
}

+ (void)pauseLayer:(CALayer*)layer {
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

+ (void)resumeLayer:(CALayer*)layer {
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

@end
