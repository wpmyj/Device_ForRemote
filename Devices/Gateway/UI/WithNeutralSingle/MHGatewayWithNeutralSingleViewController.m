//
//  MHGatewayWithNeutralSingleViewController.m
//  MiHome
//
//  Created by ayanami on 9/6/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayWithNeutralSingleViewController.h"
#import "MHDeviceGatewaySensorWithNeutralSingle.h"
#import "MHGatewayTimerSettingNewViewController.h"
#import "MHGatewaySensorViewController.h"
#import "MHDeviceGatewaySensorLoopDataV2.h"
#import "MHWaveAnimation.h"
#import "MHGatewayWebViewController.h"
#import "MHLumiChooseLogoListManager.h"
#import "MHLumiChangeIconManager.h"
#import "MHLumiPlugDataManager.h"
#import "MHLumiPlugQuantEngine.h"
#import "MHACPartnerQuantView.h"
#import "MHGatewayPlugQuantViewController.h"
#import "MHLumiLogGraphManager.h"
#import "MHWeakTimerFactory.h"

#define BtnTag_OnOff 1000
#define BtnTag_Timer 1001
#define ASTag_More   1003
#define OpenBtn  @"lumi_neutral_on"
#define CloseBtn @"lumi_neutral_off"

#define OpenLight  @"lumi_neutral_light_title_on"
#define CloseLight @"lumi_neutral_light_title_off"


@interface MHGatewayWithNeutralSingleViewController ()

@property (nonatomic, strong) MHDeviceGatewaySensorWithNeutralSingle *deviceSingleNetural;
@property (nonatomic, strong) MHGatewayTimerSettingNewViewController *timerVC;
@property (nonatomic, assign) BOOL isOpen;

@property (nonatomic, strong) UIButton *btnOnOff;
@property (nonatomic, strong) UILabel *logoName;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *lightImageView;
@property (nonatomic, strong) UIImageView *haloImageView;
@property (nonatomic, strong) MHACPartnerQuantView *quantView;

@property (nonatomic, strong) NSTimer *uiRefreshTimer;

@end

@implementation MHGatewayWithNeutralSingleViewController {
    UIActionSheet *_actionSheet;
    MHWaveAnimation *_waveAnimation;
}

- (instancetype)initWithDevice:(MHDevice *)device
{
    self = [super initWithDevice:device];
    if (self) {
        self.deviceSingleNetural = (MHDeviceGatewaySensorWithNeutralSingle *)device;
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
    self.isNavBarTranslucent = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.deviceSingleNetural restorePlugData:kQuantDay];
    [self.deviceSingleNetural restorePlugData:kQuantMonth];
    
    
    [[MHLumiPlugDataManager sharedInstance] setQuantDevice:self.deviceSingleNetural];
    [[MHLumiPlugQuantEngine sharedEngine] findStartPoint:kQuantDay];
    [[MHLumiPlugQuantEngine sharedEngine] findStartPoint:kQuantMonth];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = self.deviceSingleNetural.name;
    
    //先更新一次获取设备属性：开关状态，电量统计等
    [self loadStatus];
    
    //启动定时更新数据：只更新开关状态，功率（设备属性）
    XM_WS(weakself);
    if (!self.uiRefreshTimer){
        self.uiRefreshTimer = [MHWeakTimerFactory scheduledTimerWithBlock:kLoopAllDataInterval callback:^{
            [weakself loadStatus];
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.uiRefreshTimer invalidate];
    self.uiRefreshTimer = nil;
}

- (void)dealloc{
    [self.uiRefreshTimer invalidate];
    self.uiRefreshTimer = nil;
}

#pragma mark - 获取设备属性并更新UI
- (void)loadStatus {
    XM_WS(weakself);
    //获取单火状态,当前功率（设备属性信息）
    [self loadDeviceStatus];
    
    //电量统计数据
    [self.deviceSingleNetural fetchPlugDataWithSuccess:^(id obj){
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.quantView updateQuant:weakself.deviceSingleNetural.pw_day month:weakself.deviceSingleNetural.pw_month power:-1];
        });
    } failure:nil];
    
    //插座定时数据
    [self.deviceSingleNetural getTimerListWithID:LumiCtrlLn1TimerIdentify Success:nil andFailure:nil];
    //倒计时显示，该设备不需要
