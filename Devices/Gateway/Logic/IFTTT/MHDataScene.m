//
//  MHDataScene.m
//  MiHome
//
//  Created by Lynn on 9/9/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHDataScene.h"
#import "MHGatewaySceneManager.h"
#import <MiHomeKit/MiHomeKit.h>
#import "MHDeviceGateway.h"
#import "MHDeviceGatewayBase.h"
#import "MHDeviceListCache.h"
#import <MiHomeKit/MHDevFactory.h>
#import "MHGatewayExtraSceneManager.h"

@implementation MHDataScene

+ (instancetype)dataWithJSONObject:(id)obj
{
    MHDataScene* scene = [[self alloc] init];

    if(self){
        if([obj isKindOfClass:[NSDictionary class]]){
            scene.uid = [obj valueForKey:@"uid"] ? [obj valueForKey:@"uid"]: @"";
            scene.usId = [obj valueForKey:@"us_id"] ? [obj valueForKey:@"us_id"]: @"";
            scene.name = [obj valueForKey:@"name"] ? [obj valueForKey:@"name"]: @"";
            scene.std_id = [obj valueForKey:@"st_id"] ? [obj valueForKey:@"st_id"]: @"15";
            scene.identify = [obj valueForKey:@"identify"] ? [obj valueForKey:@"identify"]: @"";

            scene.authed = [NSMutableArray arrayWithArray:[obj valueForKey:@"authed"]];
            scene.setting = [NSMutableDictionary dictionaryWithDictionary:[obj valueForKey:@"setting"]];
            
            if([[[obj valueForKey:@"setting"] valueForKey:@"action_list"] isKindOfClass:[NSArray class]]){
                scene.actionList = [NSMutableArray arrayWithCapacity:1];
                scene.actionList = [[MHDataAction dataListWithJSONObjectList:[[obj valueForKey:@"setting"] valueForKey:@"action_list"]] mutableCopy];
            }
            
            scene.launchList = [NSMutableArray arrayWithCapacity:1];
            if ([[[obj valueForKey:@"setting"] valueForKey:@"launch"] isKindOfClass:[NSDictionary class]]) {
                scene.launchList = [[MHDataLaunch dataListWithJSONObjectList:[[[obj valueForKey:@"setting"] valueForKey:@"launch"] valueForKey:@"attr"]] mutableCopy];
            }
            
            scene.enable = [[[obj valueForKey:@"setting"] valueForKey:@"enable"] boolValue];
        }
    }
    return scene;
}

- (void)initLaunchList:(NSArray *)launchList withDevice:(MHDevice *)sensor {
    
    self.launchList = [NSMutableArray arrayWithCapacity:1];
    
    //初始化launch
    for (NSMutableDictionary *launchDic in launchList){
        [launchDic setObject:sensor.did forKey:@"did"];
        [launchDic setObject:sensor.name forKey:@"device_name"];
        MHDataLaunch *launch = [[MHDataLaunch alloc] initWithRecomObject:launchDic];
        [self.launchList addObject:launch];
    }
}

