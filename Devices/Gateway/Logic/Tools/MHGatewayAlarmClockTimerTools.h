//
//  MHGatewayAlarmClockTimerTools.h
//  MiHome
//
//  Created by guhao on 3/23/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MiHomeKit/MHDataDeviceTimer.h>

#define NextIdentifierOn    @"mydevice.gateway.setting.alarmclock.timerspacephase"
#define NextIdentifierOff   @"mydevice.gateway.setting.alarmclock.timerspacephaseOff"


@interface MHGatewayAlarmClockTimerTools : NSObject

+ (id)sharedInstance;
/**
 *  闹钟下次响的时间
 *
 *  @param timer      timer
 *  @param identifier 国际化字段(on-NextIdentifierOn, off-NextIdentifierOff)
 *
 *  @return 下次响闹钟时间的字符串
 */
- (NSString *)fetchTimeSpace:(MHDataDeviceTimer *)timer andIdentifier:(NSString *)identifier;
@end
