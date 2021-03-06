//
//  MHDeviceGatewaySensorCassette.m
//  MiHome
//
//  Created by guhao on 16/1/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewaySensorCassette.h"
#import "MHLumiPlugDataManager.h"
#import "MHDeviceGateway.h"
#import "MHDeviceListCache.h"
#import "MHLumiPlugQuantEngine.h"
#import "MHTimerSettingManager.h"
#define kFAQEN @"https://app-ui.aqara.cn/faq/en/mp7Socket.html"
#define kFAQCN @"https://app-ui.aqara.cn/faq/cn/mp7Socket.html"

//static NSDictionary *logoNames = nil;

@implementation MHDeviceGatewaySensorCassette

+ (void)load {
    logoNames = @{ @"default": NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.logo.default",@"plugin_gateway", ""),
                   @"bulb":NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.logo.bulb",@"plugin_gateway", ""),
                   @"heater":NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.logo.heater", @"plugin_gateway",""),
                   @"air":NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.logo.aircondition",@"plugin_gateway", "")};
    [MHDevListManager registerDeviceModelId:DeviceModelgateWaySensor86PlugV1 className:NSStringFromClass([MHDeviceGatewaySensorCassette class]) isRegisterBase:YES];
}

+ (NSUInteger)getDeviceType {
    return MHDeviceType_GatewaySensorPlug;
}

- (NSString* )eventNameOfStatusChange {
    return Gateway_Event_Plug_Change;
}



+ (NSString* )largeIconNameOfStatus:(MHDeviceStatus)status {
    return @"device_icon_gateway_cassette";
}

+ (NSString* )getBatteryCategory {
    return @"CR1632";
}

+ (NSString* )getBatteryChangeGuideUrl {
    return Battery_Change_Guide_Magnet;
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




//是否在主app快联页显示
- (BOOL)isShownInQuickConnectList {
    return YES;
}


+ (BOOL)isDeviceAllowedToShown {
    return YES;
}

+ (NSString *)getViewControllerClassName {
    return @"MHGatewayWallPlugViewController";
}

- (NSArray *)getLogoNames {
    return [logoNames allKeys];
}

- (NSString *)getLogoName:(NSString *)name {
    return [logoNames valueForKey:name];
}

- (NSInteger)category
{
    return MHDeviceCategoryZigbee;
}

- (NSString*)defaultName {
    return NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.plug", @"plugin_gateway", nil);
}

+ (NSString* )offlineTips {
    return NSLocalizedStringFromTable(@"mydevice.gateway.humiture.offlineview.tips",@"plugin_gateway","请尝试");
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
    service.isOpen = [self.neutral_0 isEqualToString:@"on"] ? 1 : 0;
    service.isOnline = self.isOnline;
    service.isDisable = (!self.isOnline) || ([self.neutral_0 isEqualToString:@"disable"] ? 1 : 0);
    //    service.serviceIcon = [self getMainPageSensorIconWithService:service];
    service.serviceIcon = [self updateMainPageSensorIconWithService:service];
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
    NSString *parms = service.isOpen ? @"off" : @"on";
    service.isOpen = !service.isOpen;
    service.serviceIcon = [self getMainPageSensorIconWithService:service];
    BOOL isOpen = service.isOpen;
    UIImage *icon = service.serviceIcon;
    
    [self switchPlugWithToggle:parms Success:^(id obj) {
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
        if (service.isOpen) {
            return [UIImage imageNamed:@"home_plug_other_on"];
        }
        else {
            return [UIImage imageNamed:@"home_plug_other_off"];
        }
    }
    return custom;
}

- (void)updateServices {
    XM_WS(weakself);
    
    [self.services enumerateObjectsUsingBlock:^(MHDeviceGatewayBaseService *service, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![service.serviceName isEqualToString:weakself.name]) {
            service.serviceName = weakself.name;
        }
        service.isOnline = weakself.isOnline;
        service.isOpen = [weakself.neutral_0 isEqualToString:@"on"] ? 1 : 0;
        service.isDisable = (!weakself.isOnline) || ([weakself.neutral_0 isEqualToString:@"disable"] ? 1 : 0);
        service.serviceIcon = [weakself getMainPageSensorIconWithService:service];
    }];
    
}


- (UIImage *)getMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    UIImage *custom = [super getMainPageSensorIconWithService:service];
    if(!custom){
        if (service.isOpen) {
            return [UIImage imageNamed:@"home_plug_other_on"];
        }
        else {
            return [UIImage imageNamed:@"home_plug_other_off"];
        }
    }
    return custom;
}

#pragma mark - 根据countdown timer 计算倒计时的时间长度－－ timer是按照时间执行的，倒计时显示距离现在的时间差
- (void)fetchCountDownTime:(void (^)(NSInteger hour, NSInteger minute))countDownTimer {
    NSDate *currentDate = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *currentComps = [gregorian components:NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:currentDate];
    
    NSInteger currentHour = currentComps.hour;
    NSInteger currentMinute = currentComps.minute;
    NSInteger timerMinute = 0;
    NSInteger timerHour = 0;
    MHDataDeviceTimer *todoTimer = [self fetchCountDownTimer];
    if(todoTimer.isOnOpen){
        timerHour = todoTimer.onHour ;
        timerMinute = todoTimer.onMinute;
    }
    else if(self.countDownTimer.isOffOpen){
        timerHour = todoTimer.offHour ;
        timerMinute = todoTimer.offMinute;
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

#pragma mark - plug load all data
- (void)loadStatus {
    [self getPropertyWithSuccess:nil andFailure:nil];
    [self getTimerListWithID:WallPlugCountDownIdentify Success:nil failure:nil];
    [self getTimerListWithID:WallPlugTimerIdentify Success:nil failure:nil];
    [self fetchPlugDataWithSuccess:nil failure:nil];
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
        quantEngine.currentDay = currentDay;
    }
    if ([dateType isEqualToString:@"month"]) {
        MHLumiPlugQuant *currentMonth = [[MHLumiPlugQuant alloc] init];
        currentMonth.deviceId = self.did;
        currentMonth.dateString = [quantEngine dateString:[NSDate date] withDateType:dateType];
        currentMonth.dateType = dateType;
        currentMonth.quantValue = [NSString stringWithFormat:@"%.3lf", self.pw_month];
        quantEngine.currentMonth = currentMonth;
    }
}
#pragma mark - plug RPC方法
- (void)getPropertyWithSuccess:(SucceedBlock)success andFailure:(FailedBlock)failure {
    XM_WS(weakself);
    NSArray *params = @[self.did, @"channel_0", @"load_power" ];
    NSDictionary *payload = [self subDevicePayloadWithMethodName:@"get_device_prop_exp"
                                                        deviceId:nil
                                                           value:@[params]];
    [self sendPayload:payload success:^(id respObj) {
        NSArray *objArray = [respObj valueForKey:@"result"];
        NSArray *resultArray = [NSArray array];
        if ([objArray isKindOfClass:[NSArray class]] && objArray.count >= 1){
            resultArray = objArray[0];
        }
        
        if ([resultArray isKindOfClass:[NSArray class]] && resultArray.count >= (params.count-1)){
            double sloadPower = [resultArray[1] doubleValue];
            weakself.sload_power = MAX(sloadPower, 0);
            weakself.neutral_0 = resultArray[0];
            weakself.isOpen = [resultArray[0] isEqualToString:@"on"] ? 1 : 0;
            if (!weakself.isOpen) weakself.sload_power = 0;
            if (success){
                success(respObj);
            }
        }else{
            if (failure) failure(nil);
        }
    } failure:^(NSError *error) {
        weakself.neutral_0 = @"disable";
        if (failure) failure(error);
    }];
}

- (void)switchPlugWithToggle:(NSString *)toggle
                     Success:(SucceedBlock)success
                  andFailure:(FailedBlock)failure {
    XM_WS(weakself);
    NSDictionary *payload = [self subDevicePayloadWithMethodName:@"toggle_plug" deviceId:self.did value:@[ @"channel_0", toggle ]];
    [self sendPayload:payload success:^(id respObj) {
        if([toggle isEqualToString:@"off"]){
            weakself.neutral_0 = @"off";
            weakself.isOpen = NO;
            weakself.sload_power = 0;
            if (success) success(respObj);
        }else if([toggle isEqualToString:@"on"]){
            [weakself getPropertyWithSuccess:^(id obj) {
                weakself.neutral_0 = @"on";
                weakself.isOpen = YES;
                if (success) success(obj);
            } andFailure:^(NSError *error) {
                weakself.neutral_0 = @"on";
                weakself.isOpen = YES;
                if (success) success(error);
            }];
        }
        
    } failure:^(NSError *error) {
        if (failure)failure(error);
    }];
    
}
#pragma mark - plug protect
- (MHDeviceGateway *)fetchPlugParentDevice {
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

- (void)setPlugProtect:(NSString *)methodName
             withValue:(NSInteger)value
            andSuccess:(SucceedBlock)success
               failure:(FailedBlock)failure {
    
    MHDeviceGateway *gateway = [self fetchPlugParentDevice];
    
    NSMutableDictionary* payload = [[NSMutableDictionary alloc] init];
    [payload setObject:@( [gateway getRPCNonce] ) forKey:@"id"];
    [payload setObject:@"set_device_prop" forKey:@"method"];
    [payload setObject:@{ @"sid" : self.did, methodName : @(value) } forKey:@"params"];
    
    [gateway sendPayload:payload success:^(id respObj) {
        if (success)success(respObj);
        
    } failure:^(NSError *error) {
        if (failure)failure(error);
    }];
}

- (void)fetchPlugProtectStatusWithSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    MHDeviceGateway *gateway = [self fetchPlugParentDevice];
    
    NSArray *value = @[ self.did , @"poweroff_memory" , @"charge_protect" , @"en_night_tip_light" ];
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

#pragma mark - 重写gettimerlist
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
            [timerarray removeObject: timer];
        }
    }
    if([array isKindOfClass:[NSArray class]]) {
        if(timerarray) [timerarray addObjectsFromArray:array];
        else timerarray = [array mutableCopy];
    }
    self.powerTimerList = timerarray;
    [self saveTimerList];
    
    if([identify isEqualToString:WallPlugCountDownIdentify])
        self.countDownTimer = [self fetchCountDownTimer];
    
}

- (MHDataDeviceTimer *)fetchCountDownTimer {
    XM_WS(weakself);
    MHDataDeviceTimer *todoTimer;
    for (MHDataDeviceTimer *timer in self.powerTimerList){
        if ([timer.identify isEqualToString:WallPlugCountDownIdentify]){
            if(todoTimer == nil && timer.isEnabled){
                todoTimer = timer;
            }else {
                [self deleteTimerId:timer.timerId success:^(id obj) {
                    [weakself saveTimerList];
                } failure:nil];
            }
        }
    }
    return todoTimer;
}

- (void)setCountDownTimer:(MHDataDeviceTimer *)timer success:(void (^)(void))success failure:(void (^)(void))failure{
    self.countDownTimer = timer;
    [self getTimerListWithIdentify:WallPlugTimerIdentify success:^(id obj) {
    } failure:^(NSError *error) {
        
    }];
}

- (MHDataDeviceTimer *)countDownTimer{
    return [self fetchCountDownTimer];
}

@end
