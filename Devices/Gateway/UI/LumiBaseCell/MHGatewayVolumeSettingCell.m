//
//  MHGatewayVolumeSettingCell.m
//  MiHome
//
//  Created by guhao on 16/2/1.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayVolumeSettingCell.h"
#import "MHGatewayNumberSliderView.h"

@interface MHGatewayVolumeSettingCell ()

@property (nonatomic, strong) MHGatewayNumberSliderView *sliderView;

@property (nonatomic, copy) NSString *titleType;

@end

@implementation MHGatewayVolumeSettingCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:[self cellStyle] reuseIdentifier:reuseIdentifier];
    if (self) {
        [self buildSubViews];
    }
    return self;
}


+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    
    [self buildConstraints];
    [super updateConstraints];
}

- (void)buildSubViews {
    [super buildSubViews];
    XM_WS(weakself);
    _sliderView = [[MHGatewayNumberSliderView alloc] init];
    _sliderView.numberControlCallBack = ^(NSInteger value, NSString *type){
           [weakself.item.accessories setValue:@(weakself.sliderView.sliderValue) forKey:CurValue];
        if (weakself.item.callbackBlock) {
            weakself.item.callbackBlock(weakself);
        }
        if (weakself.volumeControlCallBack) {
            weakself.volumeControlCallBack(value, type, weakself);
        }
    };
    [self.contentView addSubview:_sliderView];
}
//
- (void)buildConstraints {
    XM_WS(weakself);
    CGFloat padding = 18 * ScaleWidth;
    [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(weakself.contentView);
        make.left.equalTo(self.contentView).offset(padding);
        make.right.equalTo(self.contentView).offset(-padding);
    }];
    if (self.item.type == MHGatewaySettingItemTypeBrightness) {
        _sliderView.minusImageName = @"gateway_brightness_minus_icon";
        _sliderView.plusImageName = @"gateway_brightness_plus_icon";
    }
}
- (void)configureConstruct:(NSInteger)value andType:(NSString *)type {
    [_sliderView configureConstruct:value];
    [_sliderView setType:type];
}

- (void)configureConstruct:(NSInteger)value andType:(NSString *)type imageType:(MHGatewaySettingItemType)imageType {
    [_sliderView configureConstruct:value];
    [_sliderView setType:type];
    
    if (imageType == MHGatewaySettingItemTypeBrightness) {
        _sliderView.minusImageName = @"gateway_brightness_minus_icon";
        _sliderView.plusImageName = @"gateway_brightness_plus_icon";
    }

}

+ (CGFloat)heightWithItem:(MHDeviceSettingItem *)item width:(CGFloat)width
{
    [super heightWithItem:item width:width];
    if (item.customUI) {
        CGFloat cellHeight = [[item.accessories valueForKey:SettingAccessoryKey_CellHeight class:[NSNumber class]] floatValue];
        return cellHeight > 0 ? cellHeight : 60.0f;
    }
    return 60.0f;
}
- (void)fillWithItem:(MHDeviceSettingItem *)item {
    [super fillWithItem:item];
    [_sliderView setType:self.item.caption];
    [_sliderView setMinimumValue:[[self.item.accessories valueForKey:MinValue class:[NSNumber class]] integerValue]];
    [_sliderView setMaximumValue:[[self.item.accessories valueForKey:MaxValue class:[NSNumber class]] integerValue]];
    [_sliderView setSliderValue:[[self.item.accessories valueForKey:CurValue class:[NSNumber class]] floatValue]];
    if (item.customUI) {
        CGFloat captionFontSize = [[item.accessories valueForKey:SettingAccessoryKey_CaptionFontSize class:[NSNumber class]] floatValue];
        if (captionFontSize > 0) {
            _sliderView.titleFont = [UIFont systemFontOfSize:captionFontSize];
        }
        UIColor* captionFontColor = [item.accessories valueForKey:SettingAccessoryKey_CaptionFontColor class:[UIColor class]];
        if (captionFontColor) {
            [_sliderView setTitleColor:captionFontColor];
        }
    }
}



@end
