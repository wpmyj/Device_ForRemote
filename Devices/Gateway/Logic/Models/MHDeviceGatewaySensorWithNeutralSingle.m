//
//  MHDeviceGatewaySensorCtrlLn1.m
//  MiHome
//
//  Created by ayanami on 9/5/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewaySensorWithNeutralSingle.h"
#import "MHDeviceGatewayBase.h"
#import "MHLumiPlugQuantEngine.h"
#import "MHLumiPlugDataManager.h"

@implementation MHDeviceGatewaySensorWithNeutralSingle
- (id)initWithData:(MHDataDevice *)data
{
    self = [super initWithData:data];
    if (self) {
    }
    return self;
}

+ (void)load {
    [MHDeviceListManager registerDeviceModelId:DeviceModelgateWaySensorCtrlLn1V1 className:NSStringFromClass([MHDeviceGatewaySensorWithNeutralSingle class]) isRegisterBase:YES];
}

+ (NSUInteger)getDeviceType {
    return MHDeviceType_GatewaySensorNeutral1;
}

- (NSString* )eventNameOfStatusChange {
    return Gateway_Event_CtrlLn1_Change;
}



+ (NSString* )largeIconNameOfStatus:(MHDeviceStatus)status {
    return @"device_icon_gateway_neutral";
}

+ (BOOL)isDeviceAllowedToShown {
    return YES;
}

+ (NSString *)getViewControllerClassName {
    return @"MHGatewayWithNeutralSingleViewController";
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
    return NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.singleneutral", @"plugin_gateway", nil);
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
    MHDeviceGatewayBaseService *service = [[MHDeviceGatewayBaseService alloc] init];
    service.serviceName = self.name;
    service.serviceId = 0;
    service.serviceParentDid = self.did;
    service.serviceParentClass = NSStringFromClass(self.class);
    service.serviceParentModel = self.model;
    service.isOpen = [self.channel_0 isEqualToString:@"on"] ? 1 : 0;
    service.isOnline = self.isOnline;
    service.isDisable = (!self.isOnline) || ([self.channel_0 isEqualToString:@"disable"] ? 1 : 0);
    service.serviceIcon = [self getMainPageSensorIconWithService:service];
    service.serviceMethodCallBack = ^(MHDeviceGatewayBaseService *service){
        [weakself serviceMethodCall:service];
    };
    service.serviceChangeNameCall = ^(MHDeviceGatewayBaseService *service){
        [weakself serviceChangeName:service];
    };
    [self.services addObject:service];
}

- (void)updateServices {
    XM_WS(weakself);
    
    [self.services enumerateObjectsUsingBlock:^(MHDeviceGatewayBaseService *service, NSUInteger idx, BOOL * _Nonnull stop) {
        service.serviceName = weakself.name;
        service.isOnline = weakself.isOnline;
        service.isOpen = [weakself.channel_0 isEqualToString:@"on"] ? 1 : 0;
        service.isDisable = (!weakself.isOnline) || ([weakself.channel_0 isEqualToString:@"disable"] ? 1 : 0);
        service.serviceIcon = [weakself getMainPageSensorIconWithService:service];
    }];
    
}

- (void)serviceMethodCall:(MHDeviceGatewayBaseService *)service {
    XM_WS(weakself);
    NSString *parms = service.isOpen ? @"off" : @"on";
    
    [self switchNeutralWithParam:parms Success:^(id obj) {
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
- (UIImage *)updateMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    UIImage *custom = [super updateMainPageSensorIconWithService:service];
    if(!custom){
        if(service.isOpen) return [UIImage imageNamed:@"home_neutral_light_on"];
        else return [UIImage imageNamed:@"home_neutral_light_off"];
    }
    return custom;
}

- (UIImage *)getMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    UIImage *custom = [super getMainPageSensorIconWithService:service];
    if(!custom){
        if(service.isOpen)  {
            return [UIImage imageNamed:@"home_neutral_light_on"];
        }
        else {
          return [UIImage imageNamed:@"home_neutral_light_off"];
        }
    }
    return custom;
}

#pragma mark - neutral payload
/**
 *  获取开关状态和功率
 *
 *  @param success success description
 *  @param failure failure description
 */
- (void)getPropertyWithSuccess:(SucceedBlock)success andFailure:(FailedBlock)failure {
    XM_WS(weakself);
    NSDictionary *payload = [self subDevicePayloadWithMethodName:@"get_device_prop_exp" deviceId:nil value:@[ @[self.did, @"channel_0" , @"load_power"] ]];
    NSLog(@"%@",payload);
    [self sendPayload:payload success:^(id respObj) {
        if ([[respObj valueForKey:@"result"] isKindOfClass:[NSArray class]] &&
            [[respObj valueForKey:@"result"] count] > 0) {
            NSLog(@"%@", respObj);
            NSArray *result = [[respObj valueForKey:@"result"] firstObject];
            if (result.count < 2) {
                return;
            }
            
            //只处理‘on’或者‘off‘的状态，别的值都不管
            if([result[0] isEqualToString:@"on"] ||
               [result[0] isEqualToString:@"off"]) {
                weakself.channel_0 = result[0];
                weakself.isOpen = [weakself.channel_0 isEqualToString:@"on"];
            }
            else {
                weakself.channel_0 = @"disable";
            }
            double sloadPower = [result[1] doubleValue];
            weakself.sload_power = MAX(sloadPower, 0);
        }
        if (success) success(respObj);
    } failure:^(NSError *error) {
        if (failure) failure(error);

    }];
    

    
}

- (void)switchNeutralWithParam:(NSString *)status
                       Success:(void (^)(id))success
                    andFailure:(void (^)(NSError *))failure {
    XM_WS(weakself);

    NSDictionary *payload = [self subDevicePayloadWithMethodName:@"toggle_ctrl_neutral" deviceId:self.did value:@[ @"channel_0" , status ]];
    

    
    [self sendPayload:payload success:^(id respObj) {
        if ([weakself.channel_0 isEqualToString:@"on"]) {
            weakself.channel_0 = @"off";
            weakself.isOpen = NO;
        }
        else {
            weakself.channel_0 = @"on";
            weakself.isOpen = YES;
        }
        weakself.isOpen = [weakself.channel_0 isEqualToString:@"on"];
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

#pragma mark - plug data
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


@end
