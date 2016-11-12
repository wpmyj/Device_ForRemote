//
//  MHDevicePlugMini.m
//  MiHome
//
//  Created by Woody on 14/11/14.
//  Copyright (c) 2014年 小米移动软件. All rights reserved.
//

#import "MHDevicePlugMini.h"
#import <MiHomeKit/MHTimeUtils.h>
#import <MiHomeKit/MHGetDeviceSceneNewRequest.h>
#import <MiHomeKit/MHGetDeviceSceneNewResponse.h>
#import <MiHomeKit/MHEditDeviceSceneNewRequest.h>
#import <MiHomeKit/MHEditDeviceSceneNewResponse.h>
#import "MHDevListManager.h"

@implementation MHDevicePlugMini
+ (instancetype)deviceWithData:(MHDataDevice* )data {
    MHDevicePlugMini* plug = [[MHDevicePlugMini alloc] initWithData:data];
    return plug;
}

- (id)initWithData:(MHDataDevice* )data {
    if (self = [super initWithData:data]) {
        if (self.prop) {
            self.isOpen = [[[self.prop objectForKey:@"power"] stringValue] isEqualToString:@"on"];
        }
        self.deviceBindPattern = MHDeviceBind_WithoutCheck;
        self.isNeedAutoBindAfterDiscovery = YES;
        self.deviceConnectPattern = MHDeviceConnect_Both;
        self.firmwareVersionType = MHDeviceFirmwareVersionType_New;
        self.lightType = MHDeviceLightType_OneColor;
        self.permissionControl = 1;
        self.wexinShare = 1;
    }
    return self;
}

+ (void)load {
    [MHDevListManager registerDeviceModelId:DeviceModelPlugMini className:NSStringFromClass([MHDevicePlugMini class]) isRegisterBase:YES];
}

+ (NSUInteger)getDeviceType {
    return MHDeviceType_Plug;
}

+ (NSString* )largeIconNameOfStatus:(MHDeviceStatus)status {
    return @"device_icon_plug_mini";
}

+ (NSString* )smallIconName {
    return @"device_plug_small_icon";
}
+ (NSString* )guideImageNameOfOnline:(BOOL)isOnline {
    return isOnline ? @"device_guide_plug_on" : @"device_guide_plug_off";
}
+ (NSString* )guideLargeImageNameOfOnline:(BOOL)isOnline {
    return isOnline ? @"device_guide_large_plug_on" : @"device_guide_large_plug_off";
}
+ (NSString* )shareImageName {
    return @"device_share_plug";
}

+ (NSString* )defaultName {
    return NSLocalizedString(@"plugMini","小米插座基础版");
}

+ (BOOL)isDeviceAllowedToShown {
    return YES;
}

- (BOOL)isShownInQuickConnectList {
    return NO;
}

+ (NSString* )getViewControllerClassName {
    return @"MHPlugMiniViewController";
}

+ (NSString* )uapWifiNamePrefix:(BOOL)isNewVersion {
    if (isNewVersion) {
        return @"MI-Socket";
    } else {
        return @"chuangmi-plug";
    }
}

+ (NSString* )quickConnectGuideVideoUrl {
    return @"http://v.youku.com/v_show/id_XODU2NDA2OTIw.html";
}

#pragma mark - 插座控制

- (NSString* )getOnlineStatusDescription {
    NSString* on = NSLocalizedString(@"mydevice.label.open","开");
    NSString* off = NSLocalizedString(@"mydevice.label.close","关");
    NSString* onlineStatus;
    if (self.isOpen) {
        onlineStatus = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"mydevice.label.plug","插座"), on];
    }else {
        onlineStatus = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"mydevice.label.plug","插座"), off];
    }
    
    return onlineStatus;
}

- (NSDictionary* )getStatusRequestPayload {
    NSMutableDictionary* jason = [[NSMutableDictionary alloc] init];
    [jason setObject:@"get_prop" forKey:@"method"];
    [jason setObject:@[@"power", @"temperature"] forKey:@"params"];
    return jason;
}

- (NSArray *)propertiesForSubscription {
        NSArray* properties = [[NSArray alloc] initWithObjects:@"power", @"temperature", nil];
    return properties;
}

