//
//  MHACPartnerTimerCell.m
//  MiHome
//
//  Created by ayanami on 16/5/20.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerTimerCell.h"
#import <MiHomeKit/MHDataDeviceTimer.h>

@interface MHACPartnerTimerCell ()

@property (nonatomic, copy) MHDataDeviceTimer *timerItem;
@property (nonatomic, strong) UILabel *timespanLabel;
@property (nonatomic, strong) UILabel *repeatTypeLabel;

@property (nonatomic, strong) UILabel *labelOff;

@property (nonatomic, strong) UILabel *modeLabel;
@property (nonatomic, strong) UILabel *windsLabel;
@property (nonatomic, strong) UILabel *temperatureLabel;

@property (nonatomic, strong) UIView *verticalLine;//竖直分割线
@property (nonatomic, strong) UIView *bottomLine;//底部分割线
@end

@implementation MHACPartnerTimerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self buildSubviews];
        [self buildConstraints];
    }
    return self;
}

- (void)configureWithDataObject:(MHDataDeviceTimer *)timer acpartner:(MHDeviceAcpartner *)acpartner {
//    NSLog(@"开启参数%@", timer.onParam);
//    NSLog(@"关闭参数%@", timer.offParam);
//    [acpartner analyzeHexInfo:nil decimalInfo:[[timer.onParam firstObject] intValue] type:PROP_TIMER];

    
    NSString *strOn = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.timer.on",@"plugin_gateway","开启");
    NSString *strOff = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.timer.off",@"plugin_gateway","关闭");
    
    _timerItem = timer;
    if (timer.isOnOpen && timer.isOffOpen) {
        [acpartner analyzeHexInfo:nil decimalInfo:[[timer.onParam firstObject] intValue] type:PROP_TIMER];
        _timespanLabel.text = [NSString stringWithFormat:@"%@-%@", [timer getOnTimeString],  [timer getOffTimeString]];
    }
    else if (timer.isOnOpen && !timer.isOffOpen) {
        [acpartner analyzeHexInfo:nil decimalInfo:[[timer.onParam firstObject] intValue] type:PROP_TIMER];
        _timespanLabel.text = [NSString stringWithFormat:@"%@ %@", [timer getOnTimeString], strOn];
        
    }
    else if (!timer.isOnOpen && timer.isOffOpen) {
        _timespanLabel.text = [NSString stringWithFormat:@"%@ %@", [timer getOffTimeString], strOff];
//        [acpartner analyzeHexInfo:nil decimalInfo:[[timer.offParam firstObject] intValue] type:PROP_TIMER];
        
    }
    
    if (acpartner.timerACType >= 2 && timer.isOnOpen) {
        _temperatureLabel.text = [NSString stringWithFormat:@"%d℃", acpartner.timerTemperature ? : 24];
        _modeLabel.text = modeArray[acpartner.timerModeState];
        _windsLabel.text = windPowerArray[acpartner.timerWindPower];
        _labelOff.text = nil;
    }
    else {
        _temperatureLabel.text = nil;
        _modeLabel.text = nil;
        _windsLabel.text = nil;
        _labelOff.text = timer.isEnabled ? strOn : strOff;
    }
    
    NSLog(@"%ld,模式%d,  风速%d, 温度%d",  timer.timerId,acpartner.timerModeState, acpartner.timerWindPower, acpartner.timerTemperature);

    
    
    if (timer.onRepeatType == MHDeviceTimerRepeat_Once) {
        _repeatTypeLabel.text = NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.once",@"plugin_gateway","执行一次");
    }
    else if (timer.onRepeatType == MHDeviceTimerRepeat_Workday){
        _repeatTypeLabel.text = NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.workday",@"plugin_gateway","周一到周五");
    }
    else {
        _repeatTypeLabel.text = [_timerItem getOffRepeatTypeString];
    }
    _switcher.on = _timerItem.isEnabled;
    
    [self rebuildConstraints];

}



