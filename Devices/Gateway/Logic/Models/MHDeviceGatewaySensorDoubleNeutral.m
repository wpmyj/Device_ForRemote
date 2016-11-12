//
//  MHDeviceGatewaySensorNeutral2.m
//  MiHome
//
//  Created by guhao on 15/12/9.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewaySensorDoubleNeutral.h"
#import "MHDeviceGatewayBase.h"

@implementation MHDeviceGatewaySensorDoubleNeutral

- (id)initWithData:(MHDataDevice *)data
{
    self = [super initWithData:data];
    if (self) {
    }
    return self;
}

+ (void)load {
    [MHDeviceListManager registerDeviceModelId:DeviceModelgatewaySencorCtrlNeutral2V1 className:NSStringFromClass([MHDeviceGatewaySensorDoubleNeutral class]) isRegisterBase:YES];
}

+ (NSUInteger)getDeviceType {
    return MHDeviceType_GatewaySensorNeutral2;
}

- (NSString* )eventNameOfStatusChange {
    return Gateway_Event_Neutral_Change;
}



+ (NSString* )largeIconNameOfStatus:(MHDeviceStatus)status {
    return @"device_icon_gateway_doubleNeutral";
}

+ (BOOL)isDeviceAllowedToShown {
    return YES;
}

+ (NSString *)getViewControllerClassName {
    return @"MHGatewayNeutralViewController";
}

+ (NSString* )getBatteryCategory {
    return @"CR1632";
}

+ (NSString* )getBatteryChangeGuideUrl {
    return Battery_Change_Guide_Switch;
}

- (NSInteger)category
{
    return MHDeviceCategoryZigbee;
}

- (NSString*)defaultName {
    return NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.doubleneutral", @"plugin_gateway", nil);
}

+ (NSString* )offlineTips {
    return NSLocalizedStringFromTable(@"mydevice.gateway.neutral.offlineview.tips",@"plugin_gateway","请尝试");
}

#pragma mark - service , 一个设备可以提供多个service（比如双路开关，可以提供两个service）
- (void)buildServices {
    XM_WS(weakself);
    if (self.services.count) {
        [self updateServices];
        return;
    }

    self.services = [NSMutableArray new];
    NSArray *names = [self.name componentsSeparatedByString:@"/"];
    if(names.count < 2) names = @[self.name,self.name];
        
    MHDeviceGatewayBaseService *service = [[MHDeviceGatewayBaseService alloc] init];
    service.serviceName = names[0];
    service.serviceId = 0;
    service.serviceParentDid = self.did;
    service.serviceParentClass = NSStringFromClass(self.class);
    service.serviceParentModel = self.model;
    service.isOpen = [self.neutral_0 isEqualToString:@"on"] ? 1 : 0;
    service.isDisable = (!self.isOnline) || ([self.neutral_0 isEqualToString:@"disable"] ? 1 : 0);
    service.isOnline = self.isOnline;
    service.serviceIcon =  [self getMainPageSensorIconWithService:service];
    service.serviceMethodCallBack = ^(MHDeviceGatewayBaseService *service){
        [weakself serviceMethodCall:service];
    };
    service.serviceChangeNameCall = ^(MHDeviceGatewayBaseService *service){
        [weakself serviceChangeName:service];
    };
    [self.services addObject:service];
    
    MHDeviceGatewayBaseService *service2 = [[MHDeviceGatewayBaseService alloc] init];
    service2.serviceName = names[1];
    service2.serviceId = 1;
    service2.serviceParentDid = self.did;
    service2.serviceParentClass = NSStringFromClass(self.class);
    service2.serviceParentModel = self.model;
    service2.isOpen = [self.neutral_1 isEqualToString:@"on"] ? 1 : 0;
    service2.isDisable = (!self.isOnline) || ([self.neutral_1 isEqualToString:@"disable"] ? 1 : 0);
    service2.isOnline = self.isOnline;
    service2.serviceIcon = [self getMainPageSensorIconWithService:service2];
    service2.serviceMethodCallBack = ^(MHDeviceGatewayBaseService *service){
        [weakself serviceMethodCall:service];
    };
    service2.serviceChangeNameCall = ^(MHDeviceGatewayBaseService *service){
        [weakself serviceChangeName:service];
    };
    [self.services addObject:service2];
}

