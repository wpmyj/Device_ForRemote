//
//  MHGetP2PIdResponse.m
//  	
//
//  Created by huchundong on 15/12/29.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//

#import "MHGetP2PIdResponse.h"

@implementation MHGetP2PIdResponse
+ (instancetype)responseWithJSONObject:(id)object
{
    MHGetP2PIdResponse* response = [[self alloc] init];
    
    MHSafeDictionary* result = [object objectForKey:@"result" class:[NSDictionary class]];
    response.p2pId = [result objectForKey:@"p2p_id" class:[NSString class]];
    
    response.password =[result objectForKey:@"password" class:[NSString class]];// [MHDataCameraUpdateInfo dataWithJSONObject:object];
    
    return response;
}
@end
