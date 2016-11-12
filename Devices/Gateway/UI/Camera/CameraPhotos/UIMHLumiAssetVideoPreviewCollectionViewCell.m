//
//  UIMHLumiAssetVideoPreviewCollectionViewCell.m
//  Lumi_demo_OC
//
//  Created by Noverre on 2016/10/30.
//  Copyright © 2016年 LM21Mac002. All rights reserved.
//

#import "UIMHLumiAssetVideoPreviewCollectionViewCell.h"
#import <Photos/Photos.h>
#import "MHLumiAVPlayerView.h"

@interface UIMHLumiAssetVideoPreviewCollectionViewCell()
@property (nonatomic, strong) MHLumiAVPlayerView *playerView;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, copy) NSString *todoIdentifier;
@property (nonatomic, strong) UIButton *playButton;
@end
//lumi_camera_video_play_button
@implementation UIMHLumiAssetVideoPreviewCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.isPlaying = NO;
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (self.playerView){
        [self updatePlayerViewFrame];
    }
    if (self.playButton.superview){
        self.playButton.frame = CGRectMake(0, 0, 50, 50);
        self.playButton.center = self.playButton.superview.center;
    }
}

- (void)updatePlayerViewFrame{
    CGSize size = [self imageViewSizeWithAsset:self.asset];
    self.playerView.frame = CGRectMake(0, 64, size.width, size.height);
    CGFloat x = CGRectGetWidth(self.contentView.bounds)/2;
    CGFloat y = CGRectGetHeight(self.contentView.bounds)/2;
    self.playerView.center = CGPointMake(x, y);
}

- (void)configureCellWithAsset:(PHAsset *)asset{
    self.asset = asset;
    self.isPlaying = NO;
    [self.contentView addSubview:self.playButton];
    [self initPlayerViewWithAsset:asset];
}

+ (NSString *)videoCellReuseIdentifier{
    static NSString *kImageCellReuseIdentifier = @"imageCellReuseIdentifier.UIMHLumiAssetVideoPreviewCollectionViewCell";
    return kImageCellReuseIdentifier;
}

- (void)addAndResetFramePlayerView:(MHLumiAVPlayerView *)playerView{
    self.playerView = playerView;
    [self.contentView insertSubview:playerView belowSubview:self.playButton];
    [self updatePlayerViewFrame];
}

#pragma mark - event response
- (void)playButtonAction:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(videoPreviewCollectionViewCell:didTapPlayButton:)]){
        [self.delegate videoPreviewCollectionViewCell:self didTapPlayButton:sender];
    }else{
        if (self.isPlaying){
            [self playerViewPause];
        }else{
            [self playerViewPlay];
        }
    }
}

- (void)playerViewPlay{
    self.isPlaying = YES;
    [[self.playerView player] play];
    self.playButton.selected = YES;
}

- (void)playerViewPause{
    self.isPlaying = NO;
    [[self.playerView player] pause];
    self.playButton.selected = NO;
}

- (void)playerViewEndToPlay{
    [[self.playerView player] seekToTime:kCMTimeZero];
    [self playerViewPause];
    if ([self.delegate respondsToSelector:@selector(videoPreviewCollectionViewCellPlayerViewEndToPlay:)]) {
        [self.delegate videoPreviewCollectionViewCellPlayerViewEndToPlay:self];
    }
}

#pragma mark - private function
- (void)initPlayerViewWithAsset:(PHAsset *)asset{
    self.todoIdentifier = asset.localIdentifier;
    __weak typeof(self) weakself = self;
    [asset requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
        if (contentEditingInput.avAsset && [asset.localIdentifier isEqualToString:weakself.todoIdentifier]){
            dispatch_async(dispatch_get_main_queue(), ^{
                AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:contentEditingInput.avAsset];
                AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
                if (weakself.playerView){
                    [[weakself.playerView player] pause];
                    [weakself.playerView removeFromSuperview];
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[weakself.playerView player].currentItem];
                }
                weakself.playerView = [[MHLumiAVPlayerView alloc] initWithFrame:CGRectZero withPlayer:player];
                [weakself.contentView insertSubview:weakself.playerView belowSubview:weakself.playButton];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerViewEndToPlay) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
                [weakself updatePlayerViewFrame];
            });
        }
    }];
}

- (CGSize)imageViewSizeWithAsset:(PHAsset *)asset{
    CGSize size = CGSizeZero;
    CGFloat assetWidth = asset.pixelWidth;///[UIScreen mainScreen].scale;
    CGFloat assetHeight = asset.pixelHeight;///[UIScreen mainScreen].scale;
    CGFloat width = assetWidth;
    CGFloat height = assetHeight;
    width = MIN(CGRectGetWidth(self.contentView.bounds), assetWidth);
    height = width*(assetHeight/assetWidth);
    if (height > CGRectGetHeight(self.contentView.bounds)){
        height = CGRectGetHeight(self.contentView.bounds);
        width = height*(assetWidth/assetHeight);
    }
    size = CGSizeMake(width, height);
    return size;
}

#pragma mark - getter and setter
- (UIButton *)playButton{
    if (!_playButton) {
        UIButton *aButton = [[UIButton alloc] init];
        [aButton setImage:[UIImage imageNamed:@"lumi_camera_video_play"] forState:UIControlStateNormal];
        [aButton setImage:[UIImage imageNamed:@"lumi_camera_video_stop"] forState:UIControlStateSelected];
        [aButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _playButton = aButton;
    }
    return _playButton;
}
@end
