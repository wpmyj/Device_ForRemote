//
//  MHGatewayGetShareUserDataResponse.m
//  MiHome
//
//  Created by guhao on 4/18/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayGetShareUserDataResponse.h"

@implementation MHGatewayGetShareUserDataResponse

+ (instancetype)responseWithJSONObject:(id)object {
    MHGatewayGetShareUserDataResponse *response = [[self alloc] init];
    response.code = [[object objectForKey:@"code" class:[NSNumber class]] integerValue];
    response.message = [object objectForKey:@"message" class:[NSString class]];
    NSLog(@"%ld", response.code);
    NSLog(@"%@", response.message);
    NSLog(@"%@", [object objectForKey:@"result"]);

    if (response.code == 0 && [response.message isEqualToString:@"ok"]) {
        NSDictionary *result = [object objectForKey:@"result" class:[NSDictionary class]];
        response.shareUsers = [result objectForKey:@"list"];
        }
    else {
        response.shareUsers = [[NSMutableArray alloc] init];
    }
    
    return response;
}
@end
