//
//  MHLumiActivitiesHelper.m
//  MiHome
//
//  Created by LM21Mac002 on 16/10/10.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//



#import "MHLumiActivitiesHelper.h"
#import "MHDeviceGatewaySensorMotion.h"
#import "MHDeviceGatewaySensorMagnet.h"
#import "MHDeviceGatewaySensorSwitch.h"
#import "MHDeviceGatewaySensorPlug.h"
@interface MHLumiActivitiesHelper()
@property (nonatomic, strong) MHLumiRequestLogHelper *logHelper;
@property (nonatomic, strong) NSArray<MHDeviceGatewayBase *> *subDevices;
@property (nonatomic, strong) dispatch_group_t activitiesHelperGroup;

@end

@implementation MHLumiActivitiesHelper

- (instancetype)initWithType:(MHLumiActivitiesType)type
                     gateway:(MHDeviceGateway *)gateway
                   logHelper:(MHLumiRequestLogHelper *)helper{
    self = [super init];
    if (self){
        _activitiesType = type;
        _gateway = gateway;
        _logHelper = helper;
        _activitiesHelperGroup = dispatch_group_create();
    }
    return self;
}

- (void)setDefaultconfigurationWithSuccess:(void(^)())success failure:(void(^)())failure{
    __weak typeof(self) weakself = self;
    [self fetchGatewaySubDevicesWithCompletionHandler:^(NSArray<MHDeviceGatewayBase *> *subDevices) {
        __strong typeof(weakself) strongSelf = weakself;
        weakself.subDevices = subDevices;
        if (subDevices.count<=0){
            if (failure) {failure();}
            return;
        }
        dispatch_group_async(strongSelf.activitiesHelperGroup, dispatch_get_global_queue(0, 0), ^{
            NSArray *todoIndexs = [strongSelf.logHelper todoIndexArray];
            for (NSNumber *index in todoIndexs) {
                [strongSelf mapIndexWithType:strongSelf.activitiesType index:[index integerValue]];
            }
        });
        dispatch_group_notify(strongSelf.activitiesHelperGroup, dispatch_get_main_queue(), ^{
            NSLog(@"AASDASDASDASDASDASD33");
            if ([strongSelf.logHelper isCompleted]){
                success();
            }else{
                failure();
            }
        });
    }];
}

#pragma mark - 设置触发警戒设备
- (void)setSensorMagnetDefaultAlarmingWithSubDevices:(NSArray<MHDeviceGatewayBase *> *)subDevices
                                     todoSensorClass:(Class)class
                                   completionHandler:(void(^)(bool flag))completionHandler{
    NSMutableArray<MHDeviceGatewayBase *>* todoDevices = [NSMutableArray array];
    for (MHDeviceGatewayBase *subDevice in subDevices) {
        if ([subDevice isKindOfClass:class]){
            [todoDevices addObject:subDevice];
            NSLog(@"%@",subDevice);
        }
    }
    
    if (todoDevices.count < 1) {
        completionHandler(NO);
        return;
    }
    
    [todoDevices[0] setAlarmingWithSuccess:^(id obj) {
        completionHandler(YES);
    } failure:^(NSError *error) {
        completionHandler(NO);
    }];
}
#pragma mark - 定时警戒
//定时警戒：周一到周五9:00-18:00，Disable
- (void)setAlarmingTimerWithCompletionHandler:(void(^)(bool flag))completionHandler{
    
    MHDataDeviceTimer *newTimer = [[MHDataDeviceTimer alloc] init];
    newTimer.identify = @"lumi_gateway_arming_timer";
    newTimer.onMethod = @"set_arming";
    newTimer.onParam = @[ @"on" ];
    newTimer.offMethod = @"set_arming";
    newTimer.offParam = @[ @"off" ];
    newTimer.onRepeatType = MHDeviceTimerRepeat_Workday;
    newTimer.offRepeatType = MHDeviceTimerRepeat_Workday;
    newTimer.onHour = 9;
    newTimer.onMinute = 0;
    newTimer.offHour = 18;
    newTimer.offMinute = 0;
    newTimer.onDay = 0;
    newTimer.onMonth = 0;
    newTimer.offDay = 0;
    newTimer.offMonth = 0;
    newTimer.isEnabled = NO;
    newTimer.isOnOpen = YES;
    newTimer.isOffOpen = YES;
    [self.gateway editTimer:newTimer success:^(id obj) {
        completionHandler(YES);
    } failure:^(NSError *error) {
        completionHandler(NO);
    }];
}

