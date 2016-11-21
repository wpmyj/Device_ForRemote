//
//  MHGatewayMainViewController.m
//  MiHome
//
//  Created by Lynn on 2/16/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayMainViewController.h"
#import "MHDeviceGateway.h"
#import "MHGatewayDisclaimerView.h"
#import "MHGatewayDisclaimerViewController.h"
#import "MHGatewayTabView.h"
#import "MHGatewayControlViewController.h"
#import "MHGatewaySceneListViewController.h"
#import "MHGatewayDeviceListViewController.h"
#import "MHGatewayBindSceneManager.h"
#import "MHGatewayExtraSceneManager.h"
#import "MHGatewayLogViewController.h"
#import "MHGatewayWebViewController.h"
#import "MHGatewaySettingViewController.h"
#import "MHLuWebViewController.h"
#import "MHGatewayAboutViewController.h"
#import "MHGatewayAlarmSettingViewController.h"
#import "MHGatewayDoorBellSettingViewController.h"
#import "MHGatewayLightSettingViewController.h"
#import "MHGatewayClockTimerListViewController.h"
#import "MHGatewaySetAlarmClockViewController.h"
#import "MHGatewayLightTimerSettingViewController.h"
#import "MHGatewayMainpageAnimation.h"
#import "MHLumiFmPlayer.h"
#import "MHIFTTTEditViewController.h"
#import "MHDeviceVerViewController.h"
#import "MHLumiFMCollectViewController.h"
#import "MHLumiDreamPartnerDataManager.h"
#import "MHLumiChooseLogoListManager.h"
#import "MHLumiLogGraphManager.h"
#import "MHGatewayAlarmClockTimerNewViewController.h"
#import "MHGatewayTempAndHumidityViewController.h"
#import "MHGatewayAddSubDeviceListController.h"
#import "MHLumiHtmlHandleTools.h"
#import "MHGatewaySceneLogDataManager.h"
#import "MHGatewayMigrationAboutController.h"
#import "MHGatewaySceneLogViewController.h"
#import "MHFeedbackDeviceDetailViewController.h"
#import "MHWebViewController.h"
#import "MHLumiActivitiesHelper.h"
#define kDreamPartner           @"DreamPartnerFlag"
#define kURL_Dream              @"http://ld-app.mi-ae.com.cn/html/dreamPartner/pageturn.html"

#import "MHDeviceGatewaySensorMagnet.h"
#import "MHDeviceGatewaySensorMotion.h"
#import "MHDeviceGatewaySensorSwitch.h"
#import "MHWeakTimerFactory.h"

@interface MHGatewayMainViewController () <UIActionSheetDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) MHDeviceGateway *gateway;
@property (nonatomic, assign) BOOL isShowingDisclaimer;   //是否正在显示“免责声明”的view
@property (nonatomic, retain) MHGatewayDisclaimerView* disclaimerView;
@property (nonatomic, retain) MHGatewayTabView *tabView;
@property (nonatomic, strong) MHGatewayControlViewController *controlView;
@property (nonatomic, strong) MHGatewaySceneListViewController *sceneList;
@property (nonatomic, strong) MHGatewayDeviceListViewController *deviceList;
@property (nonatomic, strong) MHGatewayMainpageAnimation *animationTool;
@property (nonatomic, assign) NSInteger retryCount;
@property (nonatomic, assign) BOOL hasSetDefaultIFTTT; //产品要求只在进入页面时才检测。与之前的检测时机不同。但又有顺序依赖。
@property (nonatomic, strong) NSTimer *timerForSetDefaultIFTTT;
@end

@implementation MHGatewayMainViewController
{
    UIActionSheet *                             _actionSheet;
//    MHGatewayMainpageAnimation *                _animationTool;
}

- (id)initWithDevice:(MHDevice*)device {
    if (self = [super initWithDevice:device]) {
        self.isHasSetting = YES;
        self.retryCount = 0;
        self.gateway = (MHDeviceGateway *)device;
        _hasSetDefaultIFTTT = NO;
        XM_WS(weakself);
        [[NSNotificationCenter defaultCenter] addObserverForName:[[MHDevListManager sharedManager] notificationNameForUIUpdate] object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [weakself onGetDeviceListSucceed:note];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:@"NightTouchesBegan" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [weakself.animationTool homeVCRemovewGestureRecognizer];
            weakself.view.userInteractionEnabled = NO;
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:@"NightTouchesEnded" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [weakself.animationTool homeVCAddGestureRecognizer];
            weakself.view.userInteractionEnabled = YES;

        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:@"NightTouchesCancelled" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [weakself.animationTool homeVCAddGestureRecognizer];
            weakself.view.userInteractionEnabled = YES;

        }];

    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isNavBarTranslucent = YES;
    [self loadStatus];
    [self getOtherStatus];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self redrawNavigationBar];
    if (![self isDisclaimerShown]) {
        _isShowingDisclaimer = YES;
        [self showDisclaimer];
    }else{
        [self checkVersionAndSetDefaultConfiguration];
    }
    
    [_deviceList startRefresh];
    [_sceneList loadIFTTTRecords];
}

