//
//  MHDeviceGatewaySensorNatgas.m
//  MiHome
//
//  Created by ayanami on 16/5/30.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewaySensorNatgas.h"
#import "MHLMDecimalBinaryTools.h"
#import "MHLumiSensorSelfCheckEnableRequest.h"
#import "MHLumiSensorSelfCheckEnableResponse.h"
#import "MHLumiSensorSelfCheckStatusRequest.h"
#import "MHLumiSensorSelfCheckStatusResponse.h"
#define kSelfTest   @"03010000"
#define kHigh       @"04010000"
#define kMiddle     @"04020000"
#define kLow        @"04030000"

@implementation MHDeviceGatewaySensorNatgas

- (id)initWithData:(MHDataDevice* )data {
    if (self = [super initWithData:data]) {
    }
    return self;
}

+ (void)load {
    [MHDevListManager registerDeviceModelId:DeviceModelgateWaySensorNatgasV1
                                  className:NSStringFromClass([MHDeviceGatewaySensorNatgas class])
                             isRegisterBase:YES];
}

+ (NSUInteger)getDeviceType {
    return MHDeviceType_GatewaySensorSwitch;
}

+ (NSString* )largeIconNameOfStatus:(MHDeviceStatus)status {
    return @"device_icon_natgas";
}

+ (NSString* )getBatteryCategory {
    return @"CR2032";
}

+ (NSString* )getBatteryChangeGuideUrl {
    return Battery_Change_Guide_Switch;
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


+ (NSString* )getViewControllerClassName {
    return @"MHGatewayNatgasViewController";
}
//是否在主app快联页显示
- (BOOL)isShownInQuickConnectList {
    return NO;
}

#pragma mark - 获取首页展示图片
- (UIImage *)updateMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    UIImage *custom = [super updateMainPageSensorIconWithService:service];
    if(!custom){
        return [UIImage imageNamed:@"home_natgas_on"];
    }
    return custom;
}

- (UIImage *)getMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    UIImage *custom = [super getMainPageSensorIconWithService:service];
    if(!custom){
        return [UIImage imageNamed:@"home_natgas_on"];
    }
    return custom;
}


- (void)setPrivateProperty:(Natgas_Prop_Id)propid value:(id)value success:(SucceedBlock)success failure:(FailedBlock)failure {
    if (propid == SELFTEST_ENABLE_INDEX){
        MHLumiSensorSelfCheckEnableRequest *request = [MHLumiSensorSelfCheckEnableRequest new];
        request.did = self.did;
        request.enable = [value boolValue];
        XM_WS(weakself);
        [[MHNetworkEngine sharedInstance] sendRequest:request success:^(id obj) {
            MHLumiSensorSelfCheckEnableResponse *rep = [MHLumiSensorSelfCheckEnableResponse responseWithJSONObject:obj];
            NSLog(@"rep = %ld",(long)rep.code);
            NSLog(@"rep = %@",rep.message);
            weakself.selfcheckEnable = [value boolValue];
            if (success){
                success(obj);
            }
        } failure:^(NSError *error) {
            NSLog(@"error: %@",error);
            failure(error);
        }];
        return;
    }
    
    NSString *strHex = nil;

    switch (propid) {
        case SELFTEST_INDEX:
            strHex = kSelfTest;
            break;
        case HIGH_INDEX:
            strHex = kHigh;
            break;
        case MIDDLE_INDEX:
            strHex = kMiddle;
            break;
        case LOW_INDEX:
            strHex = kLow;
            break;
            
        default:
            break;
    }
    uint32_t test = (uint32_t)strtoul([strHex UTF8String], 0, 16);
    NSMutableDictionary* jason = [[NSMutableDictionary alloc] init];
    [jason setObject:@( [self getRPCNonce] ) forKey:@"id"];
//    [jason setObject:@( nonce++ ) forKey:@"id"];
    [jason setObject:@"set_device_prop" forKey:@"method"];
    [jason setObject:@{ @"sid":self.did, @"write_info": @(test) } forKey:@"params"];

    XM_WS(weakself);
    [self sendPayload:jason success:^(id respObj) {
        NSLog(@"%@", respObj);
        if ([[[respObj[@"result"] firstObject] stringValue] isEqualToString:@"ok"]) {
            if (propid != SELFTEST_INDEX) {
                weakself.sensitivity = propid;
                [weakself saveStatus];
            }
        }
        if (success) success(respObj);

    } failure:^(NSError *error) {
        NSLog(@"%@", error);
        if (failure) failure(error);
    }];
}
- (void)getPrivateProperty:(Natgas_Prop_Id)propid success:(SucceedBlock)success failure:(FailedBlock)failure {
    XM_WS(weakself);
    
    if (propid == SELFTEST_ENABLE_INDEX){
        MHLumiSensorSelfCheckStatusRequest *request = [MHLumiSensorSelfCheckStatusRequest new];
        request.did = self.did;
        //        XM_WS(weakself);
        [[MHNetworkEngine sharedInstance] sendRequest:request success:^(id obj) {
            MHLumiSensorSelfCheckStatusResponse *rep = [MHLumiSensorSelfCheckStatusResponse responseWithJSONObject:obj];
            NSLog(@"rep = %ld",(long)rep.code);
            NSLog(@"rep = %@",rep.message);
            weakself.selfcheckEnable = rep.enable;
            if (success){
                success(obj);
            }
        } failure:^(NSError *error) {
            NSLog(@"error: %@",error);
            failure(error);
        }];
        return;
    }
    NSDictionary *payload = [self requestPayloadWithMethodName:@"get_device_prop" value:@[ self.did, @"read_info" ]];

    [self sendPayload:payload success:^(id respObj) {
        NSLog(@"%@", respObj);
        if (!([[respObj[@"result"] firstObject] isKindOfClass:[NSString class]] && [[respObj[@"result"] firstObject] isEqualToString:@"waiting"])) {
            //72620544259850240 正常数据
            //waiting  睡眠中
            
            /*
             code = 0;
             message = ok;
             result =     (
             0,
             1292,
             off,
             off,
             3,
             6,
             34,
             "<null>",
             "<null>",
             off,
             300,
             1090530815,
             1473241580,
             on,
             "<null>"
             );
             */
            NSString *strProp = [MHLMDecimalBinaryTools decimalToHex:[[respObj[@"result"] firstObject] integerValue]];
                    NSLog(@"%@", strProp);//102000010010000
            if (strProp.length < 3) {
                if (failure) failure(nil);
                return;
            }
            NSString *sens = [strProp substringWithRange:NSMakeRange(2, 1)];
                    NSLog(@"%@", sens);
            weakself.sensitivity = (Natgas_Prop_Id)[sens integerValue];
            [weakself saveStatus];
            //        uint32_t value = (uint32_t)strtoul([strHex UTF8String], 0, 16);
            //2 02 00 00 10 01 00 00
        }
        if (success) success(respObj);
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
        if (failure) failure(error);
    }];
}



- (void)saveStatus {
    [[NSUserDefaults standardUserDefaults] setObject:@(self.sensitivity) forKey:[NSString stringWithFormat:@"sensitivity%@_%@",self.did, [MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)readStatus {
    self.sensitivity = (Natgas_Prop_Id)[[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"sensitivity%@_%@",self.did, [MHPassportManager sharedSingleton].currentAccount.userId]] integerValue];
}

- (void)asdf{
    
}
@end
