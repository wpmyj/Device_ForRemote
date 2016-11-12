//
//  MHGatewayCurtainSettingViewController.m
//  MiHome
//
//  Created by guhao on 16/5/13.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayCurtainSettingViewController.h"
#import "MHLumiSwitchSettingCell.h"
#import "MHLumiDefaultSettingCell.h"
#import "MHLumiAccessSettingCell.h"
#import "MHGatewaySensorViewController.h"
#import "MHGatewayCurtainViewController.h"
#import "MHGatewayCurtainInstallationViewController.h"

@interface MHGatewayCurtainSettingViewController ()

@property (nonatomic, strong) MHDeviceGatewaySensorCurtain *deviceCurtain;
@property (nonatomic, weak) MHGatewayCurtainViewController *curtainVC;

@property (nonatomic, strong) MHLuDeviceSettingViewController *directionVC;

@end

@implementation MHGatewayCurtainSettingViewController

- (id)initWithCurtainDevice:(MHDeviceGatewaySensorCurtain *)curtain curtainController:(UIViewController *)curtainVC
{
    self = [super init];
    if (self) {
        self.deviceCurtain = curtain;
        self.curtainVC = (MHGatewayCurtainViewController *)curtainVC;
        [self dataConstruct];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isTabBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedStringFromTable(@"mydevice.actionsheet.more",@"plugin_gateway","更多");
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[MHTipsView shareInstance] hide];
}

