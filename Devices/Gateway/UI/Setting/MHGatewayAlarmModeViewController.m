//
//  MHGatewayAlarmModeViewController.m
//  MiHome
//
//  Created by ayanami on 16/6/28.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayAlarmModeViewController.h"
#import "MHGatewayTimerSettingNewViewController.h"
#import "MHGatewayBellChooseViewController.h"
#import "MHGatewayBellChooseNewViewController.h"
#import "MHDeviceSettingVolumeCell.h"
#import "MHLuDeviceSettingViewController.h"
#import "MHGatewayDurationSettingViewController.h"
#import "MHGatewayVolumeSettingCell.h"
#import "MHGatewayLegSettingCell.h"
#import "MHLumiAccessSettingCell.h"
#import "MHGatewayLinkAlarmViewController.h"
#import "MHGatewaySceneManager.h"
#import "MHDataScene.h"

@interface MHGatewayAlarmModeViewController ()

@property (nonatomic,strong) MHDeviceGateway* gateway;
@property (nonatomic, assign) BOOL isRedFlash;
@property (nonatomic, assign) NSInteger alarmDuration;
@property (nonatomic,strong) NSMutableArray *authed;
@property (nonatomic,strong) NSMutableArray *sceneUsIds;

@property (nonatomic, strong) MHDeviceSettingItem *redflashItem;
@property (nonatomic, strong) MHGatewaySettingCellItem *alarmDurationItem;

@end

