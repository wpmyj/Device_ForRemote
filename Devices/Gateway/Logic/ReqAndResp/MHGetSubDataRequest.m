//
//  MHGetSubDataRequest.m
//  MiHome
//
//  Created by Woody on 15/4/10.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import "MHGetSubDataRequest.h"

@implementation MHGetSubDataRequest
- (NSString *)api
{
    return @"/device/getsubdata";
}

- (id)jsonObject
{
    NSMutableDictionary* json = [NSMutableDictionary dictionary];
    if (self.did) {
        [json setObject:self.did forKey:@"did"];
    }
    if (self.keys) {
        [json setObject:self.keys forKey:@"key"];
    }
    if (self.timestamp > 0) {
        [json setObject:@(self.timestamp) forKey:@"timestamp"];
    }
    [json setObject:@(self.limit) forKey:@"limit"];

    return json;
}
@end
