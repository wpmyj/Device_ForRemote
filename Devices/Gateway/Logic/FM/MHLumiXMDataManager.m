//
//  MHLumiXMDataManager.m
//  MiHome
//
//  Created by Lynn on 11/20/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLumiXMDataManager.h"
#import "MHGatewayGetZipPDataRequest.h"
#import "MHGatewayGetZipPDataResponse.h"
#import "MHGatewaySetZipPDataRequest.h"
#import "MHGatewaySetZipPDataResponse.h"

#define FM_UserCollection @"lumi_gateway_fm_usercollection_"

@implementation MHLumiXMDataManager
{
    NSString *          _userID;
}

+ (id)sharedInstance {
    static MHLumiXMDataManager *obj = nil;
    @synchronized([MHLumiXMDataManager class]) {
        if(!obj)
            obj = [[MHLumiXMDataManager alloc] init];
    }
    return obj;
}

#pragma mark - 获取热搜词
- (void)fetchXMHotWordsWithCompletionHandler:(void (^)(id result, NSError *error))completionHandler {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@10 forKey:@"top"];
    
    XM_WS(weakself);
    [[XMReqMgr sharedInstance] requestXMData:XMReqType_SearchHotWords
                                      params:params
                        withCompletionHander:^(id result, XMErrorModel *error) {
                            if(error.error_code){
                                
                            }
                            else {
                                NSArray *topWordList = [MHLumiXMTopWord dataListWithJSONObjectList:result];
                                [weakself saveTopWordsDataList:topWordList];
                                if(completionHandler)completionHandler(topWordList,nil);
                            }
    }];
}

- (void)saveTopWordsDataList:(NSArray *)dataList {
//    _userID = [MHPassportManager sharedSingleton].currentAccount.userId;
    [[MHPlistCacheEngine sharedEngine] asyncSave:dataList
                                          toFile:@"lumi_gateway_xm_topwords"
                                      withFinish:nil];
}

- (void)restoreTopWordsDataListWithSuccess:(SucceedBlock)success {
//    _userID = [MHPassportManager sharedSingleton].currentAccount.userId;
    [[MHPlistCacheEngine sharedEngine] asyncLoadFromFile:@"lumi_gateway_xm_topwords"
                                              withFinish:^(id obj) {
                                                  if (success) success(obj);
                                              }];
}

- (void)fetchKeywordRadios:(NSString *)keyword withCompletionHandler:(void (^)(id result, NSError *error))completionHandler {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@20 forKey:@"count"];
    [params setObject:@1 forKey:@"page"];
    [params setObject:keyword forKey:@"q"];
    
    MHLumiXMTopWord *keyHistoryWord = [[MHLumiXMTopWord alloc] init];
    keyHistoryWord.search_word = keyword;
    keyHistoryWord.count = @(1);
    keyHistoryWord.degree = @"1";
    [self saveOneWord:keyHistoryWord];
    
    [[XMReqMgr sharedInstance] requestXMData:XMReqType_SearchRadios
                                      params:params
                        withCompletionHander:^(id result, XMErrorModel *error) {
                            if(error.error_code){
                                
                            }
                            else {
                                NSArray *searchRadios = [MHLumiXMRadio dataListWithJSONObjectList:[result valueForKey:@"radios"]];
                                if(completionHandler)completionHandler(searchRadios,nil);
                            }
                        }];
}

- (void)saveOneWord:(MHLumiXMTopWord *)word {
    XM_WS(weakself);
    [self restoreHistoryKeywords:^(NSArray *wordList) {
        
        NSMutableArray *oldWordList = [NSMutableArray arrayWithCapacity:1];
        if (wordList) oldWordList = [wordList mutableCopy];
        
        __block BOOL hasWordFlag = NO;
        [wordList enumerateObjectsUsingBlock:^(MHLumiXMTopWord *oldWord, NSUInteger idx, BOOL * stop) {
            if([oldWord.search_word isEqualToString:word.search_word]){
                word.count = @([oldWord.count intValue] + 1);
                [oldWordList removeObject:oldWord];
                [oldWordList addObject:word];
                hasWordFlag = YES;
            }
        }];
        if (!hasWordFlag) [oldWordList addObject:word];
        [weakself saveHistoryKeywords:oldWordList];
    }];
}