#pragma mark - 开启感应夜灯
//开夜灯和开启触发设备
- (void)setNightLightEnableWithCompletionHandler:(void(^)(bool flag))completionHandler{
    __weak typeof(self) weakself = self;
    [self.gateway setProperty:CORRIDOR_LIGHT_INDEX value:@"on" success:^(id obj) {
        __strong typeof(weakself) strongSelf = weakself;
        NSMutableArray<MHDeviceGatewaySensorMotion *>* todoDevices = [NSMutableArray array];
        for (MHDeviceGatewayBase *subDevice in strongSelf.subDevices) {
            if ([subDevice isKindOfClass:[MHDeviceGatewaySensorMotion class]]){
                [todoDevices addObject:(MHDeviceGatewaySensorMotion *)subDevice];
                NSLog(@"%@",subDevice);
            }
        }
        
        if (todoDevices.count < 1) {
            completionHandler(NO);
            return;
        }
        
        NSArray *param = @[ @0, @0, @0, @0];
        [todoDevices[0] setOpenNightLightWithTime:param Success:^(id obj) {
            completionHandler(YES);
        } failure:^(NSError *error) {
            completionHandler(NO);
        }];
    } failure:^(NSError *error) {
        completionHandler(NO);
    }];
}

#pragma mark - 定时彩灯
//每天：18:00-22:00，Disable
- (void)setColorLightTimerWithCompletionHandler:(void(^)(bool flag))completionHandler{
    //0x2b00ff7f 定时彩灯
    //
    MHDataDeviceTimer *newTimer = [[MHDataDeviceTimer alloc] init];
    newTimer.identify = @"lumi_gateway_single_rgb_timer";
    newTimer.onMethod = @"set_night_light_rgb";
    newTimer.onParam = @[ @(0x2b00ff7f) ];
    newTimer.offMethod = @"toggle_light";
    newTimer.offParam = @[ @"off" ];
    newTimer.onRepeatType = MHDeviceTimerRepeat_Workday;
    newTimer.offRepeatType = MHDeviceTimerRepeat_Workday;
    newTimer.onHour = 18;
    newTimer.onMinute = 0;
    newTimer.offHour = 22;
    newTimer.offMinute = 0;
    newTimer.onDay = 0;
    newTimer.onMonth = 0;
    newTimer.offDay = 0;
    newTimer.offMonth = 0;
    newTimer.isEnabled = NO;
    newTimer.isOnOpen = YES;
    newTimer.isOffOpen = YES;
    [self.gateway editTimer:newTimer success:^(id obj) {
        completionHandler(YES);
    } failure:^(NSError *error) {
        completionHandler(NO);
    }];
}

#pragma mark - 懒人闹钟
//周一到周五7:30，Disable
- (void)setAlarmClockWithCompletionHandler:(void(^)(bool flag))completionHandler{
    MHDataDeviceTimer *newTimer = [[MHDataDeviceTimer alloc] init];
    newTimer.isEnabled = NO;
    newTimer.isOnOpen = YES;
    newTimer.isOffOpen = YES;
    newTimer.onHour = 7;
    newTimer.onMinute = 30;
    newTimer.onDay = 0;
    newTimer.onMonth = 0;
    newTimer.offHour = 8;
    newTimer.offMinute = 0;
    newTimer.offMonth = 0;
    newTimer.offDay = 0;
    newTimer.onParam = @[@"on",@"20",@60];
    newTimer.onRepeatType = MHDeviceTimerRepeat_Workday;
    newTimer.offRepeatType = MHDeviceTimerRepeat_Workday;
    newTimer.identify = @"lumi_gateway_clock_timer";
    newTimer.onMethod = @"play_alarm_clock";
    newTimer.offMethod = @"play_alarm_clock";
    newTimer.offParam = @[ @"off" ];
    newTimer.onDay = 0;
    newTimer.onMonth = 0;
    
    [self.gateway editTimer:newTimer success:^(id obj) {
        completionHandler(YES);
    } failure:^(NSError *error) {
        completionHandler(NO);
    }];
}

