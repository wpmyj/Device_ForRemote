//
//  MHPlugDataRequest.m
//  MiHome
//
//  Created by Lynn on 11/12/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLumiPlugDataRequest.h"

@implementation MHLumiPlugDataRequest

- (NSString *)api {
    return @"/user/get_user_device_data";
}

- (id)jsonObject {
    //self.groupType
    NSString *startTimeString;
    NSString *endTimeString;
    if(self.dateString) {
        NSArray *dateArray  = [self fetchCurrentDateString];
        startTimeString = dateArray[0];
        endTimeString = dateArray[1];
    }
    else{
        startTimeString = self.startDateString;
        endTimeString = self.endDateString;
    }
    
    NSString *userid = [MHPassportManager sharedSingleton].currentAccount.userId;
    NSDictionary *data =
            @{ @"uid"           :   userid,
               @"did"           :   self.deviceDid,
               @"time_start"    :   startTimeString,
               @"time_end"      :   endTimeString,
               @"type"          :   @"store",
               @"key"           :   @"powerCost",
               @"group"         :   self.groupType,
               @"limit"         :   @(1000),
            };

    return data;
}

//电量获取的时间
- (NSArray *)fetchCurrentDateString{
    //如果是当日的电量，starttime 从当日的零点
    //如果是当月的电量，starttime 从当月的第一天零点开始
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    dateFormatter.timeZone = [NSTimeZone systemTimeZone];
    
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    calendar.timeZone = [NSTimeZone systemTimeZone];
    
    NSDate *startDate = [dateFormatter dateFromString:self.dateString];
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    if([self.groupType isEqualToString:@"day"]){
        [adcomps setDay:+1];
    }
    else if([self.groupType isEqualToString:@"month"]){
        [adcomps setMonth:+1];
    }
    NSDate *endDate = [calendar dateByAddingComponents:adcomps toDate:startDate options:0];
    
    NSLog(@"startDate = %@",startDate);
    NSLog(@"endDate = %@",endDate);
    
    NSTimeInterval unixStartTime= [startDate timeIntervalSince1970];
    long long int startTime=(long long int)unixStartTime;
    NSTimeInterval unixEndTime= [endDate timeIntervalSince1970];
    long long int endTime=(long long int)unixEndTime;
    
    NSString *startTimeString = [NSString stringWithFormat:@"%lld",startTime];
    NSString *endTimeString = [NSString stringWithFormat:@"%lld",endTime];
    NSLog(@"%@",startTimeString);
    NSLog(@"%@",endTimeString);

    NSArray *dateArray = @[ startTimeString, endTimeString ];
    
    return dateArray;
}

@end