- (BOOL)isAllowedToCheckUpgrade{
    return [self isDisclaimerShown];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_controlView viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self saveStatus];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (![self.navigationController.topViewController isKindOfClass:[MHLumiFMCollectViewController class]]) {
        [[MHLumiFmPlayer shareInstance] hide];
    }
}

- (void)applicationDidEnterBackground {
    [self saveStatus];
}



- (void)redrawNavigationBar {

    UIImage* leftImage = [[UIImage imageNamed:@"navi_back_black"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    if(!_tabView.currentIndex) {
        leftImage = [[UIImage imageNamed:@"navi_back_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage* imageMore = [[UIImage imageNamed:@"navi_more_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        if(self.gateway.shareFlag == MHDeviceUnShared){
            UIBarButtonItem *rightItemMore = [[UIBarButtonItem alloc] initWithImage:imageMore
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self action:@selector(onMore:)];
            self.navigationItem.rightBarButtonItem = rightItemMore;
            
        }

        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
    }
    else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

        self.navigationItem.rightBarButtonItem = nil;
    }
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:leftImage
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self action:@selector(onBack:)];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)buildSubviews {
    [super buildSubviews];
    
    XM_WS(weakself);
    CGRect tabRect = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds) * 0.6, 44);
    NSArray *tabTitleArray = @[
                               @{ @"name" : NSLocalizedStringFromTable(@"mydevice.gateway.mainpage.tab.title1", @"plugin_gateway", nil) ,
                                  @"color" : [UIColor colorWithWhite:1.f alpha:1.f] } ,
                               @{ @"name" : NSLocalizedStringFromTable(@"mydevice.gateway.mainpage.tab.title2", @"plugin_gateway", nil) ,
                                  @"color" : [MHColorUtils colorWithRGB:0x25bba4] } ,
                               @{ @"name" : NSLocalizedStringFromTable(@"mydevice.gateway.mainpage.tab.title3", @"plugin_gateway", nil) ,
                                  @"color" : [MHColorUtils colorWithRGB:0x25bba4] } ,
                               ];
    _tabView = [[MHGatewayTabView alloc] initWithFrame:tabRect
                                            titleArray:tabTitleArray
                                             stypeType:LumiTabStyleInTitle
                                              callback:^(NSInteger idx) {
                                                  [weakself onTabClicked:idx];
                                              }];
    self.navigationItem.titleView = _tabView;

    _controlView = [[MHGatewayControlViewController alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT) sensor:_gateway];
    _controlView.navigationClick = ^(UIViewController *destinationVC) {
        [weakself.navigationController pushViewController:destinationVC animated:YES];
    };
    _controlView.openDevicePageCallback = ^(MHDeviceGatewayBase *sensor){
        Class deviceClassName = NSClassFromString([[sensor class] getViewControllerClassName]);
        id deviceVC = [[deviceClassName alloc] initWithDevice:sensor];
        [weakself.navigationController pushViewController:deviceVC animated:YES];
    };
    _controlView.chooseServiceIcon = ^(MHDeviceGatewayBaseService *service){
        [[MHLumiChooseLogoListManager sharedInstance] chooseLogoWithSevice:service iconID:service.serviceIconId titleIdentifier:service.serviceName segeViewController:weakself];
    };
    _controlView.openDeviceLogPageCallback = ^(MHDeviceGatewayBase *sensor){
        [weakself openDeviceLogPage:sensor];
    };
    [self.view addSubview:_controlView.view];
    
    _sceneList = [[MHGatewaySceneListViewController alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT) sensor:_gateway];
    _sceneList.view.hidden = YES;
    _sceneList.sceneLogClicked = ^{
        MHGatewaySceneLogViewController* logVC = [[MHGatewaySceneLogViewController alloc] initWithGateway:weakself.gateway];
        [weakself.navigationController pushViewController:logVC animated:YES];
    };
    _sceneList.sysIftCellClicked = ^(SysIftType type){
        [weakself sysIftCellSelected:type];
    };
    _sceneList.customIftCellClicked = ^(MHDataIFTTTRecord *record){
        MHIFTTTEditViewController* editVC = [MHIFTTTEditViewController new];
        editVC.record = record;
        editVC.editCompletion = ^(MHDataIFTTTRecord *record) {
            [[MHIFTTTManager sharedInstance].recordList addObject:record];
            [weakself.navigationController popToViewController:weakself animated:YES];
        };
        editVC.recordDeleted = ^(MHDataIFTTTRecord* record) {
            [weakself.navigationController popToViewController:weakself animated:YES];
        };
        [weakself.navigationController pushViewController:editVC animated:YES];
    };
    [_sceneList setOfflineRecord:^(MHDataIFTTTRecord *offlineRecord) {
        [weakself offlineClicked:offlineRecord];
    }];
    
    [self.view addSubview:_sceneList.view];

    _deviceList = [[MHGatewayDeviceListViewController alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT) sensor:_gateway];
    _deviceList.view.hidden = YES;
    _deviceList.clickAddDeviceBtn = ^(){
        MHGatewayAddSubDeviceListController *addlist = [[MHGatewayAddSubDeviceListController alloc] init];
        addlist.device = weakself.gateway;
        MHLuDeviceSettingGroup* group1 = [[MHLuDeviceSettingGroup alloc] init];
        group1.title = NSLocalizedStringFromTable(@"deviceselect.title",@"plugin_gateway", "选择要连接的设备");
        MHLuDeviceSettingGroup* group2 = [[MHLuDeviceSettingGroup alloc] init];
        addlist.settingGroups = [NSMutableArray arrayWithObjects:group1,group2, nil];
        [weakself.navigationController pushViewController:addlist animated:YES];
    };
    _deviceList.clickDeviceCell = ^(MHDeviceGatewayBase *device){
        if([device isKindOfClass:[MHDeviceGateway class]]){
            MHGatewaySettingViewController* settingVC = [[MHGatewaySettingViewController alloc] initWithDevice:weakself.gateway];
            settingVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.title",@"plugin_gateway","多功能网关");
            [weakself.navigationController pushViewController:settingVC animated:YES];
            [weakself gw_clickMethodCountWithStatType:@"openGatewaySettingPage"];
        }
        else{
//            MHGatewayNamingSpeedViewController *nameVC = [[MHGatewayNamingSpeedViewController alloc] initWithSubDevice:device gatewayDevice:weakself.gateway shareIdentifier:NO serviceIndex:0];
//            [weakself.navigationController pushViewController:nameVC animated:YES];
            [weakself gw_clickMethodCountWithStatType:[NSString stringWithFormat:@"openDeviceDetatilPage_%@", NSStringFromClass([device class])]];

            Class deviceClassName = NSClassFromString([[device class] getViewControllerClassName]);
            id deviceVC = [[deviceClassName alloc] initWithDevice:device];
            [weakself.navigationController pushViewController:deviceVC animated:YES];
        }
    };
    _deviceList.clickChangeBattery = ^(MHDeviceGatewayBase *device){
        //更换电池
        NSURL* faqURL = [NSURL URLWithString:[[device class] getBatteryChangeGuideUrl]];
        MHGatewayWebViewController* faqVC = [[MHGatewayWebViewController alloc] initWithURL:faqURL];
        faqVC.controllerIdentifier = @"mydevice.gateway.sensor.changebattery";
        faqVC.hasShare = NO;
        faqVC.strOriginalURL = [[device class] getBatteryChangeGuideUrl];
        [weakself.navigationController pushViewController:faqVC animated:YES];
    };
    _deviceList.deviceCountChange = ^{
        [weakself.controlView reBuildSubviews];
    };

    [self.view addSubview:_deviceList.view];
    
    _animationTool = [[MHGatewayMainpageAnimation alloc] init];
    _animationTool.homeVC = self;
    _animationTool.subViewArray = @[_controlView.view,_sceneList.view,_deviceList.view];
    [_animationTool homeVCAddGestureRecognizer];
    _animationTool.leftAnimationEndCallBack = ^(){
        [weakself onBack:nil];
    };
    _animationTool.onClickCurrentIndex = ^(NSInteger index){
        [weakself.tabView selectItem:index];
    };
}

