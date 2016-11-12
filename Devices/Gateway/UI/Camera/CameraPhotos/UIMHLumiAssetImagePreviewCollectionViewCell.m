//
//  UIMHLumiAssetImagePreviewCollectionViewCell.m
//  Lumi_demo_OC
//
//  Created by Noverre on 2016/10/30.
//  Copyright © 2016年 LM21Mac002. All rights reserved.
//

#import "UIMHLumiAssetImagePreviewCollectionViewCell.h"
#import <Photos/Photos.h>

@interface UIMHLumiAssetImagePreviewCollectionViewCell()<UIScrollViewDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, copy) NSString *todoIdentifier;
@property (nonatomic, strong) PHImageManager *imageManager;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation UIMHLumiAssetImagePreviewCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.imageSize = CGSizeMake(80, 80);
        [self.contentView addSubview:self.scrollView];
        [self.scrollView addSubview:self.imageView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.scrollView.frame = self.contentView.bounds;
    [self updateImageViewFrame];
}

+ (NSString *)imageCellReuseIdentifier{
    static NSString *kImageCellReuseIdentifier = @"imageCellReuseIdentifier.UIMHLumiAssetImagePreviewCollectionViewCellr";
    return kImageCellReuseIdentifier;
}

- (void)updateImageViewFrame{
    CGFloat centerX = self.scrollView.center.x;
    CGFloat centerY = self.scrollView.center.y;
    centerX = self.scrollView.contentSize.width > self.scrollView.frame.size.width ? self.scrollView.contentSize.width/2 : centerX;
    centerY = self.scrollView.contentSize.height > self.scrollView.frame.size.height ? self.scrollView.contentSize.height/2 : centerY;
    self.imageView.center = CGPointMake(centerX, centerY);
}

- (void)configureCellWithAsset:(PHAsset *)asset{
    self.asset = asset;
    self.imageSize = [self imageViewSizeWithAsset:asset];
    self.imageView.frame = CGRectMake(0, 0, self.imageSize.width, self.imageSize.height);
    [self updateImageViewFrame];
    __weak typeof(self) weakself = self;
    [self requestImageForAsset:asset resultHandler:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakself.imageView.image = image;
        });
    }];
}

- (void)resetCell{
    [self.scrollView setZoomScale:1 animated:NO];
    self.imageSize = CGSizeMake(80, 80);
    self.imageView.frame = CGRectMake(0, 0, self.imageSize.width, self.imageSize.height);
    [self updateImageViewFrame];
}

#pragma mark - event response
- (void)scrollViewTapAction:(UITapGestureRecognizer *)sender{
    if ([self.delegate respondsToSelector:@selector(imagePreviewCollectionViewCellDidTap:)]){
        [self.delegate imagePreviewCollectionViewCellDidTap:self];
    }
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    [self updateImageViewFrame];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view {
    if ([self.delegate respondsToSelector:@selector(imagePreviewCollectionViewCellWillZoom:)]){
        [self.delegate imagePreviewCollectionViewCellWillZoom:self];
    }
}

#pragma mark - private function
- (void)requestImageForAsset:(PHAsset *)asset resultHandler:(void(^)(UIImage *image))resultHandler{
    CGSize imageViewSize = [self imageViewSizeWithAsset:asset];
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(imageViewSize.width*scale , imageViewSize.height*scale);
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.resizeMode = PHImageRequestOptionsResizeModeNone;
    self.todoIdentifier = asset.localIdentifier;
    __weak typeof(self) weakself = self;
    PHImageRequestID todoRequestID = [self.imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        __strong typeof(weakself) strongself = weakself;
        if ([strongself.todoIdentifier isEqualToString:asset.localIdentifier]){
            resultHandler(result);
        }else{
            [strongself.imageManager cancelImageRequest:todoRequestID];
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
- (UIImageView *)imageView{
    if (!_imageView) {
        UIImageView *aImageView = [[UIImageView alloc] init];
        _imageView = aImageView;
    }
    return _imageView;
}

- (PHImageManager *)imageManager{
    return [PHImageManager defaultManager];
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        UIScrollView *sv = [[UIScrollView alloc] init];
        sv.delegate = self;
        sv.minimumZoomScale = 1;
        sv.maximumZoomScale = 4;
        sv.bounces = NO;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapAction:)];
        [sv addGestureRecognizer:tap];
        _scrollView = sv;
    }
    return _scrollView;
}
@end
