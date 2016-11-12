//
//  MHDeviceGatewayBase.m
//  MiHome
//
//  Created by Woody on 15/4/8.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewayBase.h"
#import "MHDeviceGateway.h"
#import "MHGatewaySceneManager.h"
#import "MHDeviceListCache.h"
#import "MHGatewayBindSceneManager.h"
#import "MHLumiChangeIconManager.h"
#import <MiHomeKit/MHMiioDevice.h>
#import "MHGatewayExtraSceneManager.h"

static NSInteger nonce = 100;
static NSUInteger maxKeyFrameLength = 700;


@interface MHDeviceGatewayBase()

@property (nonatomic, assign) NSInteger pageIndexOfBindList;

@end

@implementation MHDeviceGatewayBase {

}

- (id)initWithData:(MHDataDevice* )data {
    if (self = [super initWithData:data]) {
        self.logManager = [[MHGatewayLogListManager alloc] initWithManagerIdentify:
                           [NSString stringWithFormat:@"%@_%@", @"mhgatewaylogmanager", self.did] device:self];
        self.deviceConnectPattern = MHDeviceConnect_Both;
    }
    return self;
}

- (void)dealloc {
    
}

- (void)getBatteryWithSuccess:(SucceedBlock)success
                      failure:(FailedBlock)failure {
    NSDictionary *payload = [self requestPayloadWithMethodName:@"get_battery"
                                                         value:self.did];
    
    [self sendPayload:payload success:^(id respObj) {
        NSArray* resultList = [respObj objectForKey:@"result" class:[NSArray class]];
        if ([resultList count] > 0) {
            self.battery = [resultList[0] integerValue];
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

//是否展示在极客模式的快联入口
- (BOOL)isShownInQuickConnectList {
    return YES;
}

#pragma mark - 获取属性 子类重写才可用
- (void)getPropertyWithSuccess:(SucceedBlock)success andFailure:(FailedBlock)failure {
    
}

#pragma mark - 联动item管理
- (MHLumiBindItem* )findItem:(MHLumiBindItem* )source {
    for (MHLumiBindItem* item in self.bindList) {
        if ([item isEqualTo:source]) {
            return item;
        }
    }
    return nil;
}

- (void)removeItem:(MHLumiBindItem* )item {
    NSMutableArray *bindList = [NSMutableArray arrayWithArray:self.bindList];
    MHLumiBindItem* found = [self findItem:item];
    if (found) {
        [bindList removeObject:found];
    }
    self.bindList = bindList;
    [self saveBindItems];
}

- (void)addItem:(MHLumiBindItem* )item {
    NSMutableArray *bindList = [NSMutableArray arrayWithArray:self.bindList];
    if (![self findItem:item]) {
        [bindList addObject:item];
    }
    self.bindList = bindList;
    [self saveBindItems];
}

#pragma mark - 联动
- (NSDictionary* )requestPayloadWithMethodName:(NSString* )method
                                         value:(id)value {
    NSMutableDictionary* jason = [[NSMutableDictionary alloc] init];
//    [jason setObject:@( [self getRPCNonce] ) forKey:@"id"];
    [jason setObject:@( nonce++ ) forKey:@"id"];
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

- (NSDictionary *)subDevicePayloadWithMethodName:(NSString *)method deviceId:(NSString *)did value:(id)value {
    NSMutableDictionary* jason = [[NSMutableDictionary alloc] init];
    //    [jason setObject:@( [self getRPCNonce] ) forKey:@"id"];
    [jason setObject:@( [self getRPCNonce] ) forKey:@"id"];
    if (did != nil){
        [jason setObject:did forKey:@"sid"];
    }
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

- (void)getBindPage:(NSInteger)pageIndex
           bindList:(NSMutableArray*)bindList
            success:(SucceedBlock)success
            failure:(FailedBlock)failure {
    NSDictionary *payload = [self requestPayloadWithMethodName:@"bind_page"
                                                         value:@[ self.did, @(pageIndex) ]];
    [self sendPayload:payload success:^(id respObj) {
        NSInteger currentPage = 0;
        NSInteger totalPage = 0;
        
        NSArray* list = [(MHSafeDictionary* )respObj objectForKey:@"result" class:[NSArray class]];
        if ([list count] > 0) {
            for (MHSafeDictionary* item in list) {
                if([item isKindOfClass:[NSDictionary class]]){
                    currentPage = [[item objectForKey:@"current" class:[NSNumber class]] integerValue];
                    totalPage = [[item objectForKey:@"total" class:[NSNumber class]] integerValue];
                    NSArray* bindListInPage = [item objectForKey:@"page" class:[NSArray class]];
                    for (MHSafeDictionary* item in bindListInPage) {
                        MHLumiBindItem* bindItem = [[MHLumiBindItem alloc] init];
                        bindItem.from_sid = [item objectForKey:@"from_sid" class:[NSString class]];
                        bindItem.to_sid = [item objectForKey:@"to_sid" class:[NSString class]];
                        bindItem.method = [item objectForKey:@"method" class:[NSString class]];
                        bindItem.params = [item objectForKey:@"params" class:[NSArray class]];
                        bindItem.event = [item objectForKey:@"event" class:[NSString class]];
                        bindItem.enable = [[item objectForKey:@"enable" class:[NSNumber class]] boolValue];
                        bindItem.index = [[item objectForKey:@"index" class:[NSNumber class]] integerValue];
                        [bindList addObject:bindItem];
                    }
                }
            }
        }
        
        if (currentPage < totalPage-1) {
            self.pageIndexOfBindList++;
            [self getBindPage:self.pageIndexOfBindList bindList:bindList success:success failure:failure];
        } else {
            if (success) {
                success(respObj);
            }
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getBindListWithSuccess:(SucceedBlock)success
                       failure:(FailedBlock)failure {
    [self restoreBindItems];
    _pageIndexOfBindList = 0;
    NSMutableArray* bindList = [[NSMutableArray alloc] init];
    [self getBindPage:_pageIndexOfBindList bindList:bindList success:^(id v) {
        NSLog(@"%@", v);
        self.bindList = bindList;
        self.isBindListGot = YES;
        [self saveBindItems];
        if (success) {
            success(bindList);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)addBind:(MHLumiBindItem* )item
        success:(SucceedBlock)success
        failure:(FailedBlock)failure {

    item.from_sid = self.did;
    
    if ([self.parent_model isEqualToString:kGatewayModelV1] ||
        [self.parent_model isEqualToString:kGatewayModelV2]) {
        NSMutableArray* params = [NSMutableArray arrayWithObjects:self.did, item.event, item.to_sid, item.method, nil];
        for (id param in item.params) {
            [params addObject:param];
        }
        
        NSDictionary *payload = [self requestPayloadWithMethodName:@"bind"
                                                             value:params];
        
        [self sendPayload:payload success:^(id respObj) {
            [self addItem:item];
            if (success) {
                success(respObj);
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];

    }
    else {
        [[MHGatewayBindSceneManager sharedInstance] addScene:item withGateway:self.parent success:^(id obj) {
            [self addItem:item];
            if (success) {
                success(obj);
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
        
//        [self getBindListWithSuccess:^(id obj) {
//            NSArray *currentBindlist = [NSArray arrayWithArray:obj];
//            [currentBindlist enumerateObjectsUsingBlock:^(MHLumiBindItem *currentItem, NSUInteger idx, BOOL * _Nonnull stop) {
//                
//            }];
//        } failure:^(NSError *error) {
//            if (failure) failure(error);
//
//        }];
    }
}

- (void)removeBind:(MHLumiBindItem* )item
           success:(SucceedBlock)success
           failure:(FailedBlock)failure {
    XM_WS(weakself);
    if ([self.parent_model isEqualToString:kGatewayModelV1] ||
        [self.parent_model isEqualToString:kGatewayModelV2]) {
        
        [self getBindListWithSuccess:^(id obj) {
            NSArray *currentBindlist = [NSArray arrayWithArray:obj];
            [currentBindlist enumerateObjectsUsingBlock:^(MHLumiBindItem *currentItem, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([currentItem.event isEqualToString:item.event] &&
                    [currentItem.to_sid isEqualToString:item.to_sid] &&
                    [currentItem.method isEqualToString:item.method] &&
                    [currentItem.from_sid isEqualToString:self.did]) {
                    
                    NSDictionary *payload = [self requestPayloadWithMethodName:@"remove_bind"
                                                                         value:@[ self.did, currentItem.event, currentItem.to_sid, currentItem.method ]];
                    
                    [weakself sendPayload:payload success:^(id respObj) {
                        NSLog(@"删除是否成功%@", respObj);
                        [weakself removeItem:item];
                        if (success) {
                            success(respObj);
                        }
                    } failure:^(NSError *error) {
                        if (failure) failure(error);
                        
                    }];
                    
                }
            }];
        } failure:^(NSError *error) {
            if (failure) failure(error);
            
        }];

    }
    else {
        
        [[MHGatewayBindSceneManager sharedInstance] removeScene:item withGateway:self.parent success:^(id obj) {
            [self removeItem:item];
            if (success) {
                success(obj);
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];

        }
}

- (BOOL)isSetAlarming {
    return NO;
}

- (NSString* )eventNameOfSetAlarming {
    return nil;
}

- (void)setAlarmingWithSuccess:(SucceedBlock)success
                       failure:(FailedBlock)failure {
    MHLumiBindItem* item = [[MHLumiBindItem alloc] init];
    item.event = [self eventNameOfSetAlarming];
    item.from_sid = self.did;
    item.to_sid = SID_Gateway;
    item.method = Method_Alarm;
    item.params = @[ @( [self.parent.default_music_index[0] integerValue] ) ];
    [self addBind:item success:success failure:failure];
}

- (void)removeAlarmingWithSuccess:(SucceedBlock)success
                          failure:(FailedBlock)failure {
    MHLumiBindItem* item = [[MHLumiBindItem alloc] init];
    item.event = [self eventNameOfSetAlarming];
    item.from_sid = self.did;
    item.to_sid = SID_Gateway;
    item.method = Method_Alarm;
    item.params = @[ @( [self.parent.default_music_index[0] integerValue] ) ];
    [self removeBind:item success:success failure:failure];
}

- (BOOL)isSetAlarmClock {
    return NO;
}

- (void)setStopAlarmClockWithSuccess:(SucceedBlock)success
                             failure:(FailedBlock)failure {
    MHLumiBindItem* item = [[MHLumiBindItem alloc] init];
    item.event = [self eventNameOfSetAlarming];
    item.from_sid = self.did;
    item.to_sid = SID_Gateway;
    item.method = Method_StopClockMusic;
    [self addBind:item success:success failure:failure];
}

- (void)removeStopAlarmClockWithSuccess:(SucceedBlock)success
                                failure:(FailedBlock)failure {
    MHLumiBindItem* item = [[MHLumiBindItem alloc] init];
    item.event = [self eventNameOfSetAlarming];
    item.from_sid = self.did;
    item.to_sid = SID_Gateway;
    item.method = Method_StopClockMusic;
    [self removeBind:item success:success failure:failure];
}

- (NSString *)modelCutVersionCode:(NSString *)model {
    NSMutableArray *modelParseArray = [NSMutableArray arrayWithArray:[model componentsSeparatedByString:@"."]];
    id lastObj = [modelParseArray lastObject];
    [modelParseArray removeObject:lastObj];
    
    NSString *modelString = [NSString string];
    for(NSString *objString in modelParseArray){
        modelString = [NSString stringWithFormat:@"%@%@",modelString,objString];
    }
    return modelString;
}

- (BOOL)isSetDoorBell {
    return NO;
}

#pragma mark - service , 一个设备可以提供多个service（比如双路开关，可以提供两个service）
- (void)buildServices {
    XM_WS(weakself);
    if (self.services.count) {
        [self updateServices];
        return;
    }
    self.services = [NSMutableArray new];
    MHDeviceGatewayBaseService *service = [[MHDeviceGatewayBaseService alloc] init];
    service.serviceName = self.name;
    service.serviceId = 0;
    service.serviceParentDid = self.did;
    service.serviceParentClass = NSStringFromClass(self.class);
    service.serviceParentModel = self.model;
    service.isOnline = self.isOnline;
    service.isDisable = !self.isOnline;
    service.isOpen = self.isOpen;
//    service.serviceIcon = [self getMainPageSensorIconWithService:service];
    service.serviceIcon = [self updateMainPageSensorIconWithService:service];
    service.serviceMethodCallBack = ^(MHDeviceGatewayBaseService *service){
        
    };
    service.serviceChangeNameCall = ^(MHDeviceGatewayBaseService *service){
        [weakself serviceChangeName:service];
    };
    [self.services addObject:service];
}

- (void)updateServices {
    XM_WS(weakself);
    [self.services enumerateObjectsUsingBlock:^(MHDeviceGatewayBaseService *service, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![service.serviceName isEqualToString:weakself.name]) {
            service.serviceName = weakself.name;
        }
        service.isOnline = weakself.isOnline;
        service.isDisable = !weakself.isOnline;
        service.isOpen = weakself.isOpen;
        service.serviceIcon = [weakself getMainPageSensorIconWithService:service];
    }];
    
}

#pragma mark - service method
- (void)serviceChangeName:(MHDeviceGatewayBaseService *)service {
    __block NSString *currentName = service.serviceName;
    __block NSString *newName = @"";
    
    if(self.services){
        [self.services enumerateObjectsUsingBlock:^(MHDeviceGatewayBaseService *currentService, NSUInteger idx, BOOL *stop) {
            NSString *oldName = currentService.serviceName;
            if(currentService.serviceId == service.serviceId){
                oldName = service.serviceName;
            }
            if(newName.length) newName = [NSString stringWithFormat:@"%@/%@",newName,oldName];
            else newName = oldName;
        }];
    }
    if(!newName) newName = currentName;
    [self changeName:newName success:^(id obj) {
        if(service.serviceChangeNameSuccess)service.serviceChangeNameSuccess(obj);
    } failure:^(NSError *error) {
        if(service.serviceChangeNameFailure)service.serviceChangeNameFailure(error);
    }];
}

#pragma mark - 获取首页展示图片
- (UIImage *)updateMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    if(!service) return nil;
    return [self fetchNewCustomIcon:service];
}

- (UIImage *)fetchNewCustomIcon:(MHDeviceGatewayBaseService *)service {
    NSString *iconId = [[MHLumiChangeIconManager sharedInstance] restorePdataByService:service
                                                                 withCompletionHandler:^(id result, NSError *error) { }];
    service.serviceIconId = iconId;
    [[MHLumiChangeIconManager sharedInstance] fetchNewPdataByService:service withCompletionHandler:^(id  _Nullable result, NSError * _Nullable error) {
        
    }];
//    NSLog(@"缓存的图标标号%@", iconId);
    service.serviceIconId = iconId;
    NSString *iconName = [service fetchIconNameWithHeader:@"home"];
    if(!iconName) return nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:iconName]) {
        UIImage *icon = [UIImage imageWithContentsOfFile:iconName];
        return icon;
    }
    
    
    return nil;
}
- (UIImage *)getMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    if(!service) return nil;
    return [self fetchCustomIcon:service];
}

- (UIImage *)fetchCustomIcon:(MHDeviceGatewayBaseService *)service {
    
    NSString *iconId = [[MHLumiChangeIconManager sharedInstance] restorePdataByService:service
                                                                 withCompletionHandler:^(id result, NSError *error) { }];
//    NSLog(@"缓存的图标标号%@", iconId);
    service.serviceIconId = iconId;
    NSString *iconName = [service fetchIconNameWithHeader:@"home"];
    if(!iconName) return nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:iconName]) {
        UIImage *icon = [UIImage imageWithContentsOfFile:iconName];
        return icon;
    }
    else {
        [[MHLumiChangeIconManager sharedInstance] fetchIconUrlsByIconId:iconId
                                                            withService:service
                                                      completionHandler:^(id result,NSError *error){ }];
        return nil;
    }
    
}



//处理本地较大数据分帧
- (void)pushLocalCommand:(NSDictionary *)command success:(void (^)())success failure:(void (^)(NSInteger))failure
{
    //编辑
    if ([command[@"method"] isEqualToString:@"miIO.xset"]) {
        NSMutableDictionary *payload = [NSMutableDictionary new];
        payload[@"method"] = @"send_data_frame";
        payload[@"id"] = @([self getRPCNonce]);
        payload[@"params"] = command[@"params"];
        NSLog(@"%@", payload);
        [self sendPayload:payload keyFrameLength:maxKeyFrameLength type:@"scene" success:^(id v) {
            if (success) {
                success();
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error.code);
            }
        }];
    }
    //删除
    if ([command[@"method"] isEqualToString:@"miIO.xdel"]) {
        NSMutableDictionary *payload = [NSMutableDictionary new];
        payload[@"method"] = @"miIO.xdel";
        payload[@"id"] = @([self getRPCNonce]);
        payload[@"params"] = command[@"params"];
        [self sendPayload:payload success:^(id v) {
            if (success) {
                success();
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error.code);
            }

        }];
    }
}

- (void)prepareExtraValueForIFTAction:(MHDataIFTTTAction *)action withAbsoluteDelaytime:(NSUInteger)adt {
    
//    NSLog(@"%@", action.extra);
    
    [[MHGatewayExtraSceneManager sharedInstance] extraInfoForDelayAction:action withAbsoluteDelaytime:adt];
}


- (void)saveBindItems {
    NSString *userID = [MHPassportManager sharedSingleton].currentAccount.userId;
    [[MHPlistCacheEngine sharedEngine] asyncSave:self.bindList
                                          toFile:[NSString stringWithFormat:@"lumi_subDevice_bindlist_%@_%@", userID, self.did]
                                      withFinish:nil];
}


- (void)restoreBindItems {
    NSString *userID = [MHPassportManager sharedSingleton].currentAccount.userId;
    XM_WS(weakself);
    [[MHPlistCacheEngine sharedEngine] asyncLoadFromFile:[NSString stringWithFormat:@"lumi_subDevice_bindlist_%@_%@", userID, self.did] withFinish:^(id obj) {
        weakself.bindList = [NSMutableArray arrayWithArray:obj];
    }];
}


#pragma mark - 定时
- (void)lumiEditTimer:(MHDataDeviceTimer *)timer success:(SucceedBlock)success failure:(FailedBlock)failure {
    
    XM_WS(weakself);
    
    [self editTimer:timer success:^(id obj) {
        
        switch ([obj status]) {
            case 0: {
                if (success) success(obj);

                break;
            }
            case 1: {
                if (failure) failure(nil);

                break;
            }
            case 2: {
                if (success) success(obj);

                break;
            }
            case 3: {
                [weakself deleteTimerId:timer.timerId success:^(id obj) {
                    if (failure) failure(nil);
                } failure:^(NSError *error) {
                    if (failure) failure(nil);
                }];
                break;
            }
            case -1: {
                if (failure) failure(nil);

                break;
            }
            default:
                break;
        }
    } failure:^(NSError *error) {
        if (failure) failure(error);

    }];
}

#pragma mark - 其它
+ (NSString* )getBatteryChangeGuideUrl
{
    return @"";
}

+ (NSString* )getIconImageName {
    return @"gateway";
}
+ (NSString* )getBatteryCategory {
    return @"CR2450";
}

+ (NSString* )getViewControllerClassName {
    return @"MHGatewaySensorViewController";
}


+ (NSString* )offlineTips {
    return NSLocalizedStringFromTable(@"mydevice.offlineview.tips", @"plugin_gateway", nil);
}

+ (NSString *)getFAQUrl {
    return @"https://app-ui.aqara.cn/faq/ios-en/faq.html";
}

- (NSString*)defaultName {
    return NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.base", @"plugin_gateway", nil);
}

#pragma mark - GatewayInfoGetter
- (NSString *)gatewayId{
    return self.did;
}

- (NSString *)subDevicesInfo{
    NSMutableString *contentStr = [NSMutableString string];
    NSArray <MHDevice *>* array = self.subDevices;
    for (MHDevice *device in array){
        NSString *model = [NSString stringWithFormat:@"{ Model: %@,",device.model];
        NSString *did = [NSString stringWithFormat:@"did: %@,",device.did];
        NSString *name = [NSString stringWithFormat:@"name: %@ }",device.name];
        [contentStr appendString:model];
        [contentStr appendString:did];
        [contentStr appendString:name];
        NSString *asdf = device.did;
        NSLog(@"%@",asdf);
    }
    return contentStr;
}

- (void)fetchGatewayInfoWithSuccess:(void (^)(NSString *, NSDictionary *))success failure:(void (^)(NSError *))failure{
    NSString *method = @"miIO.info";
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@( [self getRPCNonce] ) forKey:@"id"];
    [dic setObject:method forKey:@"method"];
    [dic setObject:@[] forKey:@"params"];
    [self sendPayload:dic success:^(id result) {
        NSLog(@"result = %@ ", result);
        NSString *message = [result objectForKey:@"message"];
        if ([message isEqualToString:@"ok"] && success){
            NSArray *resultArray = [result objectForKey:@"result"];
            NSString *info = [NSString stringWithFormat:@"%@",resultArray];
            info = [info stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            info = [info stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSLog(@"%@",info);
            success(info,result);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)fetchZigbeeChannelWithSuccess:(void (^)(NSString *, NSDictionary *))success failure:(void (^)(NSError *))failure{
    NSString *method = @"get_zigbee_channel";
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@( [self getRPCNonce] ) forKey:@"id"];
    [dic setObject:method forKey:@"method"];
    [dic setObject:@[] forKey:@"params"];
    [self sendPayload:dic success:^(id result) {
        NSLog(@"result = %@ ", result);
        NSString *message = [result objectForKey:@"message"];
        if ([message isEqualToString:@"ok"] && success){
            NSArray *resultArray = [result objectForKey:@"result"];
            success(resultArray.firstObject,result);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark - GatewayProtocolGetter
- (void)fetchLumiDpfAesKeyWithSuccess:(void (^)(NSString *, NSDictionary *))success failure:(void (^)(NSError *))failure{
    NSString *method = @"get_lumi_dpf_aes_key";
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@( [self getRPCNonce] ) forKey:@"id"];
    [dic setObject:method forKey:@"method"];
    [dic setObject:@[] forKey:@"params"];
    [self sendPayload:dic success:^(id result) {
        NSLog(@"result = %@ ", result);
        NSString *message = [result objectForKey:@"message"];
        if ([message isEqualToString:@"ok"] && success){
            NSArray *resultArray = [result objectForKey:@"result"];
            success(resultArray.firstObject,result);
        }
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)setLumiDpfAesKeyWithPassWord:(NSString *)passWord success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure{
    NSString *method = @"set_lumi_dpf_aes_key";
    NSString *todoStr = passWord == nil ? @"": passWord;
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@( [self getRPCNonce] ) forKey:@"id"];
    [dic setObject:method forKey:@"method"];
    [dic setObject:@[todoStr] forKey:@"params"];
    [self sendPayload:dic success:^(id result) {
        NSLog(@"result = %@ ", result);
        NSString *message = [result objectForKey:@"message"];
        if ([message isEqualToString:@"ok"] && success){
            success(result);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}


@end
