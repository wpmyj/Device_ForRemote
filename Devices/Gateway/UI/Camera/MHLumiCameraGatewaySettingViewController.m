//
//  MHLumiCameraGatewaySettingViewController.m
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/2.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiCameraGatewaySettingViewController.h"
#import "MHDeviceSettingVolumeCell.h"
#import "MHDeviceSettingColorVolumeCell.h"
#import "MHGatewayBaseSettingViewController.h"
#import "MHGatewaySettingCell.h"
#import "MHGatewaySetAlarmClockViewController.h"
#import "MHGatewayAlarmSettingViewController.h"
#import "MHGatewayDoorBellSettingViewController.h"
#import "MHGatewayLightSettingViewController.h"
#import "MHGwMusicInvoker.h"
#import "MHLumiFMCollectViewController.h"
#import "MHGatewayBindSceneManager.h"
#import "MHGatewayBellSettingViewController.h"
#import "MHGatewayVolumeSettingViewController.h"
#import "MHGatewayWebViewController.h"
#import "MHGatewayAddSubDeviceListController.h"
#import "MHDeviceCamera.h"

@interface MHLumiCameraGatewaySettingViewController()
@property (nonatomic, strong) MHDeviceGateway* gateway;
@end

@implementation MHLumiCameraGatewaySettingViewController

- (id)initWithDevice:(MHDeviceGateway *)gateway {
    if (self = [super init]){
        _gateway = gateway;
        [self dataConstruct];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"dddd");
}

- (void)dataConstruct {
    XM_WS(weakself);
    self.title = _gateway.name;
    
    MHLuDeviceSettingGroup* group1 = [[MHLuDeviceSettingGroup alloc] init];
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:1];
    
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
    [items addObject:volumSetting];
    
    MHDeviceSettingItem *bellSetting = [[MHDeviceSettingItem alloc] init];
    bellSetting.identifier = @"bell setting";
    bellSetting.type = MHDeviceSettingItemTypeDefault;
    bellSetting.hasAcIndicator = YES;
    bellSetting.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.bell",@"plugin_gateway","铃音设置");
    bellSetting.customUI = YES;
    bellSetting.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(60), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    bellSetting.callbackBlock = ^(MHDeviceSettingCell *cell) {
        [weakself openBellSetting];
    };
    [items addObject:bellSetting];
    
//    if([_gateway laterV3Gateway]){
//        MHDeviceSettingItem *xmFM = [[MHDeviceSettingItem alloc] init];
//        xmFM.identifier = @"xmFM";
//        xmFM.type = MHDeviceSettingItemTypeDefault;
//        xmFM.hasAcIndicator = YES;
//        xmFM.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm",@"plugin_gateway","网络收音机");
//        xmFM.customUI = YES;
//        xmFM.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(60), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
//        xmFM.callbackBlock = ^(MHDeviceSettingCell *cell) {
//            [weakself openFMPage];
//        };
//        [items addObject:xmFM];
//    }
    

    if (_gateway.shareFlag == MHDeviceUnShared) {
        MHDeviceSettingItem *addSubdev = [[MHDeviceSettingItem alloc] init];
        addSubdev.identifier = @"addsub";
        addSubdev.type = MHDeviceSettingItemTypeDefault;
        addSubdev.hasAcIndicator = YES;
        addSubdev.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.addsubdeviceslist",@"plugin_gateway","子设备");
        addSubdev.customUI = YES;
        addSubdev.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(60), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
        addSubdev.callbackBlock = ^(MHDeviceSettingCell *cell) {
            [weakself openSubDevicesListPage];
        };
        [items addObject:addSubdev];
    }
    group1.items = items;
    self.settingGroups = [NSMutableArray arrayWithObjects:group1, nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.settingTableView.scrollEnabled = YES;
    [self loadStatus];
}

- (void)loadStatus {
    if([_gateway laterV3Gateway]){
        [[MHLumiXMDataManager sharedInstance] fetchProvinceDataManager];
        [_gateway getMusicInfoWithGroup:0 Success:nil failure:nil];
        [_gateway getMusicInfoWithGroup:1 Success:nil failure:nil];
        [_gateway getMusicInfoWithGroup:2 Success:nil failure:nil];
        [[MHGatewayBindSceneManager sharedInstance] restoreBindList:_gateway];
        //缓存FM信息
        if ([_gateway isKindOfClass:[MHDeviceCamera class]]){
            
        }else{
            [_gateway fetchRadioDeviceStatusWithSuccess:nil andFailure:nil];
            [_gateway getAlarmClockData:nil failure:nil];
        }
    }
    [_gateway getTimerListWithSuccess:nil failure:nil];
    //缓存网关下载的音乐名称
    [_gateway fetchGatewayDownloadList];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_gateway restoreStatus];
    [self dataConstruct];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.settingTableView reloadData];
}

#pragma mark - 设置:音量设置
- (void)openVolumeSettingPage {
    MHGatewayVolumeSettingViewController *volumeSettingVC = [[MHGatewayVolumeSettingViewController alloc] initWithDevice:_gateway];
    volumeSettingVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.volume", @"plugin_gateway","音量设置");
    [self.navigationController pushViewController:volumeSettingVC animated:YES];
    
    [self gw_clickMethodCountWithStatType:@"openVolumeSettingPage"];
}

#pragma mark - 铃音设置
- (void)openBellSetting {
    MHGatewayBellSettingViewController *bellSetting = [[MHGatewayBellSettingViewController alloc] initWithDevice:_gateway];
    bellSetting.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.bell",@"plugin_gateway","铃音设置");
    [self.navigationController pushViewController:bellSetting animated:YES];
    [self gw_clickMethodCountWithStatType:@"openBellSettingPage"];
    
}

#pragma mark - FM
- (void)openFMPage {
    MHLumiFMCollectViewController *fm = [[MHLumiFMCollectViewController alloc] initWithRadioDevice:_gateway];
    fm.isTabBarHidden = YES;
    [self.navigationController pushViewController:fm animated:YES];
    
    [self gw_clickMethodCountWithStatType:@"openFMPage"];
}

#pragma mark 设置:添加子设备分类列表
- (void)openSubDevicesListPage {
    MHGatewayAddSubDeviceListController *addlist = [[MHGatewayAddSubDeviceListController alloc] init];
    addlist.device = _gateway;
    MHLuDeviceSettingGroup* group1 = [[MHLuDeviceSettingGroup alloc] init];
    group1.title = NSLocalizedStringFromTable(@"deviceselect.title",@"plugin_gateway", "选择要连接的设备");
    MHLuDeviceSettingGroup* group2 = [[MHLuDeviceSettingGroup alloc] init];
    addlist.settingGroups = [NSMutableArray arrayWithObjects:group1,group2, nil];
    [self.navigationController pushViewController:addlist animated:YES];
    [self gw_clickMethodCountWithStatType:@"openAddDeviceListPage:"];
    
}
@end