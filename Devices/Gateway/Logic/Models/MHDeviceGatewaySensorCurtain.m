//
//  MHDeviceGatewaySensorCurtain.m
//  MiHome
//
//  Created by guhao on 15/12/24.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewaySensorCurtain.h"
#import "MHDeviceGatewayBase.h"
#import "MHDeviceListCache.h"
#import "MHDeviceGateway.h"

@implementation MHDeviceGatewaySensorCurtain


- (instancetype)initWithData:(MHDataDevice *)data
{
    self = [super initWithData:data];
    if (self) {
        
    }
    return self;
}

+ (void)load {
    [MHDeviceListManager registerDeviceModelId:DeviceModelgateWaySensorCurtainV1 className:(NSStringFromClass([MHDeviceGatewaySensorCurtain class])) isRegisterBase:YES];
}

+ (BOOL)isDeviceAllowedToShown {
    return YES;
}


+ (NSString* )largeIconNameOfStatus:(MHDeviceStatus)status {
    return @"device_icon_gateway_curtain";
}

+ (NSString *)getViewControllerClassName {
    return @"MHGatewayCurtainViewController";
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
    return NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.curtain", @"plugin_gateway", nil);
}

//是否在主app快联页显示
- (BOOL)isShownInQuickConnectList {
    return NO;
}

#pragma mark - service , 一个设备可以提供多个service（比如双路开关，可以提供两个service）
- (void)buildServices {
    XM_WS(weakself);
    
    self.services = [NSMutableArray new];
    MHDeviceGatewayBaseService *service = [[MHDeviceGatewayBaseService alloc] init];
    service.serviceName = self.name;
    service.serviceId = 0;
    service.serviceParentDid = self.did;
    service.serviceParentClass = NSStringFromClass(self.class);
    service.serviceParentModel = self.model;
    service.serviceIcon = [self getMainPageSensorIconWithService:service];
    service.isOpen = [self.curtain_status isEqualToString:@"open"] ? 1 : 0;
    service.isOnline = self.isOnline;
    service.serviceMethodCallBack = ^(MHDeviceGatewayBaseService *service){
        [weakself serviceMethodCall:service];
    };
    service.serviceChangeNameCall = ^(MHDeviceGatewayBaseService *service){
        [weakself serviceChangeName:service];
    };
    [self.services addObject:service];
}

- (void)serviceMethodCall:(MHDeviceGatewayBaseService *)service {
    NSLog(@"serviceMethodCall service %d is open ? %d",service.serviceId, service.isOpen);
    NSString *parms = service.isOpen ? @"close" : @"open";
    service.isOpen = !service.isOpen;
    service.serviceIcon = [self getMainPageSensorIconWithService:service];
    BOOL isOpen = service.isOpen;
    UIImage *icon = service.serviceIcon;
    
    [self switchCurtainWithStatus:parms Success:^(id obj) {
        service.isOpen = isOpen;
        service.serviceIcon = icon;
        if(service.serviceMethodSuccess)service.serviceMethodSuccess(obj);
    } andFailure:^(NSError *error) {
        NSLog(@"error = %@",error);
        service.isOpen = !service.isOpen;
        service.serviceIcon = [self getMainPageSensorIconWithService:service];
        if(service.serviceMethodFailure)service.serviceMethodFailure(error);
    }];
}

#pragma mark - 获取首页展示图片
- (UIImage *)updateMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    UIImage *custom = [super updateMainPageSensorIconWithService:service];
    if(!custom){
        if(service.isOpen) return [UIImage imageNamed:@"gateway_curtain_on"];
        return [UIImage imageNamed:@"gateway_curtain_off"];
    }
    return custom;
}

- (UIImage *)getMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    UIImage *custom = [super getMainPageSensorIconWithService:service];
    if(!custom){
        if(service.isOpen) return [UIImage imageNamed:@"gateway_curtain_on"];
        return [UIImage imageNamed:@"gateway_curtain_off"];
    }
    return custom;
}

