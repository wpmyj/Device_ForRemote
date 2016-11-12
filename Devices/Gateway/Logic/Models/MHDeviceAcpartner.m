//
//  MHDeviceAcpartner.m
//  MiHome
//
//  Created by guhao on 16/5/9.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHDeviceAcpartner.h"
#import "MHScenePushHandler.h"
#import "MHGatewayScenePushChildHandler.h"
#import "MHACPartnerTypeListResponse.h"
#import "MHACPartnerIrCodeListResponse.h"
#import "MHLumiPlugDataManager.h"
#import "MHLumiPlugQuantEngine.h"
#import "MHLMDecimalBinaryTools.h"
#import "MHGatewaySetZipPDataRequest.h"
#import "MHGatewaySetZipPDataResponse.h"
#import "MHGatewayGetZipPDataRequest.h"
#import "MHGatewayGetZipPDataResponse.h"
#import "MHLMACTipsView.h"

#define kACTYPELIST_URL @"https://app-api.aqara.cn/api/v1/ir/aclist/5"
#define kIRCODELIST_URL @"https://app-api.aqara.cn/api/v1/ir/brandic/%ld/5/1"
#define kIRCODELIST_Uncompressed_URL @"https://app-api.aqara.cn/api/v1/ir/brandic/%ld/5/2"
#define kNONBUTTON_URL  @"https://app-api.aqara.cn/api/v1/ir/irkeys/"
#define kNONREMOTE_URL  @"https://app-api.aqara.cn/api/v1/ir/remoteic/%@/1"
#define kExtraIrCode_URL @"https://app-api.aqara.cn/api/v1/ir/eids"
/**
 *  上传图片 post
 *
 *  @return deviceid,品牌名称,设备模型
 */
#define kUPLOAD_URL     @"https://app-api.aqara.cn/api/v1/ir/irrb/"
#define kLUMIAPPKEY     @"0EAC8846FED98634F460193A575B3CC4"
#define kDBAPPKEY       @"60095E329B9CA04FCFE98ED51B70CCD9"
#define kMIHOMEAPPKEY   @"87250803BEA2D0D1CCB7055DFAB036A3"



#define kGREEREMOTEID                       @"80222221"
#define kMIDEAREMOTEIDFIRST                 @"80111111"
#define kMIDEAREMOTEIDSECOND                @"80111112"
#define kHAIERREMOTEIDSECOND                @"80333331"
#define kPANASONICREMOTEIDFIRST             @"80444441"
#define kMATSUSHITREMOTEIDFIRST             @"80555551"
#define kAUXREMOTEIDFIRST                   @"80666661"
#define kCHIGOREMOTEIDFIRST                 @"80777771"

#define kGREEBRANDID                97
#define kMIDEABRANDID               182
#define kHAIERBRANDID               37
#define kMATSUSHITABRANDID          202
#define kPANASONICBRANDID           2782
#define kAUXBRANDID                 192
#define kCHIGOBRANDID               197


#define kMINONPOWER                 20 //开机临界功率
#define kMAXOFFPOWER                5 //关机
#define kOFFTOONPOWER               4 //关机到开机变化值


#define kExtraListKey                       @"acpartnerExtraIrCodeList"


static NSInteger scanFailure = -1;

static NSArray *specialMapArray;
const NSArray *modeArray;
const NSArray *windPowerArray;
static NSArray *noStatusCmdArray;

@interface MHDeviceAcpartner ()

@property (nonatomic, strong) NSTimer *scanTimer;
@property (nonatomic, assign) NSUInteger scanCount;

@property (nonatomic, strong) NSMutableArray *irIds;
@property (nonatomic, copy) NSString *remoteParams;


@property (nonatomic, copy) void (^callback)(NSInteger);
@property (nonatomic, copy) void (^getScanRetry)(NSInteger);
@property (nonatomic, copy) void (^updateCmdMap)(NSInteger currentIndex, NSInteger retryCount);
@property (nonatomic, copy) void (^saveCmdBlock)(NSDictionary *params);
@property (nonatomic, copy) void (^remoteMatchBlock)(void);


@property (nonatomic, copy) void (^scanBefore)(NSInteger);

@property (nonatomic, assign) NSInteger updateCmdMapCount;
@property (nonatomic, assign) NSInteger cmdMapRetryCount;

//扩展码库
@property (nonatomic, copy) NSArray *extraRemoteList;


@end


@implementation MHDeviceAcpartner

- (id)initWithData:(MHDataDevice* )data {
    if (self = [super initWithData:data]) {
        self.deviceBindPattern = MHDeviceBind_WithoutCheck;
        self.isNeedAutoBindAfterDiscovery = YES;
        self.isCanControlWhenOffline = YES;
            modeArray = @[ NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.mode.cool",@"plugin_gateway","制冷"),NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.mode.heat",@"plugin_gateway","制热"),NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.mode.auto",@"plugin_gateway","自动"), NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.mode.fan",@"plugin_gateway","送风") , NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.mode.dry",@"plugin_gateway","除湿")   ];
            windPowerArray = @[ NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.fanspeed.auto",@"plugin_gateway","自动风速"), NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.fanspeed.low",@"plugin_gateway","低速"), NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.fanspeed.medium",@"plugin_gateway","中速"), NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.fanspeed.high",@"plugin_gateway","高速")  ];
            specialMapArray = @[ @"fffffffc", @"1fffff00", @"0fffff00", @"2fffff00", @"1fffff01", @"1fffff02", @"0fffff01", @"0fffff02", @"2fffff01",@"2fffff02", @"0ffffff0"];
        
        //对应ACPARTNER_COMMAND_Id
        noStatusCmdArray = @[ @"EFFFFF00", @"EFFFFF00", @"feffff00", @"fffff300", @"fffff400",  @"FFFDFF00",  @"ffefff00",
                              @"efffff00", @"1fffff00", @"0fffff00", @"2fffff00", kOFFCOMMAND,  @"2fffff00",
                              @"F1FFFF00", @"F0FFFF00", @"F3FFFF00", @"FFF5FF00", @"FFF5FF00",   @"FFF5FF00 ", @"FFF1FF00",
                              @"FFEFFF00", @"FFF9FF00"];

    }
    return self;
}

+ (void)load {
    [MHDevListManager registerDeviceModelId:DeviceModelAcpartner className:NSStringFromClass([MHDeviceAcpartner class]) isRegisterBase:YES];
    //push
    [[MHScenePushHandler sharedInstance] registerScenePushDelegate:[MHGatewayScenePushChildHandler new]];
}


+ (NSUInteger)getDeviceType {
    return MHDeviceType_Gateway;
}

+ (NSString* )largeIconNameOfStatus:(MHDeviceStatus)status {
    return @"device_icon_acpartner";
}

+ (NSString* )smallIconName {
    return @"device_icon_acpartner";
}

+ (NSString* )guideImageNameOfOnline:(BOOL)isOnline {
    return isOnline ? @"device_icon_acpartner" : @"device_icon_acpartner";
}

+ (NSString* )guideLargeImageNameOfOnline:(BOOL)isOnline {
    return [self guideImageNameOfOnline:isOnline];
}

+ (NSString* )shareImageName {
    return @"device_icon_acpartner";
}

+ (BOOL)isDeviceAllowedToShown {
    return YES;
}




+ (NSString* )getViewControllerClassName {
    return @"MHACPartnerMainViewController";
}

+ (NSString* )uapWifiNamePrefix:(BOOL)isNewVersion {
    if (isNewVersion) {
        return @"Mi-Smart Home Kits";
    } else {
        return @"lumi-acpartner";
    }
}
- (NSString* )lightStatusAfterReset {
    return NSLocalizedStringFromTable(@"devcnnt.checklight.status.flicker.red", @"plugin_gateway", "红灯闪烁中");
}

- (NSString *)defaultName {
    return NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.acpartner", @"plugin_gateway", nil);
}

#pragma mark- 注册
- (void)registerAppAndInit {
    self.apikey = kLUMIAPPKEY;
    self.kkAcManager = [[KKACManager alloc] init];
    self.kkAcManager.apikey = self.apikey;
    self.ACVersion = 1;
    self.codeList = [[NSMutableArray alloc] init];
    self.acTypeList = [[NSMutableArray alloc] init];
    self.irIds = [[NSMutableArray alloc] init];
    self.pulseArray = [[NSMutableArray alloc] init];
    self.usableCodeList = [[NSMutableArray alloc] init];
    self.nonCodeList = [[NSMutableArray alloc] init];
    
    XM_WS(weakself);
    [[MHPlistCacheEngine sharedEngine] asyncLoadFromFile:[NSString stringWithFormat:@"%@", kACTYPELISTKEY] withFinish:^(id obj) {
        if ([obj isKindOfClass:[NSArray class]]) {
//            [weakself.acTypeList addObjectsFromArray:obj];
            weakself.acTypeList = [obj mutableCopy];
        }
    }];
    
}

-(NSDictionary *)getACDict:(NSDictionary *)dataDic
{
    NSLog(@"解析之前码库%@", dataDic);
    
    /**
     *keys =     (
     {
     id = 1;
     pulse = 0009F600FF;
     },
     {
     id = 2;
     pulse = 0009F601FE;
     },
     {
     id = 3;
     pulse = 0009F60AF5;
     },
     {
     id = 4;
     pulse = 0009F60BF4;
     },
     {
     id = 22;
     pulse = 0009F608F7;
     },
     {
     id = 23;
     pulse = 0009F603FC;
     },
     {
     id = 9362;
     pulse = 0009F609F6;
     },
     {
     id = 9367;
     pulse = 0009F602FD;
     }
     );
     */
    
    XM_WS(weakself);
    NSMutableDictionary *newExtsDic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *newDataDic = [[NSMutableDictionary alloc] init];

    for (NSDictionary *extsDic in dataDic[@"exts"]) {
        [newExtsDic setObject:[extsDic[@"value"] stringValue] forKey:[extsDic[@"tag"] stringValue]];
        if ([dataDic[@"type"] intValue] == 1 &&  [extsDic[@"tag"] integerValue] == 99999) {
            self.remoteParams = extsDic[@"value"];
        }
    }

    [newDataDic setObject:newExtsDic forKey:@"exts"];
    [newDataDic setObject:dataDic[@"frequency"] ? [dataDic[@"frequency"] stringValue] : @"38000" forKey:@"fre"];
    if ([dataDic[@"keys"] isKindOfClass:[NSArray class]] && [dataDic[@"keys"] count] > 0) {
        NSArray *keys = dataDic[@"keys"];
        [newDataDic setObject:keys forKey:@"keys"];
        self.irIds = [NSMutableArray new];
        self.pulseArray = [NSMutableArray new];
//        NSLog(@"id和命令数组%@", keys);
        [keys enumerateObjectsUsingBlock:^(NSDictionary *buttonDic, NSUInteger idx, BOOL * _Nonnull stop) {
            [weakself.irIds addObject:buttonDic[@"id"]];
            [weakself.pulseArray addObject:buttonDic[@"pulse"]];
        }];
//        NSLog(@"为什么是空的啊啊%@", weakself.pulseArray);
    }
    else {
        NSArray *keysArray = [[NSArray alloc] init];
        [newDataDic setObject:keysArray forKey:@"keys"];
    }
    [newDataDic setObject:[dataDic[@"id"] stringValue] forKey:@"rid"];
    [newDataDic setObject:[dataDic[@"type"] stringValue] forKey:@"type"];
//    NSLog(@"解析之后%@", newDataDic);

    return newDataDic;
}


#pragma mark - 向空调发送控制命令
- (void)sendCommand:(NSString *)command success:(SucceedBlock)success failure:(FailedBlock)failure {
//    XM_WS(weakself);
    NSDictionary *payload = [self requestPayloadWithMethodName:@"send_cmd" value:command];
    
    [self sendPayload:payload success:^(id obj) {
        if (success) success(obj);
        [[MHTipsView shareInstance] hide];
    } failure:^(NSError *error) {
        [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"operation.failed",@"plugin_gateway","操作失败, 请检查网络") duration:1.5f modal:NO];
        if (failure) failure(error);

    }];
}

- (void)sendIrCode:(NSString *)code success:(SucceedBlock)success failure:(FailedBlock)failure {
    NSDictionary *payload = [self requestPayloadWithMethodName:@"send_ir_code" value:code];
    
    [self sendPayload:payload success:^(id obj) {
        if (success) success(obj);
        
    } failure:^(NSError *error) {
        [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"operation.failed",@"plugin_gateway","操作失败, 请检查网络") duration:1.5f modal:NO];
        if (failure) failure(error);
        
    }];

}

