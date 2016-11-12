//
//  MHACPartnerAddControlView.m
//  MiHome
//
//  Created by ayanami on 16/7/1.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerAddControlView.h"
#import "MHGatewayAlarmControlView.h"
#import "MHGatewayNightLightControlView.h"
#import "MHLumiFmPlayerViewController.h"
#import "MHGatewayTempAndHumidityViewController.h"
#import "MHGatewayMainpageAnimation.h"
#import "MHGatewayDragCircularSlider.h"
#import "MHACPartnerAddAcListViewController.h"
#import "MHACPartnerDetailViewController.h"
#import "MHLumiHtmlHandleTools.h"
#import "MHACPartnerUploadViewController.h"
#import "MHACPartnerAddTipsViewController.h"

@interface MHACPartnerAddControlView ()
@property (nonatomic, strong) MHDeviceAcpartner *acpartner;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *lessBtn;
@property (nonatomic, strong) UIButton *plusBtn;
@property (nonatomic, strong) UIButton *addAcBtn;
@property (nonatomic, strong) UILabel *addAcLabel;
@property (nonatomic, strong) UILabel *powerTitle;
@property (nonatomic, strong) UILabel *moreTitle;

@property (nonatomic, strong) UILabel *currentMode;
@property (nonatomic, strong) UILabel *currentTemperature;
@property (nonatomic, strong) UILabel *celsius;


@property (nonatomic, strong) UILabel *quantLabel;

@end

@implementation MHACPartnerAddControlView
- (id)initWithFrame:(CGRect)frame sensor:(MHDeviceAcpartner *)acpartner {
    if (self = [super initWithFrame:frame]) {
        self.acpartner = acpartner;
        [self buildSubViews];
        //        [self buildConstraints];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"空调添加首页dead");
}

- (void)buildSubViews {
//    self.backgroundColor = [MHColorUtils colorWithRGB:0x22333f];
    //无空调设备
    _addAcBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_addAcBtn addTarget:self action:@selector(onAddAc:) forControlEvents:UIControlEventTouchUpInside];
    [_addAcBtn setImage:[UIImage imageNamed:@"acpartner_home_addac"] forState:UIControlStateNormal];
    [self addSubview:_addAcBtn];
    
    _addAcLabel = [[UILabel alloc] init];
    _addAcLabel.textAlignment = NSTextAlignmentCenter;
    _addAcLabel.font = [UIFont systemFontOfSize:16.0f];
    _addAcLabel.textColor = [UIColor whiteColor];
    _addAcLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add",@"plugin_gateway","添加空调");
    UITapGestureRecognizer *addTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAddAc:)];
    [_addAcLabel addGestureRecognizer:addTap];
    _addAcLabel.userInteractionEnabled = YES;
    [self addSubview:_addAcLabel];
    
    //有空调设备
    _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playBtn addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [_playBtn setImage:[UIImage imageNamed:@"acpartner_power_on"] forState:UIControlStateNormal];
    [self addSubview:_playBtn];
    
    _currentMode = [[UILabel alloc] init];
    _currentMode.textAlignment = NSTextAlignmentCenter;
    _currentMode.font = [UIFont systemFontOfSize:13.0f];
    _currentMode.textColor = [MHColorUtils colorWithRGB:0x030303 alpha:0.7];
    _currentMode.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.mode.cool",@"plugin_gateway","制冷");
    [self addSubview:_currentMode];
    
    _currentTemperature = [[UILabel alloc] init];
    _currentTemperature.textAlignment = NSTextAlignmentCenter;
    _currentTemperature.font = [UIFont  fontWithName:@"DINOffc-CondMedi" size:50.0f];
    _currentTemperature.textColor = [UIColor blackColor];
    _currentTemperature.text = @"26";
    [self addSubview:_currentTemperature];
    
    _celsius = [[UILabel alloc] init];
    _celsius.textAlignment = NSTextAlignmentCenter;
    _celsius.font = [UIFont  fontWithName:@"DINOffc-CondMedi" size:16.0f];
    _celsius.textColor = [UIColor blackColor];
    _celsius.text = @"℃";
    [self addSubview:_celsius];
    
    
    _plusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_plusBtn setImage:[UIImage imageNamed:@"acpartner_temperature_plus"] forState:UIControlStateNormal];
    [_plusBtn addTarget:self action:@selector(onPlusTemperature:) forControlEvents:UIControlEventTouchUpInside];
    _playBtn.tag = 0 + TEMPERATUREBUTTON_TAG;
    [self addSubview:_plusBtn];
    
    _lessBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_lessBtn setImage:[UIImage imageNamed:@"acpartner_temperature_less"] forState:UIControlStateNormal];
    [_lessBtn addTarget:self action:@selector(onLessTemperature:) forControlEvents:UIControlEventTouchUpInside];
    _lessBtn.tag = 1 + TEMPERATUREBUTTON_TAG;
    [self addSubview:_lessBtn];
    
    _powerTitle = [[UILabel alloc] init];
    _powerTitle.textAlignment = NSTextAlignmentCenter;
    _powerTitle.font = [UIFont systemFontOfSize:13.0f];
    _powerTitle.textColor = [MHColorUtils colorWithRGB:0x030303 alpha:0.7];
    self.powerTitle.text = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.tips.on.tips",@"plugin_gateway","点击关闭");
    [self addSubview:_powerTitle];
    
    _moreTitle = [[UILabel alloc] init];
    _moreTitle.textAlignment = NSTextAlignmentCenter;
    _moreTitle.font = [UIFont systemFontOfSize:20.0f];
    _moreTitle.textColor = [UIColor whiteColor];
    _moreTitle.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.detail",@"plugin_gateway","更多控制 >");
    //
    UITapGestureRecognizer *detailTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDetailPage:)];
    [_moreTitle addGestureRecognizer:detailTap];
    _moreTitle.userInteractionEnabled = YES;
    [self addSubview:_moreTitle];
    
