//
//  MHLumiVolumeSettingCell.m
//  MiHome
//
//  Created by ayanami on 16/5/20.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiVolumeSettingCell.h"
#import "MHGatewayNumberSliderView.h"

@interface MHLumiVolumeSettingCell ()
@property (nonatomic, strong) MHGatewayNumberSliderView *sliderView;

@end

@implementation MHLumiVolumeSettingCell
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
    [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakself.contentView);
    }];
    if (self.item.type == MHLumiSettingItemTypeBrightness) {
        _sliderView.minusImageName = @"gateway_brightness_minus_icon";
        _sliderView.plusImageName = @"gateway_brightness_plus_icon";
    }
}

- (void)configureConstruct:(NSInteger)value andType:(NSString *)type imageType:(MHLumiSettingItemType)imageType {
    [_sliderView configureConstruct:value];
    [_sliderView setType:type];
    
    if (imageType == MHLumiSettingItemTypeBrightness) {
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
    [_sliderView setType:self.lumiItem.caption];
    [_sliderView setMinimumValue:[[self.lumiItem.accessories valueForKey:MinValue class:[NSNumber class]] integerValue]];
    [_sliderView setMaximumValue:[[self.lumiItem.accessories valueForKey:MaxValue class:[NSNumber class]] integerValue]];
    [_sliderView setSliderValue:[[self.lumiItem.accessories valueForKey:CurValue class:[NSNumber class]] floatValue]];
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
