//
//  MHGatewaySceneListManager.m
//  MiHome
//
//  Created by Lynn on 9/4/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHGatewaySceneManager.h"
#import "MHGatewaySceneListRequest.h"
#import "MHGatewaySceneListResponse.h"
#import "MHGatewaySceneTplRequest.h"
#import "MHGatewaySceneTplResponse.h"
#import "MHGatewaySceneEditRequest.h"
#import "MHGatewaySceneDeleteRequest.h"
#import "MHGatewaySceneDeleteResponse.h"
#import "MHDataScene.h"
#import "MHGatewaySceneRecomRequest.h"
#import "MHGatewaySceneRecomResponse.h"

@implementation MHGatewaySceneManager

+ (id)sharedInstance {
    static MHGatewaySceneManager *obj = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        obj = [[MHGatewaySceneManager alloc] init];
    });
    return obj;
}

- (void)fetchSceneListWithDevice:(MHDeviceGatewayBase *)device
                            stid:(NSString *)stid
                      andSuccess:(SucceedBlock)success
                         failure:(FailedBlock)failure {

    MHGatewaySceneListRequest *req = [[MHGatewaySceneListRequest alloc] init];
    req.sensor = device;
    req.st_id = stid;
    [[MHNetworkEngine sharedInstance] sendRequest:req success:^(id json) {
        MHGatewaySceneListResponse *rsp = [MHGatewaySceneListResponse responseWithJSONObject:json];
        if(success)success([rsp.sceneList mutableCopy]);
        
    } failure:^(NSError *error) {
        if(failure)failure(error);
    }];
}

- (void)fetchSceneListWithDevice:(MHDeviceGatewayBase *)device
                         success:(SucceedBlock)success
                      andfailure:(FailedBlock)failure {
    
    MHGatewaySceneListRequest *req = [[MHGatewaySceneListRequest alloc] init];
    req.sensor = device;
    [[MHNetworkEngine sharedInstance] sendRequest:req success:^(id json) {
        MHGatewaySceneListResponse *rsp = [MHGatewaySceneListResponse responseWithJSONObject:json];
        if(success)success([rsp.sceneList mutableCopy]);
        
    } failure:^(NSError *error) {
        if(failure)failure(error);
    }];
}

- (void)fetchSceneTplWithSuccess:(SucceedBlock)success andfailure:(FailedBlock)failure {

    MHGatewaySceneTplRequest *req = [[MHGatewaySceneTplRequest alloc] init];

    [[MHNetworkEngine sharedInstance] sendRequest:req success:^(id json) {
        MHGatewaySceneTplResponse *rsp = [MHGatewaySceneTplResponse responseWithJSONObject:json];
        rsp.completionBlock = ^(NSMutableDictionary *ifThenDictionary) {
            if(success)success(ifThenDictionary);
        };
    } failure:^(NSError *error) {
        if(failure)failure(error);
    }];
}

+ (NSMutableArray *)reBuildActionData:(NSMutableArray *)actionList {
    
    NSMutableArray *newActionList = [NSMutableArray arrayWithCapacity:1];
    for (id action in actionList){
        
        for(id obj in [action valueForKey:@"action_list"]){
            
            NSMutableDictionary *selectedActionObject = [NSMutableDictionary dictionaryWithCapacity:1];
            [selectedActionObject setObject:[action valueForKey:@"device_name"] forKey:@"name"];
            [selectedActionObject setObject:[obj valueForKey:@"model"] forKey:@"model"];
            [selectedActionObject setObject:[obj valueForKey:@"name"] forKey:@"keyName"];
            [selectedActionObject setObject:[obj valueForKey:@"type"] forKey:@"type"];
            
            NSString *command = [[obj valueForKey:@"payload"] valueForKey:@"command"];
            NSString *value = [[obj valueForKey:@"payload"] valueForKey:@"value"];
            NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithCapacity:1];
            [payload setObject:command forKey:@"command"];
            [payload setObject:[action valueForKey:@"device_did"] forKey:@"did"];
            [payload setObject:@"0" forKey:@"total_length"];
            [payload setObject:value forKey:@"value"];
            
            [selectedActionObject setObject:payload forKey:@"payload"];
            
            MHDataAction *newActionObj = [MHDataAction dataWithJSONObject:selectedActionObject];
            newActionObj.deviceModel = [obj valueForKey:@"model"];
            
            [newActionList addObject:newActionObj];
        }
    }
    
    return newActionList;
}

+ (NSMutableArray *)reBuildLaunchData:(NSMutableArray *)launchList {
    
    NSMutableArray *newLaunchList = [NSMutableArray arrayWithCapacity:1];
    for (id launch in launchList){
        for(id obj in [launch valueForKey:@"launch"]){
            NSMutableDictionary *selectedLaunchObject = [NSMutableDictionary dictionaryWithCapacity:1];
            [selectedLaunchObject setObject:[launch valueForKey:@"device_name"] forKey:@"device_name"];
            [selectedLaunchObject setObject:[launch valueForKey:@"device_did"] forKey:@"did"];
            [selectedLaunchObject setObject:[obj valueForKey:@"name"] forKey:@"name"];
            [selectedLaunchObject setObject:[obj valueForKey:@"key"] forKey:@"key"];
            [selectedLaunchObject setObject:[obj valueForKey:@"value"] forKey:@"value"];
            [selectedLaunchObject setObject:[obj valueForKey:@"src"] forKey:@"src"];
            
            MHDataLaunch *newLaunchObj = [MHDataLaunch  dataWithJSONObject:selectedLaunchObject];
            newLaunchObj.model = [obj valueForKey:@"model"];
            [newLaunchList addObject:newLaunchObj];
        }
    }
    return newLaunchList;
}

- (void)saveSceneEditWithParms:(NSMutableDictionary *)parmas
                    andSuccess:(SucceedBlock)success
                    andfailure:(FailedBlock)failure {
    MHGatewaySceneEditRequest *req = [[MHGatewaySceneEditRequest alloc] init];
    req.sceneJson = parmas;
    
    [[MHNetworkEngine sharedInstance] sendRequest:req success:^(id json) {
        if(success)success(json);
        
    } failure:^(NSError *error) {
        if(failure)failure(error);
    }];
}

- (void)deleteSceneWithUsid:(NSString *)usid
                 andSuccess:(SucceedBlock)success
                 andFailure:(FailedBlock)failure {
    
    MHGatewaySceneDeleteRequest *req = [[MHGatewaySceneDeleteRequest alloc] init];
    req.usid = usid;
    
    [[MHNetworkEngine sharedInstance] sendRequest:req success:^(id json){
        if(success)success(json);
    } failure:^(NSError *error){
        if(failure)failure(error);
    }];
}

- (void)fetchSceneRecomWithDevice:(MHDeviceGatewayBase *)device
                          success:(SucceedBlock)success
                       andfailure:(FailedBlock)failure {
    
    MHGatewaySceneRecomRequest *req = [[MHGatewaySceneRecomRequest alloc] init];
    req.deviceDid = device.did;
    
    [[MHNetworkEngine sharedInstance] sendRequest:req success:^(id json){
        MHGatewaySceneRecomResponse *rsp = [MHGatewaySceneRecomResponse responseWithJSONObject:json];
        if(success)success(rsp.sceneRecomList);
        
    } failure:^(NSError *error){
        if(failure)failure(error);
    }];
}

@end
