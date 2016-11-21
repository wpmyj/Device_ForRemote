//
//  MHLumiPhotoGridCollectionViewCell.h
//  Lumi_demo_OC
//
//  Created by LM21Mac002 on 2016/10/24.
//  Copyright © 2016年 LM21Mac002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/PhotosTypes.h>

@interface MHLumiPhotoGridCollectionViewCell : UICollectionViewCell
+ (NSString *)reuseIdentifier;
@property (copy, nonatomic) NSString *identifierForAsset;
@property (strong, nonatomic) UIImageView *imageView;
- (void)setMediaType:(PHAssetMediaType)type;
- (void)setDurationWithTimeInterval:(NSTimeInterval)seconds;
@end
