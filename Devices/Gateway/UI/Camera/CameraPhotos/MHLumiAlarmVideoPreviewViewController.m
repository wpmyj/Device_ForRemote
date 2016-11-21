//
//  MHLumiAlarmVideoPreviewViewController.m
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/15.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiAlarmVideoPreviewViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MHLumiCameraVideoShareView.h"

@interface MHLumiAlarmVideoPreviewViewController ()
@property (nonatomic, strong) NSMutableArray *buttonArray; //
/**
 *  分享按钮
 */
@property (nonatomic, strong) UIButton *shareButton;

/**
 *  删除按钮
 */
@property (nonatomic, strong) UIButton *deleteButton;

/**
 *  保存按钮
 */
@property (nonatomic, strong) UIButton *saveButton;

@property (nonatomic, strong) UIButton *alarmAbleButton;
@property (nonatomic, strong) UIView *buttonsContanerView;
@property (nonatomic, strong) MASConstraint *buttonsContanerViewBottomConstraint;
@property (nonatomic, strong) AVPlayerViewController *playerViewController;
@property (nonatomic, strong) MHLumiCameraVideoShareView *shareView;
@end

@implementation MHLumiAlarmVideoPreviewViewController
static CGFloat kButtonsContanerViewHeight = 80;

- (instancetype)initWithCameraDevice:(MHDeviceCamera *)device{
    self = [super initWithDevice:device];
    if (self){
        _cameraDevice = (MHDeviceCamera*)device;
        self.isHasMore = NO;
    }
    return self;
}

- (void)dealloc{
    [_playerViewController.player pause];
    _playerViewController.player = nil;
    _playerViewController = nil;
    [_playerViewController removeFromParentViewController];
    NSLog(@"MHLumiAlarmVideoPreviewViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isTabBarHidden = YES;
    self.isNavBarTranslucent = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [_playerViewController.player pause];
     NSLog(@"_playerViewController pause");
}

- (void)buildSubviews{
    [super buildSubviews];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.buttonsContanerView];
    [self.buttonArray addObject:self.deleteButton];
    [self.buttonArray addObject:self.saveButton];
    [self.buttonArray addObject:self.shareButton];
    [self.buttonArray addObject:self.alarmAbleButton];
    for (UIButton *todoButton in self.buttonArray) {
        [self.buttonsContanerView addSubview:todoButton];
    }
    
    AVPlayer *player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:self.videoUrl]];
    self.playerViewController = [[AVPlayerViewController alloc] init];
    self.playerViewController.player = player;
    [self.playerViewController willMoveToParentViewController:self];
    [self addChildViewController:self.playerViewController];
    [self.view addSubview:self.playerViewController.view];
    [self.playerViewController didMoveToParentViewController:self];
    
    [self configureLayoutWithOrientation:UIInterfaceOrientationPortrait];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

#pragma mark - configureLayout
- (void)configureLayoutWithOrientation:(UIInterfaceOrientation)orientation{
    [self.buttonsContanerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(kButtonsContanerViewHeight);
        self.buttonsContanerViewBottomConstraint = make.bottom.equalTo(self.view);
    }];
    
    UIButton *lastButton = nil;
    for (UIButton *button in self.buttonArray) {
        [button mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.buttonsContanerView);
            if (lastButton){
                make.left.equalTo(lastButton.mas_right);
            }else{
                make.left.equalTo(self.buttonsContanerView.mas_left);
            }
            make.width.mas_equalTo(self.buttonsContanerView.mas_width).multipliedBy(1.0/self.buttonArray.count);
        }];
        lastButton = button;
    }
    
    [self.playerViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).mas_offset(self.navigationController ? 64 : 0);
        make.left.right.equalTo(self.view);
        make.height.equalTo(self.playerViewController.view);
    }];
}

#pragma mark - event response
- (void)shareButtonAction:(UIButton *)sender{
    [self.shareView showInDuration:0.2];
}

- (void)deleteButtonAction:(UIButton *)sender{

}

- (void)saveButtonAction:(UIButton *)sender{
    
}

- (void)alarmButtonAction:(UIButton *)sender{
    
}


#pragma mark - private
- (void)setHidesControlView:(BOOL)hidesControlView{
    if (hidesControlView){
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.buttonsContanerViewBottomConstraint uninstall];
        [self.buttonsContanerView mas_makeConstraints:^(MASConstraintMaker *make) {
            self.buttonsContanerViewBottomConstraint = make.bottom.equalTo(self.view).mas_offset(kButtonsContanerViewHeight);
        }];
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.buttonsContanerView.hidden = YES;
        }];
    }else{
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.buttonsContanerViewBottomConstraint uninstall];
        [self.buttonsContanerView mas_makeConstraints:^(MASConstraintMaker *make) {
            self.buttonsContanerViewBottomConstraint = make.bottom.equalTo(self.view);
        }];
        self.buttonsContanerView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
    }
}

#pragma mark - getter ans setter

- (UIView *)buttonsContanerView{
    if (!_buttonsContanerView){
        UIView *aView = [[UIView alloc] init];
//        aView.backgroundColor = [MHColorUtils colorWithRGB:0x141212 alpha:0.6];
        _buttonsContanerView = aView;
    }
    return _buttonsContanerView;
}

- (UIButton *)shareButton{
    if (!_shareButton) {
        UIButton *button = [[UIButton alloc] init];
        [button addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"lumi_camera_share"] forState:UIControlStateNormal];
        _shareButton = button;
    }
    return _shareButton;
}

- (UIButton *)deleteButton{
    if (!_deleteButton) {
        UIButton *button = [[UIButton alloc] init];
        [button addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"lumi_camera_video_delete"] forState:UIControlStateNormal];
        _deleteButton = button;
    }
    return _deleteButton;
}

- (UIButton *)saveButton{
    if (!_saveButton) {
        UIButton *button = [[UIButton alloc] init];
        [button addTarget:self action:@selector(saveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"lumi_camera_video_save"] forState:UIControlStateNormal];
        _saveButton = button;
    }
    return _saveButton;
}

- (UIButton *)alarmAbleButton{
    if (!_alarmAbleButton) {
        UIButton *button = [[UIButton alloc] init];
        [button addTarget:self action:@selector(alarmButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"lumi_camera_alarm_on"] forState:UIControlStateNormal];
        _alarmAbleButton = button;
    }
    return _alarmAbleButton;
}

- (NSMutableArray *)buttonArray{
    if (!_buttonArray){
        _buttonArray = [NSMutableArray array];
    }
    return _buttonArray;
}

- (MHLumiCameraVideoShareView *)shareView{
    if (!_shareView) {
        _shareView = [[MHLumiCameraVideoShareView alloc] init];
    }
    return _shareView;
}
@end
