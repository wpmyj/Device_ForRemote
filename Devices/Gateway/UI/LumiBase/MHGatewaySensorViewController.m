//
//  MHGatewaySensorViewController.m
//  MiHome
//
//  Created by Woody on 15/4/9.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import "MHGatewaySensorViewController.h"
#import "MHGatewayTabView.h"
#import "MHGatewayLogListManager.h"
#import "MHDeviceGateway.h"
#import "MHWebViewController.h"
#import "MHGatewayScensView.h"
#import "MHIFTTTEditViewController.h"
#import "MHTableViewControllerInternal.h"
#import "MHGatewayLogCell.h"
#import "MHLumiChooseLogoListManager.h"
#import "MHDeviceGatewaySensorNatgas.h"
#import "MHGatewayNatgasSettingViewController.h"

#define ASTag_More  10000
#define ASTag_Lowbattery 10001

@interface MHGatewaySensorViewController() <UIGestureRecognizerDelegate,MHTableViewControllerInternalDelegate,UIAlertViewDelegate,UIActionSheetDelegate>
@property (nonatomic,strong) MHDeviceGatewayBase *sensor;
@property (nonatomic,strong) MHGatewayScensView *sceneTableView;
@property (nonatomic,strong) MHTableViewControllerInternal* logTvcInternal;
@property (nonatomic,strong) MHDataListManagerBase* dataManager;
@property (nonatomic, assign) BOOL showChangeLogo;
@end

@implementation MHGatewaySensorViewController {
    MHDeviceGatewayBase*        _sensor;
    BOOL                        _canShowLog;
    
    MHGatewayTabView*           _tabView;     //等添加了联动后，再重新打开
    UIView*                     _footerView;
    UIButton*                   _btnFooter;
    UILabel*                    _labelFooter;
    UIActionSheet*              _actionSheet;
    
    id                          _observer;
}

