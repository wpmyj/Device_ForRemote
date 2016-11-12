//
//  MHACPartnerDetailViewController.m
//  MiHome
//
//  Created by ayanami on 16/5/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerDetailViewController.h"
#import "MHACPartnerTimerNewSettingViewController.h"
#import "MHACPartnerMoreFunctionSettingViewController.h"
#import "MHACPartnerModeSettingViewController.h"
#import "MHACPartnerWindsSettingViewController.h"
#import "MHACPartnerPickerView.h"
#import "MHACPartnerCircleView.h"
#import "MHACPartnerQuantView.h"
#import "MHACPartnerStatusView.h"
#import "MHLumiSensorFooterView.h"
#import "MHACPartnerQuantViewController.h"
#import "MHLumiLogGraphManager.h"
#import "MHLumiPlugDataManager.h"
#import "MHLumiPlugQuantEngine.h"
#import "MHWaveAnimation.h"
#import "MHACTypeModel.h"
#import "MHACPartnerAddTipsViewController.h"
#import "MHACCustomRemoteNameViewController.h"
#import "MHACSleepViewController.h"
#import "MHACPartnerCountdownViewController.h"
#import "MHACCoolSpeedViewController.h"
#import "MHACPartnerReMatchViewController.h"
#import "MHACAddRemoteViewController.h"
#import "MHLMGuidePage.h"
#import "MHACSleepSettingViewController.h"


#define kACGuidePagesKey @"lifeScene"


#define LabelWhiteTextColor [UIColor whiteColor]
#define kACPartner_DefaultBtn_Count 8
#define kACPartner_Status_time 2

static NSUInteger acpartnerDefaultCount;

@interface MHACPartnerDetailViewController ()<ACPartnerCountdownDelegate>

@property (nonatomic, strong) MHDeviceAcpartner *acpartner;

@property (nonatomic, strong) UIButton *plusBtn;
@property (nonatomic, strong) UIButton *lessBtn;

@property (nonatomic, strong) UIImageView *temperatureImageView;

@property (nonatomic, strong) MHACPartnerPickerView *picker;
@property (nonatomic, strong) MHACPartnerCircleView *circleView;
@property (nonatomic, strong) MHACPartnerQuantView *quantView;
@property (nonatomic, strong) MHACPartnerStatusView *statusView;
@property (nonatomic, strong) MHLumiSensorFooterView *footerView;
@property (nonatomic, strong) UIButton *addAcBtn;
@property (nonatomic, strong) UILabel *addAcLabel;
@property (nonatomic, strong) NSTimer *powerTimer;

@property (nonatomic,assign) BOOL shouldKeepRunning;
@property (nonatomic, assign) BOOL isFold;

//layoutGuideView
@property (nonatomic, strong) UIView *layoutGuideView;

@end

@implementation MHACPartnerDetailViewController {
    MHWaveAnimation *_waveAnimation;
}

- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner
{
    self = [super init];
    if (self) {
        self.isTabBarHidden = YES;
        self.acpartner = acpartner;
        acpartnerDefaultCount = 8;
        
        [self getCurrentACBrand];
    }
    return self;
}

