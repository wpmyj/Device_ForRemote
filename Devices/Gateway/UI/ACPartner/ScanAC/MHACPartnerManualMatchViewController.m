//
//  MHACPartnerManualMatchViewController.m
//  MiHome
//
//  Created by ayanami on 16/6/7.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerManualMatchViewController.h"
#import "MHACPartnerAddSucceedViewController.h"
#import "MHACPartnerUploadViewController.h"
#import "MHPromptKit.h"

#define kCURRENTBTN_WIDTH 96
#define kCURRENTBTN_HEIGHT 95.5



#define kHead NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.type.manual.plancount.head",@"plugin_gateway", "第")
#define kTail NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.type.manual.plancount.tail",@"plugin_gateway", "方案")

@interface MHACPartnerManualMatchViewController ()
@property (nonatomic, strong) MHDeviceAcpartner *acpartner;


@property (nonatomic, assign) int oldType;
@property (nonatomic, assign) BOOL hasSeeleted;


@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UILabel *planLabel;
@property (nonatomic, strong) UIButton *previousBtn;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UIButton *currentBtn;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, assign) NSInteger oldIndex;

@property (nonatomic, strong) UIButton *onBtn;
@property (nonatomic, strong) UIButton *offBtn;
@property (nonatomic, strong) UIButton *plusBtn;
@property (nonatomic, strong) UIButton *lessBtn;

@property (nonatomic, strong) UILabel *onLabel;
@property (nonatomic, strong) UILabel *offLabel;
@property (nonatomic, strong) UILabel *plusLabel;
@property (nonatomic, strong) UILabel *lessLabel;


@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UILabel *noneLabel;
@property (nonatomic, strong) UIButton *determineBtn;
@property (nonatomic, strong) UIButton *selectBtn;

@end

@implementation MHACPartnerManualMatchViewController
- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner
{
    self = [super init];
    if (self) {
        self.isTabBarHidden = YES;
        self.acpartner = acpartner;
        self.oldType = self.acpartner.ACType;
        self.acpartner.currentCodeIndex = 0;
        self.oldIndex = 0;
        
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.type.manual",@"plugin_gateway", "手动匹配空调");
//    [self restoreCurrentIdex];
    [[MHTipsView shareInstance] showTips:@"" modal:YES];

    
    if (self.oldBrandid == self.acpartner.brand_id && self.acpartner.codeList.count > 0) {
        [self.acpartner manualMatchSuccess:^(id obj) {
            [[MHTipsView shareInstance] hide];

        } failure:^(NSError *v) {
            [[MHTipsView shareInstance] hide];
        }];
    }
    else if (self.oldBrandid != self.acpartner.brand_id) {
        XM_WS(weakself);
        [self.acpartner getIrCodeListWithBrandId:self.acpartner.brand_id Success:^(id obj) {
            [weakself.acpartner manualMatchSuccess:^(id obj) {
                [[MHTipsView shareInstance] hide];

            } failure:^(NSError *v) {
                [[MHTipsView shareInstance] hide];

            }];
            [[MHTipsView shareInstance] hide];
            weakself.planLabel.text = [NSString stringWithFormat:@"%@%ld/%ld%@", kHead,weakself.acpartner.currentCodeIndex + 1, weakself.acpartner.codeList.count, kTail];
        } Failure:^(NSError *v) {
            [[MHTipsView shareInstance] hide];
        }];
    }

    
   
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.planLabel.text = [NSString stringWithFormat:@"%@%ld/%ld%@",  kHead,self.acpartner.currentCodeIndex + 1, self.acpartner.codeList.count, kTail];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self saveCurrentIndex];
    [self.acpartner saveACStatus];
}

