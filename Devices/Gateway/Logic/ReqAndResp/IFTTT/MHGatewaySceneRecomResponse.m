//
//  MHGatewaySceneRecomResponse.m
//  MiHome
//
//  Created by Lynn on 9/30/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHGatewaySceneRecomResponse.h"
#import "MHDataScene.h"

@implementation MHGatewaySceneRecomResponse

+ (instancetype)responseWithJSONObject:(id)object{

    MHGatewaySceneRecomResponse *response = [[self alloc] init];
    response.sceneRecomList = [NSMutableArray arrayWithCapacity:1];
    
    response.code = [[object objectForKey:@"code"] integerValue];
    response.message = [object objectForKey:@"message"];
    
    MHSafeDictionary *result = [object objectForKey:@"result"];
    response.sceneRecomList = [result valueForKey:@"value"];
    
    return response;
}

@end
