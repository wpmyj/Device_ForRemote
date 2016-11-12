//
//  MHGatewaySceneLogDataManager.h
//  MiHome
//
//  Created by guhao on 16/5/6.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>
#import "MHDataGatewaySceneLogMessage.h"
#import "MHDataGatewaySceneLog.h"

#define kALLDEVICE @"allDeviceDids"

@interface MHGatewaySceneLogDataManager : MHDataListManagerBase

+ (id)sharedInstance;

@property (nonatomic, retain) NSMutableArray *executeHistories;  //执行历史
@property (nonatomic, copy) NSString *deviceDid;

/**
 *  获取自动化日志,默认最新
 *
 *  @param dids    需要获取日志的设备did
 *  @param success 包含 MHDataGatewaySceneLog 的数组
 *  @param failure failure description
 */
- (void)getExecuteHistoryWithDeviceDids:(NSArray *)dids Success:(void (^)())success
                         failure:(void (^)())failure;
/**
 *  加载更多自动化日志
 *
 *  @param dids    dids description
 *  @param success success description
 *  @param failure failure description
 */
- (void)getMoreExecuteHistoryWithDeviceDids:(NSArray *)dids Success:(void (^)())success
                                failure:(void (^)())failure;
/**
 *  获取指定时间点的自动化日志
 *
 *  @param dids    dids description
 *  @param date    date description
 *  @param success success description
 *  @param failure failure description
 */
- (void)getExecuteHistoryWithDeviceDids:(NSArray *)dids date:(NSDate *)date success:(void (^)())success
                                    failure:(void (^)())failure;
/**
 *  读取自动化日志缓存
 *
 *  @param finish finish description
 */
- (void)restoreLogListWithFinish:(void(^)(id))finish;

@end
