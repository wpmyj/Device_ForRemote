//
//  UIMHLumiAssetImagePreviewCollectionViewCell.h
//  Lumi_demo_OC
//
//  Created by Noverre on 2016/10/30.
//  Copyright © 2016年 LM21Mac002. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UIMHLumiAssetImagePreviewCollectionViewCell;
@protocol UIMHLumiAssetImagePreviewCollectionViewCellDelegate <NSObject>
@optional
- (void)imagePreviewCollectionViewCellDidTap:(UIMHLumiAssetImagePreviewCollectionViewCell *)cell;
- (void)imagePreviewCollectionViewCellWillZoom:(UIMHLumiAssetImagePreviewCollectionViewCell *)cell;
@end

@class PHAsset;
@interface UIMHLumiAssetImagePreviewCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, weak) id<UIMHLumiAssetImagePreviewCollectionViewCellDelegate> delegate;
+ (NSString *)imageCellReuseIdentifier;
- (void)configureCellWithAsset:(PHAsset *)asset;
- (void)resetCell;
@end
