//
//  MHDeviceCameraDemo.m
//  MiHome
//
//  Created by huchundong on 2016/8/23.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHDeviceCameraDemo.h"
#import "MHDevListManager.h"
#import "MHGetP2PIdRequest.h"
#import "MHGetP2PIdResponse.h"

static NSString* const kDeviceModelCameraDemo = @"chuangmi.camera.xiaobai";
@implementation MHDeviceCameraDemo
+ (void)load {
//    [MHDevListManager registerDeviceModelId:@"lumi.camera.v1" className:NSStringFromClass([MHDeviceCameraDemo class]) isRegisterBase:NO];
}
+ (NSString* )getViewControllerClassName {
    return @"MHCameraDemoViewController";
}
- (BOOL)isShownInQuickConnectList {
    return YES;
}
- (BOOL)isBaseModel{
    //小白是特殊的，因为它的model没有按规范来，只能返回NO。其他直接用父类的方法判断
    return NO;
}
+ (NSUInteger)getDeviceType {
//    return MHDeviceType_XiaoBai;
    return MHDeviceType_Gateway;
}
//- (NSInteger)category
//{
//    return MHDeviceCategoryWifi;
//}
+ (BOOL)isDeviceAllowedToShown {
    return YES;
}
- (instancetype)initWithData:(MHDataDevice *)data
{
    self = [super initWithData:data];
    if (self){
        self.deviceBindPattern = MHDeviceBind_WithoutCheck;
        self.isNeedAutoBindAfterDiscovery = YES;
        self.isCanControlWhenOffline = YES;
    }
    return self;
}

- (void)getP2PId:(NSString*)did callback:(void(^)(MHGetP2PIdResponse*))handle
{
    NSLog(@"%@",did);
    MHGetP2PIdRequest *request = [[MHGetP2PIdRequest alloc] init];
    request.did = did;
    XM_WS(ws);
    [[MHNetworkEngine sharedInstance] sendRequest:request success:^(id response) {
        XM_SS(ss, ws);
        
        
        MHGetP2PIdResponse *p2pResponse = [MHGetP2PIdResponse responseWithJSONObject:response];
        
        ss.udid = p2pResponse.p2pId;
        ss.password = p2pResponse.password;
        if (handle) {
            handle(p2pResponse);
        }
        
    } failure:^(NSError * error) {
        XBLog(@"getP2PId fail error = %@",error);
        XM_SS(ss, ws);
        if(handle){
            handle(nil);
        }
    }];
}

#pragma mark - 获取UID
//[obj[@"result"] firstObject]
- (void)getUidSuccess:(void(^)(NSString *udid,NSString *password))success failure:(FailedBlock)failure {
    NSDictionary *payload = [self requestPayloadWithMethodName:@"get_prop" value:@[ @"p2p_id"]];
    XM_WS(weakself);
    [self sendPayload:payload success:^(id obj) {
        NSLog(@"%@",obj);
        NSString *udid = [obj[@"result"] firstObject];
        weakself.udid = udid;
        weakself.password = @"888888";
        if (success) success(udid,@"888888");
        
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
        
        if (failure) failure(error);
        
    }];
}

#pragma mark - 打开/关闭视频采集
- (void)setVideoWithOnOff:(BOOL)onOrOff uid:(NSString *)uid success:(void (^)(BOOL))success failure:(void (^)(NSError *))failure{
    NSString *methodName = @"set_video";
    NSString *actionName = onOrOff ? @"on" : @"off";
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    payload[@"id"] = @([self getRPCNonce]);
    payload[@"method"] = methodName;
    payload[@"params"] = @[actionName, uid];
    NSLog(@"%@",payload);
    [self sendPayload:payload success:^(id obj) {
        NSLog(@"%@",obj);
        NSArray<NSString *> *resultArray = [obj valueForKey:@"result"];
        if ([resultArray.firstObject isEqualToString:@"ok"]){
            if (success) success(obj);
        }else{
            if (failure) failure(nil);
        }
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

#pragma mark - 摄像头工作模式（floor／wall／ceiling）
- (void)setCameraMode:(MHLumiDeviceCameraMode)mode
              success:(void (^)(MHDeviceCameraDemo *deviceCamera, MHLumiDeviceCameraMode mode))completedHandler
              failure:(FailedBlock)failure{
    NSString *methodName = @"set_app_type";
    NSString *modeName = @"ceiling";
    switch (mode) {
        case MHLumiDeviceCameraModeWall:
            modeName = @"wall";
            break;
        case MHLumiDeviceCameraModeFloor:
            modeName = @"table";
            break;
        case MHLumiDeviceCameraModeCeiling:
            modeName = @"ceil";
            break;
        default:
            break;
    }
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    payload[@"id"] = @([self getRPCNonce]);
    payload[@"method"] = methodName;
    payload[@"params"] = @[modeName];
    NSLog(@"%@",payload);
    [self sendPayload:payload success:^(id obj) {
        NSLog(@"%@",obj);
        NSArray<NSString *> *resultArray = [obj valueForKey:@"result"];
        if ([resultArray.firstObject isEqualToString:@"ok"]){
#warning 解析格式不知道
        }else{
            if (failure) failure(nil);
        }
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}


@end