- (void)removeOneWord:(MHLumiXMTopWord *)word {
    XM_WS(weakself);
    [self restoreHistoryKeywords:^(NSArray *wordList) {
        
        NSMutableArray *oldWordList = [NSMutableArray arrayWithCapacity:1];
        if (wordList) oldWordList = [wordList mutableCopy];
        
        [wordList enumerateObjectsUsingBlock:^(MHLumiXMTopWord *oldWord, NSUInteger idx, BOOL * stop) {
            if([oldWord.search_word isEqualToString:word.search_word]){
                [oldWordList removeObject:oldWord];
            }
        }];
        [weakself saveHistoryKeywords:oldWordList];
    }];
}

- (void)saveHistoryKeywords:(NSArray *)keywords {
    NSLog(@"history keywords = %@",keywords);
    _userID = [MHPassportManager sharedSingleton].currentAccount.userId;
    [[MHPlistCacheEngine sharedEngine] asyncSave:keywords
                                          toFile:[NSString stringWithFormat:@"lumi_gateway_xm_historywords_%@",_userID]
                                      withFinish:nil];
}

- (void)restoreHistoryKeywords:(SucceedBlock)success {
    _userID = [MHPassportManager sharedSingleton].currentAccount.userId;
    [[MHPlistCacheEngine sharedEngine] asyncLoadFromFile:[NSString stringWithFormat:@"lumi_gateway_xm_historywords_%@",_userID]
                                              withFinish:^(NSArray *datalist) {
                                                  
                                                  NSMutableArray *mutableDataList = [datalist mutableCopy];
                                                  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"count" ascending:NO];
                                                  [mutableDataList sortUsingDescriptors:@[sortDescriptor]];
                                                  if (success) success(mutableDataList);
                                              }];
}

#pragma mark - 节目单
- (void)fetchProgramList:(NSDictionary *)params
             withSuccess:(void (^)(NSMutableArray *datalist))success
              andFailure:(void (^)(NSError *error))failure {
    
    [[XMReqMgr sharedInstance] requestXMData:XMReqType_LiveSchedule
                                      params:params
                        withCompletionHander:^(id result, XMErrorModel *error) {
                            
                            if(error.error_code){
                                if(failure)failure(nil);
                            }
                            else {
                                NSArray *pragramList = [MHLumiXMProgram dataListWithJSONObjectList:result];
                                if(success)success([pragramList mutableCopy]);
                            }
                        }];
}

- (void)fetchProgramDetailWithRadioId:(NSString *)radioId
                              success:(void (^)(id dataInfo))success
                           andFailure:(void (^)(NSError *error))failure {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:radioId forKey:@"radio_id"];
    
    [[XMReqMgr sharedInstance] requestXMData:XMReqType_LiveProgram
                                      params:params
                        withCompletionHander:^(id result, XMErrorModel *error) {
                            if(error.error_code){
                                if(failure)failure(nil);
                            }
                            else{
                                NSString *imgUrl = [result valueForKey:@"back_pic_url"];
                                NSString *pgName = [result valueForKey:@"program_name"];
                                NSString *rateUrl = [result valueForKey:@"rate64_aac_url"];
                                
                                NSMutableDictionary *radio = [NSMutableDictionary dictionaryWithCapacity:1];
                                if (imgUrl) [radio setObject:imgUrl forKey:@"radioCoverLargeUrl"];
                                if (imgUrl) [radio setObject:imgUrl forKey:@"radioCoverSmallUrl"];
                                if (radioId)[radio setObject:radioId forKey:@"radioId"];
                                if (rateUrl)[radio setObject:rateUrl forKey:@"radioRateUrl"];
                                if (pgName) [radio setObject:pgName forKey:@"radioName"];
                                
                                if(success)success(radio);
                            }
                        }];
}

