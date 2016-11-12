//
//  MHLumiFMCell.m
//  MiHome
//
//  Created by Lynn on 11/16/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLumiFMCell.h"
#import "MHLumiXMRadio.h"
#import "MHImageView.h"

#define ImageSize 60.f
#define BtnSize   42.f
#define CellSize  76.f
#define screenWidth CGRectGetWidth([[UIScreen mainScreen] bounds])

@interface MHLumiFMCell ()

@property (nonatomic,strong) MHImageView *coverImage;

@end

@implementation MHLumiFMCell
{
    UIImageView *           _animationImageView;
    UILabel *               _contentTitle;
    UILabel *               _contentSubTitle;
    UILabel *               _contentFoot;
    UIButton *              _collectionButton;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self buildSubviews];
    }
    return self;
}

- (void)setIsAnimation:(BOOL)isAnimation {
    _isAnimation = isAnimation ;
    
    if (isAnimation) {
        _animationImageView.hidden = NO;
        NSArray *imageArray = @[ [UIImage imageNamed:@"lumi_fm_play_animation_1"] ,
                                 [UIImage imageNamed:@"lumi_fm_play_animation_2"] ,
                                 [UIImage imageNamed:@"lumi_fm_play_animation_3"] ,
                                 [UIImage imageNamed:@"lumi_fm_play_animation_4"] ];
        _animationImageView.animationImages = imageArray;
        _animationImageView.animationDuration = 1.5;
        [_animationImageView startAnimating];
        _contentTitle.frame = CGRectMake(ImageSize + 30.f, CellSize * 0.5 - 14.f, screenWidth - 3 * ImageSize, 28.f);
    }
    else {
        _contentTitle.frame = CGRectMake(ImageSize + 30.f, CellSize * 0.5 - 14.f, screenWidth - 2.5 * ImageSize, 28.f);
        _animationImageView.hidden = YES;
    }
}

- (void)configureWithDataObject:(id)object {
    
    MHLumiXMRadio *radio = (MHLumiXMRadio *)object;
    _contentTitle.text = radio.radioName;
    _contentSubTitle.text = [NSString stringWithFormat:@"%@：%@",
                             NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.program", @"plugin_gateway", nil),
                             radio.currentProgram.length ? radio.currentProgram : NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.program.none", @"plugin_gateway", nil)];

    _contentFoot.text = [NSString stringWithFormat:@"%0.2f%@",
                         [radio.radioPlayCount doubleValue] / 10000.f,
                         NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.program.count", @"plugin_gateway", nil)];
    
    if([radio.radioCollection isEqualToString:@"yes"]){
        [_collectionButton setImage:[UIImage imageNamed:@"lumi_fm_shoucanged"] forState:UIControlStateNormal];
    }
    else{
        [_collectionButton setImage:[UIImage imageNamed:@"lumi_fm_shoucang"] forState:UIControlStateNormal];
    }
    
    _coverImage.imageUrl = radio.radioCoverSmallUrl;
    [_coverImage loadImage];
}

- (void)buildSubviews {
    
    _coverImage = [[MHImageView alloc] init];
    _coverImage.frame = CGRectMake(20, 10, ImageSize, ImageSize);
    _coverImage.placeHolderImage = [UIImage imageNamed:@"lumi_fm_cover_placeholder"];
    _coverImage.layer.borderWidth = 0.5;
    _coverImage.layer.borderColor = [MHColorUtils colorWithRGB:0xf1f1f1].CGColor;
    [self.contentView addSubview:_coverImage];
    
    _contentTitle = [[UILabel alloc] initWithFrame:CGRectMake(ImageSize + 30.f, CellSize * 0.5 - 14.f, screenWidth - 2.5 * ImageSize, 28.f)];
    _contentTitle.textColor = [MHColorUtils colorWithRGB:0x333333];
    _contentTitle.backgroundColor = [UIColor clearColor];
    _contentTitle.font = [UIFont systemFontOfSize:16.f];
    [self.contentView addSubview:_contentTitle];
    
//    _contentSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(ImageSize + 20.f, 30, screenWidth - ImageSize, 25.f)];
//    _contentSubTitle.textColor = [MHColorUtils colorWithRGB:0x888888];
//    _contentSubTitle.backgroundColor = [UIColor clearColor];
//    _contentSubTitle.font = [UIFont systemFontOfSize:13.f];
//    [self.contentView addSubview:_contentSubTitle];
//    
//    _contentFoot = [[UILabel alloc] initWithFrame:CGRectMake(ImageSize + 20.f, 55.f, screenWidth - ImageSize, 15.f)];
//    _contentFoot.textColor = [MHColorUtils colorWithRGB:0x888888];
//    _contentFoot.backgroundColor = [UIColor clearColor];
//    _contentFoot.font = [UIFont systemFontOfSize:13.f];
//    [self.contentView addSubview:_contentFoot];
    
    _collectionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _collectionButton.frame = CGRectMake(0, 0, BtnSize, BtnSize);
    [_collectionButton setImage:[UIImage imageNamed:@"lumi_fm_shoucang"] forState:UIControlStateNormal];
    _collectionButton.center = CGPointMake(screenWidth - BtnSize, _coverImage.center.y);
    [_collectionButton addTarget:self action:@selector(onCollectionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_collectionButton];
    
    _animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                        (CellSize -BtnSize) / 2 ,
                                                                        30,
                                                                        30)];
    _animationImageView.center = CGPointMake(_collectionButton.center.x - 35, _collectionButton.center.y);
    if(self.isAnimation) _animationImageView.hidden = NO;
    else _animationImageView.hidden = YES;
    [self.contentView addSubview:_animationImageView];
    
    UIView *bottomLine = [[UIView alloc] init];
    [bottomLine setFrame:CGRectMake(20.0f, CellSize - 1.0f, screenWidth - 40.f, 1.0f)];
    bottomLine.backgroundColor = [MHColorUtils colorWithRGB:0xf1f1f1];
    [self.contentView addSubview:bottomLine];
}

- (void)onCollectionBtnClicked:(id)sender {
    if(self.onCollectionClicked)self.onCollectionClicked(self);
}

@end
