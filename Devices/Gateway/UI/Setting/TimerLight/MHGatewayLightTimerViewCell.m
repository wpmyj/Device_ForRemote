//
//  MHGatewayLightTimerViewCell.m
//  MiHome
//
//  Created by guhao on 16/1/15.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayLightTimerViewCell.h"
#import <MiHomeKit/MHDataDeviceTimer.h>

#define kRomantic @"light_scene_color_xml_romantic_normal"
#define kPink     @"light_scene_color_xml_pink_normal"
#define kGolden   @"light_scene_color_xml_yellow_normal"
#define kWhite    @"light_scene_color_xml_white_normal"
#define kForest   @"light_scene_color_xml_forest_normal"
#define kBlue     @"light_scene_color_xml_blue_normal"

static NSDictionary *colorNumber = nil;
static NSDictionary *colorString = nil;
@interface MHGatewayLightTimerViewCell ()
@property (nonatomic, strong) MHDataDeviceTimer *timerItem;
@property (nonatomic, strong) UILabel *labelOn;
@property (nonatomic, strong) UILabel *labelRepeatType;
@property (nonatomic, strong) UIImageView *colorImageView;
@property (nonatomic, strong) UIView *bottomLine;//分割线

@end

@implementation MHGatewayLightTimerViewCell {
    MHDataDeviceTimer*  _timerItem;
    NSArray*            _constraints_H;
    NSArray*            _constraints_V;
    NSArray*            _repeatTypeH;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        colorNumber = @{ @(0x2beb6877):kPink, @(0x2bffd700):kGolden, @(0x2b00ff7f):kForest,@(0x2b9400d3):kRomantic, @(0x2b7dd2f0):kWhite, @(0x2b0900fa):kBlue };
        colorString = @{ @"736847991":kPink, @"738187008":kGolden, @"721485695":kForest, @"731119827":kRomantic, @"722010362":kBlue, @"729666288":kWhite };
        _timerItem.isOnOpen = _timerItem.isOffOpen = YES;
        [self buildSubviews];
        [self buildConstraints];
    }
    return self;
}

- (void)configureWithDataObject:(MHDataDeviceTimer *)timer {
    _timerItem = timer;
    _labelOn.text = [_timerItem timerTitle];
    _labelRepeatType.text = [_timerItem timerDetail];
    _switcher.on = _timerItem.isEnabled;
    
    
    _colorImageView.image =  [UIImage imageNamed:[_timerItem.onParam[0] isKindOfClass:[NSString class]] ? colorString[_timerItem.onParam[0]] : colorNumber[_timerItem.onParam[0]]];
    [self rebuildConstraints];
}

- (void)buildSubviews {
    
    _colorImageView = [[UIImageView alloc] init];
    _colorImageView.image = [UIImage imageNamed:@"light_scene_color_xml_pink_normal"];
    [self.contentView addSubview:_colorImageView];
    
    _labelOn = [[UILabel alloc] init];
    //    _labelOn.text = NSLocalizedString(@"mydevice.timersetting.on","开启");
    _labelOn.font = [UIFont systemFontOfSize:14];
    _labelOn.textColor = [MHColorUtils colorWithRGB:0x3e3e3e];
    [self.contentView addSubview:_labelOn];
    
    _labelRepeatType = [[UILabel alloc] init];
    _labelRepeatType.text = @"   ";
    _labelRepeatType.font = [UIFont systemFontOfSize:10];
    _labelRepeatType.textColor = [MHColorUtils colorWithRGB:0x5f5f5f];
    [self.contentView addSubview:_labelRepeatType];
    
    _switcher = [[UISwitch alloc] init];
    _switcher.on = _timerItem.isOnOpen;
    [_switcher addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_switcher];
    
    _bottomLine = [[UIView alloc] init];
    _bottomLine.backgroundColor = [MHColorUtils colorWithRGB:0xf1f1f1];
    [self.contentView addSubview:_bottomLine];
}

- (void)buildConstraints {
    CGFloat hLeadSpacing = 23;
    CGFloat hSpacing1 = 5;
    CGFloat hTrailSpacing = 23;
    CGFloat vLeadSpacing = 10;
    CGFloat vSpacing = 8;
    CGFloat btnSize = 38;
    
    XM_WS(weakself);
    [self.colorImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.contentView).with.offset(hLeadSpacing);
        make.top.equalTo(weakself.contentView).with.offset(vLeadSpacing);
        make.size.mas_equalTo(CGSizeMake(btnSize, btnSize));
    }];
    
    [self.labelOn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.colorImageView.mas_right).with.offset(hSpacing1);
        make.top.equalTo(weakself.contentView).with.offset(vLeadSpacing);
    }];
    
    [self.labelRepeatType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.colorImageView.mas_right).with.offset(hSpacing1);
        make.top.equalTo(weakself.labelOn.mas_bottom).with.offset(vSpacing);
    }];
    
    [self.switcher mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakself.contentView).with.offset(-hTrailSpacing);
        make.centerY.equalTo(weakself.contentView);
    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.contentView);
        make.bottom.equalTo(weakself.contentView);
        make.size.mas_equalTo(CGSizeMake(WIN_WIDTH - vLeadSpacing * 4, 1.0f));
    }];
}

- (void)rebuildConstraints {
    XM_WS(weakself);
    CGFloat hSpacing1 = 5;
    [self.labelOn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.colorImageView.mas_right).with.offset(hSpacing1);
    }];
    
    [self.labelRepeatType mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.colorImageView.mas_right).with.offset(hSpacing1);
    }];
}

- (void)onSwitch:(id)sender {
    _timerItem.isEnabled = !_timerItem.isEnabled;
    if (_onSwitch) {
        _onSwitch();
    }
}

//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    
//    //绘制cell分隔线
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGPoint start = CGPointMake(20, CGRectGetMaxY(rect)-0.5);
//    CGPoint end = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect)-0.5);
//    draw1PxStroke(ctx, start, end, [MHColorUtils colorWithRGB:0xf1f1f1].CGColor);
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
