//
//  MHLumiSensorSelfCheckEnableRequest.m
//  MiHome
//
//  Created by LM21Mac002 on 16/10/12.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiSensorSelfCheckEnableRequest.h"

@implementation MHLumiSensorSelfCheckEnableRequest
- (NSString *)api
{
    return @"/device/setsetting";
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
    [json setObject:@{
                      @"self_check_notify":self.enable ? @"1" : @"0"
                      }forKey:@"settings"];
    return json;
}
@end