- (void)getCurrentACBrand {
    XM_WS(weakself);
    if (self.acpartner.acTypeList.count) {
        [[self.acpartner.acTypeList lastObject] enumerateObjectsUsingBlock:^(MHACTypeModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            if (model.brand_id == weakself.acpartner.brand_id) {
                weakself.acpartner.ACBrand = [[MHLumiHtmlHandleTools sharedInstance] currentLanguageIsChinese] ? model.name : model.eng_name;
                *stop = YES;
            }
        }];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    XM_WS(weakself);
    self.title = [NSString stringWithFormat:@"(%@)%@%@", self.acpartner.ACBrand,NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.control",@"plugin_gateway","空调控制"), self.acpartner.ACRemoteId];
    self.isNavBarTranslucent = YES;
    //    self.view.backgroundColor = [MHColorUtils colorWithRGB:0x22333f];
    self.view.backgroundColor = [MHColorUtils colorWithRGB:0x202f3b];
    self.isFold = NO;
    
    //获取扩展码
    [self.acpartner getExtraIrCodeListSuccess:^(id obj) {
        
    } Failure:^(NSError *error) {
        
    }];
    
    
    [self.acpartner getLearnedRemoteListSuccess:^(id obj) {
        [weakself.footerView rebuildView:[weakself buildFooterResource]];
    } failure:^(NSError *v) {
        
    }];
    
    [self loadStatus];
    
    if (![self isGuidePagesShown]) {
        [self setIsShowGuidePages:YES];
        [self showGuide];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateStatus];
    [self startWatchingAcpartnerStatus];
    NSLog(@"是否展开%d", self.isFold);
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    XM_WS(weakself);
    [[NSNotificationCenter defaultCenter] addObserverForName:AddRemoteNotiName object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSDictionary *dic = note.userInfo;
        [weakself rebuildRemote:dic];
        [weakself foldViewAnimated:NO];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopWatchingAcpartnerStatus];
    
}


- (void)loadStatus {
    XM_WS(weakself);
    [self.acpartner restorePlugData:kQuantDay];
    [self.acpartner restorePlugData:kQuantMonth];
    
    [self startGetQuant];
    
    [self.acpartner getACTypeAndStatusSuccess:^(id obj) {
        [weakself.acpartner handleNewStatus:obj isRepeat:NO];
        [weakself updateStatus];
    } failure:^(NSError *v) {
        
    }];
    
    [[MHLumiPlugDataManager sharedInstance] setQuantDevice:self.acpartner];
    [[MHLumiPlugQuantEngine sharedEngine] findStartPoint:kQuantDay];
    [[MHLumiPlugQuantEngine sharedEngine] findStartPoint:kQuantMonth];
    
    //电量统计数据
    [self.acpartner fetchPlugDataWithSuccess:^(id obj){
        [weakself updateStatus];
    } failure:nil];
    
    
    [self.acpartner getTimerListWithID:kACPARTNERCOUNTDOWNTIMERID Success:^(id obj) {
        [weakself.acpartner fetchCountDownTime:^(NSInteger hour, NSInteger minute) {
            weakself.acpartner.pwHour = hour;
            weakself.acpartner.pwMinute = minute;
        }];
    } failure:^(NSError *v) {
        
    }];
    
    
    
    
    
}

- (void)buildSubviews {
    [super buildSubviews];
    XM_WS(weakself);
    
    self.layoutGuideView = [[UIView alloc] init];
    
    [self.view addSubview:self.layoutGuideView];
    
    UIImage* imageMore = [[UIImage imageNamed:@"navi_more_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *rightItemMore = [[UIBarButtonItem alloc] initWithImage:imageMore style:UIBarButtonItemStylePlain target:self action:@selector(onMore:)];
    self.navigationItem.rightBarButtonItem = rightItemMore;
    
    
    _addAcBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_addAcBtn addTarget:self action:@selector(onAddAc:) forControlEvents:UIControlEventTouchUpInside];
    [_addAcBtn setBackgroundImage:[UIImage imageNamed:@"acpartner_home_addac"] forState:UIControlStateNormal];
    
    [self.view addSubview:_addAcBtn];
    
    _addAcLabel = [[UILabel alloc] init];
    _addAcLabel.textAlignment = NSTextAlignmentCenter;
    _addAcLabel.font = [UIFont systemFontOfSize:16.0f];
    _addAcLabel.textColor = [UIColor whiteColor];
    _addAcLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add",@"plugin_gateway","添加空调");
    UITapGestureRecognizer *addTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAddAc:)];
    [_addAcLabel addGestureRecognizer:addTap];
    _addAcLabel.userInteractionEnabled = YES;
    [self.view addSubview:_addAcLabel];
    
    
    
    _temperatureImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"acpartner_device_temperatureControl"]];
    _temperatureImageView.userInteractionEnabled = YES;
    [self.view addSubview:_temperatureImageView];
    _temperatureImageView.hidden = YES;
    
    _plusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_plusBtn addTarget:self action:@selector(onPlusTemperature:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_plusBtn];
    
    _lessBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_lessBtn addTarget:self action:@selector(onLessTemperature:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_lessBtn];
    
    //状态
    _statusView = [[MHACPartnerStatusView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, 200) ACPartner:self.acpartner];
    _statusView.plusCallback = ^{
        [weakself onPlus];
    };
    _statusView.lessCallback = ^{
        [weakself onLess];
    };
    [_statusView setSwitchCallback:^{
        [weakself onSwitch];
    }];
    [self.view addSubview:_statusView];
    
    //功率
    _quantView = [[MHACPartnerQuantView alloc] initWithFrame:CGRectMake(0, 500, WIN_WIDTH, 80)];
    _quantView.todayCallback = ^{
        [weakself quantClicked:10000];
    };
    _quantView.monthCallback = ^{
        [weakself quantClicked:10001];
        
    };
    _quantView.quantCallback = ^{
        [weakself onQuantTrend];
    };
    
    
    
    [self.view addSubview:_quantView];
    
    
    NSDictionary *footerSource = [self buildFooterResource];
    self.footerView = [[MHLumiSensorFooterView alloc] initWithSource:footerSource handle:^(NSInteger buttonIndex, NSInteger btnTag, NSString *name) {
        switch (buttonIndex) {
            case 0:
                NSLog(@"零号机------");
                [weakself onSwitch];
                break;
            case 1:
                NSLog(@"初号机------");
                [weakself onDelayOff];
                break;
            case 2:
                NSLog(@"二号机------");
                [weakself onSpeedCoolMode];
                break;
            case 3:
                NSLog(@"六号机------");
                [weakself onSleepMode];
                break;
            case 4:
                NSLog(@"六号机------");
                [weakself onSwing];
                break;
            case 5:
                NSLog(@"六号机------");
                [weakself onWinds];
                break;
            case 6:
                NSLog(@"六号机------");
                [weakself onMode];
                break;
            default:
                break;
        }
        if (btnTag == BtnTag_Light) {
            
            [weakself onLED];
        }
        
        if (btnTag == BtnTag_Add) {
            NSLog(@"十三号机------");
            [weakself addNewRemote];
        }
        if (buttonIndex >= 7) {
            if (!weakself.acpartner.powerState) {
                return ;
            }
            [weakself.acpartner.customFunctionList enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {
                NSLog(@"%@", dic);
                if (![dic isKindOfClass:[NSDictionary class]]) {
                    return;
                }
                [self gw_clickMethodCountWithStatType:@"ACPartnerCustomButton:"];
                if ([dic[kACNameKey] isEqualToString:name]) {
                    NSString *strCmd = dic[kACCmdKey];
                    [weakself.acpartner sendIrCode:strCmd success:^(id obj) {
                        
                    } failure:^(NSError *v) {
                        
                    }];
                    *stop = YES;
                }
            }];
        }
        
    }];
    [self.footerView setFoldCallback:^(){
        [weakself.footerView hideDelete];
        [weakself gw_clickMethodCountWithStatType:@"ACPartnerFoldFooterView:"];
        weakself.isFold = !weakself.isFold;
        if (weakself.isFold) {
            [weakself foldViewAnimated:YES];
        }
        else {
            [weakself unfoldViewAnimated:YES];
        }
    }];
    [self.footerView setDeleteCallback:^(NSString *name) {
        [weakself deleteCustomButton:name];
    }];
    
    [self.footerView setPanFoldCallback:^(UIPanGestureRecognizerDirection direction) {
        [weakself gw_clickMethodCountWithStatType:@"ACPartnerFoldFooterView:"];
        switch (direction) {
            case UIPanGestureRecognizerDirectionUp: {
                if (!weakself.isFold)  {
                    [weakself foldViewAnimated:YES];
                    weakself.isFold = YES;
                }
                
                break;
            }
            case UIPanGestureRecognizerDirectionDown: {
                if (weakself.isFold)  {
                    [weakself unfoldViewAnimated:YES];
                    weakself.isFold = NO;
                }
                break;
            }
            default: {
                break;
            }
        }
    }];
    
    [self.view addSubview:self.footerView];
    
    
    
    _waveAnimation = [[MHWaveAnimation alloc] initWithFrame:CGRectZero];
    _waveAnimation.waveInterval = 0.5f;
    _waveAnimation.singleWaveScale = 1.5f;
    [self.view addSubview:_waveAnimation];
    
    [self updateStatus];
    
}

