//
//  MHGatewayNatgasSettingViewController.m
//  MiHome
//
//  Created by ayanami on 16/7/6.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayNatgasSettingViewController.h"
#import "MHDeviceGatewaySensorNatgas.h"
#import "MHLumiSettingCell.h"
#import "MHGatewaySensorViewController.h"
#import "MHGatewayNatgasSensitivityViewController.h"
#import "MHGatewayNatgasSelfTestViewController.h"
#import "MHLumiLogGraphManager.h"

@interface MHGatewayNatgasSettingViewController ()

@property (nonatomic, strong) MHDeviceGatewaySensorNatgas *deviceNatgas;
@property (nonatomic, weak) MHGatewaySensorViewController *natgasVC;

@property (nonatomic, assign) NSInteger passtime;
@property (nonatomic, strong) NSDate *beginDate;

@end

@implementation MHGatewayNatgasSettingViewController

- (id)initWithDeviceNatgas:(MHDeviceGatewaySensorNatgas *)deviceNatgas natgasController:(UIViewController *)natgasVC
{
    self = [super init];
    if (self) {
        self.deviceNatgas = deviceNatgas;
        self.natgasVC = (MHGatewaySensorViewController *)natgasVC;
        [self.deviceNatgas readStatus];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //请求新的数据
    self.title = NSLocalizedStringFromTable(@"mydevice.actionsheet.more",@"plugin_gateway","更多");
    
//    XM_WS(weakself);
//    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"getting",@"plugin_gateway","获取中，请稍候...") modal:YES];
//
    
    self.beginDate = [NSDate date];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getNewDeviceData];
}


- (void)getNewDeviceData {
    
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"loading",@"plugin_gateway","loading..") modal:YES];
    XM_WS(weakself);
    [self.deviceNatgas getPrivateProperty:HIGH_INDEX success:^(id obj) {
        if (!([[obj[@"result"] firstObject] isKindOfClass:[NSString class]] && [[obj[@"result"] firstObject] isEqualToString:@"waiting"])) {
            [weakself.deviceNatgas getPrivateProperty:SELFTEST_ENABLE_INDEX success:^(id obj) {
                [weakself buildTableView];
                [[MHTipsView shareInstance] hide];
            } failure:^(NSError *error) {
                [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.5f modal:NO];
            }];
        }
        else {
            weakself.passtime = [weakself countPasstime];
            //烟感有15s休眠
            if (weakself.passtime < 18) {
                [weakself getNewDeviceData];
            }
            else {
                [[MHTipsView shareInstance] hide];
            }
        }
    } failure:^(NSError *error) {
         [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.5f modal:NO];
    }];
}


- (NSInteger)countPasstime {
    NSInteger passtime = 0;
    NSDate *onDate = self.beginDate;
    NSDate *offDate = [NSDate date];
    
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // 需要对比的时间数据
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth
    | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    // 对比时间差
    NSDateComponents *compare = [calendar components:unit fromDate:onDate toDate:offDate options:0];
    passtime = compare.second;
    NSLog(@"过去的时间%ld", passtime);
    return passtime;
}

- (void)buildSubviews {
    [super buildSubviews];
    [self buildTableView];
}

