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


- (void)getExecuteHistoryWithDeviceDids:(NSArray *)dids Success:(void (^)())success
                         failure:(void (^)())failure;

- (void)getMoreExecuteHistoryWithDeviceDids:(NSArray *)dids Success:(void (^)())success
                                failure:(void (^)())failure;

- (void)getExecuteHistoryWithDeviceDids:(NSArray *)dids date:(NSDate *)date success:(void (^)())success
                                    failure:(void (^)())failure;

- (void)restoreLogListWithFinish:(void(^)(id))finish;

@end
