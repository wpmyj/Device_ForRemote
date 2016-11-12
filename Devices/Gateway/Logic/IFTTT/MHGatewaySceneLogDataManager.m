//
//  MHGatewaySceneLogDataManager.m
//  MiHome
//
//  Created by guhao on 16/5/6.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewaySceneLogDataManager.h"
#import "MHGatewaySceneLogDataRequest.h"
#import "MHGatewaySceneLogDataResponse.h"
#import "MHIFTTTManager.h"
#import "MHDeviceGatewayBase.h"

@interface MHGatewaySceneLogDataManager ()

@property (nonatomic, assign) NSTimeInterval timestamp;//拉取日志的截止时间

@end

@implementation MHGatewaySceneLogDataManager
{
    
    MHDataGatewaySceneLog* _lastLog;
}

+ (id)sharedInstance {
    static MHGatewaySceneLogDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[MHGatewaySceneLogDataManager alloc] init];
        }
    });
    return manager;
}

#pragma mark - 请求
//打包“刷新”请求
- (MHBaseRequest*)packageRefreshRequest:(NSInteger)pageSize {
    MHGatewaySceneLogDataRequest* request = [[MHGatewaySceneLogDataRequest alloc] init];
//    request.did = _device.did;
//    request.keys = _events;
//    request.timestamp = -1;
//    request.limit = pageSize > LOG_LIMIT ? LOG_LIMIT : pageSize;
    return request;
}

//打包“获取更多”请求
- (MHBaseRequest*)packageLoadNextPageRequest:(NSInteger)pageSize {
    MHGatewaySceneLogDataRequest* request = [[MHGatewaySceneLogDataRequest alloc] init];
    request.timestamp = _timestamp;
//    request.limit = pageSize > LOG_LIMIT ? LOG_LIMIT : pageSize;
    return request;
}

- (void)getMoreExecuteHistoryWithDeviceDids:(NSArray *)dids Success:(void (^)())success failure:(void (^)())failure {
    MHGatewaySceneLogDataRequest* request = [MHGatewaySceneLogDataRequest new];
    request.dids = dids;
    request.timestamp = self.timestamp;
    XM_WS(ws);
    [[MHNetworkEngine sharedInstance] sendRequest:request success:^(id json) {
        MHGatewaySceneLogDataResponse* response = [MHGatewaySceneLogDataResponse responseWithJSONObject:json];
        if (response.code == 0) {
            NSMutableArray *tempArray = [NSMutableArray new];
            MHDataGatewaySceneLog *last = [response.sceneLogs lastObject];
            if (ws.timestamp != last.executeTime) {
                ws.timestamp = last.executeTime;
                [tempArray addObjectsFromArray:ws.executeHistories];
                [tempArray addObjectsFromArray:response.sceneLogs];
                NSArray *newArray = [ws processHistoryLogs:tempArray];
                ws.executeHistories = [NSMutableArray arrayWithArray:newArray];
            }
            else {
                [[MHTipsView shareInstance] showTipsInfo:    NSLocalizedStringFromTable(@"ifttt.scene.local.scene.log.refresh.nomoredaata", @"plugin_gateway", "已经加载全部数据")
 duration:1.5f modal:NO];
            }
//            ws.executeHistories = [ws processHistoryLogs:response.sceneLogs];
//            ws.executeHistories = tempArray;
            if (success) {
                success();
            }
        } else {
            if (failure) {
                failure();
            }
        }
    } failure:^(NSError *v) {
        if (failure) {
            failure();
        }
    }];

}

- (void)getExecuteHistoryWithDeviceDids:(NSArray *)dids date:(NSDate *)date success:(void (^)())success failure:(void (^)())failure {
    MHGatewaySceneLogDataRequest* request = [MHGatewaySceneLogDataRequest new];
//    request.timestamp = date;
//    NSLog(@"转换前的时间%lf", [date timeIntervalSince1970]);
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date];
//    NSLog(@"%ld, %ld, %ld,  %ld, %ld", [comp1 year],[comp1 month], [comp1 day] ,[comp1 hour], [comp1 minute]);
    comp1.hour = 23;
    comp1.minute = 59;
    comp1.second = 59;
//    NSDateComponents *newComp = [NSDateComponents ]
    
    NSDate *requestDate = [calendar dateFromComponents:comp1];
//    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:requestDate];
//    NSLog(@"%ld, %ld, %ld, %ld, %ld", [comp2 year],[comp2 month], [comp2 day], [comp2 hour], [comp2 minute]);
    request.timestamp = [requestDate timeIntervalSince1970];
    request.dids = dids;
//    NSLog(@"转换后的时间%lf", request.timestamp);
    XM_WS(ws);
    [[MHNetworkEngine sharedInstance] sendRequest:request success:^(id json) {
        MHGatewaySceneLogDataResponse* response = [MHGatewaySceneLogDataResponse responseWithJSONObject:json];
        if (response.code == 0) {
            MHDataGatewaySceneLog *last = [response.sceneLogs lastObject];
            ws.timestamp = last.executeTime;
            ws.executeHistories = [ws processHistoryLogs:response.sceneLogs];
            ws.deviceDid = [dids firstObject];
            [ws saveLogList];
            if (success) {
                success();
            }
        } else {
            if (failure) {
                failure();
            }
        }
    } failure:^(NSError *v) {
        if (failure) {
            failure();
        }
    }];

}


