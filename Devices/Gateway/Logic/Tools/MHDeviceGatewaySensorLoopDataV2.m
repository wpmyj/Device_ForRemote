//
//  MHDeviceGatewaySensorLoopDataV2.m
//  MiHome
//
//  Created by LM21Mac002 on 16/9/8.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewaySensorLoopDataV2.h"


//循环请求间隔
#define LoopDataInterval 6.0

@interface MHDeviceGatewaySensorLoopDataV2()

@property (nonatomic,strong) NSString *methodName;
@property (nonatomic,strong) id params;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) NSRunLoop *currentRL;
@property (nonatomic,assign) BOOL shouldKeepRunning;
@property (nonatomic,strong) id propNewData;

@end

@implementation MHDeviceGatewaySensorLoopDataV2

- (void)setPropNewData:(id)propNewData {
    if (_propNewData != propNewData) {
        _propNewData = propNewData;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.fetchNewDataCallBack) self.fetchNewDataCallBack(propNewData);
        });
    }
}

- (void)startWatchingNewData:(NSString *)methodName WithParams:(id)params {
    self.shouldKeepRunning = YES;
    _params = params;
    _methodName = methodName;
    
    XM_WS(weakself);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        weakself.timer = [NSTimer timerWithTimeInterval:LoopDataInterval target:self selector:@selector(fetchNewData:) userInfo:nil repeats:YES];
        [weakself.timer fire];
        
        weakself.currentRL = [NSRunLoop currentRunLoop];
        [weakself.currentRL addTimer:weakself.timer forMode:NSDefaultRunLoopMode];
        
        //        [[NSRunLoop currentRunLoop] run]; //donot use run
        //apple official coding suggestion
        while (weakself.shouldKeepRunning && [weakself.currentRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
    });
}

- (void)fetchNewData:(id)sender {
    
    XM_WS(weakself);
    
    [self loopDeviceProp:self.methodName value:self.params success:^(id obj){
        if([obj valueForKey:@"result"]){
            weakself.propNewData = [obj valueForKey:@"result"];
        }
    } failure:nil];
    
    NSLog(@" loop fetch data , propname = %@", self.methodName);
}

- (void)loopDeviceProp:(NSString *)prop
                 value:(id)params
               success:(void (^)(id))success
               failure:(void (^)(NSError *))failure {
    
    NSDictionary *payload = [self subDevicePayloadWithMethodName:prop deviceId:nil value:params];
    NSLog(@"%@",payload);
    [self.device sendPayload:payload success:^(id respObj) {
        NSLog(@"%@",respObj);
        if (success) success(respObj);

    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

#pragma mark - 重写销毁方法
- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
    self.shouldKeepRunning = NO;
}

- (void)stopWatching {
    [self.timer invalidate];
    self.timer = nil;
    self.shouldKeepRunning = NO;
}

@end
