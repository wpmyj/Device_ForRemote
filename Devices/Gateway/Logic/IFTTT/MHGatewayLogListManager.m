//
//  MHGatewayLogListManager.m
//  MiHome
//
//  Created by Woody on 15/4/10.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import "MHGatewayLogListManager.h"
#import "MHGetSubDataRequest.h"
#import "MHGetSubDataResponse.h"
#import "MHDeviceGatewayBase.h"
#import "MHSetSubDataRequest.h"
#import "MHDeviceGateway.h"
#import <MiHomeKit/MHPlistCacheEngine.h>
#import <MiHomeKit/MHTimeUtils.h>
#import "MHLMLogKeyMap.h"

#define LOG_LIMIT 20

@implementation MHGatewayLogListManager {
    __weak MHDeviceGatewayBase*             _device;
    NSMutableArray*                         _events;
    NSInteger                               _timestamp;
    
    MHDataGatewayLog*                       _lastLog;
}

#pragma mark - 初始化
- (id)initWithManagerIdentify:(NSString*)managerIdentify device:(MHDevice* )device {
    self = [super initWithManagerIdentify:managerIdentify];
    if (self) {
        _device = (MHDeviceGatewayBase *)device;
        _deviceClass = NSStringFromClass([device class]);
        _timestamp = -1;
        [self initDeviceEvents];
        [self restoreLogListWithFinish:nil];
        [self restoreLatestLogWithFinish:nil];
    }
    return self;
}

- (void)dealloc {
    
}

