//
//  MHACPartnerMainViewController.m
//  MiHome
//
//  Created by ayanami on 16/5/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerMainViewController.h"
#import "MHACPartnerControlViewController.h"
#import "MHACPartnerDeviceListViewController.h"
#import "MHACPartnerSceneListViewController.h"
#import "MHDeviceAcpartner.h"
#import "MHGatewayTabView.h"
#import "MHGatewayAboutViewController.h"
#import "MHGatewayWebViewController.h"
#import "AppDelegate.h"
#import "MHGatewayMainpageAnimation.h"
#import "MHACPartnerSettingViewController.h"
#import "MHGatewayAddSubDeviceListController.h"
#import "MHGatewaySceneLogViewController.h"
#import "MHIFTTTEditViewController.h"
#import "MHIFTTTManager.h"
#import "MHLumiChooseLogoListManager.h"
#import "MHGatewayLogViewController.h"
#import "MHFeedbackDeviceDetailViewController.h"
#import "MHGatewayBindSceneManager.h"
#import "MHGatewayExtraSceneManager.h"
#import "MHACPartnerAddTipsViewController.h"
#import "MHGatewayAlarmSettingViewController.h"
#import "MHGatewayDoorBellSettingViewController.h"
#import "MHACPartnerDetailViewController.h"
#import "MHACPartnerTimerNewSettingViewController.h"
#import "MHACHistoryMatchViewController.h"
#import "MHACPartnerReMatchViewController.h"



@interface MHACPartnerMainViewController ()

@property (nonatomic, strong) MHDeviceAcpartner *acPartner;
@property (nonatomic, strong) MHACPartnerControlViewController *controlView;
@property (nonatomic, strong) MHACPartnerSceneListViewController *sceneList;
@property (nonatomic, strong) MHACPartnerDeviceListViewController *deviceList;
@property (nonatomic, strong) MHACPartnerDetailViewController *airControl;
@property (nonatomic, strong) UIViewController *oldVC;

@property (nonatomic, strong) MHGatewayTabView *tabView;
@property (nonatomic, strong) MHGatewayMainpageAnimation *animationTool;

@property (nonatomic, strong) UIPanGestureRecognizer *leftPan;
@property (nonatomic, strong) UIPanGestureRecognizer *rightPan;

@property (nonatomic, assign) NSInteger defaultIndex;

@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRight;
@property (nonatomic, assign) NSInteger currentIndex;
@end

@implementation MHACPartnerMainViewController

-(id)initWithDevice:(MHDevice *)device {
    if(self = [super initWithDevice:device]) {
        self.acPartner = (MHDeviceAcpartner*)device;
        [self.acPartner registerAppAndInit];
        [self.acPartner restoreACStatus];
        self.defaultIndex = 0;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isNavBarTranslucent = YES;
    [self loadStatus];
    [self getOtherStatus];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self redrawNavigationBar];
    //    if (![self isDisclaimerShown]) {
    //        _isShowingDisclaimer = YES;
    //        [self showDisclaimer];
    //    }
    
    //    [_deviceList startRefresh];
    //    [_sceneList loadIFTTTRecords];
    //    [self startRefresh];
    [self checkVersion];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.acPartner saveACStatus];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)applicationDidEnterBackground {
    
    [self.acPartner saveACStatus];
}