- (void)buildTableView {
    XM_WS(weakself);
    
    NSString* strSensitivity = NSLocalizedStringFromTable(@"mydevice.gateway.setting.natgas.sensitive", @"plugin_gateway", @"报警灵敏度");
    NSString* strSelfTest = NSLocalizedStringFromTable(@"mydevice.gateway.setting.natgas.selftest", @"plugin_gateway", @"设备自检");
    NSString* strSelfTestCaption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.natgas.selftestnotify", @"plugin_gateway", @"设备自检提醒(每月)");
    NSString* strSelfTestComment = NSLocalizedStringFromTable(@"mydevice.gateway.setting.natgas.selftestnotify.comment", @"plugin_gateway", @"开启后每月的第一天提醒一次");
    
    NSString* strChangeTitle = [NSString stringWithFormat:@"%@", NSLocalizedStringFromTable(@"mydevice.actionsheet.changename",@"plugin_gateway","修改设备名称")];
    NSString* strShowMode = _deviceNatgas.showMode ? NSLocalizedStringFromTable(@"mydevice.gateway.delsub.rmvlist",@"plugin_gateway","撤销显示") : NSLocalizedStringFromTable(@"mydevice.gateway.delsub.addlist",@"plugin_gateway","添加显示");
    NSString* strFeedback = NSLocalizedStringFromTable(@"mydevice.actionsheet.feedback",@"plugin_gateway","反馈");
    
    MHLuDeviceSettingGroup* group1 = [[MHLuDeviceSettingGroup alloc] init];
    NSMutableArray *curtainSettings = [NSMutableArray new];
    
    //报警灵敏度
    MHLumiSettingCellItem *itemSensitivity = [[MHLumiSettingCellItem alloc] init];
    itemSensitivity.identifier = @"mydevice.gateway.sensor.curtain.installationtutorial";
    itemSensitivity.lumiType = MHLumiSettingItemTypeDefault;
    itemSensitivity.hasAcIndicator = YES;
    itemSensitivity.caption = strSensitivity;
    itemSensitivity.customUI = YES;
    itemSensitivity.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    itemSensitivity.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
        MHGatewayNatgasSensitivityViewController *sensitivityVC = [[MHGatewayNatgasSensitivityViewController alloc] initWithDeviceNatgas:weakself.deviceNatgas];
        [weakself.navigationController pushViewController:sensitivityVC animated:YES];
    };
    [curtainSettings addObject:itemSensitivity];
    
    //自动化
//    MHLumiSettingCellItem *itemAuto = [[MHLumiSettingCellItem alloc] init];
//    itemAuto.identifier = @"mydevice.gateway.sensor.curtain.installationtutorial";
//    itemAuto.lumiType = MHLumiSettingItemTypeDefault;
//    itemAuto.hasAcIndicator = YES;
//    itemAuto.caption = strAuto;
//    itemAuto.customUI = YES;
//    itemAuto.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
//    itemAuto.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
    //       MHGatewaySensorViewController *sceneVC = [[MHGatewaySensorViewController alloc] initWithDevice:self.deviceHt];
//    sceneVC.isHasMore = NO;
//    sceneVC.isHasShare = NO;
//    [weakself.navigationController pushViewController:sceneVC animated:YES];
//    };
//    [curtainSettings addObject:itemAuto];
    
    //设备自检
    MHLumiSettingCellItem *itemSelfTest = [[MHLumiSettingCellItem alloc] init];
    itemSelfTest.identifier = @"mydevice.gateway.sensor.curtain.installationtutorial";
    itemSelfTest.lumiType = MHLumiSettingItemTypeDefault;
    itemSelfTest.hasAcIndicator = YES;
    itemSelfTest.caption = strSelfTest;
    itemSelfTest.customUI = YES;
    itemSelfTest.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    itemSelfTest.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
        MHGatewayNatgasSelfTestViewController *sensitivityVC = [[MHGatewayNatgasSelfTestViewController alloc] initWithDeviceNatgas:weakself.deviceNatgas];
        [weakself.navigationController pushViewController:sensitivityVC animated:YES];
    };
    [curtainSettings addObject:itemSelfTest];
    
    //手动开关
    //    MHLumiSettingCellItem *itemManual = [[MHLumiSettingCellItem alloc] init];
    //    itemManual.identifier = @"mydevice.gateway.sensor.curtain.manualcontrol";
    //    itemManual.lumiType = MHLumiSettingItemTypeSwitch;
    //    itemManual.hasAcIndicator = YES;
    //    itemManual.caption = strManual;
    //    itemManual.comment = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.manualcontrol.comment",@"plugin_gateway","手动开/关窗帘");
    //    itemManual.customUI = YES;
    //    itemManual.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
    //    itemManual.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
    //        [weakself onManualControl];
    //    };
    //    [curtainSettings addObject:itemManual];
    
    //设备自检提醒
    MHDeviceSettingItem *itemManual = [[MHDeviceSettingItem alloc] init];
    itemManual.identifier = @"mydevice.gateway.sensor.curtain.manualcontrol";
    itemManual.type = MHDeviceSettingItemTypeSwitch;
    itemManual.hasAcIndicator = NO;
    itemManual.caption = strSelfTestCaption;
    itemManual.comment = strSelfTestComment;
    itemManual.isOn = self.deviceNatgas.selfcheckEnable;
    itemManual.enabled = YES;
    itemManual.customUI = YES;
    itemManual.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
    itemManual.callbackBlock = ^(MHDeviceSettingCell *cell) {
        [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"setting", @"plugin_gateway", @"设置中，请稍候...") modal:YES];
        bool flag = cell.item.isOn;
        [weakself.deviceNatgas setPrivateProperty:SELFTEST_ENABLE_INDEX value:[NSNumber numberWithBool:flag] success:^(id obj) {
            [[MHTipsView shareInstance] hide];
            cell.item.isOn = flag;
            [cell fillWithItem:cell.item];
            [cell finish];
        } failure:^(NSError *error) {
            [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"setting.failed", @"plugin_gateway", @"设置失败") modal:YES];
            cell.item.isOn = !flag;
            [cell fillWithItem:cell.item];
            [cell finish];
        }];
    };
    [curtainSettings addObject:itemManual];
    
