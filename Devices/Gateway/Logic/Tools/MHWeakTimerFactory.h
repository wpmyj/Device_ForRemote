//
//  MHWeakTimerFactory.h
//  MiHome
//
//  Created by LM21Mac002 on 16/9/8.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kLoopAllDataInterval 6.0
#define kLoopDeviceStatusIntervar 6
#define kLoopDeviceTimerDataIntervar 20

@interface MHWeakTimerFactory : NSObject
+ (NSTimer *)scheduledTimerWithBlock:(NSTimeInterval)timeInteval
                            userInfo:(NSObject *)userInfo
                             repeats:(bool)repeats
                            callback: (void(^)(void)) callback;
+ (NSTimer *)scheduledTimerWithBlock:(NSTimeInterval)timeInteval
                            callback: (void(^)(void)) callback;
@end
