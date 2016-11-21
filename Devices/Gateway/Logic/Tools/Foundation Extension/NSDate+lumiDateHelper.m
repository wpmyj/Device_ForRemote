//
//  NSDate+lumiDateHelper.m
//  Lumi_demo_OC
//
//  Created by LM21Mac002 on 16/10/22.
//  Copyright © 2016年 LM21Mac002. All rights reserved.
//

#import "NSDate+lumiDateHelper.h"
#import "NSDateFormatter+lumiDateFormatterHelper.h"
@implementation NSDate (lumiDateHelper)
- (NSDate *)startDateInHour{
    NSDateFormatter *aDateFormatter = [NSDateFormatter timeLineDateFormatter];
    NSString *dateString = [aDateFormatter stringFromDate:self];
    NSMutableString *todoString = [NSMutableString stringWithString:dateString];
    [todoString replaceCharactersInRange:NSMakeRange(dateString.length-2, 2) withString:@"00"];
    return [aDateFormatter dateFromString:todoString];
}

- (NSDate *)endDateInHour{
    if ([self isEqualToDate:[self startDateInHour]]){
        return self;
    }
    return [[self startDateInHour] dateByAddingTimeInterval:60*60];
}

@end
