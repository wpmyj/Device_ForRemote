//
//  MHDevicePlug.m
//  MiHome
//
//  Created by Woody on 14/11/14.
//  Copyright (c) 2014年 小米移动软件. All rights reserved.
//

#import "MHDevicePlug.h"
#import <MiHomeKit/MHTimeUtils.h>
#import "MHDevListManager.h"
#import "MHTimerSettingManager.h"

@implementation MHDevicePlug
{
    MHTimerSettingManager* _timerManager;
}
+ (instancetype)deviceWithData:(MHDataDevice* )data {
    MHDevicePlug* plug = [[MHDevicePlug alloc] initWithData:data];
    return plug;
}

- (id)initWithData:(MHDataDevice* )data {
    if (self = [super initWithData:data]) {
        if (self.prop) {
            self.isUsbOn = [[self.prop objectForKey:@"usb_on"] boolValue];
        }
        self.deviceBindPattern = MHDeviceBind_WithoutCheck;
        self.isNeedAutoBindAfterDiscovery = YES;
        self.deviceConnectPattern = MHDeviceConnect_Both;
        self.permissionControl = 1;
        self.wexinShare = 1;
        _timerManager = [MHTimerSettingManager sharedInstance];
        _timerManager.device = self;
    }
    return self;
}

+ (void)load {
    [MHDevListManager registerDeviceModelId:DeviceModelPlug className:NSStringFromClass([MHDevicePlug class]) isRegisterBase:YES];
}

+ (NSUInteger)getDeviceType {
    return MHDeviceType_Plug;
}

+ (NSString* )largeIconNameOfStatus:(MHDeviceStatus)status {
    return @"device_icon_plug";
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
    return NSLocalizedString(@"plug","小米智能插座");
}

+ (BOOL)isDeviceAllowedToShown {
    return YES;
}

+ (NSString* )getViewControllerClassName {
    return @"MHPlugViewController";
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
    if (self.isUsbOn) {
        onlineStatus = [onlineStatus stringByAppendingString:[NSString stringWithFormat:@" %@%@", NSLocalizedString(@"mydevice.label.plug.usb","USB"), on]];
    } else {
        onlineStatus = [onlineStatus stringByAppendingString:[NSString stringWithFormat:@" %@%@", NSLocalizedString(@"mydevice.label.plug.usb","USB"), off]];
    }
    
    return onlineStatus;
}

- (NSDictionary* )getStatusRequestPayload {
    NSMutableDictionary* jason = [[NSMutableDictionary alloc] init];
    [jason setObject:@"get_prop" forKey:@"method"];
    [jason setObject:@[@"on", @"usb_on", @"temperature"] forKey:@"params"];
    return jason;
}

- (NSArray *)propertiesForSubscription {
    NSArray* properties = [[NSArray alloc] initWithObjects:@"on", @"usb_on", @"temperature", nil];
    
    return properties;
}

- (BOOL)parseGetStatusResponse:(id)response {
    MHDeviceRPCResponse* rsp = [MHDeviceRPCResponse responseWithJSONObject:response];
    if (rsp.code == MHNetworkErrorOk) {
        if ([rsp.resultList count] == 3) { // 大插座3值
            self.isOpen = [rsp.resultList[0] boolValue];
            self.isUsbOn = [rsp.resultList[1] boolValue];
            self.temperature = [rsp.resultList[2] integerValue];
            return YES;
        }
    }
    return NO;
}

- (NSDictionary* )powerOnRequestPayload:(BOOL)on {
    NSMutableDictionary* jason = [[NSMutableDictionary alloc] init];
    if (on) {
        [jason setObject:@"set_on" forKey:@"method"];
    } else {
        [jason setObject:@"set_off" forKey:@"method"];
    }
    [jason setObject:@[] forKey:@"params"];
    return jason;
}

- (void)parsePowerOnResponse:(id)response isOn:(BOOL)isOn {
    MHDeviceRPCResponse* rsp = [MHDeviceRPCResponse responseWithJSONObject:response];
    if (rsp.code == MHNetworkErrorOk) {
        self.isOpen = isOn;
    }
}