- (void)getExecuteHistoryWithDeviceDids:(NSArray *)dids
                                Success:(void (^)())success
                                failure:(void (^)())failure {
    MHGatewaySceneLogDataRequest* request = [MHGatewaySceneLogDataRequest new];
    request.dids = dids;
    request.timestamp = 0;

    XM_WS(ws);
    [[MHNetworkEngine sharedInstance] sendRequest:request success:^(id json) {
        MHGatewaySceneLogDataResponse* response = [MHGatewaySceneLogDataResponse responseWithJSONObject:json];
        if (response.code == 0) {
            //            ws.executeHistories = [response.histories mutableCopy];
            MHDataGatewaySceneLog *last = [response.sceneLogs lastObject];
            ws.timestamp = last.executeTime;
            ws.executeHistories = [ws processHistoryLogs:response.sceneLogs];
            [ws saveLogList];
            if (success) {
                success();
            }
        } else {
            if (failure) {
                failure();
            }
        }
    } failure:^(NSError *v) {
        if (failure) {
            failure();
        }
    }];

}



#pragma mark - 自动化日志
/**
 自动化日志：在展示时，需要按日期分段展示，所以我们需要在data source将其按日期做个分组
 1. 不同的日期之间添加一个“fake item”，用来展示这一组的日期
 2. 每个自动化日志添加hasPrev 和 hasNext标志，用来标识是否是此组的开头或结尾，因为开头和结尾在ui展示上会有差异
 */
- (NSMutableArray* )processHistoryLogs:(NSArray* )logs {
    
    MHIFTTTManager *iFTTTManager = [MHIFTTTManager sharedInstance];
    
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    
    //    if ([opMode isEqualToString:Operation_Refresh])
    {
        _lastLog = nil;
    }
    
    NSMutableArray* processedLog = [[NSMutableArray alloc] init];
    NSInteger idx = 0;
    for (MHDataGatewaySceneLog* log in logs) {
        //        if ([[MHDeviceGateway getLogDetailString:log] length] > 0)
        {
            
            NSDateComponents* compsOfLastLog = [calendar components:unitFlags fromDate:[NSDate dateWithTimeIntervalSince1970:_lastLog.executeTime]];
            NSDateComponents* compsLog = [calendar components:unitFlags fromDate:[NSDate dateWithTimeIntervalSince1970:log.executeTime]];
            if (compsLog.day != compsOfLastLog.day ||
                compsLog.month != compsOfLastLog.month ||
                compsLog.year != compsOfLastLog.year) {
                MHDataGatewaySceneLog* fakeLog = [[MHDataGatewaySceneLog alloc] init];
                fakeLog.executeTime = log.executeTime;
                fakeLog.recordType = @"fake";
                [processedLog addObject:fakeLog];
            }
            
            //设置Log在Tableview中，前后是否有真实的同一天的log
            MHDataGatewaySceneLog* lastLogInProcessedLog = (MHDataGatewaySceneLog*)[processedLog lastObject];//可能是fake
            MHDataGatewaySceneLog* lastLogInDataList = (MHDataGatewaySceneLog*)[iFTTTManager.recordList lastObject];//可能是fake
            if (idx == 0) {
                //本次拉取的组中的第一条
                //                if ([opMode isEqualToString:Operation_Refresh])
                {
                    log.isFirst = YES;
                }
                
//                if ([self getDataListCount] > 0 &&
//                                    ![opMode isEqualToString:Operation_Refresh] && !lastLogInProcessedLog)
                if ([iFTTTManager.recordList count] > 0 && !lastLogInProcessedLog)
                {
                    
                    if (![lastLogInDataList.recordType isEqualToString:@"fake"]) {
                        log.hasPrev = YES;
                        lastLogInDataList.hasNext = YES;
                    } else {
                        log.hasPrev = NO;
                    }
                }
            } else {
                
                if (![lastLogInProcessedLog.recordType isEqualToString:@"fake"]) {
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





#pragma mark - 缓存
- (void)saveLogList {
    [[MHPlistCacheEngine sharedEngine] asyncSave:self.executeHistories toFile:[NSString stringWithFormat:@"scene_logList_%@", self.deviceDid] withFinish:nil];
}
- (void)restoreLogListWithFinish:(void(^)(id))finish {
    [[MHPlistCacheEngine sharedEngine] asyncLoadFromFile:[NSString stringWithFormat:@"scene_logList_%@", self.deviceDid] withFinish:^(id obj) {
        if ([obj isKindOfClass:[NSArray class]]) {
            self.executeHistories = [obj mutableCopy];
        }
        if (finish) {
            finish(obj);
        }
    }];
}





@end