- (NSDictionary *)buildFooterResource {
    NSDictionary *source = nil;
    NSMutableArray *imageArray = [NSMutableArray arrayWithArray:@[ @"gateway_plug_kaion", @"acpartner_device_delay", @"acpartner_device_coolspeed", @"acpartner_device_sleep", @"acpartner_device_swing", @"acpartner_device_winds", @"acpartner_device_mode"]];
    NSMutableArray *nameArray = [NSMutableArray arrayWithArray:@[ NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.switch",@"plugin_gateway","开关"), NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.footer.delayoff",@"plugin_gateway","延时关"), NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.footer.coolmode",@"plugin_gateway","速冷设置"), NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.footer.sleepmode",@"plugin_gateway","睡眠设置"),NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.airswing",@"plugin_gateway","扫风"),NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.fanspeed",@"plugin_gateway","风速"), NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.mode",@"plugin_gateway","模式")]];
    
    if ([self.acpartner isExtraRemoteId]) {
        [imageArray addObject:@"acpartner_device_led"];
        [nameArray addObject:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.footer.led",@"plugin_gateway","灯光")];
    }
    //
    NSUInteger limitCount = [self.acpartner isExtraRemoteId] ? 5 : 6;
    acpartnerDefaultCount = [self.acpartner isExtraRemoteId] ? 9 : 8;
    
    //
    //无速冷
    //    NSMutableArray *imageArray = [NSMutableArray arrayWithArray:@[ @"gateway_plug_kaion", @"acpartner_device_delay", @"acpartner_device_sleep", @"acpartner_device_winds", @"acpartner_device_mode"]];
    //     NSMutableArray *nameArray = [NSMutableArray arrayWithArray:@[ NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.switch",@"plugin_gateway","开关"), @"延时关", @"睡眠模式",NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.fanspeed",@"plugin_gateway","风速"), NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.mode",@"plugin_gateway","模式")]];
    [self.acpartner.customFunctionList enumerateObjectsUsingBlock:^(NSDictionary *function, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@", function);
        if (![function isKindOfClass:[NSDictionary class]]) {
            return;
        }
        [imageArray addObject:@"acpartner_device_common"];
        [nameArray addObject:function[kACNameKey]];
        //限制数量
        if (idx == limitCount) {
            *stop = YES;
        }
    }];
    [imageArray addObjectsFromArray:@[@"acpartner_device_add", @"acpartner_device_delete"]];
    [nameArray addObjectsFromArray:@[NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.footer.addremote",@"plugin_gateway","添加按键"), NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.footer.deleteremote",@"plugin_gateway","删除按键")]];
    
    source = @{ kIMAGENAMEKEY : imageArray, kTEXTKEY : nameArray };
    return source;
}



- (void)foldViewAnimated:(BOOL)animated
{
    [self gw_clickMethodCountWithStatType:@"ACPartnerFold:"];
    CGFloat foldHeight = [self footerLineCount] * ItemDefaultHeigh;
    
    XM_WS(weakself);
    
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect tempRect = weakself.footerView.frame;
            tempRect.size.height = tempRect.size.height + foldHeight;
            tempRect.origin.y = tempRect.origin.y - foldHeight;
            weakself.footerView.frame = tempRect;
        } completion:^(BOOL finished) {
            [weakself.footerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.bottom.right.equalTo(weakself.view);
                make.height.mas_equalTo(153 * ScaleHeight + foldHeight);
            }];
            [weakself.footerView updateArrow:@"acpartner_device_unfold"];
        }];
    }
    else {
        CGRect tempRect = self.footerView.frame;
        tempRect.size.height = tempRect.size.height + foldHeight;
        tempRect.origin.y = tempRect.origin.y - foldHeight;
        self.footerView.frame = tempRect;
        [self.footerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(weakself.view);
            make.height.mas_equalTo(153 * ScaleHeight + foldHeight);
        }];
        [self.footerView updateArrow:@"acpartner_device_unfold"];
        
    }
    
    
}

- (void)unfoldViewAnimated:(BOOL)animated {
    XM_WS(weakself);
    [self gw_clickMethodCountWithStatType:@"ACPartnerUnfold:"];
    CGFloat foldHeight = [self footerLineCount] * ItemDefaultHeigh;
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect tempRect = weakself.footerView.frame;
            tempRect.size.height = tempRect.size.height - foldHeight;
            tempRect.origin.y = tempRect.origin.y + foldHeight;
            weakself.footerView.frame = tempRect;
        } completion:^(BOOL finished) {
            [weakself.footerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.bottom.right.equalTo(weakself.view);
                make.height.mas_equalTo(153 * ScaleHeight);
            }];
            [weakself.footerView updateArrow:@"acpartner_device_fold"];
        }];
    }
    else {
        CGRect tempRect = self.footerView.frame;
        tempRect.size.height = tempRect.size.height - foldHeight;
        tempRect.origin.y = tempRect.origin.y + foldHeight;
        self.footerView.frame = tempRect;
        [self.footerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(weakself.view);
            make.height.mas_equalTo(153 * ScaleHeight);
        }];
        [self.footerView updateArrow:@"acpartner_device_fold"];
    }
    
}

- (NSInteger)footerLineCount {
    NSInteger itemCount = self.acpartner.customFunctionList.count + acpartnerDefaultCount;
    itemCount += self.acpartner.customFunctionList.count ? 1 : 0;
    NSInteger line = itemCount / 4 - 1;
    if (itemCount % 4 != 0) {
        line += 1;
    }
    return line;
}

- (void)buildConstraints {
    [super buildConstraints];
    XM_WS(weakself);
    //    90 * 244
    // 90 * 90  65
    //200
    //48 * 48
    
    CGFloat imageTopSpacing = 100 * ScaleHeight;
    CGFloat imageWidth = 90;
    CGFloat imageHeight = 244;
    
    CGFloat temperatureBtnSize = 90;
    CGFloat plusLessSpacing = 65;
    
    
    CGFloat footerHeight =  153 * ScaleHeight;
    CGFloat foldHeight = [self footerLineCount] * ItemDefaultHeigh;
    footerHeight = self.isFold ? (footerHeight + foldHeight) : footerHeight;
    //没有空调
    CGFloat addBtnSpacing = 180 * ScaleHeight;
    CGFloat addLabelSapcing = 52 * ScaleHeight;
    CGFloat addBtnSize = 130 * ScaleWidth;
    
    [self.footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(weakself.view);
        make.height.mas_equalTo(footerHeight);
    }];
    
    [self.quantView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakself.view);
        make.height.mas_equalTo(65);
        make.bottom.mas_equalTo(self.view).with.offset(-(20 * ScaleHeight) - (153 * ScaleHeight));
    }];
    
    CGFloat h = self.navigationController.navigationBar.bounds.size.height + 20;
    [self.layoutGuideView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.quantView.mas_top);
        make.top.equalTo(self.view).offset(h);
    }];
    
    
    [self.statusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.centerY.equalTo(self.layoutGuideView);
        make.height.mas_equalTo(200);
    }];
    
    [self.addAcBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(addBtnSize, addBtnSize));
        make.top.mas_equalTo(weakself.view.mas_top).with.offset(addBtnSpacing);
    }];
    
    
    [self.addAcLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.view);
        make.top.mas_equalTo(weakself.addAcBtn.mas_bottom).with.offset(addLabelSapcing);
    }];
    
    
    [self.plusBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.view.mas_top).with.offset(imageTopSpacing);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(temperatureBtnSize, temperatureBtnSize));
    }];
    
    
    [self.lessBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.plusBtn.mas_bottom).with.offset(plusLessSpacing);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(temperatureBtnSize, temperatureBtnSize));
    }];
    
    [self.temperatureImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.view.mas_top).with.offset(imageTopSpacing);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(imageWidth, imageHeight));
        //        make.size.mas_equalTo(controlImage.size);
    }];
}