- (BOOL)parseGetStatusResponse:(id)response {
    MHDeviceRPCResponse* rsp = [MHDeviceRPCResponse responseWithJSONObject:response];
    if (rsp.code == MHNetworkErrorOk) {
        if ([rsp.resultList count] == 2) {// 小插座做2个值
            self.isOpen = [[rsp.resultList[0] stringValue] isEqualToString:@"on"];
            self.temperature = [rsp.resultList[1] integerValue];
            return YES;
        }
    }
    return NO;
}

- (NSDictionary* )powerOnRequestPayload:(BOOL)on {
    NSMutableDictionary* jason = [[NSMutableDictionary alloc] init];
    [jason setObject:@"set_power" forKey:@"method"];
    if (on) {
        [jason setObject:@[@"on"] forKey:@"params"];
    } else {
        [jason setObject:@[@"off"] forKey:@"params"];
    }
    
    return jason;
}

- (void)parsePowerOnResponse:(id)response isOn:(BOOL)isOn {
    MHDeviceRPCResponse* rsp = [MHDeviceRPCResponse responseWithJSONObject:response];
    if (rsp.code == MHNetworkErrorOk) {
        self.isOpen = isOn;
    }
}

- (void)bind {
    
}

//#pragma mark - 定时
//- (void)editTimer:(MHDataDeviceTimer *)timer success:(SucceedBlock)success failure:(FailedBlock)failure
//{
//    MHEditDeviceSceneNewRequest* req = [[MHEditDeviceSceneNewRequest alloc] init];
//    
//    MHDataSceneNew *scene = [[MHDataSceneNew alloc] init];
//    scene.us_id = timer.timerId;
//    scene.identify = self.did;
//    scene.name = self.name;
//    scene.st_id = @"8";
//    scene.authed = @[self.did];
//    scene.did = self.did;
//    
//    MHDataDeviceTimer* dstTimer = [timer copy];
//    [dstTimer changeTimeToBeijingZone];
//    id onParam = dstTimer.onParam;
//    if ([onParam isKindOfClass:[NSArray class]] && [onParam count] == 1) {
//        onParam = onParam[0];
//    }
//    id offParam = dstTimer.offParam;
//    if ([offParam isKindOfClass:[NSArray class]] && [offParam count] == 1) {
//        offParam = offParam[0];
//    }
//    
//    NSDictionary* setting = [NSDictionary dictionaryWithObjectsAndKeys:
//                             @"0",@"enable_push",
//                             (dstTimer.isEnabled?@"1":@"0"),@"enable_timer",
//                             [dstTimer getCrontabStringOfPowerOn:YES],@"on_time",
//                             (dstTimer.isOnOpen?@"1":@"0"),@"enable_timer_on",
//                             [dstTimer getCrontabStringOfPowerOn:NO],@"off_time",
//                             (dstTimer.isOffOpen?@"1":@"0"),@"enable_timer_off",
//                             dstTimer.onMethod, @"on_method",
//                             dstTimer.offMethod, @"off_method",
//                             onParam, @"on_param",
//                             offParam, @"off_param",
//                             nil];
//    
//    scene.setting = setting;
//    req.scene = scene;
//    
//    [[MHNetworkEngine sharedInstance] sendRequest:req success:^(id obj) {
//        MHEditDeviceSceneNewResponse* rsp = [MHEditDeviceSceneNewResponse responseWithJSONObject:obj];
//        if (rsp.code == MHNetworkErrorOk) {
//            timer.timerId = rsp.usId;
//            timer.status = rsp.status;
//            if (success) {
//                success(rsp);
//            }
//        } else {
//            if (failure) {
//                failure([NSError errorWithDomain:MHNetworkErrorDomain_Remote code:rsp.code userInfo:nil]);
//            }
//        }
//        
//    } failure:^(NSError *error) {
//        if (failure) {
//            failure(error);
//        }
//    }];
//}
//
//- (void)deleteTimer:(MHDataDeviceTimer* )timer success:(SucceedBlock)success failure:(FailedBlock)failure
//{
//    [self deleteTimerId:timer.timerId success:success failure:failure];
//}

@end