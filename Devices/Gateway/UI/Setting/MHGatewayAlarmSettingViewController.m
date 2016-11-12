 //
//  MHGatewayAlarmSettingViewController.m
//  MiHome
//
//  Created by Lynn on 10/16/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayAlarmSettingViewController.h"
#import "MHGatewayTimerSettingNewViewController.h"
#import "MHGatewayBellChooseViewController.h"
#import "MHGatewayBellChooseNewViewController.h"
#import "MHDeviceGatewaySensorSwitch.h"
#import "MHDeviceGatewaySensorMotion.h"
#import "MHDeviceGatewaySensorMagnet.h"
#import "MHDeviceGatewaySensorCube.h"
#import "MHLuDeviceSettingViewController.h"
#import "MHGatewayLegSettingCell.h"
#import "MHGatewayDurationSettingViewController.h"
#import "MHLumiAccessSettingCell.h"
#import "MHGatewayAlarmModeViewController.h"
#import "MHGatewayBindSceneManager.h"


@interface MHGatewayAlarmSettingViewController ()

@property (nonatomic,strong) MHDeviceGateway* gateway;
@property (nonatomic, assign) BOOL isRedFlash;
@property (nonatomic, assign) NSInteger alarmDuration;

@property (nonatomic, strong) MHDeviceSettingItem *redflashItem;
@property (nonatomic, strong) MHGatewaySettingCellItem *alarmDurationItem;

@end

@implementation MHGatewayAlarmSettingViewController

