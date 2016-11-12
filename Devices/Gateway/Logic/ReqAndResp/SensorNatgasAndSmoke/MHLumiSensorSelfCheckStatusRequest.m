//
//  MHLumiSensorSelfCheckStatusRequest.m
//  MiHome
//
//  Created by LM21Mac002 on 16/10/12.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiSensorSelfCheckStatusRequest.h"

@implementation MHLumiSensorSelfCheckStatusRequest
- (NSString *)api
{
    return @"/device/getsetting";
}

- (id)jsonObject
{
    //
    //    data={
    //        "did":"lumi.158d00011478c8",
    //        "settings":{
    //            "self_check_notify":"1"   // "0"为关闭，其他值都为开启。默认开启
    //        }
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    if (self.did) [json setObject:self.did forKey:@"did"];
    [json setObject:@[@"self_check_notify"] forKey:@"settings"];
    return json;
}
@end
