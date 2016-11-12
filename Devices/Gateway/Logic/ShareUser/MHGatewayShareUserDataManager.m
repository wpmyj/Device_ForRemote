//
//  MHGatewayShareUserDataManager.m
//  MiHome
//
//  Created by guhao on 4/18/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayShareUserDataManager.h"
#import "MHGatewayGetShareUserDataRequest.h"
#import "MHGatewayGetShareUserDataResponse.h"

@implementation MHGatewayShareUserDataManager

+ (id)sharedInstance {
    static MHGatewayShareUserDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[MHGatewayShareUserDataManager alloc] init];
        }
    });
    return manager;
}

- (void)getShareUserListWithGatewayDid:(NSString *)did success:(SucceedBlock)success failure:(FailedBlock)failure {
    MHGatewayGetShareUserDataRequest *request = [[MHGatewayGetShareUserDataRequest alloc] init];
    request.did = did;
    [[MHNetworkEngine sharedInstance] sendRequest:request success:^(id obj) {
        MHGatewayGetShareUserDataResponse *response = [MHGatewayGetShareUserDataResponse responseWithJSONObject:obj];
        if (success) {
            success(response.shareUsers);
        }
        
    } failure:^(NSError *error) {
        if (error) {
            failure(error);
        }
    }];

}

@end