- (void)setDefaultBanner:(GatewayBannerType)headerType {
    
    self.defaultIndex = 1;
    
    NSString *key = [NSString stringWithFormat:@"%@%@",ACHeaderViewLastIndexKey,self.acPartner.did];
    [[NSUserDefaults standardUserDefaults] setObject:@(headerType) forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
}


- (void)buildSubviews {
    [super buildSubviews];
    
    XM_WS(weakself);
    
    CGRect tabRect = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds) * 0.6, 44);
    NSArray *tabTitleArray = @[
                               @{ @"name" : NSLocalizedStringFromTable(@"mydevice.gateway.mainpage.tab.title4", @"plugin_gateway", "空调"),
                                  @"color" : [UIColor colorWithWhite:1.f alpha:1.f] } ,
                               @{ @"name" : NSLocalizedStringFromTable(@"mydevice.gateway.mainpage.tab.title5", @"plugin_gateway", "网关"),
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
    if (self.defaultIndex) {
        [self.tabView selectItem:self.defaultIndex];
    }
    
    
    
    //动画
    _animationTool = [[MHGatewayMainpageAnimation alloc] init];
    _animationTool.homeVC = self;
    _animationTool.subViewArray = @[self.airControl.view, self.controlView.view,self.sceneList.view,self.deviceList.view];
    [_animationTool homeVCAddGestureRecognizer];
    _animationTool.leftAnimationEndCallBack = ^(){
        [weakself onBack:nil];
    };
    _animationTool.onClickCurrentIndex = ^(NSInteger index){
        [weakself.tabView selectItem:index];
    };
    
    
}


#pragma mark - tab view clicked 切换view
- (void)onTabClicked:(NSInteger)index {
    switch (index) {
        case 0:
            self.oldVC = [self moveControllerFrom:self.oldVC to:self.airControl];
            
            break;
        case 1:
            self.oldVC = [self moveControllerFrom:self.oldVC to:self.controlView];
            
            break;
        case 2:
            self.oldVC = [self moveControllerFrom:self.oldVC to:self.sceneList];
            
            break;
        case 3:
            self.oldVC = [self moveControllerFrom:self.oldVC to:self.deviceList];
            
            break;
        default:
            break;
    }
    _animationTool.currentIndex = index;
    [self redrawNavigationBar];
}


- (UIViewController *)moveControllerFrom:(UIViewController *)fromVC to:(UIViewController *)toVC {
    if (fromVC == toVC) {
        NSLog(@"相同的操作返回");
        return fromVC;
    }
    [self addChildViewController:toVC];
    [fromVC willMoveToParentViewController:nil];
    [self.view addSubview:toVC.view];
    toVC.view.hidden = NO;
    fromVC.view.hidden = YES;
    [fromVC removeFromParentViewController];
    [toVC didMoveToParentViewController:self];
    [fromVC.view removeFromSuperview];
    
    return toVC;
}

- (MHACPartnerControlViewController *)controlView {
    //    XM_WS(weakself);
    if (!_controlView) {
        //控制
        _controlView = [[MHACPartnerControlViewController alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT) acpartner:self.acPartner];
    }
    return _controlView;
}

- (MHACPartnerSceneListViewController *)sceneList {
    //    XM_WS(weakself);
    if (!_sceneList) {
        //自动化
        _sceneList = [[MHACPartnerSceneListViewController alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT) sensor:self.acPartner];
        
    }
    return _sceneList;
}


- (MHACPartnerDeviceListViewController *)deviceList {
    XM_WS(weakself);
    if (!_deviceList) {
        //设备列表
        _deviceList = [[MHACPartnerDeviceListViewController alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT) sensor:self.acPartner];
        _deviceList.deviceCountChange = ^{
            [weakself startRefresh];
        };
    }
    return _deviceList;
}


- (MHACPartnerDetailViewController *)airControl {
    if (!_airControl) {
        _airControl = [[MHACPartnerDetailViewController alloc] initWithAcpartner:self.acPartner];
    }
    return _airControl;
}

- (void)redrawNavigationBar {
    
    UIImage* leftImage = [[UIImage imageNamed:@"navi_back_black"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    if(!_tabView.currentIndex || _tabView.currentIndex == 1) {
        leftImage = [[UIImage imageNamed:@"navi_back_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        UIImage* imageMore = [[UIImage imageNamed:@"navi_more_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        if(self.acPartner.shareFlag == MHDeviceUnShared){
            UIBarButtonItem *rightItemMore = [[UIBarButtonItem alloc] initWithImage:imageMore
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self action:@selector(onMore:)];
            self.navigationItem.rightBarButtonItem = rightItemMore;
        }
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

#pragma mark - more btn
// 点击设备页面右上角(...)按钮后的响应函数
- (void)onMore:(id)sender {
    //。。。更多按钮，actionsheet
    XM_WS(weakself);
    
    if (_animationTool.currentIndex == 1) {
        NSString *title = NSLocalizedStringFromTable(@"mydevice.actionsheet.more",@"plugin_gateway","更多");
        
        NSMutableArray *objects = [NSMutableArray new];
        
        [objects addObject:[MHPromptKitObject objWithTitle:NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway",@"取消") isCancelBtn:YES isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
            
        }]];
        
        [objects addObject:[MHPromptKitObject objWithTitle:NSLocalizedStringFromTable(@"mydevice.gateway.about.tutorial",@"plugin_gateway","新手引導") isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
            NSString *strURL = kNewUserCN;
            [weakself openWebVC:strURL identifier:@"mydevice.gateway.about.tutorial" share:NO];
            [weakself gw_clickMethodCountWithStatType:@"ACPartnerTutorial"];
        }]];
        
        [[MHPromptKit shareInstance] showPromptInView:self.view withTitle:title withObjects:objects];
        
    }
    else {
        
        NSString *strTimer = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.timer.title",@"plugin_gateway","空调定时");
        NSString* strNew = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.more.newir",@"plugin_gateway","重新匹配空调");
        NSString* strSetting = NSLocalizedStringFromTable(@"mydevice.gateway.about.freFAQ",@"plugin_gateway","常见问题");
        NSString* strChangeTitle = NSLocalizedStringFromTable(@"mydevice.actionsheet.changename",@"plugin_gateway","修改设备名称");
        NSString* strShare = NSLocalizedStringFromTable(@"mydevice.actionsheet.share",@"plugin_gateway","设备共享");
        //    NSString* strNew = NSLocalizedStringFromTable(@"mydevice.gateway.about.tutorial",@"plugin_gateway","新手引導");
        NSString* strAbout = NSLocalizedStringFromTable(@"mydevice.gateway.about.titlesettingcell",@"plugin_gateway","关于");
        NSString* strUpgrade = NSLocalizedStringFromTable(@"mydevice.actionsheet.upgrade",@"plugin_gateway","检查固件升级");
        NSString* strFeedback = NSLocalizedStringFromTable(@"mydevice.actionsheet.feedback",@"plugin_gateway","反馈");
        NSString* strLife = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.actionsheet.life",@"plugin_gateway","生活场景");
        NSString* cancel = NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway",@"取消");
        NSString *title = NSLocalizedStringFromTable(@"mydevice.actionsheet.more",@"plugin_gateway","更多");
        
        
        NSMutableArray *objArray = [NSMutableArray array];
        XM_WS(weakself);
        
        [objArray addObject:[MHPromptKitObject objWithTitle:strTimer isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
            //空调定时
            MHACPartnerTimerNewSettingViewController *tVC = [[MHACPartnerTimerNewSettingViewController alloc] initWithDevice:weakself.acPartner andIdentifier:kACPARTNERTIMERID];
            tVC.title = strTimer;
            tVC.controllerIdentifier = kACPARTNERTIMERID;
            [weakself.navigationController pushViewController:tVC animated:YES];
            [weakself gw_clickMethodCountWithStatType:@"openACPartnerTimerSetting"];
        }]];
        
        [objArray addObject:[MHPromptKitObject objWithTitle:strNew isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
            //重新匹配
            MHACPartnerReMatchViewController *rematchVC = [[MHACPartnerReMatchViewController alloc] initWithAcpartner:weakself.acPartner type:REMACTCH_INDEX];
            [weakself.navigationController pushViewController:rematchVC animated:YES];
            
            [weakself gw_clickMethodCountWithStatType:@"openACPartnerRemactchPage"];
        }]];
        
        [objArray addObject:[MHPromptKitObject objWithTitle:strSetting isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
            //常见问题
            MHFeedbackDeviceDetailViewController *detailVC = [MHFeedbackDeviceDetailViewController new];
            detailVC.category = Device;
            detailVC.device = weakself.acPartner;
            [weakself.navigationController pushViewController:detailVC animated:YES];
            [weakself gw_clickMethodCountWithStatType:@"openACPartnerFreFAQ"];
        }]];
        
        [objArray addObject:[MHPromptKitObject objWithTitle:strChangeTitle isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
            //重命名
            [weakself gw_clickMethodCountWithStatType:@"ChangeName"];
            [weakself deviceChangeName];
        }]];
        
        [objArray addObject:[MHPromptKitObject objWithTitle:strShare isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
            //分享
            [weakself gw_clickMethodCountWithStatType:@"Share"];
            [weakself deviceShare];
        }]];
        
        [objArray addObject:[MHPromptKitObject objWithTitle:strAbout isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
            [weakself gw_clickMethodCountWithStatType:@"about"];
            MHGatewayAboutViewController *about = [[MHGatewayAboutViewController alloc] init];
            about.gatewayDevice = weakself.acPartner;
            [weakself.navigationController pushViewController:about animated:YES];
        }]];
        
        [objArray addObject:[MHPromptKitObject objWithTitle:strUpgrade isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
            //固件升级
            [weakself gw_clickMethodCountWithStatType:@"UpgradePage"];
            [weakself onDeviceUpgradePage];
        }]];
        
        [objArray addObject:[MHPromptKitObject objWithTitle:strFeedback isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
            //反馈
            [weakself gw_clickMethodCountWithStatType:@"Feedback"];
            [weakself onFeedback];
        }]];
        
        [objArray addObject:[MHPromptKitObject objWithTitle:strLife isCancelBtn:YES isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
            //生活场景
            [weakself openWebVC:kAC_SCENE_URL identifier:@"mydevice.gateway.sensor.acpartner.actionsheet.life" share:NO];
            [weakself gw_clickMethodCountWithStatType:@"openACPartnerLifeScene"];
        }]];
        
        [objArray addObject:[MHPromptKitObject objWithTitle:cancel isCancelBtn:YES isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
            
        }]];
        
        [[MHPromptKit shareInstance] showPromptInView:self.view withTitle:title withObjects:objArray];
    }
}

