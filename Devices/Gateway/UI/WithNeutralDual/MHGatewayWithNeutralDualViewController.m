//
//  MHGatewayWithNeutralDualViewController.m
//  MiHome
//
//  Created by ayanami on 9/6/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayWithNeutralDualViewController.h"
#import "MHDeviceGatewaySensorWithNeutralDual.h"
#import "MHGatewayNullNeutralTimerSelectedViewController.h"
#import "MHGatewaySensorViewController.h"
#import "MHDeviceGatewaySensorLoopDataV2.h"
#import "MHWaveAnimation.h"
#import "MHGatewayNeutralChangeNameViewController.h"
#import "MHGatewayNeutralLogoSelectedViewController.h"
#import "MHLumiChangeIconManager.h"
#import "MHLumiPlugDataManager.h"
#import "MHLumiPlugQuantEngine.h"
#import "MHACPartnerQuantView.h"
#import "MHGatewayPlugQuantViewController.h"
#import "MHLumiLogGraphManager.h"
#import "MHWeakTimerFactory.h"

#define OpenBtn  @"lumi_neutral_on"
#define CloseBtn @"lumi_neutral_off"
#define OpenLight  @"lumi_neutral_light_title_on"
#define CloseLight @"lumi_neutral_light_title_off"

#define BtnTag_Neutral0 1000
#define BtnTag_neutral1 1001
#define btnTag_Timer    1002
#define ASTag_More      1003

@interface MHGatewayWithNeutralDualViewController ()

@property (nonatomic, strong) MHDeviceGatewaySensorWithNeutralDual *deviceNeutral;
@property (nonatomic, strong) MHGatewayNullNeutralTimerSelectedViewController *swtichSelectedVC;

@property (nonatomic, assign) BOOL isLeftOn;
@property (nonatomic, assign) BOOL isRightOn;

@property (nonatomic, strong) NSArray *callbackBlockArr;

@property (nonatomic, strong) UIButton *leftBtn;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UILabel *leftName;
@property (nonatomic, strong) UILabel *rightName;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *leftLightView;
@property (nonatomic, strong) UIImageView *rightLightView;
@property (nonatomic, strong) UIImageView *leftHaloView;
@property (nonatomic, strong) UIImageView *rightHaloView;
@property (nonatomic, strong) UIImageView *lineView;
@property (nonatomic, strong) MHACPartnerQuantView *quantView;

//layout辅助view，左右对分
@property (nonatomic, strong) UIView *layoutGuideLeftView;
@property (nonatomic, strong) UIView *layoutGuideRightView;
//

@property (nonatomic, strong) NSTimer *uiRefreshTimer;
@end

@implementation MHGatewayWithNeutralDualViewController {
    
    UIActionSheet* _actionSheet;
    MHWaveAnimation *_lWaveAnimation;
    MHWaveAnimation *_rWaveAnimation;

}

