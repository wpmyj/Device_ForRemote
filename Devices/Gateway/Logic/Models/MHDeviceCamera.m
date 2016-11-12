//
//  MHDeviceCamera.m
//  MiHome
//
//  Created by ayanami on 8/20/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHDeviceCamera.h"
#import "MHScenePushHandler.h"
#import "MHDevListManager.h"
#import "MHGatewayScenePushChildHandler.h"

@interface MHDeviceCamera ()



@end

@implementation MHDeviceCamera
- (id)initWithData:(MHDataDevice* )data {
    if (self = [super initWithData:data]) {
        self.deviceBindPattern = MHDeviceBind_WithoutCheck;
        self.isNeedAutoBindAfterDiscovery = YES;
        self.isCanControlWhenOffline = YES;
        self.udid = nil;
    }
    return self;
}
+ (void)load {
    [MHDevListManager registerDeviceModelId:DeviceModelCamera className:NSStringFromClass([MHDeviceCamera class]) isRegisterBase:YES];
    //push
    [[MHScenePushHandler sharedInstance] registerScenePushDelegate:[MHGatewayScenePushChildHandler new]];
}


+ (NSUInteger)getDeviceType {
    return MHDeviceType_Gateway;
}

+ (NSString* )largeIconNameOfStatus:(MHDeviceStatus)status {
    return @"device_icon_gateway";
}

+ (NSString* )smallIconName {
    return @"device_icon_gateway";
}

+ (NSString* )guideImageNameOfOnline:(BOOL)isOnline {
    return isOnline ? @"device_icon_gateway" : @"device_icon_gateway";
}

+ (NSString* )guideLargeImageNameOfOnline:(BOOL)isOnline {
    return [self guideImageNameOfOnline:isOnline];
}

+ (NSString* )shareImageName {
    return @"device_icon_gateway";
}

+ (BOOL)isDeviceAllowedToShown {
    return YES;
}

+ (NSString* )getViewControllerClassName {
    return @"MHLumiCameraControlPanelViewController";
//    return @"MHCameraDemoViewController";
}

+ (NSString* )uapWifiNamePrefix:(BOOL)isNewVersion {
    if (isNewVersion) {
        return @"Mi-Smart Home Kits";
    } else {
        return @"lumi-camera";
    }
}
- (NSString* )lightStatusAfterReset {
    return NSLocalizedStringFromTable(@"devcnnt.checklight.status.flicker.red", @"plugin_gateway", "红灯闪烁中");
}

- (NSString *)defaultName {
//    return NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.acpartner", @"plugin_gateway", nil);
    return @"绿米摄像头";
}


- (void)setVideoParams:(NSString *)toggle Success:(SucceedBlock)success failure:(FailedBlock)failure {
    NSDictionary *payload = [self requestPayloadWithMethodName:@"set_video" value:@[ toggle, self.UID ?: @"FDPUBD5CK1VM8N6GY1C1"  ]];
    [self sendPayload:payload success:^(id obj) {
        if (success) success(obj);

    } failure:^(NSError *error) {
        if (failure) failure(error);

    }];
}

#pragma mark - 获取UID
//[obj[@"result"] firstObject]
- (void)getUidSuccess:(void(^)(NSString *udid,NSString *password))success failure:(FailedBlock)failure {
    if (_udid && _password){
        success(_udid,_password);
        return;
    }
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
              success:(void (^)(MHDeviceCamera *deviceCamera, MHLumiDeviceCameraMode mode))success
              failure:(FailedBlock)failure{
    self.OperatingMode = mode;
    if (success) {
        success(self, mode);
    }
    return;
    
    
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
    __weak typeof(self) weakself = self;
    [self sendPayload:payload success:^(id obj) {
        NSLog(@"%@",obj);
        NSArray<NSString *> *resultArray = [obj valueForKey:@"result"];
        if ([resultArray.firstObject isEqualToString:@"ok"]){
            weakself.OperatingMode = mode;
            if (success) {
                success(self, mode);
            }
#warning 解析格式不知道
        }else{
            if (failure) failure(nil);
        }
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

#pragma mark - 获取鱼眼校正的中心点偏移量
- (void)fetchCameraCenterPointOffsetSuccess:(void (^)(MHDeviceCamera *client))success failure:(void (^)(NSError *))failure{
    NSString *methodName = @"get_feccal";
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    payload[@"id"] = @([self getRPCNonce]);
    payload[@"method"] = methodName;
    payload[@"params"] = @[self.did];
    NSLog(@"%@",payload);
    __weak typeof(self) weakself = self;
    
    weakself.centerPointOffsetX = 28;
    weakself.centerPointOffsetY = 5;
    weakself.centerPointOffsetR = -80;
    if (success) success(nil);
    return;
    
//    [self sendPayload:payload success:^(id obj) {
//        NSLog(@"%@",obj);
//        NSArray<NSString *> *resultArray = [obj valueForKey:@"result"];
//        if ([resultArray.firstObject isEqualToString:@"ok"]){
//            weakself.centerPointOffsetX = 28;
//            weakself.centerPointOffsetY = 5;
//            weakself.centerPointOffsetR = -80;
//            if (success) success(obj);
//        }else{
//            if (failure) failure(nil);
//        }
//    } failure:^(NSError *error) {
//        if (failure) failure(error);
//    }];
}

#pragma mark - 图像反转
- (void)cameraOverturnWithSuccess:(void (^)(MHDeviceCamera *client))success failure:(void (^)(NSError *))failure{
    if (success) success(nil);
    return;
    
//    NSString *methodName = @"get_feccal";
//    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
//    payload[@"id"] = @([self getRPCNonce]);
//    payload[@"method"] = methodName;
//    payload[@"params"] = @[self.did];
//    NSLog(@"%@",payload);
//    __weak typeof(self) weakself = self;
//    
//    weakself.centerPointOffsetX = 28;
//    weakself.centerPointOffsetY = 5;
//    weakself.centerPointOffsetR = -80;
//    if (success) success(nil);
//    return;
}

@end
