//
//  MHGatewayLinkAlarmViewController.m
//  MiHome
//
//  Created by ayanami on 16/7/5.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayLinkAlarmViewController.h"
#import "MHDevListManager.h"
#import "MHGatewaySceneManager.h"
#import "MHDataScene.h"
#import "MHIFTTTManager.h"

#define ALARM_IDENTIFY              @"lm_linkage_alarm"
#define DIS_ALARM_IDENTIFY          @"lm_linkage_dis_alarm"
#define DIS_ALARM_ALL_IDENTIFY      @"lm_linkage_dis_all_alarm"


@interface MHGatewayLinkAlarmViewController ()

@property (nonatomic,strong) MHDeviceGateway* gateway;
@property (nonatomic,strong) NSMutableArray *sceneUsIds;
@property (nonatomic,strong) NSMutableArray *gatewayArray;
@property (nonatomic,strong) NSMutableArray *selectedGateways;
@property (nonatomic,strong) NSMutableArray *authed;
@property (nonatomic,strong) NSMutableArray *tempAuthed;
@property (nonatomic, copy) void (^deleteCallback)(NSInteger);
@property (nonatomic, copy) void (^removeCallback)(void);
@property (nonatomic, copy) void (^saveCallback)(void);

@end

@implementation MHGatewayLinkAlarmViewController
- (id)initWithGateway:(MHDeviceGateway*)gateway {
    if (self = [super init]) {
        self.gateway = gateway;
        self.authed = [NSMutableArray new];
        self.tempAuthed = [NSMutableArray new];
        self.selectedGateways = [NSMutableArray new];
        self.sceneUsIds = [NSMutableArray new];
        //读取缓存
        [self buildDataSource];        
    }
    return self;
}

- (void)buildDataSource {
    self.gatewayArray = [NSMutableArray new];
    NSMutableArray<MHDevice *> *todoDevices = [NSMutableArray array];
    [todoDevices addObjectsFromArray:[[MHDevListManager sharedManager] devicesWithModel:kGatewayModelV2]];
    [todoDevices addObjectsFromArray:[[MHDevListManager sharedManager] devicesWithModel:kGatewayModelV3]];
    [todoDevices addObjectsFromArray:[[MHDevListManager sharedManager] devicesWithModel:kACPartnerModelV1]];//先去掉空调伴侣
    for (MHDevice *device in todoDevices) {
        if (!device.shareFlag) {
            [self.gatewayArray addObject:device];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //请求新的数据
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.moresettings.linkalarm",@"plugin_gateway","联动报警");
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 44, 26);
    [btn setBackgroundColor:[MHColorUtils colorWithRGB:0x1dc58a]];
    [btn setTitle:NSLocalizedStringFromTable(@"Ok",@"plugin_gateway", "确定") forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13.f];
    btn.layer.cornerRadius = 3.0f;
    [btn addTarget:self action:@selector(onDone:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    XM_WS(weakself);
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"getting",@"plugin_gateway","获取中，请稍候...") modal:YES];
   
    [[MHGatewaySceneManager sharedInstance] getRecordsListSuccess:^(id obj) {
        NSMutableArray<MHDataIFTTTRecord *> *systemScene = [NSMutableArray arrayWithArray:obj];
        [systemScene enumerateObjectsUsingBlock:^(MHDataIFTTTRecord *scene, NSUInteger idx, BOOL * _Nonnull stop) {
        
            if ([scene.identify isEqualToString:ALARM_IDENTIFY] ||
                [scene.identify isEqualToString:DIS_ALARM_IDENTIFY] ||
                [scene.identify isEqualToString:DIS_ALARM_ALL_IDENTIFY]) {
                NSMutableArray *authedDid = [NSMutableArray new];
                [weakself.sceneUsIds addObject:scene.us_id];
                [scene.actions enumerateObjectsUsingBlock:^(MHDataIFTTTAction *action, NSUInteger idxAction, BOOL * _Nonnull stopAction) {
                    [authedDid addObject:action.did];
                }];
                weakself.authed = [NSMutableArray arrayWithArray:authedDid];
            }
        }];
        [[MHTipsView shareInstance] hide];
        [weakself buildTableView];
        
    } failure:^(NSError *v) {
         [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.5f modal:NO];
    }];
}

- (void)buildSubviews {
    [super buildSubviews];
    [self buildTableView];
}

- (void)buildTableView {
    XM_WS(weakself);
    
    MHLuDeviceSettingGroup* group3 = [[MHLuDeviceSettingGroup alloc] init];
    NSMutableArray *doorbellItems = [NSMutableArray arrayWithCapacity:1];
    group3.items = doorbellItems;
    group3.title = nil;
    
    [self.gatewayArray enumerateObjectsUsingBlock:^(MHDeviceGateway *sensor, NSUInteger idx, BOOL * _Nonnull stop) {
        MHDeviceSettingItem *item3 = [[MHDeviceSettingItem alloc] init];
        item3.identifier = [NSString stringWithFormat:@"%ld", idx];
        item3.type = MHDeviceSettingItemTypeSwitch;
        __block BOOL isOn = NO;
        [weakself.authed enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([sensor.did integerValue] == [obj integerValue]) {
                isOn = YES;
                [weakself.selectedGateways addObject:sensor];
                *stop = YES;
            }
        }];
        item3.isOn = isOn;
        item3.caption = sensor.name;
        item3.customUI = YES;
        item3.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
        item3.callbackBlock = ^(MHDeviceSettingCell *cell) {
            MHDeviceGateway *currentGateway = weakself.gatewayArray[[cell.item.identifier integerValue]];
            if (cell.item.isOn) {
                [weakself.authed addObject:currentGateway.did];
                [weakself.selectedGateways addObject:currentGateway];
            }
            else {
                [weakself.authed removeObject:currentGateway.did];
                [weakself.selectedGateways removeObject:currentGateway];
            }
            [cell fillWithItem:cell.item];
            
        };
        [doorbellItems addObject:item3];
        
    }];
    self.settingGroups = [NSMutableArray arrayWithObjects:group3, nil];
    [self.settingTableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)onDone:(id)sender {
    if (self.selectedGateways.count < 2 && self.selectedGateways.count > 0) {
        [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.moresettings.linkalarm.tipsone",@"plugin_gateway","亲,至少要选择两个网关才能联动报警哦~") duration:1.5f modal:YES];
        return;
    }
    
    XM_WS(weakself);
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"getting",@"plugin_gateway","获取中，请稍候...") modal:YES];
    [self removeLinkAlarmSceneSuccess:^(id obj) {
        if (!weakself.authed.count) {
            [[MHTipsView shareInstance] hide];
            [weakself onBack:nil];
        }else {
            [weakself buildLinkAlarmSceneSuccess:^(id obj) {
                [[MHTipsView shareInstance] hide];
                [weakself onBack:nil];
            } andfailure:^(NSError *error) {
                [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"operation.failed",@"plugin_gateway","操作失败, 请检查网络") duration:1.5f modal:NO];
            }];
        }
       
    } andfailure:^(NSError *error) {
        [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"operation.failed",@"plugin_gateway","操作失败, 请检查网络") duration:1.5f modal:NO];
    }];
}

