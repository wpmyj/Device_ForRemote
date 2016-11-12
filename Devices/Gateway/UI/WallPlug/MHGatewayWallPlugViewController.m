//
//  MHGatewayWallPlugViewController.m
//  MiHome
//
//  Created by ayanami on 9/6/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayWallPlugViewController.h"
#import "MHDeviceGatewaySensorCassette.h"
#import "MHGatewayTimerSettingNewViewController.h"
#import "MHGatewayPlugQuantViewController.h"
#import "MHGatewayPlugCountdownViewController.h"
#import "MHWaveAnimation.h"
#import "MHGatewayPlugQuantViewController.h"
#import "MHLumiPlugDataManager.h"
#import "MHLumiPlugQuantEngine.h"
#import "MHGatewayPlugProtectViewController.h"
#import "MHGatewaySensorViewController.h"
#import "MHDeviceGatewaySensorLoopDataV2.h"
#import "MHGatewayWebViewController.h"
#import "MHGatewayDisclaimerView.h"
#import "MHGatewayPlugDisclaimerViewController.h"
#import "MHLumiChooseLogoListManager.h"
#import "MHLumiChangeIconManager.h"
#import "MHLumiLogGraphManager.h"
#import "MHLumiHtmlHandleTools.h"
#import "MHWeakTimerFactory.h"

#define ASTag_More 1001

#define BtnTag_CountDown 1001
#define BtnTag_Timer 1002
#define BtnTag_Toggle 1003

#define LabelWhiteTextColor [UIColor whiteColor]
#define OpenBgColor [MHColorUtils colorWithRGB:0x00a161]
#define CloseBgColor [MHColorUtils colorWithRGB:0x464646]

#define kHOUR NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.countdown.hour", @"plugin_gateway",@"小时")
#define kMINUTE NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.countdown.minute", @"plugin_gateway",@"分钟")
#define kREAR NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.countdown.rear",@"plugin_gateway", @"后")
#define kON NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.countdown.on",@"plugin_gateway", @"开启")
#define kOFF NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.countdown.off", @"plugin_gateway",@"关闭")

#define kBadgeSide 8.f

@interface MHGatewayWallPlugViewController ()<CountdownDelegate>

@property (nonatomic,strong) MHDeviceGatewaySensorCassette *devicePlug;
@property (nonatomic,strong) MHGatewayTimerSettingNewViewController *tVC;
@property (nonatomic,strong) UILabel *todayCountNum;
@property (nonatomic,strong) UILabel *monthCountNum;
@property (nonatomic,strong) UILabel *currentWatNum;
@property (nonatomic,strong) UILabel *todayCountTail;
@property (nonatomic,strong) UILabel *monthCountTail;
@property (nonatomic,strong) UILabel *currentWatTail;
@property (nonatomic,assign) NSInteger pwHour;
@property (nonatomic,assign) NSInteger pwMinute;
@property (nonatomic,strong) UIButton *imgPlugLogo;
@property (nonatomic, assign) BOOL isShowingDisclaimer;   //是否正在显示“免责声明”的view
@property (nonatomic, retain) MHGatewayDisclaimerView* disclaimerView;
@property (nonatomic, strong) NSTimer *uiRefreshTimer;

@end

@implementation MHGatewayWallPlugViewController
{
    MHWaveAnimation *                   _waveAnimation;
    MHWaveAnimation *                   _smallBtnAnimation;
    UIView *                            _headerView;
    UIImageView *                       _bgPlug;
    UILabel *                           _imgTitle;
    UIActionSheet *                     _actionSheet;
    
    UIButton *                          _btnOnOff;
    UILabel *                           _lblOnOff;
    UIButton *                          _btnTimer;
    UILabel *                           _lblTimer;
    UIButton *                          _btnCntDown;
    UILabel *                           _lblCntDown;
    
    UIView *                            _menuView;
    BOOL                                _isLoading;
    
    UILabel *                           _todayCountTitle;
    UILabel *                           _monthCountTitle;
    UILabel *                          _currentWatTitle;
    
    UIView *                            _badgeView;
    UIView *                            _navigationBadge;
}

