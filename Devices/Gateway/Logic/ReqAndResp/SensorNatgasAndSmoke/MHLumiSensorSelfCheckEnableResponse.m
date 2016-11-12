//
//  MHLumiSensorSelfCheckEnableResponse.m
//  MiHome
//
//  Created by LM21Mac002 on 16/10/12.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiSensorSelfCheckEnableResponse.h"

@implementation MHLumiSensorSelfCheckEnableResponse
+ (instancetype)responseWithJSONObject:(id)object
{
    MHLumiSensorSelfCheckEnableResponse *response = [[self alloc] init];
//    code = 0;
//    message = ok;
//    result = "";
    response.code = [[object valueForKey:@"code"] integerValue];
    response.message = [object valueForKey:@"message"];
    NSLog(@"%@",object);
    
    return response;
    
}
@end
