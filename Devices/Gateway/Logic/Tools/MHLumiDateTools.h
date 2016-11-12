//
//  MHLumiDateTools.h
//  MiHome
//
//  Created by Lynn on 12/28/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MHLumiDateTools : NSObject

+ (NSString *)fullStringFromDate :(NSDate *)date ;

+ (NSDate *)dateFromString :(NSString *)string ;

+ (NSString *)dateStringMinusOneDay:(NSString *)dateString ;

+ (NSString *)dateStringMinusOneMonth:(NSString *)dateString ;

+ (BOOL)isThisYear:(NSDate *)date ;

+ (BOOL)isSeperateMonthOfTheYear:(NSDate *)date ;

+ (BOOL)isSeperateDayOfTheYear:(NSDate *)date;
@end
