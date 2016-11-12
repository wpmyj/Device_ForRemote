//
//  MHGatewayNightLogicView.m
//  MiHome
//
//  Created by guhao on 2/29/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayNightLogicView.h"
#import "MHLumiFMVolumeControl.h"

@interface MHGatewayNightLogicView ()


@property (nonatomic, strong) MHDeviceGateway *gateway;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, strong) UILabel  *tipsLabel;
@property (nonatomic, assign) BOOL isOn;
@property (nonatomic, assign) BOOL anotherRPC;

@end

@implementation MHGatewayNightLogicView

-(id)initWithFrame:(CGRect)frame sensor:(MHDeviceGateway *)gateway {
    
    self = [super initWithFrame:frame];
    
    if(self){
        self.opaque = NO;
        _anotherRPC = NO;
        _gateway = gateway;
        //Define the circle radius taking into account the safe area
        _radius = self.frame.size.width;
        [self buildSubviews];
        [self setupLumin:_gateway.night_light_rgb ? _gateway.night_light_rgb : 0x64ff0000];
        self.isOn = (_gateway.rgb & 0xffffff) > 0 ? YES : NO;
        //初始化彩灯状态
//        [self controlNightIsOn:self.isOn];
        
    }
    
    return self;
}


- (void)buildSubviews {
    //彩灯图标
    _logoBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    //
    _logoBtn.backgroundColor = [UIColor clearColor];
    [self addSubview:_logoBtn];
    
    //提示文字
    _tipsLabel = [[UILabel alloc] init];
    _tipsLabel.font = [UIFont systemFontOfSize:14.0f * ScaleWidth];
    _tipsLabel.textAlignment = NSTextAlignmentCenter;
    _tipsLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.mainpage.lightoff",@"plugin_gateway", "彩灯点击关闭");
    _tipsLabel.textColor = [UIColor whiteColor];
    _tipsLabel.backgroundColor = [UIColor clearColor];
    _tipsLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_tipsLabel];
    
    //颜色
    _colorView = [[UIView alloc] init];
    self.colorView.layer.cornerRadius = kLogoColorViewSize / 2;
    self.colorView.clipsToBounds = YES;
    self.colorView.hidden = YES;
    [self addSubview:_colorView];

    //开关彩灯
    _nightControlBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_nightControlBtn addTarget:self action:@selector(onNightLight:) forControlEvents:UIControlEventTouchUpInside];
    _nightControlBtn.layer.cornerRadius = 10 * ScaleWidth;
    _nightControlBtn.layer.masksToBounds = YES;
    [self addSubview:_nightControlBtn];
    
    
    
    
    //亮度
    _brightnessBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _brightnessBtn.backgroundColor = [UIColor clearColor];
    [_brightnessBtn setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.mainpage.lightlumin",@"plugin_gateway", "亮度") forState:UIControlStateNormal];
    [_brightnessBtn setTintColor:[MHColorUtils colorWithRGB:0xffffff alpha:0.7]];
    [_brightnessBtn setBackgroundImage:[UIImage imageNamed:@"gateway_night_brightness"] forState:UIControlStateNormal];
    _brightnessBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f * ScaleWidth];
    [_brightnessBtn addTarget:self action:@selector(onAdjustTheBrightness:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_brightnessBtn];
    
    
}
+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    [self buildConstraints];
    
    [super updateConstraints];
}

- (void)buildConstraints {
    CGFloat logoHeight = 55 * ScaleHeight;
    CGFloat logoWidth = logoHeight;
    CGFloat brightHeight = 30 * ScaleHeight;
    CGFloat brightWidth = brightHeight/35*75;
    CGFloat spacing = 15 * ScaleHeight;
    CGFloat colorViewSize = kLogoColorViewSize;
//    NSLog(@"%lf", nightControlBtnSize);
    XM_WS(weakself);
//    [self.nightControlBtn mas_makeConstraints:^(MASConstraintMaker *make) {
////        make.center.equalTo(weakself);
//        make.centerX.equalTo(weakself);
//        make.top.equalTo(weakself);
//        make.height.mas_equalTo(weakself.bounds.size.height - brightHeight);
//        make.width.equalTo(weakself);
//    }];
    
    [self.logoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself);
        make.bottom.mas_equalTo(weakself.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(logoWidth, logoHeight));
    }];
    
    [self.nightControlBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(weakself.logoBtn);
//        make.centerX.equalTo(weakself);
//        make.top.equalTo(weakself);
        make.height.mas_equalTo(weakself.bounds.size.height - brightHeight);
        make.width.mas_equalTo(brightWidth);
    }];

    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself);
        make.top.mas_equalTo(weakself.logoBtn.mas_bottom).with.offset(spacing);
        make.left.equalTo(self);
        make.right.equalTo(self);
    }];
    
    [self.brightnessBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself);
        make.top.mas_equalTo(weakself.tipsLabel.mas_bottom).offset(spacing);
        make.size.mas_equalTo(CGSizeMake(brightWidth, brightHeight));
    }];

    [self.colorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakself.logoBtn);
        make.size.mas_equalTo(CGSizeMake(colorViewSize, colorViewSize));
    }];
}


