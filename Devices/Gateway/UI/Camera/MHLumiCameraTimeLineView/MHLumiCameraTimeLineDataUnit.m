//
//  MHLumiCameraTimeLineDataUnit.m
//  Lumi_demo_OC
//
//  Created by LM21Mac002 on 16/10/22.
//  Copyright © 2016年 LM21Mac002. All rights reserved.
//

#import "MHLumiCameraTimeLineDataUnit.h"
#import "NSDateFormatter+lumiDateFormatterHelper.h"

static NSString * const kEnableKey = @"enable";

@interface MHLumiCameraTimeLineDataUnit()

@end

@implementation MHLumiCameraTimeLineDataUnit
- (instancetype)initWithDic:(NSDictionary *)dictionary{
    self = [super init];
    if (self){
    }
    return self;
}

+ (MHLumiCameraTimeLineDataUnit *)data{
    MHLumiCameraTimeLineDataUnit *dataUnit = [[MHLumiCameraTimeLineDataUnit alloc] init];
    dataUnit.startDate = [NSDate date];
    dataUnit.endDate = [dataUnit.startDate dateByAddingTimeInterval:60*60];
    dataUnit.needShowTimeNoteLabel = NO;
    dataUnit.countOfSeparated = 6;
    return dataUnit;
}

- (NSTimeInterval)timeIntervalBetweenStartDateAndEndDate{
    return self.endDate.timeIntervalSince1970 - self.startDate.timeIntervalSince1970;
}
@end
