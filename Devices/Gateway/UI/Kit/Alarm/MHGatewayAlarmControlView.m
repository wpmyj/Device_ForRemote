//
//  MHGatewayAlarmControlView.m
//  MiHome
//
//  Created by guhao on 2/16/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayAlarmControlView.h"
#import "MHGatewayAlarmProgressView.h"
#import "MHGatewayLogViewController.h"
#import "MHLumiHtmlHandleTools.h"
#import "MHGatewayOfflineManager.h"
#import "MHGatewayBindSceneManager.h"
#import "MHGatewaySceneManager.h"
#import "MHDeviceGatewaySensorMagnet.h"
#import "AppDelegate.h"
#import "MHDeviceGatewaySensorMotion.h"
#import "MHDeviceGatewaySensorSwitch.h"
#import "MHGatewayAlarmSettingViewController.h"

#define kAlarmIsOff -1
#define kWidth self.frame.size.width
@interface MHGatewayAlarmControlView ()

@property (nonatomic, strong) MHDeviceGateway *gateway;
@property (nonatomic, strong) MHDeviceGatewayBase *magnet;
@property (nonatomic, assign) BOOL magnetIsOpen;
@property (nonatomic, assign) BOOL hasArmBind;

@property (nonatomic, strong) MHGatewayAlarmProgressView *alarmProgress;
@property (nonatomic, strong) UILabel *armingLogLabel;

@property (nonatomic, strong) CAShapeLayer *innerCircle;


@property (nonatomic, assign) BOOL isArming;
@property (nonatomic, assign) BOOL isUpdatingArmingStatus;
@property (nonatomic, assign) BOOL isArmingDelayCompeleted;
@property (nonatomic, assign) BOOL anotherRPC;//控制失败后,再拉一次警戒属性的标示

@property (nonatomic, assign) NSInteger armingFlag;
@property (nonatomic, assign) NSInteger armingDelayFlag;

@property (nonatomic, assign) NSTimeInterval checkArmingStatusStartTime;
@property (nonatomic, assign) int delay;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic) int currentValue;


@end

@implementation MHGatewayAlarmControlView

- (instancetype)initWithFrame:(CGRect)frame sensor:(MHDeviceGateway *)gateway
{
    self = [super initWithFrame:frame];
    if (self) {
        _gateway = gateway;
        //rpc新的状态
        self.backgroundColor = [UIColor clearColor];
        [self buildSubviews];
        _checkArmingStatusStartTime = 0;
        _armingFlag = 0;
        _armingDelayFlag = 0;
        _anotherRPC = NO;
        //
        [self addTarget:self action:@selector(onArming:) forControlEvents:UIControlEventTouchUpInside];
        [self setupGateway];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {

    [self addSubview:self.alarmProgress];

    [self.layer addSublayer:self.innerCircle];

}

- (void)buildSubviews {

    self.logoImageView = [[UIImageView alloc] init];
    self.logoImageView.image = [UIImage imageNamed:@"gateway_alarm_off"];
    [self addSubview:self.logoImageView];
    
    self.statusText = [[UILabel alloc] init];
    self.statusText.textAlignment = NSTextAlignmentCenter;
    self.statusText.font = [UIFont systemFontOfSize:16.0f];
    self.statusText.textColor = [UIColor whiteColor];
    self.statusText.backgroundColor = [UIColor clearColor];
    self.statusText.text = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.status.off",@"plugin_gateway","警戒已关闭");
    [self addSubview:self.statusText];
    
    self.tipText = [[UILabel alloc] init];
    self.tipText.textAlignment = NSTextAlignmentCenter;
    self.tipText.textColor = [UIColor whiteColor];
    self.tipText.font = [UIFont systemFontOfSize:14.0f];
    self.tipText.backgroundColor = [UIColor clearColor];
    self.tipText.text = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.status.off.tips",@"plugin_gateway","点击开启");
    [self addSubview:self.tipText];
    

    _armingLogLabel = [[UILabel alloc] init];
    _armingLogLabel.textColor = [UIColor whiteColor];
    _armingLogLabel.font = [UIFont systemFontOfSize:16.0f * ScaleWidth];
    _armingLogLabel.textAlignment = NSTextAlignmentCenter;
    _armingLogLabel.numberOfLines = 0;
    _armingLogLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *armingLogTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(armingLogPage:)];
    [_armingLogLabel addGestureRecognizer:armingLogTap];
    [self addSubview:_armingLogLabel];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    [self buildConstraints];
    
    [super updateConstraints];
}

- (void)buildConstraints {
    CGFloat logoWidth = 55 * ScaleWidth;
    XM_WS(weakself);
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(logoWidth, logoWidth));
        make.centerX.equalTo(weakself);
        make.centerY.equalTo(weakself).with.offset(-logoWidth / 2 - 5);
    }];
    
    [self.statusText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself);
        make.top.mas_equalTo(weakself.logoImageView.mas_bottom).with.offset(10);
    }];
    [self.tipText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself);
        make.top.mas_equalTo(weakself.statusText.mas_bottom).with.offset(5);
    }];
    
    [self.armingLogLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself);
        make.top.mas_equalTo(weakself.mas_bottom).with.offset(10 * ScaleHeight);
        make.width.mas_equalTo(WIN_WIDTH - 40 * ScaleWidth);
    }];
}