- (void)onBack:(id)sender {
    [super onBack:sender];
}

#pragma mark - 联动报警
- (void)buildLinkAlarmSceneSuccess:(SucceedBlock)success
                           andfailure:(FailedBlock)failure {
    XM_WS(weakself);
    __block NSInteger index = 0;

    [self setSaveCallback:^{
        switch (index) {
            case 0: {
                [[MHIFTTTManager sharedInstance] editRecord:[weakself buildAlarmRecord] success:^{
                    index++;
                    if (weakself.saveCallback) weakself.saveCallback();

                } failure:^(NSInteger v) {
                    NSError *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:v userInfo:NULL];
                    if (failure) failure(error);
                }];
            }
                break;
            case 1: {
                [[MHIFTTTManager sharedInstance] editRecord:[weakself buildDisAlarmRecord] success:^{
                    index++;
                    if (weakself.saveCallback) weakself.saveCallback();
                    
                } failure:^(NSInteger v) {
                    NSError *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:v userInfo:NULL];
                    if (failure) failure(error);
                }];
            }
                break;
            case 2: {
                [[MHIFTTTManager sharedInstance] editRecord:[weakself buildDisAllAlarmRecord] success:^{
                    if (success) success(NULL);
                } failure:^(NSInteger v) {
                    NSError *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:v userInfo:NULL];
                    if (failure) failure(error);
                }];
            }
                break;
                
            default:
                break;
        }
    }];
    
    self.saveCallback();
}

