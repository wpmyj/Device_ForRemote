//
//  MHGatewaySceneLogDataRequest.m
//  MiHome
//
//  Created by guhao on 16/5/6.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewaySceneLogDataRequest.h"

@implementation MHGatewaySceneLogDataRequest

- (NSString *)api
{
    return @"/scene/history";
}

- (id)jsonObject
{
    NSMutableDictionary* json = [NSMutableDictionary dictionary];
    if (self.dids) {
        json[@"did"] = self.dids;
    }
    [json setObject:@"history" forKey:@"command"];
    if (self.timestamp == 0) {
        self.timestamp = [[NSDate date] timeIntervalSince1970];
    }
    json[@"timestamp"] = @(self.timestamp);
    if (self.limit == 0) {
        self.limit = 30;
    }
    json[@"limit"] = @(self.limit);
    json[@"combine"] = @(1);

    return json;
}

@end
