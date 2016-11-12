//
//  MHGatewaySceneLogViewController.m
//  MiHome
//
//  Created by guhao on 16/5/17.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewaySceneLogViewController.h"
#import "MHIFTTTManager.h"
#import "MHPromptKit.h"
#import "MHGatewaySceneLogDataManager.h"
#import "MHGatewaySceneMenuView.h"
#import "MHGatewayCalendarView.h"
#import "MHGatewaySceneLogFooterView.h"
#import <MJRefresh/MJRefresh.h>
#import "MHGatewaySceneTitleView.h"
#import "MHIFTTTEditViewController.h"
#import "MHGatewaySceneLogCategoryCell.h"
#import "MHGatewaySceneLogContentCell.h"
#import "MHGatewayLightTimerSettingViewController.h"
#import "MHGatewaySetAlarmClockViewController.h"
#import "MHGatewayAlarmClockTimerNewViewController.h"
#import "MHGatewayTimerSettingNewViewController.h"
#import "MHDeviceGatewaySensorSwitch.h"
#import "MHDeviceGatewaySensorMotion.h"
#import "MHDeviceGatewaySensorMagnet.h"
#import "MHDeviceGatewaySensorCube.h"
#import "MHGatewayClockControlSettingViewController.h"
#import "MHGatewayLightSettingViewController.h"
#import "MHPromptKit.h"
#import "MHGatewayTimerSettingNewViewController.h"
#import "MHDeviceGatewaySensorPlug.h"
#import "MHDeviceGatewaySensorSingleNeutral.h"
#import "MHDeviceGatewaySensorDoubleNeutral.h"
#import "MHGatewaySceneManager.h"
#import "MHDataScene.h"
#import "MHACPartnerTimerNewSettingViewController.h"
#import "MHGatewayLinkAlarmViewController.h"

#define kNightTimerIdentifier               @"lumi_gateway_single_rgb_timer"
#define kAlarmTimerIdentifier               @"lumi_gateway_arming_timer"
#define kClockTimerIdentifier               @"lumi_gateway_clock_timer"
#define kAlarmMotionIdentifier              @"lm_scene_1_1"
#define kAlarmMagnetTimerIdentifier         @"lm_scene_1_2"
#define kAlarmSwitchTimerIdentifier         @"lm_scene_1_3"
#define kAlarmCubeTimerIdentifier           @"lm_scene_1_4"
#define kDoorbellMotionTimerIdentifier      @"lm_scene_3_1"
#define kDoorbellMagnetTimerIdentifier      @"lm_scene_3_2"
#define kDoorbellSwitchTimerIdentifier      @"lm_scene_3_3"
#define kNightLightMotionTimerIdentifier    @"lm_scene_2_1"
#define kCloseClockMotionTimerIdentifier    @"lm_scene_4_1"
#define kCloseClockMagnetTimerIdentifier    @"lm_scene_4_2"
#define kCloseClockSwitchTimerIdentifier    @"lm_scene_4_3"


@interface MHGatewaySceneLogViewController ()<MHGatewaySceneMenuViewDelegate>

@property (nonatomic, strong) MHDeviceGateway *gateway;
@property (nonatomic, strong) MHGatewaySceneLogFooterView *footerView;
@property (nonatomic, strong) MHGatewayCalendarView *calendarView;
@property (nonatomic, strong) MHGatewaySceneMenuView *menuView;

@property (nonatomic, strong) MHGatewaySceneTitleView *sceneTitleView;

@property (nonatomic, strong) UIView *buildNoDeviceMessageView;

@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, assign) BOOL isFoundDate;

@property (nonatomic, retain) NSMutableArray *deviceDids;
@property (nonatomic, retain) NSMutableArray *allDids;
@property (nonatomic, strong) id seletedDid;

@property (nonatomic,strong) MHDeviceGatewaySensorPlug *devicePlug;
@property (nonatomic, strong) MHDeviceGatewaySensorSingleNeutral *deviceSingleNetural;
@property (nonatomic, strong) MHDeviceGatewaySensorDoubleNeutral *deviceNeutral;
@property (nonatomic, assign) NSInteger neutralTimerIndex;




@end

@implementation MHGatewaySceneLogViewController

- (id)initWithGateway:(MHDeviceGateway *)gateway
{
    self = [super init];
    if (self) {
        self.gateway = gateway;
        [self loadDeviceDids];
    }
    return self;
}