#pragma mark - 修改收藏表，如果用户没有编辑过，增加两条默认的数据，从排行中取得
- (void)fetchRankListAndAddTwoToCollectionList:(NSString *)deviceId withSuccess:(SucceedBlock)success {
    
    NSString *keyString = [NSString stringWithFormat:@"%@%@",FM_UserCollection,deviceId];

    XM_WS(weakself);
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@20 forKey:@"radio_count"];
    [[XMReqMgr sharedInstance] requestXMData:XMReqType_RankRadio
                                      params:params
                        withCompletionHander:^(id result, XMErrorModel *error) {
                            if(error.error_code){
                                
                            }
                            else {
                                NSArray *rankRadioList = [MHLumiXMRadio dataListWithJSONObjectList:result];
                                
                                if (rankRadioList.count > 2){
                                    NSMutableArray *defaultCollectionList = [NSMutableArray arrayWithCapacity:2];
                                    MHLumiXMRadio *radio0 = rankRadioList[0];
                                    radio0.radioCollection = @"yes";
                                    MHLumiXMRadio *radio1 = rankRadioList[1];
                                    radio1.radioCollection = @"yes";
                                    [defaultCollectionList addObject:[radio0 toJson]];
                                    [defaultCollectionList addObject:[radio1 toJson]];
                                    //写缓存
                                    [weakself saveCollectedRadioDeviceDid:deviceId withDataList:defaultCollectionList];
                                    if(success) success(defaultCollectionList);
                                    
                                    //设置Pdata
                                    MHGatewaySetZipPDataRequest *req = [[MHGatewaySetZipPDataRequest alloc] init];
                                    req.keyString = keyString;
                                    req.value = defaultCollectionList;
                                    [[MHNetworkEngine sharedInstance] sendRequest:req success:nil failure: nil];
                                    
                                    //对收藏的电台匹配，修改当前数据
                                    [weakself mapTheCollectionRadio:[rankRadioList mutableCopy]
                                                       withDeviceId:deviceId
                                                         andSuccess:^(NSMutableArray *datalist) {
                                                             //只对第一页进行缓存(rank的只有一页)
                                                             [weakself saveRadioDataList:DataType_RankRadio andDataList:datalist];
                                                         }];
                                }
                            }
     }];
}

#pragma mark - 获取收藏
- (void)fetchCollectionRadioWithDeviceDid:(NSString *)deviceDid
                              WithSuccess:(void (^)(NSMutableArray *datalist))success
                               andFailure:(void (^)(NSError *error))failure {
    NSString *keyString = [NSString stringWithFormat:@"%@%@",FM_UserCollection,deviceDid];

    XM_WS(weakself);
    MHGatewayGetZipPDataRequest *req = [[MHGatewayGetZipPDataRequest alloc] init];
    req.keyString = keyString;
    [[MHNetworkEngine sharedInstance] sendRequest:req success:^(id json) {
        MHGatewayGetZipPDataResponse *rsp = [MHGatewayGetZipPDataResponse responseWithJSONObject:json andKeystring:keyString];
        
        //rsp.time 为 nil 时，证明用户还没有编辑过列表，则增加两个默认的电台收藏（收藏排名中的前两个）
        if (rsp.timeStamp == nil){
            [weakself fetchRankListAndAddTwoToCollectionList:deviceDid withSuccess:^(NSArray *radiolist) {
                if(success)success([radiolist mutableCopy]);
                if(radiolist) [weakself saveCollectedRadioDeviceDid:deviceDid withDataList:radiolist];
            }];
        }
        else {
            //用户编辑过则正常返回
            NSMutableArray *radioList = [NSMutableArray array];
            for (NSDictionary *dic in rsp.valueList){
                MHLumiXMRadio *radio = [MHLumiXMRadio jsonToObject:dic];
                [radioList addObject:radio];
            }
            if(success) success(radioList);
            if(radioList) [weakself saveCollectedRadioDeviceDid:deviceDid withDataList:radioList];
        }
        
    } failure:^(NSError *error) {
        if(failure)failure(error);
    }];
}

