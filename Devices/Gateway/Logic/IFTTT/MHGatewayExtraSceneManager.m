//
//  MHGatewayExtraSceneManager.m
//  MiHome
//
//  Created by Lynn on 1/25/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayExtraSceneManager.h"
#import "MHGatewayThirdDataRequest.h"
#import "MHGatewayThirdDataResponse.h"

static NSArray *activeEventArray = nil;

@implementation MHGatewayExtraSceneManager

+ (id)sharedInstance {
    activeEventArray = @[
                         @"^event\\.(\\S+)\\.click$",
                         @"^event\\.(\\S+)\\.double_click$",
                         @"^event\\.(\\S+)\\.long_click_press$",
                         @"^event\\.(\\S+)\\.neutral_0_click$",
                         @"^event\\.(\\S+)\\.neutral_1_click$",
                         @"^lumi\\.(\\S*)acpartner(\\S*)\\.set_on$",
                         @"^lumi\\.(\\S*)acpartner(\\S*)\\.set_off$",
                         @"^lumi\\.(\\S*)acpartner(\\S*)\\.toggle_ac$",
                         @"^lumi\\.(\\S*)acpartner(\\S*)\\.set_ac$",
                         @"^lumi\\.(\\S*)camera(\\S*)\\.set_video$",
//                         @"^lumi\\.(\\S*)camera(\\S*)\\.video_close$",
                         @"^lumi\\.(\\S*)camera(\\S*)\\.record_video$",
                         ];
    static MHGatewayExtraSceneManager *obj = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        obj = [[MHGatewayExtraSceneManager alloc] init];
    });
    return obj;
}

- (void)fetchExtraMapTableWithSuccess:(SucceedBlock)success failure:(FailedBlock)failure {
    MHGatewayThirdDataRequest *req = [[MHGatewayThirdDataRequest alloc] init];
//    req.keyString = @"lumi_key_extra_mapping_info";
    req.keyString = @"lumi_key_extra_mapping_info_develop";

    XM_WS(weakself);
    [[MHNetworkEngine sharedInstance] sendRequest:req success:^(id json) {
        MHGatewayThirdDataResponse *rsp = [MHGatewayThirdDataResponse responseWithJSONObject:json];
        [weakself saveMapInfoList:rsp.valueList];
        NSLog(@"extra所有的内容%@", rsp.valueList);
        if(success)success(rsp.valueList);
        
    } failure:^(NSError *error) {
        if(failure)failure(error);
    }];
}

