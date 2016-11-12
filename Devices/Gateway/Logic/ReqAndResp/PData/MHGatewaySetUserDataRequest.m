//
//  MHGatewaySetUserDataRequest.m
//  MiHome
//
//  Created by Lynn on 10/29/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHGatewaySetUserDataRequest.h"

@implementation MHGatewaySetUserDataRequest

- (NSString *)api
{
    return @"/user/setpdata";
}

- (id)jsonObject
{
    NSDictionary *json = @{ @"key":self.keyString,
                            @"time":@"0",
                            @"value":self.value};
    return json;
}


@end