- (void)buildSubviews {
    
  
    
    _timespanLabel = [[UILabel alloc] init];
    _timespanLabel.font = [UIFont systemFontOfSize:14 * ScaleWidth];
    _timespanLabel.textColor = [MHColorUtils colorWithRGB:0x3e3e3e];
    [self.contentView addSubview:_timespanLabel];
    
    _repeatTypeLabel = [[UILabel alloc] init];
    _repeatTypeLabel.font = [UIFont systemFontOfSize:14 * ScaleWidth];
    _repeatTypeLabel.textColor = [MHColorUtils colorWithRGB:0x3e3e3e];
    [self.contentView addSubview:_repeatTypeLabel];
    
    _verticalLine = [[UIView alloc] init];
    _verticalLine.backgroundColor = [MHColorUtils colorWithRGB:0xf1f1f1];
    [self.contentView addSubview:_verticalLine];

    _labelOff = [[UILabel alloc] init];
    _labelOff.font = [UIFont systemFontOfSize:14 * ScaleWidth];
    _labelOff.textColor = [MHColorUtils colorWithRGB:0x3e3e3e];
    [self.contentView addSubview:_labelOff];
    
    
    _modeLabel = [[UILabel alloc] init];
    _modeLabel.text = @"   ";
    _modeLabel.font = [UIFont systemFontOfSize:14 * ScaleWidth];
    _modeLabel.textColor = [MHColorUtils colorWithRGB:0x5f5f5f];
    [self.contentView addSubview:_modeLabel];
    
    _windsLabel = [[UILabel alloc] init];
    _windsLabel.font = [UIFont systemFontOfSize:14 * ScaleWidth];
    _windsLabel.textColor = [MHColorUtils colorWithRGB:0x3e3e3e];
    [self.contentView addSubview:_windsLabel];
    

    _temperatureLabel = [[UILabel alloc] init];
    _temperatureLabel.font = [UIFont systemFontOfSize:14 * ScaleWidth];
    _temperatureLabel.textColor = [MHColorUtils colorWithRGB:0x3e3e3e];
    [self.contentView addSubview:_temperatureLabel];
    

    
    _switcher = [[UISwitch alloc] init];
    _switcher.on = _timerItem.isEnabled;
    [_switcher addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_switcher];
    
    _bottomLine = [[UIView alloc] init];
    _bottomLine.backgroundColor = [MHColorUtils colorWithRGB:0xf1f1f1];
    [self.contentView addSubview:_bottomLine];
}

- (void)buildConstraints {
    CGFloat hLeadSpacing = 15 * ScaleWidth;
    CGFloat hSpacing1 = 5 * ScaleWidth;
    CGFloat hTrailSpacing = 15 * ScaleWidth;
    CGFloat vLeadSpacing = 10;
    CGFloat vSpacing = 8;
    
    CGFloat verticalLineHeight = 30;
    CGFloat verticalLineSpacing = 110 * ScaleWidth;
    
    XM_WS(weakself);
    [self.timespanLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.contentView).with.offset(hLeadSpacing);
        make.top.equalTo(weakself.contentView).with.offset(vLeadSpacing);
    }];
    
    [self.repeatTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.contentView).with.offset(hLeadSpacing);
        make.top.equalTo(weakself.timespanLabel.mas_bottom).with.offset(vSpacing);
    }];
    
    [self.verticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakself.contentView);
        make.size.mas_equalTo(CGSizeMake(1, verticalLineHeight));
        make.left.equalTo(weakself.contentView).with.offset(verticalLineSpacing);
    }];
    
    [self.labelOff mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.verticalLine).with.offset(hLeadSpacing);
        make.centerY.equalTo(weakself.contentView);
    }];
    
    [self.modeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.verticalLine).with.offset(hLeadSpacing);
        make.centerY.equalTo(weakself.contentView);
    }];
    
    [self.windsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.modeLabel.mas_right).with.offset(hSpacing1);
        make.centerY.equalTo(weakself.contentView);
    }];

    [self.temperatureLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.windsLabel.mas_right).with.offset(hSpacing1);
        make.centerY.equalTo(weakself.contentView);
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
//    XM_WS(weakself);
//    CGFloat hSpacing1 = 5;
//    [self.labelOn mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(weakself.colorImageView.mas_right).with.offset(hSpacing1);
//    }];
//    
//    [self.labelRepeatType mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(weakself.colorImageView.mas_right).with.offset(hSpacing1);
//    }];
}

- (void)onSwitch:(id)sender {
    _timerItem.isEnabled = !_timerItem.isEnabled;
    if (_onSwitch) {
        _onSwitch(_timerItem);
    }
}


@end