- (void)mapExtraInfoWithScene:(NSDictionary *)scene andSuccess:(SucceedBlock)success {

    __block NSDictionary *oldScene = [scene mutableCopy];
    
    XM_WS(weakself);
    void (^ fetchAllMapInfo)(NSDictionary *mapInfo) = ^(NSDictionary *allMapInfo) {
        NSMutableDictionary *mutableScene = [scene mutableCopy];
        NSMutableDictionary *mutableSetting = [mutableScene valueForKey:@"setting"];
        NSMutableDictionary *mutableLaunch = [[mutableScene valueForKey:@"setting"] valueForKey:@"launch"];
        
        //根据自动化数据分析
        NSDictionary *commands = [weakself fetchSceneCommandList:scene];
        BOOL activeFlag = [weakself activeFlagJudge:commands.allKeys];
        
        //处理action
        NSMutableArray *actionList = [[scene valueForKey:@"setting"] valueForKey:@"action_list"];
        NSMutableArray *newActionList = [actionList mutableCopy];
        [actionList enumerateObjectsUsingBlock:^(NSDictionary *oldAction, NSUInteger idx, BOOL *stop) {
            
            NSMutableDictionary *newAction = [oldAction mutableCopy];
            if (newAction[@"model"] == nil || [newAction[@"model"] rangeOfString:@"lumi"].location == NSNotFound)  { //非lumi设备，不设置extra
                return;
            }
            NSMutableDictionary *payload = [oldAction valueForKey:@"payload"];
            if(payload){
                NSString *keyname = [payload valueForKey:@"command"];
                NSString *value = [payload valueForKey:@"value"];
                NSString *extra = [weakself fetchExtraInfo:keyname value:value activeFlag:activeFlag mapInfo:allMapInfo withOldScene:oldScene];
                if (extra) {
                    [payload setObject:extra forKey:@"extra"];
                }
                [newAction setObject:payload forKey:@"payload"];
                //                [newActionList removeObject:oldAction];
                //                [newActionList addObject:newAction];
                [newActionList replaceObjectAtIndex:[newActionList indexOfObject:oldAction] withObject:newAction];
            }
        }];
        [mutableSetting setObject:newActionList forKey:@"action_list"];
        
        //处理launch
        NSMutableArray *launchList = [NSMutableArray arrayWithCapacity:1];
        NSMutableArray *newLaunchList = [NSMutableArray arrayWithCapacity:1];;
        if ([[[scene valueForKey:@"setting"] valueForKey:@"launch"] isKindOfClass:[NSDictionary class]]) {
            launchList = [[[scene valueForKey:@"setting"] valueForKey:@"launch"] valueForKey:@"attr"];
            newLaunchList = [launchList mutableCopy];
        }
        [launchList enumerateObjectsUsingBlock:^(NSDictionary *oldLaunch, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *newLaunch = [oldLaunch mutableCopy];
            
            NSString *keyname = [oldLaunch valueForKey:@"key"];
            NSString *value = [oldLaunch valueForKey:@"value"];
            NSString *extra = [weakself fetchExtraInfo:keyname value:value activeFlag:activeFlag mapInfo:allMapInfo withOldScene:oldScene];
            [newLaunch setObject:extra forKey:@"extra"];
            
            [newLaunchList removeObject:oldLaunch];
            [newLaunchList addObject:newLaunch];
        }];
        [mutableLaunch setObject:newLaunchList forKey:@"attr"];
        [mutableSetting setObject:mutableLaunch forKey:@"launch"];
        
        [mutableScene setObject:mutableSetting forKey:@"setting"];
        
        if (success)success(mutableScene);
    };
    
    [self restoreMapInfoListWithSuccess:^(id obj) {
        fetchAllMapInfo(obj);
    }];
}

- (NSString *)fetchExtraInfo:(NSString *)keyName
                       value:(id)value
                  activeFlag:(BOOL)activeFlag
                     mapInfo:(NSDictionary *)mapInfo
                withOldScene:(NSDictionary *)oldScene {
    if (keyName == nil) {
        return nil;
    }
    __block NSArray *mapedInfo = [NSArray array];
    NSArray *allRegulars = [mapInfo allKeys];
    [allRegulars enumerateObjectsUsingBlock:^(NSString *regular, NSUInteger idx, BOOL *stop2) {
        
        NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:regular
                                                                                      options:NSRegularExpressionCaseInsensitive
                                                                                        error:nil];
        NSArray *results = [regularExpression matchesInString:keyName options:0 range:NSMakeRange(0, keyName.length)];
        if(results.count){
            mapedInfo = [mapInfo valueForKey:regular];
            * stop2 = YES;
        }
        NSLog(@"结果%@", results);
    }];
    
    NSArray *extraArray = [NSArray array];
    if(mapedInfo) {
        NSDictionary *extraDic = [mapedInfo firstObject];
        NSDictionary *lastObj = [mapedInfo lastObject];
        
        NSString *valueJudge = [lastObj.allValues firstObject];
        if (![valueJudge isEqualToString:@"default"]){

            __block NSString *key = @"";
            if ([value isKindOfClass:[NSArray class]]) {
                NSString *newValue = [value componentsJoinedByString:@","];
                newValue = [NSString stringWithFormat:@"[%@]",newValue];
                
                [lastObj.allKeys enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
                    NSString *newObj = [obj stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    if([newObj isEqualToString:newValue]) {
                        key = [lastObj valueForKey:obj];
                        *stop = YES;
                    }
                }];
            }
            else {
                key = [lastObj valueForKey:value];
            }

            if(!activeFlag && [[extraDic valueForKey:key] valueForKey:@"nonActive"]){
                extraArray = [[extraDic valueForKey:key] valueForKey:@"nonActive"];
            }
            else {
                extraArray = [[extraDic valueForKey:key] valueForKey:@"active"];
            }
        }
        else{
            if(!activeFlag && [[extraDic valueForKey:@"default"] valueForKey:@"nonActive"]){
                extraArray = [[extraDic valueForKey:@"default"] valueForKey:@"nonActive"];
            }
            else {
                extraArray = [[extraDic valueForKey:@"default"] valueForKey:@"active"];
            }
        }
    }
    
    NSMutableArray *mutableExtraArray = [extraArray mutableCopy];
    for (int i = 0 ; i < extraArray.count; i ++) {
        if ([extraArray[i] isKindOfClass:[NSArray class]]){
            NSString *objextra = [extraArray[i] componentsJoinedByString:@","];
            objextra = [NSString stringWithFormat:@"[%@]",objextra];
            [mutableExtraArray replaceObjectAtIndex:i withObject:objextra];
        }
    }
    NSLog(@"extra数组%@", mutableExtraArray);
    NSString *extra = [mutableExtraArray componentsJoinedByString:@","];
    extra = [NSString stringWithFormat:@"[%@]",extra];
    extra = [self replaceXInExtra:extra withKey:keyName value:value withOldScene:oldScene];
    return extra;
}

