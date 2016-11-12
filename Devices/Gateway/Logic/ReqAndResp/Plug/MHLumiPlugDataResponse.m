//
//  MHLumiPlugDataResponse.m
//  MiHome
//
//  Created by Lynn on 11/12/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLumiPlugDataResponse.h"

@implementation MHLumiPlugDataResponse

+ (instancetype)responseWithJSONObject:(id)object
{
    MHLumiPlugDataResponse* response = [[self alloc] init];
    response.code = [[object objectForKey:@"code" class:[NSNumber class]] integerValue];
    response.message = [object objectForKey:@"message" class:[NSString class]];
    
    NSDictionary *result = [[object valueForKey:@"result"] firstObject];
    response.value = [result valueForKey:@"value"];
    
    return response;
}

@end
