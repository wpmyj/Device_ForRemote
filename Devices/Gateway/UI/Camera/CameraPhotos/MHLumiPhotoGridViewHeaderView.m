//
//  MHLumiPhotoGridViewHeaderView.m
//  Lumi_demo_OC
//
//  Created by LM21Mac002 on 2016/10/24.
//  Copyright © 2016年 LM21Mac002. All rights reserved.
//

#import "MHLumiPhotoGridViewHeaderView.h"

@interface MHLumiPhotoGridViewHeaderView()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIVisualEffectView *blurView;
@end

@implementation MHLumiPhotoGridViewHeaderView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setupSubViews];
        [self configureLayout];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.blurView.frame = self.bounds;
    self.titleLabel.frame = CGRectMake(8, 0, CGRectGetWidth(self.bounds)-8, CGRectGetHeight(self.bounds));
}

+ (NSString *)reuseIdentifier{
    return @"reuseIdentifier.MHLumiPhotoGridViewHeaderView";
}

#pragma mark - setupSubViews
- (void)setupSubViews{
    [self addSubview:self.blurView];
    [self addSubview:self.titleLabel];
}

- (void)configureLayout{
    
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        UILabel *aLabel = [[UILabel alloc] init];
        _titleLabel = aLabel;
    }
    return _titleLabel;
}

- (UIVisualEffectView *)blurView{
    if (!_blurView) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _blurView = blurView;
    }
    return _blurView;
}



@end
