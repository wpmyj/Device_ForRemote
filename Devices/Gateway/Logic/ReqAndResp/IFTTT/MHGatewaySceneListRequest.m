//
//  MHGatewayScenListRequest.m
//  MiHome
//
//  Created by Lynn on 9/4/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHGatewaySceneListRequest.h"

@implementation MHGatewaySceneListRequest

- (NSString *)api
{
    return @"/scene/list";
}

- (id)jsonObject
{
    NSDictionary *json = nil;
        if (self.sensor.did) {
            json = @{ @"did"    :  [NSString stringWithFormat:@"%@",self.sensor.did] ,
                      @"st_id"  :  self.st_id ? self.st_id : @(15) ,
                      @"fromat" :  @"array"
                      };
           
        }else {
            json = @{ @"st_id"  :  self.st_id ? self.st_id : @(15) ,
                      @"fromat" :  @"array"
                      };
        }
    return json;
}

@end