- (id)initWithDevice:(MHDevice *)device {
    if (self = [super initWithDevice:device]) {
        self.devicePlug = (MHDeviceGatewaySensorCassette* )device;
        [self.devicePlug buildServices];
        self.uiRefreshTimer = nil;
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isNavBarTranslucent = YES;
    self.view.backgroundColor = [UIColor clearColor];
    
    //PlugDataManager 需要初始化，device，此处开始下载数据
    //[[MHLumiPlugDataManager sharedInstance] setPlug:self.devicePlug];
    [[MHLumiPlugDataManager sharedInstance] setQuantDevice:self.devicePlug];
    [[MHLumiPlugQuantEngine sharedEngine] findStartPoint:@"day"];
    [[MHLumiPlugQuantEngine sharedEngine] findStartPoint:@"month"];
    
    _navigationBadge = [[UIView alloc] initWithFrame:CGRectMake( WIN_WIDTH - kBadgeSide * 2, 20 + kBadgeSide, kBadgeSide, kBadgeSide)];
    _navigationBadge.backgroundColor = [UIColor redColor];
    _navigationBadge.layer.cornerRadius = kBadgeSide / 2.0;
    [self.view addSubview:_navigationBadge];
    //    BOOL flag = [[[NSUserDefaults standardUserDefaults] valueForKey:@"lumi_plug_logochoose_clicked"] boolValue];
    //    if (flag) _navigationBadge.hidden = YES;
    //    else _navigationBadge.hidden = NO;
    _navigationBadge.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = self.devicePlug.name;
    
    [self loadStatus];
    
    //    BOOL flag = [[[NSUserDefaults standardUserDefaults] valueForKey:@"lumi_plug_quant_clicked"] boolValue];
    //    if (flag) _badgeView.hidden = YES;
    //    else _badgeView.hidden = NO;
    //    BOOL flag2 = [[[NSUserDefaults standardUserDefaults] valueForKey:@"lumi_plug_logochoose_clicked"] boolValue];
    //    if (flag2 || self.devicePlug.shareFlag == MHDeviceShared) _navigationBadge.hidden = YES;
    //    else _navigationBadge.hidden = NO;
    //
    XM_WS(weakself);
    if (!self.uiRefreshTimer){
        self.uiRefreshTimer = [MHWeakTimerFactory scheduledTimerWithBlock:kLoopDeviceStatusIntervar callback:^{
            [weakself loadDeviceTimerData];
            [weakself loadDeviceStatus];
        }];
    }
    
    //免责声明
    if (![self isDisclaimerShown]) {
        _isShowingDisclaimer = YES;
        [self showDisclaimer];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_uiRefreshTimer invalidate];
    _uiRefreshTimer = nil;
}

- (void)dealloc{
    [_uiRefreshTimer invalidate];
    _uiRefreshTimer = nil;
}

#pragma mark - 获取所有最新状态信息，并更新UI
- (void)loadStatus {
    XM_WS(weakself);
    
    //获取插座当前（功率和开关状态）数据
    [self loadDeviceStatus];
    
    //电量统计数据
    [self.devicePlug fetchPlugDataWithSuccess:^(id obj){
        [weakself updateUIDataFormRequest];
    } failure:nil];
    
    //插座定时数据
    [self loadDeviceTimerData];
    
    [self fetchPlugIcon];
}

- (void)loadDeviceStatus{
    XM_WS(weakself);
    [self.devicePlug getPropertyWithSuccess:^(id obj){
        [weakself.devicePlug updateServices];
        [weakself updateUIDataFormGateway];
    } andFailure:nil];
}

- (void)loadDeviceTimerData{
    XM_WS(weakself);
    [self.devicePlug getTimerListWithID:WallPlugTimerIdentify Success:nil failure:nil];
    [self.devicePlug getTimerListWithID:WallPlugCountDownIdentify Success:^(id v){
        [weakself.devicePlug fetchCountDownTime:^(NSInteger hour, NSInteger minute) {
            [weakself setCountDownLabelWithPwHour:hour pwMinute:minute];
        }];
    } failure:nil];
}

#pragma mark - 更新UI
- (void)updateUI{
    [self updateUIDataFormGateway];
    [self updateUIDataFormRequest];
    [self updateUIDataFormTimer];
}

//开关状态和当前功率
- (void)updateUIDataFormGateway{
    self.currentWatNum.text = [NSString stringWithFormat:@"%0.1f",self.devicePlug.sload_power];
    if(self.devicePlug.sload_power < 0){
        self.currentWatNum.text = @"0";
    }
    else if(self.devicePlug.sload_power > 2500){
        self.currentWatNum.text = @"2500";
    }
    MHDataDeviceTimer *todoTimer = [self.devicePlug fetchCountDownTimer];
    if (self.devicePlug.isOpen){
        [_imgPlugLogo setImage:[UIImage imageNamed:@"gateway_plug_on"] forState:UIControlStateNormal];
        _bgPlug.image = [UIImage imageNamed:@"gateway_plug_bgon"];
        if(!todoTimer.isEnabled){
            _imgTitle.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.ison", @"plugin_gateway", nil);
        }
    }else{
        [_imgPlugLogo setImage:[UIImage imageNamed:@"gateway_plug_off"] forState:UIControlStateNormal];
        _bgPlug.image = [UIImage imageNamed:@"gateway_plug_bgoff"];
        if(!todoTimer.isEnabled){
            _imgTitle.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.isoff", @"plugin_gateway", nil);
        }
    }
}
//电量信息更新UI
- (void)updateUIDataFormRequest{
    self.todayCountNum.text = [NSString stringWithFormat:@"%0.1f",self.devicePlug.pw_day];
    self.monthCountNum.text = [NSString stringWithFormat:@"%0.1f",self.devicePlug.pw_month];
}

- (void)updateUIDataFormTimer{
    
}

//更新倒计时提示语
- (void)setCountDownLabelWithPwHour:(NSInteger)pwHour pwMinute:(NSInteger)pwMinute {
    self.pwHour = pwHour;
    self.pwMinute = pwMinute;
    MHDataDeviceTimer *todoTimer = [self.devicePlug fetchCountDownTimer];
    if(todoTimer.isEnabled){
        BOOL isOn = YES;
        if(todoTimer.isOnOpen) isOn = NO;
        else if(todoTimer.isOffOpen) isOn = YES;
        
        if (pwHour<1) {
            _imgTitle.text = [NSString stringWithFormat:@"%ld%@%@%@",(long)pwMinute, kMINUTE, kREAR, isOn ? kOFF : kON];
        }
        else {
            if (pwMinute==0) { // 0分钟，只显示小时
                _imgTitle.text = [NSString stringWithFormat:@"%ld%@%@%@",(long)pwHour, kHOUR, kREAR, isOn ? kOFF : kON];
            }
            else {
                _imgTitle.text = [NSString stringWithFormat:@"%ld%@%ld%@%@%@",(long)pwHour, kHOUR, (long)pwMinute, kMINUTE, kREAR, isOn ? kOFF : kON];
            }
        }
    }
}

#pragma mark - 子控件初始化buildSubviews
- (void)buildSubviews {
    [super buildSubviews];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat scaleHeight = [UIScreen mainScreen].bounds.size.height / 667.f;
    CGFloat scaleWidth = [UIScreen mainScreen].bounds.size.width / 375.f;
    CGFloat logoSize = 172 * scaleHeight;
    CGFloat btnSize = 48 * scaleWidth;
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, scaleHeight * 514)];
    _headerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_headerView];
    
    _bgPlug = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gateway_plug_bgoff"]];
    
    _bgPlug.frame = _headerView.frame;
    [_headerView addSubview:_bgPlug];
    
    _imgPlugLogo = [[UIButton alloc] init];
    [_imgPlugLogo setImage:[UIImage imageNamed:@"gateway_plug_off"] forState:UIControlStateNormal];
    _imgPlugLogo.frame = CGRectMake(0, 133 * scaleHeight, logoSize, logoSize);
    _imgPlugLogo.center = CGPointMake(self.view.center.x, 133 * scaleHeight + logoSize/2.f);
    _imgPlugLogo.userInteractionEnabled = YES;
    [_imgPlugLogo addTarget:self action:@selector(logoPlugTap:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:_imgPlugLogo];
    
    _imgTitle = [[UILabel alloc] init];
    _imgTitle.text = NSLocalizedStringFromTable(@"loading" , @"plugin_gateway", nil);
    _imgTitle.textAlignment = NSTextAlignmentCenter;
    [_imgTitle setTextColor:LabelWhiteTextColor];
    _imgTitle.frame = CGRectMake(0, CGRectGetMaxY(_imgPlugLogo.frame) + 24.f * scaleHeight, logoSize, 15.f);
    _imgTitle.center = CGPointMake(_imgPlugLogo.center.x, CGRectGetMinY(_imgTitle.frame) + 6.f);
    _imgTitle.font = [UIFont systemFontOfSize:16.f];
    [_headerView addSubview:_imgTitle];
    
    _waveAnimation = [[MHWaveAnimation alloc] initWithFrame:CGRectZero];
    _waveAnimation.waveInterval = 0.5f;
    _waveAnimation.singleWaveScale = 1.5f;
    [_headerView addSubview:_waveAnimation];
    
    _menuView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_headerView.frame), screenWidth, scaleHeight * 153)];
    [_menuView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_menuView];
    
    _smallBtnAnimation = [[MHWaveAnimation alloc] initWithFrame:CGRectZero];
    _smallBtnAnimation.waveInterval = 0.5f;
    _smallBtnAnimation.singleWaveScale = 1.5f;
    [_menuView addSubview:_smallBtnAnimation];
    
    _btnOnOff = [[UIButton alloc] init];
    _btnOnOff.clipsToBounds = NO;
    _btnOnOff.frame = CGRectMake(0, 38*scaleHeight, btnSize, btnSize);
    _btnOnOff.center = CGPointMake( self.view.center.x * 1.f/2.f - btnSize/3.f, btnSize/2.f + 38.f*scaleHeight);
    _btnOnOff.tag = BtnTag_Toggle;
    [_btnOnOff setBackgroundImage:[UIImage imageNamed:@"gateway_plug_kaion"] forState:UIControlStateNormal];
    [_btnOnOff addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:_btnOnOff];
    
    _lblOnOff = [[UILabel alloc] init];
    _lblOnOff.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.switcher",@"plugin_gateway","开关");
    _lblOnOff.frame = CGRectMake(0, CGRectGetMaxY(_btnOnOff.frame) + 12 *scaleHeight, 60, 16.f);
    _lblOnOff.center = CGPointMake( _btnOnOff.center.x, CGRectGetMaxY(_btnOnOff.frame) + 12 *scaleHeight + 8);
    _lblOnOff.font = [UIFont systemFontOfSize:14];
    [_lblOnOff setTextColor:CloseBgColor];
    [_lblOnOff setTextAlignment:NSTextAlignmentCenter];
    [_menuView addSubview:_lblOnOff];
    
    _btnTimer = [[UIButton alloc] init];
    _btnTimer.clipsToBounds = NO;
    _btnTimer.frame = CGRectMake(0, 38*scaleHeight, btnSize, btnSize);
    _btnTimer.center = CGPointMake( self.view.center.x , _btnOnOff.center.y);
    _btnTimer.tag = BtnTag_Timer;
    [_btnTimer setBackgroundImage:[UIImage imageNamed:@"gateway_plug_dingon"] forState:UIControlStateNormal];
    [_btnTimer addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:_btnTimer];
    
    _lblTimer = [[UILabel alloc] init];
    _lblTimer.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.timer",@"plugin_gateway","定时");
    _lblTimer.frame = CGRectMake(0, 0, 60, 16.f);
    _lblTimer.center = CGPointMake( _btnTimer.center.x, _lblOnOff.center.y);
    _lblTimer.font = [UIFont systemFontOfSize:14];
    [_lblTimer setTextAlignment:NSTextAlignmentCenter];
    [_lblTimer setTextColor:CloseBgColor];
    [_menuView addSubview:_lblTimer];
    
    _btnCntDown = [[UIButton alloc] init];
    [_btnCntDown setBackgroundImage:[UIImage imageNamed:@"gateway_plug_daoon"] forState:UIControlStateNormal];
    [_btnCntDown addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _btnCntDown.tag = BtnTag_CountDown;
    _btnCntDown.frame = CGRectMake(0, 38*scaleHeight, btnSize, btnSize);
    _btnCntDown.center = CGPointMake( self.view.center.x * 3.f/2.f + btnSize/3.f, _btnOnOff.center.y);
    [_menuView addSubview:_btnCntDown];
    
    _lblCntDown = [[UILabel alloc] init];
    _lblCntDown.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.countdown",@"plugin_gateway","倒计时");
    _lblCntDown.frame = CGRectMake(0, 0, 80, 16.f);
    _lblCntDown.center = CGPointMake( _btnCntDown.center.x, _lblOnOff.center.y);
    _lblCntDown.font = [UIFont systemFontOfSize:14];
    [_lblCntDown setTextColor:CloseBgColor];
    [_lblCntDown setTextAlignment:NSTextAlignmentCenter];
    [_menuView addSubview:_lblCntDown];
    
    _todayCountTitle = [[UILabel alloc] init];
    _todayCountTitle.translatesAutoresizingMaskIntoConstraints = NO;
    _todayCountTitle.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.quant.today", @"plugin_gateway", @"今日");
    _todayCountTitle.font = [UIFont systemFontOfSize:14.f];
    [_todayCountTitle setTextColor:LabelWhiteTextColor];
    [_todayCountTitle setTextAlignment:NSTextAlignmentCenter];
    [_headerView addSubview:_todayCountTitle];
    
    _todayCountNum = [[UILabel alloc] init];
    _todayCountNum.translatesAutoresizingMaskIntoConstraints = NO;
    _todayCountNum.font = [UIFont systemFontOfSize:24.f];
    [_todayCountNum setTextColor:LabelWhiteTextColor];
    [_todayCountNum setTextAlignment:NSTextAlignmentLeft];
    [_todayCountNum sizeToFit];
    _todayCountNum.text = [NSString stringWithFormat:@"%0.1f",self.devicePlug.pw_day];
    [_headerView addSubview:_todayCountNum];
    
    _todayCountTail = [[UILabel alloc] init];
    _todayCountTail.translatesAutoresizingMaskIntoConstraints = NO;
    _todayCountTail.text = [NSString stringWithFormat:@"%@ >", NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.quant.degree", @"plugin_gateway", @"度")];
    [_todayCountTail setTextColor:LabelWhiteTextColor];
    [_todayCountTail setTextAlignment:NSTextAlignmentLeft];
    
    NSInteger todayCountTailLargeNumber = _todayCountTail.text.length;
    NSMutableAttributedString *todayCountTailAttribute = [[NSMutableAttributedString alloc] initWithString:_todayCountTail.text];
    [todayCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0xffffff alpha:0.5] range:NSMakeRange(todayCountTailLargeNumber - 1, 1)];
    [todayCountTailAttribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.0f] range:NSMakeRange(0, todayCountTailLargeNumber)];
    self.todayCountTail.attributedText = todayCountTailAttribute;
    
    [_headerView addSubview:_todayCountTail];
    
    _monthCountTitle = [[UILabel alloc] init];
    _monthCountTitle.translatesAutoresizingMaskIntoConstraints = NO;
    _monthCountTitle.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.quant.month", @"plugin_gateway", @"当月");
    _monthCountTitle.font = [UIFont systemFontOfSize:14];
    [_monthCountTitle setTextColor:LabelWhiteTextColor];
    [_monthCountTitle setTextAlignment:NSTextAlignmentCenter];
    [_headerView addSubview:_monthCountTitle];
    
    _monthCountNum = [[UILabel alloc] init];
    _monthCountNum.translatesAutoresizingMaskIntoConstraints = NO;
    [_monthCountNum setTextColor:LabelWhiteTextColor];
    [_monthCountNum setTextAlignment:NSTextAlignmentLeft];
    _monthCountNum.font = [UIFont systemFontOfSize:24.f];
    _monthCountNum.text = [NSString stringWithFormat:@"%0.1f",self.devicePlug.pw_month];
    [_monthCountNum sizeToFit];
    [_headerView addSubview:_monthCountNum];
    
    _monthCountTail = [[UILabel alloc] init];
    _monthCountTail.translatesAutoresizingMaskIntoConstraints = NO;
    _monthCountTail.text = [NSString stringWithFormat:@"%@ >", NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.quant.degree", @"plugin_gateway", @"度")];
    [_monthCountTail setTextColor:LabelWhiteTextColor];
    [_monthCountTail setTextAlignment:NSTextAlignmentLeft];
    
    NSInteger monthCountTailLargeNumber = _monthCountTail.text.length;
    NSMutableAttributedString *monthCountTailAttribute = [[NSMutableAttributedString alloc] initWithString:_monthCountTail.text];
    [monthCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0xffffff alpha:0.5] range:NSMakeRange(monthCountTailLargeNumber - 1, 1)];
    [monthCountTailAttribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.0f] range:NSMakeRange(0, monthCountTailLargeNumber)];
    self.monthCountTail.attributedText = monthCountTailAttribute;
    
    [_headerView addSubview:_monthCountTail];
    
    _currentWatTitle = [[UILabel alloc] init];
    _currentWatTitle.translatesAutoresizingMaskIntoConstraints = NO;
    _currentWatTitle.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.quant.wat", @"plugin_gateway", @"功率");
    _currentWatTitle.font  = [UIFont systemFontOfSize:14];
    _currentWatTitle.textColor = LabelWhiteTextColor;
    [_currentWatTitle setTextAlignment:NSTextAlignmentCenter];
    [_headerView addSubview:_currentWatTitle];
    
    _currentWatNum = [[UILabel alloc] init];
    _currentWatNum.translatesAutoresizingMaskIntoConstraints = NO;
    _currentWatNum.font = [UIFont systemFontOfSize:24.f];
    [_currentWatNum setTextColor:LabelWhiteTextColor];
    [_currentWatNum setTextAlignment:NSTextAlignmentLeft];
    [_currentWatNum sizeToFit];
    _currentWatNum.text = [NSString stringWithFormat:@"%0.1f",self.devicePlug.sload_power];
    [_headerView addSubview:_currentWatNum];
    
    _currentWatTail = [[UILabel alloc] init];
    _currentWatTail.translatesAutoresizingMaskIntoConstraints = NO;
    _currentWatTail.text = [NSString stringWithFormat:@"%@ >", NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.quant.w", @"plugin_gateway", @"w")];
    [_currentWatTail setTextColor:LabelWhiteTextColor];
    [_currentWatTail setTextAlignment:NSTextAlignmentLeft];
    
    NSInteger temperatureLargeNumber = _currentWatTail.text.length;
    NSMutableAttributedString *currentWatTailAttribute = [[NSMutableAttributedString alloc] initWithString:_currentWatTail.text];
    [currentWatTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0xffffff alpha:0.5] range:NSMakeRange(temperatureLargeNumber - 1, 1)];
    [currentWatTailAttribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.0f] range:NSMakeRange(0, temperatureLargeNumber)];
    self.currentWatTail.attributedText = currentWatTailAttribute;
    
    [_headerView addSubview:_currentWatTail];
    
    UIButton *clearBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    clearBtn1.tag = 10000;
    clearBtn1.frame = CGRectMake(0, CGRectGetMaxY(_imgTitle.frame) + 20.f , CGRectGetWidth(_headerView.frame) * 0.35, CGRectGetHeight(_headerView.frame) - CGRectGetMaxY(_imgTitle.frame) - 20.f);
    [clearBtn1 addTarget:self action:@selector(quantClicked:) forControlEvents:UIControlEventTouchUpInside];
    clearBtn1.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:clearBtn1];
    
    UIButton *clearBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    clearBtn2.tag = 10001;
    clearBtn2.frame = CGRectMake(CGRectGetWidth(_headerView.frame) * 0.35, CGRectGetMaxY(_imgTitle.frame) + 20.f , CGRectGetWidth(_headerView.frame) * 0.35, CGRectGetHeight(_headerView.frame) - CGRectGetMaxY(_imgTitle.frame) - 20.f);
    [clearBtn2 addTarget:self action:@selector(quantClicked:) forControlEvents:UIControlEventTouchUpInside];
    clearBtn2.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:clearBtn2];
    
    UIButton *clearBtn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    clearBtn3.tag = 10003;
    clearBtn3.frame = CGRectMake(CGRectGetWidth(_headerView.frame) * 0.7, CGRectGetMaxY(_imgTitle.frame) + 20.f , CGRectGetWidth(_headerView.frame) * 0.35, CGRectGetHeight(_headerView.frame) - CGRectGetMaxY(_imgTitle.frame) - 20.f);
    [clearBtn3 addTarget:self action:@selector(onQuantTrend:) forControlEvents:UIControlEventTouchUpInside];
    clearBtn3.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:clearBtn3];
    
    _badgeView = [[UIView alloc] init];
    _badgeView.translatesAutoresizingMaskIntoConstraints = NO;
    _badgeView.backgroundColor = [UIColor redColor];
    _badgeView.layer.cornerRadius = kBadgeSide / 2.0;
    [_headerView addSubview:_badgeView];
    //    BOOL flag = [[[NSUserDefaults standardUserDefaults] valueForKey:@"lumi_plug_quant_clicked"] boolValue];
    //    if (flag) _badgeView.hidden = YES;
    //    else _badgeView.hidden = NO;
    _badgeView.hidden = YES;
}

