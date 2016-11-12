//
//  MHSetSubDataRequest.m
//  MiHome
//
//  Created by Woody on 15/4/10.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import "MHSetSubDataRequest.h"

@implementation MHSetSubDataRequest
- (NSString *)api
{
    return @"/device/setsubdata";
}

- (id)jsonObject
{
    NSMutableDictionary* json = [NSMutableDictionary dictionary];
    if (self.did) {
        [json setObject:self.did forKey:@"did"];
    }
    if (self.key) {
        [json setObject:self.key forKey:@"key"];
    }
    if (self.type) {
        [json setObject:self.type forKey:@"type"];
    }
    
    return json;
}
@end
