//
//  UIMHLumiAssetVideoPreviewCollectionViewCell.h
//  Lumi_demo_OC
//
//  Created by Noverre on 2016/10/30.
//  Copyright © 2016年 LM21Mac002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHLumiAVPlayerView.h"

@class UIMHLumiAssetVideoPreviewCollectionViewCell;
@protocol UIMHLumiAssetVideoPreviewCollectionViewCellDelegate <NSObject>
@optional
- (void)videoPreviewCollectionViewCell:(UIMHLumiAssetVideoPreviewCollectionViewCell *)cell
                      didTapPlayButton:(UIButton *)button;
- (void)videoPreviewCollectionViewCellPlayerViewEndToPlay:(UIMHLumiAssetVideoPreviewCollectionViewCell *)cell;
@end

@class PHAsset;
@interface UIMHLumiAssetVideoPreviewCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong, readonly) MHLumiAVPlayerView *playerView;
@property (nonatomic, weak) id<UIMHLumiAssetVideoPreviewCollectionViewCellDelegate> delegate;
@property (nonatomic, strong, readonly) UIButton *playButton;
@property (nonatomic, strong, readonly) PHAsset *asset;
@property (nonatomic, assign) BOOL isPlaying;
+ (NSString *)videoCellReuseIdentifier;
- (void)configureCellWithAsset:(PHAsset *)asset;
- (void)playerViewPlay;
- (void)playerViewPause;
- (void)addAndResetFramePlayerView:(MHLumiAVPlayerView *)playerView;

@end