- (void)initActionList:(NSArray *)actionList withDevice:(MHDevice *)sensor {
    
    self.actionList = [NSMutableArray arrayWithCapacity:1];

    //初始化action（判断执行是否是网关）
    NSString *model = [actionList.firstObject valueForKey:@"model"];
    NSString *gatewayModel = @"lumi.gateway";
    NSRange range = [model rangeOfString:gatewayModel];
    if(range.length){
        //是网关
        MHDeviceGateway *gateway = [(MHDeviceGatewayBase *)sensor parent];
        for (NSMutableDictionary *actionDic in actionList){
            NSMutableDictionary *payload = [actionDic valueForKey:@"payload"];
            
            NSString *keyname = [NSString stringWithString:[actionDic valueForKey:@"name"]];
            [actionDic setObject:keyname forKey:@"keyName"];
            [actionDic setObject:gateway.model forKey:@"model"];
            [actionDic setObject:gateway.name forKey:@"name"];
            
            [payload setObject:gateway.did forKey:@"did"];
            [actionDic setObject:payload forKey:@"payload"];
            
            MHDataAction *action = [[MHDataAction alloc] initWithRecomObject:actionDic];
            [self.actionList addObject:action];
        }
    }
    else{
        //不是网关，是否在列表（默认成列表第一个相关设备）
        BOOL istrue = NO;
        
        MHDeviceListCache *deviceListCache = [[MHDeviceListCache alloc] init];
        NSArray *deviceList = [deviceListCache syncLoadAll];

        for (MHDevice *device in deviceList){
            NSRange range = [model rangeOfString:[device.model substringToIndex:device.model.length - 3]];
            if(range.length){
                for (NSMutableDictionary *actionDic in actionList){
                    NSMutableDictionary *payload = [actionDic valueForKey:@"payload"];
                   
                    NSString *keyname = [NSString stringWithString:[actionDic valueForKey:@"name"]];
                    [actionDic setObject:keyname forKey:@"keyName"];
                    [actionDic setObject:device.model forKey:@"model"];
                    [actionDic setObject:device.name forKey:@"name"];
                    
                    [payload setObject:device.did forKey:@"did"];
                    [actionDic setObject:payload forKey:@"payload"];
                    
                    MHDataAction *action = [[MHDataAction alloc] initWithRecomObject:actionDic];
                    [self.actionList addObject:action];
                }
                istrue = YES;
                return ;
            }
        }
        
        //不是网关，不在列表
        if(!istrue){
            for (NSMutableDictionary *actionDic in actionList){

                //不存在的设备，将action name去掉，只保留device name，这样后面就根据这个来判断啦
                [actionDic removeObjectForKey:@"keyName"];
                
                [actionDic setObject:model forKey:@"model"];
                
                MHDevice *device = [MHDevFactory deviceFromModelId:model];
//                NSUInteger modelType = [MHDevFactory deviceTypeFromModelName:model];
//                NSString *deviceName = [MHDevFactory deviceNameFromType:modelType];
                NSString *deviceName = [device defaultName];
                [actionDic setObject:deviceName forKey:@"name"];

                MHDataAction *action = [[MHDataAction alloc] initWithRecomObject:actionDic];
                [self.actionList addObject:action];
            }
        }
    }
    
}

- (BOOL)isEqual:(id)object
{
    MHDataScene *cmpScene = (MHDataScene *)object;
    if(![object isKindOfClass:[self class]]){
        return NO;
    }
    if(self.actionList.count != [[(MHDataScene *)object actionList] count]){
        return NO;
    }
    if(self.launchList.count != [[(MHDataScene *)object launchList] count]){
        return NO;
    }
    
    
    for(int i = 0 ; i < self.launchList.count ; i ++){
        if (![self.launchList[i] isEqual:cmpScene.launchList[i]]){
            return NO;
        }
    }
    for(int i = 0 ; i < self.actionList.count ; i ++){
        if (![self.actionList[i] isEqual:cmpScene.actionList[i]]){
            return NO;
        }
    }
    
    if(self.usId && self.uid && self.std_id)
        return ([cmpScene.name isEqualToString:self.name] &&
                [cmpScene.usId isEqual:self.usId] &&
                [cmpScene.uid isEqual:self.uid] &&
                [cmpScene.std_id isEqual:self.std_id] && cmpScene.enable == self.enable);
    else
        return [cmpScene.name isEqualToString:self.name];
}

- (id)copyWithZone:(NSZone *)zone
{
    MHDataScene *copy = [[[self class] allocWithZone:zone] init];
    copy.name = [self.name copy];
    copy.uid = [self.uid copy];
    copy.usId = [self.usId copy];
    copy.std_id = [self.std_id copy];
    copy.actionList = [self.actionList copy];
    copy.launchList = [self.launchList copy];
    copy.enable = self.enable;
    return copy;
}

#pragma mark - scene 操作
- (void)deleteSceneWithSuccess:(SucceedBlock)success andFailure:(FailedBlock)failure {
    
    MHGatewaySceneManager *sceneManager = [[MHGatewaySceneManager alloc] init];
    [sceneManager deleteSceneWithUsid:self.usId andSuccess:^(id obj){
        if (success) success(obj);
    } andFailure:^(NSError *error){
        if (failure) failure(error);
    }];
}

