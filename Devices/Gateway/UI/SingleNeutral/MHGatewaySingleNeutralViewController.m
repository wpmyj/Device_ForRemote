//
//  MHGatewaySingleNeutralViewController.m
//  MiHome
//
//  Created by guhao on 15/12/28.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//

#import "MHGatewaySingleNeutralViewController.h"
#import "MHDeviceGatewaySensorSingleNeutral.h"
#import "MHGatewayTimerSettingNewViewController.h"
#import "MHGatewaySensorViewController.h"
#import "MHDeviceGatewaySensorLoopData.h"
#import "MHWaveAnimation.h"
#import "MHGatewayWebViewController.h"
#import "MHLumiChooseLogoListManager.h"
#import "MHLumiChangeIconManager.h"

#define BtnTag_OnOff 1000
#define BtnTag_Timer 1001
#define ASTag_More   1003
#define OpenBtn  @"lumi_neutral_on"
#define CloseBtn @"lumi_neutral_off"

#define OpenLight  @"lumi_neutral_light_title_on"
#define CloseLight @"lumi_neutral_light_title_off"

@interface MHGatewaySingleNeutralViewController ()

@property (nonatomic, strong) MHDeviceGatewaySensorSingleNeutral *deviceSingleNetural;
@property (nonatomic, strong) MHGatewayTimerSettingNewViewController *timerVC;
@property (nonatomic, assign) BOOL isOpen;

@property (nonatomic, strong) UIButton *btnOnOff;
@property (nonatomic, strong) UILabel *btnLabel;
@property (nonatomic, strong) UILabel *logoName;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *lightImageView;
@property (nonatomic, strong) UIImageView *haloImageView;

@property (nonatomic, strong) MHDeviceGatewaySensorLoopData *loopData;
@end

@implementation MHGatewaySingleNeutralViewController {
    UIActionSheet *_actionSheet;
    MHWaveAnimation *_waveAnimation;
}

- (instancetype)initWithDevice:(MHDevice *)device
{
    self = [super initWithDevice:device];
    if (self) {
        self.deviceSingleNetural = (MHDeviceGatewaySensorSingleNeutral *)device;
        self.isHasShare = NO;
        [self.deviceSingleNetural buildServices];
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self updateStatus];
    self.isNavBarTranslucent = YES;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = self.deviceSingleNetural.name;
    //获取单火定时数据
    [self.deviceSingleNetural getTimerListWithID:LumiNeutral1TimerIdentify Success:nil andFailure:nil];

    [self loadStatus];
    XM_WS(weakself);
    _loopData = [[MHDeviceGatewaySensorLoopData alloc] init];
    _loopData.device = self.deviceSingleNetural;
    [_loopData startWatchingNewData:@"prop_ctrl_neutral" WithParams:@[ @"neutral_0" ]];
    _loopData.fetchNewDataCallBack = ^(id respObj){
        if([respObj isKindOfClass:[NSArray class]] &&
           [respObj count] > 0 &&
           [respObj[0] isKindOfClass:[NSString class]]
           ){
            weakself.deviceSingleNetural.neutral_0 = respObj[0];
            if ([weakself.deviceSingleNetural.neutral_0 isEqualToString:@"on"]) {
                weakself.isOpen = YES;
                [weakself updateCurrentStatusWithFlag:YES];
            }
            else if ([weakself.deviceSingleNetural.neutral_0 isEqualToString:@"off"]) {
                [weakself updateCurrentStatusWithFlag:NO];
                weakself.isOpen = NO;
            }
            else {
                weakself.btnOnOff.enabled = NO;
            }
        }
    };
    
    [self fetchIcon];
}

- (void)loadStatus {
    XM_WS(weakself);
    //获取单火状态
    [self.deviceSingleNetural getPropertyWithSuccess:^(id obj) {
        if ([weakself.deviceSingleNetural.neutral_0 isEqualToString:@"disable"]) {
            weakself.btnOnOff.enabled = NO;
        }
        else {
            [weakself updateStatus];
        }
    } andFailure:^(NSError *error) {
        weakself.btnOnOff.enabled = NO;
        NSLog(@"%@",error);
    }];
}