- (id)initWithGateway:(MHDeviceGateway*)gateway {
    if (self = [super init]) {
        self.gateway = gateway;
        //读取缓存
        if (![_gateway.model isEqualToString:@"lumi.gateway.v1"]) {

            self.gateway.isShowAlarmDelay = YES;
        }
        self.gateway.arming_delay = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_arming_delay_%@",self.gateway.did]] intValue];
 
        [self dataConstruct];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.isTabBarHidden = YES;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![self.gateway laterV3Gateway]) {
        [self.gateway getBindListOfSensorsWithSuccess:nil failure:nil];
    }
    if ([self.gateway laterV3Gateway]) {
        [[MHGatewayBindSceneManager sharedInstance] fetchBindSceneList:self.gateway withSuccess:nil];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    NSLog(@"dddd");
}

-(void)dataConstruct{
    [_gateway getTimerListWithSuccess:nil failure:nil];

    XM_WS(weakself);
    MHGatewaySettingGroup* group1 = [[MHGatewaySettingGroup alloc] init];
    NSMutableArray *alermTimer = [NSMutableArray arrayWithCapacity:1];
    group1.items = alermTimer;
    group1.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.timer",@"plugin_gateway","定时警戒");
    
    MHDeviceSettingItem *item1 = [[MHDeviceSettingItem alloc] init];
    item1.identifier = @"alarmtimer";
    item1.type = MHDeviceSettingItemTypeDefault;
    item1.hasAcIndicator = YES;
    item1.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.timerMode",@"plugin_gateway","定时开启警戒模式");
    item1.customUI = YES;
    item1.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    item1.callbackBlock = ^(MHDeviceSettingCell *cell) {
        [weakself gw_clickMethodCountWithStatType:@"openAlarmTimerPage:"];
        MHGatewayTimerSettingNewViewController *tVC = [[MHGatewayTimerSettingNewViewController alloc] initWithDevice:weakself.gateway andIdentifier:@"lumi_gateway_arming_timer"];
        tVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.timer",@"plugin_gateway","警戒定时");
        tVC.controllerIdentifier = @"alarm";
        __weak MHGatewayTimerSettingNewViewController *weakTimerVC = tVC;
        tVC.onAddNewTimer = ^(MHDataDeviceTimer *newTimer){
            [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.timersetting.adding",@"plugin_gateway","添加定时中，请稍候...") modal:YES];
            newTimer.identify = @"lumi_gateway_arming_timer";
            newTimer.onMethod = @"set_arming";
            newTimer.onParam = @[ @"on" ];
            newTimer.offMethod = @"set_arming";
            newTimer.offParam = @[ @"off" ];
            [weakTimerVC addTimer:newTimer];
        };
        [weakself.navigationController pushViewController:tVC animated:YES];
        [weakself gw_clickMethodCountWithStatType:@"timerSetting"];
    };
    [alermTimer addObject:item1];
    
    
    MHLuDeviceSettingGroup* group2 = [[MHLuDeviceSettingGroup alloc] init];
    NSMutableArray *alermCondition = [NSMutableArray arrayWithCapacity:1];
    group2.items = alermCondition;
    group2.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.group",@"plugin_gateway","警戒触发条件");
    {
        MHDeviceSettingItem *item1 = [[MHDeviceSettingItem alloc] init];
        item1.identifier = @"mydevice.gateway.setting.alarm.group";
        item1.type = MHDeviceSettingItemTypeDefault;
        item1.hasAcIndicator = YES;
        item1.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.group.devices",@"plugin_gateway","警戒触发设备");
        item1.customUI = YES;
        item1.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
        item1.callbackBlock = ^(MHDeviceSettingCell *cell) {
            [weakself alarmItems];
        };
        [alermCondition addObject:item1];
        
        if (self.gateway.isShowAlarmDelay) {
            MHLumiSettingCellItem *itemHoldTime = [[MHLumiSettingCellItem alloc] init];
            itemHoldTime.identifier = @"itemHoldTime";
            itemHoldTime.lumiType = MHLumiSettingItemTypeAccess;
            itemHoldTime.hasAcIndicator = YES;
            itemHoldTime.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.holdtime",@"plugin_gateway","延时生效时间");
            NSString *accessIdentifier = [NSString stringWithFormat:@"mydevice.gateway.setting.alarm.holdtime.%d", self.gateway.arming_delay];
            itemHoldTime.comment = NSLocalizedStringFromTable(accessIdentifier,@"plugin_gateway","延时生效时间");
            itemHoldTime.accessText = [self alarmDelayString];
            itemHoldTime.customUI = YES;
            itemHoldTime.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
            itemHoldTime.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
                [weakself ajustAlarmDelay:^(NSNumber *time) {
                    NSString *accessIdentifier = [NSString stringWithFormat:@"mydevice.gateway.setting.alarm.holdtime.%@", time];
                    cell.lumiItem.comment = NSLocalizedStringFromTable(accessIdentifier,@"plugin_gateway","延时生效时间");
                    cell.lumiItem.accessText = [weakself alarmDelayString];
                    [cell fillWithItem:cell.lumiItem];
                    [cell finish];
                }];

            };
            [alermCondition addObject:itemHoldTime];
        }
    }
    
    MHLuDeviceSettingGroup* group3 = [[MHLuDeviceSettingGroup alloc] init];
    NSMutableArray *doorbellItems = [NSMutableArray arrayWithCapacity:1];
    group3.items = doorbellItems;
    group3.title = nil;
    {
        
        MHDeviceSettingItem *itemAlarmMode = [[MHDeviceSettingItem alloc] init];
        itemAlarmMode.identifier = @"alarmMode";
        itemAlarmMode.type = MHDeviceSettingItemTypeDefault;
        itemAlarmMode.hasAcIndicator = YES;
        itemAlarmMode.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.moresettings",@"plugin_gateway","更多设置");
        itemAlarmMode.customUI = YES;
        itemAlarmMode.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
        itemAlarmMode.callbackBlock = ^(MHDeviceSettingCell *cell) {
            MHGatewayAlarmModeViewController *alarmModeVC = [[MHGatewayAlarmModeViewController alloc] initWithGateway:weakself.gateway];
            [weakself.navigationController pushViewController:alarmModeVC animated:YES];
            [self gw_clickMethodCountWithStatType:@"openAlarmMoresettingsPage:"];
        };
        [doorbellItems addObject:itemAlarmMode];
    }
    
    self.settingGroups = [NSMutableArray arrayWithObjects:group1, group2, group3, nil];
}

#pragma mark - 警戒铃音
- (void)openAlarmBellChoosePage:(MHDeviceSettingCell *)cell {
    if([self.gateway laterV3Gateway]){
        MHGatewayBellChooseNewViewController *bellChooseVC = [[MHGatewayBellChooseNewViewController alloc] initWithGateway:self.gateway musicGroup:0];
        bellChooseVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmbell.tone",@"plugin_gateway","选择报警铃音");
        bellChooseVC.controllerIdentifier = @"mydevice.gateway.setting.alarmbell.tone";
        bellChooseVC.onSelectMusic = ^(NSString* musicName) {
            cell.item.comment = musicName;
            [cell fillWithItem:cell.item];
            [cell finish];
        };
        [self.navigationController pushViewController:bellChooseVC animated:YES];
    }
    else{
        MHGatewayBellChooseViewController* bellChooseVC = [[MHGatewayBellChooseViewController alloc] initWithGateway:self.gateway musicGroup:0];
        bellChooseVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmbell.tone",@"plugin_gateway","选择报警铃音");
        bellChooseVC.controllerIdentifier = @"mydevice.gateway.setting.alarmbell.tone";
        bellChooseVC.onSelectMusic = ^(NSString* musicName) {
            cell.item.comment = musicName;
            [cell fillWithItem:cell.item];
            [cell finish];
        };
        [self.navigationController pushViewController:bellChooseVC animated:YES];
    }
    [self gw_clickMethodCountWithStatType:@"openAlarmBellChoosePage:"];
}



- (NSString* )alarmDelayString {
    NSLog(@"%d", self.gateway.arming_delay);
    if (self.gateway.arming_delay == Gateway_Alarm_Hold_Time_0Sec) {
        return NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.holdtime.reminder.0",@"plugin_gateway","点击警戒后,立即进入警戒模式");
    }
    else {
        return [NSString stringWithFormat:@"%@%d%@", NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.holdtime.reminder",@"plugin_gateway","点击警戒后,") ,self.gateway.arming_delay, NSLocalizedStringFromTable(@"mydevice.gateway.arming.status",@"plugin_gateway","秒后进入警戒状态")];
    }
}


#pragma mark - 警戒触发条件
- (void)alarmItems {
    XM_WS(weakself);
    
    MHGatewaySettingGroup* group = [[MHGatewaySettingGroup alloc] init];
    NSMutableArray *alarmItems = [[NSMutableArray alloc] init];
    group.items = alarmItems;
    
    [self.gateway.subDevices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MHDeviceGatewayBase* device = obj;
        if (device.isOnline
            && ([device isKindOfClass:[MHDeviceGatewaySensorMotion class]]
                || [device isKindOfClass:[MHDeviceGatewaySensorSwitch class]]
                || [device isKindOfClass:[MHDeviceGatewaySensorMagnet class]]
                || [device isKindOfClass:[MHDeviceGatewaySensorCube class]])) {
                MHDeviceSettingItem *alarmItem = [[MHDeviceSettingItem alloc] init];
                alarmItem.type = MHDeviceSettingItemTypeSwitch;
                alarmItem.caption = device.name;
                alarmItem.isOn = [device isSetAlarming];
                alarmItem.customUI = YES;
                alarmItem.accessories = [[MHStrongBox alloc] initWithDictionary:@{@"sensor" : device,SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
                
                if( [device isKindOfClass:[MHDeviceGatewaySensorSwitch class]] ){
                    alarmItem.identifier = [NSString stringWithFormat:@"%@_%d", @"switch", (int)idx];;
                    alarmItem.comment = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.switch.detail",@"plugin_gateway","有人按键报警");
                }
                if([device isKindOfClass:[MHDeviceGatewaySensorMotion class]]){
                    alarmItem.identifier = [NSString stringWithFormat:@"%@_%d", @"motion", (int)idx];
                    alarmItem.comment = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.motion.detail",@"plugin_gateway","有人经过报警");
                }
                if([device isKindOfClass:[MHDeviceGatewaySensorMagnet class]]){
                    alarmItem.identifier = [NSString stringWithFormat:@"%@_%d", @"magnet", (int)idx];
                    alarmItem.comment = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.magnet.detail",@"plugin_gateway","门窗打开报警");
                }
                if([device isKindOfClass:[MHDeviceGatewaySensorCube class]] && ([self.gateway.model isEqualToString:@"lumi.gateway.v3"] || [self.gateway.model isEqualToString:DeviceModelAcpartner])){
                    alarmItem.identifier = [NSString stringWithFormat:@"%@_%d", @"cube", (int)idx];
                    alarmItem.comment = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.cube.detail",@"plugin_gateway","魔方报警");
                }
                if([device isKindOfClass:[MHDeviceGatewaySensorCube class]] && [self.gateway.model isEqualToString:@"lumi.gateway.v2"]){
                    return;
                }
                
                alarmItem.callbackBlock = ^(MHDeviceSettingCell *cell) {
                    MHDeviceGatewayBase* sensor = [cell.item.accessories valueForKey:@"sensor" class:[MHDeviceGatewayBase class]];
                    [weakself gw_clickMethodCountWithStatType:[NSString stringWithFormat:@"switch:%@",sensor.class]];
                    [[MHTipsView shareInstance] showTips:@"" modal:YES];
                    if (cell.item.isOn) {
                        [sensor setAlarmingWithSuccess:^(id v) {
                            [[MHTipsView shareInstance] hide];
                            [cell finish];
                        } failure:^(NSError *v) {
                            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed", @"plugin_gateway",@"请求失败，请检查网络") duration:1.0f modal:NO];
                            cell.item.isOn = !cell.item.isOn;
                            [cell fillWithItem:cell.item];
                            [cell finish];
                        }];
                    }
                    else {
                        [sensor removeAlarmingWithSuccess:^(id v) {
                            [[MHTipsView shareInstance] hide];
                            [cell finish];
                        } failure:^(NSError *error) {
                            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed", @"plugin_gateway",@"请求失败，请检查网络") duration:1.0f modal:NO];
                            cell.item.isOn = !cell.item.isOn;
                            [cell fillWithItem:cell.item];
                            [cell finish];
                        }];
                    }
                };
                
                [alarmItems addObject:alarmItem];
            }
    }];
    
    MHLuDeviceSettingViewController* selMotionVC = [[MHLuDeviceSettingViewController alloc] init];
    selMotionVC.settingGroups = @[group];
    selMotionVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.group.devices",@"plugin_gateway","警戒触发设备");
    selMotionVC.controllerIdentifier = @"mydevice.gateway.setting.alarm.group.devices";
    selMotionVC.isTabBarHidden = YES;
    [self.navigationController pushViewController:selMotionVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"openAlarmDevicesPage:"];
}

#pragma mark - 警戒延时
- (void)ajustAlarmDelay:(void (^)(NSNumber *time))selectedCallBack {
    MHGatewayDurationSettingViewController *delayTime = [[MHGatewayDurationSettingViewController alloc] initWithGatewayDevice:_gateway identifier:@"mydevice.gateway.setting.alarm.holdtime" currentTime:self.gateway.arming_delay];
    delayTime.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.holdtime", @"plugin_gateway",@"");
    delayTime.selectTime = ^(NSNumber *time){
        if (selectedCallBack) {
            selectedCallBack(time);
        }
    };
    [self.navigationController pushViewController:delayTime animated:YES];
    [self gw_clickMethodCountWithStatType:@"openAlarmHoldtimePage:"];
}






@end
