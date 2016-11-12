//
//  MHGatewayMigrationManager.m
//  MiHome
//
//  Created by Lynn on 5/6/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayMigrationManager.h"
#import <MiHomeKit/MiHomeKit.h>
#import "MHDeviceGateway.h"
#import "MHIFTTTManager.h"
#import "MHIFTTTGetRecordListRequest.h"
#import "MHIFTTTGetRecordListResponse.h"
#import <AFNetworking/AFNetworking.h>
#import "MHGatewayBindSceneManager.h"
#import "MHDeviceGatewayBase.h"

#define isDataReadykey           @"isDataReady"
#define isDeviceListSuccessedKey @"isDeviceListSuccessed"
#define cacheDeviceList          @"cacheDeviceListFile"
#define cacheDataFile            @"cacheDataFile"
#define cacheBindingData         @"cacheBindDataFile"

static NSArray *logic_models = nil;

@interface MHGatewayMigrationManager ()

@property (nonatomic,assign) BOOL isDataReady;
@property (nonatomic,assign) BOOL isDeviceListSuccessed;

@property (nonatomic,strong) NSMutableArray<NSString *> *cloudVersions;//如果云端版本小于网关版本，强制网关备份数据，等待2s，重新下载云端数据进行备份。此检测只进行一次。
@property (nonatomic,strong) NSMutableArray<NSString *> *gatewayVersion;
@property (nonatomic,strong) NSMutableDictionary *cloudData;
@property (nonatomic,strong) id bindData;

@end

@implementation MHGatewayMigrationManager
{
}

+ (id)sharedInstance {
    logic_models = @[ @"lumi.gateway", @"lumi.sensor_switch", @"lumi.sensor_motion", @"lumi.sensor_magnet",
                      @"common_controler", @"luotuo_enocean_controller", @"yee_light_rgb", @"lumi.ctrl_neutral2",
                      @"lumi.sensor_cube", @"lumi.ctrl_neutral1", @"lumi.sensor_ht", @"lumi.plug",
                      @"lumi.sensor_86sw2", @"lumi.curtain", @"lumi.sensor_86sw1", @"lumi.sensor_smoke",
                      @"ge_dimmable_lighting" ];
    static MHGatewayMigrationManager *obj = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        obj = [[MHGatewayMigrationManager alloc] init];
    });
    return obj;
}

#pragma mark - 总入口
- (void)gatewayMigrationInvoker:(MHDeviceGateway *)oldGateway
                     newGateway:(MHDeviceGateway *)newGateway
                    withSuccess:(SucceedBlock)success
                        failure:(FailedBlock)failure
                       progress:(void (^)(CGFloat))progress {
    _isDataReady = [[[NSUserDefaults standardUserDefaults] valueForKey:isDataReadykey] boolValue];
    _isDeviceListSuccessed = [[[NSUserDefaults standardUserDefaults] valueForKey:isDeviceListSuccessedKey] boolValue];
    
    XM_WS(weakself);
    __block void (^sendFrameData)();
    __block void (^processBindData)();
    __block void (^moveAllSceneData)();
    
    moveAllSceneData = ^(){
        //3, 处理所有自动化数据
        [weakself moveSceneData:oldGateway newGateway:newGateway withCompletion:^(CGFloat pg) {
            progress(pg);
            if(pg == 1){
                progress(0.99);
                success(nil);
                //最后成功，将缓存清除
                [[NSUserDefaults standardUserDefaults] setValue:@(0) forKey:isDataReadykey];
                [[NSUserDefaults standardUserDefaults] setValue:@(0) forKey:isDeviceListSuccessedKey];
            }
        }];
    };
    
    processBindData = ^() {
        //2, 处理绑定数据
        NSString *bindListString = [weakself readCacheData:cacheBindingData];
        NSArray *bindList = [weakself bindStringToArray:bindListString];
        
        [weakself processBindingData:bindList newGateway:newGateway withSuccess:^(id obj) {
            progress(0.55);
            moveAllSceneData();

        } failure:^(NSError *error) {
            failure(error);
        }];
    };
    
    sendFrameData = ^(){
        //读取缓存数据
        //1, 分帧发数据
        progress(0.15);
        NSDictionary *data = [weakself readCacheData:cacheDataFile];
        [weakself sendDataFrame:newGateway oldGateway:oldGateway data:data withSuccess:^(id obj) {
            progress(0.25);

            weakself.isDeviceListSuccessed = YES;
            [[NSUserDefaults standardUserDefaults] setValue:@(weakself.isDeviceListSuccessed) forKey:isDeviceListSuccessedKey];
            processBindData();
            
        } failure:^(NSError *error) {
            failure(error);
        }];
    };
    
    if(!_isDataReady) {
        //0, 准备数据，找到最新版本数据
        progress(0.05);
        [weakself fetchRealBackData:oldGateway withSuccess:^(id obj) {
            progress(0.1);

            //准备数据成功
            weakself.isDataReady = YES;
            [[NSUserDefaults standardUserDefaults] setValue:@(weakself.isDataReady) forKey:isDataReadykey];
            sendFrameData();
            
        } failure:^(NSError *error) {
            failure(error);
        }];
    }
    else {
        if(!_isDeviceListSuccessed){
            sendFrameData();
        }
        else {
            processBindData();
        }
    }
}