#pragma mark - 发送场景的cmd给空调伴侣
- (void)saveCommandMap:(NSString *)command success:(SucceedBlock)success
               failure:(FailedBlock)failure {
    
    if (!self.ACRemoteId) {
        NSError *remoteIdError = [[NSError alloc] initWithDomain:@"remoteId is Null" code:10086 userInfo:nil];
        if (failure) failure(remoteIdError);
        return;
    }
    else if (self.ACType != 3 && command.length < 20) {
            NSError *irError = [[NSError alloc] initWithDomain:@"irCmd is Null" code:10010 userInfo:nil];
            if (failure) failure(irError);
        return;
    }
    
    NSDictionary *payload = [self requestPayloadWithMethodName:@"save_cmd_map" value:command];
    XM_WS(weakself);
    
    __block NSInteger count = 0;
//     void (^saveCmdBlock)(NSDictionary *params) = ^(NSDictionary *params) {
//           };
    
    [self setSaveCmdBlock:^(NSDictionary *params) {
        XM_SS(strongself, weakself);
        [weakself sendPayload:payload success:^(id obj) {
//            NSLog(@"保存场景成功密文%@%@", obj, command);
            if (success) {
                success(obj);
            }
        } failure:^(NSError *error) {
            NSLog(@"保存场景maperror错误%@", error);
            NSLog(@"错误时的%@", params);
            if (count < 3) {
                if (weakself.saveCmdBlock) weakself.saveCmdBlock(params);
            }
            else {
                if (failure) failure(error);
            }
        }];
        count++;

    }];
    
    self.saveCmdBlock(payload);
}

- (void)getCommandMapSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    NSDictionary *payload = [self requestPayloadWithMethodName:@"get_cmd_map" value:[NSMutableArray new]];
    
    XM_WS(weakself);
    [self sendPayload:payload success:^(id obj) {
//        NSLog(@"%@", obj);
        NSString *str = [obj[@"result"] firstObject];
        weakself.cmdMapList = [NSMutableArray arrayWithArray:[str componentsSeparatedByString:@","]];
        if (success) {
            success(obj);
        }
    } failure:^(NSError *error) {
        NSLog(@"设置场景map%@", error);
        if (failure) {
            failure(error);
        }
    }];
}

- (void)updateCommandMapSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    XM_WS(weakself);
    self.cmdMapRetryCount = 0;
    self.updateCmdMapCount = 0;
    
    if (!self.cmdMapList.count) {
        [self getCommandMapSuccess:^(id obj) {
            [weakself privateUpdateCommandMapSuccess:^(id obj) {
                if (success) success(obj);
            } failure:^(NSError *error) {
                if (failure) failure(error);
            }];
           
        } failure:^(NSError *error) {
            if (failure) failure(error);
        }];
    }
    else {
        [self privateUpdateCommandMapSuccess:^(id obj) {
            if (success) success(obj);
        } failure:^(NSError *error) {
            if (failure) failure(error);
        }];
    }

}

- (void)privateUpdateCommandMapSuccess:(SucceedBlock)success failure:(FailedBlock)failure {


    [self.cmdMapList removeObjectsInArray:specialMapArray];
//    NSLog(@"过滤之后的%@", self.cmdMapList);

    XM_WS(weakself);
    [self setUpdateCmdMap:^(NSInteger currentIndex, NSInteger retryCount) {
        if (weakself.updateCmdMapCount >= weakself.cmdMapList.count) {
            if (success) {
                success(nil);
            }
        }
        else {
            [weakself analyzeHexInfo:weakself.cmdMapList[weakself.updateCmdMapCount] decimalInfo:0 type:PROP_CHANGEIR];
            NSString *newCommand = nil;
            if (weakself.ACType == 1) {
                newCommand = [weakself generateCommandInfo:STAY_INDEX];
            }
            else {
                newCommand = [weakself generateStatusCommandInfo:STAY_INDEX commandIndex:TIMER_COMMAND];
            }
            //保存新的map
            [weakself saveCommandMap:newCommand success:^(id obj) {
                weakself.updateCmdMapCount++;
                if (weakself.updateCmdMap) {
                    weakself.updateCmdMap(weakself.updateCmdMapCount, 3);
                }
                weakself.cmdMapRetryCount = 0;
                
            } failure:^(NSError *v) {
                if (weakself.cmdMapRetryCount == 3) {
                    weakself.cmdMapRetryCount = 0;
                    weakself.updateCmdMapCount++;
                    if (weakself.updateCmdMapCount == weakself.cmdMapList.count - 1) {
                        if (success) {
                            success(nil);
                        }
                    }
                }
                if (weakself.updateCmdMapCount) {
                    weakself.updateCmdMap(weakself.updateCmdMapCount, weakself.cmdMapRetryCount);
                }
                weakself.cmdMapRetryCount++;
                
            }];
        }
        
    }];
    self.updateCmdMap(self.updateCmdMapCount, self.cmdMapRetryCount);

}

#pragma mark - 配置空调的型号,且发送控制命令
- (void)deployACByModel:(NSArray *)modelCmd success:(SucceedBlock)success failure:(FailedBlock)failure {
    NSDictionary *payload = [self requestPayloadWithMethodName:@"send_cmd_by_model" value:modelCmd];
    
    [self sendPayload:payload success:^(id obj) {
        if (success) success(obj);

    } failure:^(NSError *error) {
        NSLog(@"發送model和command失敗%@", error);
        if (failure) failure(error);

    }];
    
}

- (void)setACByModel:(NSString *)modelCmd success:(SucceedBlock)success failure:(FailedBlock)failure {
    NSDictionary *payload = [self requestPayloadWithMethodName:@"set_ac_model" value:modelCmd];
    XM_WS(weakself);
    void (^setModelBlock)(NSDictionary *params) = ^(NSDictionary *params) {
        [self sendPayload:payload success:^(id obj) {
//            NSLog(@"设置model和command成功%@", obj);
            if (success) success(obj);
            [weakself matchSuccessSaveOnOffCmd];
        } failure:^(NSError *error) {
            NSLog(@"设置model和command失敗%@", error);
            if (failure) failure(error);
        }];
    };
    setModelBlock(payload);
    
}

#pragma mark - 读取空调的型号和状态
/**
 *  空调的model和status,功率
 *
 *  @param success 数组, 3个参数
 *  @param failure 扫描失败
 */
- (void)getACTypeAndStatusSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    NSMutableArray *test = [NSMutableArray new];
    NSDictionary *payload = [self requestPayloadWithMethodName:@"get_model_and_state" value:test];
    
    [self sendPayload:payload success:^(id obj) {
//        NSLog(@"网关返回的结果%@", obj);
        if ([obj[@"result"] isKindOfClass:[NSArray class]] && [obj[@"result"]  count] >= 2) {
            if (success) success(obj[@"result"]);
        }
        else {
            if (failure) failure(nil);
        }

    } failure:^(NSError *error) {
        if (failure) failure(error);

    }];

}



- (BOOL)judgeModeCanControl:(ACPARTNER_PROP_TYPE)type {
    NSArray * array =[self.kkAcManager getAllModeState];
//    NSLog(@"%@", array);
    int modeState = 0;
    int currentMode = 0;
    switch (type) {
        case PROP_TIMER:
        currentMode = self.timerModeState;
        break;
        case PROP_POWER:
        currentMode = self.modeState;
        break;
        
        default:
        break;
    }
    
    modeState = [self showModeToSdkMode:currentMode];
    __block BOOL canControl = NO;
    [array enumerateObjectsUsingBlock:^(NSNumber *useMode, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([useMode intValue] == modeState) {
            canControl = YES;
            *stop = YES;
        }
    }];
    if (canControl) {
        NSInteger tempPower = [self.kkAcManager getPowerState];
        if (tempPower) {
            [self.kkAcManager changePowerStateWithPowerstate:AC_POWER_ON];
            [self.kkAcManager getPowerState];
        }
//        NSLog(@"要调的模式%d", modeState);
        [self.kkAcManager changeModeStateWithModeState:modeState];
        [self.kkAcManager getModeState];

//        NSLog(@"酷控调完以后的模式%d", [self.kkAcManager getModeState]);
        [self.kkAcManager getAirConditionInfrared];
        if (tempPower) {
            [self.kkAcManager changePowerStateWithPowerstate:AC_POWER_OFF];
            [self.kkAcManager getPowerState];
        }
    }
    return canControl;
}

- (void)updateCurrentModeStatus {
    
    self.temperature = [self.kkAcManager getTemperature];
    self.windPower = [self.kkAcManager getWindPower];
    self.windState = [self.kkAcManager getWindState];
    
    NSLog(@"改变模式后的风速%d", [self.kkAcManager getWindPower]);
    NSLog(@"改变模式后的扫风%d", [self.kkAcManager getWindState]);
    NSLog(@"改变模式后的温度%d", [self.kkAcManager getTemperature]);

}

- (BOOL)judgeTempratureCanControl:(ACPARTNER_PROP_TYPE)type {
    int currentTemp = 0;
    switch (type) {
        case PROP_TIMER:
        currentTemp = self.timerTemperature;
        break;
        case PROP_POWER:
        currentTemp = self.temperature;
        break;
        
        default:
        break;
    }

    
    if (([self.kkAcManager canControlTemp] == YES && currentTemp <= TEMPERATUREMAX && currentTemp >= TEMPERATUREMIN ) && [[self.kkAcManager getLackOfTemperatureArray] containsObject:[NSString stringWithFormat:@"%d",currentTemp]] == NO) {
//        NSLog(@"要调的温度%d", currentTemp);
        NSInteger tempPower = [self.kkAcManager getPowerState];
        if (tempPower) {
            [self.kkAcManager changePowerStateWithPowerstate:AC_POWER_ON];
            [self.kkAcManager getPowerState];
        }
        
        [self.kkAcManager changeTemperatureWithTemperature:currentTemp];
        [self.kkAcManager getTemperature];
        [self.kkAcManager getAirConditionInfrared];
//        NSLog(@"调完的温度%d", [self.kkAcManager getTemperature]);

        if (tempPower) {
            [self.kkAcManager changePowerStateWithPowerstate:AC_POWER_OFF];
            [self.kkAcManager getPowerState];
        }
        return YES;
    }
    
    return NO;
}

- (BOOL)judgeWindsCanControl:(ACPARTNER_PROP_TYPE)type {
   
//    XM_WS(weakself);
    __block BOOL canControlWids = NO;
    if (![self.kkAcManager canControlWindPower]) {
        return canControlWids;
    }
    int currentWindsPower = 0;
    switch (type) {
        case PROP_TIMER:
        currentWindsPower = self.timerWindPower;
        break;
        case PROP_POWER:
        currentWindsPower = self.windPower;
        break;
        
        default:
        break;
    }
#warning 有点问题
    [[self.kkAcManager getAllWindPower] enumerateObjectsUsingBlock:^(NSNumber *useWind, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([useWind intValue] == currentWindsPower) {
            canControlWids = YES;
            *stop = YES;
        }
    }];
    
    if (canControlWids) {
        NSInteger tempPower = [self.kkAcManager getPowerState];
        if (tempPower) {
            [self.kkAcManager changePowerStateWithPowerstate:AC_POWER_ON];
            [self.kkAcManager getPowerState];
        }

//        NSLog(@"要调的风速%d", currentWindsPower);
        [self.kkAcManager changeWindPowerWithWindpower:currentWindsPower];
        [self.kkAcManager getWindPower];
//        NSLog(@"要调的风速%d", [self.kkAcManager getWindPower]);
        [self.kkAcManager getAirConditionInfrared];
        if (tempPower) {
            [self.kkAcManager changePowerStateWithPowerstate:AC_POWER_OFF];
            [self.kkAcManager getPowerState];
        }

    }
    return canControlWids;
}

- (BOOL)judgeSwipCanControl:(ACPARTNER_PROP_TYPE)type {
//    XM_WS(weakself);
    __block BOOL canControlWids = NO;
    if (![self.kkAcManager canControlWindState]) {
        return canControlWids;
    }
    int currentWindsState = 0;
    switch (type) {
        case PROP_TIMER:
        currentWindsState = self.timerWindState;
        break;
        case PROP_POWER:
        currentWindsState = self.windState;
        break;
        
        default:
        break;
    }

    [[self.kkAcManager getAllWindState] enumerateObjectsUsingBlock:^(NSNumber *useWind, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([useWind intValue] == currentWindsState) {
            canControlWids = YES;
            *stop = YES;
        }
    }];
    NSInteger tempPower = [self.kkAcManager getPowerState];

    if (canControlWids) {
        if (tempPower) {
            [self.kkAcManager changePowerStateWithPowerstate:AC_POWER_ON];
            [self.kkAcManager getPowerState];
        }

//        NSLog(@"要调的风向%d", currentWindsState);
        [self.kkAcManager changeWindStateWithWindState:currentWindsState];
        [self.kkAcManager getWindState];
//        NSLog(@"调完以后的风向%d", [self.kkAcManager getWindState]);
        [self.kkAcManager getAirConditionInfrared];
    }
    if (tempPower) {
        [self.kkAcManager changePowerStateWithPowerstate:AC_POWER_OFF];
        [self.kkAcManager getPowerState];
    }
    return canControlWids;
}

