//
//  MHLumiCameraPhotosNavHeaderView.m
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/7.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiCameraPhotosNavHeaderView.h"

@interface MHLumiCameraPhotosNavHeaderView()
@property (nonatomic, strong) UIView *centerView;
//@property (nonatomic, strong) NSArray<UIButton *> *navButtons;
//@property (nonatomic, strong) NSArray<NSString *> *navButtontitles;
//@property (nonatomic, assign) NSInteger currentIndex;
@end

@implementation MHLumiCameraPhotosNavHeaderView

- (void)layoutSubviews{
    [super layoutSubviews];
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [window addSubview:self.centerView];
    CGFloat w = self.centerView.bounds.size.width;
    CGFloat h = self.centerView.bounds.size.height;
    self.centerView.frame = CGRectMake((window.bounds.size.width-w)/2.0, 20, w, h);
    CGRect rect = [window convertRect:self.centerView.frame toView:self];
    [self addSubview:self.centerView];
    rect = CGRectMake(MAX(0, rect.origin.x), rect.origin.y, rect.size.width, rect.size.height);
    self.centerView.frame = rect;
}

- (void)setCenterView:(UIView *)centerView{
    for (UIView *todoView in self.subviews) {
        [todoView removeFromSuperview];
    }
    _centerView = centerView;
    [self addSubview:centerView];
}
@end
