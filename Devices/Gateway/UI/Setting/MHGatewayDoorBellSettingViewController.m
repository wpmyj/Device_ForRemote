//
//  MHGatewayDoorBellSettingViewController.m
//  MiHome
//
//  Created by Lynn on 10/16/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayDoorBellSettingViewController.h"
#import "MHGatewayBellChooseViewController.h"
#import "MHGatewayBellChooseNewViewController.h"
#import "MHDeviceGatewaySensorSwitch.h"
#import "MHDeviceSettingVolumeCell.h"
#import "MHGatewayVolumeSettingCell.h"
#import "MHGatewayLegSettingCell.h"
#import "MHDataScene.h"
#import "MHGatewayBindSceneManager.h"
#import "MHGatewayExtraSceneManager.h"

@interface MHGatewayDoorBellSettingViewController ()

@end

@implementation MHGatewayDoorBellSettingViewController
{
    
}

- (id)initWithGateway:(MHDeviceGateway*)gateway {
    if (self = [super init]) {
        self.gateway = gateway;
        
        [self.gateway restoreGatewayDownloadList];
        [self dataConstruct];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"dddd");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    XM_WS(weakself);

    if (![self.gateway laterV3Gateway]){
        [self.gateway getBindListOfSensorsWithSuccess:^(id obj) {
            [weakself dataConstruct];
            [self.settingTableView reloadData];
        } failure:^(NSError *error) {
            
        }];
    }else {
        [[MHGatewayBindSceneManager sharedInstance] fetchBindSceneList:self.gateway withSuccess:nil];
        [[MHGatewayExtraSceneManager sharedInstance] fetchExtraMapTableWithSuccess:nil failure:nil];
    }
   
    
    [self.gateway.systemSceneList enumerateObjectsUsingBlock:^(MHDataScene *scene, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"===%@, ====%@", scene.identify, scene.name);
        if ([scene.identify isEqualToString:@"lm_scene_3_1"]) {
            [scene.actionList enumerateObjectsUsingBlock:^(MHDataAction *action, NSUInteger idx, BOOL * _Nonnull stop) {
                NSLog(@"执行设备的id%@", action.deviceDid);
            }];
        }
    }];
}



