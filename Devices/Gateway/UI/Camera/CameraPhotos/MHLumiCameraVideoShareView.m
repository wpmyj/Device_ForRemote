//
//  MHLumiCameraVideoShareView.m
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiCameraVideoShareView.h"

@interface MHLumiCameraVideoShareView()
@property (nonatomic, strong) UIView *buttonsContainerView;
@property (nonatomic, strong) UIButton *wechatShareButton;
@property (nonatomic, strong) UIButton *wechatTimeLineButton;
@property (nonatomic, strong) UIButton *weiboShareButton;
@property (nonatomic, strong) UIButton *miShareButton;
@property (nonatomic, strong) MASConstraint *containerViewBottomConstraint;
@property (nonatomic, assign) BOOL isShowing;
@end

@implementation MHLumiCameraVideoShareView
static CGFloat kRadio = 300.0/1920.0;
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.6];
        self.layer.masksToBounds = YES;
        self.isShowing = NO;
        [self addSubview:self.buttonsContainerView];
        [self.buttonsContainerView addSubview:self.wechatShareButton];
        [self.buttonsContainerView addSubview:self.wechatTimeLineButton];
        [self.buttonsContainerView addSubview:self.weiboShareButton];
        [self.buttonsContainerView addSubview:self.miShareButton];
        [self configureButtonsContainerViewLayout];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideInDuration:)];
        [self addGestureRecognizer:tap];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)configureButtonsContainerViewLayout{
    
    NSArray <UIButton *> * buttonArray = @[self.wechatShareButton,
                                           self.wechatTimeLineButton,
                                           self.weiboShareButton,
                                           self.miShareButton];
    UIButton *lastButton = nil;
    for (UIButton *todoButton in buttonArray) {
        [todoButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.buttonsContainerView);
            make.width.mas_equalTo(self.buttonsContainerView).multipliedBy(1.0/buttonArray.count);
            if (lastButton){
                make.left.equalTo(lastButton.mas_right);
            }else{
                make.left.equalTo(self.buttonsContainerView);
            }
        }];
        lastButton = todoButton;
    }
}

- (void)updateContainerViewBottomConstraintWithHidden:(BOOL)hidden{
    [self.containerViewBottomConstraint uninstall];
    if (hidden){
        [self.buttonsContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            self.containerViewBottomConstraint = make.top.equalTo(self.mas_bottom);
        }];
    }else{
        [self.buttonsContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            self.containerViewBottomConstraint = make.bottom.equalTo(self);
        }];
    }
}

- (void)showInDuration:(NSTimeInterval)duration{
    self.isShowing = YES;
    UIWindow *window = ((AppDelegate *)[UIApplication sharedApplication].delegate).window;
    self.alpha = 0;
    [window addSubview:self];
    self.frame = window.bounds;
    [UIView animateWithDuration:duration animations:^{
        self.alpha = 1;
    }];
    self.buttonsContainerView.frame = CGRectMake(0, window.bounds.size.height, window.bounds.size.width, window.bounds.size.height * kRadio);
    [UIView animateWithDuration:duration animations:^{
        self.buttonsContainerView.frame = CGRectMake(0, window.bounds.size.height-window.bounds.size.height * kRadio, window.bounds.size.width, window.bounds.size.height * kRadio);
    } completion:^(BOOL finished) {
    }];
}

- (void)hideInDuration:(NSTimeInterval)duration{
    self.isShowing = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    }];
    [UIView animateWithDuration:duration animations:^{
        self.buttonsContainerView.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height * kRadio);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - getter and setter
- (UIView *)buttonsContainerView{
    if (!_buttonsContainerView) {
        UIView *aView = [[UIView alloc] init];
        aView.backgroundColor = [UIColor whiteColor];
        _buttonsContainerView = aView;
    }
    return _buttonsContainerView;
}

- (UIButton *)wechatShareButton{
    if (!_wechatShareButton) {
        UIButton *button = [[UIButton alloc] init];
        [button setImage:[UIImage imageNamed:@"lumi_camera_share_weixxin"] forState:UIControlStateNormal];
        _wechatShareButton = button;
    }
    return _wechatShareButton;
}

- (UIButton *)wechatTimeLineButton{
    if (!_wechatTimeLineButton) {
        UIButton *button = [[UIButton alloc] init];
        [button setImage:[UIImage imageNamed:@"lumi_camera_share_pengyouquan"] forState:UIControlStateNormal];
        _wechatTimeLineButton = button;
    }
    return _wechatTimeLineButton;
}

- (UIButton *)weiboShareButton{
    if (!_weiboShareButton) {
        UIButton *button = [[UIButton alloc] init];
        [button setImage:[UIImage imageNamed:@"lumi_camera_share_weibo"] forState:UIControlStateNormal];
        _weiboShareButton = button;
    }
    return _weiboShareButton;
}

- (UIButton *)miShareButton{
    if (!_miShareButton) {
        UIButton *button = [[UIButton alloc] init];
        [button setImage:[UIImage imageNamed:@"lumi_camera_share_miliao"] forState:UIControlStateNormal];
        _miShareButton = button;
    }
    return _miShareButton;
}

@end