#pragma mark - 布局信息buildConstraints
- (void)buildConstraints {
    [super buildConstraints];
    CGFloat scaleHeight = [UIScreen mainScreen].bounds.size.height / 667.f;
    CGFloat scaleWidth = [UIScreen mainScreen].bounds.size.width / 375.f;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_todayCountTitle,_todayCountNum,_todayCountTail,_monthCountTitle,_monthCountNum,_monthCountTail,_currentWatTitle,_currentWatNum,_currentWatTail,_badgeView);
    NSDictionary *metrics = @{ @"vPadding"      :   @(435 * scaleHeight) ,
                               @"vLabelPadding" :   @(1) ,
                               @"vTailPadding"  :   @(3) ,
                               @"hPadding"      :   @(58*scaleWidth),
                               @"sizeBadge"     :   @(kBadgeSide)
                               };
    
    NSLayoutConstraint *monthCount_const = [NSLayoutConstraint constraintWithItem:_monthCountTitle attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    
    NSString *vfl_monthCountNum_v = [NSString stringWithFormat:@"V:|-vPadding-[_monthCountTitle]"];
    NSArray *constraint_monthCountNum_v = [NSLayoutConstraint constraintsWithVisualFormat:vfl_monthCountNum_v options:NSLayoutFormatAlignAllCenterX metrics:metrics views:views];
    
    NSString *vfl_titleviews_h = [NSString stringWithFormat:@"H:[_todayCountTitle]-hPadding-[_monthCountTitle]-hPadding-[_currentWatTitle]"];
    NSArray *constraint_titleview_h = [NSLayoutConstraint constraintsWithVisualFormat:vfl_titleviews_h options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views];
    NSLayoutConstraint *constraint_monthCountTail_v = [NSLayoutConstraint constraintWithItem:_monthCountTail attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_monthCountTitle attribute:NSLayoutAttributeTop multiplier:1.0 constant:-3.f];
    
    NSLayoutConstraint *monthNumConstraint = [NSLayoutConstraint constraintWithItem:_monthCountNum attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_monthCountTitle attribute:NSLayoutAttributeTop multiplier:1.0 constant:-1.f];
    
    NSLayoutConstraint *todayNumConstraint = [NSLayoutConstraint constraintWithItem:_todayCountNum attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_monthCountNum attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    NSLayoutConstraint *currentNumConstraint = [NSLayoutConstraint constraintWithItem:_currentWatNum attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_monthCountNum attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    
    NSLayoutConstraint *constraint_todayView_h = [NSLayoutConstraint constraintWithItem:_todayCountNum attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_todayCountTitle attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    NSLayoutConstraint *constraint_monthtView_h = [NSLayoutConstraint constraintWithItem:_monthCountNum attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_monthCountTitle attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    NSLayoutConstraint *constraint_currentView_h = [NSLayoutConstraint constraintWithItem:_currentWatNum attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_currentWatTitle attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    
    NSLayoutConstraint *constraint_todaytailView_h = [NSLayoutConstraint constraintWithItem:_todayCountTail attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_monthCountTail attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    NSLayoutConstraint *constraint_currenttailView_h = [NSLayoutConstraint constraintWithItem:_currentWatTail attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_monthCountTail attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    
    NSLayoutConstraint *constraint_todaytailView_v = [NSLayoutConstraint constraintWithItem:_todayCountTail attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_todayCountNum attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *constraint_currenttailView_v = [NSLayoutConstraint constraintWithItem:_currentWatTail attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_currentWatNum attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *constraint_monthtailView_h = [NSLayoutConstraint constraintWithItem:_monthCountTail attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_monthCountNum attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    
    [self.view addConstraint:monthCount_const];
    [self.view addConstraints:constraint_titleview_h];
    [self.view addConstraint:constraint_monthCountTail_v];
    [self.view addConstraints:constraint_monthCountNum_v];
    [self.view addConstraint:monthNumConstraint];
    [self.view addConstraint:todayNumConstraint];
    [self.view addConstraint:currentNumConstraint];
    [self.view addConstraint:constraint_todayView_h];
    [self.view addConstraint:constraint_monthtView_h];
    [self.view addConstraint:constraint_currentView_h];
    
    [self.view addConstraint:constraint_todaytailView_h];
    [self.view addConstraint:constraint_currenttailView_h];
    [self.view addConstraint:constraint_todaytailView_v];
    [self.view addConstraint:constraint_currenttailView_v];
    [self.view addConstraint:constraint_monthtailView_h];
    
    NSArray *constraint_badgeViewV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_badgeView(sizeBadge)]" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:views];
    NSArray *constraint_badgeViewH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_badgeView(sizeBadge)]" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views];
    NSLayoutConstraint *badgeViewYConstraint = [NSLayoutConstraint constraintWithItem:_badgeView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_todayCountTail attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *badgeViewXConstraint = [NSLayoutConstraint constraintWithItem:_badgeView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_todayCountTail attribute:NSLayoutAttributeRight multiplier:1.0 constant:5];
    [self.view addConstraints:constraint_badgeViewH];
    [self.view addConstraints:constraint_badgeViewV];
    [self.view addConstraint:badgeViewYConstraint];
    [self.view addConstraint:badgeViewXConstraint];
}

#pragma mark -
- (void)applicationDidBecomeActive {
    [super applicationDidBecomeActive];
    [self loadStatus];
}

#pragma mark - buttonClicked:
- (void)buttonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case BtnTag_Toggle:
            [self plugToggle];
            [self gw_clickMethodCountWithStatType:@"plugToggleButton"];
            break;
        case BtnTag_Timer:
            [self openTimerView];
            break;
        case BtnTag_CountDown:
            [self openCountDown];
            break;
        default:
            break;
    }
}

#pragma mark - 获取图标
- (void)fetchPlugIcon {
    XM_WS(weakself);
    MHDeviceGatewayBaseService *service = self.devicePlug.services[0] ;
    NSString *iconID = [[MHLumiChangeIconManager sharedInstance] restorePdataByService:service
                                                                 withCompletionHandler:^(id result, NSError *error) {
                                                                     if(result)[weakself fetchIconWithId:result];
                                                                 }];
    
    [self fetchIconWithId:iconID];
}

- (void)fetchIconWithId:(NSString *)iconId{
    XM_WS(weakself);
    if(!iconId) {
        [self defaultIcon];
    }
    else {
        MHDeviceGatewayBaseService *service = nil;
        NSString *iconUrl = nil;
        if(self.devicePlug.services.count) {
            service = self.devicePlug.services[0];
            service.serviceIconId = iconId;
            iconUrl = [service fetchIconNameWithHeader:@"lumi"];
        }
        
        if([[NSFileManager defaultManager] fileExistsAtPath:iconUrl]) {
            [self.imgPlugLogo setImage:[UIImage imageWithContentsOfFile:iconUrl] forState:UIControlStateNormal];
        }
        else{
            [self defaultIcon];
            [[MHLumiChangeIconManager sharedInstance] fetchIconUrlsByIconId:iconId
                                                                withService:service
                                                          completionHandler:^(id result,NSError *error){
                                                              if(!error)[weakself fetchPlugIcon];
                                                          }];
        }
    }
}

- (void)defaultIcon {
    if(self.devicePlug.isOpen) [self.imgPlugLogo setImage:[UIImage imageNamed:@"gateway_plug_on"] forState:UIControlStateNormal];
    else [self.imgPlugLogo setImage:[UIImage imageNamed:@"gateway_plug_off"] forState:UIControlStateNormal];
}

#pragma mark - 电量统计
- (void)quantClicked:(UIButton *)sender {
    MHGatewayPlugQuantViewController *quantVC = [[MHGatewayPlugQuantViewController alloc] initWithDevice:_devicePlug];
    quantVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.quant",@"plugin_gateway","电量统计");
    quantVC.selectedType = sender.tag;
    [self.navigationController pushViewController:quantVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"openPlugQuant:"];
}

#pragma mark - 倒计时
- (void)openCountDown {
    MHGatewayPlugCountdownViewController* countdownVC = [[MHGatewayPlugCountdownViewController alloc] init];
    countdownVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.countdown.title",@"plugin_gateway","插座电源");
    countdownVC.isOn = self.devicePlug.isOpen;
    MHDataDeviceTimer *todoTimer = [self.devicePlug fetchCountDownTimer];
    countdownVC.countdownTimer = todoTimer;
    countdownVC.hour = todoTimer.isEnabled ? self.pwHour : 0;
    countdownVC.minute = todoTimer.isEnabled ? self.pwMinute : 0;
    countdownVC.delegate = self;
    [self.navigationController pushViewController:countdownVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"openCountDown:"];
}

#pragma mark - CountdownDelegate
- (void)countdownDidStart:(MHDataDeviceTimer*)countdownTimer {
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"setting",@"plugin_gateway","添加中，请稍候...") modal:YES];
    
    countdownTimer.identify = WallPlugCountDownIdentify;
    countdownTimer.onMethod = @"toggle_plug";
    countdownTimer.onParam = @[ @"channel_0" , @"on" ];
    countdownTimer.offMethod = @"toggle_plug";
    countdownTimer.offParam = @[ @"channel_0" , @"off" ];
    
    XM_WS(weakself);
    
    [self.devicePlug editTimer:countdownTimer success:^(id obj) {
        [weakself.devicePlug saveTimerList];
        
        [[MHTipsView shareInstance] showFinishTips:NSLocalizedStringFromTable(@"adding.successed",@"plugin_gateway", "添加成功") duration:1.0 modal:NO];
        
    } failure:^(NSError *v) {
        [[MHTipsView shareInstance]showFailedTips:NSLocalizedStringFromTable(@"adding.failed",@"plugin_gateway", "添加失败") duration:1.0 modal:NO];
    }];
}

- (void)countdownDidReStart:(MHDataDeviceTimer *)countdownTimer {
    [self modifyTimer:countdownTimer];
}

- (void)countdownDidStop:(MHDataDeviceTimer *)countdownTimer {
    [self modifyTimer:countdownTimer];
}

- (void)countdownDidDelete:(MHDataDeviceTimer *)countdownTimer {
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"setting",@"plugin_gateway","删除定时中，请稍候...") modal:YES];
    
    XM_WS(weakself);
    [self.devicePlug deleteTimerId:countdownTimer.timerId success:^(id obj) {
        [[MHTipsView shareInstance] showFinishTips:NSLocalizedStringFromTable(@"delete.succeed", @"plugin_gateway","修改定时成功") duration:1.0 modal:NO];
        [weakself.devicePlug saveTimerList];
        
    } failure:^(NSError *v) {
        [[MHTipsView shareInstance]showFailedTips:NSLocalizedStringFromTable(@"delete.failed",@"plugin_gateway", "修改定时失败") duration:1.0 modal:NO];
    }];
}


#pragma mark - 插座功率
- (void)onQuantTrend:(id)sender {
    [[MHLumiLogGraphManager sharedInstance] getLogListGraphWithDeviceDid:self.devicePlug.did andDeviceType:MHGATEWAYGRAPH_PLUG andURL:nil andTitle:self.devicePlug.name andSegeViewController:self];
    [self gw_clickMethodCountWithStatType:@"openPlugQuantWebPage"];
}

- (void)modifyTimer:(MHDataDeviceTimer *)countdownTimer {
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"setting",@"plugin_gateway","设置中，请稍候...") modal:YES];
    
    countdownTimer.onMethod = @"toggle_plug";
    countdownTimer.onParam = @[ @"neutral_0" , @"on" ];
    countdownTimer.offMethod = @"toggle_plug";
    countdownTimer.offParam = @[ @"neutral_0" , @"off" ];
    
    XM_WS(weakself);
    [weakself.devicePlug editTimer:countdownTimer success:^(id obj) {
        [weakself.devicePlug saveTimerList];
        [[MHTipsView shareInstance]showFinishTips:NSLocalizedStringFromTable(@"modify.successed", @"plugin_gateway","修改定时成功") duration:1.0 modal:NO];
        
    } failure:^(NSError *v) {
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"modify.failed", @"plugin_gateway","修改失败") duration:1.0 modal:NO];
    }];
}




