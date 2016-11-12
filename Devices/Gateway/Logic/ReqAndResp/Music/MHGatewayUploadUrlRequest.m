//
//  MHGatewayUploadUrlRequest.m
//  MiHome
//
//  Created by Lynn on 10/28/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayUploadUrlRequest.h"

@implementation MHGatewayUploadUrlRequest

- (NSString *)api
{
    return @"/home/genpresignedurl";
}

- (id)jsonObject
{
    NSDictionary *json = @{@"did":self.device.did,@"suffix":self.suffix,@"model":self.device.model};
    return json;
}

@end