- (id)initWithDevice:(MHDevice *)device {
    if (self = [super initWithDevice:device]) {
        self.deviceNeutral = (MHDeviceGatewaySensorWithNeutralDual *)device;
        self.isHasShare = NO;
        [self.deviceNeutral buildServices];
        self.uiRefreshTimer = nil;
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
    [self.deviceNeutral restorePlugData:kQuantDay];
    [self.deviceNeutral restorePlugData:kQuantMonth];
    
    
    [[MHLumiPlugDataManager sharedInstance] setQuantDevice:self.deviceNeutral];
    [[MHLumiPlugQuantEngine sharedEngine] findStartPoint:kQuantDay];
    [[MHLumiPlugQuantEngine sharedEngine] findStartPoint:kQuantMonth];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSArray *names = [self.deviceNeutral.name componentsSeparatedByString:@"/"];
    if (names.count > 1) {
        self.title = [NSString stringWithFormat:@"%@ / %@", names[0], names[1]];
    }
    else {
        self.title = self.deviceNeutral.name;
    }
    //先更新一次获取设备属性：开关状态，电量统计等
    [self loadStatus];
    
    //启动定时更新数据：只更新开关状态，功率（设备属性）
    XM_WS(weakself);
    if (!self.uiRefreshTimer){
        self.uiRefreshTimer = [MHWeakTimerFactory scheduledTimerWithBlock:kLoopAllDataInterval callback:^{
            [weakself loadDeviceStatus];
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

- (void)loadStatus {
    XM_WS(weakself);
    //获取设备状态
    [self loadDeviceStatus];
    
    //电量统计数据
    [self.deviceNeutral fetchPlugDataWithSuccess:^(id obj){
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.quantView updateQuant:weakself.deviceNeutral.pw_day month:weakself.deviceNeutral.pw_month power:-1];
        });
    } failure:nil];
    //插座定时数据
    [self.deviceNeutral getTimerListWithID:TimerIdentifyCtrlLn2Neutral0 Success:nil andFailure:nil];
    [self.deviceNeutral getTimerListWithID:TimerIdentifyCtrlLn2Neutral1 Success:nil andFailure:nil];

}

//获取设备状态
- (void)loadDeviceStatus{
    XM_WS(weakself);
    [self.deviceNeutral getPropertyWithSuccess:^(id obj) {
        NSLog(@"%@", obj);
        [weakself.deviceNeutral updateServices];
        [weakself updateCurrentStatus];
    } andFailure:^(NSError *error) {
        [weakself.deviceNeutral updateServices];
        [weakself updateCurrentStatus];
        weakself.rightBtn.enabled = NO;
        weakself.leftBtn.enabled = NO;
    }];
}

#pragma mark - 更新UI
- (void)updateCurrentStatus {
//    self.leftBtn.enabled = ![self.deviceNeutral.channel_0 isEqualToString:@"disable"];
//    self.rightBtn.enabled = ![self.deviceNeutral.channel_1 isEqualToString:@"disable"];
    self.leftBtn.enabled = YES;
    self.rightBtn.enabled = YES;
    self.isLeftOn = [self.deviceNeutral.channel_0 isEqualToString:@"on"];
    self.isRightOn = [self.deviceNeutral.channel_1 isEqualToString:@"on"];
    self.leftHaloView.hidden = !self.isLeftOn;
    self.rightHaloView.hidden = !self.isRightOn;

    NSLog(@"左%@", self.deviceNeutral.channel_0);
    NSLog(@"右边%@", self.deviceNeutral.channel_1);
    self.leftName.text = self.isLeftOn ? NSLocalizedStringFromTable(@"mydevice.gateway.sensor.singleNeutral.isOn",@"plugin_gateway", "已开启") : NSLocalizedStringFromTable(@"mydevice.gateway.sensor.singleNeutral.isOff",@"plugin_gateway", "已关闭");
    self.rightName.text = self.isRightOn ? NSLocalizedStringFromTable(@"mydevice.gateway.sensor.singleNeutral.isOn",@"plugin_gateway", "已开启") : NSLocalizedStringFromTable(@"mydevice.gateway.sensor.singleNeutral.isOff",@"plugin_gateway", "已关闭");
    [self.leftBtn setBackgroundImage:[UIImage imageNamed:self.isLeftOn ? OpenBtn : CloseBtn] forState:UIControlStateNormal];
    
    [self.rightBtn setBackgroundImage:[UIImage imageNamed:self.isRightOn ? OpenBtn : CloseBtn] forState:UIControlStateNormal];
    [self.quantView updateQuant:self.deviceNeutral.pw_day month:self.deviceNeutral.pw_month power:self.deviceNeutral.sload_power];
    [self fetchIcon];
}

#pragma mark - 控件初始化
- (void)buildSubviews {
    [super buildSubviews];
    self.layoutGuideLeftView = [[UIView alloc] init];
    self.layoutGuideRightView = [[UIView alloc] init];
    [self.view addSubview:self.layoutGuideLeftView];
    [self.view addSubview:self.layoutGuideRightView];
    //背景
    _bgView = [[UIView alloc] init];
    _bgView.backgroundColor = [MHColorUtils colorWithRGB:0x006fc5];
    [self.view addSubview:_bgView];
    
    //左键
    self.leftBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.leftBtn.tag = BtnTag_Neutral0;
    [self.leftBtn addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.leftBtn];
    self.leftBtn.enabled = NO;
    [self.leftBtn setBackgroundImage:[UIImage imageNamed:CloseBtn] forState:UIControlStateNormal];
    
    //右键
    self.rightBtn = [[UIButton alloc] init];
    self.rightBtn.tag = BtnTag_neutral1;
    [self.rightBtn addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.rightBtn];
    self.rightBtn.enabled = NO;
    [self.rightBtn setBackgroundImage:[UIImage imageNamed:CloseBtn] forState:UIControlStateNormal];
    
    //左边开启光晕
    self.leftHaloView = [[UIImageView alloc] init];
    self.leftHaloView.image = [UIImage imageNamed:@"lumi_neutral_on_bg"];
    [self.bgView addSubview:self.leftHaloView];
    //右边开启光晕
    self.rightHaloView = [[UIImageView alloc] init];
    self.rightHaloView.image = [UIImage imageNamed:@"lumi_neutral_on_bg"];
    [self.bgView addSubview:_rightHaloView];
    
    //左边灯具图片
    self.leftLightView = [[UIImageView alloc] init];
    self.leftLightView.image = self.isLeftOn ? [UIImage imageNamed:OpenLight] : [UIImage imageNamed:CloseLight];
    [self.bgView addSubview:self.leftLightView];
    
    self.leftName = [[UILabel alloc] init];
    self.leftName.font = [UIFont systemFontOfSize:14 * ScaleWidth];
    [self.leftName setTextColor:[UIColor whiteColor]];
    [self.leftName setTextAlignment:NSTextAlignmentCenter];
    self.leftName.text = NSLocalizedStringFromTable(@"loading", @"plugin_gateway", "加载中");

    [self.bgView addSubview:self.leftName];
    
    //右边灯具图片
    self.rightLightView = [[UIImageView alloc] init];
    self.rightLightView.image = self.isRightOn ? [UIImage imageNamed:OpenLight] : [UIImage imageNamed:CloseLight];
    [self.bgView addSubview:self.rightLightView];
    
    self.rightName = [[UILabel alloc] init];
    self.rightName.font = [UIFont systemFontOfSize:14 * ScaleWidth];
    self.rightName.text = NSLocalizedStringFromTable(@"loading", @"plugin_gateway", "加载中");
    [self.rightName setTextColor:[UIColor whiteColor]];
    [self.rightName setTextAlignment:NSTextAlignmentCenter];
    [self.bgView addSubview:self.rightName];
    
    //分割线
    self.lineView = [[UIImageView alloc] init];
    self.lineView.backgroundColor = [MHColorUtils colorWithRGB:0xffffff alpha:0.2];
    [self.bgView addSubview:self.lineView];
    
    self.quantView = [[MHACPartnerQuantView alloc] init];
    [self.quantView updateQuant:0 month:0 power:0];
    XM_WS(weakSelf)
    [self.quantView setTodayCallback:^{
        MHGatewayPlugQuantViewController *quantVC = [weakSelf openQuantViewControllerWithDevice:weakSelf.deviceNeutral selectedType:kMonthDateType - 1];
        [weakSelf.navigationController pushViewController:quantVC animated:YES];
        [weakSelf gw_clickMethodCountWithStatType:@"openPlugQuant:"];
    }];
    
    [self.quantView setMonthCallback:^{
        MHGatewayPlugQuantViewController *quantVC = [weakSelf openQuantViewControllerWithDevice:weakSelf.deviceNeutral selectedType:kMonthDateType];
        [weakSelf.navigationController pushViewController:quantVC animated:YES];
        [weakSelf gw_clickMethodCountWithStatType:@"openPlugQuant:"];
    }];
    
    [self.quantView setQuantCallback:^{
        [[MHLumiLogGraphManager sharedInstance] getLogListGraphWithDeviceDid:weakSelf.deviceNeutral.did andDeviceType:MHGATEWAYGRAPH_PLUG andURL:nil andTitle:weakSelf.deviceNeutral.name andSegeViewController:weakSelf];
        //@"mydevice.gateway.sensor.plug.quant.wat.history"
        [weakSelf gw_clickMethodCountWithStatType:@"openPlugQuantWebPage"];
        [weakSelf.view addSubview:weakSelf.quantView];
    }];
    [self.bgView addSubview:self.quantView];
    
    _lWaveAnimation = [[MHWaveAnimation alloc] initWithFrame:CGRectZero];
    _lWaveAnimation.waveInterval = 0.5f;
    _lWaveAnimation.singleWaveScale = 1.5f;
    [self.view addSubview:_lWaveAnimation];
    
    _rWaveAnimation = [[MHWaveAnimation alloc] initWithFrame:CGRectZero];
    _rWaveAnimation.waveInterval = 0.5f;
    _rWaveAnimation.singleWaveScale = 1.5f;
    [self.view addSubview:_rWaveAnimation];
    
}

- (MHGatewayPlugQuantViewController *)openQuantViewControllerWithDevice:(MHDeviceGatewayBase *)device selectedType:(NSInteger)selectedType{
    MHGatewayPlugQuantViewController *quantVC = [[MHGatewayPlugQuantViewController alloc] initWithDevice:device];
    quantVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.quant",@"plugin_gateway","电量统计");
    quantVC.selectedType = selectedType ;
    return quantVC;
}

#pragma mark - 布局信息
- (void)buildConstraints {
    [super buildConstraints];
    XM_WS(weakself);
    CGFloat footHeight = 153 * ScaleHeight;
    CGFloat bgViewHeight = WIN_HEIGHT - footHeight;
    CGFloat lightViewTopPadding = (64 + 76) * ScaleHeight;
    CGFloat haloWidth = 184 * ScaleWidth;
    CGFloat haloHeight = 298 * ScaleHeight;
    
    CGFloat logoHeight = 104 * ScaleHeight;
    CGFloat logoWidth = 56 * ScaleWidth;
    
    CGFloat btnSize = 57 * ScaleWidth;
    
    CGFloat lineHeight = bgViewHeight - (64 + 76 + 62 + 86 + 80) * ScaleHeight;
    
    CGFloat logoNameSpacing = 62 * ScaleHeight;
    CGFloat quantViewBottomPadding = 40 * ScaleHeight;
    CGFloat quantViewHeight = 80 * ScaleHeight;
    [self.layoutGuideLeftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(self.view);
        make.width.equalTo(self.view).multipliedBy(0.5);
    }];
    
    [self.layoutGuideRightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(self.view);
        make.width.equalTo(self.view).multipliedBy(0.5);
    }];

    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(weakself.view);
        make.height.mas_equalTo(bgViewHeight);
    }];
    
    [self.leftLightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.layoutGuideLeftView);
        make.size.mas_equalTo(CGSizeMake(logoWidth, logoHeight));
        make.top.equalTo(self.view).offset(lightViewTopPadding);
    }];
    
    [self.leftHaloView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.leftLightView);
        make.size.mas_equalTo(CGSizeMake(haloWidth, haloHeight));
    }];
    
    [self.leftName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.leftLightView.mas_bottom).with.offset(logoNameSpacing);
        make.centerX.equalTo(weakself.leftLightView);
    }];
    
    [self.rightLightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.layoutGuideRightView);
        make.size.mas_equalTo(CGSizeMake(logoWidth, logoHeight));
        make.top.equalTo(self.view).offset(lightViewTopPadding);
    }];
    
    [self.rightHaloView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.rightLightView);
        make.size.mas_equalTo(CGSizeMake(haloWidth, haloHeight));
    }];
    
    [self.rightName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.rightLightView.mas_bottom).with.offset(logoNameSpacing);
        make.centerX.equalTo(weakself.rightLightView);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgView);
        make.centerY.equalTo(self.bgView);
        make.size.mas_equalTo(CGSizeMake(1, lineHeight));
    }];
    
    [self.quantView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.bgView);
        make.height.mas_equalTo(quantViewHeight);
        make.bottom.equalTo(self.bgView).offset(-quantViewBottomPadding);
    }];
    
    [self.leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView.mas_bottom).offset(footHeight/2);
        make.centerX.equalTo(self.layoutGuideLeftView);
        make.size.mas_equalTo(CGSizeMake(btnSize, btnSize));
    }];
    
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView.mas_bottom).offset(footHeight/2);
        make.centerX.equalTo(self.layoutGuideRightView);
        make.size.mas_equalTo(CGSizeMake(btnSize, btnSize));
    }];

}


