//
//  MHLumiUICameraHomeSettingViewController.m
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/10.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiUICameraHomeSettingViewController.h"
#import "MHLumiSettingCell.h"
#import "MHLumiUICameraHomeSetOperatingModeViewController.h"
#import "MHGatewayWebViewController.h"
#import "MHFeedbackDeviceDetailViewController.h"
#import "MHGatewayAboutViewController.h"
#import "MHSingleFirmwareUpdateViewController.h"
#import "MHDevShareAddMenuViewController.h"
#import "NSString+Emoji.h"

@implementation MHLumiUICameraHomeSettingViewController
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
    __weak typeof(self) weakself = self;
    NSString* sizeOfView = @"画面尺寸";//NSLocalizedStringFromTable(@"mydevice.actionsheet.changename",@"plugin_gateway","修改设备名称");
    NSString* overturn = @"图像翻转";
    NSString* overturnComment = @"摄像机倒转时，开启此项";
    NSString* common = @"通用设置";
    MHLuDeviceSettingGroup* group1 = [[MHLuDeviceSettingGroup alloc] init];
    NSMutableArray *curtainSettings = [NSMutableArray new];
    
    //工作模式
    MHLumiSettingCellItem *itemSizeOfView = [[MHLumiSettingCellItem alloc] init];
    itemSizeOfView.identifier = @"mydevice.camera.homesetting.sizeOfView";
    itemSizeOfView.lumiType = MHLumiSettingItemTypeDefault;
    itemSizeOfView.hasAcIndicator = YES;
    itemSizeOfView.caption = sizeOfView;
    itemSizeOfView.customUI = YES;
    itemSizeOfView.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    itemSizeOfView.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
        MHLumiUICameraHomeSetOperatingModeViewController *vc = [[MHLumiUICameraHomeSetOperatingModeViewController alloc] init];
        vc.cameraDevice = weakself.cameraDevice;
        [weakself.navigationController pushViewController:vc animated:YES];
    };
    [curtainSettings addObject:itemSizeOfView];
    
    //图像翻转
    MHDeviceSettingItem *itemOverturn = [[MHDeviceSettingItem alloc] init];
    itemOverturn.identifier = @"mydevice.camera.homesetting.overturn";
    itemOverturn.type = MHDeviceSettingItemTypeSwitch;
    itemOverturn.caption = overturn;
    itemOverturn.comment = overturnComment;
    itemOverturn.customUI = YES;
    itemOverturn.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    itemOverturn.callbackBlock = ^(MHDeviceSettingCell *cell) {
        [weakself.cameraDevice cameraOverturnWithSuccess:^(MHDeviceCamera *client) {
            [cell finish];
        } failure:^(NSError *error) {
            [cell finish];
        }];
    };
    [curtainSettings addObject:itemOverturn];
    
    //通用设置
    MHLumiSettingCellItem *itemCommon = [[MHLumiSettingCellItem alloc] init];
    itemCommon.identifier = @"mydevice.camera.homesetting.common";
    itemCommon.lumiType = MHLumiSettingItemTypeDefault;
    itemCommon.hasAcIndicator = YES;
    itemCommon.caption = common;
    itemCommon.customUI = YES;
    itemCommon.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    itemCommon.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
        [weakself commonSetting];
    };
    [curtainSettings addObject:itemCommon];
    
    
    group1.items = curtainSettings;
    self.settingGroups = [NSMutableArray arrayWithObjects:group1,nil];
    [self.settingTableView reloadData];
}

