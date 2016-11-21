//
//  MHDeviceGatewaySensorDoorLock.m
//  MiHome
//
//  Created by LM21Mac002 on 16/10/15.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewaySensorDoorLock.h"
#define kFAQEN @"https://app-ui.aqara.cn/faq/ios-en/mp5WirelessSwitch.html"
#define kFAQCN @"https://app-ui.aqara.cn/faq/ios-cn/mp5WirelessSwitch.html"

@interface MHDeviceGatewaySensorDoorLock()
@property (nonatomic, assign) MHDeviceGatewaySensorDoorLockModel doorLockModel;
@end

@implementation MHDeviceGatewaySensorDoorLock
- (id)initWithData:(MHDataDevice* )data {
    if (self = [super initWithData:data]) {
        _doorLockModel = MHDeviceGatewaySensorDoorLockModelUnknown;
    }
    return self;
}

+ (void)load {
    [MHDevListManager registerDeviceModelId:DeviceModelgateWaySensorDoorLock
                                  className:NSStringFromClass([MHDeviceGatewaySensorDoorLock class])
                             isRegisterBase:YES];
}

#warning 以后修改
+ (NSUInteger)getDeviceType {
    return MHDeviceType_GatewaySensorSwitch;
}

#warning 以后修改
- (NSString* )eventNameOfSetAlarming {
    return Gateway_Event_Switch_Click;
}

+ (NSString *)getViewControllerClassName{
    return @"MHGatewayDoorLockViewController";
}

+ (NSString* )largeIconNameOfStatus:(MHDeviceStatus)status {
    return @"device_icon_gateway_switcher";
}

+ (NSString* )getBatteryCategory {
    return @"CR2032";
}

+ (NSString* )getBatteryChangeGuideUrl {
    return Battery_Change_Guide_Switch;
}

+ (NSString *)getFAQUrl {
    NSString *url = nil;
    NSString *currentLanguage = [[MHLumiHtmlHandleTools sharedInstance] currentLanguage];
    if ([currentLanguage hasPrefix:@"zh-Hans"]) {
        url = kFAQCN;
    }
    else {
        url = kFAQEN;
    }
    return url;
}

+ (NSString* )offlineTips {
    return NSLocalizedStringFromTable(@"mydevice.gateway.switch.offlineview.tips",@"plugin_gateway","请尝试");
}

+ (BOOL)isDeviceAllowedToShown {
    return YES;
}

//是否在主app快联页显示
- (BOOL)isShownInQuickConnectList {
    return NO;
}

- (NSInteger)category
{
    return MHDeviceCategoryZigbee;
}

- (NSString*)defaultName {
    return @"动静贴";
}

#pragma mark - 获取首页展示图片
- (UIImage *)updateMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    UIImage *custom = [super updateMainPageSensorIconWithService:service];
    if(!custom){
        return [UIImage imageNamed:@"gateway_switch_click"];
    }
    return custom;
}

- (UIImage *)getMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    UIImage *custom = [super getMainPageSensorIconWithService:service];
    if(!custom){
        return [UIImage imageNamed:@"gateway_switch_click"];
    }
    return custom;
}

#pragma mark - 配置工作模式
- (void)setDoorLockModel:(MHDeviceGatewaySensorDoorLockModel)doorLockModel
             withSuccess:(void (^)())success
                 failure:(void (^)(NSError *))failure{
    NSString *method = @"set_device_prop";
    NSInteger model = doorLockModel;
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@( [self getRPCNonce] ) forKey:@"id"];
    [dic setObject:method forKey:@"method"];

    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:self.did forKey:@"sid"];
    [paramsDic setObject:@(model) forKey:@"work_mode"];
    [dic setObject:paramsDic forKey:@"params"];
    __weak typeof(self) weakself = self;
    [self sendPayload:dic success:^(id result) {
        NSLog(@"result = %@ ", result);
        NSString *message = [result objectForKey:@"message"];
        if ([message isEqualToString:@"ok"] && success){
            weakself.doorLockModel = doorLockModel;
            if (success) {
                success();
            }
        }else{
            if (failure) {
                failure(nil);
            }
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];

}

- (void)fetchDoorLockModelwithSuccess:(void (^)(MHDeviceGatewaySensorDoorLock *))success failure:(void (^)(NSError *))failure{
    NSString *method = @"get_device_prop";
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@( [self getRPCNonce] ) forKey:@"id"];
    [dic setObject:method forKey:@"method"];
    
    [dic setObject:@[self.did,@"work_mode"] forKey:@"params"];
    __weak typeof(self) weakself = self;
    [self sendPayload:dic success:^(id result) {
        NSLog(@"result = %@ ", result);
        NSString *message = [result objectForKey:@"message"];
        if ([message isEqualToString:@"ok"] && success){
            weakself.doorLockModel = MHDeviceGatewaySensorDoorLockModelSafeGuard;
            if (success) {
                success(weakself);
            }
        }else{
            if (failure) {
                failure(nil);
            }
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}
@end