#pragma mark - getter
- (CAShapeLayer *)innerCircle {
    if (_innerCircle == nil) {
        _innerCircle = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(kWidth / 2, kWidth / 2) radius:_radius - _padding startAngle:0 endAngle:M_PI * 2 clockwise:YES];
        _innerCircle.fillColor = [UIColor clearColor].CGColor;//layer填充色
        _innerCircle.strokeColor = [MHColorUtils colorWithRGB:0xffffff alpha:0.3].CGColor;//layer边框色
        _innerCircle.lineWidth = 2.0f;
        _innerCircle.path = path.CGPath;
        
    }
    
    return _innerCircle;
}

- (MHGatewayAlarmProgressView *)alarmProgress {
    if (_alarmProgress == nil) {
        float lineDiameter = self.frame.size.width; // 竖线圆直径
        _alarmProgress = [[MHGatewayAlarmProgressView alloc] initWithFrame:CGRectMake((kWidth - lineDiameter) / 2, (kWidth - lineDiameter) / 2, lineDiameter, lineDiameter)];
        _alarmProgress.backgroundColor = [UIColor clearColor];
        _alarmProgress.total = 180; // 线的个数
        _alarmProgress.color = [MHColorUtils colorWithRGB:0xffffff alpha:0.3];
        _alarmProgress.radius = lineDiameter/2.0; // 外圈半径
        _alarmProgress.innerRadius = lineDiameter/2.0 - kLineWidth; // 内圈半径
        _radius = _alarmProgress.innerRadius;
        _alarmProgress.startAngle = -M_PI * 0.5;
        _alarmProgress.endAngle = M_PI * 1.5;
        _alarmProgress.layer.shouldRasterize = NO;

    }
    return _alarmProgress;
}

#pragma mark - setter
- (void)setPadding:(CGFloat)padding {
    _padding = padding;
}

- (void)setCurrentValue:(int)currentValue {
    _currentValue = currentValue;
    if (currentValue == kAlarmIsOff) {
        [self.alarmProgress setCompleted:0];
    }
    else {
        //延时为0时,已完成等于总数
        [self.alarmProgress setCompleted: _gateway.arming_delay ? (int)(currentValue * self.alarmProgress.total / _gateway.arming_delay) : self.alarmProgress.total];
    }
    NSLog(@"已完成的部分%d", self.alarmProgress.completed);
}

