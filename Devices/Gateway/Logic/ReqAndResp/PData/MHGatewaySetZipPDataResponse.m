//
//  MHGatewaySetUserDataResponse.m
//  MiHome
//
//  Created by Lynn on 10/29/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHGatewaySetZipPDataResponse.h"

@implementation MHGatewaySetZipPDataResponse

+ (instancetype)responseWithJSONObject:(id)object
{
    MHGatewaySetZipPDataResponse *response = [[self alloc] init];
    
    response.code = [[object objectForKey:@"code"] integerValue];
    response.message = [object objectForKey:@"message"];
    
    response.result = [[object valueForKey:@"result"] firstObject];
    
    return response;
    
}

@end