- (void)serviceMethodCall:(MHDeviceGatewayBaseService *)service {
    XM_WS(weakself);
    NSString *parms = service.isOpen ? @"off" : @"on";
    NSString *neutral = (service.serviceId == 0) ? @"neutral_0" : @"neutral_1";
    
    [self switchNeutralWithNeutral:neutral Param:parms Success:^(id obj) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakself getPropertyWithSuccess:^(id obj) {
                [weakself buildServices];
                if(service.serviceMethodSuccess)service.serviceMethodSuccess(obj);
            } andFailure:^(NSError *v) {
                if(service.serviceMethodSuccess)service.serviceMethodSuccess(obj);
            }];
        });
    } andFailure:^(NSError *error) {
        NSLog(@"error = %@",error);
        if(service.serviceMethodFailure)service.serviceMethodFailure(error);
    }];
}

#pragma mark - 获取首页展示图片
- (void)updateServices {
    XM_WS(weakself);
    NSArray *names = [self.name componentsSeparatedByString:@"/"];
    if(names.count != 2) names = @[self.name,self.name];    

    [self.services enumerateObjectsUsingBlock:^(MHDeviceGatewayBaseService *service, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![service.serviceName isEqualToString:names[idx]]) {
            service.serviceName = names[idx];
        }
        service.isOnline = weakself.isOnline;
        switch (idx) {
            case 0: {
                service.isOpen = [weakself.neutral_0 isEqualToString:@"on"] ? 1 : 0;
                service.isDisable = (!weakself.isOnline) || ([weakself.neutral_0 isEqualToString:@"disable"] ? 1 : 0);
                break;
            }
            case 1: {
                service.isOpen = [weakself.neutral_1 isEqualToString:@"on"] ? 1 : 0;
                service.isDisable = (!weakself.isOnline) || ([weakself.neutral_1 isEqualToString:@"disable"] ? 1 : 0);

                break;
            }
            default:
                break;
        }
        service.serviceIcon = [weakself getMainPageSensorIconWithService:service];
    }];
    
}

- (UIImage *)updateMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    UIImage *custom = [super updateMainPageSensorIconWithService:service];
    if(!custom){
        if(service.isOpen){
            return [UIImage imageNamed:@"home_neutral_light_on"];
        }
        else{
            return [UIImage imageNamed:@"home_neutral_light_off"];
        }
    }
    return custom;
}
- (UIImage *)getMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    UIImage *custom = [super getMainPageSensorIconWithService:service];
    if(!custom){
        if(service.isOpen){
            return [UIImage imageNamed:@"home_neutral_light_on"];
        }
        else{
            return [UIImage imageNamed:@"home_neutral_light_off"];
        }
    }
    return custom;
}