- (void)buildSubviews {
    [super buildSubviews];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [MHColorUtils colorWithRGB:0x606060];
    self.titleLabel.font = [UIFont systemFontOfSize:20.0f];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.type.manual.title",@"plugin_gateway", "点击下方按键控制空调");
    [self.view addSubview:self.titleLabel];
    
    self.tipsLabel = [[UILabel alloc] init];
    self.tipsLabel.textColor = [MHColorUtils colorWithRGB:0x606060];
    self.tipsLabel.font = [UIFont systemFontOfSize:18.0f];
    self.tipsLabel.backgroundColor = [UIColor clearColor];
    self.tipsLabel.numberOfLines = 0;
    NSString *blue1 = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.type.manual.detail.green.one",@"plugin_gateway", "完成匹配");
    NSString *blue2 = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.type.manual.detail.green.two",@"plugin_gateway", "左右按键");
    
    NSString *strDetail = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.type.manual.detail",@"plugin_gateway", "如果有效果点击完成匹配,否则点击左右按键切换其他方案");
    
    NSMutableAttributedString *todayCountTailAttribute = [[NSMutableAttributedString alloc] initWithString:strDetail];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragraphStyle setLineSpacing:5];//调整行间距
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    
    [todayCountTailAttribute addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [strDetail length])];
    [todayCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x00ba7c] range:[strDetail rangeOfString:blue1]];
    [todayCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x00ba7c] range:[strDetail rangeOfString:blue2]];
    
    
    self.tipsLabel.attributedText = todayCountTailAttribute;
    [self.view addSubview:self.tipsLabel];
    
    self.planLabel = [[UILabel alloc] init];
    self.planLabel.textAlignment = NSTextAlignmentCenter;
    self.planLabel.textColor = [MHColorUtils colorWithRGB:0x606060];
    self.planLabel.font = [UIFont systemFontOfSize:18.0f];
    self.planLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.planLabel];
    
    _currentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_currentBtn setImage:[UIImage imageNamed:@"acpartner_device_mode_test"] forState:UIControlStateNormal];
    [self.view addSubview:_currentBtn];

    
    
    _previousBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_previousBtn addTarget:self action:@selector(goPrevious:) forControlEvents:UIControlEventTouchUpInside];
    [_previousBtn setTitleColor:[MHColorUtils colorWithRGB:0x606060] forState:UIControlStateNormal];
    [_previousBtn setImage:[UIImage imageNamed:@"acpartner_test_privious"] forState:UIControlStateNormal];
    [self.view addSubview:_previousBtn];
    _previousBtn.hidden = YES;
    
    _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_nextBtn addTarget:self action:@selector(goNext:) forControlEvents:UIControlEventTouchUpInside];
    [_nextBtn setTitleColor:[MHColorUtils colorWithRGB:0x606060] forState:UIControlStateNormal];
    [_nextBtn setImage:[UIImage imageNamed:@"acpartner_test_next"] forState:UIControlStateNormal];
    [self.view addSubview:_nextBtn];
    
    
    _onBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_onBtn addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [_onBtn setImage:[[UIImage imageNamed:@"acpartner_power_ontest"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    _onBtn.tag = POWER_ON_INDEX;
    [self.view addSubview:_onBtn];

    
    
    _offBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_offBtn addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [_offBtn setImage:[[UIImage imageNamed:@"acpartner_power_offtest"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    _offBtn.tag = POWER_OFF_INDEX;
    [self.view addSubview:_offBtn];
    
    
    _plusBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_plusBtn addTarget:self action:@selector(onPlus:) forControlEvents:UIControlEventTouchUpInside];
    [_plusBtn setImage:[[UIImage imageNamed:@"acpartner_temp_plustest"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [self.view addSubview:_plusBtn];
    
    _lessBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_lessBtn addTarget:self action:@selector(onLess:) forControlEvents:UIControlEventTouchUpInside];
    [_lessBtn setImage:[[UIImage imageNamed:@"acpartner_temp_lesstest"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [self.view addSubview:_lessBtn];

    
    
    self.onLabel = [[UILabel alloc] init];
    self.onLabel.textAlignment = NSTextAlignmentCenter;
    self.onLabel.textColor = [MHColorUtils colorWithRGB:0x606060];
    self.onLabel.font = [UIFont systemFontOfSize:22.0f];
    self.onLabel.backgroundColor = [UIColor clearColor];
    self.onLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.type.manual.button.on",@"plugin_gateway", "开");
    [self.view addSubview:self.onLabel];
    
    self.offLabel = [[UILabel alloc] init];
    self.offLabel.textAlignment = NSTextAlignmentCenter;
    self.offLabel.textColor = [MHColorUtils colorWithRGB:0x606060];
    self.offLabel.font = [UIFont systemFontOfSize:22.0f];
    self.offLabel.backgroundColor = [UIColor clearColor];
    self.offLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.type.manual.button.off",@"plugin_gateway", "关");
    [self.view addSubview:self.offLabel];

    
    self.plusLabel = [[UILabel alloc] init];
    self.plusLabel.textAlignment = NSTextAlignmentCenter;
    self.plusLabel.textColor = [MHColorUtils colorWithRGB:0x606060];
    self.plusLabel.font = [UIFont systemFontOfSize:22.0f];
    self.plusLabel.backgroundColor = [UIColor clearColor];
    self.plusLabel.text= NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.type.manual.button.tempplus",@"plugin_gateway", "温度+");
    [self.view addSubview:self.plusLabel];

    
    self.lessLabel = [[UILabel alloc] init];
    self.lessLabel.textAlignment = NSTextAlignmentCenter;
    self.lessLabel.textColor = [MHColorUtils colorWithRGB:0x606060];
    self.lessLabel.font = [UIFont systemFontOfSize:22.0f];
    self.lessLabel.backgroundColor = [UIColor clearColor];
    self.lessLabel.text= NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.type.manual.button.templess",@"plugin_gateway", "温度-");
    [self.view addSubview:self.lessLabel];

    
    
    self.footerView = [[UIView alloc] init];
    self.footerView.backgroundColor = [MHColorUtils colorWithRGB:0x00000 alpha:0.1];
    self.footerView.hidden = YES;
    [self.view addSubview:self.footerView];
    
    
    
    self.noneLabel = [[UILabel alloc] init];
    self.noneLabel.textAlignment = NSTextAlignmentCenter;
    self.noneLabel.textColor = [MHColorUtils colorWithRGB:0x606060];
    self.noneLabel.font = [UIFont systemFontOfSize:18.0f];
    self.noneLabel.backgroundColor = [UIColor clearColor];
    self.noneLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.type.manual.noplan",@"plugin_gateway", "没有匹配的方案 >");
    UITapGestureRecognizer *noneTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nonePlan:)];
    [self.noneLabel addGestureRecognizer:noneTap];
    self.noneLabel.userInteractionEnabled = YES;
    [self.view addSubview:self.noneLabel];
    
    
    _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *str = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.type.manual.complete",@"plugin_gateway", "完成匹配");

    NSMutableAttributedString *titleAttribute = [[NSMutableAttributedString alloc] initWithString:str];
    [titleAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x858585] range:NSMakeRange(0, str.length)];
    [titleAttribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0f] range:NSMakeRange(0, str.length)];
    [_selectBtn setAttributedTitle:titleAttribute forState:UIControlStateNormal];
    [_selectBtn addTarget:self action:@selector(onSelect:) forControlEvents:UIControlEventTouchUpInside];
    _selectBtn.layer.cornerRadius = 20.0f;
    _selectBtn.layer.borderWidth = 0.5f;
    _selectBtn.layer.borderColor = [[MHColorUtils colorWithRGB:0xBCBCBC] CGColor];
    [self.view addSubview:_selectBtn];
    
    

}

- (void)buildConstraints {
    [super buildConstraints];
    XM_WS(weakself);
    
    CGFloat btnSize = 48;
    CGFloat btnLabelSpacing = 10 * ScaleHeight;
    CGFloat labelSpcaing = 20 * ScaleHeight;
    CGFloat btnSpcaing = 20 * ScaleWidth;

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.view).with.offset(92 * ScaleHeight);
        make.centerX.equalTo(weakself.view);
    }];

    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.titleLabel.mas_bottom).with.offset(btnSpcaing);
        make.centerX.equalTo(weakself.view);
        make.width.mas_equalTo(WIN_WIDTH - 40);
    }];

    
    [self.planLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.tipsLabel.mas_bottom).with.offset(btnSpcaing);
        make.centerX.equalTo(weakself.view);
    }];
    
    //测试按键
    [self.onBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.planLabel.mas_bottom).with.offset(labelSpcaing);
        make.right.equalTo(weakself.view.mas_centerX).with.offset(-btnSpcaing);
        make.size.mas_equalTo(CGSizeMake(btnSize, btnSize));
    }];
    
    [self.onLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.onBtn.mas_bottom).with.offset(btnLabelSpacing);
        make.centerX.equalTo(weakself.onBtn);
    }];
    
    [self.plusBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.planLabel.mas_bottom).with.offset(labelSpcaing);
        make.left.equalTo(weakself.view.mas_centerX).with.offset(btnSpcaing);
        make.size.mas_equalTo(CGSizeMake(btnSize, btnSize));
    }];
    
    [self.plusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.plusBtn.mas_bottom).with.offset(btnLabelSpacing);
        make.centerX.equalTo(weakself.plusBtn);
    }];
    
    [self.offBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.onLabel.mas_bottom).with.offset(labelSpcaing);
        make.centerX.equalTo(weakself.onBtn);
        make.size.mas_equalTo(CGSizeMake(btnSize, btnSize));
    }];
    
    [self.offLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.offBtn.mas_bottom).with.offset(btnLabelSpacing);
        make.centerX.equalTo(weakself.onBtn);
    }];
    
    
    [self.lessBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.plusLabel.mas_bottom).with.offset(labelSpcaing);
        make.centerX.equalTo(weakself.plusBtn);
        make.size.mas_equalTo(CGSizeMake(btnSize, btnSize));
    }];
    
    [self.lessLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.lessBtn.mas_bottom).with.offset(btnLabelSpacing);
        make.centerX.equalTo(weakself.plusBtn);
    }];

    