- (void)setDefaultMainPageHeader:(MaiPageHeaderType)headerType {
    NSInteger type = 0;
    
    if ([self.gateway.model isEqualToString:kGatewayModelV2] ||
        [self.gateway.model isEqualToString:kGatewayModelV1]) {
        switch (headerType) {
            case MainPage_ALARM:
                type = 0;
                break;
            case MainPage_Light:
                type = 1;
                break;
            default:
                break;
        }
    }
    else {
        type = (NSInteger)headerType;
    }
    NSString *key = [NSString stringWithFormat:@"%@%@",HeaderViewLastIndexKey,self.gateway.did];
    [[NSUserDefaults standardUserDefaults] setObject:@(type) forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)offlineClicked:(MHDataIFTTTRecord *)selectedRecord {
    NSString *strDelete = NSLocalizedStringFromTable(@"ifttt.scene.local.scene.log.scenedelete.confirm", @"plugin_gateway", "我知道了");
    NSString *strRetry = NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.switch.see", @"plugin_gateway", "去看看");
    NSString *strTitle = nil;
    NSArray *buttonArray = nil;
    
    strTitle = NSLocalizedStringFromTable(@"ifttt.scene.local.delete.alert.offline.title", @"plugin_gateway", "自动化中有设备离线了,快去看看吧");
    buttonArray = @[ strDelete, strRetry ];
    
    
    XM_WS(weakself);
    [[MHPromptKit shareInstance] showAlertWithHandler:^(NSInteger buttonIndex, NSArray *inputs) {
        switch (buttonIndex) {
            case 0: {
                //我知道了
            }
                break;
            case 1: {
                //去看看
                MHIFTTTEditViewController* editVC = [MHIFTTTEditViewController new];
                editVC.record = selectedRecord;
                editVC.editCompletion = ^(MHDataIFTTTRecord *record) {
                    [[MHIFTTTManager sharedInstance].recordList addObject:record];
                    [weakself.navigationController popToViewController:weakself animated:YES];
                };
                editVC.recordDeleted = ^(MHDataIFTTTRecord* record) {
                    [weakself.navigationController popToViewController:weakself animated:YES];
                };
                [weakself.navigationController pushViewController:editVC animated:YES];
            }
                break;
                
            default:
                break;
        }
    } withTitle:@"" message:strTitle style:UIAlertViewStyleDefault defaultText:nil cancelButtonTitle:nil otherButtonTitlesArray:buttonArray];
}

#pragma mark - 打开设备页
- (void)openDeviceLogPage:(MHDeviceGatewayBase *)sensor {
    if([sensor isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorHumiture")]) {
        MHGatewayTempAndHumidityViewController *humidity = [[MHGatewayTempAndHumidityViewController alloc] initWithDevice:sensor];
        [humidity graphLogList];
//        [[MHLumiLogGraphManager sharedInstance] getLogListGraphWithDeviceDid:sensor.did
//                                                               andDeviceType:NSStringFromClass([sensor class])
//                                                                      andURL:HumitureLogWebPageURLCN
//                                                          andTitleIdentifier:@"mydevice.gateway.sensor.humiture.Trend"
//                                                       andSegeViewController:self];
    }
    else {
        MHGatewayLogViewController *log = [[MHGatewayLogViewController alloc] initWithDevice:sensor];
        log.isTabBarHidden = YES;
        log.title = [NSString stringWithFormat:@"%@%@",sensor.name, NSLocalizedStringFromTable(@"mydevice.gateway.log",@"plugin_gateway", "")];
        [self.navigationController pushViewController:log animated:YES];
    }
    
    [self gw_clickMethodCountWithStatType:[NSString stringWithFormat:@"openDeviceLogPage_%@", NSStringFromClass([sensor class])]];

}

#pragma mark - tab view clicked 切换view
- (void)onTabClicked:(NSInteger)index {
    switch (index) {
        case 0:
            _controlView.view.hidden = NO;
            _sceneList.view.hidden = YES;
            _deviceList.view.hidden = YES;
            break;
        case 1:
            _controlView.view.hidden = YES;
            _sceneList.view.hidden = NO;
            _deviceList.view.hidden = YES;
            break;
        case 2:
            _controlView.view.hidden = YES;
            _sceneList.view.hidden = YES;
            _deviceList.view.hidden = NO;
            break;
        default:
            break;
    }
    _animationTool.currentIndex = index;
    [self redrawNavigationBar];
}

#pragma mark - 梦想合伙人是否显示
- (void)dreamPartner {
    //子设备购买链接
    [[MHLumiDreamPartnerDataManager sharedInstance] fetchBuyingLinksDataSuccess:^(id obj) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSString *motion = obj[kSensor_motion];
            NSString *magnet = obj[kSensor_magnet];
            [[NSUserDefaults standardUserDefaults] setObject:motion forKey:kMotionBuyingLinksKey];
            [[NSUserDefaults standardUserDefaults] setObject:magnet forKey:kMagnetBuyingLinksKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    } andFailure:^(NSError *v) {
        
    }];
    
}

#pragma mark - 设备列表更新
- (void)onGetDeviceListSucceed:(NSNotification* )note {
    [_deviceList startRefresh];
}

#pragma mark - 设备状态
#pragma mark : - check version
- (void)checkVersionAndSetDefaultConfiguration {
    XM_WS(weakself);
    [self.gateway versionControl:^(NSInteger retcode) {
        if (retcode == -1){
            return;
        }else if (retcode == -2){
            if (weakself.hasSetDefaultIFTTT){
                [weakself onDeviceUpgradePage];
                return;
            }
            weakself.hasSetDefaultIFTTT = YES;
            //先配置再更新固件
            [self setDefaultConfigurationWithDelay:0 completionHandler:^{
                [weakself onDeviceUpgradePage];
            }];
        }else{
            if (weakself.hasSetDefaultIFTTT){
                return;
            }
            weakself.hasSetDefaultIFTTT = YES;
            [self setDefaultConfigurationWithDelay:0 completionHandler:nil];
        }
    }];
}

#pragma mark :- 缓存
- (void)loadStatus {
//    NSDictionary *params = [self.gateway getStatusRequestPayload];
//    [self.gateway sendPayload:params success:nil failure:nil];
    [self.gateway getProperty:ARMING_DELAY_INDEX success:nil failure:nil];
    [self dreamPartner];
    if ([_gateway.model isEqualToString:@"lumi.gateway.v3"]) {
        //关闭300网关的旧闹钟
        BOOL hasOldClock = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"threeOldClockTimer_%@", self.gateway.did]] boolValue];
        self.gateway.alarm_clock_enable = 0;
        NSString *gatewayDid = self.gateway.did;
        if (hasOldClock) {
            [self.gateway setAlarmClockDataWithEnable:^(id obj) {
                [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:[NSString stringWithFormat:@"threeOldClockTimer_%@", gatewayDid]];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } failure:^(NSError *v) {
                
            }];
        }
    }
   
}