-(void)dataConstruct{
//    [_gateway getTimerListWithSuccess:nil failure:nil];
    XM_WS(weakself);
    
    NSString* strIfttt = NSLocalizedStringFromTable(@"profile.entry.triggerAction",@"plugin_gateway","自动化");
    NSString* strInstallation = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.installationtutorial",@"plugin_gateway","安装教程");
    NSString* strDirection = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.directionchoice",@"plugin_gateway","方向选择");
    NSString *strForward = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.directionchoice.forward",@"plugin_gateway","正向");
    NSString *strReverse = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.directionchoice.reverse",@"plugin_gateway","反向");

    NSString* strClear = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.clearitinerary",@"plugin_gateway","清楚行程(慎点)");
    NSString* strManual = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.manualcontrol",@"plugin_gateway","手动开/关窗帘");
    
    NSString* strChangeTitle = [NSString stringWithFormat:@"%@", NSLocalizedStringFromTable(@"mydevice.actionsheet.changename",@"plugin_gateway","修改设备名称")];
    NSString* strShowMode = _deviceCurtain.showMode ? NSLocalizedStringFromTable(@"mydevice.gateway.delsub.rmvlist",@"plugin_gateway","撤销显示") : NSLocalizedStringFromTable(@"mydevice.gateway.delsub.addlist",@"plugin_gateway","添加显示");
    NSString *strFAQ = NSLocalizedStringFromTable(@"mydevice.gateway.about.freFAQ",@"plugin_gateway","常见问题");
    NSString* strFeedback = NSLocalizedStringFromTable(@"mydevice.actionsheet.feedback",@"plugin_gateway","反馈");
    
    //自动化
    MHLuDeviceSettingGroup* group1 = [[MHLuDeviceSettingGroup alloc] init];
    NSMutableArray *curtainSettings = [NSMutableArray new];
    
    MHLumiSettingCellItem *itemIfttt = [[MHLumiSettingCellItem alloc] init];
    itemIfttt.identifier = @"profile.entry.triggerAction";
    itemIfttt.lumiType = MHLumiSettingItemTypeDefault;
    itemIfttt.hasAcIndicator = YES;
    itemIfttt.caption = strIfttt;
    itemIfttt.customUI = YES;
    itemIfttt.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    itemIfttt.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
        [weakself onAddScene];
    };
    [curtainSettings addObject:itemIfttt];
    
    //安装教程
    MHLumiSettingCellItem *itemInstallation = [[MHLumiSettingCellItem alloc] init];
    itemInstallation.identifier = @"mydevice.gateway.sensor.curtain.installationtutorial";
    itemInstallation.lumiType = MHLumiSettingItemTypeDefault;
    itemInstallation.hasAcIndicator = YES;
    itemInstallation.caption = strInstallation;
    itemInstallation.customUI = YES;
    itemInstallation.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    itemInstallation.lumiCallbackBlock = ^(MHDeviceSettingCell *cell) {
        [weakself onInstallationtutorial];
    };
    [curtainSettings addObject:itemInstallation];
    
    //方向选择
    MHLumiSettingCellItem *itemDirection = [[MHLumiSettingCellItem alloc] init];
    itemDirection.identifier = @"mydevice.gateway.sensor.curtain.directionchoice";
    itemDirection.lumiType = MHLumiSettingItemTypeAccess;
    itemDirection.hasAcIndicator = YES;
    itemDirection.caption = strDirection;
    itemDirection.comment = self.deviceCurtain ? strReverse : strForward;
    itemDirection.customUI = YES;
    itemDirection.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
    itemDirection.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
        [weakself openDirectionPage:cell];
    };
    [curtainSettings addObject:itemDirection];
    
    //清除行程
    MHLumiSettingCellItem *itemClear = [[MHLumiSettingCellItem alloc] init];
    itemClear.identifier = @"mydevice.gateway.sensor.curtain.clearitinerary";
    itemClear.lumiType = MHLumiSettingItemTypeDefault;
    itemClear.hasAcIndicator = YES;
    itemClear.caption = strClear;
    itemClear.customUI = YES;
    itemClear.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
    itemClear.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
        [weakself onClearitinerary];
    };
    
    [curtainSettings addObject:itemClear];
    
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
    //手动开关
    MHDeviceSettingItem *itemManual = [[MHDeviceSettingItem alloc] init];
    itemManual.identifier = @"mydevice.gateway.sensor.curtain.manualcontrol";
    itemManual.type = MHDeviceSettingItemTypeSwitch;
    itemManual.hasAcIndicator = NO;
    itemManual.caption = strManual;
    itemManual.comment = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.manualcontrol.comment",@"plugin_gateway","手动开/关窗帘");
    itemManual.customUI = YES;
    itemManual.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
    itemManual.callbackBlock = ^(MHDeviceSettingCell *cell) {
        [weakself onManualControl];
    };
    [curtainSettings addObject:itemManual];
    
    //重命名
    MHLumiSettingCellItem *itemChangeTitle = [[MHLumiSettingCellItem alloc] init];
    itemChangeTitle.identifier = @"mydevice.actionsheet.changename";
    itemChangeTitle.lumiType = MHLumiSettingItemTypeDefault;
    itemChangeTitle.hasAcIndicator = YES;
    itemChangeTitle.caption = strChangeTitle;
    itemChangeTitle.customUI = YES;
    itemChangeTitle.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
    itemChangeTitle.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
        [weakself.curtainVC deviceChangeName];
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
        [weakself.deviceCurtain setShowMode:(int)!weakself.deviceCurtain.showMode success:^(id obj) {
            NSString *strShow = weakself.deviceCurtain.showMode ? NSLocalizedStringFromTable(@"mydevice.gateway.delsub.rmvlist",@"plugin_gateway","撤销显示") : NSLocalizedStringFromTable(@"mydevice.gateway.delsub.addlist",@"plugin_gateway","添加显示");
            cell.lumiItem.caption = strShow;
            [cell fillWithItem:cell.lumiItem];
            [cell finish];
        } failure:^(NSError *v) {
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"setting.failed", @"plugin_gateway","") duration:1.f modal:YES];
        }];
        [weakself gw_clickMethodCountWithStatType:@"actionSheetShowMode"];
    };
    [curtainSettings addObject:itemShowMode];
    
    //FAQ
    MHLumiSettingCellItem *itemFAQ = [[MHLumiSettingCellItem alloc] init];
    itemFAQ.identifier = @"mydevice.gateway.about.freFAQ";
    itemFAQ.lumiType = MHLumiSettingItemTypeDefault;
    itemFAQ.hasAcIndicator = YES;
    itemFAQ.caption = strFAQ;
    itemFAQ.customUI = YES;
    itemFAQ.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
    itemFAQ.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
        [weakself.curtainVC openFAQ:@""];
    };
    
    [curtainSettings addObject:itemFAQ];
    
    //反馈
    MHLumiSettingCellItem *itemFeedback = [[MHLumiSettingCellItem alloc] init];
    itemFeedback.identifier = @"mydevice.actionsheet.feedback";
    itemFeedback.lumiType = MHLumiSettingItemTypeDefault;
    itemFeedback.hasAcIndicator = YES;
    itemFeedback.caption = strFeedback;
    itemFeedback.customUI = YES;
    itemFeedback.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    itemFeedback.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
        [weakself.curtainVC onFeedback];
    };
    
    [curtainSettings addObject:itemFeedback];
    
    group1.items = curtainSettings;
    self.settingGroups = [NSMutableArray arrayWithObjects:group1,nil];
}


#pragma mark - 自动化
-(void)onAddScene {
    MHGatewaySensorViewController *sceneVC = [[MHGatewaySensorViewController alloc] initWithDevice:self.deviceCurtain];
    sceneVC.isHasMore = NO;
    sceneVC.isHasShare = NO;
    [self.navigationController pushViewController:sceneVC animated:YES];
}
#pragma mark - 手动开关
- (void)onManualControl {
    
}
#pragma mark - 安装教程
- (void)onInstallationtutorial {
    MHGatewayCurtainInstallationViewController *installVC = [[MHGatewayCurtainInstallationViewController alloc] init];
    [self.navigationController pushViewController:installVC animated:YES];
}
#pragma mark - 自动化
- (void)onClearitinerary {
}

