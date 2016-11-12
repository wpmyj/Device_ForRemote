//
//  MHDeviceGatewaySensorSwitch.m
//  MiHome
//
//  Created by Woody on 15/4/2.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewaySensorSwitch.h"

#define kFAQEN @"https://app-ui.aqara.cn/faq/ios-en/mp5WirelessSwitch.html"
#define kFAQCN @"https://app-ui.aqara.cn/faq/ios-cn/mp5WirelessSwitch.html"

@implementation MHDeviceGatewaySensorSwitch
- (id)initWithData:(MHDataDevice* )data {
    if (self = [super initWithData:data]) {
    }
    return self;
}

+ (void)load {
    [MHDevListManager registerDeviceModelId:DeviceModelgateWaySensorSwitchV1
                                  className:NSStringFromClass([MHDeviceGatewaySensorSwitch class])
                             isRegisterBase:YES];
}

+ (NSUInteger)getDeviceType {
    return MHDeviceType_GatewaySensorSwitch;
}

- (BOOL)isSetAlarming {
    if ([self.bindList count] <= 0) {
        return NO;
    }
    
    for (MHLumiBindItem* item in self.bindList) {
        if ([item.from_sid isEqualToString:self.did] &&
            [item.method isEqualToString:Method_Alarm] &&
            [item.event isEqualToString:Gateway_Event_Switch_Click]
            ) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isSetAlarmClock {
    if ([self.bindList count] <= 0) {
        return NO;
    }
    
    for (MHLumiBindItem* item in self.bindList) {
        if ([item.from_sid isEqualToString:self.did] &&
            [item.method isEqualToString:Method_StopClockMusic] &&
            [item.event isEqualToString:Gateway_Event_Switch_Click]
            ) {
            return YES;
        }
    }
    return NO;
}

//是否设置了"按键一次"的门铃
- (BOOL)isSetDoorBell {
    if ([self.bindList count] <= 0) {
        return NO;
    }
    
    for (MHLumiBindItem* item in self.bindList) {
        if ([item.from_sid isEqualToString:self.did] &&
            [item.method isEqualToString:Method_Door_Bell] &&
            [item.event isEqualToString:Gateway_Event_Switch_Click]
            ) {
            return YES;
        }
    }
    
    return NO;
}

//是否设置了"按键两次"的门铃
- (BOOL)isSetDoorBellForDoubleClick {
    if ([self.bindList count] <= 0) {
        return NO;
    }
    
    for (MHLumiBindItem* item in self.bindList) {
        if ([item.from_sid isEqualToString:self.did] &&
            [item.method isEqualToString:Method_Welcome] &&
            [item.event isEqualToString:Gateway_Event_Switch_Double_Click]
            ) {
            return YES;
        }
    }
    
    return NO;
}


//如果设置了按键一次响门铃，则不能按键一次警戒
- (BOOL)bindSwitchAlarmAndDoorbellConfictSearch {
    //去检查是否绑定了door_bell       //是否绑定了alarm
    if([self bindDoorBellCheck] && [self bindAlarmCheck]){
        return YES;
    }
    return NO;
}

//检查某个did，是否绑定了door_bell，method；Gateway_Event_Switch_Click
- (BOOL)bindAlarmCheck {
    for(MHLumiBindItem* item in self.bindList){
        if ([item.from_sid isEqualToString:self.did] &&
            [item.method isEqualToString:Method_Alarm] &&
            [item.event isEqualToString:Gateway_Event_Switch_Click]
            ){
            return YES;
        }
    }
    return NO;
}

//检查某个did，是否绑定了alarm，method；Gateway_Event_Switch_Click
- (BOOL)bindDoorBellCheck {
    for(MHLumiBindItem* item in self.bindList){
        if ([item.from_sid isEqualToString:self.did] &&
            [item.method isEqualToString:Method_Door_Bell] &&
            [item.event isEqualToString:Gateway_Event_Switch_Click]
            ){
            return YES;
        }
    }
    return NO;
}

- (NSString* )eventNameOfSetAlarming {
    return Gateway_Event_Switch_Click;
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

- (NSInteger)category
{
    return MHDeviceCategoryZigbee;
}

- (NSString*)defaultName {
    return NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.switch", @"plugin_gateway", nil);
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

@end