#pragma mark - sdk与面板值转换
- (int)showModeToSdkMode:(int)showMode {
    int mode = 0;
    switch (showMode) {
        case 0:
        mode = TAG_AC_MODE_COOL_FUNCTION;
        break;
        case 1:
        mode = TAG_AC_MODE_HEAT_FUNCTION;
        
        break;
        case 2:
        mode = TAG_AC_MODE_AUTO_FUNCTION;
        
        break;
        case 3:
        mode = TAG_AC_MODE_FAN_FUNCTION;
        
        break;
        case 4:
        mode = TAG_AC_MODE_DRY_FUNCTION;

        break;
        
        default:
        break;
    }
    return mode;
}
- (int)writingToShowMode:(int)writing {
    int mode = 0;
    switch (writing) {
        case 0:
        mode = AC_MODE_HEAT;
        break;
        case 1:
        mode = AC_MODE_COOL;
        break;
        case 2:
        mode = AC_MODE_AUTO;
        break;
        case 3:
        mode = AC_MODE_DRY;
        break;
        case 4:
        mode = AC_MODE_FAN;
        break;
        
        default:
        break;
    }

    return mode;
}

- (int)sdkModeToShowModeTo:(int)sdkMode {
    int mode = 0;
    switch (sdkMode) {
        case TAG_AC_MODE_HEAT_FUNCTION:
        mode = AC_MODE_HEAT;
        break;
        case TAG_AC_MODE_COOL_FUNCTION:
        mode = AC_MODE_COOL;
        break;
        case TAG_AC_MODE_AUTO_FUNCTION:
        mode = AC_MODE_AUTO;
        break;
        case TAG_AC_MODE_DRY_FUNCTION:
        mode = AC_MODE_DRY;
        break;
        case TAG_AC_MODE_FAN_FUNCTION:
        mode = AC_MODE_FAN;
        break;
        
        default:
        break;
    }
    return mode;

}

- (int)showWindPowerToSdkWindPower:(int)showWindPower {
    int windPower = 0;
    switch (showWindPower) {
        case 3:
        windPower = AC_WIND_SPEED_AUTO;
        break;
        case 0:
        windPower = AC_WIND_SPEED_LOW;
        break;
        case 1:
        windPower = AC_WIND_SPEED_MEDIUM;
        break;
        case 2:
        windPower = AC_WIND_SPEED_HIGH;
        break;
        
        default:
        break;
    }

    return windPower;
}
- (int)showWindStateToSdkWindState:(int)showWindState {
    int windState = 0;
    
    return windState;
}


- (void)analyzeHexInfo:(NSString *)hexInfo decimalInfo:(int)decimalInfo type:(ACPARTNER_PROP_TYPE)type {
    NSLog(@"当前网关存的明文%@", hexInfo);
    NSString *commandInfo = nil;
    if (hexInfo) {
        commandInfo = hexInfo;
    }
    else {
        commandInfo = [MHLMDecimalBinaryTools decimalToHex:decimalInfo];
    }
    
    if (commandInfo.length < 8) {
        int addZero = (int)(8 - commandInfo.length);
        NSString *zero = @"";
        for (int i = 0; i < addZero; i++) {
            zero = [NSString stringWithFormat:@"0%@", zero];
        }
        commandInfo = [NSString stringWithFormat:@"%@%@", zero, commandInfo];
    }
//    NSLog(@"定时的参数%@", commandInfo);

    int tempACType = 0;
    int tempPowerState = 0;
    int tempModeState = 0;
    int tempWindPower = 0;
    int tempWindDirection = 0;
    int tempWindState = 0;
    int tempTemperature = 0;

    
    tempACType = [[commandInfo substringWithRange:NSMakeRange(7, 1)] intValue] + 1;
    tempPowerState = [[commandInfo substringWithRange:NSMakeRange(0, 1)] intValue];
    if (tempACType >= 2) {
        int infoMode = [[commandInfo substringWithRange:NSMakeRange(1, 1)] intValue];
        int infoWindPower = [[commandInfo substringWithRange:NSMakeRange(2, 1)] intValue];
        tempModeState = [self writingToShowMode:infoMode];
        
        tempWindPower = [self showWindPowerToSdkWindPower:infoWindPower];
    
        
        NSString *wind = [MHLMDecimalBinaryTools hexToBinary:[commandInfo substringWithRange:NSMakeRange(3, 1)]];
        tempWindDirection = [[MHLMDecimalBinaryTools binaryToDecimal:[wind substringWithRange:NSMakeRange(0, 2)]] intValue];
        tempWindState = [[MHLMDecimalBinaryTools binaryToDecimal:[wind substringWithRange:NSMakeRange(2, 2)]] intValue];
        int tempTemp = (int)strtoul([[commandInfo substringWithRange:NSMakeRange(4, 2)] UTF8String], 0, 16);
        if (tempTemp >= TEMPERATUREMIN && tempTemp <= TEMPERATUREMAX) {
            tempTemperature = tempTemp;
        }
        else {
            tempTemperature = 26;
        }
        
        NSString *strExtra = [commandInfo substringWithRange:NSMakeRange(6, 1)];
        
        if ([self isExtraRemoteId] && (![strExtra isEqualToString:@"0"] && ![strExtra isEqualToString:@"1"])) {
            NSString *strLed =  [MHLMDecimalBinaryTools hexToBinary:strExtra];
            self.ledState = ![[strLed substringWithRange:NSMakeRange(2, 1)] intValue];
        }
        else {
            self.ledState = 1;
        }

        
    }
    
    switch (type) {
        case PROP_TIMER:
        case PROP_CHANGEIR: {
            self.timerACType = self.ACType;
            self.timerPowerState = tempPowerState;
            self.timerModeState = tempModeState;
            self.timerWindPower = tempWindPower;
            self.timerWindDirection = tempWindDirection;
            self.timerWindState = tempWindState;
            self.timerTemperature = tempTemperature;
        }
            break;
        case PROP_POWER: {
            self.powerState = tempPowerState;
            self.modeState = tempModeState;
            self.windPower = tempWindPower;
            self.windDirection = tempWindDirection;
            self.windState = tempWindState;
            self.temperature = tempTemperature;
        }
            break;
            
        default:
            break;
    }
    
    if (type == PROP_CHANGEIR && self.ACType == 2) {
        if (self.timerPowerState == 0) {
            [self.kkAcManager changeModeStateWithModeState:AC_POWER_OFF];
        }
        else {
            [self.kkAcManager changeModeStateWithModeState:AC_POWER_ON];
        }
        [self.kkAcManager getPowerState];
        [self judgeModeCanControl:PROP_TIMER];
        [self judgeWindsCanControl:PROP_TIMER];
        [self judgeTempratureCanControl:PROP_TIMER];
        [self judgeSwipCanControl:PROP_TIMER];
    }
    
}

- (BOOL)isACMatched {
    BOOL isMatched = NO;
   BOOL match = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@", self.did, kHASSCANED]] boolValue];
    if (match && self.brand_id) {
        isMatched = YES;
    }
    
    return isMatched;
}


