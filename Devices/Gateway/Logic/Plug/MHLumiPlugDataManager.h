//
//  MHLumiPlugDataManager.h
//  MiHome
//
//  Created by Lynn on 11/12/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHDeviceGatewayBase.h"

@interface MHLumiPlugDataManager : NSObject

//当前插座设备，需要初始化plug的，请不要使用单例
@property (nonatomic,strong) MHDeviceGatewayBase *quantDevice;

//使用这个，请注意plug的初始化
+ (id)sharedInstance ;

#pragma mark - 电量记录
/**
 *  获取电量历史记录
 *
 *  @param params     @{@"groupType" : ... , @"startDateString" : ... , @"endDateString" : ... ,}
 *  @param success    返回数据格式 ： ["time,powerCost","1446307200,103","1448899200,0"]
 *  @param failure    返回失败错误信息
 */
- (void)fetchPlugQuantHistoryDataWithParams:(NSDictionary *)params
                                    Success:(SucceedBlock)success
                                 andFailure:(FailedBlock)failure ;

/**
 *  获取插座电量信息
 *
 *  @param parms   @{@"groupType" : ... , @"dateString" : ... }
 *  @param success 返回数据格式 ： ["time,powerCost","1446307200,103","1448899200,0"]
 *  @param failure 返回失败错误信息
 */
- (void)fetchLumiPlugDataWithParams:(NSDictionary *)parms
                            Success:(SucceedBlock)success
                         andfailure:(FailedBlock)failure;

@end
