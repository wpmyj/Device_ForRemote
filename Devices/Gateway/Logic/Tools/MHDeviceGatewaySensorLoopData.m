//
//  MHDeviceGatewaySensorXBulbLoop.m
//  MiHome
//
//  Created by Lynn on 8/8/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewaySensorLoopData.h"

//循环请求间隔
#define LoopDataInterval 6.0

@interface MHDeviceGatewaySensorLoopData()

@property (nonatomic,strong) NSString *propName;
@property (nonatomic,strong) id params;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) NSRunLoop *currentRL;
@property (nonatomic,assign) BOOL shouldKeepRunning;
@property (nonatomic,strong) id propNewData;

@end

@implementation MHDeviceGatewaySensorLoopData

- (void)setPropNewData:(id)propNewData {
    if (_propNewData != propNewData) {
        _propNewData = propNewData;

        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.fetchNewDataCallBack) self.fetchNewDataCallBack(propNewData);
        });
    }
}

- (void)startWatchingNewData:(NSString *)propName WithParams:(id)params {
    self.shouldKeepRunning = YES;
    _params = params;
    _propName = propName;
    
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
    
    NSString *method = [NSString stringWithFormat:@"get_%@",self.propName];

    [self loopDeviceProp:method value:self.params success:^(id obj){
        if([obj valueForKey:@"result"]){
            weakself.propNewData = [obj valueForKey:@"result"];
        }
    } failure:nil];
    
    NSLog(@" loop fetch data , propname = %@", self.propName);
}

- (void)loopDeviceProp:(NSString *)prop
                 value:(id)params
               success:(void (^)(id))success
               failure:(void (^)(NSError *))failure {
    
    NSDictionary *payload = [self requestPayloadWithMethodName:prop value:params];
    MHDeviceRPCRequest* request = [[MHDeviceRPCRequest alloc] init];
    request.deviceId = self.device.did;
    request.payload = payload;
    [self.device sendRPC:request success:^(id respObj) {

//    [self sendPayload:payload success:^(id respObj) {
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