#pragma mark - 获取图标
- (void)fetchIcon {
    XM_WS(weakself);
    if(!self.deviceNeutral.services.count){
        [self.deviceNeutral buildServices];
    }
    if(self.deviceNeutral.services.count){
        [self.deviceNeutral updateServices];
        for (MHDeviceGatewayBaseService *service in self.deviceNeutral.services) {
            NSLog(@"服务的编号%d", service.serviceId);
            NSString *iconID = [[MHLumiChangeIconManager sharedInstance] restorePdataByService:service
                                                                         withCompletionHandler:^(id result, NSError *error) {
                                                                             if(result)[weakself fetchIconWithId:result service:service];
                                                                         }];
            
            [self fetchIconWithId:iconID service:service];
        }
    }
}

- (void)fetchIconWithId:(NSString *)iconId service:(MHDeviceGatewayBaseService *)service {
    XM_WS(weakself);
    if(!iconId) {
        [self defaultIcon:service.isOpen withServiceId:service.serviceId];
    }
    else {
        NSString *iconUrl = nil;
        service.serviceIconId = iconId;
        iconUrl = [service fetchIconNameWithHeader:@"lumi"];
        if([[NSFileManager defaultManager] fileExistsAtPath:iconUrl]) {
            if(service.serviceId) [_rightLightView setImage:[UIImage imageWithContentsOfFile:iconUrl]];
            else [_leftLightView setImage:[UIImage imageWithContentsOfFile:iconUrl]];
        }
        else{
            [self defaultIcon:service.isOpen withServiceId:service.serviceId];
            [[MHLumiChangeIconManager sharedInstance] fetchIconUrlsByIconId:iconId
                                                                withService:service
                                                          completionHandler:^(id result,NSError *error){
                                                              if(!error)[weakself fetchIcon];
                                                          }];
        }
    }
}

