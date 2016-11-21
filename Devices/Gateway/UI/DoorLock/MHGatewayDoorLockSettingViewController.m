//
//  MHGatewayDoorLockSettingViewController.m
//  MiHome
//
//  Created by LM21Mac002 on 16/10/15.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayDoorLockSettingViewController.h"
#import "MHLumiSettingCell.h"
#import "MHGatewayDoorLockModelControlViewController.h"

@implementation MHGatewayDoorLockSettingViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    NSString *title = NSLocalizedStringFromTable(@"mydevice.actionsheet.more",@"plugin_gateway","更多");
    self.title = title;
}

- (void)buildSubviews {
    [super buildSubviews];
    [self settingDatasource];
}

- (void)settingDatasource{
    XM_WS(weakself);
    NSString* strChangeTitle = NSLocalizedStringFromTable(@"mydevice.actionsheet.changename",@"plugin_gateway","修改设备名称");
    NSString* strShowMode = _sensorDoorLock.showMode ? NSLocalizedStringFromTable(@"mydevice.gateway.delsub.rmvlist",@"plugin_gateway","撤销显示") : NSLocalizedStringFromTable(@"mydevice.gateway.delsub.addlist",@"plugin_gateway","添加显示");
    NSString *strFAQ = NSLocalizedStringFromTable(@"mydevice.gateway.about.freFAQ",@"plugin_gateway","常见问题");
    NSString* strFeedback = NSLocalizedStringFromTable(@"mydevice.actionsheet.feedback",@"plugin_gateway","反馈");
    NSString* modelControl = @"工作模式";//NSLocalizedStringFromTable(@"mydevice.actionsheet.feedback",@"plugin_gateway","反馈");
    MHLuDeviceSettingGroup* group1 = [[MHLuDeviceSettingGroup alloc] init];
    NSMutableArray *curtainSettings = [NSMutableArray new];
    
    //控制模式
    MHLumiSettingCellItem *itemModelControl = [[MHLumiSettingCellItem alloc] init];
    itemModelControl.identifier = @"mydevice.actionsheet.changename";
    itemModelControl.lumiType = MHLumiSettingItemTypeDefault;
    itemModelControl.hasAcIndicator = YES;
    itemModelControl.caption = modelControl;
    itemModelControl.customUI = YES;
    itemModelControl.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
    itemModelControl.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
        MHGatewayDoorLockModelControlViewController *vc = [[MHGatewayDoorLockModelControlViewController alloc] init];
        vc.sensorDoorLock = weakself.sensorDoorLock;
        [weakself.navigationController pushViewController:vc animated:YES];
    };
    [curtainSettings addObject:itemModelControl];

    
    //重命名
    MHLumiSettingCellItem *itemChangeTitle = [[MHLumiSettingCellItem alloc] init];
    itemChangeTitle.identifier = @"mydevice.actionsheet.changename";
    itemChangeTitle.lumiType = MHLumiSettingItemTypeDefault;
    itemChangeTitle.hasAcIndicator = YES;
    itemChangeTitle.caption = strChangeTitle;
    itemChangeTitle.customUI = YES;
    itemChangeTitle.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
    itemChangeTitle.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
        [weakself.delegate changeDeviceName:weakself];
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
        [[MHTipsView shareInstance] showTips:@"" modal:YES];
        [weakself.sensorDoorLock setShowMode:(int)!weakself.sensorDoorLock.showMode success:^(id obj) {
            NSString *strShow = weakself.sensorDoorLock.showMode ? NSLocalizedStringFromTable(@"mydevice.gateway.delsub.rmvlist",@"plugin_gateway","撤销显示") : NSLocalizedStringFromTable(@"mydevice.gateway.delsub.addlist",@"plugin_gateway","添加显示");
            cell.lumiItem.caption = strShow;
            [cell fillWithItem:cell.lumiItem];
            [cell finish];
            [[MHTipsView shareInstance] hide];
        } failure:^(NSError *v) {
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"setting.failed", @"plugin_gateway","") duration:1.f modal:YES];
        }];
        [weakself gw_clickMethodCountWithStatType:@"actionSheetShowMode"];
    };
    [curtainSettings addObject:itemShowMode];
    
    //常见问题
    MHLumiSettingCellItem *itemFAQ = [[MHLumiSettingCellItem alloc] init];
    itemFAQ.identifier = @"mydevice.actionsheet.FAQ";
    itemFAQ.lumiType = MHLumiSettingItemTypeDefault;
    itemFAQ.hasAcIndicator = YES;
    itemFAQ.caption = strFAQ;
    itemFAQ.customUI = YES;
    itemFAQ.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    itemFAQ.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
        [weakself.delegate FAQ:weakself];
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
        [weakself.delegate feedback:weakself];
    };
    
    [curtainSettings addObject:itemFeedback];
    
    group1.items = curtainSettings;
    self.settingGroups = [NSMutableArray arrayWithObjects:group1,nil];
    [self.settingTableView reloadData];
}


@end