//    [self.deviceSingleNetural getTimerListWithID:WallPlugCountDownIdentify Success:^(id v){
//        [weakself.devicePlug fetchCountDownTime:^(NSInteger hour, NSInteger minute) {
//            weakself.pwHour = hour;
//            weakself.pwMinute = minute;
//        }];
//    } failure:nil];
}

//获取设备状态
- (void)loadDeviceStatus{
    XM_WS(weakself);
    //获取单火状态,当前功率（设备属性信息）
    [self.deviceSingleNetural getPropertyWithSuccess:^(id obj) {
        [weakself.deviceSingleNetural updateServices];
        [weakself updateStatus];
    } andFailure:^(NSError *error) {
        weakself.btnOnOff.enabled = NO;
        [weakself.deviceSingleNetural updateServices];
        [weakself updateStatus];
        NSLog(@"%@",error);
    }];
}

#pragma mark - 更新UI
- (void)updateStatus {
    bool flag = true;
    NSString *channel0 = self.deviceSingleNetural.channel_0;
    if ([channel0 isEqualToString:@"disable"] || [channel0 isEqualToString:@"off"]) {
        flag = false;
    }
    self.isOpen = flag;
    self.haloImageView.hidden = !self.isOpen;
    self.btnOnOff.enabled = YES;
    self.logoName.text = self.isOpen ? NSLocalizedStringFromTable(@"mydevice.gateway.sensor.singleNeutral.isOn",@"plugin_gateway", "已开启") : NSLocalizedStringFromTable(@"mydevice.gateway.sensor.singleNeutral.isOff",@"plugin_gateway", "已关闭");
    [self.btnOnOff setBackgroundImage:[UIImage imageNamed:self.isOpen ? OpenBtn : CloseBtn ] forState:UIControlStateNormal];
    [self.quantView updateQuant:self.deviceSingleNetural.pw_day month:self.deviceSingleNetural.pw_month power:self.deviceSingleNetural.sload_power];
    [self fetchIcon];
}

#pragma mark - 控件初始化
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
    
    //开启光晕 184 * 298
    self.haloImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lumi_neutral_on_bg"]];
    self.haloImageView.hidden = YES;
    [self.bgView addSubview:_haloImageView];
    
    //灯具图片 56 * 104 1 * 392
    self.lightImageView = [[UIImageView alloc] init];
    [self.bgView addSubview:self.lightImageView];
    
    self.logoName = [[UILabel alloc] init];
    self.logoName.font = [UIFont systemFontOfSize:16 * ScaleWidth];
    [self.logoName setTextColor:[UIColor whiteColor]];
    [self.logoName setTextAlignment:NSTextAlignmentCenter];
    self.logoName.text = NSLocalizedStringFromTable(@"loading", @"plugin_gateway", "加载中");
    [self.bgView addSubview:self.logoName];
    
    self.quantView = [[MHACPartnerQuantView alloc] init];
    [self.quantView updateQuant:0 month:0 power:0];
    XM_WS(weakSelf)
    [self.quantView setTodayCallback:^{
        MHGatewayPlugQuantViewController *quantVC = [weakSelf openQuantViewControllerWithDevice:weakSelf.deviceSingleNetural selectedType:kMonthDateType - 1];
        [weakSelf.navigationController pushViewController:quantVC animated:YES];
        [weakSelf gw_clickMethodCountWithStatType:@"openPlugQuant:"];
    }];
    
    [self.quantView setMonthCallback:^{
        MHGatewayPlugQuantViewController *quantVC = [weakSelf openQuantViewControllerWithDevice:weakSelf.deviceSingleNetural selectedType:kMonthDateType];
        [weakSelf.navigationController pushViewController:quantVC animated:YES];
        [weakSelf gw_clickMethodCountWithStatType:@"openPlugQuant:"];
    }];
    
    [self.quantView setQuantCallback:^{
        [[MHLumiLogGraphManager sharedInstance] getLogListGraphWithDeviceDid:weakSelf.deviceSingleNetural.did andDeviceType:MHGATEWAYGRAPH_PLUG andURL:nil andTitle:weakSelf.deviceSingleNetural.name andSegeViewController:weakSelf];
        //@"mydevice.gateway.sensor.plug.quant.wat.history"
        [weakSelf gw_clickMethodCountWithStatType:@"openPlugQuantWebPage"];
        [weakSelf.view addSubview:weakSelf.quantView];
    }];
    [self.bgView addSubview:self.quantView];

    _waveAnimation = [[MHWaveAnimation alloc] initWithFrame:CGRectZero];
    _waveAnimation.waveInterval = 0.5f;
    _waveAnimation.singleWaveScale = 1.5f;
    [self.view addSubview:_waveAnimation];
}