- (void)removeLinkAlarmSceneSuccess:(SucceedBlock)success
                            andfailure:(FailedBlock)failure {
    
    if (!self.sceneUsIds.count) {
        if (success) {
            success(nil);
        }
        return;
    }
    XM_WS(weakself);
    __block NSInteger index = 0;

    [self setRemoveCallback:^{
        [weakself deleteOldSceneUsid:weakself.sceneUsIds[index] Success:^(id obj) {
            NSLog(@"%ld", index);
            if (index >= weakself.sceneUsIds.count) {
                if (success) {
                    success(obj);
                }
            }
            else {
                if (weakself.removeCallback) {
                    weakself.removeCallback();
                }
            }
        } andfailure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
        index++;
        
    }];
    
    self.removeCallback();
}

- (void)deleteOldSceneUsid:(NSString *)usid Success:(SucceedBlock)success
                   andfailure:(FailedBlock)failure {
   
    XM_WS(weakself);
    __block NSInteger index = 0;

    [self setDeleteCallback:^(NSInteger v) {
        
        [[MHIFTTTManager sharedInstance] deleteRecords:weakself.sceneUsIds success:^{
            if (success) success(NULL);
            
        } failure:^(NSError *error) {
            if (index < 3) {
                if (weakself.deleteCallback) {
                    weakself.deleteCallback(0);
                }
            }
            else {
                if (failure) failure(error);
            }
            index++;
        }];
    }];
    
    self.deleteCallback(0);
}

#pragma 统一采用帮主的格式
- (MHDataIFTTTRecord *)buildAlarmRecord {
    MHDataIFTTTRecord *alarmRecord = [MHDataIFTTTRecord sceneRecord];
    alarmRecord.identify = ALARM_IDENTIFY;
    alarmRecord.name = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.moresettings.linkalarm",@"plugin_gateway","联动报警");
    alarmRecord.st_id = @"22";
    alarmRecord.userid = [MHPassportManager sharedSingleton].currentAccount.userId;
    NSMutableArray<MHDataIFTTTTrigger *> *triggers = [NSMutableArray new];
    NSMutableArray<MHDataIFTTTAction *> *actions = [NSMutableArray new];
    alarmRecord.triggerRelation = MHIFTTTTriggerRelationOr;
    
    
    [self.selectedGateways enumerateObjectsUsingBlock:^(MHDeviceGateway *gateway, NSUInteger idx, BOOL * _Nonnull stop) {
        MHDataIFTTTTrigger *alarmLaunch = [MHDataIFTTTTrigger new];
        alarmLaunch.value = @"";
        alarmLaunch.did = gateway.did;
        alarmLaunch.src = @"device";
        alarmLaunch.extra = @"[1,19,1,111,[0,1],2,0]";
        alarmLaunch.key = [NSString stringWithFormat:@"event.%@.arming", gateway.model];
        alarmLaunch.name = @"name";
        alarmLaunch.deviceName = @"dev";
        alarmLaunch.model = gateway.model;
        alarmLaunch.group = MHIFTTTTriggerDevice;
        
        [triggers addObject:alarmLaunch];
        
        MHDataIFTTTAction *action = [MHDataIFTTTAction new];
        action.model = gateway.model;
        action.name = @"name";
        action.deviceName = @"name";
        action.type = MHIFTTTActionDevice;
        NSMutableDictionary *payload = [NSMutableDictionary new];
        [payload setObject:@"10000" forKey:@"value"];
        [payload setObject:gateway.did forKey:@"did"];
        [payload setObject:[NSString stringWithFormat:@"%@.linkage_alarm",gateway.model] forKey:@"command"];
        [payload setObject:@(0) forKey:@"total_length"];
        [payload setObject:@"[1,19,9,85,[40,10000],0,0]" forKey:@"extra"];
        action.payload = payload;
        action.extra = @"[1,19,9,85,[40,10000],0,0]";
        action.did = gateway.did ;
        [actions addObject:action];
        
    }];
    
    alarmRecord.triggers = triggers;
    alarmRecord.actions = actions;
    alarmRecord.enabled = YES;
    alarmRecord.enable_push = YES;
    
    return alarmRecord;
    
}
- (MHDataIFTTTRecord *)buildDisAlarmRecord {
    MHDataIFTTTRecord *disScene = [MHDataIFTTTRecord sceneRecord];
    disScene.identify = DIS_ALARM_IDENTIFY;
    disScene.name = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.moresettings.linkalarm.off",@"plugin_gateway","联动报警取消");
    disScene.st_id = @"22";
    NSMutableArray<MHDataIFTTTTrigger *> *triggers = [NSMutableArray new];
    NSMutableArray<MHDataIFTTTAction *> *actions = [NSMutableArray new];
    disScene.triggerRelation = MHIFTTTTriggerRelationOr;
    
    
    
    [self.selectedGateways enumerateObjectsUsingBlock:^(MHDeviceGateway *gateway, NSUInteger idx, BOOL * _Nonnull stop) {
        MHDataIFTTTTrigger *alarmLaunch = [MHDataIFTTTTrigger new];
        alarmLaunch.value = @"off";
        alarmLaunch.did = gateway.did;
        alarmLaunch.src = @"device";
        alarmLaunch.extra = @"[1,19,9,111,[0,0],0,0]";
        alarmLaunch.key = [NSString stringWithFormat:@"event.%@.alarm", gateway.model];
        alarmLaunch.name = @"name";
        alarmLaunch.deviceName = @"dev";
        alarmLaunch.model = gateway.model;
        alarmLaunch.group = MHIFTTTTriggerDevice;
        
        [triggers addObject:alarmLaunch];
        
        MHDataIFTTTAction *action = [MHDataIFTTTAction new];
        action.model = gateway.model;
        action.name = @"name";
        action.deviceName = @"name";
        action.type = MHIFTTTActionDevice;
        NSMutableDictionary *payload = [NSMutableDictionary new];
        [payload setObject:@"" forKey:@"value"];
        [payload setObject:gateway.did forKey:@"did"];
        [payload setObject:[NSString stringWithFormat:@"%@.dis_alarm",gateway.model] forKey:@"command"];
        [payload setObject:@(0) forKey:@"total_length"];
        [payload setObject:@"[1,19,9,111,[40,0],0,0]" forKey:@"extra"];
        action.payload = payload;
        action.extra = @"[1,19,9,111,[40,0],0,0]";
        action.did = gateway.did ;
        [actions addObject:action];
        
    }];
    
    
    
    disScene.triggers = triggers;
    disScene.actions = actions;
    disScene.enabled = YES;
    disScene.enable_push = YES;
    
    return disScene;
    
}
- (MHDataIFTTTRecord *)buildDisAllAlarmRecord {
    MHDataIFTTTRecord *disAllScene = [MHDataIFTTTRecord sceneRecord];
    disAllScene.identify = DIS_ALARM_ALL_IDENTIFY;
    disAllScene.name = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.moresettings.linkalarm.off",@"plugin_gateway","联动报警取消");
    disAllScene.st_id = @"22";
    NSMutableArray<MHDataIFTTTTrigger *> *triggers = [NSMutableArray new];
    NSMutableArray<MHDataIFTTTAction *> *actions = [NSMutableArray new];
    disAllScene.triggerRelation = MHIFTTTTriggerRelationOr;
    
    [self.selectedGateways enumerateObjectsUsingBlock:^(MHDeviceGateway *gateway, NSUInteger idx, BOOL * _Nonnull stop) {
        
        MHDataIFTTTTrigger *alarmLaunch = [MHDataIFTTTTrigger new];
        alarmLaunch.value = @"all_off";
        alarmLaunch.did = gateway.did;
        alarmLaunch.src = @"device";
        alarmLaunch.extra = @"[1,19,9,111,[0,0],0,0]";
        alarmLaunch.key = [NSString stringWithFormat:@"event.%@.alarm", gateway.model];
        alarmLaunch.name = @"name";
        alarmLaunch.deviceName = @"dev";
        alarmLaunch.model = gateway.model;
        alarmLaunch.group = MHIFTTTTriggerDevice;
        [triggers addObject:alarmLaunch];
        
        MHDataIFTTTAction *action = [MHDataIFTTTAction new];
        action.model = gateway.model;
        action.name = @"name";
        action.deviceName = @"name";
        action.type = MHIFTTTActionDevice;
        NSMutableDictionary *payload = [NSMutableDictionary new];
        [payload setObject:@"1" forKey:@"value"];
        [payload setObject:gateway.did forKey:@"did"];
        [payload setObject:[NSString stringWithFormat:@"%@.dis_alarm",gateway.model] forKey:@"command"];
        [payload setObject:@(0) forKey:@"total_length"];
        [payload setObject:@"[1,19,9,111,[40,0],0,0]" forKey:@"extra"];
        action.payload = payload;
        action.extra = @"[1,19,9,111,[40,0],0,0]";
        action.did = gateway.did ;
        [actions addObject:action];
        
    }];
    
    disAllScene.triggers = triggers;
    disAllScene.actions = actions;
    disAllScene.enabled = YES;
    disAllScene.enable_push = YES;
    
    
    return disAllScene;
    
}


@end