- (void)commonSetting{
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
        MHGatewayWebViewController *web = [MHGatewayWebViewController openWebVC:strURL identifier:@"mydevice.camera.about.tutorial" share:NO];
        [self.navigationController pushViewController:web animated:YES];
        [weakself gw_clickMethodCountWithStatType:@"tutorial"];
    }]];
    
    [objArray addObject:[MHPromptKitObject objWithTitle:strSetting isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        MHFeedbackDeviceDetailViewController *detailVC = [MHFeedbackDeviceDetailViewController new];
        detailVC.category = Device;
        detailVC.device = weakself.cameraDevice;
        [weakself.navigationController pushViewController:detailVC animated:YES];
        [weakself gw_clickMethodCountWithStatType:@"freFAQ"];
    }]];
    
    [objArray addObject:[MHPromptKitObject objWithTitle:strAbout isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        [weakself gw_clickMethodCountWithStatType:@"about"];
        MHGatewayAboutViewController *about = [[MHGatewayAboutViewController alloc] init];
        about.gatewayDevice = weakself.cameraDevice;
        [weakself.navigationController pushViewController:about animated:YES];
    }]];
    
    [objArray addObject:[MHPromptKitObject objWithTitle:strChangeTitle isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        [weakself gw_clickMethodCountWithStatType:@"ChangeName"];
        [weakself deviceChangeName];
    }]];
    
    [objArray addObject:[MHPromptKitObject objWithTitle:strShare isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        [weakself gw_clickMethodCountWithStatType:@"Share"];
        MHDevShareAddMenuViewController* shareVC = [[MHDevShareAddMenuViewController alloc] initWithDevices:@[weakself.cameraDevice]];
        [weakself.navigationController pushViewController:shareVC animated:YES];
    }]];
    
    [objArray addObject:[MHPromptKitObject objWithTitle:strUpgrade isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        [weakself gw_clickMethodCountWithStatType:@"UpgradePage"];
        MHSingleFirmwareUpdateViewController* updateVc = [[MHSingleFirmwareUpdateViewController alloc]  initWithDevice:weakself.cameraDevice];
        [weakself.navigationController pushViewController:updateVc animated:YES];
    }]];
    
//    [objArray addObject:[MHPromptKitObject objWithTitle:strFeedback isCancelBtn:NO isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
//        [weakself gw_clickMethodCountWithStatType:@"Feedback"];
//        MHFeedbackDeviceDetailViewController *detailVC = [MHFeedbackDeviceDetailViewController new];
//        detailVC.category = Device;
//        detailVC.device = weakself.cameraDevice;
//        [weakself.navigationController pushViewController:detailVC animated:YES];
//        [weakself gw_clickMethodCountWithStatType:@"freFAQ"];
//    }]];
    
    [objArray addObject:[MHPromptKitObject objWithTitle:cancel isCancelBtn:YES isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
        
    }]];
    
    [[MHPromptKit shareInstance] showPromptInView:self.view withTitle:title withObjects:objArray];
}

- (void)deviceChangeName {
    XM_WS(ws);
    float nameLengthLimit = 20;
    if ([self.cameraDevice.model rangeOfString:@"xiaomi.tv"].length) {
        //小米电视和小米盒子 名称最长10 其它的都是20
        nameLengthLimit = 10;
    }
    [[MHPromptKit shareInstance] showAlertWithHandler:^(NSInteger buttonIndex, NSArray *inputs) {
        XM_SS(ss, ws);
        if (buttonIndex == 0) { //取消
        } else if (buttonIndex == 1) { //重命名
            NSString* name = inputs[0];
            if ([name containsEmoji]) { //含有Emoji
                [[MHTipsView shareInstance] showFailedTips:NSLocalizedString(@"mydevice.changename.tips.containemoji", @"设备名称不能包含颜文字") duration:1.0 modal:NO];
                [ws deviceChangeName];
            } else if ([name length]) {
                [ss.cameraDevice changeName:name success:^(id v) {
                    [[MHTipsView shareInstance] showFinishTips:NSLocalizedString(@"mydevice.changename.tips.succeed","修改设备名称成功") duration:1.0 modal:NO];
                    if ([ss.delegate respondsToSelector:@selector(cameraHomeSettingViewController:didChangDeviceName:)]){
                        [ss.delegate cameraHomeSettingViewController:ss didChangDeviceName:name];
                    }
                    [ws.navigationController popViewControllerAnimated:YES];
                } failure:^(NSError *v) {
                    [[MHTipsView shareInstance] showFailedTips:NSLocalizedString(@"mydevice.changename.tips.failed","修改设备名称失败") duration:1.0 modal:NO];
                }];
            } else {
                [[MHTipsView shareInstance] showFailedTips:NSLocalizedString(@"mydevice.changename.tips.emptyname","設備名稱不能為空") duration:1.0 modal:NO];
            }
        }
    } withTitle:NSLocalizedString(@"mydevice.changename.title","修改设备名称") message:nil style:UIAlertViewStylePlainTextInput inputTextLimit:nameLengthLimit defaultText:self.cameraDevice.name cancelButtonTitle:NSLocalizedString(@"Cancel", "取消") otherButtonTitles:NSLocalizedString(@"Ok", "确定"), nil];
}
@end