- (id)initWithDevice:(MHDevice *)device {
    if (self = [super initWithDevice:device]) {
        _sensor = (MHDeviceGatewayBase* )device;
        self.sensor = _sensor;
        self.dataManager = _sensor.logManager;
        _canShowLog = YES;
        NSString *sensorModel = [_sensor modelCutVersionCode:_sensor.model];
        if ( [sensorModel isEqualToString:[_sensor modelCutVersionCode:DeviceModelgateWaySensorPlug]] ||
             [sensorModel isEqualToString:[_sensor modelCutVersionCode:DeviceModelgatewaySensorHt]] ||
             [sensorModel isEqualToString:[_sensor modelCutVersionCode:DeviceModelgatewaySencorCtrlNeutral1V1]] ||
             [sensorModel isEqualToString:[_sensor modelCutVersionCode:DeviceModelgatewaySencorCtrlNeutral2V1]] ||
            [sensorModel isEqualToString:[_sensor modelCutVersionCode:DeviceModelgateWaySensor86PlugV1]] ||
            [sensorModel isEqualToString:[_sensor modelCutVersionCode:DeviceModelgateWaySensorCtrlLn1V1]] ||
            [sensorModel isEqualToString:[_sensor modelCutVersionCode:DeviceModelgateWaySensorCtrlLn2V1]]
            ) {
            _canShowLog = NO;
        }
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (BOOL)needGetDeviceStatus {
    return NO;
}

- (void)dealloc {
    NSLog(@"ddd");
}

- (void)setDataManager:(MHDataListManagerBase *)dataManager {
    if ([dataManager isEqual:_dataManager]) {
        return;
    }
    
    _dataManager = dataManager;
    self.logTvcInternal.dataSource = [dataManager getDataList];
    
    // 注册UIUpdateNotification
    NSString* notifName = [_dataManager notificationNameForUIUpdate];
    NSNotificationCenter* notifCenter = [NSNotificationCenter defaultCenter];
    if (_observer) {
        [notifCenter removeObserver:_observer];
        _observer = nil;
    }
    
    XM_WS(weakself);
    _observer = [notifCenter addObserverForName:notifName
                                         object:nil
                                          queue:[NSOperationQueue mainQueue]
                                     usingBlock:^(NSNotification *note) {
                                         weakself.logTvcInternal.dataSource = [dataManager getDataList];
                                         [weakself.logTvcInternal stopRefreshAndReload];
                                         [weakself onDataSourceUpdated];
                                     }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchLoglist];
    
    _showChangeLogo = [[MHLumiChooseLogoListManager sharedInstance] isShowLogoListWithandDeviceModel:self.sensor.model finish:nil];
}

-(void)fetchLoglist{
    //刷新
    MHGatewayLogListManager* logManager = (MHGatewayLogListManager*)self.dataManager;
    [logManager getLatestLogWithSuccess:nil failure:nil];
    [_sensor getBatteryWithSuccess:nil failure:nil];
    
    if (self.openedFromPush){
        [self onLowBatteryClicked];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(self.sceneTableView){
        [self.sceneTableView fetchRecordData];
    }
}

- (void)buildSubviews {
    [super buildSubviews];
    
    XM_WS(weakself);
    self.title = _sensor.name;
    self.controllerIdentifier = NSStringFromClass([_sensor class]);
    self.isTabBarHidden = YES;
    
    //Tab view
    NSArray *tabTitleArray = [NSArray arrayWithObjects:NSLocalizedStringFromTable(@"mydevice.gateway.scene",@"plugin_gateway","自动化"), NSLocalizedStringFromTable(@"mydevice.gateway.log",@"plugin_gateway","日志"), nil];
    CGRect tabRect = CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), 45);
    _tabView = [[MHGatewayTabView alloc] initWithFrame:tabRect titleArray:tabTitleArray callback:^(NSInteger idx) {
        [weakself onTabClicked:idx];
    }];
    _tabView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_tabView];
    if(!_canShowLog){
        _tabView.hidden = YES;
    }

    //Footer view
    [self buildFooterView];

    CGRect tableRect = CGRectMake(0, 64 + CGRectGetHeight(_tabView.frame),
                                  CGRectGetWidth(self.view.frame),
                                  CGRectGetMinY(_footerView.frame) - 64 - CGRectGetHeight(_tabView.frame));
    if(!_canShowLog){
        tableRect = CGRectMake(0, 64,
                               CGRectGetWidth(self.view.frame),
                               CGRectGetMinY(_footerView.frame) - 64);
    }
    self.sceneTableView = [[MHGatewayScensView alloc] initWithFrame:tableRect andDevices:_sensor];
    [self.view addSubview:self.sceneTableView];
    self.sceneTableView.onSelectedScene = ^(id scene){
        [weakself onFooterBtnClicked:scene];
    };
    self.sceneTableView.onSelectedRecom = ^(id recom){
        [weakself onFooterBtnClicked:recom];
    };
    
    [self.sceneTableView setOfflineRecord:^(MHDataIFTTTRecord *record) {
        [weakself offlineClicked:record];
    }];

    if (self.logTvcInternal == nil) {
        self.logTvcInternal = [[MHTableViewControllerInternal alloc] initWithStyle:UITableViewStylePlain];
    }
    self.logTvcInternal.cellClass = [MHGatewayLogCell class];
    self.logTvcInternal.delegate = self;
    self.dataManager = _sensor.logManager;
    self.logTvcInternal.dataSource = [self.dataManager getDataList];
    [self.logTvcInternal.view setFrame:tableRect];
    [self.view addSubview:self.logTvcInternal.view];
    self.logTvcInternal.view.hidden = YES;
    [self.logTvcInternal pullDownToRefresh];
    
    if(_canShowLog){
        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
        [swipeRight setDirection:(UISwipeGestureRecognizerDirectionRight)];
        [self.view addGestureRecognizer:swipeRight];
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
        [swipeLeft setDirection:(UISwipeGestureRecognizerDirectionLeft)];
        [self.view addGestureRecognizer:swipeLeft];
    }
}

