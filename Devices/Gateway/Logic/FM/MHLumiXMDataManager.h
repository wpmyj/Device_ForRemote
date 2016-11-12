//
//  MHLumiXMDataManager.h
//  MiHome
//
//  Created by Lynn on 11/20/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>
#import <MiHomeKit/XMReqMgr.h>
#import "MHDeviceGateway.h"
#import "MHLumiXMProvince.h"
#import "MHLumiXMRadio.h"
#import "MHLumiXMPageInfo.h"
#import "MHLumiXMProgram.h"
#import "MHLumiXMTopWord.h"

#define DataType_Province           @"Province"
#define DataType_CountryRadio       @"CountryRadio"
#define DataType_NetworkRadio       @"NetworkRadio"
#define DataType_LocalRadio         @"LocalRadio"
#define DataType_RankRadio          @"RankRadio"
#define DataType_Collection         @"Collection"

typedef enum{
    XDefultFailed = 1000,
    XUptoLimitedValue
} ErrorCode;

@interface MHLumiXMDataManager : MHDataListManagerBase

+ (id)sharedInstance;

#pragma mark - 搜索 && 获取热搜词
//- (void)fetchXMHotWordsWithCompletionHandler:(void (^)(id result, NSError *error))completionHandler ;

- (void)restoreTopWordsDataListWithSuccess:(SucceedBlock)success ;

- (void)fetchKeywordRadios:(NSString *)keyword withCompletionHandler:(void (^)(id result, NSError *error))completionHandler ;

- (void)restoreHistoryKeywords:(SucceedBlock)success ;
- (void)removeOneWord:(MHLumiXMTopWord *)word ;

#pragma mark - 节目单 & 节目详情
- (void)fetchProgramList:(NSDictionary *)params
             withSuccess:(void (^)(NSMutableArray *datalist))success
              andFailure:(void (^)(NSError *error))failure ;

- (void)fetchProgramDetailWithRadioId:(NSString *)radioId
                              success:(void (^)(id dataInfo))success
                           andFailure:(void (^)(NSError *error))failure;

#pragma mark - 获取收藏
- (void)restoreCollectionRadioDeviceDid:(NSString *)did
                             withFinish:(void (^)(NSMutableArray *datalist))finish ;
- (void)saveCollectedRadioDeviceDid:(NSString *)did
                       withDataList:(NSArray *)datalist ;
- (void)fetchCollectionRadioWithDeviceDid:(NSString *)deviceDid
                              WithSuccess:(void (^)(NSMutableArray *datalist))success
                               andFailure:(void (^)(NSError *error))failure;
//actionType @"add" @"remove"

- (void)setCollectionRadio:(MHLumiXMRadio *)radio
             withDeviceDid:(NSString *)deviceDid
             andActionType:(NSString *)actionType
               WithSuccess:(void (^)(id obj))success
                andFailure:(void (^)(NSError *error))failure ;

- (void)locateRadioInCollectionList:(MHLumiXMRadio *)radio
                           DeviceId:(NSString *)deviceId
                        withSuccess:(void (^)(MHLumiXMRadio *radio))success
                         andFailure:(void (^)(NSError *error))failure;

#pragma mark - 直播排行更新
- (void)fetchRankWithFinish:(void (^)(NSMutableArray *datalist))finish
                andDeviceId:(NSString *)deviceId ;
- (void)restoreRankRadioWithFinish:(void (^)(NSMutableArray *datalist))finish;

#pragma mark - 电台更新
//获取本地/国家/网络电台
- (void)fetchRadio:(NSMutableDictionary *)params
        withFinish:(void (^)(NSMutableArray *datalist))finish
       andDeviceId:(NSString *)deviceId ;
//从缓存获取本地/国家/网络电台
- (void)restoreRadioType:(NSString *)radioType
              withFinish:(void (^)(NSMutableArray *datalist))finish;
//获取特定电台的详细信息
- (void)fetchRadioByIds:(NSArray *)idsArray
            withSuccess:(SucceedBlock)success
                failure:(FailedBlock)failure;

#pragma mark - 省列表
- (void)fetchProvinceDataManager;
- (void)restoreProvinceDataIfNotLaunchRequestWithdCompleteHandle:(void(^)(id obj,bool flag))completeHandle;
- (MHLumiXMProvince *)fetchCurrentProvince:(MKPlacemark *)currentPlaceMark
                           andProvinceList:(NSArray *)provinceList;

#pragma mark - 缓存
- (void)restoreRadioDataListWithDataType:(NSString *)dataType
                               andFinish:(void(^)(id))finish;

@end
