//
//  MHACPartnerStatusView.m
//  MiHome
//
//  Created by ayanami on 16/5/31.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerStatusView.h"


@interface MHACPartnerStatusView ()

@property (nonatomic, strong) MHDeviceAcpartner *acpartner;

@property (nonatomic, strong) CAShapeLayer *circle;
@property (nonatomic, strong) UIButton *circleImage;

@property (nonatomic, strong) UILabel *currentMode;
@property (nonatomic, strong) UILabel *currentWinds;
@property (nonatomic, strong) UILabel *currentSwip;
@property (nonatomic, strong) UILabel *currentTemperature;
@property (nonatomic, strong) UILabel *celsius;

@property (nonatomic, strong) UIButton *plusTemp;
@property (nonatomic, strong) UIButton *lessTemp;

@end

@implementation MHACPartnerStatusView

//- (instancetype)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        [self buildSubviews];
//        [self buildConstraints];
//    }
//    return self;
//}

- (id)initWithFrame:(CGRect)frame ACPartner:(MHDeviceAcpartner *)acpartner
{
    self = [super initWithFrame:frame];
    if (self) {
        self.acpartner = acpartner;
        [self buildSubviews];
        [self buildConstraints];
    }
    return self;
}


- (void)buildSubviews {
    _circle = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2) radius:self.frame.size.height / 2 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    _circle.fillColor = [UIColor clearColor].CGColor;//layer填充色
    _circle.strokeColor = [MHColorUtils colorWithRGB:0xffffff alpha:0.3].CGColor;//layer边框色
    _circle.lineWidth =  1;//边框宽度
    _circle.path = path.CGPath;
    [self.layer addSublayer:_circle];
//
//    _circleImage = [UIButton buttonWithType:UIButtonTypeSystem];
//    [_circleImage addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventTouchUpInside];
//    [self.circleImage setImage:[[UIImage imageNamed:@"acpartner_power_off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
//    [self addSubview:_circleImage];
    
    
    _currentTemperature = [[UILabel alloc] init];
    _currentTemperature.textAlignment = NSTextAlignmentCenter;
    _currentTemperature.font = [UIFont  fontWithName:@"DINOffc-CondMedi" size:95.0f];
    _currentTemperature.textColor = self.acpartner.powerState ? [MHColorUtils colorWithRGB:0x030303] : [MHColorUtils colorWithRGB:0xffffff alpha:0.2];
    _currentTemperature.text = [NSString stringWithFormat:@"%d", self.acpartner.temperature];
    [self addSubview:_currentTemperature];
    
    _currentMode = [[UILabel alloc] init];
    _currentMode.textAlignment = NSTextAlignmentCenter;
    _currentMode.font = [UIFont systemFontOfSize:16.0f];
    _currentMode.textColor = self.acpartner.powerState ? [MHColorUtils colorWithRGB:0x030303 alpha:0.7] : [MHColorUtils colorWithRGB:0xffffff alpha:0.2];
    _currentMode.text = modeArray[self.acpartner.modeState];
    [self addSubview:_currentMode];
    
    
    _currentWinds = [[UILabel alloc] init];
    _currentWinds.textAlignment = NSTextAlignmentLeft;
    _currentWinds.font = [UIFont systemFontOfSize:16.0f];
    _currentWinds.textColor = self.acpartner.powerState ? [MHColorUtils colorWithRGB:0x030303 alpha:0.7] : [MHColorUtils colorWithRGB:0xffffff alpha:0.2];
    _currentWinds.text = @"自动";
    [self addSubview:_currentWinds];
    
    _currentSwip = [[UILabel alloc] init];
    _currentSwip.textAlignment = NSTextAlignmentRight;
    _currentSwip.font = [UIFont systemFontOfSize:16.0f];
    _currentSwip.textColor = self.acpartner.powerState ? [MHColorUtils colorWithRGB:0x030303 alpha:0.7] : [MHColorUtils colorWithRGB:0xffffff alpha:0.2];
    _currentSwip.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.airswing",@"plugin_gateway","扫风");
    [self addSubview:_currentSwip];
    _currentSwip.hidden = YES;
 
    
    _celsius = [[UILabel alloc] init];
    _celsius.textAlignment = NSTextAlignmentCenter;
    _celsius.font = [UIFont  fontWithName:@"DINOffc-CondMedi" size:20.0f];
    _celsius.textColor = self.acpartner.powerState ? [MHColorUtils colorWithRGB:0x030303] : [MHColorUtils colorWithRGB:0xffffff alpha:0.2];
    _celsius.text = @"℃";
    [self addSubview:_celsius];

    
    
    _plusTemp = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_plusTemp setBackgroundImage:[UIImage imageNamed:@"acpartner_device_plus"] forState:UIControlStateNormal];
    [_plusTemp setImage:[UIImage imageNamed:@"acpartner_device_plus"] forState:UIControlStateNormal];
    [_plusTemp addTarget:self action:@selector(onPlusTemperature:) forControlEvents:UIControlEventTouchUpInside];
    _plusTemp.tag = 0 + TEMPERATUREBUTTON_TAG;
    [self addSubview:_plusTemp];
    
    _lessTemp = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_lessTemp setBackgroundImage:[UIImage imageNamed:@"acpartner_device_less"] forState:UIControlStateNormal];
    [_lessTemp setImage:[UIImage imageNamed:@"acpartner_device_less"] forState:UIControlStateNormal];
    [_lessTemp addTarget:self action:@selector(onLessTemperature:) forControlEvents:UIControlEventTouchUpInside];
    _lessTemp.tag = 1 + TEMPERATUREBUTTON_TAG;
    [self addSubview:_lessTemp];

}