- (void)saveCollectedRadioDeviceDid:(NSString *)did withDataList:(NSArray *)datalist {
    NSString *dataType = [NSString stringWithFormat:@"%@%@",DataType_Collection,did];
    [self saveRadioDataList:dataType andDataList:datalist];
}

- (void)restoreCollectionRadioDeviceDid:(NSString *)did withFinish:(void (^)(NSMutableArray *datalist))finish {
    NSString *dataType = [NSString stringWithFormat:@"%@%@",DataType_Collection,did];
    [self restoreRadioDataListWithDataType:dataType andFinish:^(id obj){
        if(finish)finish(obj);
    }];
}

//actionType @"add" @"remove"
- (void)setCollectionRadio:(MHLumiXMRadio *)radio
             withDeviceDid:(NSString *)deviceDid
             andActionType:(NSString *)actionType
               WithSuccess:(void (^)(id obj))success
                andFailure:(void (^)(NSError *error))failure {
    //先下载现有收藏列表，添加信息后再设置列表
    NSString *keyString = [NSString stringWithFormat:@"%@%@",FM_UserCollection,deviceDid];
    
    __block void (^getCurrentListSuccess)(NSArray *valueArray);
    MHGatewayGetZipPDataRequest *req = [[MHGatewayGetZipPDataRequest alloc] init];
    req.keyString = keyString;

    [[MHNetworkEngine sharedInstance] sendRequest:req success:^(id json) {
        MHGatewayGetZipPDataResponse *rsp = [MHGatewayGetZipPDataResponse responseWithJSONObject:json andKeystring:keyString];

        if([actionType isEqualToString:@"add"] && rsp.valueList.count >= 20){
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.device.limited", @"plugin_gateway", nil) forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:@"20 limited" code:XUptoLimitedValue userInfo:userInfo];
            failure(error);
        }
        else{
            getCurrentListSuccess(rsp.valueList);
        }
        
    } failure:^(NSError *error) {
        if(failure)failure(error);
    }];
    
    XM_WS(weakself);
    getCurrentListSuccess = ^(NSArray *valueArray){
        NSMutableArray *newArray = [NSMutableArray arrayWithArray:valueArray];
        
        if([actionType isEqualToString:@"add"]){
            for(id rd in valueArray){
                MHLumiXMRadio *rdObj = [MHLumiXMRadio jsonToObject:rd];
                if([radio isEqual:rdObj]){
                    [newArray removeObject:rd];
                }
            }
            [newArray addObject:[radio toJson]];
        }
        else if([actionType isEqualToString:@"remove"]){
            for(id rd in valueArray){
                MHLumiXMRadio *rdObj = [MHLumiXMRadio jsonToObject:rd];
                if([radio isEqual:rdObj]){
                    [newArray removeObject:rd];
                }
            }
        }
        
        MHGatewaySetZipPDataRequest *req = [[MHGatewaySetZipPDataRequest alloc] init];
        req.keyString = keyString;
        req.value = newArray;
        [[MHNetworkEngine sharedInstance] sendRequest:req success:^(id json) {
            MHGatewaySetZipPDataResponse *rsp = [MHGatewaySetZipPDataResponse responseWithJSONObject:json];
            
            if ([rsp.result isEqualToString:@"success"]) {
                NSMutableArray *radioList = [NSMutableArray array];
                for (NSDictionary *dic in newArray){
                    MHLumiXMRadio *radio = [MHLumiXMRadio jsonToObject:dic];
                    [radioList addObject:radio];
                }
                [weakself saveCollectedRadioDeviceDid:deviceDid withDataList:radioList];
                if(success)success(radioList);
            }
            else {
                if(failure)failure(nil);
            }
            
        } failure:^(NSError *error) {
            if(failure)failure(error);
        }];
    };
}

