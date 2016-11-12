//
//  MHLMPageTitleView.m
//  MiHome
//
//  Created by ayanami on 16/7/15.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLMPageTitleView.h"

@interface MHLMPageTitleView ()

@property (nonatomic, copy) selectTitleCallback selectTitle;
@property (nonatomic, strong) NSMutableArray *titleLabelArray;
@property (nonatomic, copy) NSArray *titleArray;
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation MHLMPageTitleView

- (id)initWithFrame:(CGRect)frame titleArray:(NSArray *)titleArray selectCallback:(selectTitleCallback)callback
{
    self = [super init];
    if (self) {
        self.selectTitle = callback;
        self.titleArray = titleArray;
        [self buildSubviews];
    }
    return self;
}


- (void)buildSubviews {
    XM_WS(weakself);
    self.titleLabelArray = [NSMutableArray new];
    [self.titleArray enumerateObjectsUsingBlock:^(NSString *titleText, NSUInteger idx, BOOL * _Nonnull stop) {
        UITapGestureRecognizer *titleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleClick:)];
        
    }];
    
}


- (void)titleClick:(id)sender {
    
}


- (void)refreshCurrentOffsetX:(CGFloat)offsetX direction:(TitleScrollDirection)direction {
    
}

@end
