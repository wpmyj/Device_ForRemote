//
//  NSDateFormatter+lumiDateFormatterHelper.m
//  Lumi_demo_OC
//
//  Created by LM21Mac002 on 16/10/22.
//  Copyright © 2016年 LM21Mac002. All rights reserved.
//

#import "NSDateFormatter+lumiDateFormatterHelper.h"

@implementation NSDateFormatter (lumiDateFormatterHelper)
+ (NSDateFormatter *)timeLineDateFormatter{
    static NSDateFormatter *timeLineDateFormatter = nil;
    if (timeLineDateFormatter == nil){
        NSDateFormatter *aDateFormatter = [[NSDateFormatter alloc] init];
        aDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
        aDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:8 * 3600];
        timeLineDateFormatter = aDateFormatter;
    }
    return timeLineDateFormatter;
}

+ (NSDateFormatter *)cameraBackwardDateFormatter{
    static NSDateFormatter *cameraBackwardDateFormatter = nil;
    if (cameraBackwardDateFormatter == nil){
        NSDateFormatter *aDateFormatter = [[NSDateFormatter alloc] init];
        aDateFormatter.dateFormat = @"MM-dd HH:mm:ss";
        aDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:8 * 3600];
        cameraBackwardDateFormatter = aDateFormatter;
    }
    return cameraBackwardDateFormatter;
}

+ (NSDateFormatter *)TUTKDateFormatter{
    static NSDateFormatter *TUTKDateFormatter = nil;
    if (TUTKDateFormatter == nil){
        NSDateFormatter *aDateFormatter = [[NSDateFormatter alloc] init];
        aDateFormatter.dateFormat = @"yyyyMMddHHmmss";
        aDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:8 * 3600];
        TUTKDateFormatter = aDateFormatter;
    }
    return TUTKDateFormatter;
}


@end