//scene修改的内容提交到网络
- (void)saveSceneWithSuccess:(SucceedBlock)success andFailure:(FailedBlock)failure {
    //将scene转NSDictionary
    __block NSMutableDictionary *params = [self sceneToDictionary];
    
//    [[MHGatewayExtraSceneManager sharedInstance] mapExtraInfoWithScene:params andSuccess:^(NSMutableDictionary *obj) {
//        NSLog(@"%@",obj);
//        params = obj ;
    
        MHGatewaySceneManager *sceneManager = [[MHGatewaySceneManager alloc] init];
        [sceneManager saveSceneEditWithParms:params andSuccess:^(id obj){
            if (success) success(obj);
        } andfailure:^(NSError *error){
            if (failure) failure(error);
        }];
//    }];
}

- (NSMutableDictionary *)sceneToDictionary
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:1];
    if(self.usId) [dictionary setObject:self.usId forKey:@"us_id"];
    [dictionary setObject:self.name forKey:@"name"];
    [dictionary setObject:self.std_id ? self.std_id :@"15" forKey:@"st_id"];   //直接设置可以吗？
    if(self.identify)[dictionary setObject:self.identify forKey:@"identify"];
    
    NSMutableDictionary *setting = [NSMutableDictionary dictionaryWithCapacity:1];
    if (self.setting){
        setting = self.setting;
    }
    [setting setObject:@(self.enable) forKey:@"enable"];
    
    if (self.authed) [dictionary setObject:self.authed forKey:@"authed"];

    NSMutableArray *authed = [NSMutableArray arrayWithCapacity:1];
    {
        NSMutableArray *action_list = [NSMutableArray arrayWithCapacity:1];
        for (MHDataAction *action in self.actionList){
            [action_list addObject:[MHDataAction actionToDictionary:action]];
            if ([authed indexOfObject:action.deviceDid] == NSNotFound)[authed addObject:action.deviceDid];
        }
        
        NSMutableDictionary *launch = [NSMutableDictionary dictionaryWithCapacity:1];
        NSMutableArray *launch_attr_list = [NSMutableArray arrayWithCapacity:1];
        for (MHDataLaunch *launch in self.launchList){
            [launch_attr_list addObject:[MHDataLaunch launchToDictionary:launch]];
            if ([authed indexOfObject:launch.deviceDid] == NSNotFound)[authed addObject:launch.deviceDid];
        }
        [launch setObject:launch_attr_list forKey:@"attr"];
        if (self.express) {
            [launch setObject:self.express forKey:@"express"];
        }
        [setting setObject:launch forKey:@"launch"];
        [setting setObject:action_list forKey:@"action_list"];
    }
    
    if (authed.count)[dictionary setObject:authed forKey:@"authed"];
    [dictionary setObject:setting forKey:@"setting"];

    return dictionary;
}

#pragma mark - encoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.uid forKey:@"uid"];
    [aCoder encodeObject:self.usId forKey:@"usId"];
    [aCoder encodeObject:self.std_id forKey:@"std_id"];
    [aCoder encodeObject:self.identify forKey:@"identify"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.actionList forKey:@"actionList"];
    [aCoder encodeObject:self.launchList forKey:@"launchList"];
    [aCoder encodeObject:@(self.enable) forKey:@"enable"];
    [aCoder encodeObject:self.express forKey:@"express"];

    [aCoder encodeObject:self.authed forKey:@"authed"];
    [aCoder encodeObject:self.setting forKey:@"setting"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.uid = [aDecoder decodeObjectForKey:@"uid"];
        self.usId = [aDecoder decodeObjectForKey:@"usId"];
        self.std_id = [aDecoder decodeObjectForKey:@"std_id"];
        self.identify = [aDecoder decodeObjectForKey:@"identify"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.actionList = [aDecoder decodeObjectForKey:@"actionList"];
        self.launchList = [aDecoder decodeObjectForKey:@"launchList"];
        self.enable = [[aDecoder decodeObjectForKey:@"enable"] boolValue];
        self.express = [aDecoder decodeObjectForKey:@"express"];
        self.authed = [aDecoder decodeObjectForKey:@"authed"];
        self.setting = [aDecoder decodeObjectForKey:@"setting"];
    }
    return self;
}

@end
