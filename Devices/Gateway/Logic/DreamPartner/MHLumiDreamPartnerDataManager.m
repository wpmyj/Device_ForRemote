//
//  MHLumiDreamPartnerDataManager.m
//  MiHome
//
//  Created by guhao on 3/18/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLumiDreamPartnerDataManager.h"
#import "MHGatewayDreamPartnerThirdDataRequest.h"
#import "MHGatewayDreamPartnerThirdDataResponse.h"
#import "MHGatewayBuyingLinksThirdDataRequest.h"
#import "MHGatewayBuyingLinksThirdDataResponse.h"

@implementation MHLumiDreamPartnerDataManager
+ (id)sharedInstance {
    static MHLumiDreamPartnerDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[MHLumiDreamPartnerDataManager alloc] init];
        }
    });
    return manager;
}

- (void)fetchDreamPartnerDataSuccess:(SucceedBlock)success
                           andFailure:(FailedBlock)failure {
    MHGatewayDreamPartnerThirdDataRequest *request = [[MHGatewayDreamPartnerThirdDataRequest alloc] init];
    [[MHNetworkEngine sharedInstance] sendRequest:request success:^(id obj) {
        MHGatewayDreamPartnerThirdDataResponse *response = [MHGatewayDreamPartnerThirdDataResponse responseWithJSONObject:obj];
        if (success) {
            success(response.valueList);
        }
        
    } failure:^(NSError *error) {
        if (error) {
            failure(error);
        }
    }];
}

- (void)fetchBuyingLinksDataSuccess:(SucceedBlock)success andFailure:(FailedBlock)failure {
    MHGatewayBuyingLinksThirdDataRequest *request = [[MHGatewayBuyingLinksThirdDataRequest alloc] init];
    [[MHNetworkEngine sharedInstance] sendRequest:request success:^(id obj) {
        MHGatewayBuyingLinksThirdDataResponse *response = [MHGatewayBuyingLinksThirdDataResponse responseWithJSONObject:obj];
        if (success) {
            success(response.valueList);
        }
        
    } failure:^(NSError *error) {
        if (error) {
            failure(error);
        }
    }];

}

@end
