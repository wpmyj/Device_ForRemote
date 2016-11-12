//
//  MHLumiFMPlayerAnimation.h
//  MiHome
//
//  Created by Lynn on 2/1/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MHLumiFMPlayerAnimation : NSObject

+ (void)addAnimation:(CALayer *)layer duration:(CGFloat)duration;

+ (void)addReverseAnimation:(CALayer *)layer duration:(CGFloat)duration;

+ (void)removeAnimation:(CALayer *)layer;

+ (void)pauseLayer:(CALayer*)layer;

+ (void)resumeLayer:(CALayer*)layer;

@end
