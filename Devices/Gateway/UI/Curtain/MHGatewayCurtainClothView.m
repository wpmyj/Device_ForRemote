//
//  MHGatewayCurtainClothView.m
//  MiHome
//
//  Created by guhao on 16/5/12.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayCurtainClothView.h"
#import <Foundation/Foundation.h>

@interface MHGatewayCurtainClothView ()

@property (nonatomic, strong) NSMutableArray *lineViews;
@property (nonatomic, copy) NSArray *lineHeights;

@end

@implementation MHGatewayCurtainClothView



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.lineHeights = @[ @(30), @(200), @(80), @(100),@(120), @(20),@(95), @(70),@(50), @(36),@(80), @(140), @(47), @(45) ];
        [self buildSubviews];
    }
    return self;
}

- (void)buildSubviews {
    
    self.backgroundColor = [MHColorUtils colorWithRGB:0xc9c6b9];
    self.layer.cornerRadius = 6;
    self.lineViews = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 14; i++) {
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [MHColorUtils colorWithRGB:0xffffff alpha:0.6];
        [self addSubview:lineView];
        [self.lineViews addObject:lineView];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat spacing = (self.frame.size.width - 2 * 14 - 10) / 14;
//    NSInteger lineHeight = arc4random() % 180 + 30;
    for (int i = 0; i < self.lineViews.count; i++) {
        UIView *lineView = self.lineViews[i];
        CGRect rect = CGRectMake(5 + i * (spacing + 2) + 2, 0, 1, [self.lineHeights[i] floatValue]);
        lineView.frame = rect;
    }
    

}

@end