#pragma mark - 门铃触发设备
- (void)setDoorbellTriggerWithSubDevices:(NSArray<MHDeviceGatewayBase *> *)subDevices
                         todoSensorClass:(Class)class
                       completionHandler:(void(^)(bool flag))completionHandler{
    
    NSMutableArray<MHDeviceGatewayBase *>* todoDevices = [NSMutableArray array];
    for (MHDeviceGatewayBase *subDevice in subDevices) {
        if ([subDevice isKindOfClass:class]){
            [todoDevices addObject:subDevice];
            NSLog(@"%@",subDevice);
        }
    }
    
    if (todoDevices.count < 1) {
        completionHandler(NO);
        return;
    }
    
    MHLumiBindItem* item = [[MHLumiBindItem alloc] init];
    item.to_sid = SID_Gateway;
    item.method = Method_Door_Bell;
    item.from_sid = todoDevices[0].did;
    item.params = @[@([self.gateway.default_music_index[BellGroup_Door] integerValue])];
    if([todoDevices[0] isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorSwitch")]){
        item.event = Gateway_Event_Switch_Click;
    }
    if([todoDevices[0] isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorMagnet")]){
        item.event = Gateway_Event_Magnet_Open;
    }
    [todoDevices[0] addBind:item success:^(id obj) {
        completionHandler(YES);
    } failure:^(NSError *error) {
        completionHandler(NO);
    }];
}

#pragma mark - 自定义自动化

- (void)setCustomIFTTTIfSwitchSingleTapThenPlugOnOffWithCompletionHandler:(void(^)(bool flag))completionHandler{
    [MHLumiIFTTTHelper addCustomIFTTTAtDouble11WithGateway:self.gateway actionId:@"184" actionDeviceClass:[MHDeviceGatewaySensorPlug class] trigerId:@"18" trigerDeviceClass:[MHDeviceGatewaySensorSwitch class] customName:nil completionHandler:^(bool flag) {
        completionHandler(flag);
    }];
}

- (void)setCustomIFTTTIfSwitchDoubleTapThenGatewayAlarmOnOffWithCompletionHandler:(void(^)(bool flag))completionHandler{
    [MHLumiIFTTTHelper addCustomIFTTTAtDouble11WithGateway:self.gateway actionId:@"138" subDeviceClass:[MHDeviceGatewaySensorSwitch class] trigerId:@"19" customName:nil completionHandler:^(bool flag) {
        completionHandler(flag);
    }];
}

#pragma mark - convenience func
- (void)fetchGatewaySubDevicesWithCompletionHandler:(void(^)(NSArray <MHDeviceGatewayBase *>*subDevices))completionHandler{
    if (_gateway.subDevices.count <= 0) {
        [_gateway getSubDeviceListWithSuccess:^(id obj) {
            NSArray <MHDataDevice *>* dataDevices = obj;
            NSMutableArray <MHDeviceGatewayBase *>* subDevices = [NSMutableArray array];
            for (MHDataDevice *dataDevice in dataDevices) {
                MHDeviceGatewayBase *subDevice = (MHDeviceGatewayBase *)[MHDevFactory deviceFromModelId:dataDevice.model dataDevice:dataDevice];
                [subDevices addObject:subDevice];
            }
            completionHandler(subDevices);
        } failuer:^(NSError *error) {
            completionHandler(nil);
        }];
    }else{
        completionHandler(_gateway.subDevices);
    }
}

#pragma mark - 活动映射
- (void)mapIndexWithType:(MHLumiActivitiesType)type index:(NSInteger)index{
    switch (type) {
        case MHLumiActivitiesTypeDouble11:
            [self double11MapIndexToSelector:index];
            break;
        default:
            break;
    }
}

#pragma mark - index到具体设置func的映射
//双11的
- (void)double11MapIndexToSelector:(NSInteger) index{
    if (self.subDevices.count <= 0){
        return;
    }
    __weak typeof(self) weakself = self;
    void(^completionHandler)(bool flag) = ^(bool flag){
        __strong typeof(weakself) strongSelf = weakself;
        [strongSelf.logHelper setRequestStatus:flag ? 1 : -1 indexKey:index];//0
        dispatch_group_leave(strongSelf.activitiesHelperGroup);
    };
    
    switch (index) {
        case 0:{//门窗警戒触发设备
            dispatch_group_enter(_activitiesHelperGroup);
            [self setSensorMagnetDefaultAlarmingWithSubDevices:self.subDevices
                                               todoSensorClass:[MHDeviceGatewaySensorMagnet class]
                                             completionHandler:completionHandler];
        }
            break;
        case 1:{//定时警戒
            dispatch_group_enter(_activitiesHelperGroup);
            [self setAlarmingTimerWithCompletionHandler:completionHandler];
        }
            break;
        case 2:{//开启感应夜灯和设置出发设备
            dispatch_group_enter(_activitiesHelperGroup);
            [self setNightLightEnableWithCompletionHandler:completionHandler];
        }
            break;
        case 3:{//定时彩灯
            dispatch_group_enter(_activitiesHelperGroup);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakself setColorLightTimerWithCompletionHandler:completionHandler];
            });
        }
            break;
        case 4:{//懒人闹钟
            dispatch_group_enter(_activitiesHelperGroup);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakself setAlarmClockWithCompletionHandler:completionHandler];
            });
        }
            break;
        case 5:{//门铃触发设备
            dispatch_group_enter(_activitiesHelperGroup);
            [self setDoorbellTriggerWithSubDevices:self.subDevices
                                   todoSensorClass:[MHDeviceGatewaySensorMagnet class]
                                 completionHandler:completionHandler];
        }
            break;
        case 6:{//自动化 单击无线开关 → 插座开/关
            dispatch_group_enter(_activitiesHelperGroup);
            [weakself setCustomIFTTTIfSwitchSingleTapThenPlugOnOffWithCompletionHandler:completionHandler];
        }
            break;
        case 7:{//自动化 双击无线开关 → 开/关警戒模式
            dispatch_group_enter(_activitiesHelperGroup);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakself setCustomIFTTTIfSwitchDoubleTapThenGatewayAlarmOnOffWithCompletionHandler:completionHandler];
            });
        }
            break;
        default:
            break;
    }
}

@end
