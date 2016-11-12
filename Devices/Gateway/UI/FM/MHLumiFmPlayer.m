//
//  MHLumiFmPlayer.m
//  MiHome
//
//  Created by Lynn on 11/25/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLumiFmPlayer.h"
#import "MHImageView.h"
#import "AppDelegate.h"
#import "MHTipsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MHLumiFMVolumeControl.h"
#import "MHLumiFMPlayerAnimation.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MHMusicTipsView.h"

static MHLumiFmPlayer* fmPlayer = nil;

@interface MHLumiFmPlayer ()

@property (nonatomic,strong) UIButton *playerPlayBtn;
@property (nonatomic,strong) UIWindow *window;
@property (nonatomic,strong) MHImageView *coverImage;
@property (nonatomic,strong) MPVolumeView *volumeView;
@property (nonatomic,assign) NSInteger volumeTipShow;

@end

@implementation MHLumiFmPlayer
{
    UIView *                _backgroundView;
    UIView *                _miniPlayerView;
    UIView *                _fullPlayerView;
    
    UILabel *               _radioNameLabel;
    UILabel *               _programNameLabel;
    UIButton *              _playNextBtn;
    UIButton *              _volumeBtn;
    UILabel *               _collectionListTitle;
    
    NSDate *                _lastClickDate;
    NSInteger               _deviceVolume;
    NSString *              _lastVolume;
}

+ (MHLumiFmPlayer *)shareInstance
{
    @synchronized(@"MHLumiFmPlayer_sharedInstance")
    {
        if (fmPlayer == nil)
        {
            fmPlayer = [[MHLumiFmPlayer alloc] initFMPlayer];
        }
    }
    return fmPlayer;
}

- (MHLumiFmPlayer*)initFMPlayer
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self)
    {
        [self setUserInteractionEnabled:YES];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];

        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.backgroundColor = [MHColorUtils colorWithRGB:0x0ca8ba];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_backgroundView];
        
        AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        _window = [[UIWindow alloc] initWithFrame:delegate.window.frame];
        _window.windowLevel = UIWindowLevelStatusBar;
        _window.rootViewController = [[MHTipsViewController alloc] init];
        
        switch ([[UIApplication sharedApplication] statusBarOrientation]) {
            case UIInterfaceOrientationPortrait:
                self.transform = CGAffineTransformMakeRotation(0);
                break;
                
            case UIInterfaceOrientationPortraitUpsideDown:
                self.transform = CGAffineTransformMakeRotation(M_PI);
                break;
                
            case UIInterfaceOrientationLandscapeLeft:
                self.transform = CGAffineTransformMakeRotation(-M_PI/2);
                break;
                
            case UIInterfaceOrientationLandscapeRight:
                self.transform = CGAffineTransformMakeRotation(M_PI/2);
                break;
                
            default:
                break;
        }
        _window.hidden = YES;
    }
    return self;
}

- (void)hide {
    self.window.hidden = YES;
    self.isHide = YES;
    NSError *error;
    [[AVAudioSession sharedInstance] setActive:NO error:&error];//退出恢复系统的按键功能
    [self.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[MPVolumeView class]]) {
            [obj removeFromSuperview];
        }
    }];
    [self removeFromSuperview];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
}


- (void)setCurrentRadio:(MHLumiXMRadio *)currentRadio {
    if(_currentRadio != currentRadio){
        _currentRadio = currentRadio;
        _radioNameLabel.text = [currentRadio valueForKey:@"radioName"];
        _programNameLabel.text = [currentRadio valueForKey:@"currentProgram"];
        _coverImage.imageUrl = [currentRadio valueForKey:@"radioCoverSmallUrl"];
        [_coverImage loadImage];
    }
}

- (void)setCurrentProgramName:(NSString *)currentProgramName {
    _currentProgramName = currentProgramName;
    _programNameLabel.text = currentProgramName;
}

- (void)setIsPlaying:(BOOL)isPlaying {
    if (self.controlCallBack)  self.controlCallBack(isPlaying);

    _isPlaying = isPlaying;
    if(isPlaying){
        if(!_coverImage.layer.animationKeys){
            [self addAnimation];
        }
        [MHLumiFMPlayerAnimation resumeLayer:_coverImage.layer];
        [_playerPlayBtn setImage:[UIImage imageNamed:@"lumi_fm_pause_mini"] forState:UIControlStateNormal];
    }
    else{
        [MHLumiFMPlayerAnimation pauseLayer:_coverImage.layer];
        [_playerPlayBtn setImage:[UIImage imageNamed:@"lumi_fm_play_mini"] forState:UIControlStateNormal];
    }
}