- (void)handleNewStatus:(NSArray *)status isRepeat:(BOOL)repeat {
    NSLog(@"当前空调的状态%@", status);
    XM_WS(weakself);
    /**
     *  010500970000260701,
        0111011A0100002607,
        18
     */
    
    NSString *strModel = [status firstObject];
    NSString *strCommand = status[1];
    if (status.count > 2) {
        self.ac_power = [status[2] floatValue];
    }
    
    
    NSString *strStatus = [strCommand substringWithRange:NSMakeRange(2, 8)];
    self.ACType = [[strModel substringWithRange:NSMakeRange(17, 1)] intValue] + 1;
    NSLog(@"%d", self.ACType);
    self.powerState = [[strStatus substringWithRange:NSMakeRange(0, 1)] intValue];
    
    [self analyzeHexInfo:strStatus decimalInfo:0 type:PROP_POWER];
    
    
    NSInteger newBrandid = [[strModel substringWithRange:NSMakeRange(4, 4)] integerValue];
    NSString *newRemoteID = [NSString stringWithFormat:@"%ld",[[strModel substringWithRange:NSMakeRange(8, 8)] integerValue]];
    if ([newRemoteID isEqualToString:@"0"]) {
        self.ACType = 0;
        [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:[NSString stringWithFormat:@"%@%@", self.did, kHASSCANED]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    
//    NSLog(@"%@, %d", strStatus, self.powerState);
    
    
    //    NSLog(@"新的品牌id和遥控器id---->%ld---%@", newBrandid, newRemoteID);
    //    NSLog(@"缓存品牌id和遥控器id---->%ld--%@", self.brand_id, self.ACRemoteId);
        //已经连接空调,品牌改变
        if (newBrandid && self.brand_id != newBrandid) {
            [self getIrCodeListWithBrandId:newBrandid Success:^(id obj) {
                [weakself updateACDataWithNewRemoteID:newRemoteID newBrandid:newBrandid];
            } Failure:^(NSError *v) {
                weakself.ACRemoteId = nil;
                weakself.brand_id = 0;
                weakself.ACType = 0;
            }];
        }
        //已经连接空调,码库改变
        if (newBrandid && newBrandid == self.brand_id && ![newRemoteID isEqualToString:self.ACRemoteId]) {
            if (self.codeList.count) {
                [self updateACDataWithNewRemoteID:newRemoteID newBrandid:newBrandid];
            }
            else {
                [self getIrCodeListWithBrandId:newBrandid Success:^(id obj) {
                    [weakself updateACDataWithNewRemoteID:newRemoteID newBrandid:newBrandid];
                } Failure:^(NSError *v) {
                    weakself.ACRemoteId = nil;
                    weakself.brand_id = 0;
                    weakself.ACType = 0;
                }];
            }
        }
        
        if (newBrandid && newBrandid == self.brand_id && [newRemoteID isEqualToString:self.ACRemoteId] && self.ACType == 3) {
            self.brand_id = newBrandid;
            self.ACRemoteId = newRemoteID;
            [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:[NSString stringWithFormat:@"isfirst%@%@", self.ACRemoteId,[MHPassportManager sharedSingleton].currentAccount.userId]];
            [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:[NSString stringWithFormat:@"%@%@", self.did, kHASSCANED]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self saveACStatus];
        }
        
        if (newBrandid && newBrandid == self.brand_id && [newRemoteID isEqualToString:self.ACRemoteId] && self.ACType == 2) {
            [self assignAndHandleAirData:repeat];
        }
    
}



#pragma mark - 学习遥控器
- (void)startLearnRemoteValue:(NSNumber *)value success:(SucceedBlock)success failure:(FailedBlock)failure {
    NSDictionary *payload =  [self requestPayloadWithMethodName:@"start_ir_learn" value:@[ value ? value : @(30) ]];
    
    [self sendPayload:payload success:^(id obj) {
        if (success) success(obj);
        
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

- (void)getLearnRemoteResultSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    NSDictionary *payload =  [self requestPayloadWithMethodName:@"get_ir_learn_result" value:[NSMutableArray new]];
    
    [self sendPayload:payload success:^(id obj) {
        if (success) success(obj);
        
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

- (void)endLearnRemoteSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    NSDictionary *payload =  [self requestPayloadWithMethodName:@"end_ir_learn" value:[NSMutableArray new]];
    
    [self sendPayload:payload success:^(id obj) {
        if (success) success(obj);
        
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

- (void)editLearnedRemoteList:(NSMutableArray *)valueList success:(SucceedBlock)success failure:(FailedBlock)failure {
    
//    NSMutableArray *valueList = [NSMutableArray new];
    NSString *keyString = [NSString stringWithFormat:@"%@_%@_%@", kAcpartnerCustomRemoteKeystring, self.did, self.ACRemoteId];
    MHGatewaySetZipPDataRequest *rq = [[MHGatewaySetZipPDataRequest alloc] init];
    rq.value = valueList;
    rq.keyString = keyString;
    XM_WS(weakself);
    [[MHNetworkEngine sharedInstance] sendRequest:rq success:^(id obj){
        MHGatewaySetZipPDataResponse *rep = [MHGatewaySetZipPDataResponse responseWithJSONObject:obj];
        NSLog(@"设置的结果%@", rep.result);
        [[MHPlistCacheEngine sharedEngine] asyncSave:weakself.customFunctionList toFile:[NSString stringWithFormat:@"%@%@", weakself.did, [MHPassportManager sharedSingleton].currentAccount.userId] withFinish:^(NSInteger ret) {
            NSLog(@"保存的结果%ld", ret);
        }];
        if (success) success(obj);

    } failure:^(NSError *error){
        if (failure) failure(error);

    }];

}

- (void)getLearnedRemoteListSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    XM_WS(weakself);
    
//    NSLog(@"取数据的时候%@ %@", self.did, self.ACRemoteId);
    
    NSString *keyString = [NSString stringWithFormat:@"%@_%@_%@", kAcpartnerCustomRemoteKeystring, self.did, self.ACRemoteId];
    MHGatewayGetZipPDataRequest *rq = [[MHGatewayGetZipPDataRequest alloc] init];
    rq.keyString = keyString;
    
    [[MHPlistCacheEngine sharedEngine] asyncLoadFromFile:[NSString stringWithFormat:@"%@%@", weakself.did, [MHPassportManager sharedSingleton].currentAccount.userId] withFinish:^(id obj) {
        self.customFunctionList = [NSMutableArray arrayWithArray:obj];
        NSLog(@"缓存的数据为什么没有%@", self.customFunctionList);
    }];
    
    
    [[MHNetworkEngine sharedInstance] sendRequest:rq success:^(id obj){
        MHGatewayGetZipPDataResponse *rep = [MHGatewayGetZipPDataResponse responseWithJSONObject:obj andKeystring:keyString];
//        NSLog(@"获取的pdata按键数据%@", rep.valueList);
        weakself.customFunctionList = [NSMutableArray arrayWithArray:rep.valueList];
        if (success) success(obj);
        
    } failure:^(NSError *error){
        if (failure) failure(error);

    }];

}

#pragma mark - 速冷模式
- (void)setCoolSpeed:(NSArray *)params success:(SucceedBlock)success failure:(FailedBlock)failure {
    NSDictionary *payload =  [self requestPayloadWithMethodName:@"set_quick_cool_func" value:params];
    
    [self sendPayload:payload success:^(id obj) {
        if (success) success(obj);
        
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

- (void)getCoolSpeedResultSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    NSDictionary *payload =  [self requestPayloadWithMethodName:@"get_quick_cool_func" value:[NSMutableArray new]];
    
    [self sendPayload:payload success:^(id obj) {
        if (success) success(obj);
        
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}


#pragma mark - 睡眠模式
- (void)setSleepMode:(NSArray *)params success:(SucceedBlock)success failure:(FailedBlock)failure {
    NSDictionary *payload =  [self requestPayloadWithMethodName:@"set_sleep_func" value:params];
    
    [self sendPayload:payload success:^(id obj) {
        if (success) success(obj);
        
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

- (void)getSleepModeResultSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    NSDictionary *payload =  [self requestPayloadWithMethodName:@"get_sleep_func" value:[NSMutableArray new]];
    
    [self sendPayload:payload success:^(id obj) {
        if (success) success(obj);
        
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

#pragma mark - 遥控器匹配
- (void)startRemoteMatchParams:(NSArray *)params success:(SucceedBlock)success failure:(FailedBlock)failure {
   NSDictionary *payload =  [self requestPayloadWithMethodName:@"start_ir_match" value:params];
    
    [self sendPayload:payload success:^(id obj) {
        if (success) success(obj);

    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

- (void)getRemoteMatchResultSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    NSDictionary *payload =  [self requestPayloadWithMethodName:@"get_ir_match_result" value:[NSMutableArray new]];

    [self sendPayload:payload success:^(id obj) {
        if (success) success(obj);
        
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}


- (void)endRemoteMatchSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    NSDictionary *payload =  [self requestPayloadWithMethodName:@"end_ir_match" value:[NSMutableArray new]];
    
    [self sendPayload:payload success:^(id obj) {
        if (success) success(obj);
        
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}

- (void)setRemoteMatchResultSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    XM_WS(weakself);
    //设置model
    [self setRemoteMatchBlock:^{
        [weakself manualMatchSuccess:^(id obj) {
            if (success) success(obj);
            
        } failure:^(NSError *error) {
            if (failure) failure(error);
            
        }];
    }];

    //计算remoteID的index
    if (self.codeList.count) {
        [self.codeList enumerateObjectsUsingBlock:^(NSDictionary *dataDic, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[dataDic[@"id"] stringValue] isEqualToString:weakself.ACRemoteId]) {
                weakself.currentCodeIndex = idx;
                if (weakself.remoteMatchBlock) weakself.remoteMatchBlock();

                
                *stop = YES;
            }
        }];
    }
    else {
        [self getIrCodeListWithBrandId:self.brand_id Success:^(id obj) {
            [weakself.codeList enumerateObjectsUsingBlock:^(NSDictionary *dataDic, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([[dataDic[@"id"] stringValue] isEqualToString:weakself.ACRemoteId]) {
                    weakself.currentCodeIndex = idx;
                    if (weakself.remoteMatchBlock) weakself.remoteMatchBlock();
                    *stop = YES;
                }
            }];
        } Failure:^(NSError *error) {
            if (failure) failure(error);

        }];

    }
}
#pragma mark - 手动匹配
- (void)manualMatchSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    XM_WS(weakself);
    if (self.codeList.count) {
        [self generateModelAndCommand:self.codeList[self.currentCodeIndex]];
        
        [self setACByModel:[self getACModel] success:^(id obj) {
            if (success) success(obj);

        } failure:^(NSError *error) {
            if (failure) failure(error);

        }];
    }
    else {
        [self getIrCodeListWithBrandId:self.brand_id Success:^(id obj) {
            [weakself generateModelAndCommand:weakself.codeList[weakself.currentCodeIndex]];
            
            [self setACByModel:[weakself getACModel] success:^(id resp) {
                if (success) success(obj);

            } failure:^(NSError *error) {
                if (failure) failure(error);

            }];
        } Failure:^(NSError *error) {
            if (failure) failure(error);

        }];
    }
}

#pragma mark - 自动匹配
- (void)scanACType:(int)count success:(SucceedBlock)success failure:(FailedBlock)failure {
    XM_WS(weakself);
    
    NSDictionary *payload = [self requestPayloadWithMethodName:@"start_scan_model" value:@(count)];
    
    [self sendPayload:payload success:^(id obj) {
//        NSLog(@"開始掃描%@", obj);
        [weakself initMatchPowerState];
        //扫描前确认功率
        [weakself confirmOriginalPowerBeforeScanSuccess:^(id obj) {
            [weakself scanAcSuccess:^(id obj) {
                [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:[NSString stringWithFormat:@"%@%@", weakself.did, kHASSCANED]];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if (success) success(obj);

            } failure:^(NSError *error) {
                if (failure) failure(error);

            }];

        } failure:^(NSError *error) {
            if ([error.domain isEqualToString:CancleAutoMatch]) {
                if (failure) failure(error);
                return;
            }
            [weakself scanAcSuccess:^(id obj) {
                [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:[NSString stringWithFormat:@"%@%@", weakself.did, kHASSCANED]];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if (success) success(obj);

                
            } failure:^(NSError *error) {
                if (failure) failure(error);

            }];
        }];
        
        
    } failure:^(NSError *error) {
        if (failure) {
            NSLog(@"发送开始扫描指令失败%@",error);
            failure(error);
        }
    }];
}

- (void)confirmOriginalPowerBeforeScanSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    XM_WS(weakself);
//    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.power",@"plugin_gateway", "等待空调功率稳定中") modal:YES];
    __block BOOL cancleAutoMatch = NO;
    
    [[MHLMACTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.power",@"plugin_gateway", "等待空调功率稳定中") modal:YES handle:^{
        cancleAutoMatch = YES;
    }];
    
    __block NSInteger count = 0;
    [self setScanBefore:^(NSInteger index) {
        CGFloat delay = 2.0f;
        if (cancleAutoMatch) {
            NSError *cancleError = [[NSError alloc] initWithDomain:CancleAutoMatch code:10086 userInfo:nil];
            if (failure) failure(cancleError);
            return;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            [weakself getACDeviceProp:AC_POWER_ID success:^(id obj) {
                if (cancleAutoMatch) {
                    NSError *cancleError = [[NSError alloc] initWithDomain:CancleAutoMatch code:10086 userInfo:nil];
                    if (failure) failure(cancleError);
                    return;
                }
                [weakself initMatchPowerState];
                //从开到关取最小
                if (weakself.powerState == 1 && weakself.ac_power < weakself.original_power) {
                    weakself.original_power = weakself.ac_power;
                }
                //从关到开取最大
                if (weakself.powerState == 0 && weakself.ac_power >= weakself.original_power) {
                    weakself.original_power = weakself.ac_power;
                }

                if (index >= 3) {
                    if (success) success(obj);

                }
                else {
                    if (weakself.scanBefore) {
                        weakself.scanBefore(count);
                    }
                }
                
                
            } failure:^(NSError *error) {
                if (cancleAutoMatch) {
                    NSError *cancleError = [[NSError alloc] initWithDomain:CancleAutoMatch code:10086 userInfo:nil];
                    if (failure) failure(cancleError);
                    return;
                }
                if (index >= 3) {
                    if (failure) {
                        failure(error);
                    }
                }
                else {
                    if (weakself.scanBefore) {
                        weakself.scanBefore(count);
                    }
                }
                
            }];
        });
        count++;
    }];
    
    self.scanBefore(0);
    
   
}

- (void)stopScanSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    NSMutableArray *params = [NSMutableArray new];
    NSDictionary *payload = [self requestPayloadWithMethodName:@"end_scan_model" value:params];
    
    [self sendPayload:payload success:^(id v) {
        
    } failure:^(NSError *v) {
        
    }];
    
}

- (void)getScanResultSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    NSMutableArray *params = [NSMutableArray new];
    NSDictionary *payload = [self requestPayloadWithMethodName:@"get_scan_result" value:params];
    
    XM_WS(weakself);
    
    [self sendPayload:payload success:^(id obj) {
//        NSLog(@"获取扫描的功率成功<<<<< %@ >>>>>>>>>>>", [obj[@"result"] lastObject]);
        if ([[obj[@"result"] lastObject] integerValue]) {
            weakself.ac_power = [[obj[@"result"] lastObject] floatValue];
            if ([weakself judgeACPartnerState]) {
                //成功后2s再拉一次功率确认
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakself getACDeviceProp:AC_POWER_ID success:^(id v) {
                        if ([weakself judgeACPartnerState]) {
                           [weakself confirmMatchResultSuccess:^(id obj) {
                               if (success) success(obj);
                           } failure:^(NSError *error) {
                               if (failure) failure(nil);
                           }];
                        }
                        else {
                            if (failure) failure(nil);
                        }
                    } failure:^(NSError *error) {
                        [weakself confirmMatchResultSuccess:^(id obj) {
                            if (success) success(obj);
                        } failure:^(NSError *error) {
                            if (failure) failure(error);
                        }];
                    }];
                });
                
            }
            else {
                NSError *error = [[NSError alloc] init];
                if (failure) failure(error);
            }
        }
        else {
            NSError *error = [[NSError alloc] init];
            if (failure) failure(error);
        }
      
    } failure:^(NSError *error) {
        if (failure) failure(error);
        NSLog(@"获取扫描结果失败======================>>>>%@", error);
    }];
}

- (void)confirmMatchResultSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    XM_WS(weakself);
    NSString *strOpen = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.comfirm.open", @"plugin_gateway", "空调开了吗?");
    NSString *strClose = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.comfirm.close", @"plugin_gateway", "空调关了吗");
    NSString *strNo = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.no",@"plugin_gateway", "否");
    NSString *strYes = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.yes",@"plugin_gateway", "是");
    NSString *strTitle = self.powerState ? strClose : strOpen;
    NSArray *buttonArray = @[ strNo, strYes ];
    
    [[MHPromptKit shareInstance] showAlertWithHandler:^(NSInteger buttonIndex, NSArray *inputs) {
        switch (buttonIndex) {
            case 0: {
                if (failure) failure(nil);
            }
            break;
            case 1: {
                weakself.powerState = !weakself.powerState;
                [weakself setACByModel:[weakself getACModel] success:nil failure:nil];
                [weakself matchSuccessSaveOnOffCmd];
                if (success) success(nil);
            }
            break;
            
            default:
            break;
        }
    } withTitle:@"" message:strTitle style:UIAlertViewStyleDefault defaultText:nil cancelButtonTitle:nil otherButtonTitlesArray:buttonArray];

}

/**
 *  匹配成功保存开机和关机的密文给空调伴侣
 */
- (void)matchSuccessSaveOnOffCmd {
    [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:[NSString stringWithFormat:@"isfirst%@%@", self.ACRemoteId,[MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:[NSString stringWithFormat:@"%@%@", self.did, kHASSCANED]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (self.ACType == 2) {
        [self.kkAcManager changePowerStateWithPowerstate:AC_POWER_OFF];
        [self.kkAcManager getPowerState];
    }
    [self saveCommandMap:[self getACCommand:SPCIACL_OFF_INDEX commandIndex:POWER_COMMAND isTimer:NO] success:nil failure:nil];
    if (self.ACType == 2) {
        [self.kkAcManager changePowerStateWithPowerstate:AC_POWER_ON];
        [self.kkAcManager getPowerState];
    }
    [self saveCommandMap:[self getACCommand:SPCIACL_ON_INDEX commandIndex:POWER_COMMAND isTimer:NO] success:nil failure:nil];
    
    if (self.ACType == 1) {
        [[NSUserDefaults standardUserDefaults] setObject:self.irIds ?: [NSMutableArray new] forKey:[NSString stringWithFormat:@"no_status_id_%@", self.did]];
        [[NSUserDefaults standardUserDefaults] setObject:self.pulseArray ?: [NSMutableArray new] forKey:[NSString stringWithFormat:@"no_status_cmd_%@", self.did]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self getNoStatusRemoteNameWithIds:self.irIds Success:^(id obj) {
            
        } failure:^(NSError *error) {
            
        }];
    }

}

- (void)scanAcSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    XM_WS(weakself);
    __block BOOL cancleAutoMatch = NO;

    [[MHLMACTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.wait", @"plugin_gateway", "匹配空调中，请稍后...") modal:YES handle:^{
        cancleAutoMatch = YES;
    }];
    
//    NSLog(@"每次扫描的总次数%d", self.number);
    self.scanCount = 0;
    [self setCallback:^(NSInteger scanResult) {
        [[MHLMACTipsView shareInstance] showTips:[NSString stringWithFormat:@"%@ %ld/%ld", NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.wait", @"plugin_gateway", "匹配空调中，请稍后...") ,weakself.scanCount + 1,  weakself.codeList.count] modal:YES handle:^{
            cancleAutoMatch = YES;
        }];
        
        if (cancleAutoMatch) {
            NSError *cancleError = [[NSError alloc] initWithDomain:CancleAutoMatch code:10086 userInfo:nil];
            if (failure) failure(cancleError);
            return;
        }
        [weakself generateModelAndCommand:weakself.codeList[weakself.scanCount]];
//        NSLog(@"当前的扫描次数%ld", weakself.scanCount);
        CGFloat delay = 3.0f;

            [weakself deployACByModel:@[weakself.ACModel, weakself.ACCommand] success:^(id obj) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakself getScanResultSuccess:^(id obj) {
                        if (cancleAutoMatch) {
                            NSError *cancleError = [[NSError alloc] initWithDomain:CancleAutoMatch code:10086 userInfo:nil];
                            if (failure) failure(cancleError);
                            return;
                        }
                        if (success) success(obj);

                    } failure:^(NSError *error) {
                        if (cancleAutoMatch) {
                            NSError *cancleError = [[NSError alloc] initWithDomain:CancleAutoMatch code:10086 userInfo:nil];
                            if (failure) failure(cancleError);
                            return;
                        }
                        if (weakself.scanCount >= weakself.codeList.count ) {
                            if (failure) failure(error);
                        }
                        else {
                            [weakself loopScanResultThreeTimesSuccess:^(id obj) {
                                if (cancleAutoMatch) {
                                    NSError *cancleError = [[NSError alloc] initWithDomain:CancleAutoMatch code:10086 userInfo:nil];
                                    if (failure) failure(cancleError);
                                    return;
                                }
                                if (success) success(obj);

                            } failure:^(NSError *error) {
                                if (cancleAutoMatch) {
                                    NSError *cancleError = [[NSError alloc] initWithDomain:CancleAutoMatch code:10086 userInfo:nil];
                                    if (failure) failure(cancleError);
                                    return;
                                }
                                if (weakself.callback) {
                                    weakself.callback(scanFailure);
                                }
                               
                            }];
                        }
                    }];
                    weakself.scanCount++;
                });
                
            } failure:^(NSError *error) {
                if (cancleAutoMatch) {
                    NSError *cancleError = [[NSError alloc] initWithDomain:CancleAutoMatch code:10086 userInfo:nil];
                    if (failure) failure(cancleError);
                    return;
                }
                weakself.scanCount++;
                if (weakself.scanCount < weakself.number) {
                    if (weakself.callback) {
                        weakself.callback(scanFailure);
                    }
                }
                else {
                    if (failure) failure(error);

                }
            }];
       
    }];
    
    self.callback(scanFailure);

}

- (void)loopScanResultThreeTimesSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    XM_WS(weakself);
    __block NSInteger countIndex = 0;
    [self setGetScanRetry:^(NSInteger count) {
        [weakself getScanResultSuccess:^(id obj) {
            if (success) {
                success(obj);
            }
        } failure:^(NSError *error) {
            if (countIndex >= 3) {
                if (failure) {
                    failure(error);
                }
            }
            else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (weakself.getScanRetry) {
                        weakself.getScanRetry(countIndex);
                    }
                });
            }
            countIndex++;
        }];
    }];
    
    self.getScanRetry(0);
}



#pragma mark - 获取空调列表
- (void)getACTypeListSuccess:(SucceedBlock)success Failure:(FailedBlock)failure {
    
    [[MHNetworkEngine sharedInstance] RequestCommonURL:kACTYPELIST_URL method:MHMethod_GET params:nil success:^(id obj) {
        MHACPartnerTypeListResponse *response = [MHACPartnerTypeListResponse responseWithJSONObject:obj];
        if (response.code == 200) {
//            [self.acTypeList addObjectsFromArray:response.typeList];
            self.acTypeList = [response.typeList mutableCopy];
    
            [[MHPlistCacheEngine sharedEngine] asyncSave:response.typeList toFile:[NSString stringWithFormat:@"%@", kACTYPELISTKEY] withFinish:nil];
            
            if (success) {
                success(response.typeList);
            }
        }
        else {
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

#pragma mark -获取扩展吗
- (void)getExtraIrCodeListSuccess:(SucceedBlock)success Failure:(FailedBlock)failure {
    XM_WS(weakself);
    self.extraRemoteList = [[NSUserDefaults standardUserDefaults] objectForKey:kExtraListKey];
    NSLog(@"缓存的扩展码库%@", self.extraRemoteList);

    [[MHNetworkEngine sharedInstance] RequestCommonURL:kExtraIrCode_URL method:MHMethod_GET params:nil success:^(id obj) {
        NSLog(@"扩展码库%@", obj);
        weakself.extraRemoteList = obj[@"result"];
        NSLog(@"扩展码库%@", weakself.extraRemoteList);
//        NSLog(@"%@", [[weakself.extraRemoteList firstObject] class]);
        [[NSUserDefaults standardUserDefaults] setObject:weakself.extraRemoteList forKey:kExtraListKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (success) success(obj);
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];

}

- (BOOL)isExtraRemoteId {
    __block BOOL isExtra = NO;
    /*
    {"keys":[9,10,11,12,19,22],"rid":"2"}
    */
//    if ([self.ACRemoteId isEqualToString:kGREEREMOTEID] ||
//        [self.ACRemoteId isEqualToString:kMIDEAREMOTEIDFIRST] ||
//        [self.ACRemoteId isEqualToString:kMIDEAREMOTEIDSECOND] ||
//        [self.ACRemoteId isEqualToString:kHAIERREMOTEIDSECOND] ||
//        [self.ACRemoteId isEqualToString:kPANASONICREMOTEIDFIRST] ||
//        [self.ACRemoteId isEqualToString:kMATSUSHITREMOTEIDFIRST] ||
//        [self.ACRemoteId isEqualToString:kAUXREMOTEIDFIRST] ||
//        [self.ACRemoteId isEqualToString:kCHIGOREMOTEIDFIRST]) {
//        return YES;
//    }
    
    [self.extraRemoteList enumerateObjectsUsingBlock:^(NSDictionary *remoteDic, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([remoteDic isKindOfClass:[NSDictionary class]] && [remoteDic[@"rid"] isEqualToString:self.ACRemoteId]) {
            if ([remoteDic[@"keys"] isKindOfClass:[NSArray class]]) {
//                NSLog(@"每个遥控的key----%@", remoteDic[@"keys"]);
                NSArray *keyNamesArray = remoteDic[@"keys"];
                [keyNamesArray enumerateObjectsUsingBlock:^(NSNumber *key, NSUInteger idx, BOOL * _Nonnull stop) {
//                    NSLog(@"当前的值%@", key);
                    if ([key integerValue] == 11) {
                        isExtra = YES;
                    }
                    *stop = isExtra;
                }];
            }
            *stop = isExtra;
        }
    }];
    
    
    return isExtra;
}

#pragma mark - 获取红外码库zip压缩
- (void)getUncompressedIrCodeListWithBrandId:(NSInteger)brandId Success:(SucceedBlock)success Failure:(FailedBlock)failure  {
    
    
    XM_WS(weakself);
    NSString *strUrl = [NSString stringWithFormat:kIRCODELIST_Uncompressed_URL, brandId];
    
    [[MHNetworkEngine sharedInstance] RequestCommonURL:strUrl method:MHMethod_GET params:nil success:^(id obj) {
        NSLog(@"非压缩码库%@", obj);
        
        if (success) success(obj);
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}


- (void)getIrCodeListWithBrandId:(NSInteger)brandId Success:(SucceedBlock)success Failure:(FailedBlock)failure {
    
    NSLog(@"brandids------%ld", brandId);//322
//    [self getUncompressedIrCodeListWithBrandId:brandId Success:nil Failure:nil];
    //97 gree
    //182 midea
    XM_WS(weakself);
    NSString *url = [NSString stringWithFormat:kIRCODELIST_URL, brandId];
    [[MHNetworkEngine sharedInstance] RequestCommonURL:url method:MHMethod_GET params:nil success:^(id obj) {
        MHACPartnerIrCodeListResponse *response = [MHACPartnerIrCodeListResponse responseWithJSONObject:obj];
        if (response.code == 200) {
            NSLog(@"%@", response.codeList);
            self.codeList = [response.codeList mutableCopy];
            switch (brandId) {
                case kGREEBRANDID: {
                    [weakself.codeList insertObject:@{ @"id":kGREEREMOTEID, @"type":@(3)} atIndex:0];

                    break;
                }
                case kMIDEABRANDID: {
                    [weakself.codeList insertObject:@{ @"id":kMIDEAREMOTEIDFIRST, @"type":@(3)} atIndex:0];
                    [weakself.codeList insertObject:@{ @"id":kMIDEAREMOTEIDSECOND, @"type":@(3)} atIndex:1];
                    break;
                }
                case kHAIERBRANDID: {
                    [weakself.codeList insertObject:@{ @"id":kHAIERREMOTEIDSECOND, @"type":@(3)} atIndex:0];
                    break;
                }
                case kMATSUSHITABRANDID: {
                    [weakself.codeList insertObject:@{ @"id":kMATSUSHITREMOTEIDFIRST, @"type":@(3)} atIndex:0];

                    break;
                }
                case kPANASONICBRANDID: {
                    [weakself.codeList insertObject:@{ @"id":kPANASONICREMOTEIDFIRST, @"type":@(3)} atIndex:0];
                    break;
                }
                case kAUXBRANDID: {
                    [weakself.codeList insertObject:@{ @"id":kAUXREMOTEIDFIRST, @"type":@(3)} atIndex:0];
                    break;
                }
                case kCHIGOBRANDID: {
                    [weakself.codeList insertObject:@{ @"id":kCHIGOREMOTEIDFIRST, @"type":@(3)} atIndex:0];
                    break;
                }
                default:
                    break;
            }
            
            if (success) {
                success(obj);
            }
        }
            else {
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

- (void)uploadBrandName:(NSString *)brandName
           andBrandType:(NSString *)brandType
                Success:(SucceedBlock)success
                failure:(FailedBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@/%@/%@", kUPLOAD_URL, self.did, brandName, brandType];
    
    [[MHNetworkEngine sharedInstance] RequestCommonURL:url method:MHMethod_POST params:nil success:^(id obj) {
//        NSLog(@"%@", obj);
        if (success) success(obj);

    } failure:^(NSError *error) {
        if (failure) failure(error);

    }];
}

/**
 *  获取无状态空调的按键名
 *
 *  @param ids     按键id
 *  @param success success description
 *  @param failure failure description
 */
- (void)getNoStatusRemoteNameWithIds:(NSArray *)ids
                             Success:(SucceedBlock)success
                             failure:(FailedBlock)failure {
    
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:ids options:0 error:&parseError];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", kNONBUTTON_URL,jsonStr];
    
    XM_WS(weakself);
    
    [[MHNetworkEngine sharedInstance] RequestCommonURL:url method:MHMethod_GET params:nil success:^(id obj) {
        weakself.remoteNameList = [NSMutableArray arrayWithArray:obj[@"result"]];
                NSLog(@"%@", obj);
        if (success) success(obj);
        
    } failure:^(NSError *error) {
        if (failure) failure(error);
        
    }];

}


#pragma mark - 生成model和cmd
- (void)generateModelAndCommand:(NSDictionary *)irCode {
    self.ACType = [irCode[@"type"] intValue];
    self.ACRemoteId = [irCode[@"id"] stringValue];
  
    
    //空调伴侣自身协议
    if (self.ACType == 3) {
        self.modeState = AC_MODE_COOL;
        self.temperature = AC_MODE_COOLTEMP;
        self.windPower = AC_WIND_SPEED_HIGH;
        self.windState = 1;
        self.windDirection = 0;
        [self getACModel];
        if (self.powerState) {
            [self getACCommand:POWER_OFF_INDEX commandIndex:POWER_COMMAND isTimer:NO];
        }
        else {
            [self getACCommand:POWER_ON_INDEX commandIndex:POWER_COMMAND isTimer:NO];
        }
        return;
    }
    
    XM_WS(weakself);
    if (self.ACType == 2) {
//        NSLog(@"%@", self.ACRemoteId);
        self.ACDataSource = [self getACDict:irCode];
        self.kkAcManager.AC_RemoteId = self.ACRemoteId;
        self.kkAcManager.airDataDict = self.ACDataSource;
        [self.kkAcManager airConditionModeDataHandle];
        if (self.powerState) {
            [self.kkAcManager changePowerStateWithPowerstate:AC_POWER_OFF];
        }
        else {
            [self.kkAcManager changePowerStateWithPowerstate:AC_POWER_ON];
        }
        [self.kkAcManager getPowerState];

        self.temperature = [self.kkAcManager getTemperature];
        self.windPower = [self.kkAcManager getWindPower];
        self.windState = [self.kkAcManager getWindState];
//        NSLog(@"当前风向%d", [self.kkAcManager getWindState]);
        self.windDirection = 0;
//        NSLog(@"该模式所有的风向%@", [self.kkAcManager getAllWindState]);
        
        int infoMode = [self.kkAcManager getModeState];
        self.modeState = [self sdkModeToShowModeTo:infoMode];
        
        [self getACModel];
        if (self.powerState) {
            [self getACCommand:POWER_OFF_INDEX commandIndex:POWER_COMMAND isTimer:NO];
        }
        else {
            [self getACCommand:POWER_ON_INDEX commandIndex:POWER_COMMAND isTimer:NO];
        }
    }
    if (self.ACType == 1) {
        [self getACDict:irCode];
        [weakself getACModel];
        if (self.powerState) {
            [self getACCommand:POWER_OFF_INDEX commandIndex:POWER_COMMAND isTimer:NO];
        }
        else {
            [self getACCommand:POWER_ON_INDEX commandIndex:POWER_COMMAND isTimer:NO];
        }
    }

    

}

- (NSString *)generateModelWithRemoteid:(NSString *)remoteid brandid:(NSInteger)brandid {
    self.ACRemoteId = remoteid;
    [self getSpecialModel];
    return [self getACModel];
   
}

- (void)getSpecialModel {
    XM_WS(weakself);
    __block NSDictionary *irCode = nil;
    [self.codeList enumerateObjectsUsingBlock:^(NSDictionary *dataDic, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[dataDic[@"id"] stringValue] isEqualToString:weakself.ACRemoteId]) {
            weakself.ACType = [dataDic[@"type"] intValue];
            irCode = dataDic;
            *stop = YES;
        }
    }];
//    NSLog(@"新的actype<<%d>>", self.ACType);
    //空调伴侣自身协议
    if (self.ACType == 3) {
        self.modeState = AC_MODE_COOL;
        self.temperature = AC_MODE_COOLTEMP;
        self.windPower = AC_WIND_SPEED_HIGH;
        self.windState = 1;
        self.windDirection = 0;
    }
    
    if (self.ACType == 2) {
        //        NSLog(@"%@", self.ACRemoteId);
        self.ACDataSource = [self getACDict:irCode];
        self.kkAcManager.AC_RemoteId = self.ACRemoteId;
        self.kkAcManager.airDataDict = self.ACDataSource;
        [self.kkAcManager airConditionModeDataHandle];
        
        
        //        self.temperature = AC_MODE_COOLTEMP;
        //        self.modeState = AC_MODE_COOL;
        //        self.windPower = AC_WIND_SPEED_HIGH;
        self.temperature = [self.kkAcManager getTemperature];
        self.windPower = [self.kkAcManager getWindPower];
        self.windState = [self.kkAcManager getWindState];
//        NSLog(@"当前风向%d", [self.kkAcManager getWindState]);
        self.windDirection = 0;
//        NSLog(@"该模式所有的风向%@", [self.kkAcManager getAllWindState]);
        
        int infoMode = [self.kkAcManager getModeState];
        self.modeState = [self sdkModeToShowModeTo:infoMode];
    }
    if (self.ACType == 1) {
        [self getACDict:irCode];
    }
}

- (NSString *)getACModel {
    NSInteger device_id = 5;
    NSInteger type = 0;
    NSMutableString *model = [NSMutableString new];
    [model appendFormat:@"%02ld",self.ACVersion];
    [model appendFormat:@"%02ld", device_id];
    [model appendFormat:@"%04ld",self.brand_id];
    [model appendFormat:@"%08ld", [self.ACRemoteId  integerValue]];
    
    //
    
    if (self.ACType == 3) {
        type = 2;
        [model appendFormat:@"%02ld", type];
        self.ACModel = model;
        return model;
    }
    
    if (self.ACType == 1) {
        [model appendFormat:@"%02ld", type];
        [model appendString:self.remoteParams];
    }
    if (self.ACType == 2) {
        type = 1;
        [model appendFormat:@"%02ld", type];
        NSMutableString * ACInfrared=[[NSMutableString alloc] init];
        if (self.kkAcManager.airDataDict != nil) {
            for (NSNumber * string in [self.kkAcManager getParams]) {
                [ACInfrared appendFormat:@"%02X",[string unsignedCharValue]];
            }
            [model appendString:ACInfrared];
        }
//        NSLog(@"%@",ACInfrared);//打印红外码
    }
    
//    NSLog(@"模型%@",model);//打印model
    self.ACModel = model;
    return model;
}

- (NSString *)getACCommand:(ACPARTNER_NON_PULSE_Id)index commandIndex:(ACPARTNER_COMMAND_Id)commandIndex isTimer:(BOOL)isTimer {
    NSMutableString *model = [NSMutableString new];
    //获取扩展键和学习按键的明文
    if (index == CUSTOM_FUNCTION_INDEX || index == EXTRA_FUNCTION_INDEX) {
        [model appendString:[self getCustomAndExtraCmd:index]];
        return model;
    }

    [model appendFormat:@"%02ld",self.ACVersion];
    [model appendFormat:@"%08ld", [self.ACRemoteId  integerValue]];
    
    
    if (self.ACType == 3) {
        [model  appendString:[self generateStatusCommandInfo:index commandIndex:commandIndex]];
    }

    
    if (self.ACType == 1) {
        [model appendString:[self generateCommandInfo:index]];
        if (commandIndex == TIMER_COMMAND) {
            [model appendString:self.pulseArray[POWER_COMMAND]];
        }
        else {
            [model appendString:self.pulseArray[commandIndex]]; 
        }
    }
    if (self.ACType == 2) {

//        NSLog(@"获取到的当前模式的值>>>%d", [self.kkAcManager getModeState]);
   
        
//        NSLog(@"温度%d, 模式%d, 风向%d, 风量%d", self.temperature, self.modeState, self.windState, self.windPower);
        [model  appendString:[self generateStatusCommandInfo:index commandIndex:commandIndex]];
        
//        [model appendString:@"0023CB2601002403073B000000007E"];
//        return model;
        
        NSMutableString * ACInfrared=[[NSMutableString alloc] init];
        if (self.kkAcManager.airDataDict != nil) {
//            NSLog(@"%@", [self.kkAcManager getAirConditionInfrared]);
            for (NSNumber * string in [self.kkAcManager getAirConditionInfrared]) {
                [ACInfrared appendFormat:@"%02X",[string unsignedCharValue]];
            }
            [model appendString:ACInfrared];
        }
        NSLog(@"发送的密文%@", ACInfrared);//00A6AC000040600020000000000517
    }
    self.ACCommand = model;
//    NSLog(@"获取SKD的问题%d", [self.kkAcManager getTemperature]);
    NSLog(@"控制命令%@", self.ACCommand);
    return  self.ACCommand;
}

- (NSString *)getCustomAndExtraCmd:(ACPARTNER_NON_PULSE_Id)index {
    XM_WS(weakself);
    __block NSString *cmd = @"1fff79ff";
    
    NSMutableArray *totalArray = [NSMutableArray new];
    if (index == CUSTOM_FUNCTION_INDEX) {
        for (int i = 121; i < 241; i++) {
            [totalArray addObject:@(i)];
        }
        [totalArray enumerateObjectsUsingBlock:^(NSNumber *custom, NSUInteger idx, BOOL * _Nonnull stop) {
            __block BOOL canTotalStop = NO;
            [weakself.customFunctionList enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *cstCmd = dic[kACShortCmdKey];
                NSInteger used = [[cstCmd substringWithRange:NSMakeRange(4, 2)] integerValue];
                if ([custom integerValue] != used) {
                    cmd = [cmd stringByReplacingCharactersInRange:NSMakeRange(4, 2) withString:[MHLMDecimalBinaryTools decimalToHex:[custom longValue]]];
                    canTotalStop = YES;
                    *stop = YES;
                }
            }];
            *stop = canTotalStop;
        }];
    }
    if (index == EXTRA_FUNCTION_INDEX) {
           for (int i = 101; i < 121; i++) {
               [totalArray addObject:@(i)];
           }
           [totalArray enumerateObjectsUsingBlock:^(NSNumber *custom, NSUInteger idx, BOOL * _Nonnull stop) {
//               __block BOOL canTotalStop = NO;
//               *stop = canTotalStop;
           }];
    }

//    NSLog(@"获得学习按键明文%@", cmd);
    
    return cmd;
}

#pragma mark - 判断空调状态
- (BOOL)judgeACPartnerState {
    CGFloat temp = self.original_power - self.ac_power;
    if (self.powerState == 0 && fabs(temp) > kOFFTOONPOWER) {
        self.powerState = 1;
        return YES;
    }
    if (self.powerState == 1 && fabs(temp) > (self.original_power / 2.0f)) {
        self.powerState = 0;
        return YES;
    }
    return NO;
}

- (void)initMatchPowerState {
        self.unknowState = kCERTAINSTATE;
        if (self.original_power >= kMINONPOWER) {
            self.powerState = 1;
        }
        else if (self.original_power <= kMAXOFFPOWER) {
            self.powerState = 0;
        }
        else {
            self.unknowState = kUNKNOWSTATE;
            self.powerState = 1;
        }
}

#pragma mark - 生成明文
- (NSString *)generateCommandInfo:(ACPARTNER_NON_PULSE_Id)index {
    NSString *command_info = @"00000000";
    if (self.ACType == 1) {
        switch (index) {
                case POWER_OFF_INDEX:
            case POWER_ON_INDEX: {
                
                command_info = @"EFFFF00";
            }
                break;
            case MODE_INDEX: {
                command_info = @"feffff00";
            }
                break;
            case TEMP_PLUS_INDEX: {
                command_info = @"fffff300";
            }
                break;
            case TEMP_LESS_INDEX: {
                command_info = @"fffff400";
            }
                break;
            case SWING_INDEX: {
                command_info = @"FFFDFF00";
            }
                break;
            case FAN_SPEED_INDEX: {
                command_info = @"ffefff00";
            }
                break;
            case TOGGLE_INDEX: {
                command_info = @"efffff00";
            }
                break;
            case SCENE_ON_INDEX:
                return @"1fffff00";
                break;
        
            case SCENE_OFF_INDEX:
                    return @"0fffff00";
                break;
            case SCENE_TOGGLE_INDEX:
                    return @"2fffff00";
                break;
            case SPCIACL_OFF_INDEX:
                return kOFFCOMMAND;
                break;
            default:
                break;
        }
    }
    
    return command_info;

}


#pragma mark - 有状态空调的明文
- (NSString *)generateStatusCommandInfo:(ACPARTNER_NON_PULSE_Id)index commandIndex:(ACPARTNER_COMMAND_Id)commandIndex {
    NSString *command_info = @"00000000";
    switch (index) {
        case SCENE_ON_INDEX:{
            if (self.ACType == 2) {
                return @"1fffff01";
            }
            return @"1fffff02";
            break;
        }
        case SCENE_OFF_INDEX:{
            if (self.ACType == 2) {
                return @"0fffff01";
            }
            return @"0fffff02";
            break;
    }
        case SCENE_TOGGLE_INDEX: {
            if (self.ACType == 2) {
                return @"2fffff01";
            }
            return @"2fffff02";
            break;
        }
        case SPCIACL_OFF_INDEX:
            return kOFFCOMMAND;
            break;
        case SPEED_COOL_INDEX:
            return @"11201401";
            break;
        default:
            break;
    }
    int infoPowerState = self.powerState;
    NSInteger infoMode = self.modeState;
    NSInteger infoWindPower = self.windPower;
    NSInteger infoWindDirection = self.windDirection;
    NSInteger infoWindState = self.windState;
    int infoTemp = self.temperature;

    switch (commandIndex) {
        case TIMER_COMMAND: {
            infoPowerState = self.timerPowerState;
            infoMode = self.timerModeState;
            infoWindPower = self.timerWindPower;
            infoWindDirection = self.timerWindDirection;
            infoWindState = self.timerWindState;
            infoTemp = self.timerTemperature;
            break;
        }
        default:
        break;
    }


    NSString *strOn = [NSString stringWithFormat:@"%d", infoPowerState];
    switch (index) {
        case POWER_ON_INDEX:
            strOn = @"1";
            break;
        case POWER_OFF_INDEX:
            strOn = @"0";
            break;
        case TOGGLE_INDEX:
            strOn = @"2";
            break;
        case STAY_INDEX:
            strOn = strOn;
            break;
        case SCENE_AC_INDEX:
            strOn = @"1";
            break;
        default:
            break;
    }
    NSString *strMode = @"0";
    switch (infoMode) {
        case AC_MODE_HEAT:
            strMode = @"0";
            break;
        case AC_MODE_COOL:
            strMode = @"1";
            break;
        case AC_MODE_AUTO:
            strMode = @"2";
            break;
        case AC_MODE_DRY:
            strMode = @"3";
            break;
        case AC_MODE_FAN:
            strMode = @"4";
            break;
            
        default:
            break;
    }
    
    NSString *strWindPower = @"0";
    switch (infoWindPower) {
        case AC_WIND_SPEED_AUTO:
            strWindPower = @"3";
            break;
        case AC_WIND_SPEED_LOW:
            strWindPower = @"0";
            break;
        case AC_WIND_SPEED_MEDIUM:
            strWindPower = @"1";
            break;
        case AC_WIND_SPEED_HIGH:
            strWindPower = @"2";
            break;
            
        default:
            break;
    }
    
    NSString *strDirection = @"00";
    switch (infoWindDirection) {
        case 0:
            strDirection = @"00";
            break;
        case 1:
            strDirection = @"01";
            break;
        case 2:
            strDirection = @"10";
            break;
        case 3:
            strDirection = @"11";
            break;
        default:
            break;
    }
    
    NSString *strWindState = @"00";
    switch (infoWindState) {
        case 0:
            strWindState = @"00";
            break;
        case 1:
            strWindState = @"01";
            break;
        case 2:
            strWindState = @"10";
            break;
        case 3:
            strWindState = @"11";
            break;
        default:
            break;
    }
  
    NSInteger ten = [[MHLMDecimalBinaryTools binaryToDecimal:[NSString stringWithFormat:@"%@%@", strDirection,strWindState] ] integerValue];
    NSString *strWind = [MHLMDecimalBinaryTools decimalToHex:ten];
    
    NSString *strTemp = [MHLMDecimalBinaryTools decimalToHex:infoTemp];
    NSString *strNoUse = nil;
    NSString *last = @"0";
    if (commandIndex == LED_COMMAND) {
        
        NSString *strExtra = @"10";
        NSString *strLed = nil;
        switch (self.ledState) {
            case 0:
                strLed = @"10";
                NSUInteger tenLed = [[MHLMDecimalBinaryTools binaryToDecimal:[NSString stringWithFormat:@"%@%@", strExtra,strLed]] integerValue];
                strNoUse = [MHLMDecimalBinaryTools decimalToHex:tenLed];
                break;
            case 1:
                strNoUse = @"1";
                break;
            default:
                break;
        }
      
        NSLog(@"限值为%@", strNoUse);
        switch (self.ACType) {
            case 2:
                last = @"1";
                break;
            case 3:
                last = @"2";
                break;
            default:
                break;
        }
        NSLog(@"灯的开关状态和明文%d, %@", self.ledState, strNoUse);
//        strNoUse = self.ledState ? strNoUse : @"A";
        last = self.ledState ?  last : @"0";
    }
    else {
        strNoUse = @"1";
        switch (index) {
            case POWER_ON_INDEX:
            case POWER_OFF_INDEX:
            case STAY_INDEX:
                strNoUse = @"0";
                break;
                
            default:
                break;
        }
        switch (self.ACType) {
            case 2:
                last = @"1";
                break;
            case 3:
                last = @"2";
                break;
            default:
                break;
        }
        NSLog(@"灯的开关状态和明文%d, %@", self.ledState, strNoUse);
        strNoUse = self.ledState ? strNoUse : @"A";
        last = self.ledState ?  last : @"0";
    }
    command_info = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", strOn, strMode,strWindPower, strWind, strTemp,strNoUse, last];
    NSLog(@"下发的明文%@", command_info);
    return command_info;
}




#pragma mark - 更新码库
- (void)updateACDataWithNewRemoteID:(NSString *)newRemoteID newBrandid:(NSInteger)newBrandid {
    self.ACRemoteId = newRemoteID;
    self.brand_id = newBrandid;
//    NSLog(@"酷控manager是不是空的%@", self.kkAcManager);
//    NSLog(@"码库列表是不是空的%@", self.codeList);
    XM_WS(weakself);
    if (self.ACType == 1) {
        [self.codeList enumerateObjectsUsingBlock:^(NSDictionary *dataDic, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[dataDic[@"id"] stringValue] isEqualToString:newRemoteID]) {
                [weakself getACDict:dataDic];
                *stop = YES;
            }
        }];
    }
    if (self.ACType == 2) {
        [self.codeList enumerateObjectsUsingBlock:^(NSDictionary *dataDic, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[dataDic[@"id"] stringValue] isEqualToString:newRemoteID]) {
                weakself.kkAcManager.AC_RemoteId = newRemoteID;
                weakself.ACDataSource = [weakself getACDict:dataDic];
                weakself.kkAcManager.airDataDict = weakself.ACDataSource;
                [weakself.kkAcManager airConditionModeDataHandle];
                [weakself.kkAcManager getPowerState];
                *stop = YES;
            }
        }];
    }
    
     [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:[NSString stringWithFormat:@"isfirst%@%@", self.ACRemoteId,[MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:[NSString stringWithFormat:@"%@%@", self.did, kHASSCANED]];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [weakself saveACStatus];
}


#pragma mark - 有状态的空调
- (void)resetAcStatus {
    [self.kkAcManager changePowerStateWithPowerstate:self.powerState ? AC_POWER_ON : AC_POWER_OFF];
    [self.kkAcManager getPowerState];
    [self judgeModeCanControl:PROP_POWER];
    [self judgeWindsCanControl:PROP_POWER];
    [self judgeTempratureCanControl:PROP_POWER];
    [self judgeSwipCanControl:PROP_POWER];

}

-(void)assignAndHandleAirData:(BOOL)isRepeat
{
//    NSLog(@"从缓存初始化manager时候的remote--->%@", self.ACRemoteId);
//    NSLog(@"从缓存初始化manager时候的datasource--->%@", self.ACDataSource);
    self.kkAcManager.apikey = self.apikey;//验证apikey
    self.kkAcManager.AC_RemoteId = self.ACRemoteId;//空调的remoteid
    self.kkAcManager.airDataDict = self.ACDataSource;//空调的红外码库
    if (!self.ACDataSource.count) {
        self.ACRemoteId = nil;
        self.brand_id = 0;
        self.ACType = 0;
        return;
    }
    if (!isRepeat) {
        [self.kkAcManager airConditionModeDataHandle];//空调数据处理。
        [self.kkAcManager getParams];
        [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:[NSString stringWithFormat:@"%@%@", self.did, kHASSCANED]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:[NSString stringWithFormat:@"isfirst%@%@", self.ACRemoteId,[MHPassportManager sharedSingleton].currentAccount.userId]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
//    [self.kkAcManager changePowerStateWithPowerstate:self.powerState ? AC_POWER_ON : AC_POWER_OFF];
    [self.kkAcManager changePowerStateWithPowerstate:AC_POWER_ON];
    [self.kkAcManager getPowerState];
    [self.kkAcManager getAirConditionInfrared];
    //模式
    if (self.modeState !=  [self sdkModeToShowModeTo:[self.kkAcManager getModeState]]) {
        [self judgeModeCanControl:PROP_POWER];
    }
    if ([self showWindPowerToSdkWindPower:self.windPower] != [self.kkAcManager getWindPower]) {
        [self judgeWindsCanControl:PROP_POWER];
    }
    
   
    if (self.temperature != [self.kkAcManager getTemperature]) {
        [self judgeTempratureCanControl:PROP_POWER];
    }
    if ([self showWindStateToSdkWindState:self.windState] != [self.kkAcManager getWindState]) {
        [self judgeSwipCanControl:PROP_POWER];
        
    }
    //        [self saveACStatus];
    
}

#pragma mark- 当前空调是否首次使用
-(BOOL)isFirstUser
{
    BOOL isFirst=NO;
    isFirst = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"isfirst%@%@", self.ACRemoteId, [MHPassportManager sharedSingleton].currentAccount.userId]] boolValue];
    return isFirst;
}

#pragma mark - 缓存数据
- (void)saveACStatus {
    [[NSUserDefaults standardUserDefaults] setObject:self.ACRemoteId forKey:[NSString stringWithFormat:@"acpartner_remoteid_%@%@",self.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.ACType) forKey:[NSString stringWithFormat:@"acpartner_type_%@%@",self.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.brand_id) forKey:[NSString stringWithFormat:@"acpartner_brand_id_%@%@",self.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] setObject:self.pulseArray forKey:[NSString stringWithFormat:@"acpartner_non_pulse_%@%@",self.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
     [[NSUserDefaults standardUserDefaults] setObject:self.codeList forKey:[NSString stringWithFormat:@"acpartner_codeList_%@%@",self.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] setObject:self.usableCodeList forKey:[NSString stringWithFormat:@"acpartner_usableCodeList_%@%@",self.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.usableCodeIndex) forKey:[NSString stringWithFormat:@"acpartner_usableCodeIndex_%@%@",self.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] setObject:self.nonCodeList forKey:[NSString stringWithFormat:@"acpartner_nonCodeList_%@%@",self.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] setObject:self.ACDataSource forKey:[NSString stringWithFormat:@"acpartner_ACDataSource_%@%@",self.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    
     [[NSUserDefaults standardUserDefaults] setObject:@(self.pwHour) forKey:[NSString stringWithFormat:@"acpartner_pwHour_%@%@",self.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
     [[NSUserDefaults standardUserDefaults] setObject:@(self.pwMinute) forKey:[NSString stringWithFormat:@"acpartner_pwMinute_%@%@",self.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    

    
    if (self.ACRemoteId) {
        [[NSUserDefaults standardUserDefaults] setObject:@[ @(self.powerState), @(self.modeState), @(self.windPower), @(self.windState), @(self.temperature), @(self.ledState) ] forKey:self.ACRemoteId];//保存当前模式及模式下对应的状态
         [[NSUserDefaults standardUserDefaults] setObject:self.ACDataSource forKey:[NSString stringWithFormat:@"ACDataSource%@%@",self.ACRemoteId,[MHPassportManager sharedSingleton].currentAccount.userId]];
    }
    if (self.ACType == 2 && self.ACRemoteId) {
            [[NSUserDefaults standardUserDefaults] setObject:[self.kkAcManager getAirConditionAllModeAndValue] forKey:[NSString stringWithFormat:@"air%@air%@",self.ACRemoteId,[MHPassportManager sharedSingleton].currentAccount.userId]];
    }
    
   
    
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)restoreACStatus {

    self.ACRemoteId = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"acpartner_remoteid_%@%@",self.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    self.ACType = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"acpartner_type_%@%@",self.did,[MHPassportManager sharedSingleton].currentAccount.userId]] intValue];
    self.brand_id = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"acpartner_brand_id_%@%@",self.did,[MHPassportManager sharedSingleton].currentAccount.userId]] intValue];
    NSArray *plulse = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"acpartner_non_pulse_%@%@",self.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    self.pulseArray = [plulse mutableCopy];
    NSArray *code = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"acpartner_codeList_%@%@",self.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    self.codeList = [code mutableCopy];
    NSArray *usable = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"acpartner_usableCodeList_%@%@",self.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    self.usableCodeList = [usable mutableCopy];
    self.usableCodeIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"acpartner_usableCodeIndex_%@%@",self.did,[MHPassportManager sharedSingleton].currentAccount.userId]] integerValue];
    NSArray *noncode = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"acpartner_nonCodeList_%@%@",self.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    self.nonCodeList = [noncode mutableCopy];
    self.ACDataSource = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"acpartner_ACDataSource_%@%@",self.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    
    self.pwHour = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"acpartner_pwHour_%@%@",self.did,[MHPassportManager sharedSingleton].currentAccount.userId]] integerValue];
    self.pwMinute = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"acpartner_pwMinute_%@%@",self.did,[MHPassportManager sharedSingleton].currentAccount.userId]] integerValue];

//    NSLog(@"遥控器%@, 状态%d, 品牌%ld, %@, 倒计时%ld,%ld, 电量%lf, %lf ", self.ACRemoteId, self.ACType, self.brand_id, self.codeList, self.pwHour, self.pwMinute, self.pw_day, self.pw_month);
    if (self.ACRemoteId) {
        NSArray *status = [[NSUserDefaults standardUserDefaults] objectForKey:self.ACRemoteId];
        if (status.count >= 6) {
            self.powerState = [status[0] intValue];
            self.modeState = [status[1] intValue];
            self.windPower = [status[2] intValue];
            self.windState = [status[3] intValue];
            self.temperature = [status[4] intValue] ?: 26;
            self.ledState = [status[5] intValue];
            self.ACDataSource = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"ACDataSource%@%@",self.ACRemoteId,[MHPassportManager sharedSingleton].currentAccount.userId]];
        }
        
        if (self.ACType == 2) {            
                [self assignAndHandleAirData:NO];
        }
    }
    
    if (self.ACType == 1) {
       self.irIds = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"no_status_id_%@", self.did]]];
        self.pulseArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"no_status_cmd_%@", self.did]]];
    }
    
}