#pragma mark - curtain payload
- (void)getPropertyWithSuccess:(SucceedBlock)success andFailure:(FailedBlock)failure {
    XM_WS(weakself);
    //profile文档不明确,暂时先传字符串 //get_prop_curtain
    NSDictionary *payload = [self requestPayloadWithMethodName:@"get_device_prop" value:@[ @"curtain_status" ]];
//    [self sendPayload:payload success:^(id respObj) {
//        if([[respObj valueForKey:@"result"] isKindOfClass:[NSArray class]] &&
//           [[respObj valueForKey:@"result"] count] > 1 &&
//           [[respObj valueForKey:@"result"][1] isKindOfClass:[NSString class]]
//           ){
//            NSLog(@"%@", respObj);
//            weakself.curtain_level = [[respObj valueForKey:@"result"][0] intValue];
//            weakself.curtain_status = [respObj valueForKey:@"result"][1];
//            if (success) {
//                success(respObj);
//            }
//        }
//    } failure:^(NSError *error) {
//        if (error) {
//            NSLog(@"%@", error);
//            failure(error);/*
//                            Error Domain=ServerRejected Code=-10000 "(null)" UserInfo={message=Method not found., result=, code=-10000}
//                            */
//        }
//    }];
    MHDeviceRPCRequest* request = [[MHDeviceRPCRequest alloc] init];
    request.deviceId = self.did;
    request.payload = payload;
    [self sendRPC:request success:^(id respObj) {
        if ([[respObj valueForKey:@"result"] isKindOfClass:[NSArray class]] &&
            [[respObj valueForKey:@"result"] count] > 1) {
            NSLog(@"%@", respObj);
            weakself.curtain_level = [[respObj valueForKey:@"result"][0] intValue];
            weakself.curtain_status = [respObj valueForKey:@"result"][1];
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

- (void)switchCurtainWithStatus:(NSString *)status
                        Success:(void (^)(id))success
                     andFailure:(void (^)(NSError *))failure {
    XM_WS(weakself);
    //status @"open" @"close" @"stop"
//    NSDictionary *payload = [self requestPayloadWithMethodName:@"toggle_device" value:@[ status ]];
    NSDictionary *payload = [self subDevicePayloadWithMethodName:@"toggle_device" deviceId:self.did value:@[ status ]];
    
    [self sendPayload:payload success:^(id respObj) {
        NSLog(@"%@", respObj);
        if ([weakself.curtain_status isEqualToString:@"open"]) {
            weakself.curtain_status = @"close";
            weakself.isOpen = NO;
        }
        else {
            weakself.curtain_status = @"open";
            weakself.isOpen = YES;
        }
        if (success) {
            success(respObj);
        }
    } failure:^(NSError *error) {
        if (error) {
            failure(error);
        }
    }];
}



- (void)openCurtainSuccess:(void (^)(id obj))success andFailure:(void (^)(NSError *))failure {
    XM_WS(weakself);
    NSDictionary *payload = [self requestPayloadWithMethodName:@"toggle_device" value:@[ @"open" ]];

    MHDeviceRPCRequest* request = [[MHDeviceRPCRequest alloc] init];
    request.deviceId = self.did;
    request.payload = payload;
    [self sendRPC:request success:^(id respObj) {
        NSLog(@"%@", respObj);
        weakself.curtain_status = @"open";
        weakself.isOpen = YES;
        if (success) {
            success(respObj);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];

 
}


- (void)stopCurtainSuccess:(void (^)(id obj))success andFailure:(void (^)(NSError *))failure {
    XM_WS(weakself);
    NSDictionary *payload = [self requestPayloadWithMethodName:@"toggle_device" value:@[ @"stop" ]];
//    [self sendPayload:payload success:^(id respObj) {
//        NSLog(@"%@", respObj);
//        weakself.curtain_status = @"stop";
////        weakself.isOpen = YES;
//        if (success) {
//            success(respObj);
//        }
//    } failure:^(NSError *error) {
//        if (error) {
//            failure(error);
//        }
//    }];
    MHDeviceRPCRequest* request = [[MHDeviceRPCRequest alloc] init];
    request.deviceId = self.did;
    request.payload = payload;
    [self sendRPC:request success:^(id respObj) {
        NSLog(@"%@", respObj);
        weakself.curtain_status = @"stop";
        weakself.isOpen = YES;
        if (success) {
            success(respObj);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];


}

- (void)closeCurtainSuccess:(void (^)(id obj))success andFailure:(void (^)(NSError *))failure {
    XM_WS(weakself);
    NSDictionary *payload = [self requestPayloadWithMethodName:@"toggle_device" value:@[ @"close" ]];
//    [self sendPayload:payload success:^(id respObj) {
//        weakself.curtain_status = @"close";
//        weakself.isOpen = NO;
//        if (success) {
//            success(respObj);
//        }
//    } failure:^(NSError *error) {
//        if (error) {
//            failure(error);
//        }
//    }];
    MHDeviceRPCRequest* request = [[MHDeviceRPCRequest alloc] init];
    request.deviceId = self.did;
    request.payload = payload;
    [self sendRPC:request success:^(id respObj) {
        NSLog(@"%@", respObj);
        weakself.curtain_status = @"close";
        weakself.isOpen = NO;
        if (success) {
            success(respObj);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];

 
}

#pragma mark - 窗帘属性
- (MHDeviceGateway *)fetchCurtainParentDevice {
    __block MHDeviceGateway *gateway = [[MHDeviceGateway alloc] init];
    if (self.parent){
        gateway = self.parent;
    }
    else {
        MHDeviceListCache *deviceListCache = [[MHDeviceListCache alloc] init];
        NSArray *deviceList = [deviceListCache syncLoadAll];
        [deviceList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([[obj valueForKey:@"did"] isEqualToString:self.parent_id]) {
                gateway = (MHDeviceGateway *)obj;
                *stop = YES;
            }
        }];
    }
    return gateway;
}

- (void)setCurtainProperty:(NSInteger)value
                andSuccess:(SucceedBlock)success
                   failure:(FailedBlock)failure {
    
    MHDeviceGateway *gateway = [self fetchCurtainParentDevice];
    
    NSMutableDictionary* payload = [[NSMutableDictionary alloc] init];
    [payload setObject:@( [gateway getRPCNonce] ) forKey:@"id"];
    [payload setObject:@"ctrl_device_prop" forKey:@"method"];
    [payload setObject:self.did forKey:@"sid"];
    [payload setObject:@{ @"curtain_level" : @(value) } forKey:@"params"];
    [gateway sendPayload:payload success:^(id respObj) {
        if (success)success(respObj);
        
    } failure:^(NSError *error) {
        if (failure)failure(error);
    }];
}

- (void)getCurtainPropertyStatusWithSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    MHDeviceGateway *gateway = [self fetchCurtainParentDevice];
    
    NSArray *value = @[ self.did , @"curtain_level" ];
    NSMutableDictionary* payload = [[NSMutableDictionary alloc] init];
    [payload setObject:@( [gateway getRPCNonce] ) forKey:@"id"];
    [payload setObject:@"get_device_prop" forKey:@"method"];
    [payload setObject:value forKey:@"params"];
    
    [gateway sendPayload:payload success:^(id respObj) {
        if (success)success(respObj);
        
    } failure:^(NSError *error) {
        if (failure)failure(error);
    }];
}

#pragma mark - 私有属性
- (void)getPrivatePropertySuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setObject:@( [self getRPCNonce] ) forKey:@"id"];
    [payload setObject:@"get_device_prop" forKey:@"method"];
    [payload setObject:@[ self.did, @"cfg_param" ] forKey:@"params"];
    XM_WS(weakself);
    
    [self sendPayload:payload success:^(id obj) {
        NSLog(@"%@", obj);
        if (![obj[@"code"] boolValue] && [obj[@"message"] isEqualToString:@"ok"]) {
            NSString *strProp = obj[@"result"][0];
            if (strProp.length >= 14) {
                NSString *strWriteMask = [strProp substringWithRange:NSMakeRange(0, 4)];
                NSString *strPosLimitState = [strProp substringWithRange:NSMakeRange(4, 2)];
                NSString *strPolarity = [strProp substringWithRange:NSMakeRange(6, 2)];
                NSString *strMotorStatus = [strProp substringWithRange:NSMakeRange(8, 2)];
                NSString *strManualEnabled = [strProp substringWithRange:NSMakeRange(10, 2)];
                NSString *strTotalTime = [strProp substringWithRange:NSMakeRange(12, 2)];
                
                weakself.writeMask = [strWriteMask intValue];
                weakself.posLimitState = [strPosLimitState boolValue];
                weakself.polarity = [strPolarity boolValue];
                weakself.motorStatus = [strMotorStatus intValue];
                weakself.manualEnabled = [strManualEnabled boolValue];
                weakself.totalTime = [strTotalTime intValue];
                [weakself saveStatus];
                if (success) {
                    success(obj);
                }
            }
        }
    } failure:^(NSError *error) {
        [weakself readStatus];
        NSLog(@"%@", error);
    }];
}

- (void)setPrivateProperty:(WriteMask_Prop_Id)propid value:(id)value success:(SucceedBlock)success failure:(FailedBlock)failure {
    //set_device
    
//    NSString *strWriteMask = [strProp substringWithRange:NSMakeRange(0, 4)];
//    NSString *strPosLimitState = [strProp substringWithRange:NSMakeRange(4, 2)];
//    NSString *strPolarity = [strProp substringWithRange:NSMakeRange(6, 2)];
//    NSString *strMotorStatus = [strProp substringWithRange:NSMakeRange(8, 2)];
//    NSString *strManualEnabled = [strProp substringWithRange:NSMakeRange(10, 2)];
//    NSString *strTotalTime = [strProp substringWithRange:NSMakeRange(12, 2)];
    
//    weakself.writeMask = [strWriteMask intValue];
//    weakself.posLimitState = [strPosLimitState boolValue];
//    weakself.polarity = [strPolarity boolValue];
//    weakself.motorStatus = [strMotorStatus intValue];
//    weakself.manualEnabled = [strManualEnabled boolValue];
//    weakself.totalTime = [strTotalTime intValue];
//
    
    
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setObject:@( [self getRPCNonce] ) forKey:@"id"];
    [payload setObject:@"set_device_prop" forKey:@"method"];
    [payload setObject:@{ @"sid" : self.did, @"cfg_param" : @"" } forKey:@"params"];
    XM_WS(weakself);
    
    [self sendPayload:payload success:^(id obj) {
        NSLog(@"%@", obj);
        if (obj[@"code"] == 0 && [obj[@"message"] isEqualToString:@"ok"]) {
            NSString *strProp = obj[@"result"];
            if (strProp.length >= 14) {
                NSString *strWriteMask = [strProp substringWithRange:NSMakeRange(0, 4)];
                NSString *strPosLimitState = [strProp substringWithRange:NSMakeRange(4, 2)];
                NSString *strPolarity = [strProp substringWithRange:NSMakeRange(6, 2)];
                NSString *strMotorStatus = [strProp substringWithRange:NSMakeRange(8, 2)];
                NSString *strManualEnabled = [strProp substringWithRange:NSMakeRange(10, 2)];
                NSString *strTotalTime = [strProp substringWithRange:NSMakeRange(12, 2)];
                
                weakself.writeMask = [strWriteMask intValue];
                weakself.posLimitState = [strPosLimitState boolValue];
                weakself.polarity = [strPolarity boolValue];
                weakself.motorStatus = [strMotorStatus intValue];
                weakself.manualEnabled = [strManualEnabled boolValue];
                weakself.totalTime = [strTotalTime intValue];
                [weakself saveStatus];
                if (success) {
                    success(obj);
                }
            }
        }
    } failure:^(NSError *error) {
        [weakself readStatus];
        NSLog(@"%@", error);
    }];

}


- (void)saveStatus {
    
}


- (void)readStatus {
    
}

@end
