//
//  MHGatewayLogListManager.h
//  MiHome
//
//  Created by Woody on 15/4/10.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>
#import "MHDataGatewayLog.h"
@interface MHGatewayLogListManager : MHDataListManagerBase

@property (nonatomic, retain) MHDataGatewayLog* latestLog;
@property (nonatomic, strong) NSString *deviceClass;
/**
 *  子设备did与子设备name的key-value
 */
@property (nonatomic, strong) NSDictionary *deviceNames;

- (id)initWithManagerIdentify:(NSString*)managerIdentify device:(MHDevice* )device;
- (void)deleteAllLogsWithSuccess:(SucceedBlock)success failure:(FailedBlock)failure;
- (void)getLatestLogWithSuccess:(SucceedBlock)success failure:(FailedBlock)failure;

- (NSString* )getLatestLogDescription;
+ (NSString* )getLogDescription:(MHDataGatewayLog* )log;

- (NSString* )notificationNameForDeleteAllLogs;
//- (NSString* )notificationNameForGetLatestLog;

- (void)saveLogList;
- (void)restoreLogListWithFinish:(void(^)(id))finish;
- (void)saveLatestLog;
- (void)restoreLatestLogWithFinish:(void(^)(id))finish;
@end
