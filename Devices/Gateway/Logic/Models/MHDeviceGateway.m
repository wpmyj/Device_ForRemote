//
//  MHDeviceGateway.m
//  MiHome
//
//  Created by Woody on 15/3/31.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import "MHDeviceGateway.h"
#import "MHDeviceGatewayBase.h"
#import "MHDeviceGatewaySensorMotion.h"
#import "MHGatewayMusicListManager.h"
#import "MHGatewayUploadMusicManager.h"
#import "MHGatewayThirdDataRequest.h"
#import "MHGatewayThirdDataResponse.h"
#import "MHGatewayGetZipPDataRequest.h"
#import "MHGatewayGetZipPDataResponse.h"
#import "MHScenePushHandler.h"
#import "MHGatewayScenePushChildHandler.h"
#import "MHLMLogKeyMap.h"
#import "MHLMOperationQueueTools.h"
#import "MHGatewayExtraSceneManager.h"
#import "MHGatewayCheckUpdateView.h"
#import "MHGatewayShareUserDataManager.h"
#import "MHDeviceGatewaySensorDoubleNeutral.h"
#import "MHDeviceGatewaySensorSingleNeutral.h"
#import "MHDeviceGatewaySensorPlug.h"
#import "MHDeviceGatewaySensorHumiture.h"
#import "MHDeviceGatewaySensorWithNeutralSingle.h"
#import "MHDeviceGatewaySensorWithNeutralDual.h"
#import "MHDeviceGatewaySensorCassette.h"

static NSArray* propNames = nil;
static NSArray *colorSences = nil;
static NSArray *colorViewsSences = nil;
static NSArray* alarmNames = nil;

static NSArray* gatewayOne = nil;

static NSArray* gatewayTwo = nil;

static NSArray* gatewayThree = nil;


static NSArray* acpartnerOne = nil;

@implementation MHDeviceGateway
{
    
}

- (id)initWithData:(MHDataDevice* )data {
    if (self = [super initWithData:data]) {
        _default_music_index = [NSMutableArray arrayWithObjects:@(0), @(10), @(20), nil];
        _music_list = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@[],@(0),@[],@(1),@[],@(2),nil];
        self.deviceBindPattern = MHDeviceBind_WithoutCheck;
        self.isNeedAutoBindAfterDiscovery = YES;
//        self.isCanControlWhenOffline = YES;
        self.arming = [data.prop valueForKey:@"arming"];
    }
    return self;
}

+ (void)load {
    [MHDevListManager registerDeviceModelId:DeviceModelGateWay className:NSStringFromClass([MHDeviceGateway class]) isRegisterBase:YES];
    //push
    [[MHScenePushHandler sharedInstance] registerScenePushDelegate:[MHGatewayScenePushChildHandler new]];
    propNames = @[@"rgb", @"illumination", @"mute", @"arming", @"gateway_volume", @"alarming_volume", @"doorbell_volume",@"clock_volume", @"fm_volume", @"corridor_light", @"corridor_on_time", @"night_light_rgb", @"arming_time",@"doorbell_push", @"arm_wait_time"];
    colorSences = @[@(0x2b9400d3),@(0x2beb6877),@(0x2bffd700),@(0x2b7dd2f0),@(0x2b00ff7f),@(0x2b0900fa)];
    colorViewsSences = @[@(0x2b9400d3),@(0x2beb6877),@(0x3fffd700),@(0x1f7dd2f0),@(0x2b00ff7f),@(0xff66ccff)];
    alarmNames = @[@"en_alarm_light", @"alarm_time_len", @"fm_low_rate"];
    gatewayOne = @[DeviceModelgateWaySensorMotionV1,
                   DeviceModelgateWaySensorMotionV2,
                   DeviceModelgateWaySensorMagnetV1,
                   DeviceModelgateWaySensorMagnetV2,
                   DeviceModelgateWaySensorSwitchV1,
                   DeviceModelgateWaySensorSwitchV2,
                   ];
    gatewayTwo = @[DeviceModelgateWaySensorMotionV1,
                   DeviceModelgateWaySensorMotionV2,
                   DeviceModelgateWaySensorMagnetV1,
                   DeviceModelgateWaySensorMagnetV2,
                   DeviceModelgateWaySensorSwitchV1,
                   DeviceModelgateWaySensorSwitchV2,
                   DeviceModelgateWaySensorXBulbV1,
                   DeviceModelgateWaySensorPlug,
                   DeviceModelgateWaySensorCubeV1,
                   DeviceModelgatewaySensorHt,
                   DeviceModelgatewaySencorCtrlNeutral1V1,
                   DeviceModelgatewaySencorCtrlNeutral2V1,
                   DeviceModelgateWaySensor86Switch1V1,
                   DeviceModelgateWaySensor86Switch2V1,
                   ];
    gatewayThree = @[DeviceModelgateWaySensorMotionV1,
                     DeviceModelgateWaySensorMotionV2,
                     DeviceModelgateWaySensorMagnetV1,
                     DeviceModelgateWaySensorMagnetV2,
                     DeviceModelgateWaySensorSwitchV1,
                     DeviceModelgateWaySensorSwitchV2,
                     DeviceModelgateWaySensorXBulbV1,
                     DeviceModelgateWaySensorPlug,
                     DeviceModelgateWaySensorCubeV1,
                     DeviceModelgatewaySensorHt,
                     DeviceModelgatewaySencorCtrlNeutral1V1,
                     DeviceModelgatewaySencorCtrlNeutral2V1,
                     DeviceModelgateWaySensor86Switch1V1,
                     DeviceModelgateWaySensor86Switch2V1,
                     DeviceModelgateWaySensor86PlugV1,
                     DeviceModelgateWaySensorCurtainV1,
                     DeviceModelgateWaySensorSmokeV1,
                     DeviceModelgateWaySensorNatgasV1,
                     DeviceModelgateWaySensorDlockV1,
                     ];
    acpartnerOne = @[DeviceModelgateWaySensorMotionV1,
                     DeviceModelgateWaySensorMotionV2,
                     DeviceModelgateWaySensorMagnetV1,
                     DeviceModelgateWaySensorMagnetV2,
                     DeviceModelgateWaySensorSwitchV1,
                     DeviceModelgateWaySensorSwitchV2,
                     DeviceModelgateWaySensorXBulbV1,
                     DeviceModelgateWaySensorPlug,
                     DeviceModelgateWaySensorCubeV1,
                     DeviceModelgatewaySensorHt,
                     DeviceModelgatewaySencorCtrlNeutral1V1,
                     DeviceModelgatewaySencorCtrlNeutral2V1,
                     DeviceModelgateWaySensor86Switch1V1,
                     DeviceModelgateWaySensor86Switch2V1,
                     DeviceModelgateWaySensor86PlugV1,
                     DeviceModelgateWaySensorCurtainV1,
                     DeviceModelgateWaySensorSmokeV1,
                     DeviceModelgateWaySensorNatgasV1,
                     DeviceModelgateWaySensorDlockV1,
                     ];
}

- (BOOL)isShownInQuickConnectList {
    return YES;
}

- (void)initPropertiesFromGateway:(MHDeviceGateway*)gateway {
    if (self) {
        self.corridor_light = gateway.corridor_light;
        self.corridor_on_time = gateway.corridor_on_time;
        self.rgb = gateway.rgb;
        self.night_light_rgb = gateway.night_light_rgb;
        self.corridor_light_rgb = gateway.corridor_light_rgb;
        
        self.mute = gateway.mute;
        self.illumination = gateway.illumination;
        
        self.arming = gateway.arming;
        self.arming_time = gateway.arming_time;
        self.gateway_volume = gateway.gateway_volume;
        self.alarming_volume = gateway.alarming_volume;
        self.doorbell_volume = gateway.doorbell_volume;
        self.music_list = gateway.music_list;
        self.doorbell_push = gateway.doorbell_push;
    }
}

- (void)dealloc {
    
}

+ (NSUInteger)getDeviceType {
    return MHDeviceType_Gateway;
}

+ (NSString* )largeIconNameOfStatus:(MHDeviceStatus)status {
    return @"device_icon_gateway";
}

+ (NSString* )smallIconName {
    return @"device_gateway_small_icon";
}

+ (NSString* )guideImageNameOfOnline:(BOOL)isOnline {
    return isOnline ? @"device_guide_gateway_on" : @"device_guide_gateway_off";
}

+ (NSString* )guideLargeImageNameOfOnline:(BOOL)isOnline {
    return [self guideImageNameOfOnline:isOnline];
}

+ (NSString* )shareImageName {
    return @"device_share_gateway";
}

+ (NSString* )defaultName {
    return NSLocalizedStringFromTable(@"gateway",@"plugin_gateway","网关");
}

+ (BOOL)isDeviceAllowedToShown {
    return YES;
}


+ (NSString* )getViewControllerClassName {
    return @"MHGatewayMainViewController";
}

+ (NSString* )uapWifiNamePrefix:(BOOL)isNewVersion {
    if (isNewVersion) {
        return @"Mi-Smart Home Kits";
    } else {
        return @"lumi-gateway";
    }
}

- (NSString *)defaultName {
    return NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.gateway", @"plugin_gateway", nil);
}

- (void)assignProperty:(Gateway_Prop_Id)propId value:(id)value {
    switch (propId) {
        case RGB_INDEX:
            self.rgb = [value integerValue];
            break;
        case ILLUMINATION_INDEX:
            self.illumination = [value integerValue];
            break;
        case MUTE_INDEX:
            self.mute = value;
            break;
        case ARMING_INDEX:
            self.arming = value;
            break;
        case GATEWAY_VOLUME_INDEX:
            self.gateway_volume = [value integerValue];
            break;
        case ALARMING_VOLUME_INDEX:
            self.alarming_volume = [value integerValue];
            break;
        case DOORBELL_VOLUME_INDEX:
            self.doorbell_volume = [value integerValue];
            break;
        case CORRIDOR_LIGHT_INDEX:
            self.corridor_light = value;
            break;
        case CORRIDOR_ON_TIME_INDEX:
            self.corridor_on_time = [value integerValue];
            break;
        case NIGHT_LIGHT_RGB_INDEX: {
            NSInteger newValue = [value integerValue];
            if (newValue < 0) {
                newValue = 0x64ffffff;
            }
            else {
                //网关的初始值为黑色
                int r = newValue >> 16 & 0xff;
                int g = newValue >> 8 & 0xff;
                int b = newValue & 0xff;
                if (r == 127 && g == 127 & b == 127) {
                    newValue = 0x64ffffff;
                }
            }
            self.night_light_rgb = newValue;
            break;
        }
        case ARMING_TIME_INDEX:
            self.arming_time = [value unsignedIntegerValue];
            break;
        case DOORBELL_PUSH_INDEX:
            self.doorbell_push = value;
            break;
        default:
            break;
    }
    [self saveStatus:nil];
}