- (void)defaultIcon:(BOOL)isOpen withServiceId:(int)serviceId {
    if(isOpen){
        if(serviceId) [_rightLightView setImage:[UIImage imageNamed:OpenLight]];
        else [_leftLightView setImage:[UIImage imageNamed:OpenLight]];
    }
    else{
        if(serviceId) [_rightLightView setImage:[UIImage imageNamed:CloseLight]];
        else [_leftLightView setImage:[UIImage imageNamed:CloseLight]];
    }
}

#pragma mark - 波纹动画
- (void)setWaveAnim:(BOOL)anim forBtn:(UIButton*)btn {
    BOOL isOpen = [btn isEqual:self.leftBtn] ? self.isLeftOn : self.isRightOn;

    MHWaveAnimation *todoWaveAnimation = nil;
    if (btn.tag == BtnTag_Neutral0){
        todoWaveAnimation = _lWaveAnimation;
    }else{
        todoWaveAnimation = _rWaveAnimation;
    }
    
    [todoWaveAnimation setFrame:[btn frame]];
    if (isOpen) {
        todoWaveAnimation.waveColor = [MHColorUtils colorWithRGB:0x888888];
    }
    else {
        todoWaveAnimation.waveColor = [MHColorUtils colorWithRGB:0x006fc5];
    }
    if (anim){
        [todoWaveAnimation startAnimation];
    }
    else{
        [todoWaveAnimation stopAnimation];
    }
}