#pragma mark - 0,准备阶段。找到最新版本数据。
- (void)fetchRealBackData:(MHDeviceGateway *)oldGateway withSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    
    XM_WS(weakself);
    __block void (^fetchGatewayVersion)();
    __block void (^makeGatewayBackup)();
    __block bool needToBackup = NO;
    
    [self fetchCloudBackupData:oldGateway withSuccess:^(id obj) {
        if([[obj valueForKey:@"code"] intValue] == 402 ) {
            makeGatewayBackup();
        }
        else {
            fetchGatewayVersion();
        }
        
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    fetchGatewayVersion = ^(){
        [weakself fetchGatewayVersion:oldGateway withSuccess:^(id obj) {
            if(![weakself.cloudVersions[0] isEqualToString:(NSString*)weakself.gatewayVersion[0]] ||
               ![weakself.cloudVersions[1] isEqualToString:(NSString*)weakself.gatewayVersion[1]] ||
               ![weakself.cloudVersions[2] isEqualToString:(NSString*)weakself.gatewayVersion[2]]) {
                needToBackup = YES;
            }
            
            if(needToBackup){
                makeGatewayBackup();
            }
            else {
                success(obj);
            }
            
        } failure:^(NSError *error) {
            failure(error);
        }];
    };
    
    makeGatewayBackup = ^(){
        [weakself notifyGatewayBackup:oldGateway withSuccess:^(id obj) {
            //等待两秒再从云端获取备份
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakself fetchCloudBackupData:oldGateway withSuccess:^(id obj) {
                    if([[obj valueForKey:@"code"] intValue] == 402 ){
                        failure(nil);
                    }
                    else {
                        success(obj);
                    }
    
                } failure:^(NSError *error) {
                    failure(error);
                }];
            });
            
        } failure:^(NSError *error) {
            failure(error);
        }];
    };
}

#pragma mark : 0.1，获取云端数据
//APP端用以获取网关最新备份数据的接口 https://lumi-app.mi-ae.com.cn/api/v1/migrate/backup
- (void)fetchCloudBackupData:(MHDeviceGateway *)oldGateway
                 withSuccess:(SucceedBlock)success
                     failure:(FailedBlock)failure {
    NSString *url = @"https://app-api.aqara.cn/api/v1/migrate/backup";
    //其中logic为V2网关绑定数据，不一定有数据。前面zigbee，dev_list直接分帧下发新网关
    NSString *params = [NSString stringWithFormat:@"?did=%@&params=['%@','%@','%@']", oldGateway.did, @"zigbee", @"dev_list", @"logic"];
    url = [url stringByAppendingString:params];
    XM_WS(weakself);
    [[MHNetworkEngine sharedInstance] RequestCommonURL:url method:MHMethod_POST params:nil timeout:15.f success:^(id respObj) {
        if([[respObj valueForKey:@"code"] intValue] == 402 ) {
            weakself.cloudVersions = [@[@"0",@"0",@"0"] mutableCopy];
            success(respObj);
        }
        else {
            BOOL result = [weakself rawBackupDataProcess:respObj];
            if(result) success(respObj);
            else failure(nil);
        }
    }
    failure:^(NSError *error) {
        failure(error);
    }];
}