- (void)saveStatus {
    for (MHDeviceGatewayBase* subDevice in self.device.subDevices) {
        [subDevice.logManager saveLogList];
        [subDevice.logManager saveLatestLog];
    }
}

#pragma mark :- 其它状态
- (void)getOtherStatus {
    XM_WS(weakself);
    __block MHSafeDictionary *tempDic = [[MHSafeDictionary alloc] init];
    [self.gateway.subDevices enumerateObjectsUsingBlock:^(MHDeviceGatewayBase *sensor, NSUInteger idx, BOOL *stop) {
        sensor.parent = weakself.gateway;
        NSString *name = sensor.name;
        [tempDic setObject:name forKey:sensor.did];
    }];
    //网关时间可能did是网关的did导致取不到子设备名字
    [tempDic setObject:@"小米多功能网关" forKey:self.gateway.did];
    self.gateway.logManager.deviceNames = tempDic;

    if([self.gateway.model isEqualToString:kGatewayModelV3]){
        [[MHGatewayBindSceneManager sharedInstance] fetchBindSceneList:self.gateway withSuccess:nil];
        [[MHGatewayExtraSceneManager sharedInstance] fetchExtraMapTableWithSuccess:nil failure:nil];
    }
    else {
        [self.gateway getBindListOfSensorsWithSuccess:nil failure:nil];
    }
}