- (void)openWebVC:(NSString *)strURL identifier:(NSString *)identifier share:(BOOL)share{
    MHGatewayWebViewController *web = [MHGatewayWebViewController openWebVC:strURL identifier:identifier share:share];
    [self.navigationController pushViewController:web animated:YES];
}

- (void)startRefresh {
    [self.controlView startRefresh];
}
#pragma mark : - check version
- (void)checkVersion {
    XM_WS(weakself);
    [self.acPartner versionControl:^(NSInteger retcode){
        if (retcode == -2){
            [weakself onDeviceUpgradePage];
        }
    }];
}

#pragma mark - loadstatus
- (void)loadStatus {
    //    [self startRefresh];
    NSDictionary *params = [self.acPartner getStatusRequestPayload];
    [self.acPartner sendPayload:params success:nil failure:nil];
    [self.acPartner getProperty:ARMING_DELAY_INDEX success:nil failure:nil];
    
    
    [self.acPartner getACTypeListSuccess:^(id obj) {
        
    } Failure:^(NSError *v) {
        
    }];
    
    
    [self.acPartner getCommandMapSuccess:^(id obj) {
        
    } failure:^(NSError *v) {
        
    }];
}

#pragma mark :- 其它状态
- (void)getOtherStatus {
    XM_WS(weakself);
    __block MHSafeDictionary *tempDic = [[MHSafeDictionary alloc] init];
    [self.acPartner.subDevices enumerateObjectsUsingBlock:^(MHDeviceGatewayBase *sensor, NSUInteger idx, BOOL *stop) {
        sensor.parent = weakself.acPartner;
        NSString *name = sensor.name;
        [tempDic setObject:name forKey:sensor.did];
    }];
    //网关时间可能did是网关的did导致取不到子设备名字
    [tempDic setObject:@"小米多功能网关" forKey:self.acPartner.did];
    self.acPartner.logManager.deviceNames = tempDic;
    
    
    [[MHGatewayBindSceneManager sharedInstance] fetchBindSceneList:self.acPartner withSuccess:nil];
    [[MHGatewayExtraSceneManager sharedInstance] fetchExtraMapTableWithSuccess:nil failure:nil];
    
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
