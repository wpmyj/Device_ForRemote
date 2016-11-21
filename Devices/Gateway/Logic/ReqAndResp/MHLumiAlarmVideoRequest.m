//
//  MHLumiAlarmVideoRequest.m
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/14.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiAlarmVideoRequest.h"

@implementation MHLumiAlarmVideoRequest

- (instancetype)init{
    self = [super init];
    if (self) {
        _limit = 1000;
    }
    return self;
}

- (NSString *)api{
    return @"/user/get_user_device_data";
}

- (id)jsonObject
{
    NSMutableDictionary* json = [NSMutableDictionary dictionary];
    if (self.did) [json setObject:self.did forKey:@"did"];
    [json setObject:@(self.timeStart) forKey:@"time_start"];
    [json setObject:@(self.timeEnd) forKey:@"time_end"];
    [json setObject:@(self.limit) forKey:@"limit"];
    [json setObject:@"event" forKey:@"type"];
    [json setObject:@"alarmVideo" forKey:@"key"];
//    if (self.group) [json setValue:self.group forKey:@"group"];
    return json;
}

@end