#pragma mark - 硬件控制音量（手机音量键）
- (void)listenPhoneVolumeControlButton {
    NSError *error;
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    
    _volumeTipShow = -1;
    if(!_volumeView){
        _volumeView = [[MPVolumeView alloc] init];
        _volumeView.frame = CGRectMake(-1000, -100, 100, 100);
        [self addSubview:_volumeView];
    }
}

- (void)volumeChanged:(NSNotification *)notification {
    CGFloat volume = [[[notification valueForKey:@"userInfo"] valueForKey:@"AVSystemController_AudioVolumeNotificationParameter"] doubleValue];

    if(!_lastVolume) {
        NSLog(@"准备好了");
        [self volumeUpDown:@"start" volume:volume];
    }
    else {
        if([_lastVolume doubleValue] > volume) {
            //当前为减挡
            [self volumeUpDown:@"down" volume:volume];
        }
        else if ([_lastVolume doubleValue] < volume) {
            //当前为加挡
            [self volumeUpDown:@"up" volume:volume];
        }
        else if ([_lastVolume doubleValue] == volume) {
            if (volume == 0.0) {
                //当前为减挡
                [self volumeUpDown:@"down" volume:volume];
            }
            else if (volume == 1.0){
                //当前为加挡
                [self volumeUpDown:@"up" volume:volume];
            }
        }
    }
    _lastVolume = [NSString stringWithFormat:@"%f" ,volume];
}

- (void)volumeUpDown:(NSString *)direction volume:(CGFloat)volume {
    CGFloat volumeStep = 6;
    
    if ([direction isEqualToString:@"start"]){
        _deviceVolume = self.radioDevice.fm_volume;
    }
    else if([direction isEqualToString:@"up"]) {
        _deviceVolume = _deviceVolume + volumeStep;
        if(_deviceVolume > 100) _deviceVolume = 100;
    }
    else if([direction isEqualToString:@"down"]) {
        _deviceVolume = _deviceVolume - volumeStep;
        if(_deviceVolume < 0) _deviceVolume = 0;
    }
    
    CGFloat fmVolume = _deviceVolume / 100.f;
    [self setDeviceFMVolume:_deviceVolume withSuccess:nil failure:nil];
    
    _lastClickDate = [NSDate date];
    if(_volumeTipShow == 1) {
        [[MHMusicTipsView shareInstance] setFMVolume:fmVolume];
    }
    else {
        [[MHMusicTipsView shareInstance] showFMHardwareVolumeProgress:fmVolume withTips:NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.volume.hardware", @"plugin_gateway", nil)];
        _volumeTipShow = 1;
        
        XM_WS(weakself);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[MHMusicTipsView shareInstance] hide];
            weakself.volumeTipShow = -1;
        });
    }
}

#pragma mark - full player
- (void)hidePlayerSubs {
    _coverImage.hidden = YES;
    _playNextBtn.hidden = YES;
    _playerPlayBtn.hidden = YES;
    _radioNameLabel.hidden = YES;
    _volumeBtn.hidden = YES;
}

- (void)showPlayerSubs {
    [self addAnimation];

    _coverImage.hidden = NO;
    _playNextBtn.hidden = NO;
    _playerPlayBtn.hidden = NO;
    _radioNameLabel.hidden = NO;
    _volumeBtn.hidden = NO;
}

- (void)showFullPlayer {
    if ([self.currentRadio valueForKey:@"radioId"] && [self.currentRadio valueForKey:@"radioRateUrl"]) {
        [self hidePlayerSubs];
        if(self.showFullPlayerCallBack) self.showFullPlayerCallBack();
    }
}

#pragma mark - mini player
- (void)showMiniPlayer:(CGFloat)yPosition isMainPage:(BOOL)isMainPage {
    if (isMainPage) {
        CGRect playerFrame = CGRectMake(0, -100, 0, 0);
        self.frame = playerFrame;
        self.isHide = YES;
        _window.hidden = YES;
    }
    else {
        CGRect playerFrame = CGRectMake(0, yPosition, ScreenWidth, MiniPlayerHeight);
        self.frame = playerFrame;
        self.backgroundColor = [MHColorUtils colorWithRGB:0x0ca8ba];
        [self firstMiniConstruct];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFullPlayer)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tap];
        
        [self addAnimation];
        self.isHide = NO;
        _window.hidden = NO;
    }
    
    [self performSelectorOnMainThread:@selector(showFMOnMainTread)
                           withObject:nil
                        waitUntilDone:NO];
    
    [self listenPhoneVolumeControlButton];
}

