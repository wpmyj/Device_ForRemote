//
//  MHGatewayBuyingLinksThirdDataResponse.m
//  MiHome
//
//  Created by guhao on 16/4/28.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayBuyingLinksThirdDataResponse.h"
#import "Base64.h"
#import "GatewayZipTools.h"

@implementation MHGatewayBuyingLinksThirdDataResponse

+ (instancetype)responseWithJSONObject:(id)object
{
    MHGatewayBuyingLinksThirdDataResponse *response = [[self alloc] init];
    
    response.code = [[object objectForKey:@"code"] integerValue];
    response.message = [object objectForKey:@"message"];
    
    MHSafeDictionary *result = [object objectForKey:@"result"];
    if ([result isKindOfClass:[NSDictionary class]])
    {
        NSString *codeString = [result valueForKey:@"value"];
        NSData *codeData = [codeString dataUsingEncoding:NSUTF8StringEncoding];
        NSData *decodeData = [Base64 decodeData:codeData];
        NSData *upZipData = [GatewayZipTools uncompressZippedData:decodeData];
        
        response.valueList = [NSJSONSerialization JSONObjectWithData:upZipData
                                                             options:NSJSONReadingMutableLeaves
                                                               error:nil];
        NSLog(@"%@",response.valueList);
    }
    return response;
    
}
@end