- (MHDevice*)getSubDevice:(NSString* )sid {
    for (MHDevice* device in self.subDevices) {
        if ([device.did isEqualToString:sid]) {
            return device;
        }
    }
    return nil;
}

+ (NSString* )getLogDetailString:(MHDataGatewayLog* )log {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString* stringDetail = [NSString stringWithFormat:@"%@", [formatter stringFromDate:log.time]];
    stringDetail = [stringDetail stringByAppendingString:@" "];
    
    stringDetail = [MHLMLogKeyMap LMDeviceLogKeyMap:stringDetail log:log];
    return stringDetail;
}

- (MHDeviceGatewayBase* )getFirstMotionDevice {
    for (MHDeviceGatewayBase* subDevice in self.subDevices) {
        NSString *deviceModel = [subDevice modelCutVersionCode:subDevice.model];
        if([deviceModel isEqualToString:[subDevice modelCutVersionCode:DeviceModelgateWaySensorMotionV1]]){
            return subDevice;
        }
    }
    return nil;
}

- (MHDeviceGatewayBase* )getFirstMagnetDevice {
    for (MHDeviceGatewayBase* subDevice in self.subDevices) {
        NSString *deviceModel = [subDevice modelCutVersionCode:subDevice.model];
        if([deviceModel isEqualToString:[subDevice modelCutVersionCode:DeviceModelgateWaySensorMagnetV1]]){
            return subDevice;
        }
    }
    return nil;
}

- (MHDeviceGatewayBase* )getFirstSwitchDevice {
    for (MHDeviceGatewayBase* subDevice in self.subDevices) {
        NSString *deviceModel = [subDevice modelCutVersionCode:subDevice.model];
        if([deviceModel isEqualToString:[subDevice modelCutVersionCode:DeviceModelgateWaySensorSwitchV1]]){
            return subDevice;
        }
    }
    return nil;
}

- (void)onRemoveSubDeviceSucceed:(NSString* )sid {
    MHDeviceGatewayBase* foundDevice = nil;
    for (MHDeviceGatewayBase* subDevice in self.subDevices) {
        if ([subDevice.did isEqualToString:sid]) {
            foundDevice = subDevice;
        }
    }
    if (foundDevice) {
        [self.subDevices removeObject:foundDevice];
    }
}

#pragma mark - 控制
- (NSString* )getOnlineStatusDescription {
    return [NSString stringWithFormat:NSLocalizedStringFromTable(@"mydevice.gateway.subdevice.status",@"plugin_gateway","已连接%d个设备"), [self.subDevices count]];;
}

- (NSDictionary* )getStatusRequestPayload {
    NSMutableDictionary* jason = [[NSMutableDictionary alloc] init];
    [jason setObject:@( [self getRPCNonce] ) forKey:@"id"];
    [jason setObject:@"get_prop" forKey:@"method"];
    [jason setObject:propNames forKey:@"params"];
    return jason;
}

- (NSDictionary* )setPropertyRequestPayloadWithPropertyName:(NSString* )prop value:(id)value {
    NSMutableDictionary* jason = [[NSMutableDictionary alloc] init];
    [jason setObject:@( [self getRPCNonce] ) forKey:@"id"];
    NSString* method = [NSString stringWithFormat:@"set_%@", prop];
    [jason setObject:method forKey:@"method"];
    [jason setObject:@[value] forKey:@"params"];
    return jason;
}

- (NSDictionary* )getPropertyRequestPayloadWithPropertyName:(NSString* )prop {
    NSMutableDictionary* jason = [[NSMutableDictionary alloc] init];
    [jason setObject:@( [self getRPCNonce] ) forKey:@"id"];
    NSString* method = [NSString stringWithFormat:@"get_%@", prop];
    [jason setObject:method forKey:@"method"];
    return jason;
}

- (NSDictionary* )requestPayloadWithMethodName:(NSString* )method value:(id)value {
    NSMutableDictionary* jason = [[NSMutableDictionary alloc] init];
    [jason setObject:@( [self getRPCNonce] ) forKey:@"id"];
    [jason setObject:method forKey:@"method"];
    if (value != nil) {
        if ([value isKindOfClass:[NSArray class]]) {
            [jason setObject:value forKey:@"params"];
        } else {
            [jason setObject:@[value] forKey:@"params"];
        }
    }
    return jason;
}

- (NSDictionary* )requestJsonDictionaryPayloadWithMethodName:(NSString* )method value:(NSDictionary *)value {
    NSMutableDictionary* jason = [[NSMutableDictionary alloc] init];
    [jason setObject:@( [self getRPCNonce] ) forKey:@"id"];
    [jason setObject:method forKey:@"method"];
    if (value != nil) {
        [jason setObject:value forKey:@"params"];
    }
    return jason;
}

- (BOOL)parseGetStatusResponse:(id)response {
    MHDeviceRPCResponse* rsp = [MHDeviceRPCResponse responseWithJSONObject:response];
    if (rsp.code == MHNetworkErrorOk) {
        if ([rsp.resultList count] >= [propNames count]) {
            for (NSInteger i = RGB_INDEX; i < GATEWAY_PROP_COUNTs; i++) {
                [self assignProperty:(Gateway_Prop_Id)i value:rsp.resultList[i]];
            }
            return YES;
        }
    }
    return NO;
}

- (void)parsePowerOnResponse:(id)response isOn:(BOOL)isOn {
    MHDeviceRPCResponse* rsp = [MHDeviceRPCResponse responseWithJSONObject:response];
    if (rsp.code == MHNetworkErrorOk) {
        self.isOpen = isOn;
    }
}