//    26 * 47
    
    [self.previousBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.view.mas_left).with.offset(btnSpcaing);
        make.centerY.equalTo(weakself.onLabel.mas_bottom).with.offset(btnLabelSpacing);
        make.size.mas_equalTo(CGSizeMake(26, 47));
    }];
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakself.view.mas_right).with.offset(-btnSpcaing);
        make.centerY.equalTo(weakself.previousBtn);
        make.size.mas_equalTo(CGSizeMake(26, 47));
    }];
    
    
    
    CGFloat btnHeight = 46;
    
    [self.selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakself.view).with.offset(-30);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(WIN_WIDTH - 60, btnHeight));
    }];
    
    
    
    [self.noneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakself.selectBtn.mas_top).with.offset(-20);
        make.centerX.equalTo(weakself.view);
    }];
    
    
    
}


- (void)saveCurrentIndex {
//    [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:[NSString stringWithFormat:@"isfirst%@%@", self.acpartner.did, [MHPassportManager sharedSingleton].currentAccount.userId]];
//    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)restoreCurrentIdex {
//    self.acpartner.currentCodeIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"isfirst%@%@", self.acpartner.did, [MHPassportManager sharedSingleton].currentAccount.userId]] integerValue];
}



#pragma mark - 控制
- (void)goPrevious:(id)sender {
    self.acpartner.currentCodeIndex = self.acpartner.currentCodeIndex - 1;
    if (self.acpartner.currentCodeIndex >= 0 && self.acpartner.currentCodeIndex <= self.acpartner.codeList.count - 1) {
        [self restartScan];
        [self gw_clickMethodCountWithStatType:@"manualRemotePreviousPlan:"];
    }

}