//    MHLumiSettingCellItem *itemTrend = [[MHLumiSettingCellItem alloc] init];
//    itemTrend.identifier = @"mydevice.gateway.sensor.curtain.manualcontrol";
//    itemTrend.lumiType = MHLumiSettingItemTypeDefault;
//    itemTrend.hasAcIndicator = YES;
//    itemTrend.caption = strTrend;
//    itemTrend.customUI = YES;
//    itemTrend.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
//    itemTrend.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
//        [[MHLumiLogGraphManager sharedInstance] getLogListGraphWithDeviceDid:weakself.deviceNatgas.did andDeviceType:MHGATEWAYGRAPH_NATGAS andURL:nil andTitle:weakself.deviceNatgas.name andSegeViewController:weakself];
//    };
//    [curtainSettings addObject:itemTrend];
    
    //重命名
    MHLumiSettingCellItem *itemChangeTitle = [[MHLumiSettingCellItem alloc] init];
    itemChangeTitle.identifier = @"mydevice.actionsheet.changename";
    itemChangeTitle.lumiType = MHLumiSettingItemTypeDefault;
    itemChangeTitle.hasAcIndicator = YES;
    itemChangeTitle.caption = strChangeTitle;
    itemChangeTitle.customUI = YES;
    itemChangeTitle.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
    itemChangeTitle.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
        [weakself.natgasVC deviceChangeName];
    };
    
    [curtainSettings addObject:itemChangeTitle];
    
    //设置显示
    MHLumiSettingCellItem *itemShowMode = [[MHLumiSettingCellItem alloc] init];
    itemShowMode.identifier = @"mydevice.gateway.delsub.rmvlist";
    itemShowMode.lumiType = MHLumiSettingItemTypeDefault;
    itemShowMode.hasAcIndicator = YES;
    itemShowMode.caption = strShowMode;
    itemShowMode.customUI = YES;
    itemShowMode.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
    itemShowMode.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
        // 设置列表显示
        [weakself.deviceNatgas setShowMode:(int)!weakself.deviceNatgas.showMode success:^(id obj) {
            NSString *strShow = weakself.deviceNatgas.showMode ? NSLocalizedStringFromTable(@"mydevice.gateway.delsub.rmvlist",@"plugin_gateway","撤销显示") : NSLocalizedStringFromTable(@"mydevice.gateway.delsub.addlist",@"plugin_gateway","添加显示");
            cell.lumiItem.caption = strShow;
            [cell fillWithItem:cell.lumiItem];
            [cell finish];
        } failure:^(NSError *v) {
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"setting.failed", @"plugin_gateway","") duration:1.f modal:YES];
        }];
        [weakself gw_clickMethodCountWithStatType:@"actionSheetShowMode"];
    };
    [curtainSettings addObject:itemShowMode];
 
    //反馈
    MHLumiSettingCellItem *itemFeedback = [[MHLumiSettingCellItem alloc] init];
    itemFeedback.identifier = @"mydevice.actionsheet.feedback";
    itemFeedback.lumiType = MHLumiSettingItemTypeDefault;
    itemFeedback.hasAcIndicator = YES;
    itemFeedback.caption = strFeedback;
    itemFeedback.customUI = YES;
    itemFeedback.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    itemFeedback.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
        [weakself.natgasVC onFeedback];
    };
    
    [curtainSettings addObject:itemFeedback];
    
    group1.items = curtainSettings;
    self.settingGroups = [NSMutableArray arrayWithObjects:group1,nil];
    [self.settingTableView reloadData];
    
}

@end
