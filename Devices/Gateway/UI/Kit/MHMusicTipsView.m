//
//  MHMusicTipsView.m
//  MiHome
//
//  Created by Lynn on 10/27/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHMusicTipsView.h"
#import "AppDelegate.h"
#import "SDProgressView.h"
#import "MHVolumeBarView.h"
#import <QuartzCore/QuartzCore.h>

#define KeyForTipsContextInfo                                       @"info"
#define KeyForTipsContextDuration                                   @"duration"
#define KeyForTipsContextModelFlag                                  @"isModel"
#define KeyForTipsContextProgress                                   @"progress"
#define KeyForTipsContextVolume                                     @"volume"

static MHMusicTipsView* gTipsView = nil;

@interface MHMusicTipsView ()

@property (nonatomic, strong) void(^onPlayBtn)(NSString *status);

@end

@implementation MHMusicTipsView
{
    UIImageView*                    _playBackgroundView;
    
    UILabel *                       _playButtonLabel;
    UIButton *                      _playButton;
    
    CountTimerProgressView*         _progressView;
    
    UIImageView *                   _squareBackground;
    
    UIView *                        _volumeView;
    
    UIImageView *                   _fmIconImageView;
}

#pragma mark - play view
-(void)setCurrentStatus:(NSString *)currentStatus
{
    _currentStatus = currentStatus;
    if([_currentStatus isEqualToString:CallBackPauseKey]){
        [_playButton setImage:[UIImage imageNamed:@"lumi_gateway_pause_button"] forState:UIControlStateNormal];
        _currentStatus = CallBackPlayKey;
    }
    else if([_currentStatus isEqualToString:CallBackPlayKey]){
        [_playButton setImage:[UIImage imageNamed:@"lumi_gateway_play_button"] forState:UIControlStateNormal];
        _currentStatus = CallBackPauseKey;
    }
}

- (void)showRecordModal:(BOOL)isModal withTouchBlock:(void (^)(id))success andInfo:(NSString *)info{
    NSMutableDictionary* context = [[NSMutableDictionary alloc] initWithCapacity:3];
    
    NSNumber* modelFlag = [[NSNumber alloc] initWithBool:isModal];
    [context setObject:modelFlag forKey:KeyForTipsContextModelFlag];
    _window.hidden = YES;
    
    self.onPlayBtn = success;
    
    _boardView.hidden =YES;
    
    UIViewAutoresizing viewAutoresizing = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    _playBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 150)];
    UIImage* bgImage = [UIImage imageNamed:@"lumi_tip_playBak"];
    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    _playBackgroundView.image = bgImage;
    _playBackgroundView.center = CGPointMake(self.bounds.size.width /2, self.bounds.size.height /2) ;
    _playBackgroundView.autoresizingMask = viewAutoresizing;
    
    [self addSubview:_playBackgroundView];
    
    _playButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 66, 50, 30)];
    _playButtonLabel.center = CGPointMake(_playBackgroundView.frame.size.width /2, 90);
    _playButtonLabel.text = info;
    _playButtonLabel.font = [UIFont systemFontOfSize:17.f];
    _playButtonLabel.backgroundColor = [UIColor clearColor];
    _playButtonLabel.textAlignment = NSTextAlignmentCenter;
    _playButtonLabel.textColor = _labelInfo.textColor;
    [_playBackgroundView addSubview:_playButtonLabel];
    
    [self performSelectorOnMainThread:@selector(showPlayOnMainTread:)
                           withObject:context
                        waitUntilDone:NO];
    context = nil;
    modelFlag = nil;
}