/**
 *   打开电量统计页面
 *  @param selectedType “日”还是“月”统计
 */
- (MHGatewayPlugQuantViewController *)openQuantViewControllerWithDevice:(MHDeviceGatewayBase *)device selectedType:(NSInteger)selectedType{
    MHGatewayPlugQuantViewController *quantVC = [[MHGatewayPlugQuantViewController alloc] initWithDevice:device];
    quantVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.quant",@"plugin_gateway","电量统计");
    quantVC.selectedType = selectedType ;
    return quantVC;
}

#pragma mark - 控件布局信息
- (void)buildConstraints {
    [super buildConstraints];
    CGFloat footHeight = 153 * ScaleHeight;
    CGFloat bgViewHeight = WIN_HEIGHT - footHeight;
    
    CGFloat haloWidth = 184 * ScaleWidth;
    CGFloat haloHeight = 298 * ScaleHeight;
    
    CGFloat logoHeight = 104 * ScaleHeight;
    CGFloat logoWidth = 56 * ScaleWidth;
    
    CGFloat btnSize = 57 * ScaleWidth;
    
    CGFloat logoNameSpacing = 62 * ScaleHeight;
    CGFloat lightImageViewTopPadding = (76+64) * ScaleHeight;
    CGFloat quantViewBottomPadding = 40 * ScaleHeight;
    CGFloat quantViewHeight = 80 * ScaleHeight;

    XM_WS(weakself);
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(weakself.view);
        make.height.mas_equalTo(bgViewHeight);
    }];
    
    [self.haloImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakself.lightImageView);
        make.size.mas_equalTo(CGSizeMake(haloWidth, haloHeight));
    }];
    
    [self.lightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.bgView.mas_centerX);
        make.top.equalTo(weakself.bgView.mas_top).offset(lightImageViewTopPadding);
        make.size.mas_equalTo(CGSizeMake(logoWidth, logoHeight));
    }];
    
    [self.logoName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.lightImageView.mas_bottom).with.offset(logoNameSpacing);
        make.centerX.equalTo(weakself.bgView);
    }];
    
    [self.quantView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.bgView);
        make.height.mas_equalTo(quantViewHeight);
        make.bottom.equalTo(self.bgView).offset(-quantViewBottomPadding);
    }];
    
    [self.btnOnOff mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakself.bgView.mas_bottom).offset(footHeight/2);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(btnSize, btnSize));
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

#pragma mark - 开启与关闭
- (void)onButtonClicked:(UIButton *)sender {
    XM_WS(weakself);
    if (![self.deviceSingleNetural.channel_0 isEqualToString:@"on"] && ![self.deviceSingleNetural.channel_0 isEqualToString:@"off"]){
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.offlineview.networkfail.tips",@"plugin_gateway", nil) duration:1.5f modal:YES];
        return;
    }
    self.btnOnOff.enabled = NO;
    [self setWaveAnim:YES forBtn:sender];
    MHDeviceGatewayBaseService *todoSevice = (MHDeviceGatewayBaseService *)weakself.deviceSingleNetural.services[0];
    [todoSevice serviceMethod];
    [todoSevice setServiceMethodSuccess:^(id obj) {
            [weakself.deviceSingleNetural updateServices];
            [weakself setWaveAnim:NO forBtn:weakself.btnOnOff];
            weakself.btnOnOff.enabled = YES;
            if ([weakself.deviceSingleNetural.channel_0 isEqualToString:@"disable"]) {
                weakself.isOpen = !weakself.isOpen;
            }
            else {
                [weakself loadStatus];
            }
            [weakself fetchIcon];
    }];
    
    [todoSevice setServiceMethodFailure:^(NSError *error) {
        [weakself.deviceSingleNetural updateServices];
        weakself.btnOnOff.enabled = YES;
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"send.failed",@"plugin_gateway", nil) duration:1.5f modal:YES];
        [weakself setWaveAnim:NO forBtn:weakself.btnOnOff];
    }];
    [self gw_clickMethodCountWithStatType:@"onButtonClicked:"];
}

