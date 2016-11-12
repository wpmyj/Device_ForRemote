//
//  MHLumiNamingSpeedCell.m
//  MiHome
//
//  Created by guhao on 4/17/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLumiNamingSpeedCell.h"


@interface MHLumiNamingSpeedCell ()

@property (nonatomic, strong) UIImageView *selectImage;

@end

@implementation MHLumiNamingSpeedCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self buildSubViews];
    }
    return self;
}

- (void)buildSubViews {
    self.locationLabel = [[UILabel alloc] init];
    self.locationLabel.textAlignment = NSTextAlignmentCenter;
    self.locationLabel.textColor = [MHColorUtils colorWithRGB:0x000000];
    self.locationLabel.font = [UIFont systemFontOfSize:14.0f];
    self.locationLabel.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.locationLabel];
    //
    
    self.selectImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lumi_ht_selectedCity"]];
    self.selectImage.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:self.selectImage];
    

}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    [self buildConstraints];
    
    [super updateConstraints];
}

- (void)buildConstraints {
    XM_WS(weakself);
    [self.locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakself.contentView);
    }];
    
    [self.selectImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.locationLabel.mas_right).with.offset(5 * ScaleWidth);
        make.centerY.equalTo(weakself.contentView);
    }];
}

- (void)setIsSelected:(NSString *)isSelected {
    _isSelected = isSelected;
    self.selectImage.hidden = [isSelected isEqualToString:@"YES"] ? YES : NO;
    self.locationLabel.textColor =  [isSelected isEqualToString:@"YES"] ? [MHColorUtils colorWithRGB:0x000000] :[MHColorUtils colorWithRGB:0x00ba7c];
}

@end