#pragma mark - 选择方向
- (void)openDirectionPage:(MHLumiSettingCell *)directionCell {
    
    XM_WS(weakself);
    MHLuDeviceSettingGroup* groupSelMotion = [[MHLuDeviceSettingGroup alloc] init];
    NSMutableArray *directionItems = [NSMutableArray arrayWithCapacity:1];
    groupSelMotion.items = directionItems;
    groupSelMotion.title = nil;
    
    NSString *strForward = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.directionchoice.forward",@"plugin_gateway","正向");
    NSString *strReverse = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.directionchoice.reverse",@"plugin_gateway","反向");
    
    MHDeviceSettingItem *itemForward = [[MHDeviceSettingItem alloc] init];
        itemForward.identifier = @"mydevice.gateway.sensor.curtain.directionchoice.forward";
        itemForward.type = MHDeviceSettingItemTypeCheckmark;
        itemForward.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.directionchoice.forward",@"plugin_gateway","正向");
        itemForward.hasAcIndicator = self.deviceCurtain.polarity;
        itemForward.customUI = YES;
        itemForward.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
        itemForward.callbackBlock = ^(MHDeviceSettingCell *cell) {
            
            [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"updating",@"plugin_gateway","正在更新中...") modal:NO];
            
            [weakself.deviceCurtain setPrivateProperty:POLARITY_INDEX value:@(0) success:^(id obj) {
                [[MHTipsView shareInstance] hide];
                [weakself adjustDirectionItems];
                directionCell.lumiItem.comment = strForward;
                [directionCell fillWithItem:directionCell.lumiItem];
                [directionCell finish];
            } failure:^(NSError *v) {
                [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed", @"plugin_gateway",@"请求失败，请检查网络") duration:1.0f modal:NO];
            }];
        };
    
        [directionItems addObject:itemForward];
    
    MHDeviceSettingItem *itemReverse = [[MHDeviceSettingItem alloc] init];
    itemReverse.identifier = @"mydevice.gateway.sensor.curtain.directionchoice.reverse";
    itemReverse.type = MHDeviceSettingItemTypeCheckmark;
    itemReverse.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.directionchoice.reverse",@"plugin_gateway","反向");
    itemReverse.hasAcIndicator = self.deviceCurtain.polarity;
    itemReverse.customUI = YES;
    itemReverse.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    itemReverse.callbackBlock = ^(MHDeviceSettingCell *cell) {
        
        [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"updating",@"plugin_gateway","正在更新中...") modal:NO];
        
        [weakself.deviceCurtain setPrivateProperty:POLARITY_INDEX value:@(1) success:^(id obj) {
            [[MHTipsView shareInstance] hide];
            [weakself adjustDirectionItems];
            directionCell.lumiItem.comment = strReverse;
            [directionCell fillWithItem:directionCell.lumiItem];
            [directionCell finish];
        } failure:^(NSError *v) {
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed", @"plugin_gateway",@"请求失败，请检查网络") duration:1.0f modal:NO];

        }];
    };
    
    [directionItems addObject:itemReverse];

    
    MHLuDeviceSettingViewController* directionVC = [[MHLuDeviceSettingViewController alloc] init];
    directionVC.settingGroups = @[groupSelMotion];
    directionVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.directionchoice",@"plugin_gateway","方向选择");
    directionVC.controllerIdentifier = @"mydevice.gateway.sensor.curtain.directionchoice";
    directionVC.isTabBarHidden = YES;
    [self.navigationController pushViewController:directionVC animated:YES];
}

- (void)adjustDirectionItems {
    if (!_directionVC) {
        return;
    }
    
    MHDeviceSettingItem* item1 = [_directionVC itemWithIdentifier:@"mydevice.gateway.sensor.curtain.directionchoice.forward"];
    item1.hasAcIndicator = self.deviceCurtain.polarity;
    MHDeviceSettingItem* item2 = [_directionVC itemWithIdentifier:@"mydevice.gateway.sensor.curtain.directionchoice.reverse"];
    item2.hasAcIndicator = self.deviceCurtain.polarity;
    [_directionVC reloadItemAtIndex:[_directionVC indexOfItemWithIdentifier:@"mydevice.gateway.sensor.curtain.directionchoice.forward"] atSection:0];
    [_directionVC reloadItemAtIndex:[_directionVC indexOfItemWithIdentifier:@"mydevice.gateway.sensor.curtain.directionchoice.reverse"] atSection:0];
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