- (void)buildSubviews {
    [super buildSubviews];
    
    //背景
    _bgView = [[UIView alloc] init];
    _bgView.backgroundColor = [MHColorUtils colorWithRGB:0x006fc5];
    [self.view addSubview:_bgView];
    
    //开关
    self.btnOnOff = [[UIButton alloc] init];
    self.btnOnOff.tag = BtnTag_OnOff;
    [self.btnOnOff addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnOnOff];
    
    self.btnLabel = [[UILabel alloc] init];
    self.btnLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.switcher",@"plugin_gateway","开关");
    self.btnLabel.font = [UIFont systemFontOfSize:14 * ScaleWidth];
    [self.btnLabel setTextColor:[MHColorUtils colorWithRGB:0x464646]];
    [self.btnLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.btnLabel];
    
    //开启光晕 184 * 298
    self.haloImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lumi_neutral_on_bg"]];
    self.haloImageView.hidden = YES;
    [self.bgView addSubview:_haloImageView];
    
    //灯具图片 56 * 104 1 * 392
    self.lightImageView = [[UIImageView alloc] init];
    [self.bgView addSubview:self.lightImageView];
    
    self.logoName = [[UILabel alloc] init];
    self.logoName.font = [UIFont systemFontOfSize:14 * ScaleWidth];
    [self.logoName setTextColor:[UIColor whiteColor]];
    [self.logoName setTextAlignment:NSTextAlignmentCenter];
    [self.bgView addSubview:self.logoName];
    
    
    _waveAnimation = [[MHWaveAnimation alloc] initWithFrame:CGRectZero];
    _waveAnimation.waveInterval = 0.5f;
    _waveAnimation.singleWaveScale = 1.5f;
    [self.view addSubview:_waveAnimation];
}

- (void)buildConstraints {
    [super buildConstraints];
    CGFloat bgViewHeight = 467 * ScaleHeight;
    
    CGFloat haloWidth = 184 * ScaleWidth;
    CGFloat haloHeight = 298 * ScaleHeight;
    
    CGFloat logoHeight = 104 * ScaleHeight;
    CGFloat logoWidth = 56 * ScaleWidth;
    
    CGFloat btnSize = 57 * ScaleWidth;
    CGFloat bottomSpacing = 70 * ScaleHeight;
    
    CGFloat labTitleSpacing = 15 * ScaleHeight;
    CGFloat logoNameSpacing = 90 * ScaleHeight;
    
    XM_WS(weakself);
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.view);
        make.height.mas_equalTo(bgViewHeight);
        make.width.mas_equalTo(weakself.view.mas_width);
    }];
    
    [self.haloImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakself.bgView);
        make.size.mas_equalTo(CGSizeMake(haloWidth, haloHeight));
    }];
    
    [self.lightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakself.bgView);
        make.size.mas_equalTo(CGSizeMake(logoWidth, logoHeight));
    }];
    
    [self.logoName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakself.bgView.mas_bottom).with.offset(-logoNameSpacing);
        make.centerX.equalTo(weakself.bgView);
    }];
    
    [self.btnOnOff mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakself.view).with.offset(-bottomSpacing);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(btnSize, btnSize));
    }];
    
    [self.btnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.btnOnOff.mas_bottom).with.offset(labTitleSpacing);
        make.centerX.equalTo(weakself.view);
    }];
}

#pragma mark - 波纹动画
- (void)setWaveAnim:(BOOL)anim forBtn:(UIButton*)btn {
    if (self.isOpen) {
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
}

- (void)onButtonClicked:(UIButton *)sender {
    XM_WS(weakself);
    self.isOpen = !self.isOpen;
    self.btnOnOff.enabled = NO;
    [self setWaveAnim:YES forBtn:sender];
    [(MHDeviceGatewayBaseService *)weakself.deviceSingleNetural.services[0] serviceMethod];
    [(MHDeviceGatewayBaseService *)weakself.deviceSingleNetural.services[0] setServiceMethodSuccess:^(id obj) {
        [weakself setWaveAnim:NO forBtn:weakself.btnOnOff];

        if ([weakself.deviceSingleNetural.neutral_0 isEqualToString:@"disable"]) {
            weakself.isOpen = !weakself.isOpen;
        }
        else {
            [weakself updateCurrentStatusWithFlag:[weakself.deviceSingleNetural.neutral_0 isEqualToString:@"on"] ? YES : NO];
        }
        [weakself fetchIcon];
    }];
    [(MHDeviceGatewayBaseService *)weakself.deviceSingleNetural.services[0] setServiceMethodFailure:^(NSError *error) {
        weakself.btnOnOff.enabled = YES;
        weakself.isOpen = !weakself.isOpen;
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"send.failed",@"plugin_gateway", nil) duration:1.5f modal:YES];
        [weakself setWaveAnim:NO forBtn:weakself.btnOnOff];
    }];
    [self gw_clickMethodCountWithStatType:@"onButtonClicked:"];
}

