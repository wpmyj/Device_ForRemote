//
//  MHGatewayDownloadUrlResponse.m
//  MiHome
//
//  Created by Lynn on 10/28/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayDownloadUrlResponse.h"

@implementation MHGatewayDownloadUrlResponse

+ (instancetype)responseWithJSONObject:(id)object
{
    MHGatewayDownloadUrlResponse *response = [[self alloc] init];
    
    response.code = [[object objectForKey:@"code"] integerValue];
    response.message = [object objectForKey:@"message"];
    
    MHSafeDictionary *result = [object objectForKey:@"result"];
    if ([result isKindOfClass:[NSDictionary class]])
    {
        response.url = [result valueForKey:@"url"];
    }
    
    return response;
    
}

@end