-(void)dataConstruct{
    XM_WS(weakself);
    
    //门铃条件
    MHLuDeviceSettingGroup *groupDoorbellCondition = [[MHLuDeviceSettingGroup alloc] init];
    NSMutableArray *doorbellConditionItems = [NSMutableArray arrayWithCapacity:1];
    groupDoorbellCondition.items = doorbellConditionItems;

    
    groupDoorbellCondition.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.condition" ,@"plugin_gateway","门铃触发条件");
    
    MHDeviceSettingItem *itemDoorBellDevice = [[MHDeviceSettingItem alloc] init];
    itemDoorBellDevice.identifier = @"clickbellchoosedevice";
    itemDoorBellDevice.type = MHDeviceSettingItemTypeDefault;
    itemDoorBellDevice.hasAcIndicator = YES;
    itemDoorBellDevice.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.condition.devices",@"plugin_gateway","门铃触发设备");
    itemDoorBellDevice.customUI = YES;
    itemDoorBellDevice.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    itemDoorBellDevice.callbackBlock = ^(MHDeviceSettingCell *cell) {
        [weakself doorbellItems];
    };
    [doorbellConditionItems addObject:itemDoorBellDevice];

    //响铃方式
    MHLuDeviceSettingGroup *groupDoorbellTone = [[MHLuDeviceSettingGroup alloc] init];
    NSMutableArray *doorbellToneItems = [NSMutableArray arrayWithCapacity:1];
    groupDoorbellTone.items = doorbellToneItems;
    groupDoorbellTone.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.tone",@"plugin_gateway","响铃方式");
    
    __block MHGatewaySettingCellItem *itemDoorBellTone = [[MHGatewaySettingCellItem alloc] init];
    itemDoorBellTone.identifier = @"doubleclickbellchoose";
    itemDoorBellTone.type = MHGatewaySettingItemTypeLeg;
    itemDoorBellTone.hasAcIndicator = YES;
    itemDoorBellTone.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.choose",@"plugin_gateway","铃音选择");
    if([weakself.gateway.model isEqualToString:@"lumi.gateway.v3"]){
    }
//    int index = [self.gateway.default_music_index[BellGroup_Door] intValue];
     int index = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%ld", self.gateway.did, BellGroup_Door]] intValue];    
    NSString *musicname = [MHDeviceGateway getBellNameOfGroup:BellGroup_Door index:index % 10];
    if (index > 1000) {
        musicname = [self.gateway fetchGwDownloadMidName:[NSString stringWithFormat:@"%d",index]];
    }
    itemDoorBellTone.comment = musicname;
    if(![weakself.gateway laterV3Gateway]){
        [self.gateway getMusicListOfGroup:BellGroup_Door success:^(id v) {
            int index = [weakself.gateway.default_music_index[BellGroup_Door] intValue];
            NSString *musicname = [MHDeviceGateway getBellNameOfGroup:BellGroup_Door index:index % 10];
            if (index > 1000) {
                musicname = [weakself.gateway fetchGwDownloadMidName:[NSString stringWithFormat:@"%d",index]];
            }
            itemDoorBellTone.comment = musicname;
            [weakself.settingTableView reloadData];
        } failure:^(NSError *v) {
            
        }];
    }
    else {
        [self.gateway getMusicInfoWithGroup:BellGroup_Door Success:^(id v) {
            int index = [weakself.gateway.default_music_index[BellGroup_Door] intValue];
            NSString *musicname = [MHDeviceGateway getBellNameOfGroup:BellGroup_Door index:index % 10];
            if (index > 1000) {
                musicname = [weakself.gateway fetchGwDownloadMidName:[NSString stringWithFormat:@"%d",index]];
            }
            itemDoorBellTone.comment = musicname;
            [weakself.settingTableView reloadData];
        } failure:^(NSError *v) {
            
        }];
    }
    

    itemDoorBellTone.customUI = YES;
    itemDoorBellTone.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
    itemDoorBellTone.callbackBlock = ^(MHDeviceSettingCell *cell) {
        
        if([weakself.gateway laterV3Gateway]){
            MHGatewayBellChooseNewViewController *bellChooseVC = [[MHGatewayBellChooseNewViewController alloc] initWithGateway:weakself.gateway musicGroup:1];
            bellChooseVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.choose",@"plugin_gateway","铃音选择");
            bellChooseVC.controllerIdentifier = @"mydevice.gateway.setting.doorbell.choose";
            bellChooseVC.onSelectMusic = ^(NSString* musicName) {
                cell.item.comment = musicName;
                [cell fillWithItem:cell.item];
                [cell finish];
            };
            [weakself.navigationController pushViewController:bellChooseVC animated:YES];
        }
        else{
            MHGatewayBellChooseViewController *bellChooseVC = [[MHGatewayBellChooseViewController alloc] initWithGateway:weakself.gateway musicGroup:1];
            bellChooseVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.choose",@"plugin_gateway","铃音选择");
            bellChooseVC.controllerIdentifier = @"mydevice.gateway.setting.doorbell.choose";
            bellChooseVC.onSelectMusic = ^(NSString* musicName) {
                cell.item.comment = musicName;
                [cell fillWithItem:cell.item];
                [cell finish];
            };
            [weakself.navigationController pushViewController:bellChooseVC animated:YES];
        }
        
        [weakself gw_clickMethodCountWithStatType:@"bellChooseVC"];
    };
    [doorbellToneItems addObject:itemDoorBellTone];
    
    //门铃音量
    MHGatewaySettingCellItem *itemBellVolume = [[MHGatewaySettingCellItem alloc] init];
    itemBellVolume.identifier = @"volume";
    itemBellVolume.type = MHGatewaySettingItemTypeVolume;
    itemBellVolume.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.volume.doorbell",@"plugin_gateway","门铃音量");
    itemBellVolume.customUI = YES;
    itemBellVolume.accessories = [[MHStrongBox alloc] initWithDictionary:@{MinValue:@(0), MaxValue:@(100), CurValue:@(self.gateway.doorbell_volume),SettingAccessoryKey_CellHeight : @(70), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    itemBellVolume.callbackBlock = ^(MHGatewaySettingCell *cell) {
        id volume = [cell.item.accessories valueForKey:CurValue class:[NSNumber class]];

        [weakself gw_clickMethodCountWithStatType:@"volume"];

        [weakself.gateway setProperty:DOORBELL_VOLUME_INDEX value:volume success:^(id v) {
            [cell finish];
        } failure:^(NSError *v) {
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
            [cell.item.accessories setValue:@(weakself.gateway.doorbell_volume) forKey:CurValue];
            [cell fillWithItem:cell.item];
            [cell finish];
        }];
    };
    [doorbellToneItems addObject:itemBellVolume];
    
    MHDeviceSettingItem *itemDoorBellPush = [[MHDeviceSettingItem alloc] init];
    itemDoorBellPush.identifier = @"DoorBellPush";
    itemDoorBellPush.type = MHDeviceSettingItemTypeSwitch;
    itemDoorBellPush.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.push.title",@"plugin_gateway","消息提醒");
    itemDoorBellPush.comment = NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.push.comment",@"plugin_gateway","有人按门铃发送消息提醒");
    itemDoorBellPush.isOn = [self.gateway.doorbell_push caseInsensitiveCompare:@"on"] == NSOrderedSame;
    itemDoorBellPush.customUI = YES;
    NSMutableDictionary* accessories = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(56),SettingAccessoryKey_CellHeight, @(15),SettingAccessoryKey_CaptionFontSize,[MHColorUtils colorWithRGB:0x333333],SettingAccessoryKey_CaptionFontColor, nil];
    itemDoorBellPush.accessories = [[MHStrongBox alloc] initWithDictionary:accessories];
    itemDoorBellPush.callbackBlock = ^(MHDeviceSettingCell *cell) {
        NSString* value = cell.item.isOn ? @"on" : @"off";
        
        [weakself gw_clickMethodCountWithStatType:@"doorBellPush"];
        
        [weakself.gateway setProperty:DOORBELL_PUSH_INDEX value:value success:^(id v) {
            [cell fillWithItem:cell.item];
            [cell finish];
        } failure:^(NSError *v) {
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
            cell.item.isOn = !cell.item.isOn;
            [cell fillWithItem:cell.item];
            [cell finish];
        }];
    };
    [doorbellToneItems addObject:itemDoorBellPush];

    self.settingGroups = @[groupDoorbellCondition, groupDoorbellTone];
    [self.settingTableView reloadData];
}

#pragma mark - 关闭
-(void)refetchDoorBellStatus{
    BOOL tmp = NO;
    for (MHDeviceGatewayBase *device in self.gateway.subDevices) {
        if (!([device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorMotion")]
            || [device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorSwitch")]
            || [device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorMagnet")])) {
            continue;
        }
        if(device != nil && [device isSetDoorBell]){
            tmp = YES;
        }
    }
}

#pragma mark - 门铃条件
- (void)doorbellItems {
    XM_WS(weakself);
    MHLuDeviceSettingGroup *groupDoorbellCondition = [[MHLuDeviceSettingGroup alloc] init];
    NSMutableArray *doorbellConditionItems = [NSMutableArray arrayWithCapacity:1];
    groupDoorbellCondition.items = doorbellConditionItems;

    NSInteger switchIndex = 0;
    for (MHDeviceGatewayBase *device in self.gateway.subDevices) {
        if (device.isOnline
            && ([device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorMotion")]
                || [device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorSwitch")]
                || [device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorMagnet")])) {
                
                MHDeviceSettingItem *itemClick = [[MHDeviceSettingItem alloc] init];
                itemClick.type = MHDeviceSettingItemTypeSwitch;
                itemClick.caption = device.name;
                itemClick.isOn = (device != nil && [device isSetDoorBell]);
                itemClick.customUI = YES;
                
                NSMutableDictionary* accessories = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(56),SettingAccessoryKey_CellHeight, @(15),SettingAccessoryKey_CaptionFontSize,[MHColorUtils colorWithRGB:0x333333],SettingAccessoryKey_CaptionFontColor, nil];
                if (device) {
                    [accessories setObject:device forKey:@"device"];
                }
                
                if( [device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorMotion")]){
                    itemClick.identifier = [NSString stringWithFormat:@"%@_%d", @"switch", (int)switchIndex];;
                    itemClick.comment = NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.motion.comment",@"plugin_gateway","移动响门铃");
                }
                if([device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorSwitch")]){
                    itemClick.identifier = [NSString stringWithFormat:@"%@_%d", @"motion", (int)switchIndex];
                    itemClick.comment = NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.click.comment",@"plugin_gateway","按动无线开关响门铃");
                }
                if([device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorMagnet")]){
                    itemClick.identifier = [NSString stringWithFormat:@"%@_%d", @"magnet", (int)switchIndex];
                    itemClick.comment = NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.magnetopen.comment",@"plugin_gateway","门窗打开门铃");
                }
                
                itemClick.accessories = [[MHStrongBox alloc] initWithDictionary:accessories];
                itemClick.callbackBlock = ^(MHDeviceSettingCell *cell) {
                    MHDeviceGatewayBase* sensor = [cell.item.accessories valueForKey:@"device" class:[MHDeviceGatewayBase class]];
                    MHLumiBindItem* item = [[MHLumiBindItem alloc] init];
                    if( [device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorMotion")]){
                        item.event = Gateway_Event_Motion_Motion;
                    }
                    if([device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorSwitch")]){
                        item.event = Gateway_Event_Switch_Click;
                    }
                    if([device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorMagnet")]){
                        item.event = Gateway_Event_Magnet_Open;
                    }
                    item.to_sid = SID_Gateway;
                    item.method = Method_Door_Bell;
                    item.from_sid = device.did;
                    item.params = @[@([weakself.gateway.default_music_index[BellGroup_Door] integerValue])];
                    [[MHTipsView shareInstance] showTips:@"" modal:YES];
                    if (cell.item.isOn) {
                        //这个sensor
                        MHDeviceGatewayBase* switchSensor = [cell.item.accessories valueForKey:@"device" class:[MHDeviceGatewayBase class]];
                        [weakself gw_clickMethodCountWithStatType:[NSString stringWithFormat:@"device:%@",switchSensor.class]];
                        
                        [sensor addBind:item success:^(id v) {
                            [cell fillWithItem:cell.item];
                            [cell finish];
                            [[MHTipsView shareInstance] hide];
                            
                        } failure:^(NSError *v) {
                            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
                            cell.item.isOn = !cell.item.isOn;
                            [cell fillWithItem:cell.item];
                            [cell finish];
                        }];
                        
                    } else {
                        [sensor removeBind:item success:^(id v) {
                            [cell finish];
                            [weakself refetchDoorBellStatus];  //关闭就去全拉一边
                            [[MHTipsView shareInstance] hide];
                        } failure:^(NSError *error) {
                            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
                            cell.item.isOn = !cell.item.isOn;
                            [cell fillWithItem:cell.item];
                            [cell finish];
                        }];
                    }
                };
                
                [doorbellConditionItems addObject:itemClick];
                switchIndex ++;
            }
    }
    
    MHLuDeviceSettingViewController* selMotionVC = [[MHLuDeviceSettingViewController alloc] init];
    selMotionVC.settingGroups = @[groupDoorbellCondition];
    selMotionVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.condition",@"plugin_gateway","门铃触发条件");
    selMotionVC.controllerIdentifier = @"mydevice.gateway.setting.doorbell.condition";
    selMotionVC.isTabBarHidden = YES;
    [self.navigationController pushViewController:selMotionVC animated:YES];
}


#pragma mark - 获取门铃音
- (void)getDoorBellMusic {
    
}

@end
