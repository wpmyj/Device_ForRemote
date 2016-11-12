//
//  MHGatewayHtDataRequest.m
//  MiHome
//
//  Created by ayanami on 16/8/10.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayHtDataRequest.h"

@implementation MHGatewayHtDataRequest
- (NSString *)api
{
    return @"/user/get_user_device_data";
}

- (id)jsonObject
{
    NSMutableDictionary* json = [NSMutableDictionary dictionary];
    if (self.did) [json setObject:self.did forKey:@"did"];
    [json setObject:@(self.timeStart) forKey:@"time_start"];
    [json setObject:@(self.timeEnd) forKey:@"time_end"];
    [json setObject:@(10) forKey:@"limit"];
    [json setObject:@"prop" forKey:@"type"];
    [json setObject:self.key forKey:@"key"];
    if (self.group) [json setValue:self.group forKey:@"group"];
    return json;
}

@end
