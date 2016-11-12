//
//  MHLumiPlugDataManager.m
//  MiHome
//
//  Created by Lynn on 11/12/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLumiPlugDataManager.h"
#import "MHLumiPlugDataRequest.h"
#import "MHLumiPlugDataResponse.h"
#import "MHGatewayGetZipPDataRequest.h"
#import "MHGatewayGetZipPDataResponse.h"
#import "MHGatewaySetZipPDataRequest.h"
#import "MHGatewaySetZipPDataResponse.h"

#define LMPlug_PData_Key @"lumi_plug_userdata"
#define LMPlug_QuantData_File @"lmplug_quantdata"
#define LMPlug_QuantData_Path @"lumi.plug"

@implementation MHLumiPlugDataManager

+ (id)sharedInstance {
    static MHLumiPlugDataManager *obj = nil;
    @synchronized([MHLumiPlugDataManager class]) {
        if(!obj)
            obj = [[MHLumiPlugDataManager alloc] init];
    }
    return obj;
}

#pragma mark - 电量信息
//获取插座电量统计，历史记录
- (void)fetchPlugQuantHistoryDataWithParams:(NSDictionary *)params
                                    Success:(SucceedBlock)success
                                 andFailure:(FailedBlock)failure {
    MHLumiPlugDataRequest *rsp = [[MHLumiPlugDataRequest alloc] init];
    rsp.groupType = [params valueForKey:@"groupType"];
    rsp.startDateString = [params valueForKey:@"startDateString"];
    rsp.endDateString = [params valueForKey:@"endDateString"];
    rsp.deviceDid = self.quantDevice.did;
    
    [[MHNetworkEngine sharedInstance] sendRequest:rsp success:^(id obj){
        MHLumiPlugDataResponse *req = [MHLumiPlugDataResponse responseWithJSONObject:obj];
        
        if(success) success(req.value);
        
    } failure:^(NSError *error){
        if(failure) failure(error);
    }];
}

//当前的插座电量信息
- (void)fetchLumiPlugDataWithParams:(NSDictionary *)parms
                            Success:(SucceedBlock)success
                         andfailure:(FailedBlock)failure {
    
    MHLumiPlugDataRequest *rsp = [[MHLumiPlugDataRequest alloc] init];
    rsp.groupType = [parms valueForKey:@"groupType"];
    rsp.dateString = [parms valueForKey:@"dateString"];
    rsp.deviceDid = self.quantDevice.did;
    
    [[MHNetworkEngine sharedInstance] sendRequest:rsp success:^(id obj){
        MHLumiPlugDataResponse *req = [MHLumiPlugDataResponse responseWithJSONObject:obj];

        if(success) success(req.value);
        
    } failure:^(NSError *error){
        if(failure) failure(error);
    }];
}

@end