- (void)goNext:(id)sender {
    self.acpartner.currentCodeIndex = self.acpartner.currentCodeIndex + 1;

    [self restartScan];
    [self gw_clickMethodCountWithStatType:@"manualRemoteNextPlan:"];

}

- (void)restartScan {
    
    
    XM_WS(weakself);
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.type.manual.plancount.change",@"plugin_gateway", "点击下方按键控制空调") modal:YES];
    
    [self.acpartner manualMatchSuccess:^(id obj) {
        weakself.oldIndex = weakself.acpartner.currentCodeIndex;
        [weakself updatebtnStatus];
        [[MHTipsView shareInstance] hide];
        weakself.planLabel.text = [NSString stringWithFormat:@"%@%ld/%ld%@", kHead,weakself.acpartner.currentCodeIndex + 1, weakself.acpartner.codeList.count, kTail];

    } failure:^(NSError *v) {
        [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.type.manual.plancount.change.failed",@"plugin_gateway", "更换方案失败,请重试") duration:1.5f modal:YES];
        weakself.acpartner.currentCodeIndex = weakself.oldIndex;
        [weakself updatebtnStatus];

    }];
    
}

- (void)updatebtnStatus {
    if (self.acpartner.currentCodeIndex == 0) {
        self.previousBtn.hidden = YES;
    }
    else if (self.acpartner.currentCodeIndex > 0 && self.acpartner.currentCodeIndex < self.acpartner.codeList.count - 2) {
        self.previousBtn.hidden = NO;
        self.nextBtn.hidden = NO;
    }
    else if (self.acpartner.currentCodeIndex == self.acpartner.codeList.count - 1) {
        self.nextBtn.hidden = YES;
    }
}

- (void)onBack:(id)sender {
//    [super onBack];
    if (self.hasSeeleted) {
        return;
    }
    XM_WS(weakself);
    NSString *strTitle = [NSString stringWithFormat:@"%@(%@%ld%@)", NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.type.manual.plancount.back.tips",@"plugin_gateway", "需要使用当前方案吗?"),kHead,self.acpartner.currentCodeIndex + 1, kTail];

    NSArray *buttonArray = @[ NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.type.manual.plancount.use",@"plugin_gateway", "使用"), NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.type.manual.plancount.notuse",@"plugin_gateway", "不使用") ];
    
    [[MHPromptKit shareInstance] showAlertWithHandler:^(NSInteger buttonIndex, NSArray *inputs) {
        switch (buttonIndex) {
            case 0: {
                [weakself.acpartner updateCommandMapSuccess:^(id obj) {
                    [weakself.acpartner restoreACStatus];
                } failure:^(NSError *v) {
                    
                }];
                [weakself.acpartner saveACStatus];
                [weakself goBackToMainPage];
                [weakself gw_clickMethodCountWithStatType:@"manualRemoteUsePlan:"];
            }
                break;
            case 1: {
                [weakself gw_clickMethodCountWithStatType:@"manualRemoteQuitPlan:"];
                __block NSString *model = nil;
                if (weakself.oldBrandid && weakself.oldRemoteid) {
                    if (weakself.acpartner.brand_id != weakself.oldBrandid) {
                        [weakself.acpartner getIrCodeListWithBrandId:weakself.oldBrandid Success:^(id obj) {
                            weakself.acpartner.brand_id = weakself.oldBrandid;
                            model = [weakself.acpartner generateModelWithRemoteid:weakself.oldRemoteid brandid:weakself.oldBrandid];
                            [weakself.acpartner setACByModel:model success:^(id obj) {
                                
                                
                            } failure:^(NSError *v) {
                                
                            }];
                            [weakself goBackToMainPage];

                        } Failure:^(NSError *v) {
                            
                        }];
                    }
                    else {
                        model = [weakself.acpartner generateModelWithRemoteid:weakself.oldRemoteid brandid:weakself.oldBrandid];
                        [weakself.acpartner setACByModel:model success:^(id obj) {
                            
                            
                        } failure:^(NSError *v) {
                            
                        }];
                        [weakself goBackToMainPage];
                    }

                }
                else {
                    model = kNONACMODEL;
                    [weakself.acpartner setACByModel:model success:^(id obj) {
                        
                        
                    } failure:^(NSError *v) {
                        
                    }];
                    [weakself goBackToMainPage];
                }
               
            }
                break;
                
            default:
                break;
        }
    } withTitle:@"" message:strTitle style:UIAlertViewStyleDefault defaultText:nil cancelButtonTitle:nil otherButtonTitlesArray:buttonArray];
}

- (void)onSelect:(id)sender {
    _hasSeeleted = YES;
    [self saveCurrentIndex];
    [self.acpartner saveACStatus];
    if (self.acpartner.ACType == 2) {
        [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:[NSString stringWithFormat:@"isfirst%@%@", self.acpartner.ACRemoteId,[MHPassportManager sharedSingleton].currentAccount.userId]];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:[NSString stringWithFormat:@"%@%@", self.acpartner.did, kHASSCANED]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    XM_WS(weakself);
    
    [self.acpartner updateCommandMapSuccess:^(id obj) {
        [weakself.acpartner restoreACStatus];
    } failure:^(NSError *v) {
        
    }];
    [self goBackToMainPage];
    [self gw_clickMethodCountWithStatType:@"manualRemoteCompleteRematch:"];
    
}

- (void)goBackToMainPage {
    XM_WS(weakself);
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([NSStringFromClass([obj class]) isEqualToString:@"MHACPartnerMainViewController"]) {
            [weakself.navigationController popToViewController:obj animated:YES];
            *stop = YES;
        }
        
    }];
}

