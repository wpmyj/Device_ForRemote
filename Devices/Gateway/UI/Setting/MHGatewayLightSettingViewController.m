//
//  MHGatewayLightSettingViewController.m
//  MiHome
//
//  Created by Lynn on 10/16/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayLightSettingViewController.h"
#import "MHLuTimerDetailViewController.h"
#import "MHDeviceGatewaySensorMotion.h"
#import "MHGatewayTimerSettingNewViewController.h"
#import "MHGatewayLegSettingCell.h"
#import "MHGatewayWebViewController.h"
#import "MHGatewayDurationSettingViewController.h"
#import "MHLumiAccessSettingCell.h"
#import "MHGatewayBindSceneManager.h"
#import "MHGatewayLightTimeSettingViewController.h"

@interface MHGatewayLightSettingViewController ()<UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *time;
@property (nonatomic, assign) BOOL isSuccess;//设置时段是否成功
@property (nonatomic, assign) NSInteger onHour;     //开启时间：时
@property (nonatomic, assign) NSInteger onMinute;   //开启时间：分

@property (nonatomic, assign) NSInteger offHour;    //关闭时间：时
@property (nonatomic, assign) NSInteger offMinute;  //关闭时间：分
@end

@implementation MHGatewayLightSettingViewController
{
    NSMutableArray *                            _nightLightItems;
    NSMutableArray *                            _nightLightHoldTimeItems;
    
    MHLuDeviceSettingViewController *           _selHoldTimeVC;
}

- (id)initWithGateway:(MHDeviceGateway*)gateway {
    if (self = [super init]) {
        self.gateway = gateway;
        [self readStatus];
        [self updateTimeSpan];
    }
    return self;
}

- (void)updateTimeSpan {
    XM_WS(weakself);
    [self.gateway.systemSceneList enumerateObjectsUsingBlock:^(MHDataScene *scene, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([scene.identify isEqualToString:@"lm_scene_2_1"]) {
            if ([[weakself checkSystemScene:scene][0] boolValue]) {
                if (![[weakself checkSystemScene:scene][0] boolValue]) {
                    return;
                }
                MHDataLaunch *launch = scene.launchList[0];
                NSLog(@"时间间隔%@", launch.timeSpan);
                NSLog(@"啟動id==%@, 啟動名字===%@", launch.deviceDid, launch.deviceName);
                if (launch.timeSpan.count >= 3) {
                    NSDictionary *timeFrom = launch.timeSpan[@"from"];
                    NSDictionary *timeTo = launch.timeSpan[@"to"];
                    weakself.onHour = [timeFrom[@"hour"] integerValue];
                    weakself.onMinute = [timeFrom[@"min"] integerValue];
                    weakself.offHour = [timeTo[@"hour"] integerValue];
                    weakself.offMinute = [timeTo[@"min"] integerValue];
                    [weakself dataConstruct];
                    [weakself saveStatus];
                    [weakself adjustOpenNightLightSettingItems];
                    if (weakself.settingTableView.superview){
                        [weakself.settingTableView reloadData];
                    }
                }
            }
        }
    }];
}

- (NSArray *)checkSystemScene:(MHDataScene *)scene {
    NSMutableArray *result = [NSMutableArray new];
    __block BOOL isRightScene = NO;
    __block MHDevice *resultDevice = [[MHDevice alloc] init];
    XM_WS(weakself);
    [scene.actionList enumerateObjectsUsingBlock:^(MHDataAction *action, NSUInteger idx, BOOL * _Nonnull stop) {
        //        NSLog(@"action的信息---%@, %@, %@",  action.deviceName ,action.deviceModel, action.deviceDid);
        //执行设备是当前网关
        if ([action.deviceDid isEqualToString:weakself.gateway.did]) {
            [scene.launchList enumerateObjectsUsingBlock:^(MHDataLaunch *launch, NSUInteger idx, BOOL * _Nonnull stop) {
                //                NSLog(@"启动条件的名字和did ---- %@, %@", launch.name, launch.deviceDid);
                MHDevice *newDevice = [[MHDevListManager sharedManager] deviceForDid:launch.deviceDid];
                [weakself.gateway.subDevices enumerateObjectsUsingBlock:^(MHDeviceGatewayBase *subDevice, NSUInteger idx, BOOL * _Nonnull stop) {
                    //设备是否存在, 在线,属于当前网关
                    if ((newDevice && newDevice.isOnline) && [newDevice.did isEqualToString:subDevice.did]) {
                        isRightScene = YES;
                        resultDevice = newDevice;
                        *stop = YES;
                    }
                }];
            }];
        }
        *stop = isRightScene;
    }];
    [result addObject:@(isRightScene)];
    [result addObject:resultDevice];
    return result;
}




- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)dealloc {
    NSLog(@"dddd");
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)buildSubviews {
    [super buildSubviews];
    [self dataConstruct];
}

-(void)dataConstruct{
    XM_WS(weakself);
    MHLuDeviceSettingGroup* group1 = [[MHLuDeviceSettingGroup alloc] init];
    {
        _nightLightItems = [[NSMutableArray alloc] init];
        _nightLightHoldTimeItems = [[NSMutableArray alloc] init];
        
        MHDeviceSettingItem *itemNightLight = [[MHDeviceSettingItem alloc] init];
        itemNightLight.identifier = @"nightlight";
        itemNightLight.type = MHDeviceSettingItemTypeSwitch;
        itemNightLight.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.switch.cap",@"plugin_gateway","感应夜灯设置");
        itemNightLight.comment = NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.switch.comment",@"plugin_gateway","网关所在的环境光线较暗时,自动为您点亮夜灯");
        itemNightLight.isOn = [self.gateway.corridor_light isEqualToString:@"on"] && [self.gateway getFirstMotionDevice];
        itemNightLight.customUI = YES;
        itemNightLight.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
        itemNightLight.callbackBlock = ^(MHDeviceSettingCell *cell) {
            [weakself gw_clickMethodCountWithStatType:@"itemNightLight"];
            
            if (![weakself.gateway getFirstMotionDevice]) {
//                [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.gateway.tips.nomotion",@"plugin_gateway","没找到人体传感器") duration:1.0f modal:NO];
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"mydevice.gateway.tips.nomotion",@"plugin_gateway","没找到人体传感器") message:NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.switch.tips",@"plugin_gateway","看看") preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *see = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.switch.see",@"plugin_gateway","看看") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [weakself goToBuy];
                    }];
                    UIAlertAction *cancle = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.switch.cancle",@"plugin_gateway","取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    [alert addAction:see];
                    [alert addAction:cancle];
                    [weakself presentViewController:alert animated:YES completion:nil];
                }
                else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.gateway.tips.nomotion",@"plugin_gateway","没找到人体传感器") message:NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.switch.tips",@"plugin_gateway","看看") delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.switch.cancle",@"plugin_gateway","取消") otherButtonTitles:NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.switch.see",@"plugin_gateway","看看"), nil];
                    [alert show];
                }
                cell.item.isOn = !cell.item.isOn;
                [cell fillWithItem:cell.item];
                [cell finish];
                return;
            }
            [[MHTipsView shareInstance] showTips:@"" modal:YES];
            [weakself.gateway setProperty:CORRIDOR_LIGHT_INDEX value:cell.item.isOn ? @"on" : @"off" success:^(id v) {
                [cell finish];
                [weakself adjustOpenNightLightSettingItems];
                [[MHTipsView shareInstance] hide];
            } failure:^(NSError *v) {
                [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
                cell.item.isOn = !cell.item.isOn;
                [cell fillWithItem:cell.item];
                [cell finish];
            }];
        };
        [_nightLightItems addObject:itemNightLight];
        
        group1.items = _nightLightItems;
    }
    
    self.settingGroups = [NSMutableArray arrayWithObjects:group1, nil];
    [self adjustOpenNightLightSettingItems];
    
    [self.settingTableView reloadData];
}