- (void)setupGateway {
    if (![_gateway.model isEqualToString:@"lumi.gateway.v1"]) {
         _gateway.arming_delay = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_arming_delay_%@",_gateway.did]] intValue];
          _gateway.isShowAlarmDelay = YES;
    }
    else {
        _gateway.isShowAlarmDelay = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_isShowAlarmDelay_%@",_gateway.did]] boolValue];
        if (_gateway.isShowAlarmDelay) {
            _gateway.arming_delay = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_arming_delay_%@",_gateway.did]] intValue];
        }
        else {
            _isArmingDelayCompeleted = YES;
        }
    }
    [self updateAlarmStatus];
    [self updateArmingLog];
    XM_WS(weakself);
    //请求刷新数据
    [self.gateway.logManager getLatestLogWithSuccess:^(id obj) {
        [weakself updateArmingLog];
    } failure:^(NSError *v) {
        
    }];
    //更新警戒绑定数据
    if (![self.gateway laterV3Gateway]) {
        [self.gateway getBindListOfSensorsWithSuccess:nil failure:nil];
    }
    if ([self.gateway laterV3Gateway]) {
        [[MHGatewayBindSceneManager sharedInstance] fetchBindSceneList:self.gateway withSuccess:nil];
    }
}

#pragma make - 警戒
- (void)updateAlarmStatus {
    if (!_gateway.arming) {
        [self getGatewayArmingStatus];
        return;
    }
//    NSLog(@"警戒状态%@, 延迟警戒的时间%d", _gateway.arming, _gateway.arming_delay);
    _isUpdatingArmingStatus = NO;
    _delay = _gateway.isShowAlarmDelay ? _gateway.arming_delay : 60;
    if ([[_gateway.arming lowercaseString] isEqualToString:@"on"] || [[_gateway.arming lowercaseString] isEqualToString:@"oning"]) {
        _isArming = YES;
    }
    else {
        _isArming = NO;
    }
    _checkArmingStatusStartTime = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_lastArmingStartTime_%@",_gateway.did]] doubleValue];
    if (_checkArmingStatusStartTime > 0) {
        NSTimeInterval passedTime = [[NSDate date] timeIntervalSince1970] - _checkArmingStatusStartTime;
        NSLog(@"%lf", passedTime);
        if (passedTime < _delay) {
            [self armingIsOning];
            _isUpdatingArmingStatus = YES;
            [self onUpdateArmingStatus];
        }
    }
    if (_isArming && !_isUpdatingArmingStatus) {
        //警戒开启UI
        [self armingIsOn];
    }
    else {
        [self armingIsOff];
    }
}

- (void)onArming:(id)sender {
    XM_WS(weakself);
//    [[MHGatewayOfflineManager sharedInstance] showTipsWithGateway:self.gateway];
    self.isArming = [_gateway.arming isEqualToString:@"off"] ? NO : YES;
    self.isArming = !self.isArming;
    self.isUpdatingArmingStatus = self.isArming;
//    [self magnetIsStillOpen];
    [self cheakBind];
    NSLog(@"%@, %d, %d, 是不是有绑定%d", self.magnet, self.isArming, self.magnetIsOpen, self.hasArmBind);
    if (self.isArming && !self.hasArmBind) {
        [[MHPromptKit shareInstance] showAlertWithHandler:^(NSInteger buttonIndex, NSArray *inputs) {
            switch (buttonIndex) {
                case 0: {
                MHGatewayAlarmSettingViewController *alarmVC = [[MHGatewayAlarmSettingViewController alloc] initWithGateway:weakself.gateway];
                AppDelegate *app = [UIApplication sharedApplication].delegate;
                [app.currentViewController.navigationController pushViewController:alarmVC animated:YES];
                break;
                }
                default:
                break;
            }
            
        } withTitle:@"" message:NSLocalizedStringFromTable(@"mydevice.gateway.log.arming.checkbind.title", @"plugin_gateway", @"开启前,需设置警戒触发设备") style:UIAlertViewStyleDefault defaultText:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedStringFromTable(@"mydevice.gateway.log.arming.checkbind.set", @"plugin_gateway", @"去设置"), nil];
    }
    else if (self.isArming && self.magnet && self.magnetIsOpen) {
        [[MHPromptKit shareInstance] showAlertWithHandler:^(NSInteger buttonIndex, NSArray *inputs) {
            switch (buttonIndex) {
                case 0:
                    [weakself arming:weakself.isArming];
                    weakself.enabled = NO;
                    weakself.anotherRPC = NO;
                    break;
                    
                default:
                    break;
            }
            
        } withTitle:@"" message:[NSString stringWithFormat:@"%@%@ %@",NSLocalizedStringFromTable(@"mydevice.gateway.log.arming.opentips.master", @"plugin_gateway", @"主人,"), self.magnet.name, NSLocalizedStringFromTable(@"mydevice.gateway.log.arming.opentips.text", @"plugin_gateway", @"還沒關哦") ] style:UIAlertViewStyleDefault defaultText:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedStringFromTable(@"ifttt.scene.local.scene.log.scenedelete.confirm", @"plugin_gateway", @"我知道了"), nil];

    }
    else {
        [self arming:self.isArming];
        self.enabled = NO;
        self.anotherRPC = NO;
 
    }
}