-(void)playButton:(UIButton *)sender{
    if([_currentStatus isEqualToString:CallBackPauseKey]){
        [_playButton setImage:[UIImage imageNamed:@"lumi_gateway_pause_button"] forState:UIControlStateNormal];
        _currentStatus = CallBackPlayKey;
        self.onPlayBtn(CallBackPlayKey);
    }
    else if([_currentStatus isEqualToString:CallBackPlayKey]){
        [_playButton setImage:[UIImage imageNamed:@"lumi_gateway_play_button"] forState:UIControlStateNormal];
        _currentStatus = CallBackPauseKey;
        self.onPlayBtn(CallBackPauseKey);
    }
}

-(void)uploadButton:(UIButton *)sender{
    self.onPlayBtn(CallBackUploadKey);
    [self hide];
}

- (void)giveup:(UIButton *)sender {
    self.onPlayBtn(CallBackGiveUp);
    [self hide];
}

- (void)showPlayOnMainTread:(NSDictionary*)diction
{
    NSString* info = [diction objectForKey:KeyForTipsContextInfo];
    
    NSNumber* modelFlag = [diction objectForKey:KeyForTipsContextModelFlag];
    BOOL isModal = [modelFlag boolValue];
    self.hidden = NO;
    [self setModal:isModal];
    
    UIView *hWhiteLine = [[UIView alloc] initWithFrame:CGRectMake(0, 110, _playBackgroundView.frame.size.width, 0.5)];
    hWhiteLine.backgroundColor = [UIColor whiteColor];
    [_playBackgroundView addSubview:hWhiteLine];
    
    UIView *vWhiteLine = [[UIView alloc] initWithFrame:CGRectMake(_playBackgroundView.frame.size.width/2, 110, 0.5, _playBackgroundView.frame.size.height - 110)];
    vWhiteLine.backgroundColor = [UIColor whiteColor];
    [_playBackgroundView addSubview:vWhiteLine];
    
    CGFloat textHeight = [info boundingRectWithSize:CGSizeMake(_labelInfo.frame.size.width, 200) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.0f]} context:nil].size.height;
    [_labelInfo setFrame:CGRectMake(_labelInfo.frame.origin.x, _labelInfo.frame.origin.y, _labelInfo.frame.size.width, textHeight)];
    [_playBackgroundView setUserInteractionEnabled:YES];
    _imageView.hidden = YES;
    
    _currentStatus = CallBackPauseKey;
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _playButton.frame = CGRectMake(0, 0, 50, 50);
    _playButton.center = CGPointMake(_playBackgroundView.frame.size.width/2, 50);
    _playButton.backgroundColor = _playBackgroundView.backgroundColor;
    [_playButton setImage:[UIImage imageNamed:@"lumi_gateway_play_button"] forState:UIControlStateNormal];
    [_playButton addTarget:self action:@selector(playButton:) forControlEvents:UIControlEventTouchUpInside];
    [_playBackgroundView addSubview:_playButton];
    
    UIButton *uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    uploadButton.frame = CGRectMake(_playBackgroundView.frame.size.width/2, 110, _playBackgroundView.frame.size.width/2, vWhiteLine.frame.size.height);
    uploadButton.backgroundColor = _playBackgroundView.backgroundColor;
    uploadButton.titleLabel.textColor = [UIColor whiteColor];
    uploadButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [uploadButton setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.upload.save",@"plugin_gateway",nil) forState:UIControlStateNormal];
    [uploadButton addTarget:self action:@selector(uploadButton:) forControlEvents:UIControlEventTouchUpInside];
    [_playBackgroundView addSubview:uploadButton];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(0, 110, _playBackgroundView.frame.size.width/2, vWhiteLine.frame.size.height);
    cancelButton.backgroundColor = _playBackgroundView.backgroundColor;
    cancelButton.titleLabel.textColor = [UIColor whiteColor];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [cancelButton setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.upload.giveup",@"plugin_gateway",nil) forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(giveup:) forControlEvents:UIControlEventTouchUpInside];
    [_playBackgroundView addSubview:cancelButton];
    
    //这个特殊处理，不使用顶层窗口
    _window.hidden = YES;
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate.window addSubview:self];
}