#pragma mark - more btn 更多按钮
// 点击设备页面右上角(...)按钮后的响应函数
- (void)onMore:(id)sender {
    //。。。更多按钮，actionsheet
    NSString* strNew = NSLocalizedStringFromTable(@"mydevice.gateway.about.tutorial",@"plugin_gateway","新手引導");
    NSString* strSetting = NSLocalizedStringFromTable(@"mydevice.gateway.about.freFAQ",@"plugin_gateway","常见问题");
    NSString* strAbout = NSLocalizedStringFromTable(@"mydevice.gateway.about.titlesettingcell",@"plugin_gateway","关于");
    NSString* strChangeTitle = NSLocalizedStringFromTable(@"mydevice.actionsheet.changename",@"plugin_gateway","修改设备名称");
    NSString* strShare = NSLocalizedStringFromTable(@"mydevice.actionsheet.share",@"plugin_gateway","设备共享");
    NSString* strUpgrade = NSLocalizedStringFromTable(@"mydevice.actionsheet.upgrade",@"plugin_gateway","检查固件升级");
    NSString* strFeedback = NSLocalizedStringFromTable(@"mydevice.actionsheet.feedback",@"plugin_gateway","反馈");
    NSString* cancel = NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway",@"取消");
    NSString *title = NSLocalizedStringFromTable(@"mydevice.actionsheet.more",@"plugin_gateway","更多");

    NSMutableArray *objArray = [NSMutableArray array];
    XM_WS(weakself);

    [objArray addObject:[MHPromptKitObject objWithTitle:strNew isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        NSString *strURL = kNewUserCN;
        [weakself openWebVC:strURL identifier:@"mydevice.gateway.about.tutorial" share:NO];
        [weakself gw_clickMethodCountWithStatType:@"tutorial"];
    }]];
    
    [objArray addObject:[MHPromptKitObject objWithTitle:strSetting isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        MHFeedbackDeviceDetailViewController *detailVC = [MHFeedbackDeviceDetailViewController new];
        detailVC.category = Device;
        detailVC.device = weakself.gateway;
        [weakself.navigationController pushViewController:detailVC animated:YES];
        [weakself gw_clickMethodCountWithStatType:@"freFAQ"];
    }]];
    
    [objArray addObject:[MHPromptKitObject objWithTitle:strAbout isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        [weakself gw_clickMethodCountWithStatType:@"about"];
        MHGatewayAboutViewController *about = [[MHGatewayAboutViewController alloc] init];
        about.gatewayDevice = weakself.gateway;
        [weakself.navigationController pushViewController:about animated:YES];
    }]];
    
    [objArray addObject:[MHPromptKitObject objWithTitle:strChangeTitle isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        [weakself gw_clickMethodCountWithStatType:@"ChangeName"];
        [weakself deviceChangeName];
    }]];
    
    [objArray addObject:[MHPromptKitObject objWithTitle:strShare isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        [weakself gw_clickMethodCountWithStatType:@"Share"];
        [weakself deviceShare];
    }]];
    
    [objArray addObject:[MHPromptKitObject objWithTitle:strUpgrade isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        [weakself gw_clickMethodCountWithStatType:@"UpgradePage"];
        [weakself onDeviceUpgradePage];
    }]];
    
    [objArray addObject:[MHPromptKitObject objWithTitle:strFeedback isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        [weakself gw_clickMethodCountWithStatType:@"Feedback"];
        [weakself onFeedback];
    }]];
    
    [objArray addObject:[MHPromptKitObject objWithTitle:cancel isCancelBtn:YES isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {

    }]];
    
    [[MHPromptKit shareInstance] showPromptInView:self.view withTitle:title withObjects:objArray];
}