//没有匹配的方案
- (void)nonePlan:(id)sender {
    MHACPartnerUploadViewController *succeedVC = [[MHACPartnerUploadViewController alloc] init];
    [self.navigationController pushViewController:succeedVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"manualRemoteNoMatchPlan:"];

//    MHACPartnerUploadViewController *uploadVC = [[MHACPartnerUploadViewController alloc] init];
//    [self.navigationController pushViewController:uploadVC animated:YES];
}

#pragma mark - 控制
- (void)onSwitch:(UIButton *)sender {
    XM_WS(weakself);
    
    [self gw_clickMethodCountWithStatType:@"manualRemoteSwitch:"];

    if (self.acpartner.ACType == 1) {
        
        [self.acpartner sendCommand:[self.acpartner getACCommand:(ACPARTNER_NON_PULSE_Id)(sender.tag) commandIndex:POWER_COMMAND isTimer:NO] success:^(id obj) {
            if (sender.tag == POWER_ON_INDEX) {
                weakself.acpartner.powerState = 1;
            }
            if (sender.tag == POWER_OFF_INDEX) {
                weakself.acpartner.powerState = 0;
            }
            
        } failure:^(NSError *v) {
            
        }];
    }
    
    if (self.acpartner.ACType == 3) {
    
        NSString *command = [self.acpartner getACCommand:(ACPARTNER_NON_PULSE_Id)(sender.tag) commandIndex:POWER_COMMAND isTimer:NO];
        [self.acpartner sendCommand:command success:^(id obj) {
            if (sender.tag == POWER_ON_INDEX) {
                weakself.acpartner.powerState = 1;
            }
            if (sender.tag == POWER_OFF_INDEX) {
                weakself.acpartner.powerState = 0;
            }

        } failure:^(NSError *v) {
            
        }];
    }
    if (self.acpartner.ACType == 2) {
        if (sender.tag == POWER_ON_INDEX) {
            [self.acpartner.kkAcManager changePowerStateWithPowerstate:AC_POWER_ON];
        }
        if (sender.tag == POWER_OFF_INDEX) {
            [self.acpartner.kkAcManager changePowerStateWithPowerstate:AC_POWER_OFF];
        }
        [self.acpartner.kkAcManager getPowerState];
        NSString *command = [self.acpartner getACCommand:(ACPARTNER_NON_PULSE_Id)sender.tag commandIndex:POWER_COMMAND isTimer:NO];
        [self.acpartner sendCommand:command success:^(id obj) {
            if (sender.tag == POWER_ON_INDEX) {
                weakself.acpartner.powerState = 1;
            }
            if (sender.tag == POWER_OFF_INDEX) {
                weakself.acpartner.powerState = 0;
            }

        } failure:^(NSError *v) {
            
        }];
    }
    
}

