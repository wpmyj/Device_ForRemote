//
//  MHGatewaySetAlarmClockViewController.m
//  MiHome
//
//  Created by Lynn on 8/10/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHGatewaySetAlarmClockViewController.h"
#import "MHGatewaySettingCell.h"
#import "MHDeviceGatewaySensorMagnet.h"
#import "MHDeviceGatewaySensorMotion.h"
#import "MHDeviceGatewaySensorSwitch.h"
#import "MHAlarmClockTimerViewController.h"
#import "MHGatewayAlarmClockTimerTools.h"

@interface MHGatewaySetAlarmClockViewController ()
@property (nonatomic,assign) BOOL isOpen;
@property (nonatomic,weak) MHDeviceSettingCell *alarmItemCell;

@end

@implementation MHGatewaySetAlarmClockViewController
{
    NSArray *_settingGroup;
    MHGatewaySettingCellItem *_item1;
    
    NSString *_title;
    NSString *_detail;
    NSString *_timespace;
}

- (void)setIsOpen:(BOOL)isOpen {
    _isOpen = isOpen;
    if (!isOpen){
        _timespace = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmclock.timerclose", @"plugin_gateway",@"未启用闹钟");
        _item1.identifier = _timespace;
        self.settingGroups = [NSArray arrayWithObjects:_settingGroup[0],nil];
        [self.settingTableView reloadData];
    }
    else {
        _timespace = [[MHGatewayAlarmClockTimerTools sharedInstance] fetchTimeSpace:self.device.alarm_clock_timer andIdentifier:NextIdentifierOn];
        _item1.identifier = _timespace;
        self.settingGroups = [NSArray arrayWithObjects:_settingGroup[0],_settingGroup[1],nil];
        [self.settingTableView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.device restoreClockStatus];
    
    //小时
    if((self.device.alarm_clock_hour >9 && self.device.alarm_clock_hour <=12 )|| self.device.alarm_clock_hour > 21)
        _title = [NSString stringWithFormat:@"%d:",
                  (self.device.alarm_clock_hour>12)? self.device.alarm_clock_hour - 12:self.device.alarm_clock_hour];
    else
        _title = [NSString stringWithFormat:@"0%d:",
                  (self.device.alarm_clock_hour>12)? self.device.alarm_clock_hour - 12:self.device.alarm_clock_hour];
    //分钟
    if (self.device.alarm_clock_min < 10)
        _title = [_title stringByAppendingFormat:@"0%d",self.device.alarm_clock_min];
    else
        _title = [_title stringByAppendingFormat:@"%d",self.device.alarm_clock_min];
    //上午下午
    _title = [_title stringByAppendingFormat:@" %@",
              self.device.alarm_clock_hour>12? NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmclock.pm",@"plugin_gateway",""):NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmclock.am",@"plugin_gateway","")];
    
    _detail = [self.device parseDayValue:self.device.alarm_clock_day timer:nil];
    self.isOpen = self.device.alarm_clock_enable;
    
    [self setTableview];
    
    __weak typeof(self) weakSelf = self;
    [self.device getAlarmClockData:^(id v){
        [weakSelf setTableview];
    } failure:nil];
}

