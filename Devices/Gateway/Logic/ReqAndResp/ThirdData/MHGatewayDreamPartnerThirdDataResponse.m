//
//  MHGatewayDreamPartnerThirdDataResponse.m
//  MiHome
//
//  Created by guhao on 3/18/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayDreamPartnerThirdDataResponse.h"
#import "Base64.h"
#import "GatewayZipTools.h"

@implementation MHGatewayDreamPartnerThirdDataResponse
+ (instancetype)responseWithJSONObject:(id)object
{
    MHGatewayDreamPartnerThirdDataResponse *response = [[self alloc] init];
    
    response.code = [[object objectForKey:@"code"] integerValue];
    response.message = [object objectForKey:@"message"];
    
    MHSafeDictionary *result = [object objectForKey:@"result"];
    if ([result isKindOfClass:[NSDictionary class]])
    {
        NSString *codeString = [result valueForKey:@"value"];
        NSData *codeData = [[NSData alloc] initWithData:[codeString dataUsingEncoding:NSUTF8StringEncoding]];
        response.valueList = [NSJSONSerialization JSONObjectWithData:codeData
                                                             options:NSJSONReadingMutableLeaves
                                                               error:nil];
        NSLog(@"%@", codeString);
        NSLog(@"%@", response);
    }
    return response;
    
}

@end
