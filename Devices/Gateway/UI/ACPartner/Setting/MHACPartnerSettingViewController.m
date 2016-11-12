//
//  MHACPartnerSettingViewController.m
//  MiHome
//
//  Created by ayanami on 16/5/20.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerSettingViewController.h"
#import "MHLumiAccessSettingCell.h"
#import "MHLumiVolumeSettingCell.h"
#import "MHGatewayAddSubDeviceListController.h"
#import "MHACPartnerDetailViewController.h"
#import "MHACPartnerAddAcListViewController.h"
#import "MHLumiFMCollectViewController.h"
#import "MHGatewayVolumeSettingViewController.h"
#import "MHACPartnerAddTipsViewController.h"


@interface MHACPartnerSettingViewController ()
@property (nonatomic, strong) MHDeviceAcpartner *acpartner;

@end

@implementation MHACPartnerSettingViewController

- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner
{
    self = [super init];
    if (self) {
        self.isTabBarHidden = YES;
        self.acpartner = acpartner;
        [self dataConstruct];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.more",@"plugin_gateway","更多");
    self.title = self.acpartner.name;
    NSDictionary *params = [self.acpartner getStatusRequestPayload];
    [self.acpartner sendPayload:params success:nil failure:nil];
}

-(void)dataConstruct{
    XM_WS(weakself);
    //    NSString* strIfttt = NSLocalizedStringFromTable(@"profile.entry.triggerAction",@"plugin_gateway","自动化");
    //    NSString* strInstallation =
    
    MHLuDeviceSettingGroup* group1 = [[MHLuDeviceSettingGroup alloc] init];
    NSMutableArray *acSettings = [NSMutableArray new];
    
    
    //音量
//    MHLumiSettingCellItem *itemWinds = [[MHLumiSettingCellItem alloc] init];
//    itemWinds.identifier = @"mydevice.gateway.sensor.curtain.directionchoice";
//    itemWinds.lumiType = MHLumiSettingItemTypeVolume;
//    itemWinds.hasAcIndicator = YES;
//    itemWinds.caption = @"提示音量";
//    itemWinds.customUI = YES;
//    itemWinds.accessories = [[MHStrongBox alloc] initWithDictionary:@{MinValue:@(0), MaxValue:@(100), CurValue:@(20), SettingAccessoryKey_CellHeight : @(70), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
//    itemWinds.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
//        float value = [[cell.item.accessories valueForKey:CurValue class:[NSNumber class]] floatValue];
//
//        [self.acpartner setProperty:GATEWAY_VOLUME_INDEX value:@(value) success:^(id obj) {
//            NSLog(@"%@", obj);
//        } failure:^(NSError *v) {
//            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed", @"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
//                    [cell.item.accessories setValue:@(weakself.acpartner.gateway_volume) forKey:CurValue];
//            [cell fillWithItem:cell.item];
//        }];
//
//        
//    };
//    [acSettings addObject:itemWinds];
    

    //控制
//    MHLumiSettingCellItem *itemMode = [[MHLumiSettingCellItem alloc] init];
//    itemMode.identifier = @"mydevice.gateway.sensor.curtain.directionchoice";
//    itemMode.lumiType = MHLumiSettingItemTypeAccess;
//    itemMode.hasAcIndicator = YES;
//    itemMode.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.control",@"plugin_gateway","空调控制");
//
//    itemMode.customUI = YES;
//    itemMode.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
//    itemMode.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
//        if (weakself.acpartner.ACType == 0) {
//            [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.first",@"plugin_gateway", "请先添加空调") duration:1.5f modal:YES];
//            return;
//        }
//        MHACPartnerDetailViewController *settingVC = [[MHACPartnerDetailViewController alloc] initWithAcpartner:weakself.acpartner];
//        [weakself.navigationController pushViewController:settingVC animated:YES];
//       
//    };
//    [acSettings addObject:itemMode];
    
    //添加空调
    MHLumiSettingCellItem *itemAddAC = [[MHLumiSettingCellItem alloc] init];
    itemAddAC.identifier = @"mydevice.gateway.sensor.curtain.directionchoice";
    itemAddAC.lumiType = MHLumiSettingItemTypeAccess;
    itemAddAC.hasAcIndicator = YES;
    itemAddAC.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add",@"plugin_gateway","添加空调");
    itemAddAC.customUI = YES;
    itemAddAC.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
    itemAddAC.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
        MHACPartnerAddTipsViewController *addlist = [[MHACPartnerAddTipsViewController alloc] initWithAcpartner:weakself.acpartner];
        [weakself.navigationController pushViewController:addlist animated:YES];
    };
    [acSettings addObject:itemAddAC];
    
    MHDeviceSettingItem *volumSetting = [[MHDeviceSettingItem alloc] init];
    volumSetting.identifier = @"volume setting";
    volumSetting.type = MHDeviceSettingItemTypeDefault;
    volumSetting.hasAcIndicator = YES;
    volumSetting.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.volume",@"plugin_gateway","音量设置");
    volumSetting.customUI = YES;
    volumSetting.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(60), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    volumSetting.callbackBlock = ^(MHDeviceSettingCell *cell) {
        [weakself openVolumeSettingPage];
    };
    [acSettings addObject:volumSetting];
    
    MHDeviceSettingItem *xmFM = [[MHDeviceSettingItem alloc] init];
    xmFM.identifier = @"xmFM";
    xmFM.type = MHDeviceSettingItemTypeDefault;
    xmFM.hasAcIndicator = YES;
    xmFM.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm",@"plugin_gateway","网络收音机");
    xmFM.customUI = YES;
    xmFM.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(60), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    xmFM.callbackBlock = ^(MHDeviceSettingCell *cell) {
        [weakself openFMPage];
    };
    [acSettings addObject:xmFM];

   
    //添加子设备
    MHLumiSettingCellItem *itemSwept = [[MHLumiSettingCellItem alloc] init];
    itemSwept.identifier = @"mydevice.gateway.sensor.curtain.directionchoice";
    itemSwept.lumiType = MHLumiSettingItemTypeAccess;
    itemSwept.hasAcIndicator = YES;
    itemSwept.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.addsubdeviceslist",@"plugin_gateway","子设备");
    itemSwept.customUI = YES;
    itemSwept.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
    itemSwept.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
        MHGatewayAddSubDeviceListController *addlist = [[MHGatewayAddSubDeviceListController alloc] init];
        addlist.device = weakself.acpartner;
        MHLuDeviceSettingGroup* group1 = [[MHLuDeviceSettingGroup alloc] init];
        group1.title = NSLocalizedStringFromTable(@"deviceselect.title",@"plugin_gateway", "选择要连接的设备");
        MHLuDeviceSettingGroup* group2 = [[MHLuDeviceSettingGroup alloc] init];
        addlist.settingGroups = [NSMutableArray arrayWithObjects:group1,group2, nil];
        [weakself.navigationController pushViewController:addlist animated:YES];
    };
    [acSettings addObject:itemSwept];
    
        
    group1.items = acSettings;
    self.settingGroups = [NSMutableArray arrayWithObjects:group1,nil];
}
#pragma mark - FM
- (void)openFMPage {
    MHLumiFMCollectViewController *fm = [[MHLumiFMCollectViewController alloc] initWithRadioDevice:_acpartner];
    fm.isTabBarHidden = YES;
    [self.navigationController pushViewController:fm animated:YES];
    [self gw_clickMethodCountWithStatType:@"openFMPage"];
}

#pragma mark - 设置:音量设置
- (void)openVolumeSettingPage {
    MHGatewayVolumeSettingViewController *volumeSettingVC = [[MHGatewayVolumeSettingViewController alloc] initWithDevice:_acpartner];
    volumeSettingVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.volume", @"plugin_gateway","音量设置");
    [self.navigationController pushViewController:volumeSettingVC animated:YES];
    
    [self gw_clickMethodCountWithStatType:@"openVolumeSettingPage"];
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