//设备迁移
- (void)gatewayMigration {
    MHGatewayMigrationAboutController *migrateAbout = [[MHGatewayMigrationAboutController alloc] init];
    migrateAbout.gateway = self.gateway;
    migrateAbout.isTabBarHidden = YES;
    [self.navigationController pushViewController:migrateAbout animated:YES];
}

- (void)openWebVC:(NSString *)strURL identifier:(NSString *)identifier share:(BOOL)share{
    MHGatewayWebViewController *web = [MHGatewayWebViewController openWebVC:strURL identifier:identifier share:share];
    [self.navigationController pushViewController:web animated:YES];
}

#pragma mark - 系统自动化
- (void)sysIftCellSelected:(SysIftType)type {
    switch (type) {
        case Gateway_System_Scene_Alarm:
            [self openAlarmSettingPage];
            break;
        case Gateway_System_Scene_NightLight :
            [self openNightlight];
            break;
        case Gateway_System_Scene_TimerLight :
            [self openTimerlight];
            break;
        case Gateway_System_Scene_AlarmClock :
            [self openAlarmClock];
            break;
        case Gateway_System_Scene_DoorBell :
            [self openDoorBell];
            break;
        default:
            break;
    }
}

- (void)openAlarmSettingPage {
    MHGatewayAlarmSettingViewController* alarmSettingVC = [[MHGatewayAlarmSettingViewController alloc] initWithGateway:_gateway];
    alarmSettingVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm", @"plugin_gateway","警戒模式");
    alarmSettingVC.isTabBarHidden = YES;
    [self.navigationController pushViewController:alarmSettingVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"openAlarmSettingPage"];
}

- (void)openNightlight {
    MHGatewayLightSettingViewController *nightLightSettingVC = [[MHGatewayLightSettingViewController alloc] initWithGateway:_gateway];
    nightLightSettingVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight",@"plugin_gateway","智能彩灯设置");
    nightLightSettingVC.isTabBarHidden = YES;
    [self.navigationController pushViewController:nightLightSettingVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"openNightLightSettingPage"];
}

- (void)openTimerlight {
    MHGatewayLightTimerSettingViewController *timerVC = [[MHGatewayLightTimerSettingViewController alloc] initWithDevice:self.gateway andIdentifier:@"lumi_gateway_single_rgb_timer"];
    timerVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.timer.cap",@"plugin_gateway","定时彩灯");
    timerVC.controllerIdentifier = @"gateway_single_rgb";
    [self.navigationController pushViewController:timerVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"openTimerView"];
}

