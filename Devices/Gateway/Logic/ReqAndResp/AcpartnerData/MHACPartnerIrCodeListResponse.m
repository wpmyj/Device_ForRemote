//
//  MHACPartnerIrCodeListResponse.m
//  MiHome
//
//  Created by ayanami on 16/5/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerIrCodeListResponse.h"
#import "Base64.h"
#import "GatewayZipTools.h"

@implementation MHACPartnerIrCodeListResponse

+ (instancetype)responseWithJSONObject:(id)object
{
    MHACPartnerIrCodeListResponse *response = [[self alloc] init];
    
    response.code = [[object objectForKey:@"code"] integerValue];
    response.message = [object objectForKey:@"msg"];
    if([[object objectForKey:@"result"] isKindOfClass:[NSString class]] && response.code == 200){
        NSString *codeString = [object valueForKey:@"result"];
        NSData *codeData = [codeString dataUsingEncoding:NSUTF8StringEncoding];
        NSData *decodeData = [Base64 decodeData:codeData];
        NSData *upZipData = [GatewayZipTools uncompressZippedData:decodeData];
        /*
         [{"id":1,"frequency":"123","type":2,"keys":[{"tag":1,"value":123},{"tag":2,"value":123},...],"exts":[{"id":1,"pulse":"1231242jsdf"}]},{},...]
         */
        if(upZipData){
            NSArray *recommends = [NSJSONSerialization JSONObjectWithData:upZipData
                                                                           options:NSJSONReadingMutableLeaves
                                                                             error:nil];
                response.codeList = recommends;
        }
        else {
            response.codeList = [NSMutableArray new];
        }
    }
    return response;
    
}
@end
