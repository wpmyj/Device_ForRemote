//
//  MHDeviceGatewaySensorHumiture.m
//  MiHome
//
//  Created by Lynn on 11/9/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHDeviceGatewayBase.h"
#import "MHDeviceGatewaySensorHumiture.h"
#import <MiHomeKit/MHTimeUtils.h>
#import "MHGatewayHtDataRequest.h"
#import "MHGatewayHtDataResponse.h"


#define kFAQEN @"https://app-ui.aqara.cn/faq/en/mp6TemperatureAndHumiditySensor.html"
#define kFAQCN @"https://app-ui.aqara.cn/faq/cn/mp6TemperatureAndHumiditySensor.html"

#define DryCold  NSLocalizedStringFromTable(@"mydevice.gateway.log.ht.drycold",@"plugin_gateway","dry cold")
#define HumidCold  NSLocalizedStringFromTable(@"mydevice.gateway.log.ht.humidcold",@"plugin_gateway","humid cold")
#define Cold  NSLocalizedStringFromTable(@"mydevice.gateway.log.ht.cold",@"plugin_gateway","cold")
#define Dry  NSLocalizedStringFromTable(@"mydevice.gateway.log.ht.dry",@"plugin_gateway","dry")
#define Comfortable  NSLocalizedStringFromTable(@"mydevice.gateway.log.ht.comfortable",@"plugin_gateway","comfortable")
#define Humid  NSLocalizedStringFromTable(@"mydevice.gateway.log.ht.humid",@"plugin_gateway","humid")
#define DryHot  NSLocalizedStringFromTable(@"mydevice.gateway.log.ht.dryhot",@"plugin_gateway","dry hot")
#define HumidHot  NSLocalizedStringFromTable(@"mydevice.gateway.log.ht.humidhot",@"plugin_gateway","humid hot")
#define Hot  NSLocalizedStringFromTable(@"mydevice.gateway.log.ht.hot",@"plugin_gateway","hot")


@implementation MHDeviceGatewaySensorHumiture

- (id)initWithData:(MHDataDevice* )data {
    if (self = [super initWithData:data]) {
    }
    return self;
}

+ (void)load {
    [MHDevListManager registerDeviceModelId:DeviceModelgatewaySensorHt
                                  className:NSStringFromClass([MHDeviceGatewaySensorHumiture class])
                             isRegisterBase:YES];
}

- (void)getDeviceProp:(NSArray*)propNames
              success:(void (^)(id))success
              failure:(void (^)(NSError *))failure {
//    NSDictionary *payload = [self requestPayloadWithMethodName:@"get_prop_sensor_ht" value:propNames];
    NSDictionary *payload = [self subDevicePayloadWithMethodName:@"get_prop_sensor_ht" deviceId:self.did value:propNames];
    XM_WS(weakself);
//    MHDeviceRPCRequest* request = [[MHDeviceRPCRequest alloc] init];
//    request.deviceId = self.did;
//    request.payload = payload;
//    [self sendRPC:request success:^(id respObj) {
//        if([[respObj valueForKey:@"result"] isKindOfClass:[NSArray class]] &&
//           [[respObj valueForKey:@"result"] count] > 2 &&
//           [[respObj valueForKey:@"result"][0] isKindOfClass:[NSString class]]
//           ){
//            weakself.neutral_0 = [respObj valueForKey:@"result"][0];
//            weakself.isOpen = [weakself.neutral_0 isEqualToString:@"on"] ? 1 : 0;
//            weakself.load_voltage = [[respObj valueForKey:@"result"][1] doubleValue];
//            weakself.sload_power = [[respObj valueForKey:@"result"][2] doubleValue];;
//            if (success) success(respObj);
//        }
//    } failure:^(NSError *error) {
//        if (failure) {
//            failure(error);
//        }
//    }];
    
    [self sendPayload:payload success:^(id respObj) {
        NSLog(@"%@", respObj);
        if([[respObj valueForKey:@"result"] isKindOfClass:[NSArray class]] &&
           [[respObj valueForKey:@"result"] count] > 1 &&
           [[respObj valueForKey:@"result"][0] isKindOfClass:[NSNumber class]]){
            
            CGFloat newTemp = [(NSNumber*)[[respObj valueForKey:@"result"] objectAtIndex:0] intValue] / 100.0;
            CGFloat newHumidity = [(NSNumber*)[[respObj valueForKey:@"result"] objectAtIndex:1] intValue] / 100.0;

            if (newTemp >= 100.0f || !newHumidity) {
                [weakself readStatus];
            }
            else {
                weakself.temperature = newTemp;
                weakself.humidity = newHumidity;
                [weakself saveStatus];
            }
            //            weakself.advice = [weakself getHTStautsWithTemperature:weakself.temperature humidity:weakself.humidity];
        }
        if (success) {
            success(respObj);
        }

    } failure:^(NSError *error) {
        [weakself readStatus];
        if (failure) {
            failure(error);
        }
    }];
    
    
//    [self sendRPC:request success:^(id respObj) {
//        NSLog(@"%@", respObj);
//        if([[respObj valueForKey:@"result"] isKindOfClass:[NSArray class]] &&
//            [[respObj valueForKey:@"result"] count] > 1 &&
//            [[respObj valueForKey:@"result"][0] isKindOfClass:[NSNumber class]]){
//            
//            CGFloat newTemp = [(NSNumber*)[[respObj valueForKey:@"result"] objectAtIndex:0] intValue] / 100.0;
//            CGFloat newHumidity = [(NSNumber*)[[respObj valueForKey:@"result"] objectAtIndex:1] intValue] / 100.0;
//            NSDate *date = [NSDate date];
//            weakself.time = date;
//            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//            [formatter setDateFormat:@"MM/dd HH:mm"];
//            weakself.lastTime = [NSString stringWithFormat:@"%@", [formatter stringFromDate:date]];
//            weakself.humidity ? [weakself saveStatus]  : [weakself readStatus];
//            if (newTemp >= 100.0f || !newHumidity) {
//                [weakself readStatus];
//            }
//            else {
//                weakself.temperature = newTemp;
//                weakself.humidity = newHumidity;
//                [weakself saveStatus];
//            }
//            weakself.advice = [weakself getHTStautsWithTemperature:weakself.temperature humidity:weakself.humidity];
//        }
//        if (success) {
//            success(respObj);
//        }
//    } failure:^(NSError *error) {
//        [weakself readStatus];
//        if (failure) {
//            failure(error);
//        }
//    }];
}