- (void)openAlarmClock {
    if ([_gateway.model isEqualToString:@"lumi.gateway.v2"]) {
        MHGatewaySetAlarmClockViewController *alarmClockVC = [[MHGatewaySetAlarmClockViewController alloc] init];
                alarmClockVC.settingTableView.scrollEnabled = YES;
                alarmClockVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmclock",@"plugin_gateway", "闹钟设置");
                alarmClockVC.isTabBarHidden = YES;
                alarmClockVC.isGroupStyle = YES;
                alarmClockVC.device = _gateway;
                [self.navigationController pushViewController:alarmClockVC animated:YES];
            [self gw_clickMethodCountWithStatType:@"openAlarmClockSetting"];
    }
    else {
        MHGatewayAlarmClockTimerNewViewController *tVC = [[MHGatewayAlarmClockTimerNewViewController alloc] initWithDevice:_gateway andIdentifier:@"lumi_gateway_clock_timer"];
        tVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmclock",@"plugin_gateway", "闹钟设置");
        tVC.controllerIdentifier = @"lumi_gateway_clock_timer";
        __weak MHGatewayAlarmClockTimerNewViewController *weakVC = tVC;
        tVC.onAddNewTimer = ^(MHDataDeviceTimer *newTimer){
            [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.timersetting.adding",@"plugin_gateway","添加定时中，请稍候...") modal:YES];
            newTimer.identify = @"lumi_gateway_clock_timer";
            newTimer.onMethod = @"play_alarm_clock";
            newTimer.offMethod = @"play_alarm_clock";
            newTimer.offParam = @[ @"off" ];
            [weakVC addTimer:newTimer];
        };
        [self.navigationController pushViewController:tVC animated:YES];
        [self gw_clickMethodCountWithStatType:@"openAlarmClockSetting"];
        
    }
}

- (void)openDoorBell {
    MHGatewayDoorBellSettingViewController* doorBellSettingVC = [[MHGatewayDoorBellSettingViewController alloc] initWithGateway:_gateway];
    doorBellSettingVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.settingcell", @"plugin_gateway","门铃设置");
    doorBellSettingVC.isTabBarHidden = YES;
    [self.navigationController pushViewController:doorBellSettingVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"openDoorBellSettingPage"];
}


#pragma mark - 免责声明
#define keyForDisclaimer @"keyForDisclaimer"
- (void)openDisclaimerPage {
    XM_WS(weakself);
    MHGatewayDisclaimerViewController* disclaimerVC = [[MHGatewayDisclaimerViewController alloc] init];
    disclaimerVC.onBack = ^{
        [weakself.disclaimerView showPanelWithAnimation:NO];
    };
    [self.navigationController pushViewController:disclaimerVC animated:YES];
    [_disclaimerView hideWithAnimation:NO];
}

-(void)showDisclaimer {
    XM_WS(weakself);

    _disclaimerView = [[MHGatewayDisclaimerView alloc] initWithFrame:self.view.bounds panelFrame:CGRectMake(0, self.view.bounds.size.height - 200, self.view.bounds.size.width, 200) withCancel:^(id v) {
        [weakself.navigationController popViewControllerAnimated:YES];
    } withOk:^(id v) {
        [weakself.disclaimerView hideWithAnimation:YES];
        [weakself setDisclaimerShown:YES];
        [weakself setIsShowingDisclaimer:NO];
        [weakself checkVersionAndSetDefaultConfiguration];
    }];
    _disclaimerView.onOpenDisclaimerPage = ^(void){
        [weakself openDisclaimerPage];
    };
    _disclaimerView.isExitOnClickBg = NO;
    [[UIApplication sharedApplication].keyWindow addSubview:_disclaimerView];
}

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

//对setDefaultConfigurationWithCompletionHandler 回调加个处理，延迟和v3判断
- (void)setDefaultConfigurationWithDelay:(NSTimeInterval)delay completionHandler:(void(^)())completionHandler{
    XM_WS(weakself)
    if(![self.gateway.model isEqualToString:kGatewayModelV3]){
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself setDefaultConfigurationWithCompletionHandler:^BOOL(NSInteger count, bool flag) {
            if (flag == NO && count < 3) {
                return YES;
            }
            if (completionHandler){
                completionHandler();
            }
            [weakself.sceneList loadIFTTTRecords];
            return NO;
        }];
    });
}

