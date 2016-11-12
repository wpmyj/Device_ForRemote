//
//  MHLumiFMCell.m
//  MiHome
//
//  Created by Lynn on 11/16/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLumiFMCollecttionCell.h"
#import "MHLumiXMRadio.h"
#import "MHImageView.h"

#define ImageSize 60.f
#define BtnSize   30.f
#define CellSize  76.f
#define screenWidth  CGRectGetWidth([[UIScreen mainScreen] bounds])

@interface MHLumiFMCollecttionCell ()

@property (nonatomic,strong) MHImageView *coverImage;

@end

@implementation MHLumiFMCollecttionCell
{
    UILabel *               _contentTitle;
    UIButton *              _collectionButton;
    UIImageView *           _animationImageView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self buildSubviews];
    }
    return self;
}

- (void)configureWithDataObject:(id)object {
    
    _contentTitle.text = [object valueForKey:@"radioName"];
    
    [_collectionButton setImage:[UIImage imageNamed:@"lumi_fm_shoucanged"] forState:UIControlStateNormal];
    
    _coverImage.imageUrl = [object valueForKey:@"radioCoverSmallUrl"];
    [_coverImage loadImage];
}

- (void)setIsAnimation:(BOOL)isAnimation {
    _isAnimation = isAnimation ;
    
    if (isAnimation) {
        _animationImageView.hidden = NO;
        [self animationStart];
        _contentTitle.frame = CGRectMake(ImageSize + 30.f, CellSize * 0.5 - 14.f, screenWidth - 2.5 * ImageSize, 28.f);
    }
    else {
        _contentTitle.frame = CGRectMake(ImageSize + 30.f, CellSize * 0.5 - 14.f, screenWidth - 2 * ImageSize, 28.f);
        _animationImageView.hidden = YES;
    }
}

- (void)buildSubviews {

    _coverImage = [[MHImageView alloc] init];
    _coverImage.placeHolderImage = [UIImage imageNamed:@"lumi_fm_cover_placeholder"];
    _coverImage.frame = CGRectMake(0, 0, ImageSize, ImageSize);
    _coverImage.center = CGPointMake(ImageSize / 2 + 15, CellSize/2);
    _coverImage.layer.borderWidth = 0.8;
    _coverImage.layer.borderColor = [MHColorUtils colorWithRGB:0xf1f1f1].CGColor;
    [self.contentView addSubview:_coverImage];
    
    _contentTitle = [[UILabel alloc] initWithFrame:CGRectMake(ImageSize + 25.f, CellSize/2 - 18, screenWidth - 2 * ImageSize, 40.f)];
    _contentTitle.textColor = [MHColorUtils colorWithRGB:0x333333];
    _contentTitle.backgroundColor = [UIColor clearColor];
    _contentTitle.font = [UIFont systemFontOfSize:16.f];
    [self.contentView addSubview:_contentTitle];
    
//    _collectionButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    _collectionButton.frame = CGRectMake(0, 0, BtnSize, BtnSize);
//    [_collectionButton setImage:[UIImage imageNamed:@"lumi_fm_shoucang"] forState:UIControlStateNormal];
//    _collectionButton.center = CGPointMake(screenWidth - BtnSize, _coverImage.center.y);
//    [_collectionButton addTarget:self action:@selector(onCollectionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:_collectionButton];
    
    _animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth - 2 * BtnSize,
                                                                        (CellSize -BtnSize) / 2 ,
                                                                        BtnSize,
                                                                        BtnSize)];
    if(self.isAnimation) _animationImageView.hidden = NO;
    else _animationImageView.hidden = YES;
    [self.contentView addSubview:_animationImageView];

    if(self.isAnimation) [self animationStart];
    
    UIView *bottomLine = [[UIView alloc] init];
    [bottomLine setFrame:CGRectMake(20.0f, CellSize - 1.0f, screenWidth - 40.f, 1.0f)];
    bottomLine.backgroundColor = [MHColorUtils colorWithRGB:0xf1f1f1];
    [self.contentView addSubview:bottomLine];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:tap];
}

- (void)animationStart {
    NSArray *imageArray = @[ [UIImage imageNamed:@"lumi_fm_play_animation_1"] ,
                             [UIImage imageNamed:@"lumi_fm_play_animation_2"] ,
                             [UIImage imageNamed:@"lumi_fm_play_animation_3"] ,
                             [UIImage imageNamed:@"lumi_fm_play_animation_4"] ];
    _animationImageView.animationImages = imageArray;
    _animationImageView.animationDuration = 1.5;
    [_animationImageView startAnimating];
}

- (void)onCollectionBtnClicked:(id)sender {
    if(self.onCollectionClicked)self.onCollectionClicked(self);
}

- (void)tap:(id)sender {
    if(self.onCellClicked)self.onCellClicked(self);
}

@end