- (void)setProperty:(Gateway_Prop_Id)propId
              value:(id)value
            success:(void (^)(id))success
            failure:(void (^)(NSError *))failure {
    NSDictionary *payload = [self setPropertyRequestPayloadWithPropertyName:propNames[propId]
                                                                      value:value];
    [self sendPayload:payload success:^(id respObj) {
        if (propId == ARMING_DELAY_INDEX) {
            self.arming_delay = [value intValue];
            [[NSUserDefaults standardUserDefaults] setObject:@(self.arming_delay) forKey:[NSString stringWithFormat:@"gateway_arming_delay_%@",self.did]];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else {
            [self assignProperty:propId value:value];
        }
        if (success) {
            success(respObj);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getProperty:(Gateway_Prop_Id)propId
            success:(void (^)(id))success
            failure:(void (^)(NSError *))failure {
    NSDictionary *payload = [self getPropertyRequestPayloadWithPropertyName:propNames[propId]];
    XM_WS(weakself);
    //为什么获取的属性值都保存一份到本地？！？！？
    switch (propId) {
        case ARMING_DELAY_INDEX: {
        [self sendPayload:payload success:^(id respObj) {
                if ([[respObj[@"code"] stringValue] isEqualToString:@"0"] &&
                    [respObj[@"message"] isEqualToString:@"ok"] &&
                    [respObj[@"result"] isKindOfClass:[NSArray class]]) {
                    weakself.arming_delay = [respObj[@"result"][0] intValue];
                    [[NSUserDefaults standardUserDefaults] setObject:@(weakself.arming_delay) forKey:[NSString stringWithFormat:@"gateway_arming_delay_%@",weakself.did]];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                if (success) {
                    success(respObj[@"result"]);
                }
            } failure:^(NSError *error) {
                if (failure) {
                    failure(error);
                    NSLog(@"%@", error);
                }
            }];
        }
            
            break;
        case ARMING_INDEX: {
        [self sendPayload:payload success:^(id respObj) {
                if ([[respObj[@"code"] stringValue] isEqualToString:@"0"] &&
                    [respObj[@"message"] isEqualToString:@"ok"] &&
                    [respObj[@"result"] isKindOfClass:[NSArray class]]) {
                    weakself.arming = [respObj[@"result"][0] stringValue];
                    [[NSUserDefaults standardUserDefaults] setObject:weakself.arming forKey:[NSString stringWithFormat:@"gateway_arming_%@",weakself.did]];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                if (success) {
                    success(respObj[@"result"]);
                }
            } failure:^(NSError *error) {
                if (failure) {
                    failure(error);
                    NSLog(@"%@", error);
                }
            }];
            
        }
            break;
        default:
        {
            [self sendPayload:payload success:^(id respObj) {
                if (success) success(respObj[@"result"]);
            } failure:^(NSError *error) {
                if (failure) failure(error);
            }];
        }
            break;
    }
   
}

- (void)startZigbeeJoinWithSuccess:(void (^)(id))success
                           failure:(void (^)(NSError *))failure {
    NSDictionary *payload = [self requestPayloadWithMethodName:@"start_zigbee_join"
                                                         value:@( 30 )];
    [self sendPayload:payload success:^(id respObj) {
        if (success) {
            success(respObj);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)stopZigbeeJoinWithSuccess:(void (^)(id))success
                          failure:(void (^)(NSError *))failure {
    NSDictionary *payload = [self requestPayloadWithMethodName:@"start_zigbee_join"
                                                         value:@( 0 )];
    [self sendPayload:payload success:^(id respObj) {
        if (success) {
            success(respObj);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)removeSubDevice:(NSString* )sid
                success:(void (^)(id))success
                failure:(void (^)(NSError *))failure {
    NSDictionary *payload = [self requestPayloadWithMethodName:@"remove_device"
                                                         value:sid];
    [self sendPayload:payload success:^(id respObj) {
        [self onRemoveSubDeviceSucceed:sid];
        if (success) {
            success(respObj);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}
#pragma mark - get_device_prop/set_device_prop相关属性
- (void)setDeviceProp:(ARMING_PRO_ID)propId
                value:(id)value
              success:(void (^)(id))success
              failure:(void (^)(NSError *))failure {
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"updating",@"plugin_gateway","正在更新中...") modal:NO];
    NSMutableDictionary* jason = [[NSMutableDictionary alloc] init];
    [jason setObject:@( [self getRPCNonce] ) forKey:@"id"];
    [jason setObject:@"set_device_prop" forKey:@"method"];
    [jason setObject:@{ @"sid" : @"lumi.0",  alarmNames[propId] : value } forKey:@"params"];
    /*
     params:[data:{"id":65022,"method":"set_device_prop","params":{"en_alarm_light":0,"sid":"lumi.0"}}]
     */
    [self sendPayload:jason success:^(id respObj) {
        NSLog(@"%@", respObj);
        [[MHTipsView shareInstance] hide];
        if (success) {
            success(respObj);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed", @"plugin_gateway",@"请求失败，请检查网络") duration:1.0f modal:NO];
    }];
    
}

- (void)getDeviceProp:(ARMING_PRO_ID)propId allValue:(BOOL)isAll success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    NSDictionary *payload = nil;
    if (isAll) {
        payload  = [self requestPayloadWithMethodName:@"get_device_prop" value:@[ @"lumi.0" ,  @"en_alarm_light", @"alarm_time_len"  ]];
    }
    else {
        payload  = [self requestPayloadWithMethodName:@"get_device_prop" value:@[ @"lumi.0" , alarmNames[propId] ]];
    }
    [self sendPayload:payload success:^(id respObj) {
        if([[respObj valueForKey:@"result"] isKindOfClass:[NSArray class]] &&
           [[respObj valueForKey:@"result"] count] > 0
           ){
            NSArray *tempArray = [respObj valueForKey:@"result"];
            if (success) {
                success(tempArray);
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
        if (failure) {
            failure(error);
        }
    }];
    
}




- (void)gePropDevices:(NSArray *)devices success:(SucceedBlock)success failure:(FailedBlock)failure {
    /**
     *
     *  @param value  [["lumi.158d000102fcb4","neutral_0","neutral_1"],["lumi.158d0000f708e4","humidity","temperature"],["lumi.158d0000f1a730","neutral_0","neutral_0"]]
     */
    NSDictionary *payload = [self requestPayloadWithMethodName:@"get_device_prop_exp" value:[self requestPayloadParams:devices]];
    XM_WS(weakself);
    
    [self sendPayload:payload success:^(id respObj) {
        if([[respObj valueForKey:@"result"] isKindOfClass:[NSArray class]] &&
           [[respObj valueForKey:@"result"] count] > 0
           ){
            NSLog(@"一次拉取多个属性成功%@#propResp", respObj);
            NSArray *propsArray = [respObj valueForKey:@"result"];
            [weakself analyzePropArray:propsArray devices:devices];
            if (success) {
                success(propsArray);
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"一次拉取多个设备属性失败了%@#propError", error);
        [devices enumerateObjectsUsingBlock:^(MHDeviceGatewayBase *device, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([device isKindOfClass:[MHDeviceGatewaySensorDoubleNeutral class]]) {
                MHDeviceGatewaySensorDoubleNeutral *deviceDouble = (MHDeviceGatewaySensorDoubleNeutral *)device;
                    deviceDouble.neutral_0 = @"disable";
                    deviceDouble.neutral_1 = @"disable";
            }
            else if ([device isKindOfClass:[MHDeviceGatewaySensorSingleNeutral class]]) {
                MHDeviceGatewaySensorSingleNeutral *deviceSingle = (MHDeviceGatewaySensorSingleNeutral *)device;
                deviceSingle.neutral_0 = @"disable";

            }
            else if ([device isKindOfClass:[MHDeviceGatewaySensorPlug class]]) {
                MHDeviceGatewaySensorPlug *devicePlug = (MHDeviceGatewaySensorPlug *)device;
                devicePlug.neutral_0 = @"disable";
            }
        }];
        if (failure) {
            failure(error);
        }
    }];

}
/**
 *  解析网关返回的属性列表
 *
 *  @param propsArray 属性列表
 *  @param devices    设备列表
 */
- (void)analyzePropArray:(NSArray *)propsArray devices:(NSArray *)devices {
    NSLog(@"%@", propsArray);
    NSLog(@"%@", devices);
    
    [propsArray enumerateObjectsUsingBlock:^(NSArray *deviceProp, NSUInteger idx, BOOL * _Nonnull stop) {
        MHDeviceGatewayBase *device = devices[idx];
        //零火双键
        if ([device isKindOfClass:[MHDeviceGatewaySensorWithNeutralDual class]]) {
            MHDeviceGatewaySensorWithNeutralDual *deviceDouble = (MHDeviceGatewaySensorWithNeutralDual *)device;
            if (deviceProp.count > 1) {
                //只处理‘on’或者‘off‘的状态，别的值都不管
                if([deviceProp[0] isEqualToString:@"on"] ||
                   [deviceProp[0] isEqualToString:@"off"]) {
                    deviceDouble.channel_0 = deviceProp[0];
                }
                else {
                    deviceDouble.channel_0 = @"disable";
                }
                if([deviceProp[1] isEqualToString:@"on"] ||
                   [deviceProp[1] isEqualToString:@"off"]) {
                    deviceDouble.channel_1 = deviceProp[1];
                }
                else {
                    deviceDouble.channel_1 = @"disable";
                }
            }
            else {
                deviceDouble.channel_0 = @"disable";
                deviceDouble.channel_1 = @"disable";
            }
        }
        //单火双键
        if ([device isKindOfClass:[MHDeviceGatewaySensorDoubleNeutral class]]) {
            MHDeviceGatewaySensorDoubleNeutral *deviceDouble = (MHDeviceGatewaySensorDoubleNeutral *)device;
            if (deviceProp.count > 1) {
                //只处理‘on’或者‘off‘的状态，别的值都不管
                if([deviceProp[0] isEqualToString:@"on"] ||
                   [deviceProp[0] isEqualToString:@"off"]) {
                    deviceDouble.neutral_0 = deviceProp[0];
                }
                else {
                    deviceDouble.neutral_0 = @"disable";
                }
                if([deviceProp[1] isEqualToString:@"on"] ||
                   [deviceProp[1] isEqualToString:@"off"]) {
                    deviceDouble.neutral_1 = deviceProp[1];
                }
                else {
                    deviceDouble.neutral_1 = @"disable";
                }
            }
            else {
                deviceDouble.neutral_0 = @"disable";
                deviceDouble.neutral_1 = @"disable";
            }
        }
        //单火单键
        else if ([device isKindOfClass:[MHDeviceGatewaySensorSingleNeutral class]]) {
            MHDeviceGatewaySensorSingleNeutral *deviceSingle = (MHDeviceGatewaySensorSingleNeutral *)device;
            if (deviceProp.count > 0) {
                //只处理‘on’或者‘off‘的状态，别的值都不管
                if([deviceProp[0] isEqualToString:@"on"] ||
                   [deviceProp[0] isEqualToString:@"off"]) {
                    deviceSingle.neutral_0 = deviceProp[0];
                }
                else {
                    deviceSingle.neutral_0 = @"disable";
                }
            }
            else {
                deviceSingle.neutral_0 = @"disable";
            }
            
        }
        //零火单键
        else if ([device isKindOfClass:[MHDeviceGatewaySensorWithNeutralSingle class]]) {
            NSLog(@"零火的开关状态%@", deviceProp);
            MHDeviceGatewaySensorWithNeutralSingle *deviceSingle = (MHDeviceGatewaySensorWithNeutralSingle *)device;
            if (deviceProp.count > 0) {
                //只处理‘on’或者‘off‘的状态，别的值都不管
                if([deviceProp[0] isEqualToString:@"on"] ||
                   [deviceProp[0] isEqualToString:@"off"]) {
                    deviceSingle.channel_0 = deviceProp[0];
                }
                else {
                    deviceSingle.channel_0 = @"disable";
                }
            }
            else {
                deviceSingle.channel_0 = @"disable";
            }
            
        }

        //插座 , 墙壁插座
        else if ([device isKindOfClass:[MHDeviceGatewaySensorPlug class]]) {
            MHDeviceGatewaySensorPlug *devicePlug = (MHDeviceGatewaySensorPlug *)device;
            NSLog(@"%@", deviceProp);
            if (deviceProp.count > 0) {
                //只处理‘on’或者‘off‘的状态，别的值都不管
                if([deviceProp[0] isEqualToString:@"on"] ||
                   [deviceProp[0] isEqualToString:@"off"]) {
                    devicePlug.neutral_0 = deviceProp[0];
                }
                else {
                    devicePlug.neutral_0 = @"disable";
                }
            }
            else {
                devicePlug.neutral_0 = @"disable";
            }
           
        }
        //温湿度
        else if ([device isKindOfClass:[MHDeviceGatewaySensorHumiture class]]) {
            MHDeviceGatewaySensorHumiture *deviceHT = (MHDeviceGatewaySensorHumiture *)device;
            if (deviceProp.count > 1) {
                deviceHT.temperature = [deviceProp[0] floatValue] / 100.0;
                deviceHT.humidity = [deviceProp[1] floatValue] / 100.0;
                if (deviceHT.temperature >= 100.0f || !deviceHT.humidity) {
                    [deviceHT readStatus];
                }
                else {
                    [deviceHT saveStatus];
                }
            }
        }
        
    }];

}

- (NSArray *)requestPayloadParams:(NSArray *)devices {
    __block NSMutableArray *params = [NSMutableArray new];
    NSLog(@"%ld", devices.count);
    NSLog(@"设备列表%@", devices);
    [devices enumerateObjectsUsingBlock:^(MHDeviceGatewayBase *device, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([device isKindOfClass:[MHDeviceGatewaySensorDoubleNeutral class]]) {
            [params addObject:@[ device.did, @"neutral_0", @"neutral_1" ]];
        }
        else if ([device isKindOfClass:[MHDeviceGatewaySensorSingleNeutral class]]) {
            [params addObject:@[ device.did, @"neutral_0" ]];
            
        }
        else if ([device isKindOfClass:[MHDeviceGatewaySensorPlug class]]) {
            [params addObject:@[ device.did, @"neutral_0"]];
        }
        else if ([device isKindOfClass:[MHDeviceGatewaySensorHumiture class]]) {
            [params addObject:@[ device.did, @"temperature", @"humidity" ]];
        }
        else if ([device isKindOfClass:[MHDeviceGatewaySensorCassette class]]) {
            [params addObject:@[ device.did, @"channel_0" ]];
        }
        else if ([device isKindOfClass:[MHDeviceGatewaySensorWithNeutralSingle class]]) {
            [params addObject:@[ device.did, @"channel_0" ]];
        }
        else if ([device isKindOfClass:[MHDeviceGatewaySensorWithNeutralDual class]]) {
            [params addObject:@[ device.did, @"channel_0", @"channel_1" ]];
        }
        
        if (idx == 14) {
            *stop = YES;
        }
    }];
    NSData *originData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    NSLog(@"数据长度%ld", originData.length);
    NSLog(@"%@", params);
    return params;
}


#pragma mark - 分享用户列表信息
- (void)getShareUserListSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    [[MHGatewayShareUserDataManager sharedInstance] getShareUserListWithGatewayDid:self.did success:^(id obj) {
        if (success) {
            success(obj);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}


- (void)getMusicListOfGroup:(NSInteger)idx
                    success:(void (^)(id))success
                    failure:(void (^)(NSError *))failure {
    XM_WS(weakself);
    NSDictionary *payload = [self requestPayloadWithMethodName:@"music_list" value:@( idx )];
    [self sendPayload:payload success:^(id respObj) {
        NSMutableArray* list = [[(MHSafeDictionary* )respObj objectForKey:@"result" class:[NSArray class]] mutableCopy];
        if ([list count] > 0) {
            for (MHSafeDictionary* item in list) {
                if ([[item allKeys] containsObject:@"default"]) {
                    weakself.default_music_index[idx] = [item objectForKey:@"default" class:[NSNumber class]];
                    [[NSUserDefaults standardUserDefaults] setObject:[item objectForKey:@"default" class:[NSNumber class]] forKey:[NSString stringWithFormat:@"%@%ld", self.did, idx]];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [list removeObject:item];
                }
            }
        }
        if (list) {
            [weakself.music_list setObject:list forKey:@(idx)];
        }
        if (success) success(respObj);
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getDefaultMusicOfGroup:(NSInteger)idx
                       success:(void (^)(id))success
                       failure:(void (^)(NSError *))failure {
    NSDictionary *payload = [self requestPayloadWithMethodName:@"get_default_sound"
                                                         value:@( idx )];
    [self sendPayload:payload success:^(id respObj) {
        if (success) {
            success(respObj);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark - gateway 获取云端，用户自定义 music list
- (void)getCloudUserMusicListWithSuccess:(void (^)(id))success
                                 failure:(void (^)(NSError *))failure {
    MHGatewayMusicListManager *lisManager = [[MHGatewayMusicListManager alloc] init];
    [lisManager fetchMusicListWithPageIndex:0 success:^(id obj){
        NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:obj];
        [tmpArray removeLastObject];
        self.initialMusicList = [NSArray arrayWithArray:[tmpArray mutableCopy]];
        
        if(success)success(self.initialMusicList);
        
    } andfailure:^(NSError *error){
        if(failure)failure(error);
    }];
}


- (void)getMusicFreespaceSuccess:(void (^)(id))success
                         failure:(void (^)(NSError *))failure {
    NSDictionary *payload = [self requestPayloadWithMethodName:@"get_music_free_space"
                                                         value:@[]];
    [self sendPayload:payload success:^(id respObj) {
        if (success) {
            success(respObj);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)downloadUserMusicWithMid:(NSString*)mid
                             url:(NSString*)musicUrl
                         success:(void (^)(id))success
                         failure:(void (^)(NSError *))failure {
    NSDictionary *payload = [self requestPayloadWithMethodName:@"download_user_music"
                                                         value:@[mid,musicUrl]];
    [self sendPayload:payload success:^(id respObj) {
        if (success) {
            success(respObj);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)deleteUserMusicWithMid:(NSString*)mid
                       success:(void (^)(id))success
                       failure:(void (^)(NSError *))failure {
    NSDictionary *payload = [self requestPayloadWithMethodName:@"delete_user_music"
                                                         value:mid];
    [self sendPayload:payload success:^(id respObj) {
        if (success) {
            success(respObj);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)resetUserMusicSuccess:(void (^)(id))success
                      failure:(void (^)(NSError *))failure {
    NSDictionary *payload = [self requestPayloadWithMethodName:@"reset_user_music"
                                                         value:@[]];
    [self sendPayload:payload success:^(id respObj) {
        if (success) {
            success(respObj);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}


- (void)playMusicWithMid:(NSString*)mid
                  volume:(NSInteger)vol
                 Success:(void (^)(id))success
                 failure:(void (^)(NSError *))failure {
    NSDictionary *payload = [self requestPayloadWithMethodName:@"play_music_new"
                                                         value:@[ mid , @( vol ) ]];
    [self sendPayload:payload success:^(id respObj) {
        if (success) {
            success(respObj);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)setDefaultSoundWithGroup:(NSInteger)group
                         musicId:(NSString*)mid
                         Success:(void (^)(id))success
                         failure:(void (^)(NSError *))failure {
    NSDictionary *payload = [self requestPayloadWithMethodName:@"set_default_music"
                                                         value:@[ @( group ) , mid ]];
    [self sendPayload:payload success:^(id respObj) {
        if (success) {
            success(respObj);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getDefaultSoundWithGroup:(NSInteger) group
                        Success:(void (^)(id))success
                        failure:(void (^)(NSError *))failure {
    NSDictionary *payload = [self requestPayloadWithMethodName:@"get_default_music"
                                                         value:@[ @(group)] ];
    [self sendPayload:payload success:^(id respObj) {
        if (success) {
            success(respObj);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getMusicInfoWithGroup:(NSInteger)group
                      Success:(void (^)(id))success
                      failure:(void (^)(NSError *))failure {
    XM_WS(weakself);
    NSDictionary *payload = [self requestPayloadWithMethodName:@"get_music_info"
                                                         value:@[ @( group ) ]];
    [self sendPayload:payload success:^(id respObj) {
        if([[respObj valueForKey:@"result"] isKindOfClass:[NSDictionary class]]){
            [[[MHSafeDictionary alloc] init] setObjectsInDictionary:respObj];
            
            MHSafeDictionary* result = [(MHSafeDictionary* )respObj objectForKey:@"result" class:[MHSafeDictionary class]];
            NSLog(@"%@", result);
            if (group != 9) {
                weakself.default_music_index[group] = [result objectForKey:@"default" class:[NSNumber class]];
            }
            [[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"default" class:[NSNumber class]] forKey:[NSString stringWithFormat:@"%@%ld", self.did, group]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSMutableArray *list = [result objectForKey:@"list" class:[NSArray class]];
            NSLog(@"%@", list);
            NSMutableArray *listCopy = [NSMutableArray arrayWithArray:list];
            if (list) {
                //mid > 1000 的都安排在第九组中
                NSMutableArray *nineList = [NSMutableArray arrayWithCapacity:1];
                for(id obj in [list mutableCopy]){
                    if([[obj valueForKey:@"mid"] intValue] > 1000) {
                        [nineList addObject:obj];
                        [listCopy removeObject:obj];
                    }
                }
                [weakself.music_list setObject:listCopy forKey:[NSString stringWithFormat:@"%ld",(long)group]];
                [weakself.music_list setObject:nineList forKey:[NSString stringWithFormat:@"%d",9]];
            }
            if (success) success(respObj);
        }
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

- (void)fetchGatewayDownloadList {
    XM_WS(weakself);
    MHGatewayUploadMusicManager *manager = [[MHGatewayUploadMusicManager alloc] initWithDevice:self];
    [manager fetchGatewayDownloadListWithSuccess:^(id v){
        [weakself restoreGatewayDownloadList];
    } andfailure:nil];
}

- (NSArray *)restoreGatewayDownloadList {
    MHGatewayUploadMusicManager *manager = [[MHGatewayUploadMusicManager alloc] initWithDevice:self];
    _downloadMusicList = [NSArray arrayWithArray:[manager restoreGatwayDownloadList]];
    return _downloadMusicList;
}

- (NSString *)fetchGwDownloadMidName:(NSString *)mid {
    for(id obj in self.downloadMusicList){
        if ([[[obj valueForKey:@"mid"] stringValue] isEqualToString:mid]){
            return [obj valueForKey:@"alias_name"];
        }
    }
    return nil;
}

- (NSString *)fetchGwDownloadTime:(NSString *)mid {
    for(id obj in self.downloadMusicList){
        if ([[[obj valueForKey:@"mid"] stringValue] isEqualToString:mid]){
            return [[obj valueForKey:@"time"] stringValue];
        }
    }
    return nil;
}

- (void)getDownloadMusicProgressWithSuccess:(SucceedBlock)success failure:(FailedBlock)failure {

    NSDictionary *payload = [self requestPayloadWithMethodName:@"get_download_progress"
                                                         value:@[]];
    [self sendPayload:payload success:^(id respObj) {
        
        if([[respObj valueForKey:@"result"] isKindOfClass:[NSArray class]]){
            NSString *result = [[respObj valueForKey:@"result"] firstObject];
            NSArray *resultArray = [result componentsSeparatedByString:@":"];
            NSNumber *progressValue = @( [[resultArray lastObject] integerValue] );
            
            if (progressValue.integerValue == -9 ){
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.download.oversize", @"plugin_gateway", nil) forKey:NSLocalizedDescriptionKey];
                NSError *error = [NSError errorWithDomain:@"oversize" code:-10009 userInfo:userInfo];
                if (failure) failure(error);
            }
            else if (progressValue.integerValue < 0) {
                if (failure) failure(nil);
            }
            else if (progressValue.integerValue == 100){
                if (success) success( @(1) );
            }
            else {
                if (success) success( @(progressValue.doubleValue / 100.f) );
            }
        }
        else{
            if (failure) failure(nil);
        }
        
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

//音乐列表(旧网关)
- (void)setDefaultMusicOfGroup:(NSInteger)idx
                       success:(void (^)(id))success
                       failure:(void (^)(NSError *))failure {
    XM_WS(weakself);
    NSDictionary *payload = [self requestPayloadWithMethodName:@"set_default_sound"
                                                         value:@( idx )];
    [self sendPayload:payload success:^(id respObj) {
        weakself.default_music_index[idx/10] = @(idx);
        [[NSUserDefaults standardUserDefaults] setObject:@(idx) forKey:[NSString stringWithFormat:@"%@%ld", self.did, idx/10]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if (success) {
            success(respObj);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)playMusicOfIndex:(NSInteger)idx {
    NSDictionary *payload =  [self requestPayloadWithMethodName:@"play_music"
                                                          value:@(idx)];
    [self sendPayload:payload success:nil failure:nil];
}

#pragma mark - 自动化
- (void)getBindListOfSensorsWithSuccess:(void (^)(id))success
                                failure:(void (^)(NSError *))failure {
    [self.subDevices enumerateObjectsUsingBlock:^(MHDeviceGatewayBase* sensor,
                                                  NSUInteger idx, BOOL *stop) {
        [sensor getBindListWithSuccess:nil failure:nil];
    }];
}

- (void)getBindPageWithSuccess:(void (^)(id))success
                       failure:(void (^)(NSError *))failure {
    NSDictionary *payload = [self requestPayloadWithMethodName:@"bind_page"
                                                         value:@[ SID_Gateway, @(0) ]];
    [self sendPayload:payload success:nil failure:nil];
}

/**
 * @brief 为自动化record生成extra字段，给record中的triggers和actions设置后返回
 */
- (void)prepareExtraValueForIFTRecord:(MHDataIFTTTRecord *)record
                           completion:(void (^)(MHDataIFTTTRecord *editedRecord))completion {


    
    MHGatewayExtraSceneManager *extraScene = [MHGatewayExtraSceneManager sharedInstance];
   
        NSMutableDictionary *sceneSetting = [NSMutableDictionary dictionary];
        NSMutableArray *launchs = [NSMutableArray new];
        NSMutableArray *actions = [NSMutableArray new];
        for (MHDataIFTTTTrigger *trigger in record.triggers){
            NSDictionary *triggerDic = [trigger jsonObject];
            [launchs addObject:triggerDic];
        }
        
        for (MHDataIFTTTAction *action in record.actions){
            NSDictionary *actionDic = [action jsonObject];
            [actions addObject:actionDic];
        }
        NSMutableDictionary *launch = [NSMutableDictionary new];
        [launch setObject:launchs forKey:@"attr"];
        [sceneSetting setObject:launch forKey:@"launch"];
        [sceneSetting setObject:actions forKey:@"action_list"];
        
        NSDictionary *scene = @{ @"setting" : sceneSetting };
        
        [extraScene mapExtraInfoWithScene:scene andSuccess:^(id obj) {
            
            NSMutableArray *actionList = [NSMutableArray new];
            for(NSDictionary *dic in [[obj valueForKey:@"setting"] valueForKey:@"action_list"]){
                MHSafeDictionary *safeDic = [MHSafeDictionary new];
                [safeDic setObjectsInDictionary:dic];
                [actionList addObject:safeDic];
            }
            NSMutableArray *launchList = [NSMutableArray new];
            if ([[[obj valueForKey:@"setting"] valueForKey:@"launch"] isKindOfClass:[NSDictionary class]]) {
                for(NSDictionary *dic in [[[obj valueForKey:@"setting"] valueForKey:@"launch"] valueForKey:@"attr"]){
                    MHSafeDictionary *safeDic = [MHSafeDictionary new];
                    [safeDic setObjectsInDictionary:dic];
                    [launchList addObject:safeDic];
                }
            }
            if([launchList isKindOfClass:[NSArray class]] && launchList.count){
                record.triggers = [MHDataIFTTTTrigger dataListWithJSONObjectList:launchList];
            }
            if([actionList isKindOfClass:[NSArray class]] && actionList.count){
                NSLog(@"%@",actionList);
                    record.actions = [MHDataIFTTTAction dataListWithJSONObjectList:actionList];
            }
            if(completion)completion(record);
        }];
}

#pragma mark - 报警
- (void)disAlarmWithSuccess:(void (^)(id))success
                    failure:(void (^)(NSError *))failure {
    NSDictionary *payload = [self requestPayloadWithMethodName:@"dis_alarm"
                                                         value:@(0)];
    [self sendPayload:payload success:^(id respObj) {
        if (success) {
            success(respObj);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

//取消播放铃音
- (void)setSoundPlaying:(NSString*)on
                success:(void (^)(id))success
                failure:(void (^)(NSError *))failure {
    NSDictionary *payload = [self requestPayloadWithMethodName:@"set_sound_playing"
                                                         value:on];
    [self sendPayload:payload success:^(id respObj) {
        if (success) {
            success(respObj);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (NSString* )getBellNameOfGroup:(BellGroup)group index:(NSInteger)index {
    return [MHLMLogKeyMap LMGatewayMusicNameMapWithGroup:group index:index];
}

- (NSString* )hasOpenNightLightMotionNames {
    NSString* names = [NSString new];
    for (id obj in self.subDevices) {
        if ([obj isKindOfClass:[MHDeviceGatewaySensorMotion class]]) {
            MHDeviceGatewaySensorMotion* motion = (MHDeviceGatewaySensorMotion*)obj;
            if (motion.isOnline && [motion isSetOpenNightLight]) {
                if ([names length] > 0) {
                    names = [names stringByAppendingString:@","];
                }
                names = [names stringByAppendingString:motion.name];
            }
        }
    }
    if ([names length] <= 0) {
        names = NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.motion.none",@"plugin_gateway","未选择设备");
    }
    return names;
}

#pragma mark - fm 网关
- (void)fetchRadioDeviceStatusWithSuccess:(SucceedBlock)success
                               andFailure:(FailedBlock)failure {
    XM_WS(weakself);
    NSDictionary *payload = [self requestPayloadWithMethodName:@"get_prop_fm"
                                                         value:@[]];

    [self sendPayload:payload success:^(id respObj) {
        if ([[respObj valueForKey:@"result"] isKindOfClass:[NSDictionary class]]){
            weakself.fm_volume = [[[respObj valueForKey:@"result"] valueForKey:@"current_volume"] integerValue];
            NSString *status = [[respObj valueForKey:@"result"] valueForKey:@"current_status"];
            if(status) {
                weakself.current_status = [status isEqualToString:@"pause"] ? 0 : 1;
            }
            [weakself saveStatus:nil];
        }
        if (success) success(respObj);
        
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

- (void)playSpecifyRadioWithProgramID:(NSInteger)programID
                                  Url:(NSString *)url
                                 Type:(NSString *)type
                           andSuccess:(SucceedBlock)success
                           andFailure:(FailedBlock)failure {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:@(programID) forKey:@"id"];
    [params setObject:@(0) forKey:@"type"];
    [params setObject:url forKey:@"url"];
    
    NSDictionary *payload = [self requestJsonDictionaryPayloadWithMethodName:@"play_specify_fm"
                                                                       value:params];
    [self sendPayload:payload success:^(id respObj) {
        if (success) success(respObj);
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

- (void)playSpecifyRadioForTryVolume:(NSInteger)programID
                              volume:(NSInteger)volume
                         withSuccess:(SucceedBlock)success
                             failure:(FailedBlock)failure {
    NSArray *params = @[@(programID),@(volume)];
    
    NSDictionary *payload = [self requestPayloadWithMethodName:@"play_specify_fm"
                                                         value:params];
    [self sendPayload:payload success:^(id respObj) {
        if (success) success(respObj);
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

- (void)radioVolumeControlWithDirection:(NSString *)direction
                                  Value:(NSInteger)value
                             andSuccess:(SucceedBlock)success
                             andFailure:(FailedBlock)failure {
    XM_WS(weakself);

    //value: 0 - 100
    if(!direction.length) direction = [NSString stringWithFormat:@"%ld",(long)value];
    NSDictionary *payload = [self requestPayloadWithMethodName:@"volume_ctrl_fm"
                                                         value:direction];
    [self sendPayload:payload success:^(id respObj) {
        if([[respObj valueForKey:@"result"] isKindOfClass:[NSDictionary class]]){
            weakself.fm_volume = [[[respObj valueForKey:@"result"] valueForKey:@"volume"] integerValue];
            [weakself saveStatus:nil];
        }

        if (success) success(respObj);
        
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

//目前都默认type为0 ; actionMethod 设置添加或者删除 @"add_channels" / @"remove_channels" ／@"set_channels"
- (void)setGatewayFMCollection:(NSArray *)radioList
                   withSuccess:(SucceedBlock)success
                    andFailure:(FailedBlock)failure {
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:1];
    for (id radioDic in radioList){
        //目前都默认type为 0 
        NSDictionary *chs = @{ @"id"   : @([[radioDic valueForKey:@"radioId"] integerValue]),
                               @"url"  : [radioDic valueForKey:@"radioRateUrl"] ,
                               @"type" : @(0)
                               };
        [params addObject:chs];
    }
    
    __block NSMutableArray *cmpGatewayParams = [NSMutableArray new];
    __block void (^ compareTwoArray)() = ^(){
        [self compareTwoArraysWithStandardArray:params compareArray:cmpGatewayParams];
    };

    //先取网关现有收藏，只添加多出来的
    [self fetchGatewayFMChannels:0 withSuccess:^(NSArray *obj) {
        if(obj && [obj count] == 10){
            cmpGatewayParams = [NSMutableArray arrayWithArray:obj];

            [self fetchGatewayFMChannels:10 withSuccess:^(id obj2) {
                [cmpGatewayParams addObjectsFromArray:obj2];
                compareTwoArray();
            } failure:nil];
        }
        else {
            cmpGatewayParams = [NSMutableArray arrayWithArray:obj];
            compareTwoArray();
        }
    } failure:nil];
}

- (void)compareTwoArraysWithStandardArray:(NSMutableArray *)standardArray
                                         compareArray:(NSMutableArray *)comparedArray {
    
    NSMutableArray *mutableStandardArray = [NSMutableArray arrayWithArray:standardArray];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
    [mutableStandardArray sortedArrayUsingDescriptors:@[sort]];
    [comparedArray sortedArrayUsingDescriptors:@[sort]];
    
    __block BOOL isResetAll = NO;
    if(standardArray.count < comparedArray.count) { //全部重置
        isResetAll = YES;
    }
    else {
        //如果compare里面的元素有不在standard里面的，全部重置
        [comparedArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            int cmpId = [[obj valueForKey:@"id"] intValue];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %d",cmpId];
            NSArray *filterArray = [mutableStandardArray filteredArrayUsingPredicate:predicate];
            if(!filterArray){
                isResetAll = YES;
                * stop = YES;
            }
            else {
                [mutableStandardArray removeObjectsInArray:filterArray];
            }
        }];
    }
    NSLog(@"mutableStandardArray start = %@",mutableStandardArray);
    if(isResetAll) [self resetAllChannels:standardArray];
    else{
        if(mutableStandardArray.count) {
            [self addChannelToOperation:mutableStandardArray];
        }
    }
}

- (void)resetAllChannels:(NSMutableArray *)orgParams {
    NSMutableArray *params = [NSMutableArray arrayWithArray:orgParams];
    
    NSLog(@"最后崩溃的数据%@", params);
    
    XM_WS(weakself);
    NSDictionary *paramsDic = @{ @"chs" : [params lastObject] ? @[ [params lastObject] ] : [NSMutableArray new] };
    NSDictionary *payload = [self requestJsonDictionaryPayloadWithMethodName:@"set_channels"
                                                                       value:paramsDic];
    [self sendPayload:payload success:^(id respObj){
        [params removeLastObject];
        [weakself addChannelToOperation:params];
    } failure:nil];
}

- (void)addChannelToOperation:(NSMutableArray *)channels {
    NSMutableArray *params = [channels mutableCopy];
    
    NSMutableArray *operationGroup = [NSMutableArray new];
    NSInteger countTime = params.count / 3 + (params.count % 3 ? 1 : 0);
    for (int i = 0 ; i < countTime ; i ++){
        NSMutableArray *subParams = [NSMutableArray new];
        if (params.count > 3) {
            id obj1 = params[0];
            id obj2 = params[1];
            id obj3 = params[2];
            [subParams addObject:obj1];
            [subParams addObject:obj2];
            [subParams addObject:obj3];
            [params removeObject:obj1];
            [params removeObject:obj2];
            [params removeObject:obj3];
        }
        else {
            [subParams addObjectsFromArray:params];
        }
        
        void (^ operation)() = ^() {
            [self addChannels:subParams withCompletion:nil];
        };
        [operationGroup addObject:operation];
    }
    
    MHLMOperationQueueTools *operations = [[MHLMOperationQueueTools alloc] initWithOperationGroup:operationGroup];
    operations.delayTime = 0.3;
    [operations asyncSerialQueueOperate];
}

- (void)addChannels:(NSArray *)chs withCompletion:(void (^) (id obj))completion {
    NSDictionary *paramsDic = @{ @"chs" : chs };
    
    NSDictionary *payload = [self requestJsonDictionaryPayloadWithMethodName:@"add_channels"
                                                                       value:paramsDic];
    [self sendPayload:payload success:^(id respObj){
        if(completion)completion(respObj);
    } failure:^(NSError *error){
        NSLog(@"add_channels error = %@",error);
        if(completion)completion(error);
    }];
}

- (void)removeChannels:(NSArray *)chs withCompletion:(void (^)(id obj))completion {
    NSDictionary *paramsDic = @{ @"chs" : chs };
    
    NSDictionary *payload = [self requestJsonDictionaryPayloadWithMethodName:@"remove_channels"
                                                                       value:paramsDic];
    [self sendPayload:payload success:^(id respObj){
        if(completion)completion(respObj);
    } failure:^(NSError *error){
        NSLog(@"add_channels error = %@",error);
        if(completion)completion(error);
    }];
}

- (void)fetchGatewayFMChannels:(NSInteger)startIndex
                   withSuccess:(SucceedBlock)success
                       failure:(FailedBlock)failure {
    NSDictionary *params = @{
                             @"start" : @(startIndex),
                             };

    NSDictionary *payload = [self requestJsonDictionaryPayloadWithMethodName:@"get_channels"
                                                                       value:params];

    [self sendPayload:payload success:^(id respObj){
        NSArray *results = nil;
        if([[respObj valueForKey:@"result"] isKindOfClass:[NSDictionary class]]){
            results = [[respObj valueForKey:@"result"] valueForKey:@"chs"];
        }
        if(success)success(results);
        
    } failure:^(NSError *error) {
        if (failure)failure(error);
    }];
}

- (void)playRadioWithMethod:(NSString *)method
                 andSuccess:(SucceedBlock)success
                 andFailure:(FailedBlock)failure {
    NSDictionary *payload = [self requestPayloadWithMethodName:@"play_fm"
                                                         value:method];
    [self sendPayload:payload success:^(id respObj) {
        if (success) success(respObj);
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

#pragma mark - 获取timer
- (NSString *)hasOpenNightLightTimer:(NSString *)title {
    NSString *names = [NSString string];
    for (MHDataDeviceTimer *timer in self.powerTimerList){
        if ([timer.identify isEqualToString:@"lumi_gateway_single_rgb_timer"]){
            if ([title isEqualToString:@"title"]) return [timer timerTitle];
            else if ([title isEqualToString:@"detail"]) return [timer timerDetail];
        }
    }
    return names;
}

- (MHDataDeviceTimer *)hasOpenNightLightTimer {
    //powerTimerList 里面既有警戒的判断，又有开关灯的判断,lumi_gateway_single_rgb_timer 为夜灯定时器
    for (MHDataDeviceTimer *timer in self.powerTimerList){
        if ([timer.identify isEqualToString:@"lumi_gateway_single_rgb_timer"]){
            return timer;
        }
    }
    return nil;
}

#pragma mark : 重写gettimerlist
- (void)getTimerListWithSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    XM_WS(weakself);
    [self restoreTimerListWithFinish:nil];
    
    __block BOOL alarmTimerSuccess;
    __block BOOL alarmTimerFailure;
    __block BOOL nightlightTimerSuccess;
    __block BOOL nightlightTimerFailure;
    __block BOOL fmTimerSuccess;
    __block BOOL fmTimerFailure;
    __block BOOL clockTimerSuccess;
    __block BOOL clockTimerFailure;
    
    __block void (^completionBlock)() = ^(){
        if(alarmTimerSuccess && nightlightTimerSuccess && fmTimerSuccess && clockTimerSuccess){
            if(success)success(nil);
        }
        if(alarmTimerFailure || nightlightTimerFailure || fmTimerFailure || clockTimerFailure){
            if(failure)failure(nil);
        }
    };
    
    [self getTimerListWithIdentify:@"lumi_gateway_arming_timer" success:^(id obj){
        [weakself removeOldTimerWithIdentify:@"lumi_gateway_arming_timer" andTimerArray:(NSArray *)obj];
        alarmTimerSuccess = YES;
        completionBlock();
    } failure:^(NSError *error){
        alarmTimerFailure = YES;
        completionBlock();
    }];
    
    [self getTimerListWithIdentify:@"lumi_gateway_single_rgb_timer" success:^(id obj){
        [weakself removeOldTimerWithIdentify:@"lumi_gateway_single_rgb_timer" andTimerArray:(NSArray *)obj];
        nightlightTimerSuccess = YES;
        completionBlock();
    } failure:^(NSError *v) {
        nightlightTimerFailure = YES;
        completionBlock();
    }];
    
    [self getTimerListWithIdentify:@"lumi_gateway_single_fmclose_timer" success:^(id obj){
        [weakself removeOldTimerWithIdentify:@"lumi_gateway_single_fmclose_timer" andTimerArray:(NSArray *)obj];
        fmTimerSuccess = YES;
        completionBlock();
    } failure:^(NSError *v) {
        fmTimerFailure = YES;
        completionBlock();
    }];
    
    [self getTimerListWithIdentify:@"lumi_gateway_clock_timer" success:^(id obj) {
        [weakself removeOldTimerWithIdentify:@"lumi_gateway_clock_timer" andTimerArray:(NSArray *)obj];
        clockTimerSuccess = YES;
        completionBlock();
    } failure:^(NSError *v) {
        clockTimerFailure = YES;
        completionBlock();
    }];
}

- (void)removeOldTimerWithIdentify:(NSString *)identify andTimerArray:(NSArray *)array {
    NSMutableArray *timerarray = [NSMutableArray arrayWithCapacity:1];
    timerarray = [self.powerTimerList mutableCopy];
    
    for (MHDataDeviceTimer *timer in self.powerTimerList){ //取出旧的timer
        if([timer.identify isEqualToString:identify]){
            //用新的timer替换
            [timerarray removeObject:timer];
        }
    }
    if([array isKindOfClass:[NSArray class]]) {
        if(timerarray) [timerarray addObjectsFromArray:array];
        else timerarray = [array mutableCopy];
    }
    self.powerTimerList = timerarray;
    [self saveTimerList];
}

- (void)addFMCloseNewTimer:(NSInteger)minutes WithSuccess:(SucceedBlock)success andFailure:(FailedBlock)failure {
    NSDate *currentTime = [NSDate date];
    
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    calendar.timeZone = [NSTimeZone systemTimeZone];

    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    [adcomps setMinute:+ minutes];
    
    NSDate *endDate = [calendar dateByAddingComponents:adcomps toDate:currentTime options:0];
    
    MHDataDeviceTimer* timer = [self hasFMCloseTimer];
    if (!timer) {
        timer = [[MHDataDeviceTimer alloc] init];
    }
    timer.identify = @"lumi_gateway_single_fmclose_timer";
    timer.offMethod = @"play_fm";
    timer.offParam = @[ @"off" ];
    timer.offMinute = [calendar component:NSCalendarUnitMinute fromDate:endDate];
    timer.offHour = [calendar component:NSCalendarUnitHour fromDate:endDate];
//    timer.offDay = [calendar component:NSCalendarUnitDay fromDate:endDate];
//    timer.offMonth = [calendar component:NSCalendarUnitMonth fromDate:endDate];
    timer.offRepeatType = MHDeviceTimerRepeat_Once;
    timer.onRepeatType = MHDeviceTimerRepeat_Once;
    timer.isOffOpen = YES;
    timer.isOnOpen = NO;
    [timer updateTimerMonthAndDayForRepeatOnceType];
    timer.isEnabled = YES;
    
    [self editTimer:timer success:^(id obj){
        NSMutableArray *tmpList = [NSMutableArray arrayWithArray:self.powerTimerList];
        [tmpList addObject:timer];
        self.powerTimerList = [tmpList mutableCopy];
        [self saveTimerList];
        if (success)success(obj);
        
    } failure:^(NSError *error){
        if(failure)failure(error);
    }];
}

- (MHDataDeviceTimer *)hasFMCloseTimer {
    for (MHDataDeviceTimer *timer in self.powerTimerList){
        if ([timer.identify isEqualToString:@"lumi_gateway_single_fmclose_timer"]){
            return timer;
        }
    }
    return nil;
}

- (void)deleteFMCloseTimerWithSuccess:(SucceedBlock)success andFailure:(FailedBlock)failure {
    MHDataDeviceTimer* timer = [self hasFMCloseTimer];
    if (!timer){
        if (success)success(nil);
    }
    else {
        [self deleteTimerId:timer.timerId success:^(id obj){
            NSMutableArray *tmpList = [NSMutableArray arrayWithArray:self.powerTimerList];
            [tmpList removeObject:timer];
            self.powerTimerList = [tmpList mutableCopy];
            [self saveTimerList];
            if (success)success(obj);

        } failure:^(NSError *error){
            if(failure)failure(error);
        }];
    }
}

#pragma mark -
- (NSString* )corridorOnTimeString {
    int mins = (int)(self.corridor_on_time / 60);
    switch (mins) {
        case 1:
            return NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.holdtime.1",@"plugin_gateway","1分钟");
        case 2:
            return NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.holdtime.2",@"plugin_gateway","2分钟");
        case 5:
            return NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.holdtime.5",@"plugin_gateway","5分钟");
        case 10:
            return NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.holdtime.10",@"plugin_gateway","10分钟");
        default:
            return NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.holdtime.1",@"plugin_gateway","1分钟");
    }
}

#pragma mark - 懒人闹钟

- (void)getAlarmClockData:(SucceedBlock)success
                  failure:(FailedBlock)failure {
    XM_WS(weakself);
    NSDictionary *payload = [self requestPayloadWithMethodName:@"get_clock"
                                                         value:@[]];
    [self sendPayload:payload success:^(id respObj) {
        if([[respObj valueForKey:@"result"] isKindOfClass:[NSDictionary class]]){
            weakself.alarm_clock = [respObj valueForKey:@"result"];
            [weakself parseDeviceValue:weakself.alarm_clock];
            if (success) success(respObj);
        }
    } failure:^(NSError *error) {
        [weakself restoreClockStatus];
        if (failure) failure(error);
    }];
}

- (void)setAlarmClockDataWithEnable:(SucceedBlock)success
                            failure:(FailedBlock)failure {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
    [array addObject:@(self.alarm_clock_hour)];
    [array addObject:@(self.alarm_clock_min)];
    [array addObject:@(self.alarm_clock_day)];
    [array addObject:@(self.alarm_clock_enable)];
    [array addObject:@(5)];
    XM_WS(weakself);
    NSDictionary *payload = [self requestPayloadWithMethodName:@"set_clock" value:array];
    [self sendPayload:payload success:^(id respObj) {
        [weakself saveClockStatus];
        if (success) {
            success(respObj);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)parseDeviceValue:(id)dic {
    self.alarm_clock_hour = [[dic valueForKey:@"Hour"] intValue];
    self.alarm_clock_min = [[dic valueForKey:@"Min"] intValue];
    self.alarm_clock_day = [[dic valueForKey:@"Day"] intValue];
    
    self.alarm_clock_music = [[dic valueForKey:@"Music"] intValue];
    self.clock_volume = [[dic valueForKey:@"ClockVol"] intValue];
    self.alarm_clock_enable = [[dic valueForKey:@"Enable"] intValue];
    self.alarm_clock_duration = [[dic valueForKey:@"MusicTime"] intValue];
    self.alarm_clock_timer = [self parseClockValueToTimer];
    
    //如果没有Dura
    int indexkeyDur = (int)[[dic allKeys] indexOfObject:@"MusicTime"];
    if(indexkeyDur == -1) self.alarm_clock_duration = 5;
    
    [self saveClockStatus];
}

- (MHDataDeviceTimer *)parseClockValueToTimer {
    MHDataDeviceTimer *timer = [[MHDataDeviceTimer alloc] init];
    timer.onHour = self.alarm_clock_hour;
    timer.onMinute = self.alarm_clock_min;
    timer.onRepeatType = self.alarm_clock_day;
    timer.onMethod = timer.offMethod = @"set_clock";
    return timer;
}



//计算闹钟重复所显示的日期格式
- (NSString *)parseDayValue:(int)day timer:(MHDataDeviceTimer *)timer {
    
    if (timer)
        return [timer getOnRepeatTypeString];
    
    if (day == 0) return NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.once",@"plugin_gateway","一次");
    else{
        int value = day;
        NSMutableString *string = [NSMutableString string];
        while (value){
            [string insertString:(value & 1)? @"1": @"0" atIndex:0];
            value /= 2;
        }
        if ([string isEqualToString:@"11111"]) //周一到周五
            return NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmclock.repeat.workday",@"plugin_gateway","周一到周五");
        else if ([string isEqualToString:@"1111111"])
            return NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.everyday",@"plugin_gateway","每天");
        else if ([string isEqualToString:@"1100000"])
            return NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.weekend",@"plugin_gateway","周末");
        else{
            NSString *daystring = [NSString string];
            int i = 0;
            while (i<7){
                if (day & 1) {
                    if (i == 0){
                        daystring = [daystring stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.mon",@"plugin_gateway","一")];
                        daystring = [daystring stringByAppendingString:@","];
                    }
                    else if (i ==1){
                        daystring = [daystring stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.tues",@"plugin_gateway","二")];
                        daystring = [daystring stringByAppendingString:@","];
                    }
                    else if (i ==2){
                        daystring = [daystring stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.wed",@"plugin_gateway","三")];
                        daystring = [daystring stringByAppendingString:@","];
                    }
                    else if (i ==3){
                        daystring = [daystring stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.thur",@"plugin_gateway","四")];
                        daystring = [daystring stringByAppendingString:@","];
                    }
                    else if (i ==4){
                        daystring = [daystring stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.fri",@"plugin_gateway","五")];
                        daystring = [daystring stringByAppendingString:@","];
                    }
                    else if (i ==5){
                        daystring = [daystring stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.sat",@"plugin_gateway","六")];
                        daystring = [daystring stringByAppendingString:@","];
                    }
                    else if (i ==6){
                        daystring = [daystring stringByAppendingString:NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.sun",@"plugin_gateway","日")];
                        daystring = [daystring stringByAppendingString:@","];
                    }
                }
                day /= 2;
                i ++;
            }
            return daystring;
        }
    }
    
    return NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.everyday",@"plugin_gateway","每天");
}

- (void)setClockAlarmTimeSpan:(int)minute Success:(SucceedBlock)success andFailure:(FailedBlock)failure {
    NSDictionary *payload = [self requestPayloadWithMethodName:@"set_clock" value:@[ @(0),@(0),@(0),@(0),@(minute)]];
    
    [self sendPayload:payload success:^(id obj) {
        if (success) success(obj);

    } failure:^(NSError *error) {
        if (failure) failure(error);

    }];
}

#pragma mark - 缓存clock数据
- (void)saveClockStatus {
    [[NSUserDefaults standardUserDefaults] setObject:@(self.alarm_clock_hour) forKey:[NSString stringWithFormat:@"gateway_alarm_clock_hour_%@",self.did]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.alarm_clock_min) forKey:[NSString stringWithFormat:@"gateway_alarm_clock_min_%@",self.did]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.alarm_clock_day) forKey:[NSString stringWithFormat:@"gateway_alarm_clock_day_%@",self.did]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.alarm_clock_music) forKey:[NSString stringWithFormat:@"gateway_alarm_clock_music_%@",self.did]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.clock_volume) forKey:[NSString stringWithFormat:@"gateway_alarm_clock_clockVolum_%@",self.did]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.alarm_clock_enable) forKey:[NSString stringWithFormat:@"gateway_alarm_clock_enable_%@",self.did]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.alarm_clock_duration) forKey:[NSString stringWithFormat:@"gateway_alarm_clock_duration_%@",self.did]];
}

- (id)restoreClockStatus {
    self.alarm_clock_hour = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_alarm_clock_hour_%@",self.did]] intValue];
    self.alarm_clock_min = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_alarm_clock_min_%@",self.did]] intValue];
    self.alarm_clock_day = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_alarm_clock_day_%@",self.did]] intValue];
    self.alarm_clock_music = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_alarm_clock_music_%@",self.did]] intValue];
    self.clock_volume = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_alarm_clock_clockVolum_%@",self.did]] intValue];
    self.alarm_clock_enable = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_alarm_clock_enable_%@",self.did]] intValue];
    self.alarm_clock_duration = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_alarm_clock_duration_%@",self.did]] intValue];
    
    self.alarm_clock = [NSMutableDictionary dictionaryWithCapacity:1];
    [self.alarm_clock setObject:@(self.alarm_clock_hour) forKey:@"Hour"];
    [self.alarm_clock setObject:@(self.alarm_clock_min) forKey:@"Min"];
    [self.alarm_clock setObject:@(self.alarm_clock_day) forKey:@"Day"];
    [self.alarm_clock setObject:@(self.alarm_clock_music) forKey:@"Music"];
    [self.alarm_clock setObject:@(self.alarm_clock_enable) forKey:@"Enable"];
    [self.alarm_clock setObject:@(self.clock_volume) forKey:@"ClockVol"];
    [self.alarm_clock setObject:@(self.alarm_clock_duration) forKey:@"MusicTime"];
    
    self.alarm_clock_timer = [self parseClockValueToTimer];
    return self.alarm_clock;
}

#pragma mark - 设置色彩，获取色彩
- (void)setNightLightWithRGBA:(NightLightColorSences)rgba {
    NSUInteger colorValue = [(NSNumber *)colorSences[rgba] unsignedIntegerValue];
    [self setProperty:NIGHT_LIGHT_RGB_INDEX value:@(colorValue) success:nil failure:nil];
    self.night_light_rgb = colorValue;
}

- (BOOL)getCurrentNightLightRGBACompareWith:(NightLightColorSences)rgba {
    if ([(NSNumber *)colorSences[rgba] unsignedIntegerValue] == self.night_light_rgb)
        return YES;
    return NO;
}

- (UIColor *)setBackgroundViewRGBA:(NightLightColorSences)rgba {
    NSUInteger colorValue = [(NSNumber *)colorViewsSences[rgba] unsignedIntegerValue];
    
    int r = colorValue >> 16 & 0xff;
    int g = colorValue >> 8 & 0xff;
    int b = colorValue & 0xff;
    NSInteger a = colorValue >> 24;
    
    UIColor *color = [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:a/100.0f];
    return color;
}

#pragma mark - 数据缓存
- (void)saveStatus:(id)extraInfo {
    [[NSUserDefaults standardUserDefaults] setObject:self.corridor_light forKey:[NSString stringWithFormat:@"gateway_corridor_light_%@",self.did]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.corridor_on_time) forKey:[NSString stringWithFormat:@"gateway_corridor_on_time_%@",self.did]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.rgb) forKey:[NSString stringWithFormat:@"gateway_rgb_%@",self.did]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.night_light_rgb) forKey:[NSString stringWithFormat:@"gateway_night_light_rgb_%@",self.did]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.corridor_light_rgb) forKey:[NSString stringWithFormat:@"gateway_corridor_light_rgb_%@",self.did]];
    [[NSUserDefaults standardUserDefaults] setObject:self.mute forKey:[NSString stringWithFormat:@"gateway_mute_%@",self.did]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.illumination) forKey:[NSString stringWithFormat:@"gateway_illumination_%@",self.did]];
    [[NSUserDefaults standardUserDefaults] setObject:self.arming forKey:[NSString stringWithFormat:@"gateway_arming_%@",self.did]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.arming_time) forKey:[NSString stringWithFormat:@"gateway_arming_time_%@",self.did]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.gateway_volume) forKey:[NSString stringWithFormat:@"gateway_gateway_volume_%@",self.did]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.alarming_volume) forKey:[NSString stringWithFormat:@"gateway_alarming_volume_%@",self.did]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.doorbell_volume) forKey:[NSString stringWithFormat:@"gateway_doorbell_volume_%@",self.did]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.clock_volume) forKey:[NSString stringWithFormat:@"gateway_alarm_clock_clockVolum_%@",self.did]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.fm_volume) forKey:[NSString stringWithFormat:@"gateway_fm_volume_%@",self.did]];
    [[NSUserDefaults standardUserDefaults] setObject:self.doorbell_push forKey:[NSString stringWithFormat:@"gateway_doorbell_push_%@",self.did]];
    if (extraInfo) {
        [[NSUserDefaults standardUserDefaults] setObject:extraInfo forKey:[NSString stringWithFormat:@"extraInfo_%@",self.did]];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)restoreStatus {
    self.corridor_light = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_corridor_light_%@",self.did]];
    self.corridor_on_time = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_corridor_on_time_%@",self.did]] integerValue];
    self.rgb = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_rgb_%@",self.did]] integerValue];
    self.night_light_rgb = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_night_light_rgb_%@",self.did]] integerValue];
    self.corridor_light_rgb = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_corridor_light_rgb_%@",self.did]] integerValue];
    self.mute = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_mute_%@",self.did]];
    self.illumination = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_illumination_%@",self.did]] integerValue];
    self.arming = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_arming_%@",self.did]];
    self.arming_time = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_arming_time_%@",self.did]] integerValue];
    self.gateway_volume = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_gateway_volume_%@",self.did]] integerValue];
    self.alarming_volume = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_alarming_volume_%@",self.did]] integerValue];
    self.doorbell_volume = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_doorbell_volume_%@",self.did]] integerValue];
    self.clock_volume = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_alarm_clock_clockVolum_%@",self.did]] integerValue];
    self.fm_volume = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_fm_volume_%@",self.did]] integerValue];
    self.doorbell_push = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"gateway_doorbell_push_%@",self.did]];
    return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"extraInfo_%@",self.did]];
}

#pragma mark - 获取是否可以添加子设备的设备
- (NSArray *)gatewayModelsWithSubdeviceModel:(NSString *)model {
    NSMutableArray *gatewayModels = [NSMutableArray new];
   
    if ([gatewayOne containsObject:model]) {
        [gatewayModels addObject:kGatewayModelV1];
    }
    if ([gatewayTwo containsObject:model]) {
        [gatewayModels addObject:kGatewayModelV2];
    }
    if ([gatewayThree containsObject:model]) {
        [gatewayModels addObject:kGatewayModelV3];
    }
    if ([acpartnerOne containsObject:model]) {
        [gatewayModels addObject:kACPartnerModelV1];
    }
    
    return gatewayModels;
}



- (void)getCanAddSubDevice {
    static NSString *keyString = @"lumi_add_device_whlist";
    MHGatewayGetZipPDataRequest *req = [[MHGatewayGetZipPDataRequest alloc] init];
    req.keyString = keyString;
    [[MHNetworkEngine sharedInstance] sendRequest:req success:^(id json) {
        MHGatewayGetZipPDataResponse *rsp = [MHGatewayGetZipPDataResponse responseWithJSONObject:json andKeystring:keyString];

        NSMutableArray *gatewayModels = [NSMutableArray new];
        for (NSDictionary *modelDic in rsp.valueList){
            NSString *model = [modelDic valueForKey:@"model"];
            NSString *modelCutVersion = [model stringByReplacingOccurrencesOfString:@"." withString:@""];

            [gatewayModels addObject:modelCutVersion];
            
            if ([[modelDic valueForKey:@"flag"] integerValue] == 1){
                [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:modelCutVersion];
            }
            else {
                [[NSUserDefaults standardUserDefaults] setObject:@"no" forKey:modelCutVersion];
            }
        }
        
        if(gatewayModels.count){
            [[NSUserDefaults standardUserDefaults] setObject:gatewayModels forKey:@"lumi_gateway_models"];
        }
        else {
            NSArray *models = [[NSUserDefaults standardUserDefaults] valueForKey:@"lumi_gateway_models"];
            for(NSString *model in models) {
                [[NSUserDefaults standardUserDefaults] setObject:@"no" forKey:model];
            }
        }
        
    } failure:nil];
}

#pragma mark - 获取是否可以添加子设备的设备 公用配置
- (void)getPublicCanAddSubDevice {
    static NSString *keyString = @"lumi_add_device_flag";
    MHGatewayThirdDataRequest *req = [[MHGatewayThirdDataRequest alloc] init];
    req.keyString = keyString;
    [[MHNetworkEngine sharedInstance] sendRequest:req success:^(id json) {
        MHGatewayThirdDataResponse *rsp = [MHGatewayThirdDataResponse responseWithJSONObject:json andKeystring:keyString];
        
        NSMutableArray *gatewayModels = [NSMutableArray new];
        for (NSDictionary *modelDic in rsp.valueList){
            NSString *model = [modelDic valueForKey:@"model"];
            NSString *modelCutVersion = [model stringByReplacingOccurrencesOfString:@"." withString:@""];
            modelCutVersion = [modelCutVersion stringByAppendingString:@"public"];
            [gatewayModels addObject:modelCutVersion];
            
            if ([[modelDic valueForKey:@"flag"] integerValue] == 1){
                [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:modelCutVersion];
            }
            else {
                [[NSUserDefaults standardUserDefaults] setObject:@"no" forKey:modelCutVersion];
            }
        }
        
        if(gatewayModels.count){
            [[NSUserDefaults standardUserDefaults] setObject:gatewayModels forKey:@"lumi_gateway_models_public"];
        }
        else {
            NSArray *models = [[NSUserDefaults standardUserDefaults] valueForKey:@"lumi_gateway_models_public"];
            for(NSString *model in models) {
                [[NSUserDefaults standardUserDefaults] setObject:@"no" forKey:model];
            }
        }
        
    } failure:nil];

}




- (void)getVersionControlInfoWithSuccess:(SucceedBlock)success andFailure:(FailedBlock)failure {
    MHGatewayThirdDataRequest *request = [[MHGatewayThirdDataRequest alloc] init];
    request.keyString = @"lumi_gateway_ver_control";
    
    XM_WS(weakself);
    [[MHNetworkEngine sharedInstance] sendRequest:request success:^(id json) {
        MHGatewayThirdDataResponse *rsp = [MHGatewayThirdDataResponse responseWithJSONObject:json];
        [weakself saveVersionControlData:rsp.valueList];
        if(success)success(rsp.valueList);
    } failure:^(NSError *error) {
        if(failure)failure(error);
    }];
}

- (void)saveVersionControlData:(id)obj {
    NSString *userid = [MHPassportManager sharedSingleton].currentAccount.userId;
    NSData *archiveSceneTplData = [NSKeyedArchiver archivedDataWithRootObject:obj];
    [[NSUserDefaults standardUserDefaults] setObject:archiveSceneTplData forKey:[NSString stringWithFormat:@"lumi_gateway_version_%@",userid]];
}

//读取缓存自动化模版数据，包含启动条件和执行结果
- (id)restoreVersionControlData {
    NSString *userid = [MHPassportManager sharedSingleton].currentAccount.userId;
    NSData *myEncodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"lumi_gateway_version_%@",userid]];
    id parsedObj = [NSKeyedUnarchiver unarchiveObjectWithData:myEncodedObject];
    return parsedObj;
}

//-1000         位数不等不判断
//-1            app版本低
//-2            固件版本低
- (void)versionControl:(void (^)(NSInteger retcode))hardwareUpdate {
    __block NSDictionary *verData = [self restoreVersionControlData];
    
    if(verData){
        [self getVersionControlInfoWithSuccess:nil andFailure:nil];
        [self verJudge:verData withHardwareUpdate:^(NSInteger retcode){
            if(hardwareUpdate)hardwareUpdate(retcode);
        }];
    }
    else {
        XM_WS(weakself);
        [self getVersionControlInfoWithSuccess:^(id obj) {
            [weakself verJudge:obj withHardwareUpdate:^(NSInteger retcode){
                if(hardwareUpdate)hardwareUpdate(retcode);
            }];
        } andFailure:^(NSError *error) {
            if(hardwareUpdate)hardwareUpdate(-9999);
        }];
    }
}

//-1000         位数不等不判断
//-1            app版本低
//-2            固件版本低
- (NSInteger)verJudge:(NSDictionary *)verData withHardwareUpdate:(void (^)(NSInteger retcode))hardwareUpdate {
    XM_WS(weakself);

    //1,先判断app版本
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    appVersion = [appVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSDictionary *softwareVer = [verData valueForKey:@"software"];
    NSArray *cannotUseAppVerArray = [softwareVer valueForKey:@"canot_use_version"];
    NSString *minVer = [[softwareVer valueForKey:@"max_invalid_version"] valueForKey:@"main_app_version"];
    minVer = [minVer stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    //2,再判断固件版本
    NSString *gatewayVer = [[self.version stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""];
    NSDictionary *hardwareVer = [verData valueForKey:@"hardware"];
    NSArray *cannotUseGatewayVersionArray = [[hardwareVer valueForKey:@"canot_use_version"] valueForKey:self.model] ? [[hardwareVer valueForKey:@"canot_use_version"] valueForKey:self.model] : @[];
    NSString *minGatewayVer = [[hardwareVer valueForKey:@"max_invalid_version"] valueForKey:self.model];
    minGatewayVer = [[minGatewayVer stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""];
    //位数不等不判断
    if (gatewayVer.length != minGatewayVer.length) {
        if(hardwareUpdate)hardwareUpdate(1);
        return 1;
    }

    MHGatewayCheckUpdateView *updateView = [MHGatewayCheckUpdateView shareInstance];
    __weak MHGatewayCheckUpdateView *weakUpdateView = updateView;
    [updateView hide];
    if( appVersion && cannotUseAppVerArray && [cannotUseAppVerArray indexOfObject:appVersion] != NSNotFound) {
        [updateView showUpdateViewInfoHeight:150.f
                                    withInfo:NSLocalizedStringFromTable(@"checkversion.appupdate.appcannotuser", @"plugin_gateway", nil)];
        updateView.onUpdate = ^(){
            [weakself appStoreUpdate];
        };
        if(hardwareUpdate)hardwareUpdate(-1);
        return -1;
    }
    else if(appVersion && minVer && [appVersion integerValue] <= [minVer integerValue]){
        [updateView showUpdateViewInfoHeight:150.f
                                    withInfo:NSLocalizedStringFromTable(@"checkversion.appupdate.appcanupdate", @"plugin_gateway", nil)];
        updateView.onUpdate = ^(){
            [weakself appStoreUpdate];
        };
        if(hardwareUpdate)hardwareUpdate(-1);
        return -1;
    }
    else if( gatewayVer && cannotUseGatewayVersionArray && [cannotUseGatewayVersionArray indexOfObject:gatewayVer] != NSNotFound) {
        [updateView showUpdateViewInfoHeight:150.f
                                    withInfo:NSLocalizedStringFromTable(@"checkversion.hardware.cannotuser", @"plugin_gateway", nil)];
        updateView.onUpdate = ^(){
            if(hardwareUpdate)hardwareUpdate(-2);
            [weakUpdateView hide];
        };
        return -2;
    }
    else if(gatewayVer && minGatewayVer && [gatewayVer doubleValue] <= [minGatewayVer doubleValue]){
        [updateView showUpdateViewInfoHeight:150.f
                                    withInfo:NSLocalizedStringFromTable(@"checkversion.hardware.hardwarecanupdate", @"plugin_gateway", nil)];
        updateView.onUpdate = ^(){
            if(hardwareUpdate)hardwareUpdate(-2);
            [weakUpdateView hide];
        };
        return -2;
    }
    if(hardwareUpdate)hardwareUpdate(0);
    return 0;
}

- (void)appStoreUpdate {
    NSString *appleID = @"957323480";
    NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appleID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

#pragma mark - 判断是否为网关300以上的网关，（即除了网关200这些旧网关)
- (BOOL)laterV3Gateway{
    if ([self.model isEqualToString:kGatewayModelV1] || [self.model isEqualToString:kGatewayModelV2]){
        return NO;
    }
    return YES;
}

#pragma mark - 判断是否需要建立默认联动
- (void)getLumiBlindWithSuccess:(void (^)(NSInteger retcode))success failure:(void(^)(NSError *))failure{
    NSString *method = @"get_lumi_bind";
    NSString *params = @"scene";
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@( [self getRPCNonce] ) forKey:@"id"];
    [dic setObject:method forKey:@"method"];
    [dic setObject:@[params] forKey:@"params"];
    [self sendPayload:dic success:^(id obj) {
        NSLog(@"obj = %@ ", obj);
        NSString *message = [obj objectForKey:@"message"];
        if ([message isEqualToString:@"ok"] && success){
            NSDictionary *result = [obj objectForKey:@"result"];
            if (success){
                success([result[@"fac_scene_enable"] integerValue]);
            }
        }else if(failure) {
            failure(nil);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

//- (BOOL)isShowAlarmDelay{
//    if (![self.model isEqualToString:@"lumi.gateway.v1"]) {
//        return NO;
//    }
//    return YES;
//}
@end