#pragma mark - 定时
- (void)openTimerView {
    
    XM_WS(weakself);
    self.timerVC = [[MHGatewayTimerSettingNewViewController alloc] initWithDevice:self.deviceSingleNetural andIdentifier:LumiCtrlLn1TimerIdentify];
    self.timerVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.singleNeutral.timer.title",@"plugin_gateway", @"单火定时");
    self.timerVC.controllerIdentifier = @"singleNetural";
    self.timerVC.onAddNewTimer = ^(MHDataDeviceTimer *newTimer){
        [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.timersetting.adding",@"plugin_gateway","添加定时中，请稍候...") modal:YES];
        
        newTimer.identify = LumiCtrlLn1TimerIdentify;
        newTimer.onMethod = @"toggle_ctrl_neutral";
        newTimer.onParam = @[ @"channel_0" , @"on" ];
        newTimer.offMethod = @"toggle_ctrl_neutral";
        newTimer.offParam = @[ @"channel_0" , @"off" ];
        
        [weakself.timerVC addTimer:newTimer];
    };
    [self.navigationController pushViewController:self.timerVC animated:YES];
}

#pragma mark - onMore
- (void)onMore:(id)sender {
    XM_WS(weakself);
    NSString *title = NSLocalizedStringFromTable(@"mydevice.actionsheet.more",@"plugin_gateway","更多");
    NSString* logoChange = NSLocalizedStringFromTable(@"mydevice.actionsheet.changelogo",@"plugin_gateway","更换图标");
    NSString *strScene = NSLocalizedStringFromTable(@"profile.entry.triggerAction",@"plugin_gateway","自动化");
    NSString *strTimer = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.timer",@"plugin_gateway","定时");
    NSString* strChangeTitle = NSLocalizedStringFromTable(@"mydevice.actionsheet.changename",@"plugin_gateway","修改设备名称");
    
    NSString* strShowMode = self.deviceSingleNetural.showMode ? NSLocalizedStringFromTable(@"mydevice.gateway.delsub.rmvlist",@"plugin_gateway","撤销显示") : NSLocalizedStringFromTable(@"mydevice.gateway.delsub.addlist",@"plugin_gateway","添加显示");
    NSString* strFeedback = NSLocalizedStringFromTable(@"mydevice.actionsheet.feedback",@"plugin_gateway","反馈");
    
    NSMutableArray *objects = [NSMutableArray new];
    
    [objects addObject:[MHPromptKitObject objWithTitle:strScene isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        //自动化
        [weakself onAddScene];
        [weakself gw_clickMethodCountWithStatType:@"actionSheetAddScene"];
    }]];
    
    [objects addObject:[MHPromptKitObject objWithTitle:logoChange isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        //更换图标
        [weakself htmlLogo];
        [weakself gw_clickMethodCountWithStatType:@"actionSheetChangeLogo"];
    }]];
    
    [objects addObject:[MHPromptKitObject objWithTitle:strTimer isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        //定时
        [weakself openTimerView];
        [weakself gw_clickMethodCountWithStatType:@"actionSheetOpenTimerView"];
    }]];
    
    [objects addObject:[MHPromptKitObject objWithTitle:strChangeTitle isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        //修改设备名称
        [weakself deviceChangeName];
        [weakself gw_clickMethodCountWithStatType:@"actionSheetChangeName"];
    }]];
    
    [objects addObject:[MHPromptKitObject objWithTitle:strShowMode isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        // 设置列表显示
        [weakself.deviceSingleNetural setShowMode:(int)!weakself.deviceSingleNetural.showMode success:^(id obj) {
            
        } failure:^(NSError *v) {
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"setting.failed", @"plugin_gateway","") duration:1.f modal:YES];
        }];
        [weakself gw_clickMethodCountWithStatType:@"actionSheetShowMode"];
    }]];
    
    [objects addObject:[MHPromptKitObject objWithTitle:strFeedback isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        //反馈
        [weakself onFeedback];
        [weakself gw_clickMethodCountWithStatType:@"actionSheetFeedback"];
    }]];
    
    
    [objects addObject:[MHPromptKitObject objWithTitle:NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway",@"取消") isCancelBtn:YES isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        //取消
    }]];
    
    [[MHPromptKit shareInstance] showPromptInView:self.view withTitle:title withObjects:objects];
}

#pragma mark - 自动化
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

@end
