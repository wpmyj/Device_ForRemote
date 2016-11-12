//
//  MHLumiUITool.m
//  MiHome
//
//  Created by LM21Mac002 on 16/10/19.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiUITool.h"

@implementation MHLumiUITool
+ (UIColor *)randomColor{
    CGFloat r = arc4random_uniform(255)/255.0;
    CGFloat g = arc4random_uniform(255)/255.0;
    CGFloat b = arc4random_uniform(255)/255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}
@end