- (void)buildFooterView {
    _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 65,
                                                           CGRectGetWidth(self.view.bounds), 65)];
    _footerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_footerView];
    
    _btnFooter = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(_footerView.frame) - 28) / 2.f, 5, 28, 28)];
    [_btnFooter addTarget:self action:@selector(onFooterBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_btnFooter setBackgroundImage:[UIImage imageNamed:@"device_addtimer"] forState:UIControlStateNormal];
    [_footerView addSubview:_btnFooter];

    _labelFooter = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_btnFooter.frame) + 5, CGRectGetWidth(_footerView.frame), 11)];
    _labelFooter.font = [UIFont systemFontOfSize:11];
    _labelFooter.textColor = [MHColorUtils colorWithRGB:0x0 alpha:0.4];
    _labelFooter.textAlignment = NSTextAlignmentCenter;
    _labelFooter.text = NSLocalizedStringFromTable(@"mydevice.gateway.scene.add",@"plugin_gateway","添加自动化");
    [_footerView addSubview:_labelFooter];
    
    if(_tabView.currentIndex){
        [_btnFooter setBackgroundImage:[UIImage imageNamed:@"gateway_log_delete"] forState:UIControlStateNormal];
        _labelFooter.text = NSLocalizedStringFromTable(@"mydevice.gateway.log.clear",@"plugin_gateway","清空日志");
        _btnFooter.enabled = [self.dataManager getDataListCount] > 0;
    }
    else{
        [_btnFooter setBackgroundImage:[UIImage imageNamed:@"device_addtimer"] forState:UIControlStateNormal];
        _labelFooter.text = NSLocalizedStringFromTable(@"mydevice.gateway.scene.add",@"plugin_gateway","添加自动化");
        _btnFooter.enabled = YES;
    }
}

- (void)swiped:(UISwipeGestureRecognizer *)sender{
    NSInteger total = _tabView.titleArray.count;
    NSInteger current = _tabView.currentIndex;
    NSInteger next = 0;
    
    if (sender.direction==UISwipeGestureRecognizerDirectionLeft) {
        next = current + 1;
    }
    else if (sender.direction==UISwipeGestureRecognizerDirectionRight) {
        next = current - 1;
    }

    if(next >= total) next = total - 1;
    else if (next < 0) next = 0;
    [_tabView selectItem:next];
}

- (void)onTabClicked:(NSInteger)idx {

    CATransition *animation = [[CATransition alloc] init];
    animation.duration = 0.4;
    animation.timingFunction = [ CAMediaTimingFunction  functionWithName: kCAMediaTimingFunctionEaseInEaseOut ];
    animation.type = kCATransitionPush;
    
    if(idx == 0){
        animation.subtype = kCATransitionFromLeft;
        [self.sceneTableView.layer addAnimation:animation forKey:nil];
        self.sceneTableView.hidden = NO;
        [self.logTvcInternal.view.layer addAnimation:animation forKey:nil];
        self.logTvcInternal.view.hidden = YES;
    }
    else{
        animation.subtype = kCATransitionFromRight;
        [self.sceneTableView.layer addAnimation:animation forKey:nil];
        self.sceneTableView.hidden = YES;
        [self.logTvcInternal.view.layer addAnimation:animation forKey:nil];
        self.logTvcInternal.view.hidden = NO;
    }
    [self buildFooterView];

    [self gw_clickMethodCountWithStatType:[NSString stringWithFormat:@"onTabClicked:%ld",(long)idx]];
}

