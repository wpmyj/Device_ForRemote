//
//  MHGatewayBellSettingViewController.m
//  MiHome
//
//  Created by Lynn on 2/23/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayBellSettingViewController.h"
#import "MHGatewayBellChooseNewViewController.h"
#import "MHGatewayBellChooseViewController.h"
#import "MHGatewayLegSettingCell.h"

@interface MHGatewayBellSettingViewController ()

@property (nonatomic,strong) MHDeviceGateway *gateway;

@end

@implementation MHGatewayBellSettingViewController

- (id)initWithDevice:(MHDeviceGateway *)gateway {
    if (self = [super init]) {
        self.gateway = gateway;
        [self dataConstruct];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"dddd");
}

- (void)dataConstruct {
    XM_WS(weakself);

    MHLuDeviceSettingGroup* group1 = [[MHLuDeviceSettingGroup alloc] init];
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:1];
    
    {
        MHGatewaySettingCellItem *doorbellItem1 = [[MHGatewaySettingCellItem alloc] init];
        doorbellItem1.identifier = @"doorbell";
        doorbellItem1.type = MHGatewaySettingItemTypeLeg;
        doorbellItem1.hasAcIndicator = YES;
        doorbellItem1.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmbell.name",@"plugin_gateway","警戒音");
        int index = [self.gateway.default_music_index[BellGroup_Alarm] intValue];
        NSString *musicname = [MHDeviceGateway getBellNameOfGroup:(BellGroup)BellGroup_Alarm index:index];
        if (index > 1000) musicname = [self.gateway fetchGwDownloadMidName:[NSString stringWithFormat:@"%d",index]];
        doorbellItem1.comment = musicname;
        doorbellItem1.customUI = YES;
        doorbellItem1.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(60), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
        doorbellItem1.callbackBlock = ^(MHDeviceSettingCell *cell) {
            [weakself openAlarmBellChoosePage:cell withGroup:0];
            [weakself gw_clickMethodCountWithStatType:@"alarmChooseVC"];
        };
        [items addObject:doorbellItem1];
    }
    
    {
        if (![self.gateway.model isEqualToString:DeviceModelCamera]){
            MHGatewaySettingCellItem* item = [[MHGatewaySettingCellItem alloc] init];
            item.customUI = YES;
            item.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(60), SettingAccessoryKey_CaptionFontSize : @(14), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
            item.type = MHGatewaySettingItemTypeLeg;
            item.hasAcIndicator = YES;
            item.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmclock.name",@"plugin_gateway","闹钟音");
            int index = [self.gateway.default_music_index[BellGroup_Welcome] intValue];
            NSString *musicname = @"";
            if (index > 1000) musicname = [self.gateway fetchGwDownloadMidName:[NSString stringWithFormat:@"%d",index]];
            else musicname = [MHDeviceGateway getBellNameOfGroup:(BellGroup)BellGroup_Welcome index:index % 10];
            item.comment = musicname;
            item.callbackBlock = ^(MHDeviceSettingCell *cell) {
                [weakself openAlarmBellChoosePage:cell withGroup:2];
                [weakself gw_clickMethodCountWithStatType:@"alarmClockChooseVC"];
            };
            [items addObject:item];
        }
    }
    
    {
        MHGatewaySettingCellItem *itemDoorBellTone = [[MHGatewaySettingCellItem alloc] init];
        itemDoorBellTone.identifier = @"doubleclickbellchoose";
        itemDoorBellTone.type = MHGatewaySettingItemTypeLeg;
        itemDoorBellTone.hasAcIndicator = YES;
        itemDoorBellTone.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.name",@"plugin_gateway","门铃音");
        int index = [self.gateway.default_music_index[BellGroup_Door] intValue];
        NSString *musicname = [MHDeviceGateway getBellNameOfGroup:BellGroup_Door index:index % 10];
        if (index > 1000) musicname = [self.gateway fetchGwDownloadMidName:[NSString stringWithFormat:@"%d",index]];
        itemDoorBellTone.comment = musicname;
        itemDoorBellTone.customUI = YES;
        itemDoorBellTone.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(60), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
        itemDoorBellTone.callbackBlock = ^(MHDeviceSettingCell *cell) {
            [weakself openAlarmBellChoosePage:cell withGroup:1];
            [weakself gw_clickMethodCountWithStatType:@"bellChooseVC"];
        };
        [items addObject:itemDoorBellTone];
    }
    group1.items = items;
    self.settingGroups = [NSMutableArray arrayWithObjects:group1, nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openAlarmBellChoosePage:(MHDeviceSettingCell *)cell withGroup:(NSInteger)group {
    NSString *title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmbell.name",@"plugin_gateway","警戒音");
    if(group == 1){
        title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.name",@"plugin_gateway","门铃音");
    }
    else if (group == 2){
        title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmclock.name",@"plugin_gateway","闹钟音");
    }
    
    if([self.gateway laterV3Gateway]){
        MHGatewayBellChooseNewViewController *bellChooseVC = [[MHGatewayBellChooseNewViewController alloc] initWithGateway:self.gateway musicGroup:group];
        bellChooseVC.title = title;
        bellChooseVC.controllerIdentifier = @"mydevice.gateway.setting.alarmbell.tone";
        bellChooseVC.onSelectMusic = ^(NSString* musicName) {
            cell.item.comment = musicName;
            [cell fillWithItem:cell.item];
            [cell finish];
        };
        [self.navigationController pushViewController:bellChooseVC animated:YES];
    }
    else{
        MHGatewayBellChooseViewController* bellChooseVC = [[MHGatewayBellChooseViewController alloc] initWithGateway:self.gateway musicGroup:group];
        bellChooseVC.title = title;
        bellChooseVC.controllerIdentifier = @"mydevice.gateway.setting.alarmbell.tone";
        bellChooseVC.onSelectMusic = ^(NSString* musicName) {
            cell.item.comment = musicName;
            [cell fillWithItem:cell.item];
            [cell finish];
        };
        [self.navigationController pushViewController:bellChooseVC animated:YES];
    }
}


@end
