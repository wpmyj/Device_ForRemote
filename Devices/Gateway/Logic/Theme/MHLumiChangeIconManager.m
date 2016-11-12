//
//  MHLumiChangeIconManager.m
//  MiHome
//
//  Created by Lynn on 3/18/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLumiChangeIconManager.h"
#import "MHLMDownLoadFileTools.h"
#import "MHGatewayGetZipPDataRequest.h"
#import "MHGatewayGetZipPDataResponse.h"
#import "MHGatewaySetZipPDataRequest.h"
#import "MHGatewaySetZipPDataResponse.h"
#import <AFNetworking/AFNetworking.h>

#define LM_Plug_Icon_PData_Key                  @"lumi_plug_userdata"
#define LM_SingleNeutral_Icon_PData_Key         @"lumi_singleNeutral_userdata"
#define LM_DoubleNeutral0_Icon_PData_Key        @"lumi_neutral0_userdata"
#define LM_DoubleNeutral1_Icon_PData_Key        @"lumi_neutral1_userdata"
#define LM_InfoDevice_Icon_PData_Key            @"lumi_infoDevice_icon_userdata"

#define LM_Wall_Plug_Icon_PData_Key                       @"lumi_wall_plug_userdata"
#define LM_withNeutralSingle_Icon_PData_Key               @"lumi_withNeutral_single_userdata"
#define LM_withNeutralDual_neutral0_Icon_PData_Key        @"lumi_withNeutral_dual_neutral0_userdata"
#define LM_withNeutralDual_neutral1_Icon_PData_Key        @"lumi_withNeutral_dual_neutral1_userdata"


#define LM_Icon_CacheKey            @"lumi_custom_icon_" //lumi_custom_icon_(did)

#define LM_IconId_GetURL            @"http://app-ui.aqara.cn/icon/query-icon"
#define LM_IconId_GetURL_TMP        @"http://192.168.0.92:8088/icon/query-icon"

@implementation MHLumiChangeIconManager

+ (id)sharedInstance {
    static MHLumiChangeIconManager *obj = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        obj = [[MHLumiChangeIconManager alloc] init];
    });
    return obj;
}

#pragma mark - 获取图片URL，并直接下载
- (void)fetchIconUrlsByIconId:(NSString *)iconId
                  withService:(MHDeviceGatewayBaseService *)service
            completionHandler:(CompletionHandler)completionHandler {
    XM_WS(weakself);
    NSString *strUrl = [NSString stringWithFormat:@"%@?deviceModel=%@&iconId=%@", LM_IconId_GetURL, service.serviceParentModel, iconId];
    [[AFHTTPSessionManager manager] GET:strUrl parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] &&
            [responseObject valueForKey:@"sm_open_url"] &&
            [responseObject valueForKey:@"sm_close_url"] &&
            [responseObject valueForKey:@"lg_open_url"] &&
            [responseObject valueForKey:@"lg_close_url"] ) {
            
            NSArray *iconUrlArray = @[ [responseObject valueForKey:@"sm_open_url"],
                                       [responseObject valueForKey:@"sm_close_url"],
                                       [responseObject valueForKey:@"lg_open_url"],
                                       [responseObject valueForKey:@"lg_close_url"] ];
            [weakself deviceIconByService:service iconId:iconId iconUrlArray:iconUrlArray withCompletionHandler:^(id result, NSError *error) {
                if(error){
                    if(completionHandler)completionHandler(nil,error);
                }
                else {
                    if(completionHandler)completionHandler(result,nil);
                }
            }];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(completionHandler) completionHandler(nil , error);
    }];
}

#pragma mark - 图片下载请求接收
- (void)deviceIconByService:(MHDeviceGatewayBaseService *)service
                     iconId:(NSString *)iconId
               iconUrlArray:(NSArray  *)iconUrlArray
      withCompletionHandler:(CompletionHandler)completionHandler {
    
    NSString *deviceType = [self deviceTypeByService:service];
    
    __block NSMutableArray *errorArray = [NSMutableArray arrayWithCapacity:iconUrlArray.count];
    __block NSError *error = nil;
    __block void (^comletionCheck)() = ^(){
        if(errorArray.count) error = errorArray[0];
        if(completionHandler)completionHandler(@"success",error);
    };
    
    XM_WS(weakself);
    [iconUrlArray enumerateObjectsUsingBlock:^(NSString *downloadUrlString, NSUInteger idx, BOOL *stop) {

        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                              inDomain:NSUserDomainMask
                                                                     appropriateForURL:nil create:YES error:nil];
        documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:Lumi_Device_Icons_Path];
        NSFileManager *fileMangager = [NSFileManager defaultManager];
        if(![fileMangager fileExistsAtPath:documentsDirectoryURL.absoluteString]){
            [fileMangager createDirectoryAtURL:documentsDirectoryURL withIntermediateDirectories:YES attributes:nil error:nil];
        }

        NSString *fileName = [weakself fetchFileNameWithDeviceType:deviceType iconUrlIndex:idx iconId:iconId];
        [[MHLMDownLoadFileTools sharedInstance] downloadFileWithURL:downloadUrlString suffix:@".png" saveFilePath:documentsDirectoryURL fileName:fileName andCompletionHandler:^(id result, NSError *error) {
            if(error) [errorArray addObject:error];
            if(idx == iconUrlArray.count - 1) comletionCheck();
        }];
    }];
}