//0.1.1 处理云端的数据，获得版本号和数据信息。
- (BOOL)rawBackupDataProcess:(id)respObj {
    self.cloudVersions = [NSMutableArray new];
    if([[respObj valueForKey:@"result"] valueForKey:@"dev_list_ver"]){
        [self.cloudVersions addObject:[[[respObj valueForKey:@"result"] valueForKey:@"dev_list_ver"] stringValue]];
    }
    else {
        [self.cloudVersions addObject:@"0"];
    }
    
    if([[respObj valueForKey:@"result"] valueForKey:@"zigbee_ver"]){
        [self.cloudVersions addObject:[[[respObj valueForKey:@"result"] valueForKey:@"zigbee_ver"] stringValue]];
    }
    else {
        [self.cloudVersions addObject:@"0"];
    }
    
    if([[respObj valueForKey:@"result"] valueForKey:@"logic_ver"]){
        [self.cloudVersions addObject:[[[respObj valueForKey:@"result"] valueForKey:@"logic_ver"] stringValue]];
    }
    else {
        [self.cloudVersions addObject:@"0"];
    }
    
    self.cloudData = [NSMutableDictionary new];
    NSDictionary *data = [[respObj valueForKey:@"result"] valueForKey:@"data"];
    id zigbeeData = data ? [data valueForKey:@"zigbee"] : nil;
    if(zigbeeData != nil)
        [self.cloudData setObject:zigbeeData forKey:@"zigbee"];
    
    id devlistData = data ? [data valueForKey:@"dev_list"] : nil;
    if(devlistData != nil)
        [self.cloudData setObject:devlistData forKey:@"dev_list"];
    
    self.bindData = data ? [data valueForKey:@"logic"] : nil;
    
    BOOL result = [self saveCacheData:self.cloudData withFileName:cacheDataFile];
    result = [self saveCacheData:self.bindData withFileName:cacheBindingData];
    return result;
}

