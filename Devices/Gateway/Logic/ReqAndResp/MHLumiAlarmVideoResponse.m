//
//  MHLumiAlarmVideoResponse.m
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/14.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiAlarmVideoResponse.h"

@implementation MHLumiAlarmVideoResponse
+ (instancetype)responseWithJSONObject:(id)object{
    MHLumiAlarmVideoResponse* response = [[self alloc] init];
    response.code = [[object objectForKey:@"code" class:[NSNumber class]] integerValue];
    response.message = [object objectForKey:@"message" class:[NSString class]];
    
    
    NSLog(@"%@", object);
    
    return response;
}
@end