//@[ @"mainpage_on", @"mainpage_off", @"device_on", @"device_off"]
- (NSString *)fetchFileNameWithDeviceType:(NSString *)deviceType
                             iconUrlIndex:(NSInteger)idx
                                   iconId:(NSString *)iconId {
    NSString *header = [NSString string];
    NSString *onoff = [NSString string];
    if(idx == 0 || idx == 2) onoff = @"on";
    if(idx == 1 || idx == 3) onoff = @"off";
    if(idx == 0 || idx == 1) header = @"home";
    if(idx == 2 || idx == 3) header = @"lumi";
    NSString *fileName = [NSString stringWithFormat:@"%@_%@_%@_%@.png",header,deviceType,iconId,onoff];
    return fileName;
}

#pragma mark - 用户配置数据
- (void)setDeviceIconWith:(MHDeviceGatewayBaseService *)service
               withIconId:(NSString *)iconId
        completionHandler:(CompletionHandler)completionHandler {

    NSString *deviceType = [self deviceTypeByService:service];
    
    NSDictionary *pdata = @{ @"did"         : service.serviceParentDid,
                             @"iconid"      : iconId,
                            };

    //先获取当前列表
    XM_WS(weakself);
    [self fetchIconPdataByDeviceType:deviceType withCompletionHandler:^(id  _Nullable result, NSError * _Nullable error) {
        
        if(error) {
            if(completionHandler) completionHandler(nil , error);
        }
        else {
            NSMutableArray *mutableValueList = [NSMutableArray arrayWithArray:result];
            if ([result isKindOfClass:[NSArray class]] && [(NSArray *)result count] > 0) {
                for(NSDictionary *obj in result){
                    for(NSString *key in obj.allKeys){
                        NSRange range = [key rangeOfString:@"did"];
                        if(range.length && [[obj valueForKey:key] isEqualToString:service.serviceParentDid]) {
                            [mutableValueList removeObject:obj];
                        }
                    }
                }
            }
            [mutableValueList addObject:pdata];
            
            //再添加新增项或替换旧项
            [weakself setIconPdataByDeviceType:deviceType valueList:mutableValueList withCompletionHandler:^(id  _Nullable result, NSError * _Nullable error) {
                if(error){
                    if(completionHandler) completionHandler(nil , error);
                }
                else {
                    //成功，存缓存
                    [weakself savePdataByDeviceType:deviceType deviceId:service.serviceParentDid iconId:iconId];
                    NSArray *icons = @[ [weakself fetchFileNameWithDeviceType:deviceType iconUrlIndex:0 iconId:iconId] ,
                                        [weakself fetchFileNameWithDeviceType:deviceType iconUrlIndex:1 iconId:iconId] ,
                                        [weakself fetchFileNameWithDeviceType:deviceType iconUrlIndex:2 iconId:iconId] ,
                                        [weakself fetchFileNameWithDeviceType:deviceType iconUrlIndex:3 iconId:iconId] ];
                    if(completionHandler) completionHandler(icons , nil);
                }
            }];
        }
    }];
}

- (void)fetchIconIdWithService:(MHDeviceGatewayBaseService *)service
             completionHandler:(CompletionHandler)completionHandler  {
    
    NSString *deviceType = [self deviceTypeByService:service];
    [self fetchIconPdataByDeviceType:deviceType withCompletionHandler:^(id  _Nullable result, NSError * _Nullable error) {
//        NSLog(@"设备类型%@", deviceType);
        if(error){
            if(completionHandler)completionHandler (nil , error);
        }
        else {
            for(NSDictionary *obj in result){
                for(NSString *key in obj.allKeys){
                    NSRange range = [key rangeOfString:@"did"];
                    if(range.length && [[obj valueForKey:key] isEqualToString:service.serviceParentDid]) {
                        NSString *iconid = [obj valueForKey:@"iconid"];
                        if(!iconid) iconid = [obj valueForKey:@"iconname"];
                        if(completionHandler) completionHandler(iconid , nil);
                        return;
                    }
                }
            }
            if(completionHandler) completionHandler(@"none", nil);
        }
    }];
}

#pragma mark : 用户配置数据基础接口
- (void)fetchIconPdataByDeviceType:(NSString *)deviceType
             withCompletionHandler:(CompletionHandler)completionHandler {
    
    NSString *keyString = [self deviceTypeToPDataKey:deviceType];
    MHGatewayGetZipPDataRequest *rq = [[MHGatewayGetZipPDataRequest alloc] init];
    rq.keyString = keyString;
    
    [[MHNetworkEngine sharedInstance] sendRequest:rq success:^(id obj){
        MHGatewayGetZipPDataResponse *rep = [MHGatewayGetZipPDataResponse responseWithJSONObject:obj andKeystring:keyString];
        if(rep.code == 0 && [rep.message isEqualToString:@"ok"]) {
            if(completionHandler)completionHandler(rep.valueList,nil);
        }
        else {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedStringFromTable(@"error", @"plugin_gateway", nil) forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:@"formate" code:-10000 userInfo:userInfo];
            if(completionHandler)completionHandler(nil,error);
        }
        
    } failure:^(NSError *error){
        if(completionHandler)completionHandler(nil,error);
    }];
}

