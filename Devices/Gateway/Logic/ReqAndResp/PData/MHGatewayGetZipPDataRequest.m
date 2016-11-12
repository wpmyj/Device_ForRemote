//
//  MHGatewayUserDefineDataRequest.m
//  MiHome
//
//  Created by Lynn on 10/28/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayGetZipPDataRequest.h"

@implementation MHGatewayGetZipPDataRequest

- (NSString *)api
{
    return @"/user/getpdata";
}

- (id)jsonObject
{
    NSDictionary *params = @{@"key"        : self.keyString,
                             @"time_end"   : @"0",
                             @"time_start" : @"0"};
    
    
    NSDictionary *json = @{
                           @"params":@[params]
                           };
    return json;
}

@end
