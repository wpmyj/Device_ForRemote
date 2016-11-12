//
//  MHGatewaySceneDeleteRequest.m
//  MiHome
//
//  Created by Lynn on 9/10/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHGatewaySceneDeleteRequest.h"

@implementation MHGatewaySceneDeleteRequest

- (NSString *)api
{
    return @"/scene/delete";
}

- (id)jsonObject
{
    if(!self.usid) return nil;
    return @{@"us_id":self.usid};
}

@end