#pragma mark - 将下载的新的电台列表和收藏列表进行匹配
- (void)mapTheCollectionRadio:(NSMutableArray *)newRadioArray
                 withDeviceId:(NSString *)deviceId
                   andSuccess:(void (^)(NSMutableArray *datalist))success{
    
    [self restoreCollectionRadioDeviceDid:deviceId withFinish:^(NSMutableArray *datalist) {
        //datalist 当前获取的收藏列表
        
        [newRadioArray enumerateObjectsUsingBlock:^(MHLumiXMRadio *newRadio, NSUInteger idx, BOOL *stop) {

            [datalist enumerateObjectsUsingBlock:^(MHLumiXMRadio *collectRadio, NSUInteger idx, BOOL *stop) {
                if ([newRadio isEqual:collectRadio]) {
                    newRadio.radioCollection = @"yes";
                    * stop = YES;
                }
            }];
            
            if (idx == newRadioArray.count - 1){
                if (success) success(newRadioArray);
            }
        }];
    }];
}

- (void)locateRadioInCollectionList:(MHLumiXMRadio *)radio
                           DeviceId:(NSString *)deviceId
                        withSuccess:(void (^)(MHLumiXMRadio *radio))success
                         andFailure:(void (^)(NSError *error))failure{
    
    [self restoreCollectionRadioDeviceDid:deviceId withFinish:^(NSMutableArray *datalist) {
        BOOL hasInCollection = NO;
        
        for (MHLumiXMRadio *collectRadio in datalist){
            if ([collectRadio.radioId integerValue] == radio.radioId.integerValue) {
                if (success)success(collectRadio);
                hasInCollection = YES;
            }
        }
        if (hasInCollection == NO){
            if (failure) failure(nil);
        }
    }];
}

#pragma mark - 直播排行更新
- (void)fetchRankWithFinish:(void (^)(NSMutableArray *datalist))finish
                andDeviceId:(NSString *)deviceId {
    XM_WS(weakself);
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@20 forKey:@"radio_count"];
    [[XMReqMgr sharedInstance] requestXMData:XMReqType_RankRadio
                                      params:params
                        withCompletionHander:^(id result, XMErrorModel *error) {
                            if(error.error_code){
                                if (finish) finish(nil);
                            }
                            else {
                                NSArray *rankRadioList = [MHLumiXMRadio dataListWithJSONObjectList:result];
                                
                                //对收藏的电台匹配，修改当前数据
                                [weakself mapTheCollectionRadio:[rankRadioList mutableCopy]
                                                   withDeviceId:deviceId
                                                     andSuccess:^(NSMutableArray *datalist) {
                                                         //只对第一页进行缓存(rank的只有一页)
                                                         [weakself saveRadioDataList:DataType_RankRadio andDataList:datalist];
                                                         if(finish)finish([datalist mutableCopy]);
                                                     }];
                            }
                        }];
}

- (void)restoreRankRadioWithFinish:(void (^)(NSMutableArray *datalist))finish {
    [self restoreRadioDataListWithDataType:DataType_RankRadio andFinish:^(id obj){
        if(finish)finish(obj);
    }];
}