- (void)firstMiniConstruct {
    _coverImage = [[MHImageView alloc] init];
    _coverImage.frame = CGRectMake(20, 10, miniPlayerImageSize, miniPlayerImageSize);
    _coverImage.placeHolderImage = [UIImage imageNamed:@"lumi_fm_cover_placeholder"];
    _coverImage.layer.cornerRadius = miniPlayerImageSize / 2;
    _coverImage.layer.borderColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.4].CGColor;
    _coverImage.layer.borderWidth = .5f;
    [self addSubview:_coverImage];
    
    _radioNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(miniPlayerImageSize + 30.f, 22.f, ScreenWidth - 5 * miniPlayerImageSize, 28.f)];
    _radioNameLabel.center = CGPointMake(_radioNameLabel.center.x, _coverImage.center.y);
    _radioNameLabel.font = [UIFont systemFontOfSize:14.f];
    _radioNameLabel.textAlignment = NSTextAlignmentLeft;
    _radioNameLabel.textColor = [UIColor whiteColor];
    [self addSubview:_radioNameLabel];
    
    _playNextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _playNextBtn.frame = CGRectMake(0, 0, miniPlayerBtnSize, miniPlayerBtnSize);
    _playNextBtn.center = CGPointMake(ScreenWidth - miniPlayerBtnSize, MiniPlayerHeight / 2);
    [_playNextBtn setImage:[UIImage imageNamed:@"lumi_fm_next_mini"] forState:UIControlStateNormal];
    [_playNextBtn addTarget:self action:@selector(playNext) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_playNextBtn];
    
    _playerPlayBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, miniPlayerBtnSize, miniPlayerBtnSize)];
    _playerPlayBtn.center = CGPointMake(_playNextBtn.center.x - miniPlayerBtnSize - 15.f, MiniPlayerHeight / 2);
    [_playerPlayBtn setImage:[UIImage imageNamed:@"lumi_fm_pause_mini"] forState:UIControlStateNormal];
    [_playerPlayBtn addTarget:self action:@selector(onPlayBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_playerPlayBtn];
    
    _volumeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, miniPlayerBtnSize, miniPlayerBtnSize)];
    _volumeBtn.center = CGPointMake(_playerPlayBtn.center.x - miniPlayerBtnSize - 15.f, MiniPlayerHeight / 2);
    [_volumeBtn setImage:[UIImage imageNamed:@"lumi_fm_player_volum_mini"] forState:UIControlStateNormal];
    [_volumeBtn addTarget:self action:@selector(volumeControl:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_volumeBtn];
}

- (void)showFMOnMainTread {
    //这个特殊处理，不使用顶层窗口
    _window.hidden = YES;
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate.window addSubview:self];
}

#pragma mark - animation
- (void)addAnimation {
    [MHLumiFMPlayerAnimation addAnimation:_coverImage.layer duration:8.f];
    [MHLumiFMPlayerAnimation resumeLayer:_coverImage.layer];
    
    if(!_isPlaying) {
        [MHLumiFMPlayerAnimation pauseLayer:_coverImage.layer];
    }
}

#pragma mark - device volume send
- (void)setDeviceFMVolume:(NSInteger)value
              withSuccess:(void (^)(id obj))success
                  failure:(void (^)(NSError *error))failure {
    [self.radioDevice radioVolumeControlWithDirection:nil Value:value andSuccess:^(id obj) {
        if(success)success(obj);
        
    } andFailure:^(NSError *error) {
        if (failure)failure(error);
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"setting.failed", @"plugin_gateway", nil)
                                          duration:1.5f
                                             modal:NO];
    }];
}