//    _quantLabel = [[UILabel alloc] init];
//    _quantLabel.textAlignment = NSTextAlignmentRight;
//    _quantLabel.font = [UIFont systemFontOfSize:14.0f];
//    _quantLabel.textColor = [MHColorUtils colorWithRGB:0xfffff alpha:0.7];
//    _quantLabel.text = [NSString stringWithFormat:@"当前功率 : %.0fw", self.acpartner.ac_power];
//    [self addSubview:_quantLabel];
    
}


- (void)buildConstraints {
    CGFloat playBtnSize = 110 * ScaleHeight;
    CGFloat nextBtnSize = 48 * ScaleHeight;
//    CGFloat radioTitleSpacing = 12 * ScaleHeight;
    CGFloat playBtnSpacing = 50 * ScaleHeight;
    CGFloat spacing = 60;
    CGFloat herizonSpacing = 40 * ScaleWidth;
    
    
    XM_WS(weakself);
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself);
        make.centerY.mas_equalTo(weakself.mas_centerY).with.offset(-playBtnSpacing);
        make.size.mas_equalTo(CGSizeMake(playBtnSize, playBtnSize));
    }];
    
    [self.plusBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakself.playBtn);
        make.left.mas_equalTo(weakself.playBtn.mas_right).with.offset(herizonSpacing);
        make.size.mas_equalTo(CGSizeMake(nextBtnSize, nextBtnSize));
    }];
    
    
    [self.lessBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakself.playBtn);
        make.right.mas_equalTo(weakself.playBtn.mas_left).with.offset(-herizonSpacing);
        make.size.mas_equalTo(CGSizeMake( nextBtnSize, nextBtnSize));
    }];
    
    
    
    [self.moreTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself);
        make.bottom.mas_equalTo(weakself.mas_bottom).with.offset(-spacing);
    }];
    
    
    //没有空调
    CGFloat addBtnSpacing = 52 * ScaleHeight;
    CGFloat addLabelSapcing = 22 * ScaleHeight;
    
    [self.addAcBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself);
        make.size.mas_equalTo(CGSizeMake(99, 99));
        make.top.mas_equalTo(weakself.mas_top).with.offset(addBtnSpacing);
    }];
    
    [self.addAcLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself);
        make.top.mas_equalTo(weakself.addAcBtn.mas_bottom).with.offset(addLabelSapcing);
    }];
    
    
    
    [_currentTemperature mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakself.playBtn);
    }];
    
    [_currentMode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakself.currentTemperature.mas_top).with.offset(5);
        make.centerX.equalTo(weakself);
    }];
    
    [self.powerTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself);
        make.top.equalTo(weakself.currentTemperature.mas_bottom).with.offset(-5);
    }];
    
    [_celsius mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakself.currentTemperature.mas_bottom).with.offset(-10);
        make.left.mas_equalTo(weakself.currentTemperature.mas_right);
    }];
    
    
    
//    [_quantLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.mas_equalTo(weakself.mas_bottom).with.offset(-30);
//        make.right.mas_equalTo(weakself.mas_right).with.offset(-20);
//    }];
}



+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    [self buildConstraints];
    
    [super updateConstraints];
}