#pragma mark - 开关
- (void)logoPlugTap:(id)sender {
    [self plugToggle];
    [self gw_clickMethodCountWithStatType:@"logoPlugTap:"];
}

- (void)plugToggle {
    XM_WS(weakself);
    if (self.devicePlug.isOnline) {
        [self logoAnimation:YES];
        NSString *toggleMethod = @"";
        if (self.devicePlug.isOpen) toggleMethod = @"off";
        else toggleMethod = @"on";
        _btnOnOff.enabled = NO;
        _imgPlugLogo.enabled = NO;
        __weak typeof(_btnOnOff) weakBtnOnOff = _btnOnOff;
        __weak typeof(_imgPlugLogo) weakPlugLogo = _imgPlugLogo;
        [self.devicePlug switchPlugWithToggle:toggleMethod Success:^(id obj){
            [weakself.devicePlug updateServices];
            [weakself logoAnimation:NO];
            weakBtnOnOff.enabled = YES;
            weakPlugLogo.enabled = YES;
            [weakself updateUI];
        } andFailure:^(NSError *error){
            [weakself logoAnimation:NO];
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"send.failed", @"plugin_gateway","失败") duration:1.0 modal:NO];
            weakBtnOnOff.enabled = YES;
            weakPlugLogo.enabled = YES;
        }];
    }
    else {
        [self popOfflineTips];
    }
}

