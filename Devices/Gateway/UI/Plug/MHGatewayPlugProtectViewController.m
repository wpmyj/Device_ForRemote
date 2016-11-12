//
//  MHGatewayPlugProtectViewController.m
//  MiHome
//
//  Created by Lynn on 1/4/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayPlugProtectViewController.h"

@interface MHGatewayPlugProtectViewController ()

@property (nonatomic,assign) BOOL poweroffProtectIsOn;
@property (nonatomic,assign) BOOL chargeProtectIsOn;
@property (nonatomic,assign) BOOL indicatorIsOn;

@end

@implementation MHGatewayPlugProtectViewController
{
    MHDeviceSettingItem *           _item1 ;
    MHDeviceSettingItem *           _item2 ;
    MHDeviceSettingItem *           _item3 ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.deviceprotect",@"plugin_gateway","电量统计");
    
    XM_WS(weakself);
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"getting",@"plugin_gateway","获取中，请稍候...") modal:NO];
    [self.devicePlug fetchPlugProtectStatusWithSuccess:^(id obj) {
        [[MHTipsView shareInstance] hide];
        
        NSArray *results = [NSArray arrayWithArray:[obj valueForKey:@"result"]];
        if (results && results.count > 2) {
            weakself.poweroffProtectIsOn = [[obj valueForKey:@"result"][0] boolValue];
            weakself.chargeProtectIsOn = [[obj valueForKey:@"result"][1] boolValue];
            weakself.indicatorIsOn = ![[obj valueForKey:@"result"][2] boolValue];
            [weakself buildTableView];
        }
        
    } failure:^(NSError *error) {
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
    }];
}

- (void)buildSubviews {
    [super buildSubviews];
    [self buildTableView];
}

- (void)buildTableView {
    XM_WS(weakself);
    
    MHLuDeviceSettingGroup* group1 = [[MHLuDeviceSettingGroup alloc] init];
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:1];

    _item1 = [[MHDeviceSettingItem alloc] init];
    _item1.identifier = @"broken";
    _item1.isOn = _poweroffProtectIsOn;
    _item1.type = MHDeviceSettingItemTypeSwitch;
    _item1.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.brokenprotect.title",@"plugin_gateway","断电保护");
    _item1.comment = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.brokenprotect.comment",@"plugin_gateway","断电保护");
    _item1.customUI = YES;
    _item1.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    _item1.callbackBlock = ^(MHDeviceSettingCell *cell) {
        [weakself setProtectInfo:@"poweroff_memory" withCell:cell];
    };
    [items addObject:_item1];
    
    _item2 = [[MHDeviceSettingItem alloc] init];
    _item2.identifier = @"charge";
    _item2.isOn = _chargeProtectIsOn;
    _item2.type = MHDeviceSettingItemTypeSwitch;
    _item2.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.chargeprotect.title",@"plugin_gateway","充电保护");
    _item2.comment = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.chargeprotect.comment",@"plugin_gateway","充电保护");
    _item2.customUI = YES;
    _item2.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    _item2.callbackBlock = ^(MHDeviceSettingCell *cell) {
        [weakself setProtectInfo:@"charge_protect" withCell:cell];
    };
    [items addObject:_item2];
    
    group1.items = items;
    
    _item3 = [[MHDeviceSettingItem alloc] init];
    _item3.identifier = @"indicator";
    _item3.isOn = _indicatorIsOn;
    _item3.type = MHDeviceSettingItemTypeSwitch;
    _item3.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.indicatorlight.title",@"plugin_gateway","指示灯");
    _item3.comment = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.indicatorlight.comment",@"plugin_gateway","指示灯");
    _item3.customUI = YES;
    _item3.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    _item3.callbackBlock = ^(MHDeviceSettingCell *cell) {
        cell.item.isOn = !cell.item.isOn;
        [weakself setProtectInfo:@"en_night_tip_light" withCell:cell];
    };
    [items addObject:_item3];
    
    group1.items = items;
    
    self.settingGroups = [NSMutableArray arrayWithObjects:group1, nil];
    [self.settingTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setProtectInfo:(NSString *)method withCell:(MHDeviceSettingCell *)cell{
    [[MHTipsView shareInstance] showTips:@"" modal:YES];
    
    [self.devicePlug setPlugProtect:method withValue:cell.item.isOn andSuccess:^(id obj) {
        [cell finish];
        [[MHTipsView shareInstance] hide];

    } failure:^(NSError *error) {
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
        cell.item.isOn = !cell.item.isOn;
        [cell fillWithItem:cell.item];
        [cell finish];
    }];
}

@end