@implementation MHGatewayAlarmModeViewController
- (id)initWithGateway:(MHDeviceGateway*)gateway {
    if (self = [super init]) {
        self.gateway = gateway;
        //读取缓存
        [self readStatus];
        
        [self dataConstruct];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //请求新的数据
    [self getPropertySuccess:nil failure:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.gateway setSoundPlaying:@"off" success:nil failure:nil];
}

- (void)dealloc {
    NSLog(@"dddd");
}

-(void)dataConstruct{
    [_gateway getTimerListWithSuccess:nil failure:nil];
    
    XM_WS(weakself);
    
    
    MHLuDeviceSettingGroup* group3 = [[MHLuDeviceSettingGroup alloc] init];
    NSMutableArray *doorbellItems = [NSMutableArray arrayWithCapacity:1];
    group3.items = doorbellItems;
    group3.title = nil;
//    group3.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.mode",@"plugin_gateway","报警方式");
    {
        __block MHGatewaySettingCellItem *doorbellItem1 = [[MHGatewaySettingCellItem alloc] init];
        doorbellItem1.identifier = @"doorbell";
        doorbellItem1.type = MHGatewaySettingItemTypeLeg;
        doorbellItem1.hasAcIndicator = YES;
        doorbellItem1.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmbell.tone",@"plugin_gateway","选择报警铃音");
        //        int index = [self.gateway.default_music_index[BellGroup_Alarm] intValue];
        int index = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%ld", self.gateway.did, BellGroup_Alarm]] intValue];
        NSString *musicname = [MHDeviceGateway getBellNameOfGroup:(BellGroup)BellGroup_Alarm index:index];
        if (index > 1000) musicname = [self.gateway fetchGwDownloadMidName:[NSString stringWithFormat:@"%d",index]];
        if(![self.gateway laterV3Gateway]){
            [self.gateway getMusicListOfGroup:BellGroup_Alarm success:^(id v) {
                int index = [weakself.gateway.default_music_index[BellGroup_Alarm] intValue];
                NSString *musicname = [MHDeviceGateway getBellNameOfGroup:BellGroup_Alarm index:index];
                if (index > 1000) {
                    musicname = [weakself.gateway fetchGwDownloadMidName:[NSString stringWithFormat:@"%d",index]];
                }
                doorbellItem1.comment = musicname;
                [weakself.settingTableView reloadData];
            } failure:^(NSError *v) {
                
            }];
        }
        else {
            [self.gateway getMusicInfoWithGroup:BellGroup_Alarm Success:^(id v) {
                //default
                int index = [weakself.gateway.default_music_index[BellGroup_Alarm] intValue];
                NSString *musicname = [MHDeviceGateway getBellNameOfGroup:BellGroup_Alarm index:index];
                if (index > 1000) {
                    musicname = [weakself.gateway fetchGwDownloadMidName:[NSString stringWithFormat:@"%d",index]];
                }
                doorbellItem1.comment = musicname;
                [weakself.settingTableView reloadData];
            } failure:^(NSError *v) {
                
            }];
        }
        
        
        doorbellItem1.comment = musicname;
        doorbellItem1.customUI = YES;
        doorbellItem1.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
        doorbellItem1.callbackBlock = ^(MHGatewaySettingCell *cell) {
            [weakself openAlarmBellChoosePage:cell];
        };
        
        [doorbellItems addObject:doorbellItem1];
        
        MHGatewaySettingCellItem *doorbellItem2 = [[MHGatewaySettingCellItem alloc] init];
        doorbellItem2.identifier = @"volume";
        doorbellItem2.type = MHGatewaySettingItemTypeVolume;
        doorbellItem2.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmbell.volume",@"plugin_gateway","报警音量");
        doorbellItem2.customUI = YES;
        doorbellItem2.accessories = [[MHStrongBox alloc] initWithDictionary:@{MinValue:@(0), MaxValue:@(100), CurValue:@(self.gateway.alarming_volume),SettingAccessoryKey_CellHeight : @(70), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
        doorbellItem2.callbackBlock = ^(MHGatewaySettingCell *cell) {
            id volume = [cell.item.accessories valueForKey:CurValue class:[NSNumber class]];
            
            [weakself gw_clickMethodCountWithStatType:@"volume"];
            
            [weakself.gateway setProperty:ALARMING_VOLUME_INDEX value:volume success:^(id v) {
                [cell finish];
            } failure:^(NSError *v) {
                [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
                [cell.item.accessories setValue:@(weakself.gateway.alarming_volume) forKey:CurValue];
                [cell fillWithItem:cell.item];
                [cell finish];
            }];
        };
        [doorbellItems addObject:doorbellItem2];
        if (![_gateway.model isEqualToString:kGatewayModelV1]) {
            
            if (![_gateway.model isEqualToString:DeviceModelAcpartner]) {
                
                //报警闪红灯
                MHDeviceSettingItem *item3 = [[MHDeviceSettingItem alloc] init];
                item3.identifier = @"mydevice.gateway.setting.alarm.redLight";
                item3.type = MHDeviceSettingItemTypeSwitch;
                item3.isOn = self.isRedFlash;
                item3.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.alarming.red",@"plugin_gateway","报警时闪红灯");
                item3.customUI = YES;
                item3.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
                item3.callbackBlock = ^(MHDeviceSettingCell *cell) {
                    [weakself gw_clickMethodCountWithStatType:@"openAlarmRedFlash:"];
                    [weakself setFlash:weakself.isRedFlash ? @(0) : @(1) success:^(id v) {
                        cell.item.isOn = weakself.isRedFlash;
                        [cell fillWithItem:cell.item];
                        [cell finish];
                    } failure:^(NSError *v) {
                        [cell finish];
                    }];
                };
                self.redflashItem = item3;
                [doorbellItems addObject:item3];
            }
            //报警时长
            MHGatewaySettingCellItem *item4 = [[MHGatewaySettingCellItem alloc] init];
            item4.identifier = @"mydevice.gateway.setting.alarm.alarming.duration";
            item4.type = MHGatewaySettingItemTypeLeg;
            item4.hasAcIndicator = YES;
            item4.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.alarming.duration",@"plugin_gateway","报警时长");
            NSString *accessIdentifier = [NSString stringWithFormat:@"mydevice.gateway.setting.alarm.alarming.duration.%ld", self.alarmDuration ? self.alarmDuration : 60];
            if (self.alarmDuration < 60) {
                item4.comment = [NSString stringWithFormat:@"%ld%@", self.alarmDuration, NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.second",@"plugin_gateway","秒")];
            }
            else {
                item4.comment = NSLocalizedStringFromTable(accessIdentifier,@"plugin_gateway","报警时长");
            }
            item4.customUI = YES;
            item4.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
            item4.callbackBlock = ^(MHGatewaySettingCell *cell) {
                [weakself alarmTime:^(NSNumber *time) {
                    weakself.alarmDuration = [time integerValue];
                    [weakself saveStatus];
                    if (weakself.alarmDuration < 60) {
                        cell.item.comment = [NSString stringWithFormat:@"%ld%@", weakself.alarmDuration, NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.second",@"plugin_gateway","秒")];
                    }
                    else {
                        NSString *identifier = [NSString stringWithFormat:@"mydevice.gateway.setting.alarm.alarming.duration.%@", time];
                        cell.item.comment = NSLocalizedStringFromTable(identifier,@"plugin_gateway","报警时长");
                    }
                    [cell fillWithItem:cell.item];
                    [cell finish];
                }];
            };
            self.alarmDurationItem = item4;
            [doorbellItems addObject:item4];
        }
        
        MHDeviceSettingItem *itemDoorBellPush = [[MHDeviceSettingItem alloc] init];
        itemDoorBellPush.identifier = @"alarmPush";
        itemDoorBellPush.type = MHDeviceSettingItemTypeSwitch;
        itemDoorBellPush.comment = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.alarming.push",@"plugin_gateway","手机推送报警消息(必选)");
        itemDoorBellPush.isOn = YES;
        itemDoorBellPush.enabled = NO;
        itemDoorBellPush.customUI = YES;
        NSMutableDictionary* accessories = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(56),SettingAccessoryKey_CellHeight, @(15),SettingAccessoryKey_CommentFontSize,[MHColorUtils colorWithRGB:0x333333],SettingAccessoryKey_CommentFontColor, nil];
        itemDoorBellPush.accessories = [[MHStrongBox alloc] initWithDictionary:accessories];
        [doorbellItems addObject:itemDoorBellPush];
        
//        if (![_gateway.model isEqualToString:DeviceModelAcpartner]) {
        
            MHLumiSettingCellItem *itemLinkAlarm = [[MHLumiSettingCellItem alloc] init];
            itemLinkAlarm.identifier = @"itemLinkAlarm";
            itemLinkAlarm.lumiType = MHLumiSettingItemTypeAccess;
            itemLinkAlarm.hasAcIndicator = YES;
            itemLinkAlarm.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.moresettings.linkalarm",@"plugin_gateway","联动报警");
            itemLinkAlarm.accessText = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.moresettings.linkalarm.comment",@"plugin_gateway","联动其他网关一起报警, 提升安全等级");
            itemLinkAlarm.customUI = YES;
            itemLinkAlarm.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
            itemLinkAlarm.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
                [weakself gw_clickMethodCountWithStatType:@"openLinkalarmPage:"];
                MHGatewayLinkAlarmViewController *linkAlarmVC = [[MHGatewayLinkAlarmViewController alloc] initWithGateway:weakself.gateway];
                [weakself.navigationController pushViewController:linkAlarmVC animated:YES];
                
            };
            [doorbellItems addObject:itemLinkAlarm];
//        }
    }
    
    self.settingGroups = [NSMutableArray arrayWithObjects:group3, nil];
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




#pragma mark - 报警时长
- (void)alarmTime:(void (^)(NSNumber *time))selectedCallBack {
    MHGatewayDurationSettingViewController *durationAlarm = [[MHGatewayDurationSettingViewController alloc] initWithGatewayDevice:_gateway identifier:@"mydevice.gateway.setting.alarm.alarming.duration" currentTime:self.alarmDuration ? self.alarmDuration : 60];
    durationAlarm.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.alarming.duration", @"plugin_gateway",@"");
    durationAlarm.selectTime = ^(NSNumber *time){
        if (selectedCallBack) {
            selectedCallBack(time);
        }
    };
    [self.navigationController pushViewController:durationAlarm animated:YES];
    [self gw_clickMethodCountWithStatType:@"openAlarmingDurationPage:"];
}

#pragma mark- 300网关的一些新属性
- (void)setFlash:(id)value
         success:(void (^)(id))success
         failure:(void (^)(NSError *))failure {
    XM_WS(weakself);
    [self.gateway setDeviceProp:ARMING_PRO_REDFLASH value:value success:^(id respObj) {
        weakself.isRedFlash = [value boolValue];
        NSLog(@"当前的闪红灯状态%d", weakself.isRedFlash);
        [weakself saveStatus];
        if (success) {
            success(respObj);
        }
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}


- (void)getPropertySuccess:(void (^)(id))success
                   failure:(void (^)(NSError *error))failure {
    XM_WS(weakself);
    [self.gateway getDeviceProp:ARMING_PRO_REDFLASH allValue:YES success:^(id respObj) {
        weakself.isRedFlash = [[respObj firstObject] boolValue];
        weakself.alarmDuration = [respObj[1] integerValue];
        [weakself saveStatus];
        [weakself dataConstruct];
        if (success) {
            success(respObj);
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
        if (failure) {
            failure(error);
        }
        
    }];
}

- (void)saveStatus {
    [[NSUserDefaults standardUserDefaults] setObject:@(self.isRedFlash) forKey:[NSString stringWithFormat:@"RedFlash%@%@", self.gateway.did, [MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.alarmDuration) forKey:[NSString stringWithFormat:@"AlarmDuration%@%@", self.gateway.did, [MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)readStatus {
    self.isRedFlash = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"RedFlash%@%@", self.gateway.did, [MHPassportManager sharedSingleton].currentAccount.userId]] boolValue];
    self.alarmDuration = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"AlarmDuration%@%@", self.gateway.did, [MHPassportManager sharedSingleton].currentAccount.userId]] integerValue];
    
    //读取铃音缓存
    [self.gateway restoreGatewayDownloadList];
}



@end