- (void)loadDeviceDids {
    self.deviceDids = [NSMutableArray new];
    self.allDids = [NSMutableArray new];
    [self.allDids addObject:self.gateway.did];
    for (MHDeviceGatewayBase *subDevice in self.gateway.subDevices) {
        [self.allDids addObject:subDevice.did];
        NSMutableDictionary *tempDic = [NSMutableDictionary new];
        [tempDic setObject:subDevice.name forKey:@"name"];
        [tempDic setObject:subDevice.did forKey:@"did"];
        [self.deviceDids addObject:tempDic];
    }

    [self.deviceDids insertObject:@{ @"name":NSLocalizedStringFromTable(@"ifttt.scene.local.scene.log.title", @"plugin_gateway", "所有設備"), @"did": self.allDids } atIndex:0];
    [self.deviceDids insertObject:@{ @"name":self.gateway.name, @"did": self.gateway.did } atIndex:1];
    self.seletedDid = self.allDids;
    
   MHGatewaySceneLogDataManager *logManager = [MHGatewaySceneLogDataManager sharedInstance];
    logManager.deviceDid = [NSString stringWithFormat:@"%@%@",kALLDEVICE, self.gateway.did ];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"loading", @"plugin_gateway", nil) modal:NO];

    XM_WS(weakself);
    self.isTabBarHidden = YES;
    //读取缓存
    [[MHGatewaySceneLogDataManager sharedInstance] restoreLogListWithFinish:^(id obj) {
        if ([obj isKindOfClass:[NSArray class]] && [obj count] > 0) {
            [[MHTipsView shareInstance] hide];
            [weakself updateTableView];
        }
    }];

    
    //titleview
    self.sceneTitleView = [[MHGatewaySceneTitleView alloc] initWithFrame:CGRectMake(0, 0, 220, 44)];
    self.sceneTitleView.chooseDeviceClick = ^{
        [weakself onDeviceMenu];
    };
    self.navigationItem.titleView = self.sceneTitleView;
    
    
    MJRefreshNormalHeader *refreshHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(pullDownLoadNewData)];
    refreshHeader.lastUpdatedTimeLabel.hidden = YES;
    self.expandableTable.mj_header = refreshHeader;
    
    [refreshHeader setTitle:NSLocalizedStringFromTable(@"ifttt.scene.local.scene.log.refresh.stateidle", @"plugin_gateway", "下拉刷新") forState:MJRefreshStateIdle];
   
    [refreshHeader setTitle:NSLocalizedStringFromTable(@"ifttt.scene.local.scene.log.refresh.pulling", @"plugin_gateway", "松开立即刷新") forState:MJRefreshStatePulling];
     [refreshHeader setTitle:NSLocalizedStringFromTable(@"ifttt.scene.local.scene.log.refresh.refreshing", @"plugin_gateway", "加载中") forState:MJRefreshStateRefreshing];

    
    MJRefreshAutoNormalFooter *refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(pullUpLoadNewData)];
    refreshFooter.automaticallyHidden = YES;
    self.expandableTable.mj_footer = refreshFooter;
    [refreshFooter setTitle:@"" forState:MJRefreshStateIdle];
    [refreshFooter setTitle:NSLocalizedStringFromTable(@"ifttt.scene.local.scene.log.refresh.refreshing", @"plugin_gateway", "加载中") forState:MJRefreshStateRefreshing];

    
    //    self.tvcInternal.cellClass = [MHIFTTTLogCategoryCell class];
    //    self.tvcInternal.rowHeight = 70.0;
    //    self.tvcInternal.delegate = self;
    //    self.tvcInternal.tableView.allowsSelection = NO;
    //    [self.tvcInternal pullDownToRefresh];
    
    // UI config
    [self.expandableTable registerClass:[MHGatewaySceneLogCategoryCell class] forCellReuseIdentifier:kExpandableCategoryCellID];
    [self.expandableTable registerClass:[MHGatewaySceneLogContentCell class] forCellReuseIdentifier:kExpandableContentCellID];
    self.expandableTable.rowHeight = 70.0;
    

    [[MHGatewaySceneLogDataManager sharedInstance] getExecuteHistoryWithDeviceDids:self.allDids Success:^{
        [weakself updateTableView];
        [[MHTipsView shareInstance] hide];
    } failure:^{
        [weakself updateTableView];
        [[MHTipsView shareInstance] hide];
    }];
    
    [[MHIFTTTManager sharedInstance] getAllRecordsCompletion:^(NSArray *v) {
        
    }];
    
}

- (void)pullDownLoadNewData {
    XM_WS(weakself);
    NSArray *deviceDids = [self.seletedDid isKindOfClass:[NSArray class]] ? self.seletedDid : @[ self.seletedDid ];
    [[MHGatewaySceneLogDataManager sharedInstance] getExecuteHistoryWithDeviceDids:deviceDids Success:^{
        [weakself updateTableView];
        [[MHTipsView shareInstance] hide];
        [weakself.expandableTable.mj_header endRefreshing];
    } failure:^{
        [weakself updateTableView];
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"loading.failed", @"plugin_gateway", nil) duration:1.5f modal:NO];
        [weakself.expandableTable.mj_header endRefreshing];
    }];
}
- (void)pullUpLoadNewData {
    XM_WS(weakself);
    NSArray *deviceDids = [self.seletedDid isKindOfClass:[NSArray class]] ? self.seletedDid : @[ self.seletedDid ];
    [[MHGatewaySceneLogDataManager sharedInstance] getMoreExecuteHistoryWithDeviceDids:deviceDids Success:^{
        [weakself updateTableView];
        [[MHTipsView shareInstance] hide];
        [weakself.expandableTable.mj_footer endRefreshing];
        
    } failure:^{
        [weakself updateTableView];
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"loading.failed", @"plugin_gateway", nil) duration:1.5f modal:NO];
        [weakself.expandableTable.mj_footer endRefreshing];
    }];
}

- (void)getSpecifiedTimeData {
    XM_WS(weakself);
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"loading", @"plugin_gateway", nil) modal:NO];
    NSArray *deviceDids = [self.seletedDid isKindOfClass:[NSArray class]] ? self.seletedDid : @[ self.seletedDid ];
    [[MHGatewaySceneLogDataManager sharedInstance] getExecuteHistoryWithDeviceDids:deviceDids date:self.currentDate success:^{
        [weakself updateTableView];
        [[MHTipsView shareInstance] hide];

    } failure:^{
        [weakself updateTableView];
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"loading.failed", @"plugin_gateway", nil) duration:1.5f modal:NO];

    }];
}

