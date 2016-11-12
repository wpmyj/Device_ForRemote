//
//  MHGetP2PIdRequest.m
//  	
//
//  Created by huchundong on 15/12/29.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//

#import "MHGetP2PIdRequest.h"

@implementation MHGetP2PIdRequest
- (NSString *)api
{
    return @"/device/devicepass";
}

- (id)jsonObject
{
    if(self.did == nil){
        return nil;
    }
    NSDictionary* json = @{
                           @"did" : self.did};
    return json;
}
@end
