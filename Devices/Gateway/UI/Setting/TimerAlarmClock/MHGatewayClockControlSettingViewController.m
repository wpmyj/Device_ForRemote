//
//  MHGatewayClockControlSettingViewController.m
//  MiHome
//
//  Created by guhao on 4/10/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayClockControlSettingViewController.h"
#import "MHDeviceGatewaySensorMagnet.h"
#import "MHDeviceGatewaySensorMotion.h"
#import "MHDeviceGatewaySensorSwitch.h"
#import "MHDataScene.h"

@interface MHGatewayClockControlSettingViewController ()

@property (nonatomic, weak) MHDeviceSettingCell *alarmItemCell;
@property (nonatomic, strong)  MHDeviceGateway *device;

@end

@implementation MHGatewayClockControlSettingViewController{
    NSArray *_settingGroup;

}


- (id)initWithDevice:(MHDeviceGateway *)device
{
    self = [super init];
    if (self) {
        _device = device;
        [self setTableview];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.automaticallyAdjustsScrollViewInsets = NO;
}





- (void)setTableview {
    XM_WS(weakself);
    MHGatewaySettingGroup *group2 = [[MHGatewaySettingGroup alloc] init];
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
    _settingGroup = [NSArray arrayWithObjects:group2,nil];
    self.settingGroups = [NSArray arrayWithArray:_settingGroup];
    self.alarmItemCell = [self.settingTableView.visibleCells firstObject];
//    self.isOpen = self.currentTimer.isEnabled;
    
    [self.settingTableView reloadData];
}


- (void)buildSubviews
{
    self.settingTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:self.settingTableView];
    self.settingTableView.delegate = self;
    self.settingTableView.dataSource = self;
    self.settingTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - UITableViewDelegate/DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0f;
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
