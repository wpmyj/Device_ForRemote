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
    NSArray <NSDictionary *> *dics = [object objectForKey:@"result" class:[NSArray class]];
    NSMutableArray<MHLumiAlarmVideoDownloadUnit *> *todoUnits = [NSMutableArray array];
    for (NSDictionary *dic in dics) {
        if ([dic isKindOfClass:[NSDictionary class]]) {
            MHLumiAlarmVideoDownloadUnit *todoData = [[MHLumiAlarmVideoDownloadUnit alloc] initWithDic:dic];
            [todoUnits addObject:todoData];
        }
    }
    response.alarmVideoDownloadUnits = todoUnits;
    NSLog(@"%@", object);
    
    return response;
}
@end