#pragma mark : 0.2 询问网关版本信息
//和云端的进行比对。如果不一致，要求网关重新备份
- (void)fetchGatewayVersion:(MHDeviceGateway *)gateway withSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    NSDictionary *params = @{ @"sid" : @"lumi.0", @"zigbee": @(0), @"dev_list" : @(0) , @"logic" : @(0) };
    NSDictionary *payload = [gateway requestJsonDictionaryPayloadWithMethodName:@"notify_back_up"
                                                                          value:params];

    XM_WS(weakself);
    self.gatewayVersion = [NSMutableArray new];
    [gateway sendPayload:payload success:^(id obj) {
        if([[obj valueForKey:@"result"] valueForKey:@"dev_list_ver"]){
            [weakself.gatewayVersion addObject:[[[obj valueForKey:@"result"] valueForKey:@"dev_list_ver"] stringValue]];
        }
        else {
            [weakself.gatewayVersion addObject:@""];
        }
        
        if([[obj valueForKey:@"result"] valueForKey:@"zigbee_ver"]){
            [weakself.gatewayVersion addObject:[[[obj valueForKey:@"result"] valueForKey:@"zigbee_ver"] stringValue]];
        }
        else{
            [weakself.gatewayVersion addObject:@""];
        }
        
        if([[obj valueForKey:@"result"] valueForKey:@"logic_ver"]){
            [weakself.gatewayVersion addObject:[[[obj valueForKey:@"result"] valueForKey:@"logic_ver"] stringValue]];
        }
        else {
            [weakself.gatewayVersion addObject:@""];
        }
        success(obj);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark : 0.3 强制网关备份
//请将backGroup的数据传够，三个值，按照 zigbee，dev_list，logic的顺序
- (void)notifyGatewayBackup:(MHDeviceGateway *)gateway
                withSuccess:(SucceedBlock)success
                    failure:(FailedBlock)failure {
    
    NSDictionary *params = @{ @"sid" : @"lumi.0", @"dev_list" : @(1), @"zigbee" : @(1), @"logic" : @(1) };

    NSDictionary *payload = [gateway requestJsonDictionaryPayloadWithMethodName:@"notify_back_up"
                                                                          value:params];

    [gateway sendPayload:payload success:^(id obj) {
        success(obj);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - 1,使用缓存数据, 分帧发送数据
- (void)sendDataFrame:(MHDeviceGateway *)newGateway oldGateway:(MHDeviceGateway *)oldGateway
                 data:(NSDictionary *)data
          withSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    
    NSMutableDictionary *payload = [NSMutableDictionary new];
    payload[@"method"] = @"send_data_frame";
    payload[@"id"] = @([newGateway getRPCNonce]);
    payload[@"params"] = data;
    
    XM_WS(weakself);
    [newGateway sendPayload:payload keyFrameLength:700 type:@"gw_data" success:^(id obj) {
        [weakself cloudFlagToDelete:oldGateway];
        [weakself gatewayDeleteDeviceData:oldGateway];
        success(obj);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark : 1.1, 分帧下完标记云端，进行删除
- (void)cloudFlagToDelete:(MHDeviceGateway *)oldGateway {
    NSString *api = @"https://app-api.aqara.cn/api/v1/cfg/resetgw";
    
    //其中logic为V2网关绑定数据，不一定有数据。前面zigbee，dev_list直接分帧下发新网关
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *params = [NSString stringWithFormat:@"?did=%@&cfgKey=%@&cfgValue=%@", oldGateway.did, @"rm_gw_zigbee", @(time * 100)];
    api = [api stringByAppendingString:params];
    
    [[MHNetworkEngine sharedInstance] RequestCommonURL:api method:MHMethod_POST params:nil timeout:15.f success:^(id respObj) {
        NSLog(@"%@",respObj);
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

#pragma mark : 1.2, 标记完成，尝试直接对网关删除
- (void)gatewayDeleteDeviceData:(MHDeviceGateway *)oldGateway {
    NSDictionary *payload = [oldGateway requestPayloadWithMethodName:@"remove_all_device"
                                                               value:@[]];
    
    XM_WS(weakself);
    [oldGateway sendPayload:payload success:^(id obj) {
        [weakself cloudFlagToClearFlag:oldGateway];
    } failure:^(NSError *v) {
        [weakself cloudFlagToDelete:oldGateway];
    }];
}

#pragma mark : 1.3, 网删除成功，重新标记云端
- (void)cloudFlagToClearFlag:(MHDeviceGateway *)oldGateway  {
    NSString *api = @"https://app-api.aqara.cn/api/v1/cfg/resetgw";
    
    //其中logic为V2网关绑定数据，不一定有数据。前面zigbee，dev_list直接分帧下发新网关
    NSString *params = [NSString stringWithFormat:@"?did=%@&cfgKey=%@&cfgValue=%@", oldGateway.did, @"rm_gw_zigbee", @(0)];
    api = [api stringByAppendingString:params];
    
    [[MHNetworkEngine sharedInstance] RequestCommonURL:api method:MHMethod_POST params:nil timeout:15.f success:^(id respObj) {
        NSLog(@"%@",respObj);
    } failure:nil];
}

#pragma mark - 2,处理绑定数据，转自动化数据
- (void)processBindingData:(NSArray *)bindList newGateway:(MHDeviceGateway *)newGateway
               withSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    
    [bindList enumerateObjectsUsingBlock:^(NSString *bindString, NSUInteger idx, BOOL *stop) {
        MHLumiBindItem *item = [[MHLumiBindItem alloc] init];
        
        NSString *from_model = @"";
        NSArray *bindDataArray = [bindString componentsSeparatedByString:@","];
        for(int i = 0; i < bindDataArray.count; i ++){
            NSString *bindValue = [bindDataArray[i] stringValue];
            if(i == 0){ //from_model
                int v = [bindValue intValue];
                if(v < logic_models.count) from_model = logic_models[v];
            }
            else if(i == 1){ //from_sid
                item.from_sid = [@"lumi." stringByAppendingString:bindValue];
            }
            else if(i == 2){ //action_id
                
            }
            else if (i == 3){ //event_index
                int v = [bindValue intValue];
                if([DeviceModelgateWaySensorMotionV2 containsString:from_model]) {
                    if(v == 0) item.event = Gateway_Event_Motion_Motion;
                }
                else if([DeviceModelgateWaySensorSwitchV1 containsString:from_model]) {
                    if(v == 0) item.event = Gateway_Event_Switch_Click;
                }
                else if([DeviceModelgateWaySensorMagnetV1 containsString:from_model]) {
                    if(v == 0) item.event = Gateway_Event_Magnet_Open;
                    if(v == 1) item.event = Gateway_Event_Magnet_Close;
                }
            }
            else if(i == 4){ // method_index
                int v = [bindValue intValue];
                if(v == 1) item.method = Method_Alarm;
                if(v == 12) item.method = Method_Door_Bell;
                if(v == 11) item.method = Method_Welcome;
                if(v == 13) item.method = Method_ToggleLight;
                if(v == 14) item.method = Method_OpenNightLight;
                if(v == 18) item.method = Method_StopClockMusic;
            }
            else if (i == 5){ //enable
                item.enable = [bindValue boolValue];
            }
            else if (i == 6){ //params
                item.params = @[bindValue];
            }
        }
        
        item.to_sid = newGateway.did;
        
        if(from_model.length == 0 || item.from_sid == nil || item.event == nil || item.method == 0 || item.enable == 0 ){
            NSLog(@"%@",item);
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * idx * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[MHGatewayBindSceneManager sharedInstance] addScene:item withGateway:newGateway success:^(id obj) {
                    NSLog(@"%@",obj);
                } failure:^(NSError *error) {
                    NSLog(@"%@",error);
                }];
            });
        }
        
        if(idx == bindList.count - 1) success(nil);
    }];
}

#pragma mark - 3,获取所有自动化，进行自动化迁移
- (void)moveSceneData:(MHDeviceGateway *)oldGateway newGateway:(MHDeviceGateway *)newGateway withCompletion:(void (^)(CGFloat))finish {
    NSMutableArray *subDevices = [NSMutableArray arrayWithObject:oldGateway.did];
    for(MHDeviceGatewayBase *device in oldGateway.subDevices){
        [subDevices addObject:device.did];
    }

    //us_id 置空， trigger/action 里面的did，model，（只对本网关）替换成新网关的
    XM_WS(weakself);
    //获取旧网关数据
    [[MHIFTTTManager sharedInstance] getRecordsOfDevices:subDevices completion:^(NSArray *allScenes) {
        BOOL flag = [weakself processScenes:allScenes oldGateway:oldGateway newGateway:newGateway];
        if(flag) finish(0.7);
    }];
    
    [self getRecordsOfDevices:subDevices completion:^(NSArray *allScenes) {
        BOOL flag = [weakself processScenes:allScenes oldGateway:oldGateway newGateway:newGateway];
        if(flag) finish(1);
    }];
}

- (BOOL)processScenes:(NSArray *)allScenes oldGateway:(MHDeviceGateway *)oldGateway newGateway:(MHDeviceGateway *)newGateway {
    NSMutableArray *editedScenes = [allScenes mutableCopy];
    for(MHDataIFTTTRecord *record in editedScenes){
        record.us_id = nil;
        NSMutableArray *authed = [NSMutableArray new];
        for(NSString *did in record.authed){
            NSString *newDid = did;
            if([did isEqualToString:oldGateway.did]){
                newDid = newGateway.did;
            }
            [authed addObject:newDid];
        }
        record.authed = [authed mutableCopy];
        
        for(MHDataIFTTTTrigger *trigger in record.triggers){
            if([trigger.did isEqualToString:oldGateway.did]){
                trigger.did = newGateway.did;
                trigger.model = newGateway.model;
                trigger.deviceName = newGateway.name;
            }
        }
        
        for(MHDataIFTTTAction *action in record.actions){
            if([action.did isEqualToString:oldGateway.did]){
                action.did = newGateway.did;
                action.model = newGateway.model;
                action.deviceName = newGateway.name;
            }
        }
    }
    
    for(int i = 0 ; i < allScenes.count; i++){
        MHDataIFTTTRecord *record = allScenes[i];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[MHIFTTTManager sharedInstance] editRecord:record success:nil failure:nil];
        });
        if(i == allScenes.count-1) return true;
    }
    
    return true;
}

#pragma mark : 3.1, 获取所有自动化"8",定时自动化
//定时自动化用云端接口获取数据，修改did,model,us_id置空
- (void)getRecordsOfDevices:(NSArray*) dids completion:(void (^)(NSArray *))completion {
    MHIFTTTGetRecordListRequest* request = [MHIFTTTGetRecordListRequest new];
    request.st_id = @"8";
    request.dids = dids;
    [[MHNetworkEngine sharedInstance] sendRequest:request success:^(id json) {
        MHIFTTTGetRecordListResponse* response = [MHIFTTTGetRecordListResponse responseWithJSONObject:json];
        if (response.code == MHNetworkErrorOk) {
            NSMutableArray* records;
            if ([response.recordList count]) {
                records = [response.recordList mutableCopy];
            }
            if (completion) {
                completion(records);
            }
        }
    } failure:^(NSError *error) {
        completion(nil);
    }];
}

#pragma mark - 缓存
- (BOOL)saveCacheData:(id)obj withFileName:(NSString *)fileName {
    return [[MHPlistCacheEngine sharedEngine] syncSave:obj toFile:fileName] == MHPlistCacheEngineResult_Ok;
}

- (id)readCacheData:(NSString *)fileName {
    id data = [[MHPlistCacheEngine sharedEngine] syncLoadFromFile:fileName];
    return data;
}

- (NSArray *)bindStringToArray:(NSString *)bindListString {
    NSMutableArray *bindList = [NSMutableArray new];
    NSArray *group = [bindListString componentsSeparatedByString:@"\",\""];
    for(NSString *bindString in group){
        NSString *newBindString = [NSString string];
        newBindString = [bindString stringByReplacingOccurrencesOfString:@"[" withString:@""];
        newBindString = [newBindString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        newBindString = [newBindString stringByReplacingOccurrencesOfString:@"]" withString:@""];
        [bindList addObject:newBindString];
    }
    return bindList;
}
@end