- (NSString *)replaceXInExtra:(NSString *)extra withKey:(NSString *)key value:(id)value withOldScene:(NSDictionary *)oldScene {
    NSString *replaceExtra = extra;
    NSLog(@"%@", replaceExtra);
    
    //1 door_bell
    {
        NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^lumi\\.(\\S+)\\.door_bell$" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *results = [regularExpression matchesInString:key options:0 range:NSMakeRange(0, key.length)];
        if(results.count){
            replaceExtra = [extra stringByReplacingOccurrencesOfString:@"x" withString:[value stringValue]];
            return replaceExtra;
        }
    }
    
    //2 motion
    {
        NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^event\\.(\\S+)\\.no_motion$" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *results = [regularExpression matchesInString:key options:0 range:NSMakeRange(0, key.length)];
        if(results.count){
            if ([value isKindOfClass:[NSNumber class]]){
               NSNumber *numValue = (NSNumber *) value;
                numValue = [NSNumber numberWithInteger:numValue.integerValue - 60];
                value = numValue;
            }
            replaceExtra = [extra stringByReplacingOccurrencesOfString:@"x" withString:[value stringValue]];
            return replaceExtra;
        }
    }

    //3 play_music
    {
        NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^lumi\\.(\\S+)\\.play_music_new$" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *results = [regularExpression matchesInString:key options:0 range:NSMakeRange(0, key.length)];
        if(results.count){
            if ([value isKindOfClass:[NSArray class]] && [value count] >= 2) {
//                value = [self arrayToJson:value];
                value = [NSString stringWithFormat:@"[%ld,%ld]", [value[0] integerValue], [value[1] integerValue]];
            }
            value = [value stringByReplacingOccurrencesOfString:@"[" withString:@""];
            value = [value stringByReplacingOccurrencesOfString:@"]" withString:@""];
            NSRange range = [value rangeOfString:@","];
            [value insertString:@"0," atIndex:range.location + range.length];
            replaceExtra = [extra stringByReplacingOccurrencesOfString:@"x" withString:[value stringValue]];
            return replaceExtra;
        }
    }
    
    //4 play_fm
    {
        NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^lumi\\.(\\S+)\\.play_specify_fm$" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *results = [regularExpression matchesInString:key options:0 range:NSMakeRange(0, key.length)];
        if(results.count){
            if ([value isKindOfClass:[NSArray class]] && [value count] >= 2) {
                value = [NSString stringWithFormat:@"[%ld,%ld]", [value[0] integerValue], [value[1] integerValue]];
            }
            value = [value stringByReplacingOccurrencesOfString:@"[" withString:@""];
            value = [value stringByReplacingOccurrencesOfString:@"]" withString:@""];
            NSRange range = [value rangeOfString:@","];
            [value insertString:@"0," atIndex:range.location + range.length];
            replaceExtra = [extra stringByReplacingOccurrencesOfString:@"x" withString:[value stringValue]];
            return replaceExtra;
        }
    }

    //5 temperature
    {
        NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^prop\\.(\\S+)\\.temperature$" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *results = [regularExpression matchesInString:key options:0 range:NSMakeRange(0, key.length)];
        if(results.count){
            if ([[value valueForKey:@"max"] intValue] == 6000) {
                replaceExtra = [NSString stringWithFormat:@"[2,%d]",[[value valueForKey:@"min"] intValue] ];
            }
            else if([[value valueForKey:@"min"] intValue] == -2000 ) {
                replaceExtra = [NSString stringWithFormat:@"[3,%d]", [[value valueForKey:@"max"] intValue] ];
            }
            replaceExtra = [extra stringByReplacingOccurrencesOfString:@"x" withString:replaceExtra];
            return replaceExtra;
        }
    }
    
    //6 humidity
    {
        NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^prop\\.(\\S+)\\.humidity$" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *results = [regularExpression matchesInString:key options:0 range:NSMakeRange(0, key.length)];
        if(results.count){
            if ([[value valueForKey:@"max"] intValue] == 10000) {
                replaceExtra = [NSString stringWithFormat:@"[2,%d]",[[value valueForKey:@"min"] intValue] ];
            }
            else if([[value valueForKey:@"min"] intValue] == 0) {
                replaceExtra = [NSString stringWithFormat:@"[3,%d]", [[value valueForKey:@"max"] intValue] ];
            }
            replaceExtra = [extra stringByReplacingOccurrencesOfString:@"x" withString:replaceExtra];
            return replaceExtra;
        }
    }

    //7 adjust_fm_vol
    {
        NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^lumi\\.(\\S+)\\.adjust_fm_vol$" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *results = [regularExpression matchesInString:key options:0 range:NSMakeRange(0, key.length)];
        if(results.count){
            NSDictionary *launch = [self ifSceneLaunchHasCubeRotate:oldScene];
            
            if(launch){
                NSString *did = [self cubeRotateExtraReplaceValue:launch];
                NSString *newValue = [NSString stringWithFormat:@"[%@,12,3,85,0]",did];
                replaceExtra = [extra stringByReplacingOccurrencesOfString:@"x" withString:newValue];
            }
            else {
                replaceExtra = [extra stringByReplacingOccurrencesOfString:@"x" withString:[value stringValue]];
            }
            return replaceExtra;
        }
    }
    
    //8 adjust_bright
    {
        NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^lumi\\.(\\S+)\\.adjust_bright$" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *results = [regularExpression matchesInString:key options:0 range:NSMakeRange(0, key.length)];
        if(results.count){
            NSDictionary *launch = [self ifSceneLaunchHasCubeRotate:oldScene];
            
            if(launch){
                NSString *did = [self cubeRotateExtraReplaceValue:launch];
                NSString *newValue = [NSString stringWithFormat:@"[%@,12,3,85,0]",did];
                replaceExtra = [extra stringByReplacingOccurrencesOfString:@"x" withString:newValue];
            }
            else {
                replaceExtra = [extra stringByReplacingOccurrencesOfString:@"x" withString:[value stringValue]];
            }
            return replaceExtra;
        }
    }
    
    //9 开空调
    {
        NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^lumi\\.(\\S*)acpartner(\\S*)\\.set_on$" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *results = [regularExpression matchesInString:key options:0 range:NSMakeRange(0, key.length)];
        if(results.count){
            replaceExtra = [extra stringByReplacingOccurrencesOfString:@"x" withString:[value stringValue]];
            return replaceExtra;
        }
    }
    //10 关空调
    {
        NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^lumi\\.(\\S*)acpartner(\\S*)\\.set_off$" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *results = [regularExpression matchesInString:key options:0 range:NSMakeRange(0, key.length)];
        if(results.count){
            replaceExtra = [extra stringByReplacingOccurrencesOfString:@"x" withString:[value stringValue]];
            return replaceExtra;
        }
    }
    
    //11 toggle空调
    {
        NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^lumi\\.(\\S*)acpartner(\\S*)\\.toggle_ac$" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *results = [regularExpression matchesInString:key options:0 range:NSMakeRange(0, key.length)];
        if(results.count){
            replaceExtra = [extra stringByReplacingOccurrencesOfString:@"x" withString:[value stringValue]];
            return replaceExtra;
        }
    }
    
    //12 set_ac
    {
        NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^lumi\\.(\\S*)acpartner(\\S*)\\.set_ac$" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *results = [regularExpression matchesInString:key options:0 range:NSMakeRange(0, key.length)];
        if(results.count){
//            value = [NSString stringWithFormat:@"%ld", [value integerValue]];
            replaceExtra = [extra stringByReplacingOccurrencesOfString:@"x" withString:[value stringValue]];
            return replaceExtra;
        }
    }
    
    //13viedeo_open
    {
        NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^lumi\\.(\\S*)camera(\\S*)\\.set_video$" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *results = [regularExpression matchesInString:key options:0 range:NSMakeRange(0, key.length)];
        if(results.count){
            NSString *valueString = [[value stringValue] isEqualToString:@"on"] ? @"1" : @"0";
            //            value = [NSString stringWithFormat:@"%ld", [value integerValue]];
            replaceExtra = [extra stringByReplacingOccurrencesOfString:@"x" withString:valueString];
            return replaceExtra;
        }
    }
    

    //14viedeo_close
    {
        NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^lumi\\.(\\S*)camera(\\S*)\\.video_close$" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *results = [regularExpression matchesInString:key options:0 range:NSMakeRange(0, key.length)];
        if(results.count){
            NSString *valueString = [[value stringValue] isEqualToString:@"on"] ? @"1" : @"0";
            //            value = [NSString stringWithFormat:@"%ld", [value integerValue]];
            replaceExtra = [extra stringByReplacingOccurrencesOfString:@"x" withString:valueString];
            return replaceExtra;
        }
    }
    
    
    //15viedeo_record
//    {
//        NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^lumi\\.(\\S*)camera(\\S*)\\.record_video$" options:NSRegularExpressionCaseInsensitive error:nil];
//        NSArray *results = [regularExpression matchesInString:key options:0 range:NSMakeRange(0, key.length)];
//        if(results.count){
//            //            value = [NSString stringWithFormat:@"%ld", [value integerValue]];
//            replaceExtra = [extra stringByReplacingOccurrencesOfString:@"x" withString:[value stringValue]];
//            return replaceExtra;
//        }
//    }

    return replaceExtra;
}