- (void)setModal:(BOOL)isModal
{
    if (isModal){
        [self setUserInteractionEnabled:YES];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 0.1f;
    }else{
        [self setUserInteractionEnabled:NO];
        _backgroundView.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark - progress
-(void)showProgressView:(CGFloat)progress withTips:(NSString *)tips;
{
    NSMutableDictionary* context = [[NSMutableDictionary alloc] initWithCapacity:3];
    
    if (tips) [context setObject:tips forKey:KeyForTipsContextInfo];
    
    [context setObject:@(progress) forKey:KeyForTipsContextProgress];
    
    NSNumber* modelFlag = [[NSNumber alloc] initWithBool:YES];
    [context setObject:modelFlag forKey:KeyForTipsContextModelFlag];
    _window.hidden = NO;
    
    [self performSelectorOnMainThread:@selector(showProgressOnMainTread:)
                           withObject:context
                        waitUntilDone:NO];
    context = nil;
    modelFlag = nil;
}

- (void)showProgressOnMainTread:(NSDictionary*)diction
{
    NSString* info = [diction objectForKey:KeyForTipsContextInfo];
    NSNumber* modelFlag = [diction objectForKey:KeyForTipsContextModelFlag];
    BOOL isModal = [modelFlag boolValue];
    CGFloat progressPrecent = [[diction objectForKey:KeyForTipsContextProgress] doubleValue];
    
    self.hidden = NO;
    _boardView.hidden = YES;
    _imageView.hidden = YES;
    [self setModal:isModal];
    
    UIViewAutoresizing viewAutoresizing = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    _squareBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    UIImage* bgImage = [UIImage imageNamed:@"lumi_tip_squareBak"];
    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    _squareBackground.image = bgImage;
    _squareBackground.center = CGPointMake(self.bounds.size.width /2, self.bounds.size.height /2) ;
    _squareBackground.autoresizingMask = viewAutoresizing;
    [self addSubview:_squareBackground];
    
    _progressView = [CountTimerProgressView progressView];
    _progressView.circleColor = [UIColor colorWithWhite:1.f alpha:1.f];
    _progressView.backColor = [UIColor colorWithRed:116.f/255.f green:116.f/255.f blue:116.f/255.f alpha:1.f];
    _progressView.circleUnCoverColor = [UIColor colorWithRed:153.f/255.f green:153.f/255.f blue:153.f/255.f alpha:1.f];
    _progressView.frame = CGRectMake(0, 0, 90, 90);
    _progressView.center = CGPointMake(75, 75);
    [_squareBackground addSubview:_progressView];
    
    _labelInfo.text = info;
    CGFloat textHeight = [info boundingRectWithSize:CGSizeMake(_labelInfo.frame.size.width, 200) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:17.0f] } context:nil].size.height;
    [_labelInfo setFrame:CGRectMake(0, 0, _labelInfo.frame.size.width, textHeight)];
    _labelInfo.center = CGPointMake(75, 75);
    [_squareBackground addSubview:_labelInfo];

    _progressView.hidden = NO;
    _progressView.progress = progressPrecent;
    
    //这个特殊处理，不使用顶层窗口
    _window.hidden = YES;
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate.window addSubview:self];
}

-(void)setProgressCnt:(CGFloat)progress
{
    if(_progressView.hidden){
        _progressView.hidden = NO;
    }
    if(!_progressView){
        _progressView = [SDPieProgressView progressView];
        _progressView.frame = CGRectMake(0, 0, 78, 78);
        _progressView.center = CGPointMake(160/2, 40);
        _progressView.progress = progress;
    }
        
    if(progress == 1.0) {
        progress = progress - 0.001;
        _progressView.progress = progress;
        _labelInfo.text = NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.uploaded", @"plugin_gateway",nil);
    }
    else if (progress > 1.0) {
        _progressView.progress = 0.999;
        _labelInfo.text = NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.uploaded",@"plugin_gateway", nil);
    }else{
        _progressView.progress = progress;
        _labelInfo.text = [NSString stringWithFormat:@"%0.0f%@",progress * 100,@"%"];
    }
}