- (void)onPlus:(id)sender {
    XM_WS(weakself);
    [self gw_clickMethodCountWithStatType:@"manualRemotePlusTemp:"];

    if (self.acpartner.ACType == 1) {
        [self.acpartner sendCommand:[self.acpartner getACCommand:TEMP_PLUS_INDEX commandIndex:TEMP_PLUS_COMMAND isTimer:NO] success:^(id obj) {
            
        } failure:^(NSError *v) {
            
        }];
    }
    
    
    if (self.acpartner.ACType == 2  || self.acpartner.ACType == 3) {
        int tempTemp = self.acpartner.temperature;
        
        if (self.acpartner.ACType == 3) {
            if (self.acpartner.temperature + 1 <= TEMPERATUREMAX) {
                self.acpartner.temperature += 1;
                NSString *command = [self.acpartner getACCommand:TEMP_PLUS_INDEX commandIndex:TEMP_PLUS_COMMAND isTimer:NO];
                [self.acpartner sendCommand:command success:^(id obj) {
                } failure:^(NSError *v) {
                    weakself.acpartner.temperature = tempTemp;
                }];
            }
        }
        else {
            if (([self.acpartner.kkAcManager canControlTemp] == YES && self.acpartner.temperature < TEMPERATUREMAX ) && [[self.acpartner.kkAcManager getLackOfTemperatureArray] containsObject:[NSString stringWithFormat:@"%d",self.acpartner.temperature + 1]] == NO) {
                self.acpartner.temperature += 1;
                [self.acpartner.kkAcManager changeTemperatureWithTemperature:self.acpartner.temperature];
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
            } failure:^(NSError *v) {
                weakself.acpartner.temperature = tempTemp;
            }];
            
        }
    }
    
}