- (NSDictionary *)ifSceneLaunchHasCubeRotate:(NSDictionary *)scene {
    NSArray *launchList = nil;
    if ([[[scene valueForKey:@"setting"] valueForKey:@"launch"] isKindOfClass:[NSDictionary class]]) {
        launchList = [[[scene valueForKey:@"setting"] valueForKey:@"launch"] valueForKey:@"attr"];
    }
    
    for(NSDictionary *launch in launchList){
        NSString *key = [launch valueForKey:@"key"];
        NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^event\\.(\\S+)\\.rotate$" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *results = [regularExpression matchesInString:key options:0 range:NSMakeRange(0, key.length)];
        if(results.count){
            return launch;
        }
    }
    return nil;
}

- (NSString *)cubeRotateExtraReplaceValue:(NSDictionary *)launchObj {
    NSString *did = [launchObj valueForKey:@"did"];
    NSArray *dids = [did componentsSeparatedByString:@"."];
    if(dids.count > 1){
        unsigned long long result = 0;
        NSScanner *scanner = [NSScanner scannerWithString:dids[1]];
        [scanner scanHexLongLong:&result];
        return [@(result) stringValue];
    }
    else{
        NSLog(@"error : 怎么可以不是这个规则！lumi.158d0000fa735a");
        return @"20";
    }
}