#pragma mark - button
- (void)volumeControl:(id)sender {
    MHLumiFMVolumeControl *volumeControl = [MHLumiFMVolumeControl shareInstance];
    volumeControl.gateway = self.radioDevice;
    [volumeControl showVolumeControl:CGRectGetMaxY(self.window.bounds) - VolumePlayerHeight withVolumeValue:_radioDevice.fm_volume];
    
    XM_WS(weakself);
    volumeControl.volumeControlCallBack = ^(NSInteger value){
        [weakself setDeviceFMVolume:value withSuccess:^(id obj) {
            if ([[obj valueForKey:@"result"] isKindOfClass:[NSDictionary class]]) {
                weakself.radioDevice.fm_volume = [[[obj valueForKey:@"result"] valueForKey:@"volume"] integerValue];
            }
        } failure:nil];
    };
}

- (void)onPlayBtnClicked:(UIButton *)sender {
    XM_WS(weakself);
    if(self.isPlaying){
        self.isPlaying = NO;
        [self.radioDevice playRadioWithMethod:@"off" andSuccess:^(id obj){
            if(weakself.pauseCallBack) weakself.pauseCallBack(weakself.currentRadio);
            
        } andFailure:^(NSError *error){
            weakself.isPlaying = YES;
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"loading.failed", @"plugin_gateway", nil) duration:1.5f modal:NO];
        }];
    }
    else{
        if (!_radioPlayList.count) {
            [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.collection.nonelist", @"plugin_gateway", "没有收藏哦,请先添加收藏") duration:1.5f modal:NO];
            return;
        }
        [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"loading", @"plugin_gateway", nil) modal:NO];
        [self play];
    }
}

- (void)pause {
    self.isPlaying = NO;

    XM_WS(weakself);
    [self.radioDevice playRadioWithMethod:@"off" andSuccess:^(id obj){
        [[MHTipsView shareInstance] hide];
        if(weakself.pauseCallBack) weakself.pauseCallBack(weakself.currentRadio);
        
    } andFailure:^(NSError *error){
        [[MHTipsView shareInstance] hide];
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"loading.failed", @"plugin_gateway", nil) duration:1.5f modal:NO];
        weakself.isPlaying = YES;
    }];
}

- (void)play {
    if (!_radioPlayList.count) {
        [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.collection.nonelist", @"plugin_gateway", "没有收藏哦,请先添加收藏") duration:1.5f modal:NO];
        return;
    }
    XM_WS(weakself);
    if ([self.currentRadio valueForKey:@"radioId"] && [self.currentRadio valueForKey:@"radioRateUrl"]) {
        self.isPlaying = YES;
        [self.radioDevice playSpecifyRadioWithProgramID:[[self.currentRadio valueForKey:@"radioId"] integerValue]
                                                    Url:[self.currentRadio valueForKey:@"radioRateUrl"]
                                                   Type:@"0"
                                             andSuccess:^(id obj){
                                                 [[MHTipsView shareInstance] hide];
                                                 if(weakself.playCallBack) weakself.playCallBack(weakself.currentRadio);
                                                 
                                             } andFailure:^(NSError *error){
                                                 [[MHTipsView shareInstance] hide];
                                                 [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"loading.failed", @"plugin_gateway", nil) duration:1.5f modal:NO];
                                                 weakself.isPlaying = NO;
                                             }];
    }    
}

- (void)playNext {
    if (!_radioPlayList.count) {
        [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.collection.nonelist", @"plugin_gateway", "没有收藏哦,请先添加收藏") duration:1.5f modal:NO];
        return;
    }
    NSInteger currentIdx = [_radioPlayList indexOfObject:_currentRadio];
    NSInteger nextIdx = currentIdx + 1;
    
    if(currentIdx >= _radioPlayList.count - 1) nextIdx = 0;

    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"loading", @"plugin_gateway", nil) modal:NO];
    self.currentRadio = _radioPlayList[nextIdx];
    [self play];
}

- (void)playLast {
    
    if (!_radioPlayList.count) {
        [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.collection.nonelist", @"plugin_gateway", "没有收藏哦,请先添加收藏") duration:1.5f modal:NO];
        return;
    }
    NSInteger currentIdx = [_radioPlayList indexOfObject:_currentRadio];
    NSInteger lastIdx = 0;
    if (currentIdx > 0 && currentIdx < [_radioPlayList count]) {
        lastIdx = currentIdx - 1;
    } else if(currentIdx == 0) {
        lastIdx = _radioPlayList.count - 1;
    }
    
    if (lastIdx < [_radioPlayList count]) {
        [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"loading", @"plugin_gateway", nil) modal:NO];
        self.currentRadio = _radioPlayList[lastIdx];
        [self play];
    }
}


@end