- (void)onArmingFinished:(BOOL)isSucceed isOn:(BOOL)isOn {
    if (isSucceed) {
        if (isOn) {
            [self armingIsOning];
            _isArmingDelayCompeleted = YES;
            _checkArmingStatusStartTime = -1;
            _isUpdatingArmingStatus = YES;
            [self onUpdateArmingStatus];
        } else {
            [self armingIsOff];
        }
    }
    else {
        self.isArming = !self.isArming;
    }
}

- (void)arming:(BOOL)isOn {
    XM_WS(weakself);
    NSString* value = isOn ? @"on" : @"off";
    [self.gateway setProperty:ARMING_INDEX value:value success:^(id v) {
        [weakself onArmingFinished:YES isOn:isOn];
        weakself.enabled = YES;
    } failure:^(NSError *v) {
        //第一次失败再拉一次属性,一定程度上解决状态不对
        if (!weakself.anotherRPC) {
            [weakself.gateway getProperty:ARMING_INDEX success:^(id respObj) {
                weakself.isArming = [[respObj[0] lowercaseString] isEqualToString:@"on"] || [[respObj[0] lowercaseString] isEqualToString:@"oning"];
                //发送失败,实际控制成功
                if (weakself.isArming == isOn) {
                    [weakself onArmingFinished:YES isOn:isOn];
                }
                //真失败
                else {
                    [weakself onArmingFinished:NO isOn:isOn];
                  [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"send.failed",@"plugin_gateway", nil) duration:1.5f modal:YES];
                }
                weakself.enabled = YES;
                weakself.anotherRPC = YES;
            } failure:^(NSError *error) {
                //真假未知,当做失败
                weakself.anotherRPC = YES;
                weakself.enabled = YES;
                [weakself onArmingFinished:NO isOn:isOn];
                [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"send.failed",@"plugin_gateway", nil) duration:1.5f modal:YES];
            }];

        }
    }];
}
- (void)onUpdateArmingStatus {
    if (!_isArming) {
        return;
    }
    if (!_isUpdatingArmingStatus) {
        return;
    }
    if (!_checkArmingStatusStartTime) {
        return;
    }
    if (_checkArmingStatusStartTime < 0) {
        _checkArmingStatusStartTime = [[NSDate date] timeIntervalSince1970];
        [[NSUserDefaults standardUserDefaults] setObject:@(_checkArmingStatusStartTime) forKey:[NSString stringWithFormat:@"gateway_lastArmingStartTime_%@",_gateway.did]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    NSTimeInterval passedTime = [[NSDate date] timeIntervalSince1970] - _checkArmingStatusStartTime;
    NSLog(@"%lf", _checkArmingStatusStartTime);
    NSLog(@"%lf", passedTime);
    _delay = _gateway.arming_delay;
    if (passedTime <= _delay) {
        self.statusText.text = [NSString stringWithFormat:@"%d%@", (int)(_delay - passedTime + 1), NSLocalizedStringFromTable(@"mydevice.gateway.arming.status",@"plugin_gateway","秒后进入警戒状态")];
        self.currentValue = (int)passedTime;
        [self performSelector:@selector(onUpdateArmingStatus) withObject:self afterDelay:1.0f];
    }
    else {
        [self armingIsOn];
    }
}
#pragma make - 警戒关闭
- (void)armingIsOff {
    [self updateCheckArmingStatusStartTime];
    self.statusText.text = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.status.off",@"plugin_gateway","警戒已关闭");
    self.tipText.text = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.status.off.tips",@"plugin_gateway","点击开启");
    self.logoImageView.image = [UIImage imageNamed:@"gateway_alarm_off"];
    [self setCurrentValue:kAlarmIsOff];
}

#pragma mark - 警戒开启
- (void)armingIsOn {
    [self updateCheckArmingStatusStartTime];
    [self armingIsOning];
    self.statusText.text = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.status.on",@"plugin_gateway","警戒已开启");
    [self setCurrentValue:_delay];
       NSLog(@"%d", self.currentValue);
}
#pragma mark - 正在开启
- (void)armingIsOning {
    self.tipText.text = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.tips.on.tips",@"plugin_gateway","点击关闭");
    self.logoImageView.image = [UIImage imageNamed:@"gateway_alarm_on"];
}

- (void)updateCheckArmingStatusStartTime {
    _checkArmingStatusStartTime = 0;
    _isUpdatingArmingStatus = NO;
    [[NSUserDefaults standardUserDefaults] setObject:@(_checkArmingStatusStartTime) forKey:[NSString stringWithFormat:@"gateway_lastArmingStartTime_%@",_gateway.did]];
    [[NSUserDefaults standardUserDefaults] synchronize];

}
#pragma mark - 警戒状态
- (void)getGatewayArmingStatus {
    XM_WS(weakself);
    _armingFlag++;
    [weakself.gateway getProperty:ARMING_INDEX success:^(id respObj) {
//        NSLog(@"警戒状态%@", respObj);
        if (weakself.gateway.arming) {
            weakself.isArming = [[respObj[0] lowercaseString] isEqualToString:@"on"] || [[respObj[0] lowercaseString] isEqualToString:@"oning"];
            [weakself updateAlarmStatus];
        }
        else {
            if (weakself.armingFlag < 2) {
                [weakself getGatewayArmingStatus];
            }
        }
        
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
        weakself.gateway.arming = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_arming_%@",weakself.gateway.did]];
        if (weakself.gateway.arming) {
            weakself.isArming = [[weakself.gateway.arming lowercaseString] isEqualToString:@"on"];
            [weakself updateAlarmStatus];
        }
        else {
            if (weakself.armingFlag < 2) {
                [weakself getGatewayArmingStatus];
            }
        }
    }];

}
#pragma mark- 获取自定义延迟时间
- (void)getGatewayArmingDelay {
    XM_WS(weakself);
    _armingDelayFlag++;
    [_gateway getProperty:ARMING_DELAY_INDEX success:^(id respObj) {
//        NSLog(@"延迟时间%@", respObj);
        if (respObj && [respObj isKindOfClass:[NSArray class]]) {
            weakself.delay = weakself.gateway.arming_delay;
            weakself.isArmingDelayCompeleted = YES;
            [weakself updateAlarmStatus];
        }
        else {
            if (weakself.armingDelayFlag < 2) {
                [weakself getGatewayArmingDelay];
            }
        }
        
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
        weakself.gateway.arming_delay = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_arming_delay_%@",weakself.gateway.did]] intValue];
        weakself.gateway.isShowAlarmDelay = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_isShowAlarmDelay_%@",weakself.gateway.did]] boolValue];
        weakself.isArmingDelayCompeleted = YES;
        [weakself updateAlarmStatus];
    }];

    
}

#pragma mark - 门窗打开 
- (void)magnetIsStillOpen {
    if (!self.isArming) {
        return;
    }
    self.magnet = nil;
    self.magnetIsOpen = NO;
    
    XM_WS(weakself);
    if ([self.gateway.model isEqualToString:kGatewayModelV3] ||
        [self.gateway.model isEqualToString:kACPartnerModelV1]) {
//        NSLog(@"%@", self.gateway.systemSceneList);
        [self.gateway.systemSceneList enumerateObjectsUsingBlock:^(MHDataScene *scene, NSUInteger idx, BOOL * _Nonnull stop) {
            //门窗打开报警
            if ([scene.identify isEqualToString:@"lm_scene_1_2"]) {
                NSArray *result = [weakself checkSystemScene:scene];
                if ([result[0] boolValue]) {
                    weakself.magnet = (MHDeviceGatewaySensorMagnet *)result[1];
                    weakself.magnet.logManager = [[MHGatewayLogListManager alloc] initWithManagerIdentify:
                                                  [NSString stringWithFormat:@"%@_%@", @"mhgatewaylogmanager", weakself.magnet.did] device:weakself.magnet];
                    NSString *currentLog = [weakself.magnet.logManager getLatestLogDescription];
                    NSString *log = NSLocalizedStringFromTable(@"mydevice.gateway.magnet.open",@"plugin_gateway", "门窗打开");
                    //                        NSLog(@"门窗的最新日志%@---%@", currentLog, log);
                    if ([currentLog containsString:log]) {
                        weakself.magnetIsOpen = YES;
                        *stop = YES;
                    }
                }
            }
            *stop = weakself.magnetIsOpen;
        }];
    }
    else {
        [self.gateway.subDevices enumerateObjectsUsingBlock:^(MHDeviceGatewayBase *sensor, NSUInteger idx, BOOL * _Nonnull stop) {
//            NSLog(@"门窗的最新日志%@, 绑定表%@", sensor, sensor.bindList);
            if ([sensor isKindOfClass:[MHDeviceGatewaySensorMagnet class]] && sensor.bindList.count) {
                [sensor.bindList enumerateObjectsUsingBlock:^(MHLumiBindItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([item.method isEqualToString:Method_Alarm] && [item.event isEqualToString:Gateway_Event_Magnet_Open]) {
                        weakself.magnet = sensor;
                        NSString *log = [weakself.magnet.logManager getLatestLogDescription];
//                        NSLog(@"门窗的最新日志%@", log);
                        if ([log containsString:NSLocalizedStringFromTable(@"mydevice.gateway.magnet.open",@"plugin_gateway", "")]) {
                            weakself.magnetIsOpen = YES;
                            *stop = YES;
                        }
                    }
                }];
                *stop = weakself.magnetIsOpen;
            }
        }];
    }

}

#pragma mark - 检查绑定
- (void)cheakBind {
    if (!self.isArming) {
        return;
    }
    XM_WS(weakself);
    self.hasArmBind = NO;
    if (!self.gateway.subDevices.count) {
        return;
    }
    if ([self.gateway laterV3Gateway]) {
//        NSLog(@"%@", self.gateway.systemSceneList);
        [self.gateway.systemSceneList enumerateObjectsUsingBlock:^(MHDataScene *scene, NSUInteger idx, BOOL * _Nonnull stop) {
//            NSLog(@"%d, %@, %@, 场景id----%@", scene.enable, scene.identify ,scene.name, scene.usId);
            //判断是否有报警自动化
            if ([scene.identify isEqualToString:@"lm_scene_1_1"] ||
                [scene.identify isEqualToString:@"lm_scene_1_2"] ||
                [scene.identify isEqualToString:@"lm_scene_1_3"] ||
                [scene.identify isEqualToString:@"lm_scene_1_4"]) {
//
                weakself.hasArmBind = [[weakself checkSystemScene:scene][0] boolValue];
                *stop = weakself.hasArmBind;
            }
        }];
    }
    else {
        [self.gateway.subDevices enumerateObjectsUsingBlock:^(MHDeviceGatewayBase *sensor, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([sensor isKindOfClass:[MHDeviceGatewaySensorMagnet class]] && sensor.bindList.count && sensor.isSetAlarming) {
                weakself.hasArmBind = YES;
                *stop = YES;
            }
            else if ([sensor isKindOfClass:[MHDeviceGatewaySensorMotion class]] && sensor.bindList.count && sensor.isSetAlarming) {
                weakself.hasArmBind = YES;
                *stop = YES;
            }
            else if ([sensor isKindOfClass:[MHDeviceGatewaySensorSwitch class]] && sensor.bindList.count && sensor.isSetAlarming) {
                weakself.hasArmBind = YES;
                *stop = YES;
            }
        }];
    }

}

- (NSArray *)checkSystemScene:(MHDataScene *)scene {
    NSMutableArray *result = [NSMutableArray new];
    __block BOOL isRightScene = NO;
    __block MHDevice *resultDevice = [[MHDevice alloc] init];
    XM_WS(weakself);
    [scene.actionList enumerateObjectsUsingBlock:^(MHDataAction *action, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSLog(@"action的信息---%@, %@, %@",  action.deviceName ,action.deviceModel, action.deviceDid);
        //执行设备是当前网关
        if ([action.deviceDid isEqualToString:weakself.gateway.did]) {
            [scene.launchList enumerateObjectsUsingBlock:^(MHDataLaunch *launch, NSUInteger idx, BOOL * _Nonnull stop) {
//                NSLog(@"启动条件的名字和did ---- %@, %@", launch.name, launch.deviceDid);
                MHDevice *newDevice = [[MHDevListManager sharedManager] deviceForDid:launch.deviceDid];
                [weakself.gateway.subDevices enumerateObjectsUsingBlock:^(MHDeviceGatewayBase *subDevice, NSUInteger idx, BOOL * _Nonnull stop) {
                    //设备是否存在, 在线,属于当前网关
                    if ((newDevice && newDevice.isOnline) && [newDevice.did isEqualToString:subDevice.did]) {
                        isRightScene = YES;
                        resultDevice = newDevice;
                        *stop = YES;
                    }
                }];
            }];
        }
        *stop = isRightScene;
    }];
    [result addObject:@(isRightScene)];
    [result addObject:resultDevice];
    return result;
}

#pragma mark - 警戒日志
- (void)updateArmingLog {
    NSString *log = [self.gateway.logManager getLatestLogDescription];
    if ([log isEqualToString:NSLocalizedStringFromTable(@"mydevice.gateway.log.none",@"plugin_gateway", "")]) {
        log = NSLocalizedStringFromTable(@"mydevice.gateway.log.arming",@"plugin_gateway", "");
    }
    else {
        log = [NSString stringWithFormat:@"%@ >", log];
    }
    self.armingLogLabel.text = log;
}

- (void)armingLogPage:(id)sender {
    XM_WS(weakself);
    dispatch_async(dispatch_get_main_queue(), ^{
        MHGatewayLogViewController *log = [[MHGatewayLogViewController alloc] initWithDevice:weakself.gateway];
        log.isTabBarHidden = YES;
//        log.title = [NSString stringWithFormat:@"%@%@",weakself.gateway.name, NSLocalizedStringFromTable(@"mydevice.gateway.alarm.log",@"plugin_gateway", "")];
        log.title = NSLocalizedStringFromTable(@"mydevice.gateway.alarm.log",@"plugin_gateway", "报警日志");

        AppDelegate *app = [UIApplication sharedApplication].delegate;
        [app.currentViewController.navigationController pushViewController:log animated:YES];
    });
    
}

#pragma mark - 超出父视图的view响应点击事件
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        CGPoint tempoint = [self.armingLogLabel convertPoint:point fromView:self];
        if (CGRectContainsPoint(self.armingLogLabel.bounds, tempoint))
        {
            view = self.armingLogLabel;
        }
    }
    return view;
}

@end
