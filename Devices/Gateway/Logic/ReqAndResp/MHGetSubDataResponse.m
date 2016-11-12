//
//  MHGetSubDataResponse.m
//  MiHome
//
//  Created by Woody on 15/4/10.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import "MHGetSubDataResponse.h"
#import "MHDataGatewayLog.h"
#import "MHDeviceGatewayBase.h"

@implementation MHGetSubDataResponse
+ (instancetype)responseWithJSONObject:(id)object
{
    MHGetSubDataResponse* response = [[self alloc] init];
    response.code = [[object objectForKey:@"code" class:[NSNumber class]] integerValue];
    response.message = [object objectForKey:@"message" class:[NSString class]];
    
    
    MHSafeDictionary *result = [object objectForKey:@"result" class:[NSDictionary class]];
    NSArray*data = [result objectForKey:@"data" class:[NSArray class]];
    if ([data count] > 0) {
        response.logs = [MHDataGatewayLog dataListWithJSONObjectList:data];
    }
    
    return response;
}

- (void)extraFilterForSmokeAndNatgasSensorWithDeviceModel:(NSString *)model{
    if (![model isEqualToString:DeviceModelgateWaySensorNatgasV1]){
        return;
    }
    NSMutableArray*data = [NSMutableArray arrayWithArray:self.logs];
    if ([data count] > 0) {
        //        Gateway_Event_Smoke_Alarm
        NSMutableArray <MHDataGatewayLog *> *toRemoveLogs = [NSMutableArray array];
        for (MHDataGatewayLog *log in data) {
            if ([log.key isEqualToString:Gateway_Event_Smoke_Alarm] && [log.value  isEqual: @"[8]"]){
                [toRemoveLogs addObject:log];
            }
        }
        [data removeObjectsInArray:toRemoveLogs];
        self.logs = data;
    }
}

@end
