//
//  MHGatewaySceneLogDataResponse.m
//  MiHome
//
//  Created by guhao on 16/5/6.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewaySceneLogDataResponse.h"
#import "MHDataGatewaySceneLog.h"

@implementation MHGatewaySceneLogDataResponse
+ (instancetype)responseWithJSONObject:(id)object
{
    MHGatewaySceneLogDataResponse* response = [[self alloc] init];
    response.code = [[object objectForKey:@"code" class:[NSNumber class]] integerValue];
    response.message = [object objectForKey:@"message" class:[NSString class]];
    
    
    MHSafeDictionary *result = [object objectForKey:@"result" class:[NSDictionary class]];
    NSArray *data = [result objectForKey:@"history" class:[NSArray class]];
        response.sceneLogs = [MHDataGatewaySceneLog dataListWithJSONObjectList:data];
    
    return response;
}

@end