#pragma mark - 插座相关功能
- (void)fetchCountDownTime:(void (^)(NSInteger hour, NSInteger minute))countDownTimer {
    NSDate *currentDate = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *currentComps = [gregorian components:NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:currentDate];
    
    NSInteger currentHour = currentComps.hour;
    NSInteger currentMinute = currentComps.minute;
    NSInteger timerMinute = 0;
    NSInteger timerHour = 0;
    if(self.countDownTimer.isOnOpen){
        timerHour = self.countDownTimer.onHour ;
        timerMinute = self.countDownTimer.onMinute;
    }
    else if(self.countDownTimer.isOffOpen){
        timerHour = self.countDownTimer.offHour ;
        timerMinute = self.countDownTimer.offMinute;
    }
    else{
        if(countDownTimer) countDownTimer(0,0);
        return;
    }
    
    NSInteger hour = 0,minute = 0;
    NSInteger differentTimeInMinute = (timerHour * 60 + timerMinute) - (currentHour * 60 + currentMinute);
    if(differentTimeInMinute <= 0)
        differentTimeInMinute = ((timerHour + 24) * 60 + timerMinute) - (currentHour * 60 + currentMinute);
    
    hour = differentTimeInMinute / 60;
    minute = differentTimeInMinute % 60;
    if(countDownTimer) countDownTimer(hour,minute);
}