//双11套装自动化配置
- (void)setDefaultConfigurationWithCompletionHandler:(BOOL(^)(NSInteger count, bool flag))completionHandler{
    XM_WS(weakself);
    MHLumiRequestLogHelper *helper = [[MHLumiRequestLogHelper alloc] initWithType:MHLumiActivitiesTypeDouble11 andIdentifier:self.gateway.did];
    void(^configurationBlock)() = ^(){
        [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"automation.configuring",@"plugin_gateway",@"正在配置自动化，请稍候") modal:YES];
        MHLumiActivitiesHelper *activitiesHelper = [[MHLumiActivitiesHelper alloc] initWithType:MHLumiActivitiesTypeDouble11
                                                                                        gateway:self.gateway
                                                                                      logHelper:helper];
        void(^invalidateTimer)() = ^{
            [weakself.timerForSetDefaultIFTTT invalidate];
            weakself.timerForSetDefaultIFTTT = nil;
        };
        if (weakself.timerForSetDefaultIFTTT){
            invalidateTimer();
        }
        weakself.timerForSetDefaultIFTTT = [MHWeakTimerFactory scheduledTimerWithBlock:10 userInfo:nil repeats:NO callback:^{
            [[MHTipsView shareInstance] hide];
            invalidateTimer();
        }];
        [activitiesHelper setDefaultconfigurationWithSuccess:^{
            //成功配置场景
            weakself.retryCount ++;
            if (completionHandler(weakself.retryCount,YES)){
                [weakself setDefaultConfigurationWithCompletionHandler:completionHandler];
            }
            [[MHTipsView shareInstance] showFinishTips:NSLocalizedStringFromTable(@"configuration.succeeded",@"plugin_gateway",@"配置成功") duration:2 modal:YES];
            invalidateTimer();
        } failure:^{
            weakself.retryCount ++;
            invalidateTimer();
            if (completionHandler(weakself.retryCount,NO)){
                [weakself setDefaultConfigurationWithCompletionHandler:completionHandler];
            }else{
                [[MHTipsView shareInstance] hide];
                [weakself setDefaultConfigurationFailure];
            }
        }];
    };
    if ([helper isLogExisted]){
//        if (![helper isCompleted]){
//            configurationBlock();
//        }else{
            completionHandler(weakself.retryCount,YES);
//        }
    }else{
        [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"loading",@"plugin_gateway",@"加载中") modal:YES];
        [self.gateway getLumiBlindWithSuccess:^(NSInteger retcode) {
            weakself.retryCount ++;
            if (retcode == 1){//1 代表双11
                [helper resetLogDic];
                configurationBlock();
            }else{
                [helper markToSuccess];
                [[MHTipsView shareInstance] hide];
                completionHandler(weakself.retryCount,YES);
            }
        } failure:^(NSError *error) {
            weakself.retryCount ++;
            if (completionHandler(weakself.retryCount,NO)){
                [weakself setDefaultConfigurationWithCompletionHandler:completionHandler];
            }else{
                [[MHTipsView shareInstance] hide];
            }
        }];
    }
}

//配置自动化失败弹窗处理
- (void)setDefaultConfigurationFailure{
    XM_WS(weakself);
    NSString *failureTitle = NSLocalizedStringFromTable(@"configuration.failed",@"plugin_gateway","配置失败");
    NSString *message = NSLocalizedStringFromTable(@"configuration.failed.tips",@"plugin_gateway",@"1.需将网关连接wifi\n2.需将手机连接wifi\n3.请保证wifi正常");
    NSString *cancel = NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway","取消");
    NSString *retry = NSLocalizedStringFromTable(@"retry",@"plugin_gateway",@"重试");
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:failureTitle message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *retry = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"retry",@"plugin_gateway",@"重试") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            weakself.retryCount = 0;
            [weakself setDefaultConfigurationWithDelay:0 completionHandler:nil];
        }];
        __weak typeof(self) weakself = self;
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway","取消") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            MHLumiRequestLogHelper *helper = [[MHLumiRequestLogHelper alloc] initWithType:MHLumiActivitiesTypeDouble11 andIdentifier:weakself.gateway.did];
            if (![helper isLogExisted]){
                [helper markToFailue];
            }
        }];
        [alert addAction:cancle];
        [alert addAction:retry];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:failureTitle message:message delegate:self cancelButtonTitle:cancel otherButtonTitles:retry, nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        self.retryCount = 0;
        [self setDefaultConfigurationWithDelay:0 completionHandler:nil];
    }else{
        MHLumiRequestLogHelper *helper = [[MHLumiRequestLogHelper alloc] initWithType:MHLumiActivitiesTypeDouble11 andIdentifier:self.gateway.did];
        if (![helper isLogExisted]){
            [helper markToFailue];
        }
    }
}


@end