#pragma mark - 开关控制
- (void)onButtonClicked:(UIButton *)sender {
    NSString *channelName = nil;
    NSString *channelStatus = nil;
    switch (sender.tag) {
        case BtnTag_Neutral0:
            channelName = @"channel_0";
            channelStatus = self.deviceNeutral.channel_0;
            break;
        case BtnTag_neutral1:
            channelName = @"channel_1";
            channelStatus = self.deviceNeutral.channel_1;
        default:
            break;
    }
    
    if (![channelStatus isEqualToString:@"off"] && ![channelStatus isEqualToString:@"on"]){
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.offlineview.networkfail.tips",@"plugin_gateway", nil) duration:1.5f modal:YES];
        return;
    }
    [self onNeutral:channelName andSender:sender];
    [self gw_clickMethodCountWithStatType:@"onButtonClicked:"];
}

- (void)onNeutral:(NSString *)neutral andSender:(UIButton *)sender {
    XM_WS(weakself);
    NSUInteger index = [neutral isEqualToString:@"channel_1"];
    sender.enabled = NO;
    [self setWaveAnim:YES forBtn:sender];
    MHDeviceGatewayBaseService *todoSevice = (MHDeviceGatewayBaseService *)weakself.deviceNeutral.services[index];
    [todoSevice serviceMethod];
    [todoSevice setServiceMethodSuccess:^(id obj) {
        NSLog(@"%@", obj);
        [weakself.deviceNeutral updateServices];
        if ([index ? weakself.deviceNeutral.channel_1 : weakself.deviceNeutral.channel_0 isEqualToString:@"disable"]) {
            //            index ? weakself.isRightOn = !weakself.isRightOn : weakself.isLeftOn = !weakself.isLeftOn;
            if (index) {
                weakself.isRightOn = !weakself.isRightOn;
            }
            else {
                weakself.isLeftOn = !weakself.isLeftOn;
            }
        }
        else {
            [weakself loadStatus];
        }
        [weakself setWaveAnim:NO forBtn:sender];
        sender.enabled = YES;
        [weakself fetchIcon];
    }];
    [todoSevice setServiceMethodFailure:^(NSError *error) {
        [weakself.deviceNeutral updateServices];
        sender.enabled = YES;
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"send.failed",@"plugin_gateway", nil) duration:1.5f modal:YES];
        [weakself setWaveAnim:NO forBtn:sender];
    }];
    [self gw_clickMethodCountWithStatType:@"onNeutral:andSender:"];
}