- (void)getACDeviceProp:(ACPARTNER_DEVICE_PROP_Id)propId success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    NSDictionary *payload  = [self requestPayloadWithMethodName:@"get_device_prop" value:@[ @"lumi.0" , @"ac_power" ]];
    
    [self sendPayload:payload success:^(id respObj) {
        if([[respObj valueForKey:@"result"] isKindOfClass:[NSArray class]] &&
           [[respObj valueForKey:@"result"] count] > 0
           ){
            NSArray *tempArray = [respObj valueForKey:@"result"];
//            self.ac_power = [tempArray[0] floatValue];
//            NSLog(@"获取功率成功《《%.0lf》》", self.ac_power);
            if (success) {
                success(tempArray);
            }
        }
    } failure:^(NSError *error) {
//        NSLog(@"获取功率失败%@", error);
        if (failure) {
            failure(error);
        }
    }];

}


- (void)fetchPlugDataWithSuccess:(SucceedBlock)success
                         failure:(FailedBlock)failure{
    MHLumiPlugDataManager *manager = [[MHLumiPlugDataManager alloc] init];
    manager.quantDevice = self;
    
    XM_WS(weakself);
    NSString *dateString = [NSString string];
    NSDateFormatter *fomatter = [[NSDateFormatter alloc] init];
    [fomatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *todayDate = [NSDate date];
    NSString *todayDateString = [fomatter stringFromDate:todayDate];
    dateString = [NSString stringWithFormat:@"%@ 00:00:00",todayDateString];
    
    NSMutableDictionary *params = [NSMutableDictionary
                                   dictionaryWithDictionary:@{ @"groupType"  : @"day" ,
                                                               @"dateString" : dateString
                                                               }];
    [manager fetchLumiPlugDataWithParams:params Success:^(id obj){
        [weakself savePlugData:obj andGroupType:@"day"];
        if(success)success(obj);
    } andfailure:^(NSError *error){
        if(failure)failure(error);
    }];
    
    [fomatter setDateFormat:@"yyyy-MM"];
    NSDate *currentMonthDate = [NSDate date];
    NSString *currentMonthDateString = [fomatter stringFromDate:currentMonthDate];
    dateString = [NSString stringWithFormat:@"%@-01 00:00:00",currentMonthDateString];
    
    [params setObject:@"month" forKey:@"groupType"];
    [params setObject:dateString forKey:@"dateString"];
    [manager fetchLumiPlugDataWithParams:params Success:^(id obj){

        [weakself savePlugData:obj andGroupType:@"month"];
        if(success)success(obj);
    } andfailure:^(NSError *error){
        if(failure)failure(error);
    }];
}

- (void)savePlugData:(id)value andGroupType:(NSString *)groupType {
    NSData *archiveSceneTplData = [NSKeyedArchiver archivedDataWithRootObject:value];
    [[NSUserDefaults standardUserDefaults] setObject:archiveSceneTplData
                                              forKey:[NSString stringWithFormat:@"lumi_plug_powerdata_%@_groupType_%@",self.did,groupType]];
    
    NSString *resultString = [value substringWithRange:NSMakeRange(1, [value length] - 2)];
    NSArray *resultArray = [resultString componentsSeparatedByString:@","];
    NSString *num = [NSString string];
    if(resultArray.count > 3){
        num = [[[resultArray[3] stringValue] componentsSeparatedByString:@","] lastObject];
        num = [num stringByReplacingCharactersInRange:NSMakeRange(num.length-1, 1) withString:@""];
    }
    //    ["time,powerCost","1446307200,103","1448899200,0"]
    
    if([groupType isEqualToString:@"day"])  {
        self.pw_day = [num doubleValue] / 1000.f;
        [self generateCurrentQuantWithDateType:groupType];
    }
    
    if([groupType isEqualToString:@"month"]) {
        self.pw_month = [num doubleValue] / 1000.f;
        [self generateCurrentQuantWithDateType:groupType];
    }
}

- (id)restorePlugData:(NSString *)groupType {
    NSData *myEncodedObject = [[NSUserDefaults standardUserDefaults]
                               objectForKey:[NSString stringWithFormat:@"lumi_plug_powerdata_%@_groupType_%@",self.did,groupType]];
    id parsedObj = [NSKeyedUnarchiver unarchiveObjectWithData:myEncodedObject];
    
    NSString *resultString = [parsedObj substringWithRange:NSMakeRange(1, [parsedObj length] - 2)];
    NSArray *resultArray = [resultString componentsSeparatedByString:@","];
    NSString *num = [NSString string];
    if(resultArray.count > 3){
        num = [[[resultArray[3] stringValue] componentsSeparatedByString:@","] lastObject];
        num = [num stringByReplacingCharactersInRange:NSMakeRange(num.length-1, 1) withString:@""];
    }
    //    ["time,powerCost","1446307200,103","1448899200,0"]
    
    if([groupType isEqualToString:@"day"])  {
        self.pw_day = [num doubleValue] / 1000.f;
        [self generateCurrentQuantWithDateType:groupType];
    }
    
    if([groupType isEqualToString:@"month"]) {
        self.pw_month = [num doubleValue] / 1000.f;
        [self generateCurrentQuantWithDateType:groupType];
    }  
    
    return parsedObj;
}

- (void)generateCurrentQuantWithDateType:(NSString *)dateType {
     MHLumiPlugQuantEngine *quantEngine = [MHLumiPlugQuantEngine sharedEngine];
    if ([dateType isEqualToString:@"day"]) {
        MHLumiPlugQuant *currentDay = [[MHLumiPlugQuant alloc] init];
        currentDay.deviceId = self.did;
        currentDay.dateString = [quantEngine dateString:[NSDate date] withDateType:dateType];
        currentDay.dateType = dateType;
        currentDay.quantValue = [NSString stringWithFormat:@"%.3lf", self.pw_day];
//        NSLog(@"%@", currentDay.dateString);
        quantEngine.currentDay = currentDay;
    }
    if ([dateType isEqualToString:@"month"]) {
        MHLumiPlugQuant *currentMonth = [[MHLumiPlugQuant alloc] init];
        currentMonth.deviceId = self.did;
        currentMonth.dateString = [quantEngine dateString:[NSDate date] withDateType:dateType];
        currentMonth.dateType = dateType;
        currentMonth.quantValue = [NSString stringWithFormat:@"%.3lf", self.pw_month];
//        NSLog(@"%@", currentMonth.dateString);
        quantEngine.currentMonth = currentMonth;
    }
}

- (void)getTimerListWithID:(NSString *)identify
                   Success:(SucceedBlock)success
                   failure:(FailedBlock)failure {
    XM_WS(weakself);
    [self getTimerListWithIdentify:identify success:^(id obj){
        [weakself removeOldTimerWithIdentify:identify andTimerArray:(NSArray *)obj];
        if(success) success(obj);
        
    } failure:^(NSError *error){
        if(failure) failure(error);
        [weakself restoreTimerListWithFinish:^(id obj){
            weakself.powerTimerList = obj;
            weakself.countDownTimer = [weakself fetchCountDownTimer];
        }];
    }];
}

- (void)removeOldTimerWithIdentify:(NSString *)identify
                     andTimerArray:(NSArray *)array {
    NSMutableArray *timerarray = [NSMutableArray arrayWithArray:[self.powerTimerList mutableCopy]];
    
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
    
    if([identify isEqualToString:kACPARTNERCOUNTDOWNTIMERID])
        self.countDownTimer = [self fetchCountDownTimer];
}



- (MHDataDeviceTimer *)fetchCountDownTimer {
    XM_WS(weakself);
    __block MHDataDeviceTimer *cutTimer = nil;
    [self.powerTimerList enumerateObjectsUsingBlock:^(MHDataDeviceTimer *timer, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([timer.identify isEqualToString:kACPARTNERCOUNTDOWNTIMERID]){
            if (timer.isEnabled) {
                cutTimer = timer;
            }
            else {
                [weakself deleteTimerId:timer.timerId success:^(id obj) {
                    
                } failure:^(NSError *v) {
                    [weakself saveTimerList];
                }];
            }
        }
    }];
    return cutTimer;
}


@end