#pragma mark - 电台更新
//获取本地/国家/网络电台
- (void)fetchRadio:(NSMutableDictionary *)params
        withFinish:(void (^)(NSMutableArray *datalist))finish
       andDeviceId:(NSString *)deviceId {
    
    XM_WS(weakself);
    __block NSMutableDictionary *paramslist = params;
    [[XMReqMgr sharedInstance] requestXMData:XMReqType_LiveRadio
                                      params:params
                        withCompletionHander:^(id result, XMErrorModel *error) {
                            if(error.error_code){
                                if (finish) finish(nil);
                                
                            }
                            else {
                                MHLumiXMPageInfo *pageInfo = [MHLumiXMPageInfo dataWithJSONObject:result];
                                NSArray *localRadioList = [MHLumiXMRadio dataListWithJSONObjectList:[result valueForKey:@"radios"]];
                                
                                //对收藏的电台匹配，修改当前数据
                                [weakself mapTheCollectionRadio:[localRadioList mutableCopy]
                                                   withDeviceId:deviceId
                                                     andSuccess:^(NSMutableArray *datalist) {
                                                         
                                                         NSMutableArray *datalistWithPage = [NSMutableArray arrayWithArray:datalist];
                                                         [datalistWithPage addObject:pageInfo];
                                                         
                                                         //只对第一页进行缓存
                                                         if([[paramslist valueForKey:@"page"] intValue] == 1){
                                                             if([[paramslist valueForKey:@"radio_type"] intValue] == 1)
                                                                 [self saveRadioDataList:DataType_CountryRadio andDataList:datalistWithPage];
                                                             else if([[paramslist valueForKey:@"radio_type"] intValue] == 2)
                                                                 [self saveRadioDataList:DataType_LocalRadio andDataList:datalistWithPage];
                                                             else if([[paramslist valueForKey:@"radio_type"] intValue] == 3)
                                                                 [self saveRadioDataList:DataType_NetworkRadio andDataList:datalistWithPage];
                                                         }
                                                         
                                                         if(finish)finish(datalistWithPage);
                                                     }];
                            }
                            
                        }];
}

//从缓存获取本地/国家/网络电台
- (void)restoreRadioType:(NSString *)radioType
              withFinish:(void (^)(NSMutableArray *datalist))finish {
    [self restoreRadioDataListWithDataType:radioType andFinish:^(id obj){
        if(finish)finish(obj);
    }];
}

//获取国家电台
- (void)fetchCountryRadio:(NSMutableDictionary *)params
              withFinish:(void (^)(NSMutableArray *datalist))finish {
    [[XMReqMgr sharedInstance] requestXMData:XMReqType_LiveRadio
                                      params:params
                        withCompletionHander:^(id result, XMErrorModel *error) {
                            if(error.error_code){
                                
                            }
                            else {
                                MHLumiXMPageInfo *pageInfo = [MHLumiXMPageInfo dataWithJSONObject:result];
                                NSArray *localRadioList = [MHLumiXMRadio dataListWithJSONObjectList:[result valueForKey:@"radios"]];
                                NSMutableArray *datalistWithPage = [NSMutableArray arrayWithArray:localRadioList];
                                [datalistWithPage addObject:pageInfo];
                                
                                //只对第一页进行缓存
                                if([[params valueForKey:@"page"] intValue] == 1)
                                    [self saveRadioDataList:DataType_CountryRadio andDataList:datalistWithPage];
                                
                                if(finish)finish(datalistWithPage);
                            }
                            
                        }];
}

- (void)fetchRadioByIds:(NSArray *)idsArray withSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    
    __block NSString *paramIds = @"";
    
    [idsArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        if ( idx == 0 ) paramIds = obj;
        else paramIds = [NSString stringWithFormat:@"%@,%@",paramIds, obj];
    }];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:paramIds forKey:@"ids"];
    [[XMReqMgr sharedInstance] requestXMData:XMReqType_LiveRadioByID params:params withCompletionHander:^(id result, XMErrorModel *error) {
        
        if(!error){
            NSArray *radioList = [MHLumiXMRadio dataListWithJSONObjectList:[result valueForKey:@"radios"]];
            if(success)success(radioList);
        }
        else{
            NSLog(@"%@   %@",error.description,result);
            if (failure)failure(nil);
        }
    }];
}

#pragma mark - 省市列表下载更新
- (void)fetchProvinceDataManager {
    XM_WS(weakself);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:@40 forKey:@"count"];
        [params setObject:@1 forKey:@"page"];
        [[XMReqMgr sharedInstance] requestXMData:XMReqType_LiveProvince
                                          params:params
                            withCompletionHander:^(id result, XMErrorModel *error) {
                                if(error.error_code){
                                    
                                }
                                else {
                                    if(result){
                                        NSArray *provinceList = [MHLumiXMProvince dataListWithJSONObjectList:result];
                                        [self saveRadioDataList:DataType_Province andDataList:provinceList];
                                        [weakself fetchCurrentPlaceMark:^(MKPlacemark *placemark){
                                            [weakself saveProvinceDataWithPlace:placemark andProvinceList:provinceList];
                                        }];
                                    }
                                }
                            }];
        
    });
}