#pragma mark - 控制
- (void)onTimer {
    MHACPartnerTimerNewSettingViewController *tVC = [[MHACPartnerTimerNewSettingViewController alloc] initWithDevice:self.acpartner andIdentifier:kACPARTNERTIMERID];
    tVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.timer.title",@"plugin_gateway","空调定时");
    tVC.controllerIdentifier = kACPARTNERTIMERID;
    [self.navigationController pushViewController:tVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"openACPartnerTimerSetting:"];
}

- (void)reMatchAC {
    MHACPartnerReMatchViewController *rematchVC = [[MHACPartnerReMatchViewController alloc] initWithAcpartner:self.acpartner type:REMACTCH_INDEX];
    [self.navigationController pushViewController:rematchVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"openACPartnerRematchPage:"];
}

- (void)addNewRemote {
    NSUInteger limitCount = [self.acpartner isExtraRemoteId] ? 6 : 7;
    if (self.acpartner.customFunctionList.count >= limitCount) {
        [[MHTipsView shareInstance] showTipsInfo:@"可添加按键已经达到上限" duration:1.5 modal:YES];
        return;
    }
    
    MHACAddRemoteViewController *addRemoteVC = [[MHACAddRemoteViewController alloc] initWithAcpartner:self.acpartner];
    [self.navigationController pushViewController:addRemoteVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"openACPartnerAddNewRemotePage:"];
}
- (void)rebuildRemote:(NSDictionary *)source {
    [self.footerView rebuildView:source];
}

- (void)onSleepMode {
    //    MHACSleepViewController *sleepVC = [[MHACSleepViewController alloc] initWithAcpartner:self.acpartner];
    MHACSleepSettingViewController *sleepVC = [[MHACSleepSettingViewController alloc] initWithAcpartner:self.acpartner];
    [self.navigationController pushViewController:sleepVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"openACPartnerSleepModePage:"];
    
}

- (void)onSpeedCoolMode {
    MHACCoolSpeedViewController *coolVC = [[MHACCoolSpeedViewController alloc] initWithAcpartner:self.acpartner];
    [self.navigationController pushViewController:coolVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"openACPartnerCoolSpeedPage:"];
}

- (void)onDelayOff {
    
    MHACPartnerCountdownViewController *countdownVC = [[MHACPartnerCountdownViewController alloc] init];
    countdownVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.countdown",@"plugin_gateway","倒计时");
    countdownVC.isOn = YES;
    countdownVC.countdownTimer = self.acpartner.countDownTimer;
    countdownVC.hour = self.acpartner.countDownTimer.isEnabled ? self.acpartner.pwHour : 0;
    countdownVC.minute = self.acpartner.countDownTimer.isEnabled ? self.acpartner.pwMinute : 0;
    countdownVC.delegate = self;
    [self.navigationController pushViewController:countdownVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"openACPartnerCountDownPage:"];
    
}

- (void)deleteCustomButton:(NSString *)name {
    [self gw_clickMethodCountWithStatType:@"ACPartnerDeleteCustomButton:"];
    XM_WS(weakself);
    [[MHTipsView shareInstance] showTips:@"" modal:YES];
    [self.acpartner getLearnedRemoteListSuccess:^(id obj) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:weakself.acpartner.customFunctionList];
        NSLog(@"删除之前的临时数组%@, 原数据%@", tempArray, weakself.acpartner.customFunctionList);
        [weakself.acpartner.customFunctionList enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([dic[kACNameKey] isEqualToString:name]) {
                [tempArray removeObject:dic];
                *stop = YES;
            }
        }];
        
        NSLog(@"删除之后的数组%@", tempArray);
        
        [weakself.acpartner editLearnedRemoteList:tempArray success:^(id obj) {
            [[MHTipsView shareInstance] hide];
            [weakself.footerView rebuildView:[weakself buildFooterResource]];
            [weakself foldViewAnimated:NO];
        } failure:^(NSError *v) {
            [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"operation.failed",@"plugin_gateway","操作失败, 请检查网络") duration:1.5f modal:NO];
            //            [[MHTipsView shareInstance] showTipsInfo:@"删除失败请重试" duration:1.5f modal:NO];
        }];
    } failure:^(NSError *v) {
        [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"operation.failed",@"plugin_gateway","操作失败, 请检查网络") duration:1.5f modal:NO];
        
        //        [[MHTipsView shareInstance] showTipsInfo:@"删除失败请重试" duration:1.5f modal:NO];
    }];
}


- (void)onLED {
    if (!self.acpartner.powerState) {
        return ;
    }
    [[MHTipsView shareInstance] showTips:@"" modal:YES];
    XM_WS(weakself);
    if (self.acpartner.ledState) {
        self.acpartner.ledState = 0;
    }
    else {
        self.acpartner.ledState = 1;
    }
    NSString *command = [self.acpartner getACCommand:STAY_INDEX commandIndex:LED_COMMAND isTimer:NO];
    NSLog(@"灯光命令%@", command);
    
    [self.acpartner sendCommand:command success:^(id obj) {
        //                weakself.acpartner.temperature = [weakself.acpartner.kkAcManager getTemperature];
        [weakself updateStatus];
    } failure:^(NSError *v) {
        weakself.acpartner.ledState = !weakself.acpartner.ledState;
        [weakself updateStatus];
    }];
    
}

- (void)onSwing {
    if (!self.acpartner.powerState) {
        return;
    }
    
    [[MHTipsView shareInstance] showTips:@"" modal:YES];
    
    XM_WS(weakself);
    [[MHTipsView shareInstance] showTips:@"" modal:YES];
    
    if (self.acpartner.ACType == 1) {
        [self.acpartner sendCommand:[self.acpartner getACCommand:SWING_INDEX commandIndex:SWING_COMMAND isTimer:NO] success:^(id obj) {
            [[MHTipsView shareInstance] hide];
            
        } failure:^(NSError *v) {
            
        }];
        
    }
    
    if (self.acpartner.ACType == 2  || self.acpartner.ACType == 3) {
        if (self.acpartner.ACType == 3) {
            self.acpartner.windState = !self.acpartner.windState;
            NSString *command = [self.acpartner getACCommand:SWING_INDEX commandIndex:SWING_COMMAND isTimer:NO];
            [self.acpartner sendCommand:command success:^(id obj) {
                [weakself updateStatus];
                [[MHTipsView shareInstance] hide];
                
            } failure:^(NSError *v) {
                weakself.acpartner.windState = !weakself.acpartner.windState;
                [weakself updateStatus];
            }];
        }
        else {
            self.acpartner.windState = !self.acpartner.windState;
            if (![self.acpartner judgeSwipCanControl:PROP_POWER]) {
                self.acpartner.windState = !self.acpartner.windState;
                return;
            }
            
            NSString *command = [self.acpartner getACCommand:SWING_INDEX commandIndex:SWING_COMMAND isTimer:NO];
            [self.acpartner sendCommand:command success:^(id obj) {
                //                weakself.acpartner.temperature = [weakself.acpartner.kkAcManager getTemperature];
                [weakself updateStatus];
                [[MHTipsView shareInstance] hide];
                
            } failure:^(NSError *v) {
                weakself.acpartner.windState = !weakself.acpartner.windState;
                [weakself updateStatus];
            }];
            
        }
    }
    [self gw_clickMethodCountWithStatType:@"ACPartnerSwing:"];
    
}

