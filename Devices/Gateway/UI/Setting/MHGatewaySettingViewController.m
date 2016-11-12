//
//  MHGatewaySettingViewController.m
//  MiHome
//
//  Created by Woody on 15/4/7.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import "MHGatewaySettingViewController.h"
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

@implementation MHGatewaySettingViewController
{
    NSInteger   _oldRGB;
    NSInteger   _oldLumin;
    NSInteger   _newRGB;
    NSInteger   _newLumin;

    MHGatewayBaseSettingViewController *_lightSencesVC;
    MHDeviceGateway *                   _gateway;
}

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
        
    MHDeviceSettingItem *item1 = [[MHDeviceSettingItem alloc] init];
    item1.identifier = @"lightcolor";
    item1.type = MHDeviceSettingItemTypeColorVolum;
    item1.customUI = YES;
    item1.caption = NSLocalizedStringFromTable(@"mydevice.gateway.lightcolor",@"plugin_gateway","彩灯颜色");
    item1.accessories = [[MHStrongBox alloc] initWithDictionary:@{MinValue:@(0), MaxValue:@(100), CurValue:@(_oldRGB), SettingAccessoryKey_CellHeight : @(70), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    item1.callbackBlock = ^(MHDeviceSettingCell *cell) {
        id col = [cell.item.accessories valueForKey:CurValue class:[NSNumber class]];
        [weakself setIntegerColor:col lumin:nil];
    };
    
    [items addObject:item1];
    
    MHGatewaySettingCellItem *item2 = [[MHGatewaySettingCellItem alloc] init];
    item2.identifier = @"lightlumin";
    item2.type = MHGatewaySettingItemTypeBrightness;
    item2.caption = NSLocalizedStringFromTable(@"mydevice.gateway.lightlumin",@"plugin_gateway","彩灯亮度");
    item2.customUI = YES;
    item2.accessories = [[MHStrongBox alloc] initWithDictionary:@{MinValue:@(0), MaxValue:@(100), CurValue:@(_oldLumin), SettingAccessoryKey_CellHeight : @(70), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    item2.callbackBlock = ^(MHGatewaySettingCell *cell) {
        
        id lumin = [cell.item.accessories valueForKey:CurValue class:[NSNumber class]];
        NSLog(@"%@", lumin);
        [weakself setIntegerColor:nil lumin:lumin];
        [cell finish];

    };
    [items addObject:item2];
    
    MHDeviceSettingItem *item3 = [[MHDeviceSettingItem alloc] init];
    item3.identifier = @"nightlighcolor";
    item3.type = MHDeviceSettingItemTypeDefault;
    item3.hasAcIndicator = YES;
    item3.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.scenes",@"plugin_gateway","彩灯自动化");
    item3.customUI = YES;
    item3.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(60), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    item3.callbackBlock = ^(MHDeviceSettingCell *cell) {
        [weakself openLightColorPickPage];
    };
    
    [items addObject:item3];
    
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

    if([_gateway.model isEqualToString:@"lumi.gateway.v3"]){
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
        [items addObject:xmFM];
    }
    
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
    if (_gateway.shareFlag == MHDeviceUnShared) {
        [items addObject:addSubdev];
    }
    group1.items = items;
    self.settingGroups = [NSMutableArray arrayWithObjects:group1, nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.settingTableView.scrollEnabled = YES;
    if (!_gateway.night_light_rgb){
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.readfailed", @"plugin_gateway",@"夜灯颜色获取失败，请检查网络状况或退出页面重试") duration:1.0f modal:NO];
    }
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
        [_gateway fetchRadioDeviceStatusWithSuccess:nil andFailure:nil];
    }
    else{
        [_gateway getMusicListOfGroup:0 success:nil failure:nil];
        [_gateway getMusicListOfGroup:1 success:nil failure:nil];
        [_gateway getMusicListOfGroup:2 success:nil failure:nil];
    }
    [_gateway getTimerListWithSuccess:nil failure:nil];
    [_gateway getAlarmClockData:nil failure:nil];

    //缓存网关下载的音乐名称
    [_gateway fetchGatewayDownloadList];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_gateway restoreStatus];
    [self setupLumin:_gateway.night_light_rgb ? _gateway.night_light_rgb : 0x64ff0000];
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

#pragma mark - 设置:彩灯情景
- (void)setGatewayColor:(MHGatewaySettingCell *)cell {
    for (MHGatewaySettingCellItem *item in [_lightSencesVC.settingGroups.firstObject items]){
        item.backGroundRGB = _lightSencesVC.settingTableView.backgroundColor;
    }
    
    NightLightColorSences rgba = NightLightColorSences_Pink;
    switch ([[_lightSencesVC.settingGroups.firstObject items] indexOfObject:(id)cell.gatewayItem]) {
        case 0:
            rgba = NightLightColorSences_Romantic;
            break;
        case 1:
            rgba = NightLightColorSences_Pink;
            break;
        case 2:
            rgba = NightLightColorSences_Golden;
            break;
        case 3:
            rgba = NightLightColorSences_MoonWhite;
            break;
        case 4:
            rgba = NightLightColorSences_Forest;
            break;
        case 5:
            rgba = NightLightColorSences_CharmBlue;
            break;
        default:
            break;
    }
    
    MHGatewaySettingCellItem *item = (MHGatewaySettingCellItem *)cell.item;
    [_gateway setNightLightWithRGBA:rgba];
    item.hasAcIndicator = NO;
    item.backGroundRGB = [_gateway setBackgroundViewRGBA:rgba];
    item.selected = YES;
    [_lightSencesVC.settingTableView reloadData];
    
    [self gw_clickMethodCountWithStatType:[NSString stringWithFormat:@"setIntegerColor:%lu",(unsigned long)rgba]];
}

- (void)openLightColorPickPage {
    XM_WS(weakself);
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:1];
    MHLuDeviceSettingGroup* group1 = [[MHLuDeviceSettingGroup alloc] init];
    
    MHGatewaySettingCellItem *item0 = [[MHGatewaySettingCellItem alloc] init];
    item0.identifier = @"romantic";
    item0.hasAcIndicator = NO;
    item0.selected = [_gateway getCurrentNightLightRGBACompareWith:NightLightColorSences_Romantic];
    item0.backGroundRGB = [_gateway setBackgroundViewRGBA:NightLightColorSences_Romantic];
    item0.type = MHGatewaySettingItemTypeDefault;
    item0.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.scenes.romantic",@"plugin_gateway", "romantic");
    item0.customUI = YES;
    item0.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    item0.callbackBlock = ^(MHGatewaySettingCell *cell) {
        [weakself setGatewayColor:cell];
    };
    [items addObject:item0];
    
    MHGatewaySettingCellItem *item1 = [[MHGatewaySettingCellItem alloc] init];
    item1.identifier = @"pink";
    item1.hasAcIndicator = NO;
    item1.selected = [_gateway getCurrentNightLightRGBACompareWith:NightLightColorSences_Pink];
    item1.backGroundRGB = [_gateway setBackgroundViewRGBA:NightLightColorSences_Pink];
    item1.type = MHGatewaySettingItemTypeDefault;
    item1.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.scenes.pink", @"plugin_gateway","pink");
    item1.customUI = YES;
    item1.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    item1.callbackBlock = ^(MHGatewaySettingCell *cell) {
        [weakself setGatewayColor:cell];
    };
    [items addObject:item1];
    
    MHGatewaySettingCellItem *item2 = [[MHGatewaySettingCellItem alloc] init];
    item2.identifier = @"golden";
    item2.hasAcIndicator = NO;
    item2.selected = [_gateway getCurrentNightLightRGBACompareWith:NightLightColorSences_Golden];
    item2.backGroundRGB = [_gateway setBackgroundViewRGBA:NightLightColorSences_Golden];
    item2.type = MHGatewaySettingItemTypeDefault;
    item2.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.scenes.golden", @"plugin_gateway","golden");
    item2.customUI = YES;
    item2.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    item2.callbackBlock = ^(MHGatewaySettingCell *cell) {
        [weakself setGatewayColor:cell];
    };
    [items addObject:item2];
    
    MHGatewaySettingCellItem *item3 = [[MHGatewaySettingCellItem alloc] init];
    item3.identifier = @"white";
    item3.hasAcIndicator = NO;
    item3.selected = [_gateway getCurrentNightLightRGBACompareWith:NightLightColorSences_MoonWhite];
    item3.backGroundRGB = [_gateway setBackgroundViewRGBA:NightLightColorSences_MoonWhite];
    item3.type = MHGatewaySettingItemTypeDefault;
    item3.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.scenes.white", @"plugin_gateway","white");
    item3.customUI = YES;
    item3.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    item3.callbackBlock = ^(MHGatewaySettingCell *cell) {
        [weakself setGatewayColor:cell];
    };
    [items addObject:item3];
    
    MHGatewaySettingCellItem *item4 = [[MHGatewaySettingCellItem alloc] init];
    item4.identifier = @"forest";
    item4.hasAcIndicator = NO;
    item4.selected = [_gateway getCurrentNightLightRGBACompareWith:NightLightColorSences_Forest];
    item4.backGroundRGB = [_gateway setBackgroundViewRGBA:NightLightColorSences_Forest];
    item4.type = MHGatewaySettingItemTypeDefault;
    item4.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.scenes.forest",@"plugin_gateway", "forest");
    item4.customUI = YES;
    item4.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    item4.callbackBlock = ^(MHGatewaySettingCell *cell) {
        [weakself setGatewayColor:cell];
    };
    [items addObject:item4];
    
    MHGatewaySettingCellItem *item5 = [[MHGatewaySettingCellItem alloc] init];
    item5.identifier = @"blue";
    item5.hasAcIndicator = NO;
    item5.type = MHGatewaySettingItemTypeDefault;
    item5.selected = [_gateway getCurrentNightLightRGBACompareWith:NightLightColorSences_CharmBlue];
    item5.backGroundRGB = [_gateway setBackgroundViewRGBA:NightLightColorSences_CharmBlue];
    item5.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.scenes.charmblue", @"plugin_gateway","blue");
    item5.customUI = YES;
    item5.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    item5.callbackBlock = ^(MHGatewaySettingCell *cell) {
        [weakself setGatewayColor:cell];
    };
    [items addObject:item5];
    
    group1.items = items;
    
    _lightSencesVC = [[MHGatewayBaseSettingViewController alloc] init];
    _lightSencesVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.scenes",@"plugin_gateway","彩灯自动化");
    _lightSencesVC.controllerIdentifier = @"mydevice.gateway.setting.nightlight.scenes";
    _lightSencesVC.settingGroups = [NSMutableArray arrayWithObjects:group1, nil];
    [self.navigationController pushViewController:_lightSencesVC animated:YES];
    
    [self gw_clickMethodCountWithStatType:@"openLightColorPickPage"];
}

- (void)setIntegerColor:(NSNumber *)rgbValue lumin:(NSNumber *)lumin {
    __weak typeof(self) weakSelf = self;
    
    if (lumin)_newLumin = lumin.doubleValue;
    else _newLumin = _newLumin ? _newLumin : _oldLumin;
    
    if (rgbValue) _newRGB = rgbValue.integerValue;
    else _newRGB = _newRGB ? _newRGB : _oldRGB;
    
    NSInteger argb = _newRGB + (_newLumin << 24);
    
    [_gateway setProperty:NIGHT_LIGHT_RGB_INDEX value:@(argb) success:^(id obj) {
        NSLog(@"%@",obj);
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"send.failed",@"plugin_gateway", nil) duration:1.5f modal:YES];
        [weakSelf.settingTableView reloadData];
    }];
    
    [self gw_clickMethodCountWithStatType:@"setIntegerColor:"];
}

- (void)setupLumin:(NSInteger)color {
    if (color < 0) {
        color = 0x64ffffff;
    }
    int r = color >> 16 & 0xff;
    int g = color >> 8 & 0xff;
    int b = color & 0xff;
    long a = color >> 24;
    
    UIColor *c = [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:a/100.0f];
    CGFloat hue, sat, brightness, alpha;
    [c getHue:&hue saturation:&sat brightness:&brightness alpha:&alpha];
    
    _oldRGB = color - (a << 24);
    _oldLumin = alpha * 100;
}

@end
