//
//  MHGatewayScenTplRequest.m
//  MiHome
//
//  Created by Lynn on 9/7/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHGatewaySceneTplRequest.h"

@implementation MHGatewaySceneTplRequest

- (NSString *)api
{
    return @"/scene/tpl";
}

- (id)jsonObject
{
    NSDictionary *json = [NSDictionary dictionary];
    
    return json;
}

@end