- (void)onLess {
    
    [self gw_clickMethodCountWithStatType:@"ACPartnerLessTemp:"];
    XM_WS(weakself);
    
    if (self.acpartner.ACType == 1) {
        [[MHTipsView shareInstance] showTips:@"" modal:YES];
        [self.acpartner sendCommand:[self.acpartner getACCommand:TEMP_LESS_INDEX commandIndex:TEMP_LESS_COMMAND isTimer:NO] success:^(id obj) {
            [[MHTipsView shareInstance] hide];
            
        } failure:^(NSError *v) {
            [[MHTipsView shareInstance] hide];
        }];
        
    }
    
    if (self.acpartner.ACType == 2  || self.acpartner.ACType == 3) {
        int tempTemp = self.acpartner.temperature;
        
        if (self.acpartner.ACType == 3) {
            if (self.acpartner.temperature - 1 >= TEMPERATUREMIN) {
                self.acpartner.temperature -= 1;
                [[MHTipsView shareInstance] showTips:@"" modal:YES];
                NSString *command = [self.acpartner getACCommand:TEMP_LESS_INDEX commandIndex:TEMP_LESS_COMMAND isTimer:NO];
                [self.acpartner sendCommand:command success:^(id obj) {
                    //                weakself.acpartner.temperature = [weakself.acpartner.kkAcManager getTemperature];
                    [weakself updateStatus];
                    [[MHTipsView shareInstance] hide];
                    
                } failure:^(NSError *v) {
                    weakself.acpartner.temperature = tempTemp;
                    [weakself updateStatus];
                    [[MHTipsView shareInstance] hide];
                }];
            }else{
                [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.temperature.decrease.outBoundary", @"plugin_gateway", @"亲，最低不能小于17度哦~") duration:1.5 modal:YES];
            }
        }
        else {
            if (([self.acpartner.kkAcManager canControlTemp] == YES && self.acpartner.temperature > TEMPERATUREMIN )&&[[self.acpartner.kkAcManager getLackOfTemperatureArray] containsObject:[NSString stringWithFormat:@"%d",self.acpartner.temperature - 1]] == NO) {
                self.acpartner.temperature -= 1;
                [self.acpartner.kkAcManager changeTemperatureWithTemperature:self.acpartner.temperature];
                [self.acpartner.kkAcManager getTemperature];
                
            }
            
            NSString *command = [self.acpartner getACCommand:TEMP_LESS_INDEX commandIndex:TEMP_LESS_COMMAND isTimer:NO];
            [[MHTipsView shareInstance] showTips:@"" modal:YES];
            [self.acpartner sendCommand:command success:^(id obj) {
                //                weakself.acpartner.temperature = [weakself.acpartner.kkAcManager getTemperature];
                [weakself updateStatus];
                [[MHTipsView shareInstance] hide];
                
            } failure:^(NSError *v) {
                weakself.acpartner.temperature = tempTemp;
                [weakself updateStatus];
                [[MHTipsView shareInstance] hide];
            }];
            
        }
    }
    
}


- (void)onPlus {
    
    XM_WS(weakself);
    [self gw_clickMethodCountWithStatType:@"ACPartnerPlusTemp:"];
    
    if (self.acpartner.ACType == 1) {
        [[MHTipsView shareInstance] showTips:@"" modal:YES];
        [self.acpartner sendCommand:[self.acpartner getACCommand:TEMP_PLUS_INDEX commandIndex:TEMP_PLUS_COMMAND isTimer:NO] success:^(id obj) {
            [[MHTipsView shareInstance] hide];
            
        } failure:^(NSError *v) {
            [[MHTipsView shareInstance] hide];
            
        }];
    }
    
    
    if (self.acpartner.ACType == 2  || self.acpartner.ACType == 3) {
        int tempTemp = self.acpartner.temperature;
        
        if (self.acpartner.ACType == 3) {
            if (self.acpartner.temperature + 1 <= TEMPERATUREMAX) {
                self.acpartner.temperature += 1;
                NSString *command = [self.acpartner getACCommand:TEMP_PLUS_INDEX commandIndex:TEMP_PLUS_COMMAND isTimer:NO];
                [[MHTipsView shareInstance] showTips:@"" modal:YES];
                [self.acpartner sendCommand:command success:^(id obj) {
                    [[MHTipsView shareInstance] hide];
                    
                    [weakself updateStatus];
                } failure:^(NSError *v) {
                    weakself.acpartner.temperature = tempTemp;
                    [weakself updateStatus];
                    [[MHTipsView shareInstance] hide];
                }];
            }else{
                [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.temperature.increase.outBoundary", @"plugin_gateway", @"亲，最高不能超过30度哦~") duration:1.5 modal:YES];
            }
        }
        else {
            if (([self.acpartner.kkAcManager canControlTemp] == YES
                 && self.acpartner.temperature < TEMPERATUREMAX )
                && [[self.acpartner.kkAcManager getLackOfTemperatureArray] containsObject:[NSString stringWithFormat:@"%d",self.acpartner.temperature + 1]] == NO) {
                self.acpartner.temperature += 1;
                [self.acpartner.kkAcManager changeTemperatureWithTemperature:self.acpartner.temperature];
                [self.acpartner.kkAcManager getTemperature];
            }
            [[MHTipsView shareInstance] showTips:@"" modal:YES];
            NSString *command = [self.acpartner getACCommand:TEMP_PLUS_INDEX commandIndex:TEMP_PLUS_COMMAND isTimer:NO];
            [self.acpartner sendCommand:command success:^(id obj) {
                [weakself updateStatus];
                [[MHTipsView shareInstance] hide];
                
            } failure:^(NSError *v) {
                weakself.acpartner.temperature = tempTemp;
                [weakself updateStatus];
                [[MHTipsView shareInstance] hide];
                
            }];
            
        }
    }
    
}

#pragma mark - 波纹动画
- (void)setWaveAnim:(BOOL)anim forBtn:(UIButton*)btn {
    if (self.acpartner.powerState) {
        _waveAnimation.waveColor = [MHColorUtils colorWithRGB:0x888888];
    }
    else {
        _waveAnimation.waveColor = [MHColorUtils colorWithRGB:0x006fc5];
    }
    [_waveAnimation setFrame:[btn frame]];
    if (anim){
        [_waveAnimation startAnimation];
    }
    else{
        [_waveAnimation stopAnimation];
    }
    
    //    [weakself setWaveAnim:NO forBtn:weakself.btnOnOff];
}


- (void)onPlusTemperature:(id)sender {
    [self onPlus];
}

- (void)onLessTemperature:(id)sender {
    [self onLess];
}


- (void)onSwitch {
    [[MHTipsView shareInstance] showTips:@"" modal:YES];
    
    XM_WS(weakself);
    [self gw_clickMethodCountWithStatType:@"ACPartnerPowerOn/Off:"];
    self.acpartner.powerState = !self.acpartner.powerState;
    
    if (self.acpartner.ACType == 1) {
        
        NSString *command = [self.acpartner getACCommand:self.acpartner.powerState == 1 ? POWER_ON_INDEX : POWER_OFF_INDEX commandIndex:POWER_COMMAND isTimer:NO];
        
        [self.acpartner sendCommand:command success:^(id obj) {
            [weakself updateStatus];
            [[MHTipsView shareInstance] hide];
            //            [weakself getNewQuant];
        } failure:^(NSError *v) {
            weakself.acpartner.powerState = !weakself.acpartner.powerState;
            
        }];
    }
    
    if (self.acpartner.ACType == 2 || self.acpartner.ACType == 3) {
        if (self.acpartner.ACType == 3) {
            self.acpartner.windState = 1;
            NSString *command = [self.acpartner getACCommand:STAY_INDEX commandIndex:POWER_COMMAND isTimer:NO];
            [self.acpartner sendCommand:command success:^(id obj) {
                //                [weakself getNewQuant];
                
                [[MHTipsView shareInstance] hide];
                
                //                [weakself.footerView updateLayout:weakself.acpartner.powerState];
                [weakself updateStatus];
            } failure:^(NSError *v) {
                weakself.acpartner.powerState = !weakself.acpartner.powerState;
                [weakself updateStatus];
                
            }];
        }
        else {
            [self.acpartner.kkAcManager changePowerStateWithPowerstate:self.acpartner.powerState == 0 ? AC_POWER_OFF : AC_POWER_ON];
            [self.acpartner.kkAcManager getPowerState];
            [self.acpartner.kkAcManager getAirConditionInfrared];
            //            NSLog(@"改变状态后获取SDK开关的值%d", [self.acpartner.kkAcManager getPowerState]);
            
            NSString *command = [self.acpartner getACCommand:STAY_INDEX commandIndex:POWER_COMMAND isTimer:NO];
            [self.acpartner sendCommand:command success:^(id obj) {
                //                [weakself getNewQuant];
                [[MHTipsView shareInstance] hide];
                
                
                //                [weakself.footerView updateLayout:weakself.acpartner.powerState];
                [weakself updateStatus];
            } failure:^(NSError *v) {
                weakself.acpartner.powerState = !weakself.acpartner.powerState;
                [weakself updateStatus];
            }];
        }
        
    }
    
}


- (void)onMode {
    XM_WS(weakself);
    if (!self.acpartner.powerState) {
        return;
    }
    
    [self gw_clickMethodCountWithStatType:@"openACPartnerModePage:"];
    
    if (self.acpartner.ACType == 1) {
        [[MHTipsView shareInstance] showTips:@"" modal:YES];
        [self.acpartner sendCommand:[self.acpartner getACCommand:MODE_INDEX commandIndex:MODE_COMMAND isTimer:NO] success:^(id obj) {
            [[MHTipsView shareInstance] hide];
        } failure:^(NSError *v) {
            [[MHTipsView shareInstance] hide];
        }];
    }
    else {
        MHACPartnerModeSettingViewController *modeVC = [[MHACPartnerModeSettingViewController alloc] initWithAcpartner:self.acpartner currentMode:self.acpartner.modeState];
        modeVC.chooseMode = ^(int mode){
            int tempMode = weakself.acpartner.modeState;
            weakself.acpartner.modeState = mode;
            if (self.acpartner.ACType == 3) {
                NSString *command = [weakself.acpartner getACCommand:MODE_INDEX commandIndex:POWER_COMMAND isTimer:NO];
                [weakself.acpartner sendCommand:command success:^(id obj) {
                    
                    [weakself updateStatus];
                } failure:^(NSError *v) {
                    [weakself updateStatus];
                    weakself.acpartner.modeState = tempMode;
                }];
            }
            else {
                if (![self.acpartner judgeModeCanControl:PROP_POWER]) {
                    weakself.acpartner.modeState = tempMode;
                    [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.control.mode",@"plugin_gateway","该模式不可控") duration:1.5f modal:YES];
                    return;
                }
                NSString *command = [weakself.acpartner getACCommand:MODE_INDEX commandIndex:POWER_COMMAND isTimer:NO];
                [weakself.acpartner sendCommand:command success:^(id obj) {
                    [weakself.acpartner updateCurrentModeStatus];
                    [weakself updateStatus];
                } failure:^(NSError *v) {
                    weakself.acpartner.modeState = tempMode;
                }];
            }
            
        };
        [self.navigationController pushViewController:modeVC animated:YES];
        
        
    }
    
}

- (void)onWinds {
    XM_WS(weakself);
    if (!self.acpartner.powerState) {
        return;
    }
    
    [self gw_clickMethodCountWithStatType:@"openACPartnerWindPowerPage:"];
    
    if (self.acpartner.ACType == 1) {
        [[MHTipsView shareInstance] showTips:@"" modal:YES];
        [self.acpartner sendCommand:[self.acpartner getACCommand:FAN_SPEED_INDEX commandIndex:FAN_SPEED_COMMAND isTimer:NO] success:^(id obj) {
            [[MHTipsView shareInstance] hide];
        } failure:^(NSError *v) {
            [[MHTipsView shareInstance] hide];
        }];
    }
    else {
        
        MHACPartnerWindsSettingViewController *modeVC = [[MHACPartnerWindsSettingViewController alloc] initWithAcpartner:self.acpartner currentWinds:self.acpartner.windPower];
        modeVC.chooseWinds = ^(int winds){
            int tempWinds = weakself.acpartner.windPower;
            weakself.acpartner.windPower = winds;
            if (weakself.acpartner.ACType == 3) {
                NSString *command = [weakself.acpartner getACCommand:FAN_SPEED_INDEX commandIndex:POWER_COMMAND isTimer:NO];
                [weakself.acpartner sendCommand:command success:^(id obj) {
                    [weakself updateStatus];
                } failure:^(NSError *v) {
                    weakself.acpartner.windPower = tempWinds;
                }];
            }
            else {
                if (![self.acpartner judgeWindsCanControl:PROP_POWER]) {
                    weakself.acpartner.windPower = tempWinds;
                    [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.control.windpower",@"plugin_gateway","当前模式下,风速不可控") duration:1.5f modal:NO];
                }
                
                NSString *command = [weakself.acpartner getACCommand:FAN_SPEED_INDEX commandIndex:POWER_COMMAND isTimer:NO];
                [weakself.acpartner sendCommand:command success:^(id obj) {
                    [weakself updateStatus];
                } failure:^(NSError *v) {
                    weakself.acpartner.windPower = tempWinds;
                }];
            }
            
            
        };
        [self.navigationController pushViewController:modeVC animated:YES];
        
    }
}




#pragma mark - 电量统计
- (void)quantClicked:(NSInteger)tag {
    MHACPartnerQuantViewController *quantVC = [[MHACPartnerQuantViewController alloc] initWithSensor:self.acpartner];
    quantVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.quant",@"plugin_gateway","电量统计");
    quantVC.selectedType = tag;
    [self.navigationController pushViewController:quantVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"openACPartnerQuantPage:"];
}

- (void)onQuantTrend {
    [[MHLumiLogGraphManager sharedInstance] getLogListGraphWithDeviceDid:self.acpartner.did andDeviceType:MHGATEWAYGRAPH_ACPARTNER andURL:nil andTitle:self.acpartner.name andSegeViewController:self];
    [self gw_clickMethodCountWithStatType:@"openACPartnerQuantTrendPage:"];
}

#pragma mark - 更多功能
- (void)onMore:(id)sender {
    //    MHACPartnerMoreFunctionSettingViewController *moreVC = [[MHACPartnerMoreFunctionSettingViewController alloc] initWithAcpartner:self.acpartner];
    //    [self.navigationController pushViewController:moreVC animated:YES];
    
    NSString* strNew = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.more.newir",@"plugin_gateway","重新匹配空调");
    NSString *strTimer = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.timer.title",@"plugin_gateway","空调定时");
    NSString* strLife = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.actionsheet.life",@"plugin_gateway","生活场景");
    
    NSArray *titlesArray = @[ strTimer, strNew, strLife ];
    
    XM_WS(weakself);
    [[MHPromptKit shareInstance] showPromptInView:self.view withHandler:^(NSInteger buttonIndex) {
        switch (buttonIndex) {
            case 0: {
                //取消
                break;
            }
            case 1: {
                [weakself onTimer];
                break;
            }
            case 2: {
                [weakself reMatchAC];
                break;
            }
            case 3: {
                MHGatewayWebViewController *web = [[MHGatewayWebViewController alloc] initWithURL:[NSURL URLWithString:kAC_SCENE_URL]];
                web.title = strLife;
                web.hasShare = NO;
                web.strOriginalURL = kAC_SCENE_URL;
                web.isTabBarHidden = YES;
                web.controllerIdentifier = @"openACPartnerSceneVideo";
                [self.navigationController pushViewController:web animated:YES];
                break;
            }
            default:
                break;
        }
    } withTitle:NSLocalizedStringFromTable(@"mydevice.actionsheet.more",@"plugin_gateway","更多") cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway",@"取消") destructiveButtonTitle:nil otherButtonTitlesArray:titlesArray];
    
}



#pragma mark -
- (void)updateStatus {
    
    
    if (![self.acpartner isACMatched]) {
        self.statusView.hidden = YES;
        self.footerView.hidden = YES;
        self.plusBtn.hidden = YES;
        self.lessBtn.hidden = YES;
        self.temperatureImageView.hidden = YES;
        self.quantView.hidden = YES;
        self.addAcBtn.hidden = NO;
        self.addAcLabel.hidden = NO;
        return;
    }
    else {
        self.addAcBtn.hidden = YES;
        self.addAcLabel.hidden = YES;
        self.statusView.hidden = NO;
        self.footerView.hidden = NO;
        self.plusBtn.hidden = NO;
        self.lessBtn.hidden = NO;
        self.quantView.hidden = NO;
        self.temperatureImageView.hidden = NO;
    }
    
    if (self.acpartner.ACType == 2 || self.acpartner.ACType == 3) {
        [self.statusView updateStatus];
    }
    if (self.acpartner.ACType == 1) {
        self.temperatureImageView.hidden = !self.acpartner.powerState;
        self.plusBtn.hidden = !self.acpartner.powerState;
        self.lessBtn.hidden = !self.acpartner.powerState;
    }
    [self.quantView updateQuant:self.acpartner.pw_day month:self.acpartner.pw_month power:self.acpartner.ac_power];
    
    if (self.acpartner.ACType == 1) {
        self.temperatureImageView.hidden = NO;
        self.plusBtn.hidden = NO;
        self.lessBtn.hidden = NO;
        
        self.plusBtn.enabled = self.acpartner.powerState;
        self.lessBtn.enabled = self.acpartner.powerState;
        
        self.statusView.hidden = YES;
    }
    else {
        self.temperatureImageView.hidden = YES;
        self.plusBtn.hidden = YES;
        self.lessBtn.hidden = YES;
    }
    
}


#pragma mark - 获取功率并刷新
- (void)startWatchingAcpartnerStatus {
    if (self.shouldKeepRunning) {
        return;
    }
    self.shouldKeepRunning = YES;
    
    XM_WS(weakself);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        weakself.powerTimer = [NSTimer timerWithTimeInterval:kACPartner_Status_time
                                                      target:self
                                                    selector:@selector(startGetQuant)
                                                    userInfo:nil
                                                     repeats:YES];
        [weakself.powerTimer fire];
        
        NSRunLoop *currentRL = [NSRunLoop currentRunLoop];
        [currentRL addTimer:weakself.powerTimer forMode:NSDefaultRunLoopMode];
        while (weakself.shouldKeepRunning && [currentRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
    });
}
- (void)stopWatchingAcpartnerStatus {
    NSLog(@" ------ finished ------ ");
    [self.powerTimer invalidate];
    self.powerTimer = nil;
    self.shouldKeepRunning = NO;
}
#pragma mark - 功率
- (void)startGetQuant {
    XM_WS(weakself);
    [self.acpartner getACTypeAndStatusSuccess:^(id obj) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.acpartner handleNewStatus:obj isRepeat:YES];
            [weakself updateStatus];
        });
    } failure:^(NSError *v) {
        
    }];
}

- (void)onAddAc:(id)sender {
    MHACPartnerAddTipsViewController *addVC =  [[MHACPartnerAddTipsViewController alloc] initWithAcpartner:self.acpartner];
    [self.navigationController pushViewController:addVC animated:YES];
    
}


#pragma mark - CountDownDelegate
- (void)countdownDidStart:(MHDataDeviceTimer*)countdownTimer {
    
    [self gw_clickMethodCountWithStatType:@"ACPartnerStartCountDownTimer:"];
    
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"setting",@"plugin_gateway","添加中，请稍候...") modal:YES];
    
    countdownTimer.identify = kACPARTNERCOUNTDOWNTIMERID;
    countdownTimer.onMethod = @"set_ac";
    countdownTimer.onParam = @[ @(285479426) ];
    countdownTimer.offMethod = @"set_off";
    //    NSString *strOffCmd = [self.acpartner getACCommand:SCENE_OFF_INDEX commandIndex:TIMER_COMMAND isTimer:YES];
    //    NSString *strOffHex = [strOffCmd substringWithRange:NSMakeRange(10, 8)];
    //    uint32_t offValue = (uint32_t)strtoul([strOffHex UTF8String], 0, 16);
    countdownTimer.offParam = @[ @(268435202) ];
    countdownTimer.isEnabled = YES;
    
    XM_WS(weakself);
    [self.acpartner editTimer:countdownTimer success:^(id obj) {
        weakself.acpartner.countDownTimer = countdownTimer;
        [weakself.acpartner fetchCountDownTime:^(NSInteger hour, NSInteger minute) {
            weakself.acpartner.pwHour = hour;
            weakself.acpartner.pwMinute = minute;
        }];
        [weakself.acpartner saveTimerList];
        [[MHTipsView shareInstance] showFinishTips:NSLocalizedStringFromTable(@"adding.successed",@"plugin_gateway", "添加成功") duration:1.0 modal:NO];
        
    } failure:^(NSError *v) {
        [[MHTipsView shareInstance]showFailedTips:NSLocalizedStringFromTable(@"adding.failed",@"plugin_gateway", "添加失败") duration:1.0 modal:NO];
    }];
}