- (void)logoAnimation:(BOOL)anim {
    if (self.devicePlug.isOpen){
        _waveAnimation.waveColor = CloseBgColor;
        _smallBtnAnimation.waveColor = CloseBgColor;
    }
    else {
        _waveAnimation.waveColor = OpenBgColor;
        _smallBtnAnimation.waveColor = OpenBgColor;
    }
    
    [_waveAnimation setFrame:[_imgPlugLogo frame]];
    [_smallBtnAnimation setFrame:_btnOnOff.frame];
    
    if (anim){
        [_smallBtnAnimation startAnimation];
        [_waveAnimation startAnimation];
    }
    else{
        [_smallBtnAnimation stopAnimation];
        [_waveAnimation stopAnimation];
    }
}

- (void)popOfflineTips {
    //设备离线提醒
    [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.offline.tips", @"plugin_gateway","离线") duration:1.5f modal:NO];
}

#pragma mark - 定时
- (void)openTimerView {
    
    XM_WS(weakself);
    self.tVC = [[MHGatewayTimerSettingNewViewController alloc] initWithDevice:self.devicePlug andIdentifier:WallPlugTimerIdentify];
    self.tVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.timer.title",@"plugin_gateway", @"");
    self.tVC.controllerIdentifier = @"plug";
    self.tVC.onAddNewTimer = ^(MHDataDeviceTimer *newTimer){
        [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.timersetting.adding",@"plugin_gateway","添加定时中，请稍候...") modal:YES];
        
        newTimer.identify = WallPlugTimerIdentify;
        newTimer.onMethod = @"toggle_plug";
        newTimer.onParam = @[ @"channel_0" , @"on" ];
        newTimer.offMethod = @"toggle_plug";
        newTimer.offParam = @[ @"channel_0" , @"off" ];
        
        [weakself.tVC addTimer:newTimer];
    };
    [self.navigationController pushViewController:self.tVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"openTimerView"];
}

#pragma mark - 电器保护
- (void)protectVC {
    MHGatewayPlugProtectViewController *protect = [[MHGatewayPlugProtectViewController alloc] init];
    protect.isTabBarHidden = YES;
    protect.devicePlug = _devicePlug;
    [self.navigationController pushViewController:protect animated:YES];
}

#pragma mark - IFTTTVc
- (void)IfTTTVc {
    MHGatewaySensorViewController *ifttt = [[MHGatewaySensorViewController alloc] initWithDevice:self.devicePlug];
    ifttt.isTabBarHidden = YES;
    ifttt.isHasMore = NO;
    [self.navigationController pushViewController:ifttt animated:YES];
}

#pragma mark - OnMore
- (void)onMore:(id)sender {
    XM_WS(weakself);
    NSString* ifttt = NSLocalizedStringFromTable(@"profile.entry.triggerAction",@"plugin_gateway","自动化");
    NSString* deviceProtect = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.deviceprotect",@"plugin_gateway","电器保护");
    NSString* strChangeTitle = NSLocalizedStringFromTable(@"mydevice.actionsheet.changename",@"plugin_gateway","修改设备名称");
    NSString* strShowMode = _devicePlug.showMode ? NSLocalizedStringFromTable(@"mydevice.gateway.delsub.rmvlist",@"plugin_gateway","撤销显示") : NSLocalizedStringFromTable(@"mydevice.gateway.delsub.addlist",@"plugin_gateway","添加显示");
    NSString *strFAQ = NSLocalizedStringFromTable(@"mydevice.gateway.about.freFAQ",@"plugin_gateway","常见问题");
    NSString* strFeedback = NSLocalizedStringFromTable(@"mydevice.actionsheet.feedback",@"plugin_gateway","反馈");
    NSString *title = NSLocalizedStringFromTable(@"mydevice.actionsheet.more",@"plugin_gateway","更多");
    NSMutableArray *objects = [NSMutableArray new];
    //取消
    [objects addObject:[MHPromptKitObject objWithTitle:NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway",@"取消") isCancelBtn:YES isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
    }]];
    
    //自动化
    [objects addObject:[MHPromptKitObject objWithTitle:ifttt isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        [weakself IfTTTVc];
        [weakself gw_clickMethodCountWithStatType:@"actionSheetAddScene"];
    }]];
    
    //电器保护
    [objects addObject:[MHPromptKitObject objWithTitle:deviceProtect isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        [weakself protectVC];
        [weakself gw_clickMethodCountWithStatType:@"actionSheetProtect"];
    }]];
    
    //修改设备名称
    [objects addObject:[MHPromptKitObject objWithTitle:strChangeTitle isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        [weakself deviceChangeName];
        [weakself gw_clickMethodCountWithStatType:@"actionSheetChangeName"];
        
    }]];
    
    // 设置列表显示
    [objects addObject:[MHPromptKitObject objWithTitle:strShowMode isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        
        [weakself.devicePlug setShowMode:(int)!weakself.devicePlug.showMode success:^(id obj) {
            
        } failure:^(NSError *v) {
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"setting.failed", @"plugin_gateway","") duration:1.f modal:YES];
        }];
        [weakself gw_clickMethodCountWithStatType:@"actionSheetShowMode"];
    }]];
    
    //常见问题
    [objects addObject:[MHPromptKitObject objWithTitle:strFAQ isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        
        [weakself openFAQ:[[weakself.devicePlug class] getFAQUrl]];
        [weakself gw_clickMethodCountWithStatType:@"actionSheetFAQ"];
        
    }]];
    
    //反馈
    [objects addObject:[MHPromptKitObject objWithTitle:strFeedback isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        
        [self onFeedback];
        [weakself gw_clickMethodCountWithStatType:@"actionSheetFeedback"];
        
    }]];
    
    [[MHPromptKit shareInstance] showPromptInView:self.view withTitle:title withObjects:objects];
}