- (void)initDeviceEvents {
    _events = [[NSMutableArray alloc] init];
    
    if ([_device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorCube")]){
        [_events addObject:Gateway_Event_Cube_flip90];
        [_events addObject:Gateway_Event_Cube_flip180];
        [_events addObject:Gateway_Event_Cube_move];
        [_events addObject:Gateway_Event_Cube_tap_twice];
        [_events addObject:Gateway_Event_Cube_shakeair];
        [_events addObject:Gateway_Event_Cube_rotate];
    }
    if ([_device isKindOfClass:NSClassFromString(@"MHDeviceGateway")]){
        [_events addObject:Araming_Event_Motion_Motion];
        [_events addObject:Araming_Event_Magnet_Open];
        [_events addObject:Araming_Event_Switch_Click];
        [_events addObject:Araming_Event_Cube_Alert];
    }
    if ([_device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorMotion")]){
        [_events addObject:Gateway_Event_Motion_Motion];
    }
    if ([_device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorMagnet")]){
        [_events addObject:Gateway_Event_Magnet_Open];
        [_events addObject:Gateway_Event_Magnet_Close];
        //            [_events addObject:Gateway_Event_Magnet_No_Close];
    }
    if ([_device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorSwitch")]){
        [_events addObject:Gateway_Event_Switch_Click];
        [_events addObject:Gateway_Event_Switch_Double_Click];
        [_events addObject:Gateway_Event_Switch_Long_click_Press];
    }
    if ([_device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorPlug")]){
        [_events addObject:Gateway_Event_Plug_Change];
    }
    if ([_device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorHumiture")]){
        [_events addObject:Gateway_Event_HT_dry_cold];
        [_events addObject:Gateway_Event_HT_humid_cold];
        [_events addObject:Gateway_Event_HT_cold];
        [_events addObject:Gateway_Event_HT_dry];
        [_events addObject:Gateway_Event_HT_comfortable];
        [_events addObject:Gateway_Event_HT_humid];
        [_events addObject:Gateway_Event_HT_dry_hot];
        [_events addObject:Gateway_Event_HT_humid_hot];
    }
    if ([_device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorSingleSwitch")]){
        [_events addObject:Gateway_Event_SingleSwitch_click];
        [_events addObject:Gateway_Event_SingleSwitch_double_click];
    }
    if ([_device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorDoubleSwitch")]){
        [_events addObject:Gateway_Event_DoubleSwitch_click_ch0];
        [_events addObject:Gateway_Event_DoubleSwitch_double_click_ch0];
        [_events addObject:Gateway_Event_DoubleSwitch_click_ch1];
        [_events addObject:Gateway_Event_DoubleSwitch_double_click_ch1];
        [_events addObject:Gateway_Event_DoubleSwitch_both_click];
    }
    if ([_device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorSmoke")] ||
        [_device isKindOfClass:NSClassFromString(@"MHDeviceGatewaySensorNatgas")]){
        [_events addObject:Gateway_Event_Smoke_Alarm];
        [_events addObject:Gateway_Event_Smoke_Self_Check];
    }
}

+ (NSString* )getLogDescription:(MHDataGatewayLog* )log {

    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm"];
    NSString* stringDetail = [MHTimeUtils gatewayLogDateString:log.time];
    stringDetail = [stringDetail stringByAppendingString:@" "];
    
    //添加判断，如果是当天日期，则不显示日期，只显示时间
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:log.time];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *currentComps;
    NSDateComponents *logComps;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        currentComps = [gregorian componentsInTimeZone:[NSTimeZone defaultTimeZone] fromDate:currentDate];
        logComps = [gregorian componentsInTimeZone:[NSTimeZone defaultTimeZone] fromDate:log.time];
    }
    else{
        currentComps = [gregorian components:NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:currentDate];
        logComps = [gregorian components:NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:log.time];
    }
    if(timeInterval < 86400.0 * 3){
        if (currentComps.day - logComps.day == 1){
            stringDetail = NSLocalizedStringFromTable(@"yesterday",@"plugin_gateway","昨天");
            stringDetail = [stringDetail stringByAppendingString:[NSString stringWithFormat:@"%02ld:%02ld",logComps.hour,logComps.minute]];
//            stringDetail = [stringDetail stringByAppendingString:[formatter stringFromDate:log.time]];
            stringDetail = [stringDetail stringByAppendingString:@" "];
        }
        else if (currentComps.day - logComps.day == 2){
            stringDetail = NSLocalizedStringFromTable(@"beforeyesterday",@"plugin_gateway","前天");
            stringDetail = [stringDetail stringByAppendingString:[NSString stringWithFormat:@"%02ld:%02ld",logComps.hour,logComps.minute]];
//            stringDetail = [stringDetail stringByAppendingString:[formatter stringFromDate:log.time]];
            stringDetail = [stringDetail stringByAppendingString:@" "];
        }
        else if (currentComps.day - logComps.day == 0){
//            stringDetail = [formatter stringFromDate:log.time];
            stringDetail = [NSString stringWithFormat:@"%02ld:%02ld",logComps.hour,logComps.minute];
            stringDetail = [stringDetail stringByAppendingString:@" "];
        }
    }
    
    if ([log.type isEqualToString:Gateway_Event] ) {
        stringDetail = [MHLMLogKeyMap LMDeviceLogKeyMap:stringDetail log:log];
    }
    return stringDetail;
}

- (NSString* )getLatestLogDescription {
    if (self.latestLog) {
        return [[self class] getLogDescription:self.latestLog];
    } else {
        return NSLocalizedStringFromTable(@"mydevice.gateway.log.none",@"plugin_gateway","无日志");
    }
}

- (NSString* )notificationNameForDeleteAllLogs {
    return [NSString stringWithFormat:@"%@_DelAllLogs_%p",self.managerIdentify,self];
}

#pragma mark - 请求
//打包“刷新”请求
- (MHBaseRequest*)packageRefreshRequest:(NSInteger)pageSize {
    MHGetSubDataRequest* request = [[MHGetSubDataRequest alloc] init];
    request.did = _device.did;
    request.keys = _events;
    request.timestamp = -1;
    request.limit = pageSize > LOG_LIMIT ? LOG_LIMIT : pageSize;
    return request;
}

//打包“获取更多”请求
- (MHBaseRequest*)packageLoadNextPageRequest:(NSInteger)pageSize {
    MHGetSubDataRequest* request = [[MHGetSubDataRequest alloc] init];
    request.did = _device.did;
    request.keys = _events;
    request.timestamp = _timestamp;
    request.limit = pageSize > LOG_LIMIT ? LOG_LIMIT : pageSize;
    return request;
}

- (NSArray* )processLogs:(NSArray* )logs opMode:(NSString*)opMode {

    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    
    if ([opMode isEqualToString:Operation_Refresh]) {
        _lastLog = nil;
    }
    
    NSMutableArray* processedLog = [[NSMutableArray alloc] init];
    NSInteger idx = 0;
    for (MHDataGatewayLog* log in logs) {
        log.deviceClass = self.deviceClass;
        if (self.deviceNames.count > 0) {
            if ([self.deviceNames[log.did] isEqualToString:@"小米多功能网关"] && log.subDeviceDid) {
                log.deviceName = self.deviceNames[log.subDeviceDid];
            }
            else {
                log.deviceName = self.deviceNames[log.did];
            }
        }
//        NSLog(@"%@", log.did);
//        NSLog(@"%@",log);
        if ([[MHDeviceGateway getLogDetailString:log] length] > 0) {

            NSDateComponents* compsOfLastLog = [calendar components:unitFlags fromDate:_lastLog.time];
            NSDateComponents* compsLog = [calendar components:unitFlags fromDate:log.time];
            if (compsLog.day != compsOfLastLog.day ||
                compsLog.month != compsOfLastLog.month ||
                compsLog.year != compsOfLastLog.year) {
                MHDataGatewayLog* fakeLog = [[MHDataGatewayLog alloc] init];
                fakeLog.time = log.time;
                fakeLog.type = @"fake";
                [processedLog addObject:fakeLog];
            }
            
            //设置Log在Tableview中，前后是否有真实的同一天的log
            MHDataGatewayLog* lastLogInProcessedLog = (MHDataGatewayLog*)[processedLog lastObject];//可能是fake
            MHDataGatewayLog* lastLogInDataList = (MHDataGatewayLog*)[self getLastObject];//可能是fake
            if (idx == 0) {
                //本次拉取的组中的第一条
                if ([opMode isEqualToString:Operation_Refresh]) {
                    log.isFirst = YES;
                }
                
                if ([self getDataListCount] > 0 &&
                    ![opMode isEqualToString:Operation_Refresh] && !lastLogInProcessedLog) {

                    if (![lastLogInDataList.type isEqualToString:@"fake"]) {
                        log.hasPrev = YES;
                        lastLogInDataList.hasNext = YES;
                    } else {
                        log.hasPrev = NO;
                    }
                }
            } else {

                if (![lastLogInProcessedLog.type isEqualToString:@"fake"]) {
                    log.hasPrev = YES;
                    lastLogInProcessedLog.hasNext = YES;
                } else {
                    log.hasPrev = NO;
                }
            }
            
            [processedLog addObject:log];
            _lastLog = log;
            
            idx++;
        }
    }
    return processedLog;
}

- (double)getLastLogTimestamp:(NSArray* )logs {
    MHDataGatewayLog* lastLog = logs[[logs count] -1 ];
    lastLog.deviceClass = self.deviceClass;
    return [lastLog.time timeIntervalSince1970];
}

- (void)disposeSucceedResponseAndNotifyUI:(id)response {
    MHGetSubDataResponse* rsp = [MHGetSubDataResponse responseWithJSONObject:response];
    [rsp extraFilterForSmokeAndNatgasSensorWithDeviceModel:_device.model];
    self.isHaveMore = ([rsp.logs count] >= self.pageSizeWant);
    _timestamp = [self getLastLogTimestamp:rsp.logs] - 1;

    NSString* opMode = [response objectForKey:Operation_Key];
    NSArray* processedLogs = [self processLogs:rsp.logs opMode:opMode];
    NSLog(@"%@", rsp.logs);
    [rsp.logs enumerateObjectsUsingBlock:^(MHDataGatewayLog *everyLog, NSUInteger idx, BOOL * _Nonnull stop) {
       NSLog(@"%@", everyLog.deviceName);
        NSLog(@"日志的值%@", everyLog.value);
        NSLog(@"%@", everyLog.did);

    }];
    if ([opMode isEqualToString:Operation_Refresh]) {
        [self replaceDataList:processedLogs];
    } else {
        [self appendDataList:processedLogs];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:[self notificationNameForUIUpdate]
                                                        object:nil
                                                      userInfo:@{MHNotificationKey_ResponseCode:@(rsp.code)}];
}

- (void)deleteAllLogsWithSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    MHSetSubDataRequest* request = [[MHSetSubDataRequest alloc] init];
    request.did = _device.did;
    request.key = @"HISTORY";
    request.type = @"DELETE_DEVICE_LOG";
    [[MHNetworkEngine sharedInstance] sendRequest:request success:^(id obj) {
        NSInteger code = [[obj objectForKey:@"code" class:[NSNumber class]] integerValue];
        if (code == 0) {
            MHSafeDictionary* mutableObj = [MHSafeDictionary dictionaryWithDictionary:obj];
            BOOL result = [[mutableObj objectForKey:@"result" class:[NSNumber class]] boolValue];
            if (result) {
                [self removeAllData];
                self.latestLog = nil;
                [[NSNotificationCenter defaultCenter] postNotificationName:[self notificationNameForUIUpdate]
                                                                    object:nil
                                                                  userInfo:@{MHNotificationKey_ResponseCode:@(code)}];
                [[NSNotificationCenter defaultCenter] postNotificationName:[self notificationNameForDeleteAllLogs] object:nil];
                if (success) {
                    success(mutableObj);
                }
            } else {
                if (failure) {
                    failure(obj);
                }
            }
        }else {
            if (failure) {
                failure(obj);
            }
        }

    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getLatestLogWithSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    MHGetSubDataRequest* request = [[MHGetSubDataRequest alloc] init];
    request.did = _device.did;
    request.keys = _events;
    request.timestamp = -1;
    request.limit = 1;
    [[MHNetworkEngine sharedInstance] sendRequest:request success:^(id obj) {
        MHGetSubDataResponse* rsp = [MHGetSubDataResponse responseWithJSONObject:obj];
        if (rsp.code == 0) {
            [rsp extraFilterForSmokeAndNatgasSensorWithDeviceModel:_device.model];
            self.latestLog = [rsp.logs lastObject];
            self.latestLog.deviceClass = self.deviceClass;
            if (success) {
                success(rsp);
            }
        }else {
            if (failure) {
                failure(obj);
            }
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark - 缓存
- (void)saveLogList {
    [[MHPlistCacheEngine sharedEngine] asyncSave:[self getDataList] toFile:[NSString stringWithFormat:@"gateway_logList_%@", _device.did] withFinish:nil];
}
- (void)restoreLogListWithFinish:(void(^)(id))finish {
    [[MHPlistCacheEngine sharedEngine] asyncLoadFromFile:[NSString stringWithFormat:@"gateway_logList_%@", _device.did] withFinish:^(id obj) {
        if ([obj isKindOfClass:[NSArray class]]) {
            [self replaceDataList:obj];
        }
        if (finish) {
            finish(obj);
        }
    }];
}

- (void)saveLatestLog {
    [[MHPlistCacheEngine sharedEngine] asyncSave:self.latestLog toFile:[NSString stringWithFormat:@"gateway_latestlog_%@", _device.did] withFinish:nil];
}
- (void)restoreLatestLogWithFinish:(void(^)(id))finish {
    [[MHPlistCacheEngine sharedEngine] asyncLoadFromFile:[NSString stringWithFormat:@"gateway_latestlog_%@", _device.did] withFinish:^(id obj) {
        if ([obj isKindOfClass:[MHDataGatewayLog class]]) {
            self.latestLog = obj;
        }
        if (finish) {
            finish(obj);
        }
    }];
}
@end
