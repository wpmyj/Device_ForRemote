//
//  MHLumiDateTools.m
//  MiHome
//
//  Created by Lynn on 12/28/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLumiDateTools.h"

@implementation MHLumiDateTools

+ (NSString *)fullStringFromDate :(NSDate *)date {
    NSDateFormatter *dayDateFormatter = [[NSDateFormatter alloc] init];
    dayDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    dayDateFormatter.timeZone = [NSTimeZone systemTimeZone];
    
    return [dayDateFormatter stringFromDate:date];
}

+ (NSDate *)dateFromString :(NSString *)string {
    NSDateFormatter *dayDateFormatter = [[NSDateFormatter alloc] init];
    dayDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    dayDateFormatter.timeZone = [NSTimeZone systemTimeZone];
    
    return [dayDateFormatter dateFromString:string];
}

+ (NSString *)dateStringMinusOneDay:(NSString *)dateString {

    NSDate *oldDate = [self dateFromString:dateString];
    
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    calendar.timeZone = [NSTimeZone systemTimeZone];
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];

    [adcomps setDay:-1];
    
    NSDate *newDate = [calendar dateByAddingComponents:adcomps toDate:oldDate options:0];

    return [self fullStringFromDate:newDate];
}

+ (NSString *)dateStringMinusOneMonth:(NSString *)dateString {
    NSDate *oldDate = [self dateFromString:dateString];

    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    calendar.timeZone = [NSTimeZone systemTimeZone];
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];

    [adcomps setMonth:-1];

    NSDate *newDate = [calendar dateByAddingComponents:adcomps toDate:oldDate options:0];
    
    return [self fullStringFromDate:newDate];
}

+ (BOOL)isThisYear:(NSDate *)date {
    BOOL isThisYear;
    
    NSDateFormatter *dayDateFormatter = [[NSDateFormatter alloc] init];
    dayDateFormatter.dateFormat = @"yyyy";
    dayDateFormatter.timeZone = [NSTimeZone systemTimeZone];

    NSString *yearDateString = [dayDateFormatter stringFromDate:date];
    NSInteger yearDate = yearDateString.integerValue;
    
    NSString *currentYearDate = [dayDateFormatter stringFromDate:[NSDate date]];
    NSInteger currentYear = currentYearDate.integerValue;
    
    if(currentYear == yearDate) isThisYear = YES;
    else isThisYear = NO;
    
    return isThisYear;
}

+ (BOOL)isSeperateMonthOfTheYear:(NSDate *)date {
    NSDateFormatter *dayDateFormatter = [[NSDateFormatter alloc] init];
    dayDateFormatter.dateFormat = @"MM";
    dayDateFormatter.timeZone = [NSTimeZone systemTimeZone];

    NSString *monthDateString = [dayDateFormatter stringFromDate:date];
    NSInteger monthDate = monthDateString.integerValue;
    
    if (monthDate == 12) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (BOOL)isSeperateDayOfTheYear:(NSDate *)date {
    NSDateFormatter *dayDateFormatter = [[NSDateFormatter alloc] init];
    dayDateFormatter.dateFormat = @"MM-dd";
    dayDateFormatter.timeZone = [NSTimeZone systemTimeZone];
    
    NSString *dateString = [dayDateFormatter stringFromDate:date];
    
    if ([dateString isEqualToString:@"12-31"]) {
        return YES;
    }
    else {
        return NO;
    }
}

@end