#pragma mark - fm hardware volume
- (void)showFMHardwareVolumeProgress:(CGFloat)progress withTips:(NSString *)tips {
    NSMutableDictionary* context = [[NSMutableDictionary alloc] initWithCapacity:3];
    
    if (tips) [context setObject:tips forKey:KeyForTipsContextInfo];
    
    [context setObject:@(progress) forKey:KeyForTipsContextProgress];
    
    NSNumber* modelFlag = [[NSNumber alloc] initWithBool:NO];
    [context setObject:modelFlag forKey:KeyForTipsContextModelFlag];
    _window.hidden = NO;
    
    [self performSelectorOnMainThread:@selector(showFMVolumeProgressOnMainTread:)
                           withObject:context
                        waitUntilDone:NO];
    context = nil;
    modelFlag = nil;
}

- (void)showFMVolumeProgressOnMainTread:(NSDictionary*)diction
{
    NSString* info = [diction objectForKey:KeyForTipsContextInfo];
    NSNumber* modelFlag = [diction objectForKey:KeyForTipsContextModelFlag];
    BOOL isModal = [modelFlag boolValue];
    CGFloat progressPrecent = [[diction objectForKey:KeyForTipsContextProgress] doubleValue];
    
    self.hidden = NO;
    _boardView.hidden = YES;
    _imageView.hidden = YES;
    [self setModal:isModal];
    
    UIViewAutoresizing viewAutoresizing = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    _squareBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    _squareBackground.image = [UIImage imageNamed:@"lumi_tip_squareBak"];
    _squareBackground.center = CGPointMake(self.bounds.size.width /2, self.bounds.size.height /2) ;
    _squareBackground.autoresizingMask = viewAutoresizing;
    _squareBackground.layer.cornerRadius = 75;
    _squareBackground.layer.borderColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.3].CGColor;
    _squareBackground.layer.borderWidth = .5f;
    _squareBackground.clipsToBounds = YES;
    [self addSubview:_squareBackground];
    
    _progressView = [CountTimerProgressView progressView];
    _progressView.circleColor = [UIColor colorWithWhite:1.f alpha:1.f];
    _progressView.backColor = [UIColor colorWithRed:116.f/255.f green:116.f/255.f blue:116.f/255.f alpha:1.f];
    _progressView.circleUnCoverColor = [UIColor colorWithRed:153.f/255.f green:153.f/255.f blue:153.f/255.f alpha:1.f];
    _progressView.frame = CGRectMake(0, 0, 149, 149);
    _progressView.center = CGPointMake(75, 75);
    [_squareBackground addSubview:_progressView];
    
    _fmIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    _fmIconImageView.image = [UIImage imageNamed:@"lumi_fm_volume_background"];
    _fmIconImageView.center = CGPointMake(self.bounds.size.width /2, self.bounds.size.height /2 - 15) ;
    _fmIconImageView.autoresizingMask = viewAutoresizing;
    [self addSubview:_fmIconImageView];
    
    _labelInfo.text = info;
    CGFloat textHeight = [info boundingRectWithSize:CGSizeMake(_labelInfo.frame.size.width, 200) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:17.0f] } context:nil].size.height;
    [_labelInfo setFrame:CGRectMake(0, 0, _labelInfo.frame.size.width, textHeight)];
    _labelInfo.center = CGPointMake(_squareBackground.center.x, _squareBackground.center.y + 30);
    [self addSubview:_labelInfo];
    
    _progressView.hidden = NO;
    _progressView.progress = progressPrecent;
    
    //这个特殊处理，不使用顶层窗口
    _window.hidden = YES;
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate.window addSubview:self];
}

