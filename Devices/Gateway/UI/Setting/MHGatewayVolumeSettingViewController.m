//
//  MHGatewayVolumeSettingViewController.m
//  MiHome
//
//  Created by guhao on 3/16/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayVolumeSettingViewController.h"
#import "MHGatewayVolumeSettingCell.h"

@interface MHGatewayVolumeSettingViewController ()
@property (nonatomic, strong)    MHDeviceGateway *gateway;
@property (nonatomic, strong) NSMutableArray *volumeArray;

@end

@implementation MHGatewayVolumeSettingViewController

- (id)initWithDevice:(MHDeviceGateway *)gateway {
    if (self = [super init]){
        _gateway = gateway;
        [self loadStatus];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isTabBarHidden = YES;
    self.view.backgroundColor = [UIColor lightGrayColor];
//    self.automaticallyAdjustsScrollViewInsets = NO;
    [self dataConstruct];
}

- (void)dealloc {
    NSLog(@"dddd");
}

- (void)dataConstruct {
    XM_WS(weakself);
    MHLuDeviceSettingGroup* group1 = [[MHLuDeviceSettingGroup alloc] init];
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:1];

    MHGatewaySettingCellItem *item1 = [[MHGatewaySettingCellItem alloc] init];
    item1.identifier = @"mydevice.gateway.setting.volume.alarm";
    item1.type = MHGatewaySettingItemTypeVolume;
    item1.customUI = YES;
    item1.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.volume.alarm",@"plugin_gateway",  "报警音量");
    item1.accessories = [[MHStrongBox alloc] initWithDictionary:@{MinValue:@(0), MaxValue:@(100),CurValue:@(_gateway.alarming_volume), SettingAccessoryKey_CellHeight : @(70), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    item1.callbackBlock = ^(MHGatewaySettingCell *cell) {
        float value = [[cell.item.accessories valueForKey:CurValue class:[NSNumber class]] floatValue];
        [weakself openVolumeSetting:ALARMING_VOLUME_INDEX andValue:value andCell:cell];
    };
    
    [items addObject:item1];
    
    if (![self.gateway.model isEqualToString:DeviceModelAcpartner] && ![self.gateway.model isEqualToString:DeviceModelCamera]) {
        MHGatewaySettingCellItem *item2 = [[MHGatewaySettingCellItem alloc] init];
        item2.identifier = @"mydevice.gateway.setting.volume.alarmclock";
        item2.type = MHGatewaySettingItemTypeVolume;
        item2.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.volume.alarmclock",@"plugin_gateway","闹钟音量");
        item2.customUI = YES;
        item2.accessories = [[MHStrongBox alloc] initWithDictionary:@{MinValue:@(0), MaxValue:@(100),CurValue:@(_gateway.clock_volume), SettingAccessoryKey_CellHeight : @(70), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
        item2.callbackBlock = ^(MHGatewaySettingCell *cell) {
            float value = [[cell.item.accessories valueForKey:CurValue class:[NSNumber class]] floatValue];
            [weakself openVolumeSetting:CLOCK_VOLUME_INDEX andValue:value andCell:cell];
        };
        [items addObject:item2];
    }
   
    MHGatewaySettingCellItem *item3 = [[MHGatewaySettingCellItem alloc] init];
    item3.identifier = @"nightlighcolor";
    item3.type = MHGatewaySettingItemTypeVolume;
    item3.hasAcIndicator = YES;
    item3.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.volume.doorbell", @"plugin_gateway", "门铃音量");
    item3.customUI = YES;
    item3.accessories = [[MHStrongBox alloc] initWithDictionary:@{MinValue:@(0), MaxValue:@(100), CurValue:@(_gateway.doorbell_volume),SettingAccessoryKey_CellHeight : @(70), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    item3.callbackBlock = ^(MHGatewaySettingCell *cell) {
        float value = [[cell.item.accessories valueForKey:CurValue class:[NSNumber class]] floatValue];
        [weakself openVolumeSetting:DOORBELL_VOLUME_INDEX andValue:value andCell:cell];

    };
    
    [items addObject:item3];
    if([_gateway.model isEqualToString:@"lumi.gateway.v3"] ||
       [self.gateway.model isEqualToString:DeviceModelAcpartner]){
        MHGatewaySettingCellItem *xmFM = [[MHGatewaySettingCellItem alloc] init];
        xmFM.identifier = @"mydevice.gateway.setting.volume.fm";
        xmFM.type = MHGatewaySettingItemTypeVolume;
        xmFM.hasAcIndicator = YES;
        xmFM.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.volume.fm", @"plugin_gateway", "fm音量");
        xmFM.customUI = YES;
        xmFM.accessories = [[MHStrongBox alloc] initWithDictionary:@{MinValue:@(0), MaxValue:@(100),CurValue:@(_gateway.fm_volume), SettingAccessoryKey_CellHeight : @(70), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
        xmFM.callbackBlock = ^(MHGatewaySettingCell *cell) {
            float value = [[cell.item.accessories valueForKey:CurValue class:[NSNumber class]] floatValue];
            [weakself openVolumeSetting:FM_VOLUME_INDEX andValue:value andCell:cell];
        };
        [items addObject:xmFM];
    }
    
    MHGatewaySettingCellItem *addSubdev = [[MHGatewaySettingCellItem alloc] init];
    addSubdev.identifier = @"mydevice.gateway.setting.volume.system";
    addSubdev.type = MHGatewaySettingItemTypeVolume;
    addSubdev.hasAcIndicator = YES;
    addSubdev.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.volume.system", @"plugin_gateway", "系统音量");
    addSubdev.customUI = YES;
    addSubdev.accessories = [[MHStrongBox alloc] initWithDictionary:@{MinValue:@(0), MaxValue:@(100), CurValue:@(_gateway.gateway_volume), SettingAccessoryKey_CellHeight : @(70), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    addSubdev.callbackBlock = ^(MHGatewaySettingCell *cell) {
        float value = [[cell.item.accessories valueForKey:CurValue class:[NSNumber class]] floatValue];
        [weakself openVolumeSetting:GATEWAY_VOLUME_INDEX andValue:value andCell:cell];

    };
    [items addObject:addSubdev];
    
    group1.items = items;
    self.settingGroups = [NSMutableArray arrayWithObjects:group1, nil];
}
#pragma mark - 获得初始值
- (void)loadStatus {
    [self.gateway restoreClockStatus];
    [self.gateway restoreStatus];
    
    //获取属性
    NSDictionary *params = [self.gateway getStatusRequestPayload];
    [self.gateway sendPayload:params success:nil failure:nil];
    [self.gateway getAlarmClockData:nil failure:nil];
    [self.gateway fetchRadioDeviceStatusWithSuccess:nil andFailure:nil];
}
#pragma mark - 音量设置
- (void)openVolumeSetting:(Gateway_Prop_Id)prop andValue:(float)value andCell:(MHGatewaySettingCell *)cell {
    XM_WS(weakself);
    NSLog(@"当前的值%lf", value);
    [self.gateway setProperty:prop value:@(value) success:^(id obj) {
        NSLog(@"%@", obj);
    } failure:^(NSError *v) {
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed", @"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
        switch (prop) {
            case ALARMING_VOLUME_INDEX:
            [cell.item.accessories setValue:@(weakself.gateway.alarming_volume) forKey:CurValue];
                break;
            case CLOCK_VOLUME_INDEX:
                [cell.item.accessories setValue:@(weakself.gateway.clock_volume) forKey:CurValue];
                break;
            case DOORBELL_VOLUME_INDEX:
                [cell.item.accessories setValue:@(weakself.gateway.doorbell_volume) forKey:CurValue];
                break;
            case FM_VOLUME_INDEX:
                [cell.item.accessories setValue:@(weakself.gateway.fm_volume) forKey:CurValue];
                break;
            case GATEWAY_VOLUME_INDEX:
                [cell.item.accessories setValue:@(weakself.gateway.gateway_volume) forKey:CurValue];
                break;
            default:
                break;
        }
        [cell fillWithItem:cell.item];
    }];

}

- (void)onBack:(id)sender
{
    [self.gateway setSoundPlaying:@"off" success:nil failure:nil];
    [super onBack:sender];
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
