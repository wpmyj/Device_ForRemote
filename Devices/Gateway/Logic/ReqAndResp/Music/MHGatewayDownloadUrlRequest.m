//
//  MHGatewayDownloadUrlRequest.m
//  MiHome
//
//  Created by Lynn on 10/28/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayDownloadUrlRequest.h"

@implementation MHGatewayDownloadUrlRequest

- (NSString *)api
{
    return @"/home/getfileurl";
}

- (id)jsonObject
{
    NSDictionary *json = @{@"obj_name":self.fileName};
    return json;
}

@end