#pragma mark - 调整cell的数量
- (void)adjustOpenNightLightSettingItems {
    if (!self) {
        return;
    }
    
    XM_WS(weakself);
    BOOL isSetNightLight = [self.gateway.corridor_light isEqualToString:@"on"] && [self.gateway getFirstMotionDevice];
    if (isSetNightLight) {
        MHDeviceSettingItem *itemSelMotion = [[MHDeviceSettingItem alloc] init];
        itemSelMotion.identifier = @"itemSelMotion";
        itemSelMotion.type = MHDeviceSettingItemTypeDefault;
        itemSelMotion.hasAcIndicator = YES;
        itemSelMotion.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.motion",@"plugin_gateway","选择人体传感器");
        itemSelMotion.customUI = YES;
        itemSelMotion.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
        itemSelMotion.callbackBlock = ^(MHDeviceSettingCell *cell) {
            [weakself openSelMotionPage];
        };
        [self insertNewItem:itemSelMotion atIndex:1];
        
        if (![self.gateway.model isEqualToString:kGatewayModelV1] &&
            ![self.gateway.model isEqualToString:kGatewayModelV2]) {
            MHLumiSettingCellItem *itemWorkTime = [[MHLumiSettingCellItem alloc] init];
            itemWorkTime.identifier = @"itemWorkTime";
            itemWorkTime.lumiType = MHLumiSettingItemTypeAccess;
            itemWorkTime.hasAcIndicator = YES;
            itemWorkTime.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.motion.workTime",@"plugin_gateway","感應時段");
            itemWorkTime.comment = [self calculateTimeSpacing];
            itemWorkTime.customUI = YES;
            itemWorkTime.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
            itemWorkTime.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
                [weakself adjustWorkTimePage:^(NSArray *time) {
                    if (time.count >= 4) {
                        weakself.onHour = [time[LightTimeOnHour] integerValue];
                        weakself.onMinute = [time[LightTimeOnMin] integerValue];
                        weakself.offHour = [time[LightTimeOffHour] integerValue];
                        weakself.offMinute = [time[LightTimeOffMin] integerValue];
                        [weakself setOpenNightLightWithSuccess:^(id obj) {
                            cell.lumiItem.comment = [weakself calculateTimeSpacing];
                            [cell fillWithItem:cell.lumiItem];
                            [cell finish];
                            [weakself saveStatus];
                            weakself.isSuccess = NO;
                        } failure:^(NSError *error) {
                            [weakself readStatus];
                            weakself.isSuccess = NO;
                        }];
                    }
                }];
            };
            [self insertNewItem:itemWorkTime atIndex:2];
            
            MHGatewaySettingCellItem *itemHoldTime = [[MHGatewaySettingCellItem alloc] init];
            itemHoldTime.identifier = @"itemHoldTime";
            itemHoldTime.type = MHGatewaySettingItemTypeLeg;
            itemHoldTime.hasAcIndicator = YES;
            itemHoldTime.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.holdtime",@"plugin_gateway","延时关灯选择");
            itemHoldTime.comment = [self corridorOnTimeString];
            itemHoldTime.customUI = YES;
            itemHoldTime.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
            itemHoldTime.callbackBlock = ^(MHGatewaySettingCell *cell) {
                [weakself adjustHoldTimePage:^(NSNumber *time) {
                    cell.item.comment = [weakself corridorOnTimeString];
                    [cell fillWithItem:cell.item];
                    [cell finish];
                }];
            };
            [self lumiInsertNewItem:itemHoldTime atIndex:3];

        }
        else {
            MHGatewaySettingCellItem *itemHoldTime = [[MHGatewaySettingCellItem alloc] init];
            itemHoldTime.identifier = @"itemHoldTime";
            itemHoldTime.type = MHGatewaySettingItemTypeLeg;
            itemHoldTime.hasAcIndicator = YES;
            itemHoldTime.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.holdtime",@"plugin_gateway","延时关灯选择");
            itemHoldTime.comment = [self corridorOnTimeString];
            itemHoldTime.customUI = YES;
            itemHoldTime.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
            itemHoldTime.callbackBlock = ^(MHGatewaySettingCell *cell) {
                [weakself adjustHoldTimePage:^(NSNumber *time) {
                    cell.item.comment = [weakself corridorOnTimeString];
                    [cell fillWithItem:cell.item];
                    [cell finish];
                }];
            };
            [self lumiInsertNewItem:itemHoldTime atIndex:2];
        }
        
        
        
    }
    else {
        NSUInteger idxSelMotion = [self indexOfItemWithIdentifier:@"itemSelMotion"];
        if (idxSelMotion != NSNotFound) {
            [self removeItemAtIndex:idxSelMotion];
        }
        NSUInteger idxItemWorkTime = [self indexOfItemWithIdentifier:@"itemWorkTime"];
        if (idxItemWorkTime != NSNotFound) {
            [self removeItemAtIndex:idxItemWorkTime];
        }
        NSUInteger idxHoldTime = [self indexOfItemWithIdentifier:@"itemHoldTime"];
        if (idxHoldTime != NSNotFound) {
            [self removeItemAtIndex:idxHoldTime];
        }

    }
}