-(void)setFMVolume:(CGFloat)progress
{
    if(_progressView.hidden){
        _progressView.hidden = NO;
    }
    if(!_progressView){
        _progressView = [SDPieProgressView progressView];
        _progressView.frame = CGRectMake(0, 0, 78, 78);
        _progressView.center = CGPointMake(160/2, 40);
        _progressView.progress = progress;
    }
    
    if(progress == 1.0) {
        progress = progress - 0.0001;
        _progressView.progress = progress;
    }
    else if (progress > 1.0) {
        _progressView.progress = 0.9999;
    }else{
        _progressView.progress = progress;
    }
}

#pragma mark - volume
-(void)showVolumeViewWithTips:(NSString *)tips{
    
    NSMutableDictionary* context = [[NSMutableDictionary alloc] initWithCapacity:3];
    
    if (tips) [context setObject:tips forKey:KeyForTipsContextInfo];
    
    NSNumber* modelFlag = [[NSNumber alloc] initWithBool:YES];
    [context setObject:modelFlag forKey:KeyForTipsContextModelFlag];
    _window.hidden = NO;
    
    [self performSelectorOnMainThread:@selector(showVolumeOnMainTread:)
                           withObject:context
                        waitUntilDone:NO];
    context = nil;
    modelFlag = nil;
}

- (void)showVolumeOnMainTread:(NSDictionary*)diction
{
    NSString* info = [diction objectForKey:KeyForTipsContextInfo];
    NSNumber* modelFlag = [diction objectForKey:KeyForTipsContextModelFlag];
    BOOL isModal = [modelFlag boolValue];
    
    _boardView.hidden =YES;
    
    //background
    UIViewAutoresizing viewAutoresizing = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    _squareBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    UIImage* bgImage = [UIImage imageNamed:@"lumi_tip_squareBak"];
    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    _squareBackground.image = bgImage;
    _squareBackground.center = CGPointMake(self.bounds.size.width /2, self.bounds.size.height /2) ;
    _squareBackground.autoresizingMask = viewAutoresizing;
    [self addSubview:_squareBackground];
    
    self.hidden = NO;
    [self setModal:isModal];
    
    //info
    _labelInfo.text = info;
    [_labelInfo sizeToFit];
    _labelInfo.center = CGPointMake(_squareBackground.frame.size.width/2, _squareBackground.frame.size.height - 30);
    _labelInfo.textAlignment = NSTextAlignmentCenter;
    _labelInfo.backgroundColor = [UIColor clearColor];
    _labelInfo.layer.cornerRadius = 6.0;
    _imageView.hidden = YES;

    //mic
    UIImageView *mic = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lumi_tip_mic"]];
    mic.center = CGPointMake(_squareBackground.frame.size.width / 2 - 20, _squareBackground.frame.size.height/2-10);

    //volume
    CGRect rect = CGRectMake(0, 0, _squareBackground.frame.size.width/6, mic.frame.size.height);
    _volumeView = [[UIView alloc] initWithFrame:rect];
    _volumeView.backgroundColor = [UIColor clearColor];
    _volumeView.center = CGPointMake(_squareBackground.frame.size.width / 2 + 20, _squareBackground.frame.size.height/2-10);
    [self setVolume:100];

    [_squareBackground addSubview:_volumeView];
    [_squareBackground addSubview:mic];
    [_squareBackground addSubview:_labelInfo];
    
    //这个特殊处理，不使用顶层窗口
    _window.hidden = YES;
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if(self.rescordStatus == Recording_Start) {
        [delegate.window addSubview:self];
    }
    else{
        [_squareBackground.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_squareBackground removeFromSuperview];
    }
}

