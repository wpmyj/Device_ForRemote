//
//  MHGatewaySceneRecomRequest.m
//  MiHome
//
//  Created by Lynn on 9/30/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHGatewaySceneRecomRequest.h"

@implementation MHGatewaySceneRecomRequest

- (NSString *)api
{
    return @"/scene/recom";
}

- (id)jsonObject
{
    NSDictionary *json = @{@"did":self.deviceDid};
    
    return json;
}


@end
