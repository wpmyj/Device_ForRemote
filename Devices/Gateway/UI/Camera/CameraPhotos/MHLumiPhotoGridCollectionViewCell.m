//
//  MHLumiPhotoGridCollectionViewCell.m
//  Lumi_demo_OC
//
//  Created by LM21Mac002 on 2016/10/24.
//  Copyright © 2016年 LM21Mac002. All rights reserved.
//

#import "MHLumiPhotoGridCollectionViewCell.h"

@interface MHLumiPhotoGridCollectionViewCell()
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIImageView *videoLogoImageView;
@property (nonatomic, strong) UIView *containerView;
@end

@implementation MHLumiPhotoGridCollectionViewCell
//1080 1090
static CGSize videoLogoImageViewSize = {64,55};
static CGSize durationLabelSize = {107,55};
static CGFloat kContainerViewHeight = 55;
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        videoLogoImageViewSize = CGSizeMake([self translateBy1080WithWidth:64], [self translateBy1920WithHeight:55]);
        durationLabelSize = CGSizeMake([self translateBy1080WithWidth:107], [self translateBy1920WithHeight:55]);
        kContainerViewHeight = [self translateBy1920WithHeight:55];
        [self setupSubViews];
        [self configureLayout];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
    CGFloat contentViewHeight = CGRectGetHeight(self.contentView.frame);
    CGFloat contentViewWidth = CGRectGetWidth(self.contentView.frame);
    self.videoLogoImageView.frame = CGRectMake(0,
                                               contentViewHeight-videoLogoImageViewSize.height,
                                               videoLogoImageViewSize.width,
                                               videoLogoImageViewSize.height);
    self.durationLabel.frame = CGRectMake(contentViewWidth-durationLabelSize.width-4,
                                          contentViewHeight-durationLabelSize.height,
                                          durationLabelSize.width,
                                          durationLabelSize.height);
    self.containerView.frame = CGRectMake(0,
                                          contentViewHeight-kContainerViewHeight,
                                          contentViewWidth,
                                          kContainerViewHeight);
}

- (void)setMediaType:(PHAssetMediaType)type{
    if (type == PHAssetMediaTypeVideo){
        self.videoLogoImageView.hidden = NO;
        self.durationLabel.hidden = NO;
        self.containerView.hidden = NO;
    }else{
        self.videoLogoImageView.hidden = YES;
        self.durationLabel.hidden = YES;
        self.containerView.hidden = YES;
    }
}

- (void)setDurationWithTimeInterval:(NSTimeInterval)seconds{
    seconds = ceil(seconds);
    int s = (int)seconds % 60;
    seconds = seconds - s;
    int m = seconds / 60;
    self.durationLabel.text = [NSString stringWithFormat:@"%02d:%02d",m,s];
}

#pragma mark - setupSubViews
- (void)setupSubViews{
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.containerView];
    [self.contentView addSubview:self.videoLogoImageView];
    [self.contentView addSubview:self.durationLabel];
}

- (void)configureLayout{
}

+ (NSString *)reuseIdentifier{
    return @"reuseIdentifier.MHLumiPhotoGridCollectionViewCell";
}

#pragma mark getter and setter
- (UIImageView *)imageView{
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.layer.masksToBounds = YES;
        _imageView = imageView;
    }
    return _imageView;
}

- (UIImageView *)videoLogoImageView{
    if (!_videoLogoImageView) {
        UIImage *logoImage = [UIImage imageNamed:@"cam"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:logoImage];
        imageView.contentMode = UIViewContentModeCenter;
        _videoLogoImageView = imageView;
    }
    return _videoLogoImageView;
}

- (UILabel *)durationLabel{
    if (!_durationLabel){
        UILabel *aLabel = [[UILabel alloc] init];
        aLabel.text = @"00:00";
        aLabel.textColor = [UIColor whiteColor];
        aLabel.textAlignment = NSTextAlignmentRight;
        aLabel.font = [UIFont systemFontOfSize:10];
        aLabel.adjustsFontSizeToFitWidth = YES;
        _durationLabel = aLabel;
    }
    return _durationLabel;
}

- (CGFloat)translateBy1920WithHeight:(CGFloat)height{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    return screenHeight/1920*height;
}

- (CGFloat)translateBy1080WithWidth:(CGFloat)width{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    return screenWidth/1080*width;
}

- (UIView *)containerView{
    if (!_containerView){
        UIView *aView = [[UIView alloc] init];
        aView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _containerView = aView;
    }
    return _containerView;
}
@end
