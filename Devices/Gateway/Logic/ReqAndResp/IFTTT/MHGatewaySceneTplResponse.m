//
//  MHGatewaySceneTplResponse.m
//  MiHome
//
//  Created by Lynn on 9/7/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHGatewaySceneTplResponse.h"
#import "MHDeviceListCache.h"

@implementation MHGatewaySceneTplResponse

+ (instancetype)responseWithJSONObject:(id)object
{
    MHGatewaySceneTplResponse *response = [[self alloc] init];
    response.ifList = [NSMutableArray arrayWithCapacity:1];
    response.thenList = [NSMutableArray arrayWithCapacity:1];
    
    response.code = [[object objectForKey:@"code"] integerValue];
    response.message = [object objectForKey:@"message"];
    
    NSMutableArray *allModals = [NSMutableArray arrayWithCapacity:1];     //全部model
    NSMutableDictionary *ifListTmp = [NSMutableDictionary dictionaryWithCapacity:1];     //model对应的launch
    NSMutableDictionary *thenListTmp = [NSMutableDictionary dictionaryWithCapacity:1];   //model对应的

    NSArray *result = [object objectForKey:@"result"];
    if ([result isKindOfClass:[NSArray class]]){
        //parse all the models
        for (id obj in result){
            NSString *model = [obj valueForKey:@"model"];
            [allModals addObject:model];
        }
        //去重
        NSSet *set = [NSSet setWithArray:allModals];
        allModals = [[set allObjects] mutableCopy];
        
        //if 去重
        for(NSString *model in allModals){
            //model in result
            for (id obj in result){
                NSString *modelOrg = [obj valueForKey:@"model"];
                
                if([modelOrg isEqualToString:model] &&
                   [[[obj valueForKey:@"value" ] valueForKey:@"launch"] count] ){
                    NSMutableArray *launchList = [[[obj valueForKey:@"value" ] valueForKey:@"launch"] mutableCopy];
                    for (id launch in [[obj valueForKey:@"value" ] valueForKey:@"launch"]) {
                        if([launch valueForKey:@"plug_id"]){
                            [launchList removeObject:launch];
                        }
                    }
                    [ifListTmp setObject:launchList forKey:model];
                    break;
                }
            }
        }
        
        //then 去重
        for(NSString *model in allModals){
            //model in result
            for (id obj in result){
                NSString *modelOrg = [obj valueForKey:@"model"];

                if([modelOrg isEqualToString:model] &&
                   [[[obj valueForKey:@"value" ] valueForKey:@"action_list"] count] ){
                    
                    NSMutableArray *actionList = [[[obj valueForKey:@"value" ] valueForKey:@"action_list"] mutableCopy];
                    for (id action in [[obj valueForKey:@"value" ] valueForKey:@"action_list"]) {
                        if([[action valueForKey:@"payload"] valueForKey:@"plug_id"]){
                            [actionList removeObject:action];
                        }
                    }
                    [thenListTmp setObject:actionList forKey:model];
                    break;
                }
            }
        }
    }
    
    //获取设备列表，用来匹配 aciton_list 和 launch
    MHDeviceListCache *deviceListCache = [[MHDeviceListCache alloc] init];
    __block void (^ fetchDeviceCompletionBlock)(NSArray *deviceList);
    [deviceListCache asyncLoadAllWithCompletionBlock:^(NSArray *deviceList) {
        fetchDeviceCompletionBlock(deviceList);
    }];
    
    fetchDeviceCompletionBlock = ^(NSArray *deviceList){
        //对devicelist排序，没有parent_id的排在前面
        NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"_parent_id" ascending:YES];
        NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"_deviceType" ascending:YES];
        NSArray *tempArray = [deviceList sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,nil]];
        for (MHDevice *device in tempArray){
            if(device.shareFlag != MHDeviceShared && device.isOnline && ![device.model isEqualToString:@"chuangmi.ir.v2"]){
                //先屏蔽万能遥控器设备。。。
                NSString *model = device.model;
                
                if([[ifListTmp objectForKey:model] count]){
                    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:[ifListTmp objectForKey:model], @"launch",
                                       device.did,@"device_did",
                                       device.name,@"device_name",
                                       NSStringFromClass(device.class),@"device_class",nil];
                    [response.ifList addObject:d];
                }
                
                if([[thenListTmp objectForKey:model] count]){
                    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:[thenListTmp objectForKey:model], @"action_list",
                                       device.did,@"device_did",
                                       device.name,@"device_name",
                                       NSStringFromClass(device.class),@"device_class",nil];
                    [response.thenList addObject:d];
                }
                
                response.ifThenDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:response.thenList,@"action_list",response.ifList,@"launch", nil];
                
                if(response.completionBlock)response.completionBlock(response.ifThenDictionary);
            }
        }
    };

    return response;
}

@end