- (NSDictionary* )powerOnUsbRequestPayload:(BOOL)on {
    NSMutableDictionary* jason = [[NSMutableDictionary alloc] init];
    if (on) {
        [jason setObject:@"set_usb_on" forKey:@"method"];
    } else {
        [jason setObject:@"set_usb_off" forKey:@"method"];
    }
    [jason setObject:@[] forKey:@"params"];
    return jason;
}

- (void)bind {
    
}

- (void)powerOnUsb:(BOOL)isOn success:(void(^)(id))success failure:(void(^)(NSError*))failure {
    
    [self sendPayload:[self powerOnUsbRequestPayload:isOn] success:^(id respObj) {
        MHDeviceRPCResponse* rsp = [MHDeviceRPCResponse responseWithJSONObject:respObj];
        if (rsp.code == MHNetworkErrorOk) {
            self.isUsbOn = isOn;
        }
        if (success) {
            success(rsp);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)setTimerList:(NSDictionary* )timerList success:(SucceedBlock)success failure:(FailedBlock)failure {
    NSMutableArray* powerTimerListSrc = [timerList objectForKey:@"Power"];
    NSMutableArray* usbPowerTimerListSrc = [timerList objectForKey:@"Usb"];
    
    if (self.oldPowerTimer) {    //有旧的Timer
        if ([powerTimerListSrc containsObject:self.oldPowerTimer]) {
            //新的列表中有它，证明用户要么修改了它，要么没修改
            //那么需要从新的列表中删除掉它，否则就重复了
            [powerTimerListSrc removeObject:self.oldPowerTimer];
        } else {
            //新的列表中没有它，证明用户删除掉了
            self.oldPowerTimer = nil;
        }
    }
//    else {    //没有旧的Timer
//        if ([powerTimerList count] > 0) {
//            self.oldPowerTimer = powerTimerList[0];
//            [powerTimerList removeObjectAtIndex:0];
//        }
//    }
    
    if (self.oldUsbPowerTimer) {
        if ([usbPowerTimerListSrc containsObject:self.oldUsbPowerTimer]) {
            //新的列表中有它，证明用户要么修改了它，要么没修改
            //那么需要从新的列表中删除掉它，否则就重复了
            [usbPowerTimerListSrc removeObject:self.oldUsbPowerTimer];
        } else {
            //新的列表中没有它，证明用户删除掉了
            self.oldUsbPowerTimer = nil;
        }
    }
//    else {
//        if ([usbPowerTimerList count] > 0) {
//            self.oldUsbPowerTimer = usbPowerTimerList[0];
//            [usbPowerTimerList removeObjectAtIndex:0];
//        }
//    }

    /**
     * 改变定时的时区
     */
    NSMutableArray* powerTimerList = [NSMutableArray arrayWithCapacity:[powerTimerListSrc count]];
    NSMutableArray* usbPowerTimerList = [NSMutableArray arrayWithCapacity:[usbPowerTimerListSrc count]];
    MHDataDeviceTimer* oldPowerTimer = nil;
    MHDataDeviceTimer* oldUsbPowerTimer = nil;
    for (MHDataDeviceTimer* timer in powerTimerListSrc) {
        MHDataDeviceTimer* dstTimer = [timer copy];
        [dstTimer changeTimeToBeijingZone];
        [powerTimerList addObject:dstTimer];
    }
    for (MHDataDeviceTimer* timer in usbPowerTimerListSrc) {
        MHDataDeviceTimer* dstTimer = [timer copy];
        [dstTimer changeTimeToBeijingZone];
        [usbPowerTimerList addObject:dstTimer];
    }
    if (self.oldPowerTimer) {
        oldPowerTimer = [self.oldPowerTimer copy];
        [oldPowerTimer changeTimeToBeijingZone];
    }
    if (self.oldUsbPowerTimer) {
        oldUsbPowerTimer = [self.oldUsbPowerTimer copy];
        [oldUsbPowerTimer changeTimeToBeijingZone];
    }
    
    /**
     * 发请求
     */
    MHSetDeviceSceneRequest* req = [[MHSetDeviceSceneRequest alloc] init];
    req.identify = self.did;
    req.name = self.name;
    req.st_id = @"2";
    req.authed = [NSArray arrayWithObject:self.did];
    
    NSMutableArray* powerEnable = [[NSMutableArray alloc] init];
    NSMutableArray* powerOnTime = [[NSMutableArray alloc] init];
    NSMutableArray* powerOnEnable = [[NSMutableArray alloc] init];
    NSMutableArray* powerOffTime = [[NSMutableArray alloc] init];
    NSMutableArray* powerOffEnable = [[NSMutableArray alloc] init];
    NSMutableArray* usbEnable = [[NSMutableArray alloc] init];
    NSMutableArray* usbPowerOnTime = [[NSMutableArray alloc] init];
    NSMutableArray* usbPowerOnEnable = [[NSMutableArray alloc] init];
    NSMutableArray* usbPowerOffTime = [[NSMutableArray alloc] init];
    NSMutableArray* usbPowerOffEnable = [[NSMutableArray alloc] init];
    for (MHDataDeviceTimer* timer in powerTimerList) {
        [powerEnable addObject:@(timer.isEnabled)];
        [powerOnTime addObject:[timer getCrontabStringOfPowerOn:YES]];
        [powerOnEnable addObject:@(timer.isOnOpen)];
        [powerOffTime addObject:[timer getCrontabStringOfPowerOn:NO]];
        [powerOffEnable addObject:@(timer.isOffOpen)];
    }
    for (MHDataDeviceTimer* timer in usbPowerTimerList) {
        [usbEnable addObject:@(timer.isEnabled)];
        [usbPowerOnTime addObject:[timer getCrontabStringOfPowerOn:YES]];
        [usbPowerOnEnable addObject:@(timer.isOnOpen)];
        [usbPowerOffTime addObject:[timer getCrontabStringOfPowerOn:NO]];
        [usbPowerOffEnable addObject:@(timer.isOffOpen)];
    }
    NSMutableDictionary* setting = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             powerEnable,@"enable_power_arr",
                             powerOnTime,@"power_on_time_arr",
                             powerOnEnable,@"enable_power_on_arr",
                             powerOffTime,@"power_off_time_arr",
                             powerOffEnable,@"enable_power_off_arr",
                             usbEnable,@"enable_usb_arr",
                             usbPowerOnTime,@"usb_on_time_arr",
                             usbPowerOnEnable,@"enable_usb_on_arr",
                             usbPowerOffTime,@"usb_off_time_arr",
                             usbPowerOffEnable,@"enable_usb_off_arr",
                             nil];
    if (oldPowerTimer) {
        [setting setValuesForKeysWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 [oldPowerTimer getCrontabStringOfPowerOn:YES],@"power_on_time",
                                                 @(self.oldPowerTimer.isOnOpen),@"enable_power_on",
                                                 [oldPowerTimer getCrontabStringOfPowerOn:NO],@"power_off_time",
                                                 @(oldPowerTimer.isOffOpen),@"enable_power_off",
                                                 nil]];
    }
    if (oldUsbPowerTimer) {
        [setting setValuesForKeysWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 [oldUsbPowerTimer getCrontabStringOfPowerOn:YES],@"usb_on_time",
                                                 @(oldUsbPowerTimer.isOnOpen),@"enable_usb_on",
                                                 [oldUsbPowerTimer getCrontabStringOfPowerOn:YES],@"usb_off_time",
                                                 @(oldUsbPowerTimer.isOffOpen),@"enable_usb_off",
                                                 nil]];
    }
    
    req.setting = setting;
    [[MHNetworkEngine sharedInstance] sendRequest:req success:^(id obj) {
        MHSetDeviceSceneResponse* rsp = [MHSetDeviceSceneResponse responseWithJSONObject:obj];
        if (rsp.code == MHNetworkErrorOk) {
            self.powerTimerList = powerTimerList;
            self.usbPowerTimerList = usbPowerTimerList;
            if (success) {
                success(rsp);
            }
        } else {
            if (failure) {
                failure([NSError errorWithDomain:MHNetworkErrorDomain_Remote code:rsp.code userInfo:nil]);
            }
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (MHDataDeviceTimer* )parsePowerTimer:(MHSafeDictionary* )data {
    NSString* powerOnTime = [data objectForKey:@"power_on_time" class:[NSString class]];
    NSString* powerOffTime = [data objectForKey:@"power_off_time" class:[NSString class]];
    NSString* powerOnEnable = [data objectForKey:@"enable_power_on" class:[NSString class]];
    NSString* powerOffEnable = [data objectForKey:@"enable_power_off" class:[NSString class]];

    if ([powerOnTime length] <= 0 ||
        [powerOffTime length] <= 0 ||
        [powerOnEnable length] <= 0 ||
        [powerOffEnable length] <= 0) {
        return nil;
    }
    MHDataDeviceTimer* timer = [MHDataDeviceTimer timerFromOnCrontabString:powerOnTime offCrontabString:powerOffTime];
    timer.isOnOpen = [powerOnEnable integerValue];
    timer.isOffOpen = [powerOffEnable integerValue];
    timer.isEnabled = YES;
    [timer changeTimeToLocalTimeZone];
    return timer;
}

- (MHDataDeviceTimer* )parseUsbPowerTimer:(MHSafeDictionary* )data {
    NSString* powerOnTime = [data objectForKey:@"usb_on_time" class:[NSString class]];
    NSString* powerOffTime = [data objectForKey:@"usb_off_time" class:[NSString class]];
    NSString* powerOnEnable = [data objectForKey:@"enable_usb_on" class:[NSString class]];
    NSString* powerOffEnable = [data objectForKey:@"enable_usb_off" class:[NSString class]];
    
    if ([powerOnTime length] <= 0 ||
        [powerOffTime length] <= 0 ||
        [powerOnEnable length] <= 0 ||
        [powerOffEnable length] <= 0) {
        return nil;
    }
    MHDataDeviceTimer* timer = [MHDataDeviceTimer timerFromOnCrontabString:powerOnTime offCrontabString:powerOffTime];
    timer.isOnOpen = [powerOnEnable integerValue];
    timer.isOffOpen = [powerOffEnable integerValue];
    timer.isEnabled = YES;
    [timer changeTimeToLocalTimeZone];
    return timer;
}

- (NSArray* )parsePowerTimerList:(MHSafeDictionary* )data {
    
    NSMutableArray* power = [[NSMutableArray alloc] init];
    if (self.oldPowerTimer) {
        [power addObject:self.oldPowerTimer];
    }
    
    NSArray* powerEnable = [data objectForKey:@"enable_power_arr" class:[NSArray class]];
    NSArray* powerOnTime = [data objectForKey:@"power_on_time_arr" class:[NSArray class]];
    NSArray* powerOffTime = [data objectForKey:@"power_off_time_arr" class:[NSArray class]];
    NSArray* powerOnEnable = [data objectForKey:@"enable_power_on_arr" class:[NSArray class]];
    NSArray* powerOffEnable = [data objectForKey:@"enable_power_off_arr" class:[NSArray class]];
    
    for (int i = 0; i < [powerOnTime count]; i++) {
        MHDataDeviceTimer* timer = [MHDataDeviceTimer timerFromOnCrontabString:powerOnTime[i] offCrontabString:powerOffTime[i]];
        if ([powerOnEnable count] >= i+1 )
            timer.isOnOpen = [powerOnEnable[i] integerValue];
        if ([powerOffEnable count] >= i+1)
            timer.isOffOpen = [powerOffEnable[i] integerValue];
        if ([powerEnable count] >= i+1)
            timer.isEnabled = [powerEnable[i] integerValue];
        [timer changeTimeToLocalTimeZone];
        [power addObject:timer];
    }
    
    return power;
}

- (NSArray* )parseUsbPowerTimerList:(MHSafeDictionary* )data {
    
    NSMutableArray* usbPower = [[NSMutableArray alloc] init];
    if (self.oldUsbPowerTimer) {
        [usbPower addObject:self.oldUsbPowerTimer];
    }
    NSArray* powerEnable = [data objectForKey:@"enable_usb_arr" class:[NSArray class]];
    NSArray* powerOnTime = [data objectForKey:@"usb_on_time_arr" class:[NSArray class]];
    NSArray* powerOffTime = [data objectForKey:@"usb_off_time_arr" class:[NSArray class]];
    NSArray* powerOnEnable = [data objectForKey:@"enable_usb_on_arr" class:[NSArray class]];
    NSArray* powerOffEnable = [data objectForKey:@"enable_usb_off_arr" class:[NSArray class]];
    
    for (int i = 0; i < [powerOnTime count]; i++) {
        MHDataDeviceTimer* timer = [MHDataDeviceTimer timerFromOnCrontabString:powerOnTime[i] offCrontabString:powerOffTime[i]];
        if ([powerOnEnable count] >= i+1 )
            timer.isOnOpen = [powerOnEnable[i] integerValue];
        if ([powerOffEnable count] >= i+1)
            timer.isOffOpen = [powerOffEnable[i] integerValue];
        if ([powerEnable count] >= i+1)
            timer.isEnabled = [powerEnable[i] integerValue];
        [timer changeTimeToLocalTimeZone];
        [usbPower addObject:timer];
    }
    
    return usbPower;
}

- (void)getTimerListWithSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    
    MHGetDeviceSceneRequest* req = [[MHGetDeviceSceneRequest alloc] init];
    req.identify = self.did;
    
    [[MHNetworkEngine sharedInstance] sendRequest:req success:^(id obj) {
        MHGetDeviceSceneResponse* rsp = [MHGetDeviceSceneResponse responseWithJSONObject:obj];
        NSLog(@"getTimerListWithSuccess list = %@", obj);
        if (rsp.code == MHNetworkErrorOk && [rsp.setting isKindOfClass:[NSDictionary class]]) {
            self.oldPowerTimer = [self parsePowerTimer:[[MHSafeDictionary alloc] initWithDictionary:rsp.setting]];
            self.oldUsbPowerTimer = [self parseUsbPowerTimer:[[MHSafeDictionary alloc] initWithDictionary:rsp.setting]];
            self.powerTimerList = [self parsePowerTimerList:[[MHSafeDictionary alloc] initWithDictionary:rsp.setting]];
            self.usbPowerTimerList = [self parseUsbPowerTimerList:[[MHSafeDictionary alloc] initWithDictionary:rsp.setting]];
            if (success) {
                success(rsp);
            }
        } else {
            if (failure) {
                failure([NSError errorWithDomain:MHNetworkErrorDomain_Remote code:rsp.code userInfo:nil]);
            }
        }

    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)saveTimerList {
    [_timerManager saveTimerList:self];
    
    [[MHPlistCacheEngine sharedEngine] asyncSave:self.usbPowerTimerList toFile:[NSString stringWithFormat:@"plugusb_timerList_%@", self.did] withFinish:nil];
}

- (void)restoreTimerListWithFinish:(void(^)(id))finish {
    [_timerManager restoreTimerListWithFinish:^(id obj) {
        [[MHPlistCacheEngine sharedEngine] asyncLoadFromFile:[NSString stringWithFormat:@"plugusb_timerList_%@", self.did] withFinish:^(id obj) {
            if ([obj isKindOfClass:[NSArray class]]) {
                self.usbPowerTimerList = obj;
            }
            
            if (finish) {
                finish(self.usbPowerTimerList);
            }
        }];
    }];
}

@end
