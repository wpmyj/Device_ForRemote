//
//  MHGatewayAddSubDeviceListController.m
//  MiHome
//
//  Created by Lynn on 11/19/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayAddSubDeviceListController.h"
#import "MHGatewayAddSubDeviceViewController.h"

@implementation MHGatewayAddSubDeviceListController

-(void)viewDidLoad{
    [super viewDidLoad];
    XM_WS(weakself);
    NSMutableArray *devicesItems = [NSMutableArray arrayWithCapacity:1];
    MHDeviceSettingItem *deviceItem1 = [[MHDeviceSettingItem alloc] init];
    deviceItem1.type = MHDeviceSettingItemTypeDefault;
    deviceItem1.iconName = @"device_icon_gateway_motion";
    deviceItem1.caption = NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.motion",@"plugin_gateway","人体传感器");
    deviceItem1.callbackBlock = ^(MHDeviceSettingCell *cell) {
        [weakself openAddSubDevicesPage:DeviceModelMotionClassName title:NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.motion",@"plugin_gateway","人体传感器")];

    };
    [devicesItems addObject:deviceItem1];
    
    MHDeviceSettingItem *deviceItem2 = [[MHDeviceSettingItem alloc] init];
    deviceItem2.type = MHDeviceSettingItemTypeDefault;
    deviceItem2.iconName = @"device_icon_gateway_magnet";
    deviceItem2.caption = NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.magnet",@"plugin_gateway","门窗传感器");
    deviceItem2.callbackBlock = ^(MHDeviceSettingCell *cell) {
        [weakself openAddSubDevicesPage:DeviceModelMagnetClassName title:NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.magnet",@"plugin_gateway","门窗传感器")];
    };
    [devicesItems addObject:deviceItem2];
    
    MHDeviceSettingItem *deviceItem3 = [[MHDeviceSettingItem alloc] init];
    deviceItem3.type = MHDeviceSettingItemTypeDefault;
    deviceItem3.iconName = @"device_icon_gateway_switcher";
    deviceItem3.caption = NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.switch",@"plugin_gateway","无线开关");
    deviceItem3.callbackBlock = ^(MHDeviceSettingCell *cell) {
        [weakself openAddSubDevicesPage:DeviceModelSwitchClassName title:NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.switch",@"plugin_gateway","无线开关")];
    };
    [devicesItems addObject:deviceItem3];

//    MHDeviceSettingItem *deviceItem4 = [[MHDeviceSettingItem alloc] init];
//    deviceItem4.type = MHDeviceSettingItemTypeDefault;
//    deviceItem4.iconName = @"geBulb_icon_addSubDevices";
//    deviceItem4.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.xbulb",@"plugin_gateway","智能灯泡");
//    deviceItem4.callbackBlock = ^(MHDeviceSettingCell *cell) {
//        [weakself openAddSubDevicesPage:[sensor modelCutVersionCode:DeviceModelgateWaySensorXBulbV1]];
//    };
//    [devicesItems addObject:deviceItem4];
 
        MHDeviceSettingItem *deviceItem5 = [[MHDeviceSettingItem alloc] init];
        deviceItem5.type = MHDeviceSettingItemTypeDefault;
        deviceItem5.iconName = @"device_icon_gateway_plug";
        deviceItem5.caption = NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.plug",@"plugin_gateway","智能插座");
        deviceItem5.callbackBlock = ^(MHDeviceSettingCell *cell) {
            [weakself openAddSubDevicesPage:DeviceModelPlugClassName title:NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.plug",@"plugin_gateway","智能插座")];
        };
        [devicesItems addObject:deviceItem5];

        MHDeviceSettingItem *deviceItem6 = [[MHDeviceSettingItem alloc] init];
        deviceItem6.type = MHDeviceSettingItemTypeDefault;
        deviceItem6.iconName = @"device_icon_gateway_humiture";
        deviceItem6.caption = NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.humiture",@"plugin_gateway","温湿度传感器");;
        deviceItem6.callbackBlock = ^(MHDeviceSettingCell *cell) {
            [weakself openAddSubDevicesPage:DeviceModelHtClassName title:NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.humiture",@"plugin_gateway","温湿度传感器")];
        };
        [devicesItems addObject:deviceItem6];
    

        NSString *title7 = NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.cube",@"plugin_gateway","魔方控制器");
        MHDeviceSettingItem *deviceItem7 = [[MHDeviceSettingItem alloc] init];
        deviceItem7.type = MHDeviceSettingItemTypeDefault;
        deviceItem7.iconName = @"device_icon_gateway_cube";
        deviceItem7.caption = title7;
        deviceItem7.callbackBlock = ^(MHDeviceSettingCell *cell) {
            [weakself openAddSubDevicesPage:DeviceModelCubeClassName title:title7];
        };
        [devicesItems addObject:deviceItem7];

        NSString *title8 = NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.singleneutral",@"plugin_gateway","墙壁开关(ZigBee单键版)");
        MHDeviceSettingItem *deviceItem8 = [[MHDeviceSettingItem alloc] init];
        deviceItem8.type = MHDeviceSettingItemTypeDefault;
        deviceItem8.iconName = @"device_icon_gateway_neutral";
        deviceItem8.caption = title8;
        deviceItem8.callbackBlock = ^(MHDeviceSettingCell *cell) {
            [weakself openAddSubDevicesPage:DeviceModelCtrlNeutral1ClassName title:title8];
        };
        [devicesItems addObject:deviceItem8];
    

        NSString *title9 = NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.doubleneutral",@"plugin_gateway","墙壁开关(ZigBee双键版)");
        MHDeviceSettingItem *deviceItem9 = [[MHDeviceSettingItem alloc] init];
        deviceItem9.type = MHDeviceSettingItemTypeDefault;
        deviceItem9.iconName = @"device_icon_gateway_doubleNeutral";
        deviceItem9.caption = title9;
        deviceItem9.callbackBlock = ^(MHDeviceSettingCell *cell) {
            [weakself openAddSubDevicesPage:DeviceModelCtrlNeutral2ClassName title:title9];
            
        };
        [devicesItems addObject:deviceItem9];
    

        NSString *title10 = NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.singleswitch",@"plugin_gateway","无线开关(贴墙式单键版)");
        MHDeviceSettingItem *deviceItem10 = [[MHDeviceSettingItem alloc] init];
        deviceItem10.type = MHDeviceSettingItemTypeDefault;
        deviceItem10.iconName = @"device_icon_gateway_86switch";
        deviceItem10.caption = title10;
        deviceItem10.callbackBlock = ^(MHDeviceSettingCell *cell) {
            [weakself openAddSubDevicesPage:DeviceModel86Switch1ClassName title:title10];
        };
        [devicesItems addObject:deviceItem10];
    
        NSString *title11 = NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.doubleswitch",@"plugin_gateway","无线开关(贴墙式双键版)");
        MHDeviceSettingItem *deviceItem11 = [[MHDeviceSettingItem alloc] init];
        deviceItem11.type = MHDeviceSettingItemTypeDefault;
        deviceItem11.iconName = @"device_icon_gateway_86switch2";
        deviceItem11.caption = title11;
        deviceItem11.callbackBlock = ^(MHDeviceSettingCell *cell) {
            [weakself openAddSubDevicesPage:DeviceModel86Switch2ClassName title:title11];
        };
        [devicesItems addObject:deviceItem11];
    
   
    if ([self canShowThisDeviceInDeviceListWithModel:DeviceModelgateWaySensorSmokeV1]) {
        NSString *title12 = NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.smoke",@"plugin_gateway","烟雾传感器");
        MHDeviceSettingItem *deviceItem12 = [[MHDeviceSettingItem alloc] init];
        deviceItem12.type = MHDeviceSettingItemTypeDefault;
        deviceItem12.iconName = @"device_icon_smoke";
        deviceItem12.caption = title12;
        deviceItem12.callbackBlock = ^(MHDeviceSettingCell *cell) {
            [weakself openAddSubDevicesPage:DeviceModelSmokeClassName title:title12];
        };
        [devicesItems addObject:deviceItem12];

    }
   

    if ([self canShowThisDeviceInDeviceListWithModel:DeviceModelgateWaySensorNatgasV1]) {
        NSString *title13 = NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.natgas",@"plugin_gateway","气体传感器");
        MHDeviceSettingItem *deviceItem13 = [[MHDeviceSettingItem alloc] init];
        deviceItem13.type = MHDeviceSettingItemTypeDefault;
        deviceItem13.iconName = @"device_icon_natgas";
        deviceItem13.caption = title13;
        deviceItem13.callbackBlock = ^(MHDeviceSettingCell *cell) {
            [weakself openAddSubDevicesPage:DeviceModelNatgasClassName title:title13];
        };
        [devicesItems addObject:deviceItem13];
    }
    
//    if ([self canShowThisDeviceInDeviceListWithModel:DeviceModelgateWaySensorSmokeV1]) {
//        
//    }
    
    
    
   
    
    MHLuDeviceSettingGroup* group1 = [[MHLuDeviceSettingGroup alloc] init];
    group1.items = devicesItems;
    group1.title = NSLocalizedStringFromTable(@"deviceselect.title",@"plugin_gateway", "选择要连接的设备");
    MHLuDeviceSettingGroup* group2 = [[MHLuDeviceSettingGroup alloc] init];
    self.settingGroups = [NSMutableArray arrayWithObjects:group1,group2, nil];
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.addsubdeviceslist", @"plugin_gateway","添加子设备");
    self.controllerIdentifier = @"mydevice.gateway.setting.addsubdeviceslist";
    
}

- (BOOL)canShowThisDeviceInDeviceListWithModel:(NSString *)deviceModel {
    BOOL canShow = NO;
    //白名单配置
    NSString *canShowThisModel12 =
    [[NSUserDefaults standardUserDefaults] valueForKey:[self.device modelCutVersionCode:deviceModel]];
    //公用配置
    NSString *canShowThisModelPublic12 =
    [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%@public", [self.device modelCutVersionCode:deviceModel]]];
    if ([canShowThisModel12 isEqualToString:@"yes"] || [canShowThisModelPublic12 isEqualToString:@"yes"]) {
        canShow = YES;
    }
    return canShow;
}

#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 36.f;
}

#pragma mark 设置:添加子设备
- (void)openAddSubDevicesPage :(NSString *)deviceModel title:(NSString *)title {
    MHGatewayAddSubDeviceViewController *addSubDevicesVC = [[MHGatewayAddSubDeviceViewController alloc] initWithGateway:self.device andDeviceModel:deviceModel];
    addSubDevicesVC.controllerIdentifier = deviceModel;
    addSubDevicesVC.title = title;
    [self.navigationController pushViewController:addSubDevicesVC animated:YES];
    [self gw_clickMethodCountWithStatType:[NSString stringWithFormat:@"openAddSubDevicesPage:%@",deviceModel]];
}

@end