-(void)onFooterBtnClicked:(id)sender{
    if(_sensor.shareFlag == MHDeviceShared){
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.timersetting.noright", @"plugin_gateway", "被分享设备无此权限") duration:1.0 modal:NO];
        return;
    }
    else{
        if(_tabView.currentIndex){
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.gateway.log.clear.alert.title",@"plugin_gateway","是否清空所有记录") message:nil delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"plugin_gateway",@"取消") otherButtonTitles:NSLocalizedStringFromTable(@"Ok",@"plugin_gateway", "确定"), nil];
            [alertView show];
            [self gw_clickMethodCountWithStatType:@"onDeleteLogs:"];
        }
        else{
            MHDataIFTTTRecord *selectedRecord = nil;
            
            if([sender isKindOfClass:NSClassFromString(@"MHDataIFTTTRecord")]){
                selectedRecord = sender;
            }
            else if([sender isKindOfClass:NSClassFromString(@"MHDataIFTTTRecomRecord")]){
                selectedRecord = [sender bestFitRecord];
            }
            
            MHIFTTTEditViewController* editVC = [MHIFTTTEditViewController new];
            if(sender && ![sender isKindOfClass:[UIButton class]]) editVC.record = selectedRecord;
            if([self.sensor isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorPlug")] ||
               [self.sensor isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorDoubleNeutral")] ||
               [self.sensor isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorSingleNeutral")] ||
               [self.sensor isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorWithNeutralDual")] ||
               [self.sensor isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorWithNeutralSingle")] ||
               [self.sensor isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorCassette")]){
                editVC.qualifiedDidForAction = self.sensor.did;
            }
            else{
                editVC.qualifiedDidForTrigger = self.sensor.did;
            }
            __weak typeof(self) ws = self;
            editVC.editCompletion = ^(MHDataIFTTTRecord *record) {
                [[MHIFTTTManager sharedInstance].recordList addObject:record];
                [ws.navigationController popToViewController:ws animated:YES];
            };
            editVC.recordDeleted = ^(MHDataIFTTTRecord* record) {
                [ws.navigationController popToViewController:ws animated:YES];
            };
            [self.navigationController pushViewController:editVC animated:YES];
        }
    }
    [self gw_clickMethodCountWithStatType:@"onAddScene:"];
}

- (void)onDeleteLogsFinished {
    _btnFooter.enabled = YES;
}

- (void)onLowBatteryClicked {
    NSString* strTitle = [NSString stringWithFormat:@"%@", NSLocalizedStringFromTable(@"mydevice.gateway.sensor.battery.info",@"plugin_gateway","电池信息")];
    NSString* strMessage = [NSString stringWithFormat:@"%@%d%%\r\n%@%@", NSLocalizedStringFromTable(@"mydevice.gateway.sensor.battery.left",@"plugin_gateway","剩余电量："), (int)_sensor.battery, NSLocalizedStringFromTable(@"mydevice.gateway.sensor.battery.kind",@"plugin_gateway","型号:纽扣电池"), [[_sensor class] getBatteryCategory]];
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:strTitle message:strMessage delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.battery.changeguide",@"plugin_gateway","换电池教程"), NSLocalizedStringFromTable(@"iknow",@"plugin_gateway","知道了"), nil];
    alertView.tag = ASTag_Lowbattery;
    [alertView show];
}

- (BOOL)isAllowedToCheckUpgrade {
    return NO;
}

#pragma mark - MHTableViewControllerInternalDelegate
- (void)startRefresh {
    [self.dataManager refresh:20];
}

- (void)startGetmore
{
    if ([self.dataManager hasNextPage]) {
        [self.dataManager loadNextPage:20];
    } else {
        [[MHTipsView shareInstance] showFinishTips:NSLocalizedStringFromTable(@"mydevice.gateway.log.allload",@"plugin_gateway","已加载全部日志") duration:1.0f modal:NO];
    }
}

- (void)onDataSourceUpdated {
    if(_tabView.currentIndex){
        _btnFooter.enabled = [self.dataManager getDataListCount] > 0;
    }
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


#pragma mark - 设备控制相关
- (void)onMore:(id)sender {
    
    XM_WS(weakself);
    NSString *title = NSLocalizedString(@"mydevice.actionsheet.more","更多");
    
    NSMutableArray *objects = [NSMutableArray new];
    
    [objects addObject:[MHPromptKitObject objWithTitle:NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway",@"取消") isCancelBtn:YES isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
      
    }]];
    
    if (_showChangeLogo)
    {
        [objects addObject:[MHPromptKitObject objWithTitle:NSLocalizedStringFromTable(@"mydevice.actionsheet.changelogo", @"plugin_gateway", @"更换图标") isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
            [weakself chooseLogo];
            [weakself gw_clickMethodCountWithStatType:@"actionSheetChangeLogo"];
        }]];
    }
    
    {
        [objects addObject:[MHPromptKitObject objWithTitle:NSLocalizedStringFromTable(@"mydevice.actionsheet.changename",@"plugin_gateway","重命名") isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
            [weakself deviceChangeName];
            [weakself gw_clickMethodCountWithStatType:@"actionSheetChangeName"];
        }]];
    }
    
    {
        NSString* strShowMode = _sensor.showMode ? NSLocalizedStringFromTable(@"mydevice.gateway.delsub.rmvlist",@"plugin_gateway","撤销显示") : NSLocalizedStringFromTable(@"mydevice.gateway.delsub.addlist",@"plugin_gateway","添加显示");
        
        [objects addObject:[MHPromptKitObject objWithTitle:strShowMode isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
            //设置列表显示
            [weakself.sensor setShowMode:(int)!weakself.sensor.showMode success:nil failure:^(NSError *error){
                [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"setting.failed", @"plugin_gateway","") duration:1.f modal:YES];
            }];
            [weakself gw_clickMethodCountWithStatType:@"actionSheetShowMode"];
        }]];
    }
    
    if([self.sensor isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorMagnet")] ||
       [self.sensor isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorMotion")] ||
       [self.sensor isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorSwitch")])
    {
        NSString *strFAQ = NSLocalizedStringFromTable(@"mydevice.gateway.about.freFAQ",@"plugin_gateway","常见问题");
        [objects addObject:[MHPromptKitObject objWithTitle:strFAQ isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
            //常见问题
            [weakself openFAQ:[[weakself.sensor class] getFAQUrl]];
            [weakself gw_clickMethodCountWithStatType:@"actionSheetFAQ"];
        }]];
    }
    
    {
        NSString* strFeedback = NSLocalizedStringFromTable(@"mydevice.actionsheet.feedback",@"plugin_gateway","反馈");
        [objects addObject:[MHPromptKitObject objWithTitle:strFeedback isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
            [weakself onFeedback];
            [weakself gw_clickMethodCountWithStatType:@"actionSheetFeedback"];
        }]];
    }
    
    [[MHPromptKit shareInstance] showPromptInView:self.view withTitle:title withObjects:objects];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    XM_WS(weakself);
    if (alertView.tag == ASTag_Lowbattery) {
        switch (buttonIndex) {
            case 0: {
                //换电池教程
                NSURL* faqURL = [NSURL URLWithString:[[_sensor class] getBatteryChangeGuideUrl]];
                MHWebViewController* faqVC = [[MHWebViewController alloc] initWithURL:faqURL];
                [self.navigationController pushViewController:faqVC animated:YES];
                break;
            }
            case 1: {
                //知道了
                if (self.openedFromPush) {
                    [_sensor.parent disAlarmWithSuccess:nil failure:nil];
                }
                break;
            }
            default:
                break;
        }
    }
    else{
        switch (buttonIndex) {
            case 1: {
                //确定
                _btnFooter.enabled = NO;
                [(MHGatewayLogListManager*)self.dataManager deleteAllLogsWithSuccess:^(id obj) {
                    [weakself onDeleteLogsFinished];
                } failure:^(NSError * error) {
                    [weakself onDeleteLogsFinished];
                }];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - change logo 
- (void)chooseLogo {
    [self.sensor buildServices];
    if(self.sensor.services.count){
        MHDeviceGatewayBaseService *service = self.sensor.services[0];
        [[MHLumiChooseLogoListManager sharedInstance] chooseLogoWithSevice:service iconID:service.serviceIconId titleIdentifier:service.serviceName segeViewController:self];
    }
}

@end