#pragma mark - 选择人体传感器页面
- (void)openSelMotionPage {

    XM_WS(weakself);
    MHLuDeviceSettingGroup* groupSelMotion = [[MHLuDeviceSettingGroup alloc] init];
    NSMutableArray *selMotionItems = [NSMutableArray arrayWithCapacity:1];
    groupSelMotion.items = selMotionItems;
    groupSelMotion.title = nil;
    
    int index = 0;
    for (id obj in self.gateway.subDevices) {
        if (![obj isKindOfClass:[MHDeviceGatewaySensorMotion class]]) {
            continue;
        }
        
        __block MHDeviceGatewaySensorMotion* motion = (MHDeviceGatewaySensorMotion*)obj;
        if (!motion.isOnline) {
            continue;
        }
        
        MHDeviceSettingItem *itemMotion = [[MHDeviceSettingItem alloc] init];
        itemMotion.identifier = [NSString stringWithFormat:@"itemMotion_%d", index];
        itemMotion.type = MHDeviceSettingItemTypeCheckmark;
        itemMotion.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.motion.people",@"plugin_gateway","感应到有人夜灯亮");
        itemMotion.comment = motion.name;
        itemMotion.hasAcIndicator = [motion isSetOpenNightLight];
        itemMotion.customUI = YES;
        itemMotion.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
        itemMotion.callbackBlock = ^(MHDeviceSettingCell *cell) {
            //添加绑定
            if (!cell.item.hasAcIndicator) {
                [motion setOpenNightLightWithTime:@[ @(self.onHour), @(self.onMinute), @(self.offHour), @(self.offMinute) ] Success:^(id obj) {
                    cell.item.hasAcIndicator = YES;
                    [cell fillWithItem:cell.item];
                    [cell finish];
                    [[MHTipsView shareInstance] hide];
                    [weakself updateOpenNightLightSettingItems];
                } failure:^(NSError *error) {
                    [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
                    [cell finish];
                }];
            } else {
                [motion removesetOpenNightLightWithTime:@[ @(self.onHour), @(self.onMinute), @(self.offHour), @(self.offMinute) ] Success:^(id obj) {
                    cell.item.hasAcIndicator = NO;
                    [cell fillWithItem:cell.item];
                    [cell finish];
                    [[MHTipsView shareInstance] hide];
                    [weakself updateOpenNightLightSettingItems];
                    
                } failure:^(NSError *error) {
                    [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
                    [cell finish];
                }];
            }
            
            [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"updating",@"plugin_gateway","正在更新中...") modal:NO];
        };
        
        [selMotionItems addObject:itemMotion];
        index++;
    }
    
    MHLuDeviceSettingViewController* selMotionVC = [[MHLuDeviceSettingViewController alloc] init];
    selMotionVC.settingGroups = @[groupSelMotion];
    selMotionVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.motion",@"plugin_gateway","选择人体传感器");
    selMotionVC.controllerIdentifier = @"mydevice.gateway.setting.nightlight.motion";
    selMotionVC.isTabBarHidden = YES;
    [self.navigationController pushViewController:selMotionVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"chooseNightLightMotion"];

}

- (void)updateOpenNightLightSettingItems {
    MHDeviceSettingItem* itemSelMotion = [self itemWithIdentifier:@"itemSelMotion"];
    itemSelMotion.comment = [self.gateway hasOpenNightLightMotionNames];
    [self reloadItemAtIndex:[self indexOfItemWithIdentifier:@"itemSelMotion"] atSection:0];
    
    MHDeviceSettingItem* itemHoldTime = [self itemWithIdentifier:@"itemHoldTime"];
    itemHoldTime.comment = [self corridorOnTimeString];
    [self reloadItemAtIndex:[self indexOfItemWithIdentifier:@"itemHoldTime"] atSection:0];
}

#pragma mark -延时时间
- (NSString* )corridorOnTimeString {
    int mins = (int)(self.gateway.corridor_on_time);
    switch (mins) {
        case 60:
            return NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.holdtime.60",@"plugin_gateway","1分钟");
        case 120:
            return NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.holdtime.120",@"plugin_gateway","2分钟");
        case 300:
            return NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.holdtime.300",@"plugin_gateway","5分钟");
        case 600:
            return NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.holdtime.600",@"plugin_gateway","10分钟");
        default:
            return NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.holdtime.60",@"plugin_gateway","1分钟");
    }
}

#pragma mark - 感应夜灯时段 
- (void)adjustWorkTimePage:(void (^)(NSArray *time))selectedCallBack {
    MHGatewayLightTimeSettingViewController *lightTime = [[MHGatewayLightTimeSettingViewController alloc] initWithTimer:@[ @(self.onHour), @(self.onMinute), @(self.offHour), @(self.offMinute) ] andIdentifier:nil];
    lightTime.onDone = ^(NSArray *time){
        NSLog(@"夜灯不按套路出牌怎么办");
        if (selectedCallBack) {
            selectedCallBack(time);
        }
    };
    [self.navigationController pushViewController:lightTime animated:YES];
    [self gw_clickMethodCountWithStatType:@"setNightLightTimespan"];

}

#pragma mark - 延时关灯时间选择
- (void)adjustHoldTimePage:(void (^)(NSNumber *time))selectedCallBack {
    MHGatewayDurationSettingViewController *delayTime = [[MHGatewayDurationSettingViewController alloc] initWithGatewayDevice:_gateway identifier:@"mydevice.gateway.setting.nightlight.holdtime" currentTime:self.gateway.corridor_on_time];
    delayTime.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.holdtime", @"plugin_gateway",@"");
    delayTime.selectTime = ^(NSNumber *time){
        if (selectedCallBack) {
            selectedCallBack(time);
        }
    };
    [self.navigationController pushViewController:delayTime animated:YES];
    [self gw_clickMethodCountWithStatType:@"setNightLightDelayOff"];
}



#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            //取消
        }
            break;
        case 1: {
            [self goToBuy];
        }
            break;
            
        default:
            break;
    }
}