#pragma mark - neutral payload
- (void)getPropertyWithSuccess:(SucceedBlock)success andFailure:(FailedBlock)failure {
    XM_WS(weakself);
    NSDictionary *payload = [self requestPayloadWithMethodName:@"get_prop_ctrl_neutral" value:@[ @"neutral_0", @"neutral_1" ]];
    
    MHDeviceRPCRequest* request = [[MHDeviceRPCRequest alloc] init];
    request.deviceId = self.did;
    request.payload = payload;
    [self sendRPC:request success:^(id respObj) {
        if ([[respObj valueForKey:@"result"] isKindOfClass:[NSArray class]] &&
            [[respObj valueForKey:@"result"] count] > 1 &&
            [[respObj valueForKey:@"result"][0] isKindOfClass:[NSString class]] &&
            [[respObj valueForKey:@"result"][1] isKindOfClass:[NSString class]]) {
            
            //只处理‘on’或者‘off‘的状态，别的值都不管
            if([[respObj valueForKey:@"result"][0] isEqualToString:@"on"] ||
               [[respObj valueForKey:@"result"][0] isEqualToString:@"off"]) {
                weakself.neutral_0 = [respObj valueForKey:@"result"][0];
            }
            else {
                weakself.neutral_0 = @"disable";
            }
            if([[respObj valueForKey:@"result"][1] isEqualToString:@"on"] ||
               [[respObj valueForKey:@"result"][1] isEqualToString:@"off"]) {
                weakself.neutral_1 = [respObj valueForKey:@"result"][1];
            }
            else {
                weakself.neutral_1 = @"disable";
            }
        }
        if (success) {
            success(respObj);
        }
    } failure:^(NSError *error) {
        weakself.neutral_1 = @"disable";
        weakself.neutral_0 = @"disable";
        if (failure) {
            failure(error);
        }
    }];
//    [self sendPayload:payload success:^(id respObj) {
//        if ([[respObj valueForKey:@"result"] isKindOfClass:[NSArray class]]&&
//            [[respObj valueForKey:@"result"] count] > 1 &&
//            [[respObj valueForKey:@"result"][0] isKindOfClass:[NSString class]] &&
//            [[respObj valueForKey:@"result"][1] isKindOfClass:[NSString class]]) {
//            weakself.neutral_0 = [respObj valueForKey:@"result"][1];
//            weakself.neutral_1 = [respObj valueForKey:@"result"][0];
//            NSLog(@"%@", respObj);
//            if (success) {
//                success(respObj);
//            }
//        }
//    } failure:^(NSError *error) {
//        if (failure) {
//            failure(error);
//        }
//    }];
}

- (void)switchNeutralWithNeutral:(NSString *)neutral
                          Param:(NSString *)status
                         Success:(void (^)(id))success
                      andFailure:(void (^)(NSError *))failure {
//    XM_WS(weakself);
//    NSDictionary *payload = [self requestPayloadWithMethodName:@"toggle_ctrl_neutral" value:@[ neutral, status]];
//    MHDeviceRPCRequest* request = [[MHDeviceRPCRequest alloc] init];
//    request.deviceId = self.did;
//    request.payload = payload;
//    
//    [self sendRPC:request success:^(id respObj) {
//        if ([neutral isEqualToString:@"neutral_0"]) {
//            if ([weakself.neutral_0 isEqualToString:@"on"]) {
//                weakself.neutral_0 = @"off";
//            }
//            else {
//                weakself.neutral_0 = @"on";
//            }
//        }
//        else {
//            if ([weakself.neutral_1 isEqualToString:@"on"]) {
//                weakself.neutral_1 = @"off";
//            }
//            else {
//                weakself.neutral_1 = @"on";
//            }
//        }
//        if (success) {
//            success(respObj);
//        }
//
//    } failure:^(NSError *error) {
//        if (failure) {
//            NSLog(@"%@", error);
//            failure(error);
//        }
//
//    }];
    
//    NSMutableDictionary* payload = [[NSMutableDictionary alloc] init];
//    [payload setObject:@( [self getRPCNonce] ) forKey:@"id"];
//    [payload setObject:@"toggle_ctrl_neutral" forKey:@"method"];
//    [payload setObject:self.did forKey:@"sid"];
//    [payload setObject:@[ neutral , status ] forKey:@"params"];
    
    NSDictionary *payload = [self subDevicePayloadWithMethodName:@"toggle_ctrl_neutral" deviceId:self.did value:@[ neutral , status ]];

    [self sendPayload:payload success:^(id respObj) {
        if (success) {
            success(respObj);
        }
    } failure:^(NSError *error) {
        if (failure)failure(error);
    }];


}

#pragma mark - 重写gettimerlist
- (void)getTimerListWithID:(NSString *)identify
                   Success:(SucceedBlock)success
                andFailure:(FailedBlock)failure {
    XM_WS(weakself);
    [self getTimerListWithIdentify:identify success:^(id obj){
        [weakself removeOldTimerWithIdentify:identify andTimerArray:(NSArray *)obj];
        if(success) success(obj);
        
    } failure:^(NSError *error){
        if(failure) failure(error);
        [weakself restoreTimerListWithFinish:^(id obj){
            weakself.powerTimerList = obj;
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
    
}


@end
