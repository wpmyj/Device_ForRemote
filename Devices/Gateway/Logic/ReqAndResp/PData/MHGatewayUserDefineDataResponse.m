//
//  MHGatewayUserDefineDataResponse.m
//  MiHome
//
//  Created by Lynn on 10/28/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayUserDefineDataResponse.h"

@implementation MHGatewayUserDefineDataResponse

+ (instancetype)responseWithJSONObject:(id)object andKeystring:(NSString *)keystring
{
    MHGatewayUserDefineDataResponse *response = [[self alloc] init];
    
    response.code = [[object objectForKey:@"code"] integerValue];
    response.message = [object objectForKey:@"message"];
    
    MHSafeDictionary *result = [object objectForKey:@"result"];
    if ([result isKindOfClass:[NSDictionary class]]){
        response.valueList = [[result valueForKey:keystring] valueForKey:@"value"];
    }
    
    return response;
    
}

@end