- (void)setIconPdataByDeviceType:(NSString *)deviceType
                       valueList:(NSArray *)valueList
           withCompletionHandler:(CompletionHandler)completionHandler {
    
    NSString *keyString = [self deviceTypeToPDataKey:deviceType];
    MHGatewaySetZipPDataRequest *rq = [[MHGatewaySetZipPDataRequest alloc] init];
    rq.value = valueList;
    rq.keyString = keyString;
    
    [[MHNetworkEngine sharedInstance] sendRequest:rq success:^(id obj){
        MHGatewaySetZipPDataResponse *rep = [MHGatewaySetZipPDataResponse responseWithJSONObject:obj];
        if(completionHandler)completionHandler(rep.result,nil);
        
    } failure:^(NSError *error){
        if(completionHandler)completionHandler(nil,error);
    }];
}

- (void)fetchNewPdataByService:(MHDeviceGatewayBaseService *)service withCompletionHandler:(CompletionHandler)completionHandler {
    XM_WS(weakself);
    NSString *deviceType = [self deviceTypeByService:service];

    [self fetchIconIdWithService:service completionHandler:^(id result, NSError *error) {
        if(result) [weakself savePdataByDeviceType:deviceType deviceId:service.serviceParentDid iconId:result];
        if(completionHandler)completionHandler(result,error);
    }];
}

#pragma mark - common
- (NSString *)deviceTypeToPDataKey:(NSString *)deviceType {
    if([deviceType isEqualToString:@"MHDeviceGatewaySensorPlug"] ||
       [deviceType isEqualToString:@"MHDeviceGatewaySensorPlug_Service0"]){
        return LM_Plug_Icon_PData_Key;
    }
    else if([deviceType isEqualToString:@"MHDeviceGatewaySensorDoubleNeutral_Service0"]){
        return LM_DoubleNeutral0_Icon_PData_Key;
    }
    else if([deviceType isEqualToString:@"MHDeviceGatewaySensorDoubleNeutral_Service1"]){
        return LM_DoubleNeutral1_Icon_PData_Key;
    }
    else if([deviceType isEqualToString:@"MHDeviceGatewaySensorSingleNeutral"] ||
            [deviceType isEqualToString:@"MHDeviceGatewaySensorSingleNeutral_Service0"]){
        return LM_SingleNeutral_Icon_PData_Key;
    }
    else if([deviceType isEqualToString:@"MHDeviceGatewaySensorWithNeutralSingle_Service0"]){
        return LM_withNeutralSingle_Icon_PData_Key;
    }
    else if([deviceType isEqualToString:@"MHDeviceGatewaySensorWithNeutralDual_Service0"]){
        return LM_withNeutralDual_neutral0_Icon_PData_Key;
    }
    else if([deviceType isEqualToString:@"MHDeviceGatewaySensorWithNeutralDual_Service1"]){
        return LM_withNeutralDual_neutral1_Icon_PData_Key;
    }
    else if([deviceType isEqualToString:@"MHDeviceGatewaySensorCassette_Service0"]){
        return LM_Wall_Plug_Icon_PData_Key;
    }
    return LM_InfoDevice_Icon_PData_Key;
}

- (NSString *)deviceTypeByService:(MHDeviceGatewayBaseService *)service{
    return [NSString stringWithFormat:@"%@_Service%d",service.serviceParentClass,service.serviceId];
}

#pragma mark - 缓存
- (NSString *)restorePdataByService:(MHDeviceGatewayBaseService *)service
              withCompletionHandler:(CompletionHandler)completionHandler {
    
    NSString *deviceType = [self deviceTypeByService:service];
    
    NSString *keyString = [NSString stringWithFormat:@"%@%@%@",LM_Icon_CacheKey,deviceType,service.serviceParentDid];
    NSString *iconId = [[NSUserDefaults standardUserDefaults] valueForKey:keyString];
//    NSLog(@"缓存的iconId---%@, 设备类型%@", iconId, service.serviceParentClass);
    if(iconId) {
        if ([iconId isEqualToString:@"none"]) {
            return nil;
        }
        return iconId;
    }
    else {
        XM_WS(weakself);
        [self fetchIconIdWithService:service completionHandler:^(id result, NSError *error) {
            if(result) [weakself savePdataByDeviceType:deviceType deviceId:service.serviceParentDid iconId:result];
            if(completionHandler)completionHandler(result,error);
        }];
        
        return nil;
    }

   
}

- (void)savePdataByDeviceType:(NSString *)deviceType
                     deviceId:(NSString *)deviceId
                       iconId:(NSString *)iconId {
    NSString *keyString = [NSString stringWithFormat:@"%@%@%@",LM_Icon_CacheKey,deviceType,deviceId];
    [[NSUserDefaults standardUserDefaults] setObject:iconId forKey:keyString];
}

@end