- (void)fetchCurrentPlaceMark:(void (^)(MKPlacemark *placeMark))located {
    __block MKPlacemark *currentPlaceMark = [[MHLocationManager sharedInstance] currentPlaceMark];
    if(currentPlaceMark){
        if(located)located(currentPlaceMark);
    }
//    else{
//        [[MHLocationManager sharedInstance] requestCurrentLocationAndPlaceMarkWithSuccess:^(MKPlacemark *placeMark){
//            if(located)located(placeMark);
//        } fail:^(NSInteger errorCode){
//            NSLog(@"%ld",(long)errorCode);
//        }];
//    }
}

- (MHLumiXMProvince *)fetchCurrentProvince:(MKPlacemark *)currentPlaceMark
                          andProvinceList:(NSArray *)provinceList {
    for (MHLumiXMProvince *province in provinceList){
        NSRange range = [currentPlaceMark.administrativeArea rangeOfString:province.name];
        if (range.length){
            return province;
        }
    }
    return nil;
}

- (void)saveProvinceDataWithPlace:(MKPlacemark *)currentPlaceMark
                  andProvinceList:(NSArray *)provinceList {
    NSMutableArray *cpyList = [NSMutableArray arrayWithArray:provinceList];
    for (MHLumiXMProvince *province in provinceList){
        NSRange range = [currentPlaceMark.administrativeArea rangeOfString:province.name];
        if (range.length){
            [cpyList removeObject:province];
            province.isCurrentLocal = YES;
            [cpyList addObject:province];
        }
    }
    [self saveRadioDataList:DataType_Province andDataList:provinceList];
}

#pragma mark - 缓存
- (void)saveRadioDataList:(NSString *)dataType andDataList:(NSArray *)dataList {
    _userID = [MHPassportManager sharedSingleton].currentAccount.userId;
    [[MHPlistCacheEngine sharedEngine] asyncSave:dataList
                                          toFile:[NSString stringWithFormat:@"lumi_gateway_xm_%@_%@", _userID,dataType]
                                      withFinish:nil];
}

- (void)restoreRadioDataListWithDataType:(NSString *)dataType andFinish:(void(^)(id))finish {
    _userID = [MHPassportManager sharedSingleton].currentAccount.userId;
    [[MHPlistCacheEngine sharedEngine] asyncLoadFromFile:[NSString stringWithFormat:@"lumi_gateway_xm_%@_%@", _userID,dataType]
                                              withFinish:^(id obj) {
                                                  if (finish) finish(obj);
                                              }];
}

- (void)restoreProvinceDataIfNotLaunchRequestWithdCompleteHandle:(void (^)(id, bool))completeHandle{
    [self restoreRadioDataListWithDataType:DataType_Province andFinish:^(id result) {
        NSArray<MHLumiXMProvince *> *provinceArray = result;
        if (provinceArray.count > 0){
            completeHandle(result, NO);
        }else{
                NSMutableDictionary *params = [NSMutableDictionary dictionary];
                [params setObject:@40 forKey:@"count"];
                [params setObject:@1 forKey:@"page"];
                [[XMReqMgr sharedInstance] requestXMData:XMReqType_LiveProvince
                                                  params:params
                                    withCompletionHander:^(id result, XMErrorModel *error) {
                                        if(error.error_code){
                                            completeHandle(nil, YES);
                                        }
                                        else {
                                            if(result){
                                                NSArray *provinceList = [MHLumiXMProvince dataListWithJSONObjectList:result];
                                                [self saveRadioDataList:DataType_Province andDataList:provinceList];
                                                completeHandle(provinceList, YES);
                                            }
                                        }
                                    }];
        }
    }];
}

@end
