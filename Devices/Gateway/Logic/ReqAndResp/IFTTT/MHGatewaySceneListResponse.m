//
//  MHGatewaySceneListResponse.m
//  MiHome
//
//  Created by Lynn on 9/4/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHGatewaySceneListResponse.h"
#import "MHDataScene.h"

@implementation MHGatewaySceneListResponse

+ (instancetype)responseWithJSONObject:(id)object
{
    MHGatewaySceneListResponse *response = [[self alloc] init];
    response.sceneList = [NSMutableArray arrayWithCapacity:1];
    
    response.code = [[object objectForKey:@"code"] integerValue];
    response.message = [object objectForKey:@"message"];

    MHSafeDictionary *result = [object objectForKey:@"result"];
    if ([result isKindOfClass:[NSDictionary class]]){
        response.sceneList = [MHDataScene dataListWithJSONObjectList:result.allValues];
    }
    return response;
}

@end