- (void)onLess:(id)sender {
    XM_WS(weakself);
    [self gw_clickMethodCountWithStatType:@"manualRemoteLessTemp:"];

    if (self.acpartner.ACType == 1) {
        [self.acpartner sendCommand:[self.acpartner getACCommand:TEMP_LESS_INDEX commandIndex:TEMP_LESS_COMMAND isTimer:NO] success:^(id obj) {
            
        } failure:^(NSError *v) {
            
        }];
        
    }
    
    if (self.acpartner.ACType == 2  || self.acpartner.ACType == 3) {
        int tempTemp = self.acpartner.temperature;
        
        if (self.acpartner.ACType == 3) {
            if (self.acpartner.temperature - 1 >= TEMPERATUREMIN) {
                self.acpartner.temperature -= 1;
                NSString *command = [self.acpartner getACCommand:TEMP_LESS_INDEX commandIndex:TEMP_LESS_COMMAND isTimer:NO];
                [self.acpartner sendCommand:command success:^(id obj) {
                    //                weakself.acpartner.temperature = [weakself.acpartner.kkAcManager getTemperature];
                } failure:^(NSError *v) {
                    weakself.acpartner.temperature = tempTemp;
                }];
            }
        }
        else {
            if (([self.acpartner.kkAcManager canControlTemp] == YES && self.acpartner.temperature > TEMPERATUREMIN )&&[[self.acpartner.kkAcManager getLackOfTemperatureArray] containsObject:[NSString stringWithFormat:@"%d",self.acpartner.temperature - 1]] == NO) {
                self.acpartner.temperature -= 1;
                [self.acpartner.kkAcManager changeTemperatureWithTemperature:self.acpartner.temperature];
                
            }
            
            NSString *command = [self.acpartner getACCommand:TEMP_LESS_INDEX commandIndex:TEMP_LESS_COMMAND isTimer:NO];
            [self.acpartner sendCommand:command success:^(id obj) {
                //                weakself.acpartner.temperature = [weakself.acpartner.kkAcManager getTemperature];
            } failure:^(NSError *v) {
                weakself.acpartner.temperature = tempTemp;
            }];
            
        }
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