-(void)setVolume:(int)volume
{
    [_volumeView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat barHeight = _volumeView.frame.size.height / 7.f; //(7bar + 6间隙)
    
    int level = [[NSNumber numberWithDouble:volume / 100.f * 7.f] intValue];
    for (int i = 1 ; i <= level ; i ++){
        CGFloat x = 0;
        CGFloat y = _volumeView.frame.size.height - barHeight * i;
        CGFloat width = _volumeView.frame.size.width/ 3 / 7.f * i + _volumeView.frame.size.width /3 ;
        CGRect rect = CGRectMake(x, y, width, barHeight);
        MHVolumeBarView *bar = [[MHVolumeBarView alloc] initWithFrame:rect andColor:[UIColor whiteColor] Level:i];
        [_volumeView addSubview:bar];
    }
}

#pragma mark - cancel inter
-(void)showCancelView{
    NSMutableDictionary* context = [[NSMutableDictionary alloc] initWithCapacity:3];
    
    [context setObject:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.recordCanceled", @"plugin_gateway",nil) forKey:KeyForTipsContextInfo];
    
    NSNumber* modelFlag = [[NSNumber alloc] initWithBool:YES];
    [context setObject:modelFlag forKey:KeyForTipsContextModelFlag];
    _window.hidden = NO;
    
    
    [self performSelectorOnMainThread:@selector(showCancelOnMainTread:)
                           withObject:context
                        waitUntilDone:NO];
    context = nil;
    modelFlag = nil;
}

- (void)showCancelOnMainTread:(NSDictionary*)diction
{
    NSString* info = [diction objectForKey:KeyForTipsContextInfo];
    NSNumber* modelFlag = [diction objectForKey:KeyForTipsContextModelFlag];
    BOOL isModal = [modelFlag boolValue];
    
    _boardView.hidden =YES;
    
    //background
    UIViewAutoresizing viewAutoresizing = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    _squareBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    UIImage* bgImage = [UIImage imageNamed:@"lumi_tip_squareBak"];
    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    _squareBackground.image = bgImage;
    _squareBackground.center = CGPointMake(self.bounds.size.width /2, self.bounds.size.height /2) ;
    _squareBackground.autoresizingMask = viewAutoresizing;
    [self addSubview:_squareBackground];
    
    self.hidden = NO;
    [self setModal:isModal];
    
    //info
    _labelInfo.text = info;
    _labelInfo.textAlignment = NSTextAlignmentCenter;
    _labelInfo.center = CGPointMake(_squareBackground.frame.size.width/2, _squareBackground.frame.size.height - 30);
    _imageView.hidden = YES;

    CGFloat x = _labelInfo.frame.origin.x - 5;
    CGFloat y = _labelInfo.frame.origin.y - 3;
    CGFloat width = _labelInfo.frame.size.width + 10;
    CGFloat height = _labelInfo.frame.size.height + 6;
    UIView *labelback = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    labelback.backgroundColor = [UIColor colorWithRed:74.f/255.f green:23.f/255.f blue:37.f/255.f alpha:1.0];
    labelback.layer.cornerRadius = 6.0;

    //cancel
    UIImageView *cancelview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lumi_tip_quite"]];
    cancelview.center = CGPointMake(_squareBackground.frame.size.width / 2, _squareBackground.frame.size.height/2-10);
    
    [_squareBackground addSubview:labelback];
    [_squareBackground addSubview:cancelview];
    [_squareBackground addSubview:_labelInfo];
    
    //这个特殊处理，不使用顶层窗口
    _window.hidden = YES;
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate.window addSubview:self];
}

#pragma mark - 通用操作
- (void)hide
{
    [_squareBackground.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_squareBackground removeFromSuperview];
    
    [_playBackgroundView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_playBackgroundView removeFromSuperview];
    
    if(_boardView.hidden == NO) [_boardView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_progressView removeFromSuperview];
    
    [self removeFromSuperview];
    _window.hidden = YES;
}

+ (MHMusicTipsView *)shareInstance
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        gTipsView = [[MHMusicTipsView alloc] initMHtips];
    });
    return gTipsView;
}

@end
