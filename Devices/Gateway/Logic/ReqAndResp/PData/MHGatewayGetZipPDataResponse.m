//
//  MHGatewayUserDefineDataResponse.m
//  MiHome
//
//  Created by Lynn on 10/28/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayGetZipPDataResponse.h"
#import "Base64.h"
#import "GatewayZipTools.h"

@implementation MHGatewayGetZipPDataResponse

+ (instancetype)responseWithJSONObject:(id)object andKeystring:(NSString *)keystring
{
    MHGatewayGetZipPDataResponse *response = [[self alloc] init];
    
    response.code = [[object objectForKey:@"code"] integerValue];
    response.message = [object objectForKey:@"message"];
    
    if([[object objectForKey:@"result"] isKindOfClass:[NSDictionary class]]){
        MHSafeDictionary *result = [[object objectForKey:@"result"] valueForKey:keystring];
        if ([result isKindOfClass:[NSDictionary class]]){
            
            response.timeStamp = [[result valueForKey:@"time"] stringValue];
            
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