#pragma mark - 购买页面
- (void)goToBuy {
    NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:kMagnetBuyingLinksKey];
    MHGatewayWebViewController* web = [[MHGatewayWebViewController alloc] initWithURL:[NSURL URLWithString:url ? url :kNOTFOUNDDEVICE]];
    web.isTabBarHidden = YES;
    web.hasShare = NO;
    web.controllerIdentifier = @"nightlight";
    web.strOriginalURL = url;
    [self.navigationController pushViewController:web animated:YES];
}

#pragma mark - 感应时段
- (void)readStatus {
    self.onHour = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"onHour%@%@", _gateway.did, [MHPassportManager sharedSingleton].currentAccount.userId]] integerValue];
    self.onMinute = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"onMinute%@%@", _gateway.did, [MHPassportManager sharedSingleton].currentAccount.userId]] integerValue];
    self.offHour = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"offHour%@%@", _gateway.did, [MHPassportManager sharedSingleton].currentAccount.userId]] integerValue];
    self.offMinute = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"offMinute%@%@", _gateway.did, [MHPassportManager sharedSingleton].currentAccount.userId]] integerValue];

}

- (void)saveStatus {
    [[NSUserDefaults standardUserDefaults] setObject:@(self.onHour) forKey:[NSString stringWithFormat:@"onHour%@%@", _gateway.did, [MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.onMinute) forKey:[NSString stringWithFormat:@"onMinute%@%@", _gateway.did, [MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.offHour) forKey:[NSString stringWithFormat:@"offHour%@%@", _gateway.did, [MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.offMinute) forKey:[NSString stringWithFormat:@"offMinute%@%@", _gateway.did, [MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)setOpenNightLightWithSuccess:(void (^)(id obj))success failure:(void (^)(NSError *error))failure {

    for (MHDeviceGatewayBase *subDevice in self.gateway.subDevices) {
        if ([subDevice isKindOfClass:[MHDeviceGatewaySensorMotion class]] && subDevice.isOnline) {
            for (MHLumiBindItem *item in subDevice.bindList) {
                if ([item.method isEqualToString:Method_OpenNightLight]) {
                    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"updating",@"plugin_gateway","正在更新中...") modal:YES];
                    self.isSuccess = YES;
                    MHDeviceGatewaySensorMotion *motion = (MHDeviceGatewaySensorMotion *)subDevice;
                    [motion updateNightLightWithTime:@[ @(self.onHour), @(self.onMinute), @(self.offHour), @(self.offMinute) ] Success:^(id obj) {
                        if (success) {
                            success(obj);
                        }
                        [[MHTipsView shareInstance] hide];
                    } failure:^(NSError *error) {
                        if (failure) {
                            failure(error);
                        }
                        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed", @"plugin_gateway",@"请求失败，请检查网络") duration:1.0f modal:NO];
                    }];
                }
            }
        }
    }
    if (!self.isSuccess) {
        if (success) {
            success(nil);
        }
    }
}

- (NSString *)calculateTimeSpacing {
    if (self.onHour == 0 && self.offHour == 0 && self.onMinute ==  0 && self.offMinute == 0) {
        return [NSString stringWithFormat:@"%02ld:%02ld-%@%02ld:%02ld", self.onHour, self.onMinute,NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.motion.workTime.nextDay", @"plugin_gateway", nil), self.offHour, self.offMinute];
    }
    return [NSString stringWithFormat:@"%02ld:%02ld-%02ld:%02ld", self.onHour, self.onMinute, self.offHour, self.offMinute];
}

@end