- (NSDictionary *)fetchSceneCommandList:(NSDictionary *)scene {
    NSMutableDictionary *sceneKeyValueGroup = [NSMutableDictionary dictionaryWithCapacity:1];

    NSArray *actionList = [[scene valueForKey:@"setting"] valueForKey:@"action_list"];
    [actionList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([[obj valueForKey:@"payload"] isKindOfClass:[NSDictionary class]]){
            if ([[obj valueForKey:@"payload"] valueForKey:@"command"]) {
                id tempValue = [[obj valueForKey:@"payload"] valueForKey:@"value"];
               [sceneKeyValueGroup setObject:tempValue ? tempValue : @"" forKey:[[obj valueForKey:@"payload"] valueForKey:@"command"]];
            }
            else {
                return;
            }
        }
    }];

    if ([[[scene valueForKey:@"setting"] valueForKey:@"launch"] isKindOfClass:[NSDictionary class]]) {
        NSArray *launchList = [[[scene valueForKey:@"setting"] valueForKey:@"launch"] valueForKey:@"attr"];
        [launchList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
            if([obj valueForKey:@"value"] && [obj valueForKey:@"key"]){
                [sceneKeyValueGroup setObject:[obj valueForKey:@"value"] forKey:[obj valueForKey:@"key"]];
            }
        }];
    }
    return [sceneKeyValueGroup mutableCopy];
}

