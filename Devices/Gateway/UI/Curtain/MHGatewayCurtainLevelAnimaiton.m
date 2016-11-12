//
//  MHGatewayCurtainLevelAnimaiton.m
//  MiHome
//
//  Created by guhao on 16/2/2.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayCurtainLevelAnimaiton.h"
#import "MHGatewayCurtainClothView.h"

@interface MHGatewayCurtainLevelAnimaiton ()

@property (nonatomic, strong) MHGatewayCurtainClothView *leftView;
@property (nonatomic, strong) MHGatewayCurtainClothView *rightView;
@property (nonatomic, strong) UIImageView *bgImageView;

@end

@implementation MHGatewayCurtainLevelAnimaiton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self buildSubviews];
    }
    return self;
}
+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    [self buildConstraints];
    
    [super updateConstraints];
}



- (void)buildSubviews {
    
    self.backgroundColor = [UIColor clearColor];
    
    self.leftView = [[MHGatewayCurtainClothView alloc] init];
    [self addSubview:self.leftView];
    
    self.rightView = [[MHGatewayCurtainClothView alloc] init];
    [self addSubview:self.rightView];
}

- (void)buildConstraints {
    XM_WS(weakself);
    
    [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself);
        make.left.equalTo(weakself);
        make.bottom.mas_equalTo(weakself.mas_bottom);
        make.width.mas_equalTo(30);
    }];
    
    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself);
        make.right.equalTo(weakself);
        make.bottom.mas_equalTo(weakself.mas_bottom);
        make.width.mas_equalTo(30);
    }];
}

- (void)configureWithLevel:(float)level {
    XM_WS(weakself);
    [UIView animateWithDuration:0.3 animations:^{
        CGFloat add = (weakself.bounds.size.width / 2 - 60) * level / 100.0f + 60;

        CGRect leftFrame = weakself.leftView.frame;
        CGRect rightFrame = weakself.rightView.frame;
        
        leftFrame.size.width = add;
        rightFrame.size.width = add;
        
        weakself.leftView.frame = leftFrame;
        weakself.rightView.frame = rightFrame;
        
    }];
}

@end