- (void)modifyTimer:(MHDataDeviceTimer *)countdownTimer {
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"setting",@"plugin_gateway","设置中，请稍候...") modal:YES];
    
    countdownTimer.identify = kACPARTNERCOUNTDOWNTIMERID;
    countdownTimer.onMethod = @"set_ac";
    countdownTimer.onParam = @[ @(285479426) ];
    countdownTimer.offMethod = @"set_off";
    //    NSString *strOffCmd = [self.acpartner getACCommand:SCENE_OFF_INDEX commandIndex:TIMER_COMMAND isTimer:YES];
    //    NSString *strOffHex = [strOffCmd substringWithRange:NSMakeRange(10, 8)];
    //    uint32_t offValue = (uint32_t)strtoul([strOffHex UTF8String], 0, 16);
    countdownTimer.offParam = @[ @(268435202) ];
    
    XM_WS(weakself);
    [weakself.acpartner editTimer:countdownTimer success:^(id obj) {
        [weakself.acpartner saveTimerList];
        weakself.acpartner.countDownTimer = countdownTimer;
        [weakself.acpartner fetchCountDownTime:^(NSInteger hour, NSInteger minute) {
            weakself.acpartner.pwHour = hour;
            weakself.acpartner.pwMinute = minute;
        }];
        [[MHTipsView shareInstance]showFinishTips:NSLocalizedStringFromTable(@"modify.successed", @"plugin_gateway","修改定时成功") duration:1.5f modal:NO];
        [weakself.acpartner saveACStatus];
    } failure:^(NSError *v) {
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"modify.failed", @"plugin_gateway","修改失败") duration:1.5f modal:NO];
    }];
}