- (void)buildSubviews {
    [super buildSubviews];
    XM_WS(weakself);
    


    
    //点击跳转到指定日期
    self.footerView = [[MHGatewaySceneLogFooterView alloc] init];
    self.footerView.selectDateClick = ^{
        
        [weakself.calendarView showViewInView:[UIApplication sharedApplication].keyWindow];
    };
    [self.view addSubview:self.footerView];
    
    
   
    
    //日历
    self.calendarView = [[MHGatewayCalendarView alloc] initWithCurrentDate:self.currentDate ? self.currentDate : [NSDate date]];
    self.calendarView.selectDateCallBack = ^(NSDate *date){
        weakself.currentDate = date;
        
        [weakself.categories enumerateObjectsUsingBlock:^(MHExpandableCategory *category, NSUInteger idx, BOOL * _Nonnull stop) {
            MHDataGatewaySceneLog *sceneLog = category.data;
            NSDate* executeDate = [NSDate dateWithTimeIntervalSince1970:sceneLog.executeTime];
//            NSLog(@"%@", executeDate);
//            NSLog(@"%@", date);
            if ([weakself isSameDay:date date2:executeDate]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:idx];
                [weakself.expandableTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                weakself.isFoundDate = YES;
                *stop = YES;
            }

        }];
        if (!weakself.isFoundDate) {
            [weakself getSpecifiedTimeData];
            weakself.isFoundDate = NO;
        }
    };
    
    //设备筛选
    self.menuView = [[MHGatewaySceneMenuView alloc] initWithDataSource:self.deviceDids];
    self.menuView.delegate = self;
    [self.menuView setFooterHide:^{
        [weakself.sceneTitleView updateDeviceName:nil arrowImage:@"lumi_scene_log_bottomarrow"];
    }];

}

- (void)buildConstraints {
    [super buildConstraints];
    XM_WS(weakself);
    [self.footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakself.view.mas_bottom);
        make.height.mas_equalTo(60);
        make.width.mas_equalTo(WIN_WIDTH);
        make.centerX.equalTo(weakself.view);
    }];
    
    


}

- (void)onDeviceMenu {
    if (self.menuView.superview) {
        [self.menuView hideView];
        [self.sceneTitleView updateDeviceName:nil arrowImage:@"lumi_scene_log_bottomarrow"];
        return;
    }
    self.menuView.seletedDid = self.seletedDid;
    [self.menuView showViewInView:self.view];
    [self.sceneTitleView updateDeviceName:nil arrowImage:@"lumi_scene_log_toparrow"];

    
}

