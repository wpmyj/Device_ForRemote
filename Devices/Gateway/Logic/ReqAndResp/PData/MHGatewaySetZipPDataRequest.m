//
//  MHGatewaySetUserDataRequest.m
//  MiHome
//
//  Created by Lynn on 10/29/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHGatewaySetZipPDataRequest.h"
#import "Base64.h"
#import "GatewayZipTools.h"

@implementation MHGatewaySetZipPDataRequest

- (NSString *)api
{
    return @"/user/setpdata";
}

- (id)jsonObject
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.value options:NSJSONWritingPrettyPrinted error:nil];

    NSData *zipedData = [GatewayZipTools gzipData:jsonData];
    NSData *encodeData = [Base64 encodeData:zipedData];
    NSString *zipedString = [[NSString alloc] initWithData:encodeData
                                                  encoding:NSUTF8StringEncoding];
    
    NSDictionary *json = @{ @"key"   : self.keyString,
                            @"time"  : @"0",
                            @"value" : zipedString
                            };
    return json;
}


@end