- (void)countdownDidReStart:(MHDataDeviceTimer *)countdownTimer {
    [self modifyTimer:countdownTimer];
}

- (void)countdownDidStop:(MHDataDeviceTimer *)countdownTimer {
    [self modifyTimer:countdownTimer];
}

- (void)countdownDidDelete:(MHDataDeviceTimer *)countdownTimer {
    [self gw_clickMethodCountWithStatType:@"ACPartnerDeleteCountDownTimer:"];
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"setting",@"plugin_gateway","删除定时中，请稍候...") modal:YES];
    
    XM_WS(weakself);
    [self.acpartner deleteTimerId:countdownTimer.timerId success:^(id obj) {
        [[MHTipsView shareInstance] showFinishTips:NSLocalizedStringFromTable(@"delete.succeed", @"plugin_gateway","修改定时成功") duration:1.5f modal:NO];
        weakself.acpartner.countDownTimer = nil;
        weakself.acpartner.pwHour = 0;
        weakself.acpartner.pwMinute = 0;
        [weakself.acpartner saveTimerList];
        [weakself.acpartner saveACStatus];
        
    } failure:^(NSError *v) {
        [[MHTipsView shareInstance]showFailedTips:NSLocalizedStringFromTable(@"delete.failed",@"plugin_gateway", "修改定时失败") duration:1.5f modal:NO];
    }];
}