#pragma mark - MHGatewaySceneMenuViewDelegate
- (void)menuViewDidSelectedRow:(NSInteger)index did:(id)did name:(NSString *)name {
    XM_WS(weakself);
    [self.sceneTitleView updateDeviceName:name arrowImage:@"lumi_scene_log_bottomarrow"];
    self.seletedDid = did;
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"loading", @"plugin_gateway", nil) modal:NO];
    
    if ([did isKindOfClass:[NSArray class]]) {
        [[MHGatewaySceneLogDataManager sharedInstance] setDeviceDid:[NSString stringWithFormat:@"%@%@",kALLDEVICE, self.gateway.did ]];
    }
    else {
        [[MHGatewaySceneLogDataManager sharedInstance] setDeviceDid:did];
    }
    //读取缓存
    [[MHGatewaySceneLogDataManager sharedInstance] restoreLogListWithFinish:^(id obj) {
        if ([obj isKindOfClass:[NSArray class]] && [obj count] > 0) {
            [[MHTipsView shareInstance] hide];
            [weakself updateTableView];
        }
    }];
    
    NSArray *deviceDids = [did isKindOfClass:[NSArray class]] ? did : @[ did ];
    [[MHGatewaySceneLogDataManager sharedInstance] getExecuteHistoryWithDeviceDids:deviceDids Success:^{
        [weakself updateTableView];
        [[MHTipsView shareInstance] hide];
    } failure:^{
        [weakself updateTableView];
        [[MHTipsView shareInstance] hide];
    }];
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
#pragma mark - 选中事件
- (void)didSelectContent:(MHExpandableContent *)content {
//    NSLog(@"%@", content.data);
    XM_WS(weakself);
    __block MHDataIFTTTRecord *selectedRecord = nil;
    
    [[MHIFTTTManager sharedInstance].recordList enumerateObjectsUsingBlock:^(MHDataIFTTTRecord *record, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSLog(@"%@", record.us_id);
//        NSLog(@"选中的id%@", [content.data history]);
        MHDataGatewaySceneLogMessage *logMsg = content.data;
        if ([record.us_id isEqualToString:[logMsg.history recordId]]) {
            selectedRecord = record;
            *stop = YES;
        }
    }];
    if (selectedRecord) {
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

}

- (void)didSelectCategory:(MHExpandableCategory *)category {
    XM_WS(weakself);
    __block MHDataIFTTTRecord *selectedRecord = nil;
   
    
    //系统自动化
    if ([[category.data recordIdentifier] isEqualToString:kAlarmMotionIdentifier] ||
        [[category.data recordIdentifier] isEqualToString:kAlarmMagnetTimerIdentifier] ||
        [[category.data recordIdentifier] isEqualToString:kAlarmSwitchTimerIdentifier] ||
        [[category.data recordIdentifier] isEqualToString:kAlarmCubeTimerIdentifier]) {
        [self alarmItems];
    }
    else if ([[category.data recordIdentifier] isEqualToString:kDoorbellMotionTimerIdentifier] ||
        [[category.data recordIdentifier] isEqualToString:kDoorbellMagnetTimerIdentifier] ||
        [[category.data recordIdentifier] isEqualToString:kDoorbellSwitchTimerIdentifier]) {
        [self doorbellItems];
    }
    else if ([[category.data recordIdentifier] isEqualToString:kCloseClockMotionTimerIdentifier] ||
        [[category.data recordIdentifier] isEqualToString:kCloseClockMagnetTimerIdentifier] ||
        [[category.data recordIdentifier] isEqualToString:kCloseClockSwitchTimerIdentifier]) {
        MHGatewayClockControlSettingViewController *clockSettings = [[MHGatewayClockControlSettingViewController alloc] initWithDevice:self.gateway];
        [self.navigationController pushViewController:clockSettings animated:YES];

    }
    //感应夜灯
    else if ([[category.data recordIdentifier] isEqualToString:kNightLightMotionTimerIdentifier]) {
        [self openNightlight];
    }
    //联动报警
    else if ([[category.data recordIdentifier] isEqualToString:ALARM_IDENTIFY] ||
             [[category.data recordIdentifier] isEqualToString:DIS_ALARM_IDENTIFY] ||
             [[category.data recordIdentifier] isEqualToString:DIS_ALARM_ALL_IDENTIFY]) {
        [self openLinkAlarmPage];
    }
    //警戒定时
    else if ([[category.data recordIdentifier] isEqualToString:kAlarmTimerIdentifier]) {
        [self openAlarmTimerPage];
    }
    //彩灯定时
    else if ([[category.data recordIdentifier] isEqualToString:kNightTimerIdentifier]) {
        [self openNightTimerPage];
    }
    //懒人闹钟
    else if ([[category.data recordIdentifier] isEqualToString:kClockTimerIdentifier]) {
        [self openClockTimerPage];
    }
    //插座定时
    else if ([[category.data recordIdentifier] isEqualToString:TimerIdentify]) {
        [[category.data messages] enumerateObjectsUsingBlock:^(MHDataGatewaySceneLogMessage* msg, NSUInteger idx, BOOL * _Nonnull stop) {
            [weakself.gateway.subDevices enumerateObjectsUsingBlock:^(MHDeviceGatewayBase *subDevice, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([subDevice.did isEqualToString:msg.target]) {
                    weakself.devicePlug = (MHDeviceGatewaySensorPlug *)subDevice;
                    *stop = YES;
                }
            }];
        }];
        [self openTimerView];
    }
    else if ([[category.data recordIdentifier] isEqualToString:kACPARTNERTIMERID]) {
       
        MHACPartnerTimerNewSettingViewController *tVC = [[MHACPartnerTimerNewSettingViewController alloc] initWithDevice:(MHDeviceAcpartner *)self.gateway andIdentifier:kACPARTNERTIMERID];
        tVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.timer.title",@"plugin_gateway","空调定时");
        tVC.controllerIdentifier = kACPARTNERTIMERID;
        [self.navigationController pushViewController:tVC animated:YES];
        [self gw_clickMethodCountWithStatType:@"openACPartnerTimerSetting"];
    }
    //单火单键定时
    else if ([[category.data recordIdentifier] isEqualToString:LumiNeutral1TimerIdentify]) {
        [[category.data messages] enumerateObjectsUsingBlock:^(MHDataGatewaySceneLogMessage* msg, NSUInteger idx, BOOL * _Nonnull stop) {
            [weakself.gateway.subDevices enumerateObjectsUsingBlock:^(MHDeviceGatewayBase *subDevice, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([subDevice.did isEqualToString:msg.target]) {
                    weakself.deviceSingleNetural = (MHDeviceGatewaySensorSingleNeutral *)subDevice;
                    *stop = YES;
                }
            }];
        }];

        [self openSingleNeutralTimerView];
    }
    //左键定时
    else if ([[category.data recordIdentifier] isEqualToString:TimerIdentifyNeutral0]) {
        [[category.data messages] enumerateObjectsUsingBlock:^(MHDataGatewaySceneLogMessage* msg, NSUInteger idx, BOOL * _Nonnull stop) {
            [weakself.gateway.subDevices enumerateObjectsUsingBlock:^(MHDeviceGatewayBase *subDevice, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([subDevice.did isEqualToString:msg.target]) {
                    weakself.deviceNeutral = (MHDeviceGatewaySensorDoubleNeutral *)subDevice;
                    *stop = YES;
                }
            }];
        }];
        self.neutralTimerIndex = 0;
        [self openDoubleNeutralTimerPage];
    }
    //右键定时
    else if ([[category.data recordIdentifier] isEqualToString:TimerIdentifyNeutral1]) {
        [[category.data messages] enumerateObjectsUsingBlock:^(MHDataGatewaySceneLogMessage* msg, NSUInteger idx, BOOL * _Nonnull stop) {
            [weakself.gateway.subDevices enumerateObjectsUsingBlock:^(MHDeviceGatewayBase *subDevice, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([subDevice.did isEqualToString:msg.target]) {
                    weakself.deviceNeutral = (MHDeviceGatewaySensorDoubleNeutral *)subDevice;
                    *stop = YES;
                }
            }];
        }];
        self.neutralTimerIndex = 1;
        [self openDoubleNeutralTimerPage];
    }
    else {
//        NSLog(@"%@%@", [category.data recordName], [category.data recordId]);
//        
//        [[MHGatewaySceneManager sharedInstance] fetchSceneListWithDevice:self.gateway stid:@"22" andSuccess:^(id obj) {
//            if ([obj isKindOfClass:[NSArray class]]) {
//                [obj enumerateObjectsUsingBlock:^(MHDataScene *scene, NSUInteger idx, BOOL * _Nonnull stop) {
//                    NSLog(@"系统自动化名称%@", scene.name);
//                    if ([scene.usId integerValue] == [[category.data recordId] integerValue]) {
//                        NSLog(@"找到了啊啊<<<<<<>>>>>>>");
//                    }
//                }];
//            }
//        } failure:^(NSError *v) {
//            
//        }];
        
        
        [[MHIFTTTManager sharedInstance].recordList enumerateObjectsUsingBlock:^(MHDataIFTTTRecord *record, NSUInteger idx, BOOL * _Nonnull stop) {
            //        NSLog(@"%@", record.us_id);
            //        NSLog(@"选中的id%@", [category.data recordId]);
            if ([record.us_id isEqualToString:[category.data recordId]]) {
                selectedRecord = record;
                *stop = YES;
            }
        }];
        if (selectedRecord) {
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
        else {
            [[MHPromptKit shareInstance] showAlertWithHandler:^(NSInteger buttonIndex, NSArray *inputs) {
                switch (buttonIndex) {
                    case 0:
                        
                        break;
                        
                    default:
                        break;
                }
                
            } withTitle:@"" message:NSLocalizedStringFromTable(@"ifttt.scene.local.scene.log.scenedelete", @"plugin_gateway", @"親,你的場景已經刪除了哦") style:UIAlertViewStyleDefault defaultText:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedStringFromTable(@"ifttt.scene.local.scene.log.scenedelete.confirm", @"plugin_gateway", @"我知道了"), nil];
        }
    }
}

//通知manager刷新
- (void)updateTableView
{
    NSArray* dataSource = [[MHGatewaySceneLogDataManager sharedInstance] executeHistories];
    //空白页
    if ([dataSource count]) {
        self.expandableTable.backgroundView = nil;
    }
    else {
        self.expandableTable.backgroundView = self.buildNoDeviceMessageView;
    }
    __block NSMutableArray* categories = [NSMutableArray array];
    [dataSource enumerateObjectsUsingBlock:^(MHDataGatewaySceneLog* log, NSUInteger idx, BOOL * _Nonnull stop) {
        
        BOOL isExpandable = ![log isSucceedExecuted] && [log isShowFaiedDetails] && [log.messages count];
        
        MHExpandableCategory* category = [MHExpandableCategory new];
        //            category.categoryId = tpl.did;
        category.data = log;
        category.expandable = isExpandable;
        category.expanded = NO;
        category.selected = NO;
        category.selectedContent = nil;
        [categories addObject:category];
        
        if (isExpandable) {
            __block NSMutableArray* contents = [NSMutableArray array];
            [log.messages enumerateObjectsUsingBlock:^(MHDataGatewaySceneLogMessage* msg, NSUInteger idx, BOOL * _Nonnull stop) {
                if (idx == [log.messages count]-1) {
                    msg.isLast = YES;
                } else {
                    msg.isLast = NO;
                }
                msg.history = log;
                
                MHExpandableContent* content = [MHExpandableContent new];
                //                content.contentId = trigger.did; //TODO: 没办法通过contentId区分content
                content.data = msg;
                content.selected = NO;
                //                category.selectedContent = content;
                [contents addObject:content];
            }];
            
            category.contents = contents;
        }
    }];
    
    self.categories = categories;
    
    [self.expandableTable reloadData];
}

- (void)clearHistory:(id)sender {
//    XM_WS(ws);
//    [[MHPromptKit shareInstance] showAlertWithHandler:^(NSInteger buttonIndex, NSArray *inputs) {
//        if (buttonIndex == 0) {
//            // cancelled
//        } else if (buttonIndex == 1) {
//            [[MHIFTTTManager sharedInstance] clearExecuteHistorySuccess:^{
//                [ws updateTableView];
//            } failure:^{
//                [[MHTipsView shareInstance] showFailedTips:NSLocalizedString(@"ifttt.scene.log.clear.failed","清空自动化历史失败") duration:1.0 modal:NO];
//            }];
//        }
//    } withTitle:NSLocalizedString(@"ifttt.scene.log.clear","清空自动化日志") message:NSLocalizedString(@"ifttt.scene.log.clearall","是否清空所有记录") style:UIAlertViewStyleDefault defaultText:nil cancelButtonTitle:NSLocalizedString(@"Cancel", @"取消") otherButtonTitles:NSLocalizedString(@"Ok", @"确定"), nil];
}

#pragma mark - No device page
- (UIView* )buildNoDeviceMessageView {
    if (_buildNoDeviceMessageView == nil) {
        XM_WS(ws);
        //    UIView* backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, WIN_WIDTH, WIN_WIDTH - 64 - 60)];
        UIView* backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
        [backgroundView setBackgroundColor:[UIColor whiteColor]];
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableview_blank_logo"]];
        [backgroundView addSubview:icon];
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(backgroundView);
            make.top.equalTo(backgroundView).offset(ws.topLayoutGuide.length+135*ScaleHeight);
            make.width.height.mas_equalTo(86*ScaleWidth);
        }];
        
        UILabel *label = [[UILabel alloc] init];
        label.text = NSLocalizedStringFromTable(@"list.blank", @"plugin_gateway", @"列表内容为空");
        label.textAlignment = NSTextAlignmentCenter;
        [label setTextColor:[UIColor colorWithWhite:0 alpha:0.8]];
        [label setFont:[UIFont systemFontOfSize:15.0f]];
        [backgroundView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(icon.mas_bottom).offset(15);
            make.centerX.equalTo(backgroundView);
        }];
        _buildNoDeviceMessageView = backgroundView;
    }
    return _buildNoDeviceMessageView;

}

