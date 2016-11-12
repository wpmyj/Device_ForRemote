//
//  MHGatewaySceneEditRequest.m
//  MiHome
//
//  Created by Lynn on 9/9/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHGatewaySceneEditRequest.h"

@implementation MHGatewaySceneEditRequest

- (NSString *)api
{
    return @"/scene/edit";
}

- (id)jsonObject
{
    NSLog(@"绿米创建自动化%@", self.sceneJson);
    return self.sceneJson;
}

@end
