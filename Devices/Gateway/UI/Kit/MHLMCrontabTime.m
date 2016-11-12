//
//  MHLMCrontabTime.m
//  MiHome
//
//  Created by ayanami on 16/8/6.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLMCrontabTime.h"


#define kCrontabBlank       @" "
#define kCrontabComma       @","
#define kCrontabWildcard    @"*"

@implementation MHLMCrontabTime


//- (void)parseCrontabString:(NSString *)cs
//{
//    NSArray* comps = [cs componentsSeparatedByString:kCrontabBlank];
//    if ([comps count] != 5) {
//        return;
//    }
//    self.minute = [comps[0] integerValue];
//    self.hour = [comps[1] integerValue];
//    
//    NSArray* days = [comps[4] componentsSeparatedByString:kCrontabComma];
//        XM_WS(ws);
//        [days enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            NSUInteger day = [obj integerValue];
//            switch (day) {
//                case 0:
//                    ws.daysOfWeek |= MHCrontabSunday;
//                    break;
//                case 1:
//                    ws.daysOfWeek |= MHCrontabMonday;
//                    break;
//                case 2:
//                    ws.daysOfWeek |= MHCrontabTuesday;
//                    break;
//                case 3:
//                    ws.daysOfWeek |= MHCrontabWednesday;
//                    break;
//                case 4:
//                    ws.daysOfWeek |= MHCrontabThursday;
//                    break;
//                case 5:
//                    ws.daysOfWeek |= MHCrontabFriday;
//                    break;
//                case 6:
//                    ws.daysOfWeek |= MHCrontabSaturday;
//                    break;
//                default:
//                    break;
//            }
//        }];
//}




- (NSString *)crontabString
{
    NSMutableString* crontab = [NSMutableString new];
    [crontab appendFormat:@"%ld ", self.minute];
    [crontab appendFormat:@"%ld ", self.hour];
    
    if (self.daysOfWeek == MHCrontabDayOfWeekNone) {
        [crontab appendFormat:@"%ld ", self.dayOfMonth];
        [crontab appendFormat:@"%ld ", self.month];
        [crontab appendFormat:@"%@", kCrontabWildcard];
    }
    else {
        NSMutableString* days = [NSMutableString new];
        if (self.daysOfWeek & MHCrontabSunday) {
            [days appendFormat:@"%d,", 0];
        }
        if (self.daysOfWeek & MHCrontabMonday) {
            [days appendFormat:@"%d,", 1];
        }
        if (self.daysOfWeek & MHCrontabTuesday) {
            [days appendFormat:@"%d,", 2];
        }
        if (self.daysOfWeek & MHCrontabWednesday) {
            [days appendFormat:@"%d,", 3];
        }
        if (self.daysOfWeek & MHCrontabThursday) {
            [days appendFormat:@"%d,", 4];
        }
        if (self.daysOfWeek & MHCrontabFriday) {
            [days appendFormat:@"%d,", 5];
        }
        if (self.daysOfWeek & MHCrontabSaturday) {
            [days appendFormat:@"%d,", 6];
        }
        
        // delete last ","
        [crontab appendFormat:@"%@ %@ %@", kCrontabWildcard, kCrontabWildcard, [days substringToIndex:[days length] - 1]];
    }
    
    return crontab;
}
@end