- (BOOL)activeFlagJudge:(NSArray *)events {
    __block BOOL activeFlag = NO;
    
    [activeEventArray enumerateObjectsUsingBlock:^(NSString *regular, NSUInteger idx, BOOL *stop1) {
        
        [events enumerateObjectsUsingBlock:^(NSString *checkString, NSUInteger idx, BOOL *stop2) {
            
            NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:regular options:NSRegularExpressionCaseInsensitive error:nil];
            NSArray *results = [regularExpression matchesInString:checkString options:0 range:NSMakeRange(0, checkString.length)];
            if (results.count) {
                activeFlag = YES;
                *stop2 = YES;
                *stop1 = YES;
            }
        }];
    }];
    return activeFlag;
}
#pragma mark - 延时自动化ActionList处理
- (NSArray *)extraInfoForDelayAction:(NSArray *)delayActions {
    //修改每个action对应extra，actionList的顺序很重要，不要改变
    //type == 2 为延时action，里面有 key = "delayTime" 为延时时间，其控制范围为其后的 type == 0 的action。
    //extra的倒数第二位改为6，最后一位改为delaytime，单位为秒（S）
    //extra的当前格式 [1,19,4,111,[56,1],0,0]
    NSInteger delayTime = 0;
    for (MHSafeDictionary *actionDic in delayActions) {
        if ([actionDic[@"type"] integerValue] == 2) {
            delayTime += [actionDic[@"delayTime"] integerValue];
        }
        else {
            MHSafeDictionary *payload = actionDic[@"payload"];
            NSLog(@"%@", payload[@"extra"]);
            NSString *codeString = payload[@"extra"];
            NSData *codeData = [[NSData alloc] initWithData:[codeString dataUsingEncoding:NSUTF8StringEncoding]];
            NSArray *extraArray = [NSJSONSerialization JSONObjectWithData:codeData options:NSJSONReadingMutableLeaves error:nil];
            NSMutableArray *tempArray = [NSMutableArray arrayWithArray:extraArray];
            NSLog(@"%@", tempArray);
            if (tempArray.count >= 2) {
                [tempArray replaceObjectAtIndex:(extraArray.count - 2) withObject:@(6)];
                [tempArray replaceObjectAtIndex:(extraArray.count - 1) withObject:@(delayTime)];
            }
            NSString *newStr = [self arrayToJson:tempArray];
            [actionDic[@"payload"] setObject:newStr forKey:@"extra"];
            NSLog(@"改变之后的payload%@", actionDic[@"payload"][@"extra"]);
        }
    }
    NSLog(@"旧的actonlist%@", delayActions);
    return delayActions;
}

#pragma mark - 延时自动化Action处理
- (void)extraInfoForDelayAction:(MHDataIFTTTAction *)delayAction withAbsoluteDelaytime:(NSUInteger)adt  {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:delayAction.payload];
    NSLog(@"%@", delayAction.payload[@"extra"]);
    NSString *codeString = delayAction.payload[@"extra"];
    NSData *codeData = [[NSData alloc] initWithData:[codeString dataUsingEncoding:NSUTF8StringEncoding]];
    NSArray *extraArray = [NSJSONSerialization JSONObjectWithData:codeData options:NSJSONReadingMutableLeaves error:nil];
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:extraArray];
    NSLog(@"%@", tempArray);
    if (tempArray.count >= 2) {
        [tempArray replaceObjectAtIndex:(extraArray.count - 2) withObject:@(6)];
        [tempArray replaceObjectAtIndex:(extraArray.count - 1) withObject:@(adt)];
    }
    NSString *newExtra = [self arrayToJson:tempArray];
    [dic setObject:newExtra forKey:@"extra"];
    delayAction.payload = dic;
    NSLog(@"改变之后的extra%@", delayAction.payload);
}


- (NSString*)arrayToJson:(NSArray *)array {
    
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NULL error:&parseError];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonStr;
    
}


#pragma mark - 缓存
- (void)saveMapInfoList:(id)infoList {
    [[MHPlistCacheEngine sharedEngine] asyncSave:infoList
                                          toFile:@"lumi_gateway_bindlist"
                                      withFinish:nil];
}

- (void)restoreMapInfoListWithSuccess:(SucceedBlock)success {
    [[MHPlistCacheEngine sharedEngine] asyncLoadFromFile:@"lumi_gateway_bindlist"
                                              withFinish:^(id obj) {
                                                  if (success) success(obj);
                                              }];
}

@end
