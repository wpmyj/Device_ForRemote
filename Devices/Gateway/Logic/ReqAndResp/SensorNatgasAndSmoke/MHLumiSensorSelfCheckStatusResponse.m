//
//  MHLumiSensorSelfCheckStatusResponse.m
//  MiHome
//
//  Created by LM21Mac002 on 16/10/12.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiSensorSelfCheckStatusResponse.h"

@implementation MHLumiSensorSelfCheckStatusResponse
+ (instancetype)responseWithJSONObject:(id)object
{
    MHLumiSensorSelfCheckStatusResponse *response = [[self alloc] init];
    //    code = 0;
    //    message = ok;
    //    result = "";
    response.code = [[object valueForKey:@"code"] integerValue];
    response.message = [object valueForKey:@"message"];
    response.enable = [[[object valueForKey:@"result"] objectForKey:@"self_check_notify"] boolValue];
    NSLog(@"%@",object);
    
    return response;
    
}
@end