- (void)setTableview {
    XM_WS(weakself);
    MHLuDeviceSettingGroup* group1 = [[MHLuDeviceSettingGroup alloc] init];
    {
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:1];
        
        _item1 = [[MHGatewaySettingCellItem alloc] init];
        _item1.customUI = YES;
        _item1.type = MHGatewatSettingItemTypeDetailSwitch;
        _item1.caption = _title;
        _item1.comment = _detail;
        _item1.identifier = _timespace;
        _item1.isOn = self.device.alarm_clock_enable;
        _item1.callbackBlock = ^(MHDeviceSettingCell *cell) {
            if (weakself.device.shareFlag == MHDeviceShared) {
                [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.timersetting.noright", @"plugin_gateway", "被分享设备无此权限") duration:1.0 modal:NO];
                return;
            }
            cell.item.isOn = !cell.item.isOn;
            [weakself gw_clickMethodCountWithStatType:@"openAlarm:"];
            [weakself openAlarm:cell];
            cell.userInteractionEnabled = NO;
        };
        [items addObject:_item1];
        
        group1.items = items;
        group1.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmclock.group1title",@"plugin_gateway","请选择闹钟时间");
    }
    
    MHLuDeviceSettingGroup* group2 = [[MHLuDeviceSettingGroup alloc] init];
    {
        NSMutableArray *alarmItems = [NSMutableArray arrayWithCapacity:1];
        MHDeviceSettingItem *item1 = [[MHDeviceSettingItem alloc] init];
        item1.identifier = @"gatewayclick";
        item1.type = MHDeviceSettingItemTypeSwitch;
        item1.comment = NSLocalizedStringFromTable(@"mydevice.gateway.button",@"plugin_gateway","多功能网关按钮");
        item1.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmclock.gatewayclick.once",@"plugin_gateway","按键一下");
        item1.isOn = YES;
        item1.enabled = NO;
        item1.customUI = YES;
        item1.accessories = [[MHStrongBox alloc] initWithDictionary:@{@"sensor" : _device,SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
        [alarmItems addObject:item1];
        
        [self.device.subDevices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MHDeviceGatewayBase* device = obj;
            if (device.isOnline
                && ([device isKindOfClass:[MHDeviceGatewaySensorSwitch class]]
                || [device isKindOfClass:[MHDeviceGatewaySensorMotion class]]
                || [device isKindOfClass:[MHDeviceGatewaySensorMagnet class]])) {
                MHDeviceSettingItem *alarmItem = [[MHDeviceSettingItem alloc] init];
                alarmItem.type = MHDeviceSettingItemTypeSwitch;
                alarmItem.isOn = [device isSetAlarmClock];
                alarmItem.customUI = YES;
                alarmItem.comment = device.name;
                alarmItem.accessories = [[MHStrongBox alloc] initWithDictionary:@{@"sensor" : device,SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];

                NSString *deviceModel = [device modelCutVersionCode:device.model];
                if([deviceModel isEqualToString:[device modelCutVersionCode:DeviceModelgateWaySensorSwitchV1]]){
                    alarmItem.identifier = [NSString stringWithFormat:@"%@_%ld", @"switch", idx];
                    alarmItem.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmclock.switch.detail",@"plugin_gateway","有人按键报警");
                }
                if([deviceModel isEqualToString:[device modelCutVersionCode:DeviceModelgateWaySensorMotionV1]]){
                    alarmItem.identifier = [NSString stringWithFormat:@"%@_%ld", @"motion", idx];
                    alarmItem.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmclock.motion.detail",@"plugin_gateway","有人经过报警");
                }
                if([deviceModel isEqualToString:[device modelCutVersionCode:DeviceModelgateWaySensorMagnetV1]]){
                    alarmItem.identifier = [NSString stringWithFormat:@"%@_%ld", @"magnet", idx];
                    alarmItem.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmclock.magnet.detail",@"plugin_gateway","门窗打开报警");
                }
                    
                alarmItem.callbackBlock = ^(MHDeviceSettingCell *cell) {
                    MHDeviceGatewayBase* sensor = [cell.item.accessories valueForKey:@"sensor" class:[MHDeviceGatewayBase class]];
                    [weakself gw_clickMethodCountWithStatType:[NSString stringWithFormat:@"switch:%@",sensor.class]];

                    if (cell.item.isOn) {
                        [sensor setStopAlarmClockWithSuccess:^(id v){
                            [cell finish];
                        } failure:^(NSError *error){
                            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
                            cell.item.isOn = !cell.item.isOn;
                            [cell fillWithItem:cell.item];
                            [cell finish];
                        }];
                    }
                    else {
                        [sensor removeStopAlarmClockWithSuccess:^(id v) {
                            [cell finish];
                        } failure:^(NSError *error) {
                            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
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
        group2.items = alarmItems;
        group2.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmclock.group2title", @"plugin_gateway",@"关闭闹钟铃声方式");
    }
    _settingGroup = [NSArray arrayWithObjects:group1,group2,nil];
    self.settingGroups = [NSArray arrayWithArray:_settingGroup];
    self.alarmItemCell = [self.settingTableView.visibleCells firstObject];
    self.isOpen = self.device.alarm_clock_enable;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTableview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openAlarm:(MHDeviceSettingCell *)cell {
    __weak typeof(self) weakSelf = self;
     [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.timersetting.modifying",@"plugin_gateway","修改定时中，请稍候...") modal:YES];
    //如果成功，使能
    self.device.alarm_clock_enable = cell.item.isOn ? 1 : 0;
    NSLog(@"当前的开关装填%d", self.device.alarm_clock_enable);
    [self.device setAlarmClockDataWithEnable:^(id obj){
        [[MHTipsView shareInstance] hide];
        weakSelf.isOpen = cell.item.isOn;
        [cell finish];
        cell.userInteractionEnabled = YES;
    } failure:^(NSError *error){
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
        weakSelf.isOpen = !cell.item.isOn;
        weakSelf.device.alarm_clock_enable = !cell.item.isOn ? 1 : 0;
        cell.item.isOn = !cell.item.isOn;
        [cell finish];
        cell.userInteractionEnabled = YES;
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0 && indexPath.row == 0 ){
        [self openClockSetting];
    }
}

- (void)openClockSetting {
    if (self.device.shareFlag == MHDeviceShared) {
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.timersetting.noright", @"plugin_gateway", "被分享设备无此权限") duration:1.0 modal:NO];
        return;
    }
    XM_WS(weakself);
    MHAlarmClockTimerViewController *timerVC = [[MHAlarmClockTimerViewController alloc] initWithTimer:self.device.alarm_clock_timer];
    timerVC.device = self.device;
    timerVC.duraType = [self fetchDurationType];
    timerVC.onDone = ^(id obj){
        if([obj isKindOfClass:[NSDictionary class]]){
            [weakself.device parseDeviceValue:obj];
            weakself.alarmItemCell.item.isOn = YES;
            [weakself openAlarm:weakself.alarmItemCell];
        }
    };
    [self.navigationController pushViewController:timerVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"openClockSetting"];
}

- (DurationType)fetchDurationType {
    switch(self.device.alarm_clock_duration){
        case 5:
            return FiveMinType;
            break;
        case 10:
            return TenMinType;
            break;
        case 15:
            return FifteenMinType;
            break;
        case 30:
            return HalfHourType;
            break;
        case 0:
            return ForverType;
            break;
        default:
            return ForverType;
    }
}
@end