- (void)openDetailScenePage:(id)data {
    
}

#pragma mark - timer 
- (void)openNightTimerPage {
    MHGatewayLightTimerSettingViewController *timerVC = [[MHGatewayLightTimerSettingViewController alloc] initWithDevice:self.gateway andIdentifier:@"lumi_gateway_single_rgb_timer"];
    timerVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.timer.cap",@"plugin_gateway","定时彩灯");
    timerVC.controllerIdentifier = @"gateway_single_rgb";
    [self.navigationController pushViewController:timerVC animated:YES];
}
- (void)openAlarmTimerPage {
    XM_WS(weakself);
    MHGatewayTimerSettingNewViewController *tVC = [[MHGatewayTimerSettingNewViewController alloc] initWithDevice:weakself.gateway andIdentifier:@"lumi_gateway_arming_timer"];
    tVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.timer",@"plugin_gateway","警戒定时");
    tVC.controllerIdentifier = @"alarm";
    __weak MHGatewayTimerSettingNewViewController *weakTimerVC = tVC;
    tVC.onAddNewTimer = ^(MHDataDeviceTimer *newTimer){
        [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.timersetting.adding",@"plugin_gateway","添加定时中，请稍候...") modal:YES];
        newTimer.identify = @"lumi_gateway_arming_timer";
        newTimer.onMethod = @"set_arming";
        newTimer.onParam = @[ @"on" ];
        newTimer.offMethod = @"set_arming";
        newTimer.offParam = @[ @"off" ];
        [weakTimerVC addTimer:newTimer];
    };
    [weakself.navigationController pushViewController:tVC animated:YES];

}
- (void)openClockTimerPage {

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
        
}

#pragma mark - 警戒触发条件
- (void)alarmItems {
    XM_WS(weakself);
    
    MHGatewaySettingGroup* group = [[MHGatewaySettingGroup alloc] init];
    NSMutableArray *alarmItems = [[NSMutableArray alloc] init];
    group.items = alarmItems;
    
    [self.gateway.subDevices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MHDeviceGatewayBase* device = obj;
        if (device.isOnline
            && ([device isKindOfClass:[MHDeviceGatewaySensorMotion class]]
                || [device isKindOfClass:[MHDeviceGatewaySensorSwitch class]]
                || [device isKindOfClass:[MHDeviceGatewaySensorMagnet class]]
                || [device isKindOfClass:[MHDeviceGatewaySensorCube class]])) {
                MHDeviceSettingItem *alarmItem = [[MHDeviceSettingItem alloc] init];
                alarmItem.type = MHDeviceSettingItemTypeSwitch;
                alarmItem.caption = device.name;
                alarmItem.isOn = [device isSetAlarming];
                alarmItem.customUI = YES;
                alarmItem.accessories = [[MHStrongBox alloc] initWithDictionary:@{@"sensor" : device,SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
                
                if( [device isKindOfClass:[MHDeviceGatewaySensorSwitch class]] ){
                    alarmItem.identifier = [NSString stringWithFormat:@"%@_%d", @"switch", (int)idx];;
                    alarmItem.comment = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.switch.detail",@"plugin_gateway","有人按键报警");
                }
                if([device isKindOfClass:[MHDeviceGatewaySensorMotion class]]){
                    alarmItem.identifier = [NSString stringWithFormat:@"%@_%d", @"motion", (int)idx];
                    alarmItem.comment = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.motion.detail",@"plugin_gateway","有人经过报警");
                }
                if([device isKindOfClass:[MHDeviceGatewaySensorMagnet class]]){
                    alarmItem.identifier = [NSString stringWithFormat:@"%@_%d", @"magnet", (int)idx];
                    alarmItem.comment = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.magnet.detail",@"plugin_gateway","门窗打开报警");
                }
                if([device isKindOfClass:[MHDeviceGatewaySensorCube class]] && ([self.gateway.model isEqualToString:@"lumi.gateway.v3"] || [self.gateway.model isEqualToString:DeviceModelAcpartner])){
                    alarmItem.identifier = [NSString stringWithFormat:@"%@_%d", @"cube", (int)idx];
                    alarmItem.comment = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.cube.detail",@"plugin_gateway","魔方报警");
                }
                if([device isKindOfClass:[MHDeviceGatewaySensorCube class]] && [self.gateway.model isEqualToString:@"lumi.gateway.v2"]){
                    return;
                }
                
                alarmItem.callbackBlock = ^(MHDeviceSettingCell *cell) {
                    MHDeviceGatewayBase* sensor = [cell.item.accessories valueForKey:@"sensor" class:[MHDeviceGatewayBase class]];
                    [weakself gw_clickMethodCountWithStatType:[NSString stringWithFormat:@"switch:%@",sensor.class]];
                    
                    if (cell.item.isOn) {
                        [sensor setAlarmingWithSuccess:^(id v) {
                            [cell finish];
                        } failure:^(NSError *v) {
                            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed", @"plugin_gateway",@"请求失败，请检查网络") duration:1.0f modal:NO];
                            cell.item.isOn = !cell.item.isOn;
                            [cell fillWithItem:cell.item];
                            [cell finish];
                        }];
                    }
                    else {
                        [sensor removeAlarmingWithSuccess:^(id v) {
                            [cell finish];
                        } failure:^(NSError *error) {
                            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed", @"plugin_gateway",@"请求失败，请检查网络") duration:1.0f modal:NO];
                            cell.item.isOn = !cell.item.isOn;
                            [cell fillWithItem:cell.item];
                            [cell finish];
                        }];
                    }
                };
                
                [alarmItems addObject:alarmItem];
            }
        
        if (!device.isBindListGot) {
            [device getBindListWithSuccess:nil failure:nil];
        }
    }];
    
    MHLuDeviceSettingViewController* selMotionVC = [[MHLuDeviceSettingViewController alloc] init];
    selMotionVC.settingGroups = @[group];
    selMotionVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.group.devices",@"plugin_gateway","警戒触发设备");
    selMotionVC.controllerIdentifier = @"mydevice.gateway.setting.alarm.group.devices";
    selMotionVC.isTabBarHidden = YES;
    [self.navigationController pushViewController:selMotionVC animated:YES];
}


#pragma mark - 门铃条件
- (void)doorbellItems {
    XM_WS(weakself);
    MHLuDeviceSettingGroup *groupDoorbellCondition = [[MHLuDeviceSettingGroup alloc] init];
    NSMutableArray *doorbellConditionItems = [NSMutableArray arrayWithCapacity:1];
    groupDoorbellCondition.items = doorbellConditionItems;
    
    NSInteger switchIndex = 0;
    for (MHDeviceGatewayBase *device in self.gateway.subDevices) {
        if (device.isOnline
            && ([device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorMotion")]
                || [device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorSwitch")]
                || [device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorMagnet")])) {
                
                MHDeviceSettingItem *itemClick = [[MHDeviceSettingItem alloc] init];
                itemClick.type = MHDeviceSettingItemTypeSwitch;
                itemClick.caption = device.name;
                itemClick.isOn = (device != nil && [device isSetDoorBell]);
                itemClick.customUI = YES;
                
                NSMutableDictionary* accessories = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(56),SettingAccessoryKey_CellHeight, @(15),SettingAccessoryKey_CaptionFontSize,[MHColorUtils colorWithRGB:0x333333],SettingAccessoryKey_CaptionFontColor, nil];
                if (device) {
                    [accessories setObject:device forKey:@"device"];
                }
                
                if( [device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorMotion")]){
                    itemClick.identifier = [NSString stringWithFormat:@"%@_%d", @"switch", (int)switchIndex];;
                    itemClick.comment = NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.motion.comment",@"plugin_gateway","移动响门铃");
                }
                if([device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorSwitch")]){
                    itemClick.identifier = [NSString stringWithFormat:@"%@_%d", @"motion", (int)switchIndex];
                    itemClick.comment = NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.click.comment",@"plugin_gateway","按动无线开关响门铃");
                }
                if([device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorMagnet")]){
                    itemClick.identifier = [NSString stringWithFormat:@"%@_%d", @"magnet", (int)switchIndex];
                    itemClick.comment = NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.magnetopen.comment",@"plugin_gateway","门窗打开门铃");
                }
                
                itemClick.accessories = [[MHStrongBox alloc] initWithDictionary:accessories];
                itemClick.callbackBlock = ^(MHDeviceSettingCell *cell) {
                    MHDeviceGatewayBase* sensor = [cell.item.accessories valueForKey:@"device" class:[MHDeviceGatewayBase class]];
                    MHLumiBindItem* item = [[MHLumiBindItem alloc] init];
                    if( [device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorMotion")]){
                        item.event = Gateway_Event_Motion_Motion;
                    }
                    if([device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorSwitch")]){
                        item.event = Gateway_Event_Switch_Click;
                    }
                    if([device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorMagnet")]){
                        item.event = Gateway_Event_Magnet_Open;
                    }
                    item.to_sid = SID_Gateway;
                    item.method = Method_Door_Bell;
                    item.from_sid = device.did;
                    item.params = @[@([weakself.gateway.default_music_index[BellGroup_Door] integerValue])];
                    if (cell.item.isOn) {
                        //这个sensor
                        MHDeviceGatewayBase* switchSensor = [cell.item.accessories valueForKey:@"device" class:[MHDeviceGatewayBase class]];
                        [weakself gw_clickMethodCountWithStatType:[NSString stringWithFormat:@"device:%@",switchSensor.class]];
                        
                        [sensor addBind:item success:^(id v) {
                            [cell fillWithItem:cell.item];
                            [cell finish];
                            
                        } failure:^(NSError *v) {
                            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
                            cell.item.isOn = !cell.item.isOn;
                            [cell fillWithItem:cell.item];
                            [cell finish];
                        }];
                        
                    } else {
                        [sensor removeBind:item success:^(id v) {
                            [cell finish];
                            [weakself refetchDoorBellStatus];  //关闭就去全拉一边
                            
                        } failure:^(NSError *error) {
                            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
                            cell.item.isOn = !cell.item.isOn;
                            [cell fillWithItem:cell.item];
                            [cell finish];
                        }];
                    }
                };
                
                [doorbellConditionItems addObject:itemClick];
                switchIndex ++;
            }
    }
    
    MHLuDeviceSettingViewController* selMotionVC = [[MHLuDeviceSettingViewController alloc] init];
    selMotionVC.settingGroups = @[groupDoorbellCondition];
    selMotionVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.condition",@"plugin_gateway","门铃触发条件");
    selMotionVC.controllerIdentifier = @"mydevice.gateway.setting.doorbell.condition";
    selMotionVC.isTabBarHidden = YES;
    [self.navigationController pushViewController:selMotionVC animated:YES];
}


#pragma mark - 联动报警
- (void)openLinkAlarmPage {
    MHGatewayLinkAlarmViewController *linkVC = [[MHGatewayLinkAlarmViewController alloc] initWithGateway:self.gateway];
    [self.navigationController pushViewController:linkVC animated:YES];

}

-(void)refetchDoorBellStatus{
    BOOL tmp = NO;
    for (MHDeviceGatewayBase *device in self.gateway.subDevices) {
        if (!([device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorMotion")]
              || [device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorSwitch")]
              || [device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorMagnet")])) {
            continue;
        }
        if(device != nil && [device isSetDoorBell]){
            tmp = YES;
        }
    }
}
- (void)openNightlight {
    MHGatewayLightSettingViewController *nightLightSettingVC = [[MHGatewayLightSettingViewController alloc] initWithGateway:_gateway];
    nightLightSettingVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight",@"plugin_gateway","智能彩灯设置");
    nightLightSettingVC.isTabBarHidden = YES;
    [self.navigationController pushViewController:nightLightSettingVC animated:YES];
}


#pragma mark - 插座定时
- (void)openTimerView {
    MHGatewayTimerSettingNewViewController *tVC = [[MHGatewayTimerSettingNewViewController alloc] initWithDevice:self.devicePlug andIdentifier:TimerIdentify];
    tVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.timer.title",@"plugin_gateway", @"");
    tVC.controllerIdentifier = @"plug";
    __weak MHGatewayTimerSettingNewViewController *weakVC = tVC;
    tVC.onAddNewTimer = ^(MHDataDeviceTimer *newTimer){
        [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.timersetting.adding",@"plugin_gateway","添加定时中，请稍候...") modal:YES];
        
        newTimer.identify = TimerIdentify;
        newTimer.onMethod = @"toggle_plug";
        newTimer.onParam = @[ @"neutral_0" , @"on" ];
        newTimer.offMethod = @"toggle_plug";
        newTimer.offParam = @[ @"neutral_0" , @"off" ];
        
        [weakVC addTimer:newTimer];
    };
    [self.navigationController pushViewController:tVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"openTimerView"];
}

- (void)openSingleNeutralTimerView {
    
    MHGatewayTimerSettingNewViewController *timerVC = [[MHGatewayTimerSettingNewViewController alloc] initWithDevice:self.deviceSingleNetural andIdentifier:LumiNeutral1TimerIdentify];
    timerVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.singleNeutral.timer.title",@"plugin_gateway", @"单火定时");
    timerVC.controllerIdentifier = @"singleNetural";
    __weak MHGatewayTimerSettingNewViewController *weakVC = timerVC;
    timerVC.onAddNewTimer = ^(MHDataDeviceTimer *newTimer){
        [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.timersetting.adding",@"plugin_gateway","添加定时中，请稍候...") modal:YES];
        
        newTimer.identify = LumiNeutral1TimerIdentify;
        newTimer.onMethod = @"toggle_ctrl_neutral";
        newTimer.onParam = @[ @"neutral_0" , @"on" ];
        newTimer.offMethod = @"toggle_ctrl_neutral";
        newTimer.offParam = @[ @"neutral_0" , @"off" ];
        
        [weakVC addTimer:newTimer];
    };
    [self.navigationController pushViewController:timerVC animated:YES];
}

- (void)openDoubleNeutralTimerPage {
    switch (self.neutralTimerIndex) {
        case 0: {
            MHGatewayTimerSettingNewViewController *timerVC = [[MHGatewayTimerSettingNewViewController alloc] initWithDevice:self.deviceNeutral andIdentifier:TimerIdentifyNeutral0];
            
            timerVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.doubleNeutral.timer.left.title",@"plugin_gateway", @"左键定时");
           timerVC.controllerIdentifier = @"doubleNeutral";
            __weak MHGatewayTimerSettingNewViewController *weakVC = timerVC;
            timerVC.onAddNewTimer = ^(MHDataDeviceTimer *newTimer){
                [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.timersetting.adding",@"plugin_gateway","添加定时中，请稍候...") modal:YES];
                
                newTimer.identify = TimerIdentifyNeutral0;
                newTimer.onMethod = @"toggle_ctrl_neutral";
                newTimer.onParam = @[ @"neutral_0" , @"on" ];
                newTimer.offMethod = @"toggle_ctrl_neutral";
                newTimer.offParam = @[ @"neutral_0" , @"off" ];
                
                [weakVC addTimer:newTimer];
            };
            [self.navigationController pushViewController:timerVC animated:YES];
        }
            break;
        case 1: {
            MHGatewayTimerSettingNewViewController *timerVC = [[MHGatewayTimerSettingNewViewController alloc] initWithDevice:self.deviceNeutral andIdentifier:TimerIdentifyNeutral1];
            
            timerVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.doubleNeutral.timer.right.title",@"plugin_gateway", @"右键定时");
            timerVC.controllerIdentifier = @"doubleNeutral";
            __weak MHGatewayTimerSettingNewViewController *weakVC = timerVC;
            timerVC.onAddNewTimer = ^(MHDataDeviceTimer *newTimer){
                [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.timersetting.adding",@"plugin_gateway","添加定时中，请稍候...") modal:YES];
                
                newTimer.identify = TimerIdentifyNeutral1;
                newTimer.onMethod = @"toggle_ctrl_neutral";
                newTimer.onParam = @[ @"neutral_1" , @"on" ];
                newTimer.offMethod = @"toggle_ctrl_neutral";
                newTimer.offParam = @[ @"neutral_1" , @"off" ];
                [weakVC addTimer:newTimer];
            };
            [self.navigationController pushViewController:timerVC animated:YES];
        }
            break;
        default:
            break;
    }

}

#pragma mark - 判断日期是否是同一天
- (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%@", self.sceneTitleView.subviews);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[MHTipsView shareInstance] hide];
}

@end
