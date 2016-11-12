//
//  MHGatewayHtDataResponse.m
//  MiHome
//
//  Created by ayanami on 16/8/10.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayHtDataResponse.h"

@implementation MHGatewayHtDataResponse
+ (instancetype)responseWithJSONObject:(id)object
{
    MHGatewayHtDataResponse* response = [[self alloc] init];
    response.code = [[object objectForKey:@"code" class:[NSNumber class]] integerValue];
    response.message = [object objectForKey:@"message" class:[NSString class]];
    
    
    NSLog(@"%@", object);
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        response.valueList = [NSMutableArray arrayWithArray:[object valueForKey:@"result"]];
    }
    else {
        response.valueList = [NSMutableArray new];
    }
    
    return response;
}
@end
