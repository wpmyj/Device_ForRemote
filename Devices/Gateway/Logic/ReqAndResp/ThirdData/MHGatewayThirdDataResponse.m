//
//  MHGatewayMusicResponse.m
//  MiHome
//
//  Created by Lynn on 8/31/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayThirdDataResponse.h"
#import "Base64.h"
#import "GatewayZipTools.h"

@implementation MHGatewayThirdDataResponse

+ (instancetype)responseWithJSONObject:(id)object
{
    MHGatewayThirdDataResponse *response = [[self alloc] init];
    
    response.code = [[object objectForKey:@"code"] integerValue];
    response.message = [object objectForKey:@"message"];
    
    MHSafeDictionary *result = [object objectForKey:@"result"];
    if ([result isKindOfClass:[NSDictionary class]])
    {
        NSString *codeString = [result valueForKey:@"value"];
//        NSLog(@"压缩的字符串%@", codeString);
        NSData *codeData = [codeString dataUsingEncoding:NSUTF8StringEncoding];
        NSData *decodeData = [Base64 decodeData:codeData];
        NSData *upZipData = [GatewayZipTools uncompressZippedData:decodeData];
        
        response.valueList = [NSJSONSerialization JSONObjectWithData:upZipData
                                                             options:NSUTF8StringEncoding
                                                               error:nil];
//        NSLog(@"%@",response.valueList);
    }
    return response;

}
+ (instancetype)responseWithJSONObject:(id)object andKeystring:(NSString *)keystring {
    MHGatewayThirdDataResponse *response = [[self alloc] init];
    
    response.code = [[object objectForKey:@"code"] integerValue];
    response.message = [object objectForKey:@"message"];
    
    if([[object objectForKey:@"result"] isKindOfClass:[NSDictionary class]]){
        MHSafeDictionary *result = [object objectForKey:@"result"];
        if ([result isKindOfClass:[NSDictionary class]] && [result[@"key"] isEqualToString:keystring]){
                        
            NSString *codeString = [result valueForKey:@"value"];
            NSData *codeData = [codeString dataUsingEncoding:NSUTF8StringEncoding];
            NSData *decodeData = [Base64 decodeData:codeData];
            NSData *upZipData = [GatewayZipTools uncompressZippedData:decodeData];
            
            if(upZipData){
                response.valueList = [NSJSONSerialization JSONObjectWithData:upZipData
                                                                     options:NSJSONReadingMutableLeaves
                                                                       error:nil];
            }
            else{
                response.valueList = [NSMutableArray array];
            }
        }
        else {
            response.valueList = [NSMutableArray array];
        }
    }
    else {
        response.valueList = [NSMutableArray array];
    }
    return response;
}

@end