#pragma mark - 控制
- (void)onPlusTemperature:(id)sender {
    XM_WS(weakself);
    //    [[MHTipsView shareInstance] showTipsInfo:@"加温度" duration:1.0 modal:NO];
    if (self.acpartner.ACType == 1) {
        
        [self.acpartner sendCommand:[self.acpartner getACCommand:TEMP_PLUS_INDEX commandIndex:TEMP_PLUS_COMMAND isTimer:NO] success:^(id obj) {
            
        } failure:^(NSError *v) {
            
        }];
    }
    
    if (self.acpartner.ACType == 2 || self.acpartner.ACType == 3) {
        int tempTemp = self.acpartner.temperature;
        if (self.acpartner.ACType == 3) {
            if (self.acpartner.temperature + 1 <= TEMPERATUREMAX) {
                
                self.acpartner.temperature += 1;
                NSString *command = [self.acpartner getACCommand:TEMP_PLUS_INDEX commandIndex:TEMP_PLUS_COMMAND isTimer:NO];
                [self.acpartner sendCommand:command success:^(id obj) {
                    [weakself updateMainPageStatus];
                } failure:^(NSError *v) {
                    weakself.acpartner.temperature = tempTemp;
                    [weakself updateMainPageStatus];
                }];
            }
        }
        else {
            if (([self.acpartner.kkAcManager canControlTemp] == YES && self.acpartner.temperature < TEMPERATUREMAX ) && [[self.acpartner.kkAcManager getLackOfTemperatureArray] containsObject:[NSString stringWithFormat:@"%d",self.acpartner.temperature + 1]] == NO) {
                self.acpartner.temperature += 1;
                [self.acpartner.kkAcManager changeTemperatureWithTemperature:self.acpartner.temperature];
                [self.acpartner.kkAcManager getTemperature];
                //            [self setWorkingButtonTitleColor:self._addtemperature];
                
                if (self.acpartner.temperature > TEMPERATUREMIN && [[self.acpartner.kkAcManager getLackOfTemperatureArray] containsObject:[NSString stringWithFormat:@"%d",self.acpartner.temperature - 1]] == NO) {
                    //                [self setWorkingButtonTitleColor:self.acpartner.temperature];
                }
                else
                {
                    //                [self setDisableButtonTitleColor:self._subtempterature];
                }
            }
            NSString *command = [self.acpartner getACCommand:TEMP_PLUS_INDEX commandIndex:TEMP_PLUS_COMMAND isTimer:NO];
            [self.acpartner sendCommand:command success:^(id obj) {
                [weakself updateMainPageStatus];
            } failure:^(NSError *v) {
                weakself.acpartner.temperature = tempTemp;
                [weakself updateMainPageStatus];
            }];
            
        }
    }
    
}

- (void)onLessTemperature:(id)sender {
    XM_WS(weakself);
    if (self.acpartner.ACType == 1) {
        
        [self.acpartner sendCommand:[self.acpartner getACCommand:TEMP_LESS_INDEX commandIndex:TEMP_LESS_COMMAND isTimer:NO] success:^(id obj) {
            
        } failure:^(NSError *v) {
            
        }];
    }
    
    if (self.acpartner.ACType == 2 || self.acpartner.ACType == 3) {
        int tempTemp = self.acpartner.temperature;
        
        if (self.acpartner.ACType == 3) {
            if (self.acpartner.temperature - 1 >= TEMPERATUREMIN) {
                self.acpartner.temperature -= 1;
                NSString *command = [self.acpartner getACCommand:TEMP_LESS_INDEX commandIndex:TEMP_LESS_COMMAND isTimer:NO];
                [self.acpartner sendCommand:command success:^(id obj) {
                    [weakself updateMainPageStatus];
                } failure:^(NSError *v) {
                    weakself.acpartner.temperature = tempTemp;
                    [weakself updateMainPageStatus];
                }];
            }
        }
        else {
            if (([self.acpartner.kkAcManager canControlTemp] == YES && self.acpartner.temperature > TEMPERATUREMIN )&&[[self.acpartner.kkAcManager getLackOfTemperatureArray] containsObject:[NSString stringWithFormat:@"%d",self.acpartner.temperature - 1]] == NO) {
                self.acpartner.temperature -= 1;
                [self.acpartner.kkAcManager changeTemperatureWithTemperature:self.acpartner.temperature];
                [self.acpartner.kkAcManager getTemperature];

                
            }
            
            NSString *command = [self.acpartner getACCommand:TEMP_LESS_INDEX commandIndex:TEMP_LESS_COMMAND isTimer:NO];
            [self.acpartner sendCommand:command success:^(id obj) {
                [weakself updateMainPageStatus];
            } failure:^(NSError *v) {
                weakself.acpartner.temperature = tempTemp;
                [weakself updateMainPageStatus];
            }];
            
        }
    }
    
}


