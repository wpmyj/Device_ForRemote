//
//  MHGatewayUploadUrlResponse.m
//  MiHome
//
//  Created by Lynn on 10/28/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayUploadUrlResponse.h"
#import "NSString+LU_URL.h"

@implementation MHGatewayUploadUrlResponse

+ (instancetype)responseWithJSONObject:(id)object andSuffix:(NSString *)suffix
{
    MHGatewayUploadUrlResponse *response = [[self alloc] init];
    
    response.code = [[object objectForKey:@"code"] integerValue];
    response.message = [object objectForKey:@"message"];
    
    MHSafeDictionary *result = [object objectForKey:@"result"];
    if ([result isKindOfClass:[NSDictionary class]])
    {
        response.url = [[[result valueForKey:suffix] valueForKey:@"url"] gw_DecodeURLFromPercentEscapeString];
//        response.url = [[result valueForKey:suffix] valueForKey:@"url"];
        response.uploadFileName = [[result valueForKey:suffix] valueForKey:@"obj_name"];
    }
    
    return response;
    
}


@end