#pragma mark - 引导按钮
-(void)showGuide {
    XM_WS(weakself);
    MHLMGuidePage *guidePage = [[MHLMGuidePage alloc] initWithFrame:self.view.bounds];
    guidePage.isExitOnClickBg = NO;
    guidePage.okBlock = ^(){
        [weakself openWebVC:kAC_SCENE_URL identifier:@"mydevice.gateway.sensor.acpartner.actionsheet.life" share:NO];    };
    guidePage.closeBlock = ^(){
        
    };
    
    //    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //    [appDelegate.window addSubview:guidePage];
    [[UIApplication sharedApplication].keyWindow addSubview:guidePage];
}

-(BOOL)isGuidePagesShown {
    NSString* key = [NSString stringWithFormat:@"%@_%@",
                     kACGuidePagesKey,
                     [MHPassportManager sharedSingleton].currentAccount.userId];
    NSNumber* flag = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if(flag){
        return [flag boolValue];
    }
    return NO;
}

- (void)setIsShowGuidePages:(BOOL)isShowGuidePages {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* key = [NSString stringWithFormat:@"%@_%@",
                     kACGuidePagesKey,
                     [MHPassportManager sharedSingleton].currentAccount.userId];
    NSNumber* flag = [NSNumber numberWithBool:isShowGuidePages];
    [defaults setObject:flag forKey:key];
    [defaults synchronize];
}

- (void)openWebVC:(NSString *)strURL identifier:(NSString *)identifier share:(BOOL)share{
    MHGatewayWebViewController *web = [MHGatewayWebViewController openWebVC:strURL identifier:identifier share:share];
    [self.navigationController pushViewController:web animated:YES];
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