- (void)onSwitch:(id)sender {
    XM_WS(weakself);
    self.acpartner.powerState = !self.acpartner.powerState;
    
    if (self.acpartner.ACType == 1) {
        NSString *command = [self.acpartner getACCommand:self.acpartner.powerState == 1 ? POWER_ON_INDEX : POWER_OFF_INDEX commandIndex:POWER_COMMAND isTimer:NO];
        
        [self.acpartner sendCommand:command success:^(id obj) {
            //            [self getNewQuant];
            [weakself updateMainPageStatus];
        } failure:^(NSError *v) {
            weakself.acpartner.powerState = !weakself.acpartner.powerState;
            
        }];
    }
    if (self.acpartner.ACType == 3) {
        NSString *command = [self.acpartner getACCommand:STAY_INDEX commandIndex:POWER_COMMAND isTimer:NO];
        [self.acpartner sendCommand:command success:^(id obj) {
            //                [self getNewQuant];
            [weakself updateMainPageStatus];
        } failure:^(NSError *v) {
            weakself.acpartner.powerState = !weakself.acpartner.powerState;
            
            [weakself updateMainPageStatus];
            
        }];
    }
    if (self.acpartner.ACType == 2) {
        [self.acpartner.kkAcManager changePowerStateWithPowerstate:self.acpartner.powerState == 0 ? AC_POWER_OFF : AC_POWER_ON];
        [self.acpartner.kkAcManager getPowerState];
        
        NSString *command = [self.acpartner getACCommand:STAY_INDEX commandIndex:POWER_COMMAND isTimer:NO];
        [self.acpartner sendCommand:command success:^(id obj) {
            //            [self getNewQuant];
            [weakself updateMainPageStatus];
        } failure:^(NSError *v) {
            weakself.acpartner.powerState = !weakself.acpartner.powerState;
            [weakself updateMainPageStatus];
            
        }];
    }
    
}


- (void)onAddAc:(id)sender {
    if (self.addACClicked) {
        self.addACClicked();
    }
    
}

- (void)onDetailPage:(id)sender {
    if (self.acDetailClicked) {
        self.acDetailClicked();
    }

       
}

- (void)getNewQuant {
    XM_WS(weakself);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself.acpartner getACDeviceProp:AC_POWER_ID success:^(id v) {
            [weakself updateMainPageStatus];
        } failure:^(NSError *error) {
            
        }];
    });
    
}

#pragma mark - 更新状态
- (void)updateMainPageStatus {
    self.currentTemperature.text = [NSString stringWithFormat:@"%d", self.acpartner.temperature];
    self.currentMode.text = modeArray[self.acpartner.modeState];
    self.powerTitle.hidden = !self.acpartner.powerState;
    [self.playBtn setImage:[UIImage imageNamed:self.acpartner.powerState ? @"acpartner_power_on" : @"acpartner_home_off" ] forState:UIControlStateNormal];
    
//    _quantLabel.text = [NSString stringWithFormat:@"当前功率 : %.0fw", self.acpartner.ac_power];
    

    self.addAcBtn.hidden = YES;
    self.addAcLabel.hidden = YES;
    self.moreTitle.hidden = NO;
    self.playBtn.hidden = NO;
    
    BOOL hasScan = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@", self.acpartner.did, kHASSCANED]] boolValue];
    if (!hasScan) {
        self.plusBtn.hidden = YES;
        self.playBtn.hidden = YES;
        self.lessBtn.hidden = YES;
        self.moreTitle.hidden = YES;
        self.powerTitle.hidden = YES;
        self.addAcBtn.hidden = NO;
        self.addAcLabel.hidden = NO;
        self.currentTemperature.hidden = YES;
        self.currentMode.hidden = YES;
        self.celsius.hidden = YES;
    }
    else {
        if (self.acpartner.ACType == 1) {
            self.currentTemperature.hidden = YES;
            self.currentMode.hidden = YES;
            self.celsius.hidden = YES;
            self.plusBtn.hidden = !self.acpartner.powerState;
            self.lessBtn.hidden = !self.acpartner.powerState;
        }
        else if (self.acpartner.ACType == 2 || self.acpartner.ACType == 3) {
            self.currentTemperature.hidden = !self.acpartner.powerState;
            self.currentMode.hidden = !self.acpartner.powerState;
            self.celsius.hidden = !self.acpartner.powerState;
            self.plusBtn.hidden = !self.acpartner.powerState;
            self.lessBtn.hidden = !self.acpartner.powerState;
        }
        else {
            self.plusBtn.hidden = YES;
            self.playBtn.hidden = YES;
            self.lessBtn.hidden = YES;
            self.moreTitle.hidden = YES;
            self.powerTitle.hidden = YES;
            self.addAcBtn.hidden = NO;
            self.addAcLabel.hidden = NO;
            self.currentTemperature.hidden = YES;
            self.currentMode.hidden = YES;
            self.celsius.hidden = YES;
        }
        
    }
}

@end
