//
//  MHWeakTimerFactory.m
//  MiHome
//
//  Created by LM21Mac002 on 16/9/8.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHWeakTimerFactory.h"

@interface MHWeakTimerWithBlock : NSObject
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy) void(^callback)(void);
- (instancetype)initWithTimeInterval: (NSTimeInterval)timeInterval
                            userInfo:(NSObject *)userInfo
                             repeats:(bool)repeats
                            callback: (void(^)(void)) callback;
@end


@implementation MHWeakTimerWithBlock

- (void)invokeCallback{
    if (self.callback) {
        self.callback();
    }
}

- (void)dealloc{
    NSLog(@"%@析构了",self);
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval
                            userInfo:(NSObject *)userInfo
                             repeats:(bool)repeats
                            callback:(void(^)(void))callback{
    self = [super init];
    if (self) {
        self.callback = callback;
        self.timer = [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(invokeCallback)  userInfo:userInfo repeats:repeats];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode: NSRunLoopCommonModes];
    }
    return self;
}

+ (instancetype)timerWithInterval:(NSTimeInterval)timeInterval
                         userInfo:(NSObject *)userInfo
                          repeats:(bool)repeats
                         callback:(void(^)(void))callback{
    return [[MHWeakTimerWithBlock alloc] initWithTimeInterval:timeInterval userInfo:userInfo repeats:repeats callback:callback];
}

@end


@implementation MHWeakTimerFactory

+ (NSTimer *)scheduledTimerWithBlock:(NSTimeInterval)timeInteval
                            userInfo:(NSObject *)userInfo
                             repeats:(bool)repeats
                            callback: (void(^)(void)) callback{
    return [MHWeakTimerWithBlock timerWithInterval:timeInteval userInfo:userInfo repeats:repeats callback:callback].timer;
}

+ (NSTimer *)scheduledTimerWithBlock:(NSTimeInterval)timeInteval
                            callback: (void(^)(void)) callback{
    return [MHWeakTimerWithBlock timerWithInterval:timeInteval userInfo:nil repeats:YES callback:callback].timer;
}

@end