- (void)buildConstraints {
    XM_WS(weakself);
    
//    CGFloat currentSpacing = 0 * ScaleHeight;
    CGFloat imageSize = 200 * ScaleWidth;
    
//    NSLog(@"%@", image);
    [_circleImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakself);
//        make.size.mas_equalTo(image.size);
        make.size.mas_equalTo(CGSizeMake(imageSize, imageSize));
    }];
    
    
    //显示
    [_currentTemperature mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakself);
    }];
    
    [_currentMode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakself.currentTemperature.mas_top).with.offset(20);
        make.centerX.equalTo(weakself);
    }];
    
    
    [_currentSwip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.currentTemperature.mas_bottom).with.offset(-10);
        make.right.mas_equalTo(weakself.mas_centerX).with.offset(-5);
    }];
    
    [_currentWinds mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(weakself.currentTemperature.mas_bottom).with.offset(-10);
//        make.left.mas_equalTo(weakself.mas_centerX).with.offset(5);
        make.top.equalTo(weakself.currentTemperature.mas_bottom).with.offset(-10);
        make.centerX.equalTo(weakself);
    }];

    
    [_celsius mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakself.currentTemperature.mas_bottom).with.offset(-20);
        make.left.mas_equalTo(weakself.currentTemperature.mas_right);
    }];
    
    [self.plusTemp mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself);
        make.top.equalTo(weakself.mas_top);
        make.size.mas_equalTo(CGSizeMake(56, 32));
    }];
    
    
    [self.lessTemp mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself);
        make.bottom.equalTo(weakself.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(56, 32));
    }];

}

#pragma mark - 控制
- (void)onPlusTemperature:(id)sender {
    if (self.plusCallback) {
        self.plusCallback();
    }
}

- (void)onLessTemperature:(id)sender {
    if (self.lessCallback) {
        self.lessCallback();
    }
    
}

//- (void)onSwitch:(id)sender {
//    if (self.switchCallback) {
//        self.switchCallback();
//    }
//}

- (void)updateStatus {
    
    
//    NSLog(@"%@", modeArray);
//    NSLog(@"第一个模式%@", modeArray[0]);
//    
//    NSLog(@"%@", windPowerArray);
//    NSLog(@"第一个风速%@", windPowerArray[0]);
    
    //
    //
    //
//    NSString *strSwingOn = [NSString stringWithFormat:@"%@", NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.airswing",@"plugin_gateway","扫风")];


    _currentTemperature.text = [NSString stringWithFormat:@"%d", self.acpartner.temperature];
    _currentMode.text = modeArray[self.acpartner.modeState];
    _currentWinds.text = windPowerArray[self.acpartner.windPower];
//    _currentSwip.text = self.acpartner.windState ? @"" : strSwingOn;
    
    self.plusTemp.enabled = self.acpartner.powerState;
    self.lessTemp.enabled = self.acpartner.powerState;
    
    _currentTemperature.textColor = self.acpartner.powerState ? [MHColorUtils colorWithRGB:0xffffff] : [MHColorUtils colorWithRGB:0xffffff alpha:0.2];
    _currentMode.textColor = self.acpartner.powerState ? [MHColorUtils colorWithRGB:0xffffff alpha:0.7] : [MHColorUtils colorWithRGB:0xffffff alpha:0.2];
    _currentWinds.textColor = self.acpartner.powerState ? [MHColorUtils colorWithRGB:0xffffff alpha:0.7] : [MHColorUtils colorWithRGB:0xffffff alpha:0.2];
    _celsius.textColor = self.acpartner.powerState ? [MHColorUtils colorWithRGB:0xffffff] : [MHColorUtils colorWithRGB:0xffffff alpha:0.2];
//    _currentSwip.textColor = self.acpartner.powerState ? [MHColorUtils colorWithRGB:0xffffff alpha:0.7] : [MHColorUtils colorWithRGB:0xffffff alpha:0.2];
//    XM_WS(weakself);
//    if (self.acpartner.windState) {
//        [_currentWinds mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(weakself.currentTemperature.mas_bottom).with.offset(-10);
//            make.centerX.equalTo(weakself);
//        }];
//    }
//    else {
//        [_currentWinds mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(weakself.currentTemperature.mas_bottom).with.offset(-10);
//            make.left.mas_equalTo(weakself.mas_centerX).with.offset(5);
//        }];
//    }

    _plusTemp.alpha = self.acpartner.powerState ?: 0.2;
    _lessTemp.alpha = self.acpartner.powerState ?: 0.2;




//    self.currentTemperature.alpha = self.acpartner.powerState ? 1 : 0.2;
//    self.currentMode.alpha = self.acpartner.powerState ? 1 : 0.2;
//    self.currentWinds.alpha = self.acpartner.powerState ? 1 : 0.2;
//    self.celsius.alpha = self.acpartner.powerState ? 1 : 0.2;

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