#pragma make - 控制
- (void)onAdjustTheBrightness:(id)sender {
    [[MHGatewayOfflineManager sharedInstance] showTipsWithGateway:self.gateway];

    MHLumiFMVolumeControl *brightnessControl = [MHLumiFMVolumeControl shareInstance];
    [self setupLumin:_gateway.night_light_rgb ? _gateway.night_light_rgb : 0x64ff0000];
    [brightnessControl showNumberControl:CGRectGetMaxY(self.window.bounds) - VolumePlayerHeight withNewValue:_oldLumin WithNumberType:NumberType_Brightness];
    XM_WS(weakself);
    brightnessControl.volumeControlCallBack = ^(NSInteger value){
        [weakself setIntegerColor:nil lumin:@(value)];
    };
    
}

- (void)onNightLight:(id)sender {
    [[MHGatewayOfflineManager sharedInstance] showTipsWithGateway:self.gateway];
    
    _anotherRPC = NO;
//    self.isOn = (_gateway.rgb & 0xffffff) > 0 ? YES : NO;
    self.isOn = !self.isOn;
    //开关彩灯
    [self controlNightIsOn:self.isOn];
    XM_WS(weakself);
    if (self.gateway.night_light_rgb < 0) {
        self.gateway.night_light_rgb = 0x64ffffff;
    [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.readfailed", @"plugin_gateway",@"夜灯颜色获取失败，请检查网络状况或退出页面重试") duration:1.0f modal:NO];
    }
    NSInteger value = _isOn ? self.gateway.night_light_rgb : 0;
    [self.gateway setProperty:RGB_INDEX value:@(value) success:^(id v) {
        NSLog(@"今天没吃药感觉萌萌哒");
    } failure:^(NSError *v) {
        NSLog(@"孩子感冒老不好,多半是废了");
        if (weakself.anotherRPC) {
            return;
        }
        NSDictionary *params = [weakself.gateway getStatusRequestPayload];
        [weakself.gateway sendPayload:params success:^(id v) {
            BOOL isOpen = (weakself.gateway.rgb & 0xffffff) > 0 ? YES : NO;
            //实际控制成功
            if (isOpen == weakself.isOn) {
                weakself.anotherRPC = YES;
            }
            //真失败
            else {
                weakself.anotherRPC = YES;
                [weakself controlNightIsOn:!weakself.isOn];
                [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"send.failed",@"plugin_gateway", nil) duration:1.5f modal:YES];
            }
        } failure:^(NSError *v) {
            weakself.anotherRPC = YES;
            [weakself controlNightIsOn:!weakself.isOn];
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"send.failed",@"plugin_gateway", nil) duration:1.5f modal:YES];
        }];
//        [weakself controlNightIsOn:!weakself.isOn];
//        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"send.failed",@"plugin_gateway", nil) duration:1.5f modal:YES];
    }];
    
}

- (void)controlNightIsOn:(BOOL)isOn {
    _tipsLabel.text = isOn ? NSLocalizedStringFromTable(@"mydevice.gateway.mainpage.lighton",@"plugin_gateway", "彩灯点击开启") : NSLocalizedStringFromTable(@"mydevice.gateway.mainpage.lightoff",@"plugin_gateway", "彩灯点击关闭");
    _colorView.backgroundColor = isOn ? [MHColorUtils colorWithRGB:_gateway.night_light_rgb] : [MHColorUtils colorWithRGB:0x22333f];
    [_logoBtn setImage:[[UIImage imageNamed: isOn ? @"gateway_night_logo" : @"gateway_night_logo_off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    self.colorView.hidden = !isOn;
}




#pragma mark - setter
- (void)setIntegerColor:(NSNumber *)rgbValue lumin:(NSNumber *)lumin
{
    if (lumin)_newLumin = lumin.doubleValue;
    else _newLumin = _newLumin ? _newLumin : _oldLumin;
    
    if (rgbValue) _newRGB = rgbValue.integerValue;
    else _newRGB = _newRGB ? _newRGB : _oldRGB;
    
    NSInteger argb = _newRGB + (_newLumin << 24);
    XM_WS(weakself);
    if (argb < 0) {
        argb = 0x64ffffff;
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.readfailed", @"plugin_gateway",@"夜灯颜色获取失败，请检查网络状况或退出页面重试") duration:1.0f modal:NO];
    }
    [_gateway setProperty:NIGHT_LIGHT_RGB_INDEX value:@(argb) success:^(id obj) {
//        NSLog(@"%@",obj);
            [weakself controlNightIsOn:YES];
    } failure:^(NSError *error) {
//        NSLog(@"%@",error);
//        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"send.failed",@"plugin_gateway", nil) duration:1.5f modal:YES];
    }];
    
}

- (void)setupLumin:(NSInteger)color
{
    int r = color >> 16 & 0xff;
    int g = color >> 8 & 0xff;
    int b = color & 0xff;
    long a = color >> 24;
//    NSLog(@"红%d, 绿%d, 蓝%d, 透明度%ld", r, g, b, a);
    UIColor *c = [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:a/100.0f];
    CGFloat hue, sat, brightness, alpha;
    [c getHue:&hue saturation:&sat brightness:&brightness alpha:&alpha];
//    NSLog(@"取值后的透明度%ld",(NSInteger)alpha);
    _oldRGB = color - (a << 24);
    _oldLumin = alpha * 100;
//    NSLog(@"最终给slider的透明度%ld",_oldLumin);
    
}



@end
