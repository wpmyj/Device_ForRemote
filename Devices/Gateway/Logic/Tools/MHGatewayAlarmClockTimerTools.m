//
//  MHGatewayAlarmClockTimerTools.m
//  MiHome
//
//  Created by guhao on 3/23/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayAlarmClockTimerTools.h"

@implementation MHGatewayAlarmClockTimerTools

+ (id)sharedInstance {
    static MHGatewayAlarmClockTimerTools *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[MHGatewayAlarmClockTimerTools alloc] init];
        }
    });
    return manager;
}


//计算距离下次像闹钟需要的时间
- (NSString *)fetchTimeSpace:(MHDataDeviceTimer *)timer andIdentifier:(NSString *)identifier {
    if(!timer){
        return @"";
    }
    BOOL isOn = [identifier isEqualToString:NextIdentifierOn];
    int timerMinute = isOn ? (int)timer.onMinute : (int)timer.offMinute;
    int timerHour = isOn ? (int)timer.onHour : (int)timer.offHour;
    
    NSString *timeSpacing = [NSString string];
    
    NSDateComponents *dateComponents = [self getCurrentDateComponents];
    
    int currentHour = (int)dateComponents.hour;
    int currentMint = (int)dateComponents.minute;
    //当前星期数
    int currentWeekday = [self getCurrentWeekday:dateComponents];
    
    int minTip = 0;
    int hourTip = 0;
    
    //单独处理执行一次的
    if(timer.onRepeatType == 0)
    {
        if (currentMint > timerMinute){
            minTip = timerMinute + 60 - currentMint;
            hourTip = timerHour - 1 - currentHour;
        }
        else {
            minTip = timerMinute - currentMint;
            hourTip = timerHour - currentHour;
        }
        if (hourTip<0) hourTip = hourTip + 24;
        if (hourTip) {
            NSString *strIdentifier = [NSString stringWithFormat:@"%@2", identifier];
            timeSpacing = [NSString stringWithFormat:NSLocalizedStringFromTable(strIdentifier,@"plugin_gateway","还有%d小时%d分钟响铃"),hourTip,minTip];
        }
        else {
            NSString *strIdentifier = [NSString stringWithFormat:@"%@3", identifier];
            timeSpacing = [NSString stringWithFormat:NSLocalizedStringFromTable(strIdentifier,@"plugin_gateway","%d分钟响铃"),minTip];
        }
        return timeSpacing;
    }
    
    //处理重复的星期
    //找到最近的day
    NSMutableArray *alarmDayArray = [NSMutableArray arrayWithObjects:@"0",@"0",@"0",@"0",@"0",@"0",@"0",nil];
    int value = (int)timer.onRepeatType;
    int i = 0;
    while (value){
        [alarmDayArray replaceObjectAtIndex:i withObject:(value & 1)? @"1": @"0"];
        value /= 2;
        i ++ ;
    }
    int dayRecent = 0;
    for (int i = currentWeekday - 1; i< 7 ;i++){
        if([[alarmDayArray objectAtIndex:i] isEqualToString:@"1"]){
            dayRecent = i+1;
            
            //重复的天，如果时间已经过，再重新轮询
            if (dayRecent == currentWeekday){
                if (currentHour > timerHour ||
                    (currentHour == timerHour && currentMint >= timerMinute)){
                    dayRecent = -1; //如果已过今天，就要继续轮询，轮不到就说明只有今天重复
                }
                else{
                    break;
                }
            }
            else{
                break;
            }
        }
    }
    if(dayRecent == 0 || dayRecent == -1){
        for (int i = 0; i<currentWeekday -1; i++){
            if([[alarmDayArray objectAtIndex:i] isEqualToString:@"1"]){
                dayRecent = i+1;
                break;
            }
        }
    }
    
    //日期相差 *24
    int dayGap = 0;
    if (dayRecent == -1) dayGap = 7;
    else{
        if (dayRecent >= currentWeekday) dayGap = dayRecent - currentWeekday;
        else dayGap = 7 + dayRecent - currentWeekday;
    }
    
    if (currentMint > timerMinute){
        minTip = timerMinute + 60 - currentMint;
        hourTip = timerHour - 1 - currentHour;
    }
    else {
        minTip = timerMinute - currentMint;
        hourTip = timerHour - currentHour;
    }
    hourTip = hourTip + dayGap *24;
    int dayTip = hourTip / 24;
    int hourwithDayTip = hourTip % 24;
    
    if(dayTip){
        NSString *strIdentifier = [NSString stringWithFormat:@"%@1", identifier];
        timeSpacing = [NSString stringWithFormat:NSLocalizedStringFromTable(strIdentifier,@"plugin_gateway","还有%d天%d小时%d分钟响铃"),dayTip,hourwithDayTip,minTip];
    }
    else{
        if(hourwithDayTip) {
            NSString *strIdentifier = [NSString stringWithFormat:@"%@2", identifier];
              timeSpacing = [NSString stringWithFormat:NSLocalizedStringFromTable(strIdentifier,@"plugin_gateway","还有%d小时%d分钟响铃"),hourwithDayTip,minTip];
        }
        else {
            NSString *strIdentifier = [NSString stringWithFormat:@"%@3", identifier];
             timeSpacing = [NSString stringWithFormat:NSLocalizedStringFromTable(strIdentifier,@"plugin_gateway","还有%d分钟响铃"),minTip];
        }
    }
    return timeSpacing;
}

//获取当前的日期
- (NSDateComponents *)getCurrentDateComponents {
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [greCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit fromDate:[NSDate date]];
    return dateComponents;
}

//获取当前的星期数，从周一开始
- (int)getCurrentWeekday:(NSDateComponents *)dateComponents {
    //转换当前weekday,因为weekday 从周日开始
    int currentWeekday = 0;
    
    switch (dateComponents.weekday) {
        case 1://周日
            currentWeekday = 7;
            break;
        case 2://周一
            currentWeekday = 1;
            break;
        case 3://周二
            currentWeekday = 2;
            break;
        case 4://周三
            currentWeekday = 3;
            break;
        case 5://周四
            currentWeekday = 4;
            break;
        case 6://周五
            currentWeekday = 5;
            break;
        case 7:
            currentWeekday = 6;
            break;
        default:
            break;
    }
    return currentWeekday;
}


@end
