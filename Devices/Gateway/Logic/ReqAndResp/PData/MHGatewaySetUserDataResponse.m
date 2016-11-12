//
//  MHGatewaySetUserDataResponse.m
//  MiHome
//
//  Created by Lynn on 10/29/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHGatewaySetUserDataResponse.h"

@implementation MHGatewaySetUserDataResponse

+ (instancetype)responseWithJSONObject:(id)object
{
    MHGatewaySetUserDataResponse *response = [[self alloc] init];
    
    response.code = [[object objectForKey:@"code"] integerValue];
    response.message = [object objectForKey:@"message"];
    
    MHSafeDictionary *result = [object objectForKey:@"result"];
    if ([result isKindOfClass:[NSDictionary class]])
    {
        response.result = [NSJSONSerialization JSONObjectWithData:[[result valueForKey:@"result"] firstObject]
                                                             options:NSUTF8StringEncoding
                                                               error:nil];
    }
    
    return response;
    
}

@end