#pragma mark - 免责声明
#define keyForDisclaimer @"keyForPlugDisclaimer"
-(BOOL)isDisclaimerShown {
    NSString* key = [NSString stringWithFormat:@"%@_%@",
                     keyForDisclaimer,
                     [MHPassportManager sharedSingleton].currentAccount.userId];
    NSNumber* flag = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if(flag){
        return [flag boolValue];
    }
    return NO;
}

-(void)setDisclaimerShown:(BOOL)shown {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* key = [NSString stringWithFormat:@"%@_%@",
                     keyForDisclaimer,
                     [MHPassportManager sharedSingleton].currentAccount.userId];
    NSNumber* flag = [NSNumber numberWithBool:shown];
    [defaults setObject:flag forKey:key];
    [defaults synchronize];
}

-(void)showDisclaimer {
    XM_WS(weakself);
    _disclaimerView = [[MHGatewayDisclaimerView alloc] initWithFrame:self.view.bounds panelFrame:CGRectMake(0, self.view.bounds.size.height - 200, self.view.bounds.size.width, 200) withCancel:^(id v) {
        [weakself.navigationController popViewControllerAnimated:YES];
    } withOk:^(id v) {
        [weakself.disclaimerView hideWithAnimation:YES];
        [weakself setDisclaimerShown:YES];
        [weakself setIsShowingDisclaimer:NO];
    }];
    _disclaimerView.onOpenDisclaimerPage = ^(void){
        [weakself openDisclaimerPage];
    };
    _disclaimerView.isExitOnClickBg = NO;
    _disclaimerView.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.disclaimer", @"plugin_gateway", nil);
    [[UIApplication sharedApplication].keyWindow addSubview:_disclaimerView];
}

- (void)openDisclaimerPage{
    XM_WS(weakself);
    MHGatewayPlugDisclaimerViewController* disclaimerVC = [[MHGatewayPlugDisclaimerViewController alloc] init];
    disclaimerVC.onBack = ^{
        [weakself.disclaimerView showPanelWithAnimation:NO];
    };
    [self.navigationController pushViewController:disclaimerVC animated:YES];
    [_disclaimerView hideWithAnimation:NO];
}

#pragma mark - 选择电器 , H5 Logo
- (void)htmlLogo {
    MHDeviceGatewayBaseService *service = self.devicePlug.services[0];
    NSString *iconID = [[MHLumiChangeIconManager sharedInstance] restorePdataByService:service
                                                                 withCompletionHandler:^(id result, NSError *error){}];
    
    MHLumiChooseLogoListManager *chooseLogManager = [MHLumiChooseLogoListManager sharedInstance];
    [chooseLogManager chooseLogoWithSevice:self.devicePlug.services[0] iconID:iconID ? iconID : @"" titleIdentifier:@"mydevice.actionsheet.changelogo" segeViewController:self];
}

@end