#pragma mark - 定时
- (void)openTimerView {
    self.swtichSelectedVC = [[MHGatewayNullNeutralTimerSelectedViewController alloc] initWithDevice:self.deviceNeutral];
    [self.navigationController pushViewController:self.swtichSelectedVC animated:YES];
}

#pragma mark - 设备控制相关
- (void)onMore:(id)sender {
    
    XM_WS(weakself);
    NSString *title = NSLocalizedStringFromTable(@"mydevice.actionsheet.more",@"plugin_gateway","更多");
    NSString* logoChange = NSLocalizedStringFromTable(@"mydevice.actionsheet.changelogo",@"plugin_gateway","更换图标");
    NSString *strScene = NSLocalizedStringFromTable(@"profile.entry.triggerAction",@"plugin_gateway","自动化");
    NSString *strTimer = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.timer",@"plugin_gateway","定时");
    NSString* strChangeTitle = NSLocalizedStringFromTable(@"mydevice.actionsheet.changename",@"plugin_gateway","修改设备名称");
    
    NSString* strShowMode = _deviceNeutral.showMode ? NSLocalizedStringFromTable(@"mydevice.gateway.delsub.rmvlist",@"plugin_gateway","撤销显示") : NSLocalizedStringFromTable(@"mydevice.gateway.delsub.addlist",@"plugin_gateway","添加显示");
    NSString* strFeedback = NSLocalizedStringFromTable(@"mydevice.actionsheet.feedback",@"plugin_gateway","反馈");
    
    NSMutableArray *objects = [NSMutableArray new];
    
    [objects addObject:[MHPromptKitObject objWithTitle:strScene isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        //自动化
        [weakself onAddScene];
        [weakself gw_clickMethodCountWithStatType:@"actionSheetAddScene"];
    }]];
    
    [objects addObject:[MHPromptKitObject objWithTitle:logoChange isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        //更换图标
        [weakself chooseLogo];
        [weakself gw_clickMethodCountWithStatType:@"actionSheetChangeLogo"];
    }]];
    
    [objects addObject:[MHPromptKitObject objWithTitle:strTimer isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        //定时
        [weakself openTimerView];
        [weakself gw_clickMethodCountWithStatType:@"actionSheetOpenTimerView"];
    }]];
    
    [objects addObject:[MHPromptKitObject objWithTitle:strChangeTitle isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        //修改设备名称
        [weakself onchangeName];
        [weakself gw_clickMethodCountWithStatType:@"actionSheetChangeName"];
    }]];
    
    [objects addObject:[MHPromptKitObject objWithTitle:strShowMode isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        // 设置列表显示
        [weakself.deviceNeutral setShowMode:(int)!weakself.deviceNeutral.showMode success:^(id obj) {
            
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
    MHGatewaySensorViewController *sceneVC = [[MHGatewaySensorViewController alloc] initWithDevice:self.deviceNeutral];
    sceneVC.isHasMore = NO;
    sceneVC.isHasShare = NO;
    [self.navigationController pushViewController:sceneVC animated:YES];
}

#pragma mark - 重命名
- (void)onchangeName {
    MHGatewayNeutralChangeNameViewController *changeNameVC = [[MHGatewayNeutralChangeNameViewController alloc] initWithDevice:self.deviceNeutral];
    [self.navigationController pushViewController:changeNameVC animated:YES];
}

#pragma mark - 选择图标
-(void)chooseLogo{
    XM_WS(weakself);
    MHGatewayNeutralLogoSelectedViewController *logoChoose = [[MHGatewayNeutralLogoSelectedViewController alloc] initWithDevice:_deviceNeutral];
    if(self.deviceNeutral.services.count){
        logoChoose.service0 = weakself.deviceNeutral.services[0];
        logoChoose.service1 = weakself.deviceNeutral.services[1];
    }
    [self.navigationController pushViewController:logoChoose animated:YES];
}


@end