- (void)getHTProp:(NSString *)prop success:(void (^)(id))success failure:(void (^)(NSError *))failure {
//
    MHGatewayHtDataRequest *request = [MHGatewayHtDataRequest new];
    request.did = self.did;
    request.timeStart = 0;
    request.timeEnd = [[NSDate date] timeIntervalSince1970];
    request.key = prop;
    XM_WS(weakself);
    [[MHNetworkEngine sharedInstance] sendRequest:request success:^(id obj) {
        MHGatewayHtDataResponse *rep = [MHGatewayHtDataResponse responseWithJSONObject:obj];
        if ([prop isEqualToString:LUMI_HUMITURE_TEMP_PROP]) {
            [rep.valueList enumerateObjectsUsingBlock:^(NSDictionary *tempDic, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *temp = tempDic[@"value"];
                temp = [temp stringByReplacingOccurrencesOfString:@"[" withString:@""];
                temp = [temp stringByReplacingOccurrencesOfString:@"]" withString:@""];
                NSLog(@"去掉大大大%@", temp);
                NSInteger newTemp = [temp integerValue];
                if (newTemp != 10000) {
                    weakself.temperature = newTemp / 100.0f;
                    [weakself saveStatus];
                    *stop = YES;
                }
            }];
        }
        if ([prop isEqualToString:LUMI_HUMITURE_HUMIDITY_PROP]) {
            [rep.valueList enumerateObjectsUsingBlock:^(NSDictionary *tempDic, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *temp = tempDic[@"value"];
                temp = [temp stringByReplacingOccurrencesOfString:@"[" withString:@""];
                temp = [temp stringByReplacingOccurrencesOfString:@"]" withString:@""];
                NSInteger newTemp = [temp integerValue];
                NSLog(@"去掉大大大湿度%@", temp);
                if (newTemp != 0) {
                    weakself.humidity = newTemp / 100.0f;
                    [weakself saveStatus];
                    *stop = YES;
                }
            }];
        }
        
        if (success) success(obj);

    } failure:^(NSError *error) {
        if (failure) failure(error);

    }];
    
    
}

+ (NSUInteger)getDeviceType {
    return MHDeviceType_GatewaySensorHumiture;
}



+ (NSString* )largeIconNameOfStatus:(MHDeviceStatus)status {
    return @"device_icon_gateway_humiture";
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

+ (BOOL)isDeviceAllowedToShown {
    return YES;
}

+ (NSString*)getViewControllerClassName {
    return @"MHGatewayTempAndHumidityViewController";
}

- (NSInteger)category {
    return MHDeviceCategoryZigbee;
}

- (NSString*)defaultName {
    return NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.humiture", @"plugin_gateway", nil);
}

+ (NSString* )offlineTips {
    return NSLocalizedStringFromTable(@"mydevice.gateway.plug.offlineview.tips",@"plugin_gateway","请尝试");
}
#pragma mark - 获取首页展示图片
- (UIImage *)updateMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    UIImage *custom = [super updateMainPageSensorIconWithService:service];
    if(!custom){
        return [UIImage imageNamed:@"gateway_ht"];
    }
    return custom;
}

- (UIImage *)getMainPageSensorIconWithService:(MHDeviceGatewayBaseService *)service {
    UIImage *custom = [super getMainPageSensorIconWithService:service];
    if(!custom){
//    if(status == Device_Folder || !self.isOnline){
        return [UIImage imageNamed:@"gateway_ht"];
//    }
//    return [self buildDataImage];
    }
    return custom;
}