- (void)updateStatus {
    self.isOpen = [self.deviceSingleNetural.neutral_0 isEqualToString:@"on"] ? YES : NO;
    self.haloImageView.hidden = !self.isOpen;
    [self.btnOnOff setBackgroundImage:[UIImage imageNamed:self.isOpen ? OpenBtn : CloseBtn ] forState:UIControlStateNormal];
    self.btnOnOff.enabled = YES;
    //
    self.logoName.text = self.isOpen ? NSLocalizedStringFromTable(@"mydevice.gateway.sensor.singleNeutral.isOn",@"plugin_gateway", "已开启") : NSLocalizedStringFromTable(@"mydevice.gateway.sensor.singleNeutral.isOff",@"plugin_gateway", "已关闭");
}

- (void)updateCurrentStatusWithFlag:(BOOL)isOn {
    self.isOpen = isOn;
    self.haloImageView.hidden = !self.isOpen;
    self .btnOnOff.enabled = YES;
    self.logoName.text = self.isOpen ? NSLocalizedStringFromTable(@"mydevice.gateway.sensor.singleNeutral.isOn",@"plugin_gateway", "已开启") : NSLocalizedStringFromTable(@"mydevice.gateway.sensor.singleNeutral.isOff",@"plugin_gateway", "已关闭");
    [self.btnOnOff setBackgroundImage:[UIImage imageNamed:self.isOpen ? OpenBtn : CloseBtn ] forState:UIControlStateNormal];
}

