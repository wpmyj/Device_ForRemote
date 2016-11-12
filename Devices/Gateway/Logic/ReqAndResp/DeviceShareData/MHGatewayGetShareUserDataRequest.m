//
//  MHGatewayGetShareUserDataRequest.m
//  MiHome
//
//  Created by guhao on 4/18/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayGetShareUserDataRequest.h"

@implementation MHGatewayGetShareUserDataRequest
- (NSString *)api
{
    return @"/share/get_share_user";
}

- (id)jsonObject
{
    NSDictionary *json =  @{@"did"   : self.did,
                            @"pid"   : @"0"};
    NSLog(@"%@", self.did);
    return json;
}
@end