- (UIImage *)buildDataImage {
    UIView *canvasView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
    canvasView.backgroundColor = [UIColor clearColor];
    
    UIImageView *imgview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gateway_ht_custom.png"]];
    imgview.frame = canvasView.frame;
    [canvasView addSubview:imgview];
    
    UILabel *tmpLabel = [[UILabel alloc] init];
    tmpLabel.text = [NSString stringWithFormat:@"%.1f",self.temperature];
    tmpLabel.font = [UIFont systemFontOfSize:28.f];
    tmpLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.f];
    tmpLabel.center = CGPointMake(12, 9);
    [tmpLabel sizeToFit];
    [canvasView addSubview:tmpLabel];
    
    UILabel *tmpPartLabel = [[UILabel alloc] init];
    tmpPartLabel.text = @"℃";
    tmpPartLabel.font = [UIFont systemFontOfSize:15.f];
    tmpPartLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.f];
    tmpPartLabel.center = CGPointMake(tmpLabel.center.x + 16, tmpLabel.center.y - 14);
    [tmpPartLabel sizeToFit];
    [canvasView addSubview:tmpPartLabel];
    
    UILabel *hLabel = [[UILabel alloc] init];
    hLabel.text = [NSString stringWithFormat:@"%.1f",self.humidity];
    hLabel.font = [UIFont systemFontOfSize:28.f];
    hLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.f];
    hLabel.center = CGPointMake(35, 46);
    [hLabel sizeToFit];
    [canvasView addSubview:hLabel];
    
    UILabel *hpLabel = [[UILabel alloc] init];
    hpLabel.text = @"%";
    hpLabel.font = [UIFont systemFontOfSize:15.f];
    hpLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.f];
    hpLabel.center = CGPointMake(hLabel.center.x + 16, hLabel.center.y - 14);
    [hpLabel sizeToFit];
    [canvasView addSubview:hpLabel];
    
    UIGraphicsBeginImageContext(CGSizeMake(90, 90));
    [canvasView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (NSString *)getStatusText {
    
    float strTemperature = 0;
    float strHumidity = 0;
    NSString* stringDetail = [NSString stringWithFormat:@"%.1f℃ %.1f%%", self.temperature, self.humidity];
    if (!self.humidity) {
        NSDictionary *oldStatus = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"humiture_currentStatus_%@_%@",self.did, [MHPassportManager sharedSingleton].currentAccount.userId]];
        if ([oldStatus isKindOfClass:[NSDictionary class]] && oldStatus.count == 2) {
            strTemperature = [oldStatus[@"temperature"] floatValue];
            strHumidity = [oldStatus[@"humidity"] floatValue];
            stringDetail = [NSString stringWithFormat:@"%.1f℃ %.1f%%", strTemperature, strHumidity];
        }
    }
    return stringDetail;
}
#pragma mark - 缓存
- (void)saveStatus {
    NSMutableDictionary *currentStatus = [[NSMutableDictionary alloc] init];
    [currentStatus setObject:@(self.temperature) forKey:@"temperature"];
    [currentStatus setObject:@(self.humidity) forKey:@"humidity"];
    [[NSUserDefaults standardUserDefaults] setObject:currentStatus forKey:[NSString stringWithFormat:@"humiture_lastStatus_%@_%@",self.did, [MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)readStatus {
    NSDictionary *oldStatus = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"humiture_lastStatus_%@_%@",self.did, [MHPassportManager sharedSingleton].currentAccount.userId]];
    if ([oldStatus isKindOfClass:[NSDictionary class]] && oldStatus.count == 2) {
        self.humidity = [oldStatus[@"humidity"] floatValue];
        self.temperature =  self.humidity ? [oldStatus[@"temperature"] floatValue] : 0;
    }
}

#pragma mark - 提示文字
- (NSString *)getHTStautsWithTemperature:(float)temperature humidity:(float)humidity {
    if (temperature < 18 && ( humidity > 0 && humidity < 30)) {
        return DryCold;
    }
    else if (temperature < 18 && (humidity >= 30 && humidity <= 80)) {
        return Cold;
    }
    else if (temperature < 18 && (humidity > 80 && humidity <= 100)) {
        return HumidCold;
    }
    else if ((temperature >= 18 && temperature <= 27) && (humidity > 0 && humidity < 30)) {
        return Dry;
    }
    else if ((temperature >= 18 && temperature <= 27) && (humidity >= 30 && humidity <= 80)) {
        return Comfortable;
    }
    else if ((temperature >= 18 && temperature <= 27) && (humidity > 80 && humidity <= 100)) {
        return Humid;
    }
    else if ((temperature > 27) && (humidity > 80 && humidity <= 100)) {
        return HumidHot;
    }
    else if (temperature > 27 && ( humidity > 0 && humidity < 30)) {
        return DryHot;
    }
    else if (temperature > 27 && ( humidity >= 30 && humidity <= 80)) {
        return Hot;
    }
    else {
        return @"";
    }
}

@end