#pragma mark - 定时
- (void)openTimerView {
    
    XM_WS(weakself);
    self.timerVC = [[MHGatewayTimerSettingNewViewController alloc] initWithDevice:self.deviceSingleNetural andIdentifier:LumiNeutral1TimerIdentify];
    self.timerVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.singleNeutral.timer.title",@"plugin_gateway", @"单火定时");
    self.timerVC.controllerIdentifier = @"singleNetural";
    self.timerVC.onAddNewTimer = ^(MHDataDeviceTimer *newTimer){
        [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.timersetting.adding",@"plugin_gateway","添加定时中，请稍候...") modal:YES];
        
        newTimer.identify = LumiNeutral1TimerIdentify;
        newTimer.onMethod = @"toggle_ctrl_neutral";
        newTimer.onParam = @[ @"neutral_0" , @"on" ];
        newTimer.offMethod = @"toggle_ctrl_neutral";
        newTimer.offParam = @[ @"neutral_0" , @"off" ];
        
        [weakself.timerVC addTimer:newTimer];
    };
    [self.navigationController pushViewController:self.timerVC animated:YES];
}

#pragma mark - 设备控制相关
- (void)onMore:(id)sender {
    NSString *strScene = NSLocalizedStringFromTable(@"profile.entry.triggerAction",@"plugin_gateway","自动化");
    NSString *strTimer = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.timer",@"plugin_gateway","定时");
    NSString* strChangeTitle = NSLocalizedStringFromTable(@"mydevice.actionsheet.changename",@"plugin_gateway","修改设备名称");

    NSString *logoChange = NSLocalizedStringFromTable(@"mydevice.actionsheet.changelogo",@"plugin_gateway","更换图标");
    
    NSString* strShowMode = _deviceSingleNetural.showMode ? NSLocalizedStringFromTable(@"mydevice.gateway.delsub.rmvlist",@"plugin_gateway","撤销显示") : NSLocalizedStringFromTable(@"mydevice.gateway.delsub.addlist",@"plugin_gateway","添加显示");
    NSString *strFAQ = NSLocalizedStringFromTable(@"mydevice.gateway.about.freFAQ",@"plugin_gateway","常见问题");
    NSString* strFeedback = NSLocalizedStringFromTable(@"mydevice.actionsheet.feedback",@"plugin_gateway","反馈");

    NSArray *titlesArray = @[ strScene, logoChange, strTimer, strChangeTitle, strShowMode, strFeedback ];
    
    XM_WS(weakself);
    [[MHPromptKit shareInstance] showPromptInView:self.view withHandler:^(NSInteger buttonIndex) {
        switch (buttonIndex) {
            case 0: {
                //取消
                break;
            }
              
            case 1: {
                //自动化
                [weakself onAddScene];
                [weakself gw_clickMethodCountWithStatType:@"actionSheetAddScene"];
                break;
            }
            case 2: {
                //单火图标
                [weakself htmlLogo];
                [weakself gw_clickMethodCountWithStatType:@"actionSheetChangeLogo"];
                break;
            }
            case 3: {
                //定时
                [weakself openTimerView];
                [weakself gw_clickMethodCountWithStatType:@"actionSheetOpenTimerView"];
                break;
            }
            case 4: {
                //修改设备名称
                [weakself deviceChangeName];
                [weakself gw_clickMethodCountWithStatType:@"actionSheetChangeName"];
                break;
            }
            case 5: {
                // 设置列表显示
                [weakself.deviceSingleNetural setShowMode:(int)!weakself.deviceSingleNetural.showMode success:^(id obj) {
                    
                } failure:^(NSError *v) {
                    [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"setting.failed", @"plugin_gateway","") duration:1.f modal:YES];
                }];
                [weakself gw_clickMethodCountWithStatType:@"actionSheetShowMode"];
                break;
            }
                
            case 6: {
                //反馈
                [weakself onFeedback];
                [weakself gw_clickMethodCountWithStatType:@"actionSheetFeedback"];
                break;
            }
                
            default:
                break;
        }
                //            case 6: {
                //                //常见问题
                //                [weakself openFAQ:[[weakself.deviceHt class] getFAQUrl]];
                //                break;
                //            }

    } withTitle:NSLocalizedStringFromTable(@"mydevice.actionsheet.more",@"plugin_gateway","更多") cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway",@"取消") destructiveButtonTitle:nil otherButtonTitlesArray:titlesArray];
}


- (void)onAddScene {
    MHGatewaySensorViewController *sceneVC = [[MHGatewaySensorViewController alloc] initWithDevice:self.deviceSingleNetural];
    sceneVC.isHasMore = NO;
    sceneVC.isHasShare = NO;
    [self.navigationController pushViewController:sceneVC animated:YES];
}

#pragma mark - fetch图标
- (void)fetchIcon {
    XM_WS(weakself);
    MHDeviceGatewayBaseService *service = _deviceSingleNetural.services[0] ;
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
        NSString *iconUrl = nil;
        MHDeviceGatewayBaseService *service;
        if(_deviceSingleNetural.services.count) {
            service = _deviceSingleNetural.services[0];
            service.serviceIconId = iconId;
            iconUrl = [service fetchIconNameWithHeader:@"lumi"];
        }
        
        if([[NSFileManager defaultManager] fileExistsAtPath:iconUrl]) {
            [self.lightImageView setImage:[UIImage imageWithContentsOfFile:iconUrl]];
        }
        else{
            [self defaultIcon];
            [[MHLumiChangeIconManager sharedInstance] fetchIconUrlsByIconId:iconId
                                                                withService:service
                                                          completionHandler:^(id result,NSError *error){
                                                              if(!error)[weakself fetchIcon];
                                                          }];
        }
    }
}

- (void)defaultIcon {
    if(self.isOpen) [self.lightImageView setImage:[UIImage imageNamed:@"lumi_neutral_light_title_on"]];
    else [self.lightImageView setImage:[UIImage imageNamed:@"lumi_neutral_light_title_off"]];
}

#pragma mark - H5logo
- (void)htmlLogo {
    MHDeviceGatewayBaseService *service = self.deviceSingleNetural.services[0];
    NSString *iconID = [[MHLumiChangeIconManager sharedInstance] restorePdataByService:service
                                                                 withCompletionHandler:^(id result, NSError *error){ }];
    
    [[MHLumiChooseLogoListManager sharedInstance] chooseLogoWithSevice:self.deviceSingleNetural.services[0] iconID:iconID ? iconID : @"" titleIdentifier:@"mydevice.actionsheet.changelogo" segeViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
