//
//  MHDataAction.m
//  MiHome
//
//  Created by Lynn on 9/9/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHDataAction.h"
#import "MHDeviceListCache.h"
#import <MiHomeKit/MiHomeKit.h>

@implementation MHDataAction

+ (instancetype)dataWithJSONObject:(id)object
{
    MHDataAction* action = [[self alloc] init];

    if(self){
        if([object isKindOfClass:[NSDictionary class]]){
            action.name = [object valueForKey:@"keyName"] ? [object valueForKey:@"keyName"] : @"";
            action.deviceModel = [object valueForKey:@"model"]  ? [object valueForKey:@"model"] : @"";
            action.deviceName = [object valueForKey:@"name"]  ? [object valueForKey:@"name"] : @"";
            action.type = [object valueForKey:@"type"]  ? [object valueForKey:@"type"] : @"";
            
            action.command = [[object valueForKey:@"payload"] valueForKey:@"command"];
            action.deviceDid = [[object valueForKey:@"payload"] valueForKey:@"did"];
            action.total_length = [[object valueForKey:@"payload"] valueForKey:@"total_length"];
            action.value = [[object valueForKey:@"payload"] valueForKey:@"value"];
            action.extra = [[object valueForKey:@"payload"] valueForKey:@"extra"];
            
            action.plug_id = [[object valueForKey:@"payload"] valueForKey:@"plug_id"];
        }
    }
    return action;
}

- (instancetype)initWithRecomObject:(id)object
{
    if(self){
        self.name = [object valueForKey:@"keyName"] ? [object valueForKey:@"keyName"] : @"";
        self.deviceModel = [object valueForKey:@"model"]  ? [object valueForKey:@"model"] : @"";
        self.deviceName = [object valueForKey:@"name"]  ? [object valueForKey:@"name"] : @"";
        self.type = [object valueForKey:@"type"]  ? [object valueForKey:@"type"] : @"";
        
        self.command = [[object valueForKey:@"payload"] valueForKey:@"command"];
        self.deviceDid = [[object valueForKey:@"payload"] valueForKey:@"did"];
        self.total_length = [[object valueForKey:@"payload"] valueForKey:@"total_length"];
        self.value = [[object valueForKey:@"payload"] valueForKey:@"value"];
        self.extra = [[object valueForKey:@"payload"] valueForKey:@"extra"];
        
        self.plug_id = [[object valueForKey:@"payload"] valueForKey:@"plug_id"];
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    MHDataAction *action = (MHDataAction *)object;
    
    if(![object isKindOfClass:[self class]]){
        return NO;
    }
    
    return ([action.name isEqualToString:self.name] &&
            [action.deviceModel isEqualToString:self.deviceModel] &&
            [action.deviceName isEqualToString:self.deviceName] &&
            [action.command isEqualToString:self.command] &&
            [action.type isEqual:self.type] &&
            [action.value isEqual:self.value] &&
            [action.deviceDid isEqual:self.deviceDid]);
}

+ (NSDictionary *)actionToDictionary:(MHDataAction *)action
{
    NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithCapacity:1];
    [payload setObject:action.value ? action.value : @"" forKey:@"value"];
    [payload setObject:action.deviceDid ? action.deviceDid : @"" forKey:@"did"];
    [payload setObject:action.command ? action.command : @"" forKey:@"command"];
    [payload setObject:@(0) forKey:@"total_length"];
    [payload setObject:action.type ? action.type : @"0" forKey:@"type"];
    if(action.extra && action.extra.length) [payload setObject:action.extra forKey:@"extra"];
    if(action.plug_id)[payload setObject:action.plug_id forKey:@"plug_id"];

    NSMutableDictionary *actionDictionary = [NSMutableDictionary dictionaryWithCapacity:1];
    [actionDictionary setObject:payload forKey:@"payload"];
    [actionDictionary setObject:action.deviceModel ? action.deviceModel : @"" forKey:@"model"];
    [actionDictionary setObject:action.deviceName ? action.deviceName : @"" forKey:@"name"];
    [actionDictionary setObject:action.name ? action.name : @"" forKey:@"keyName"];
    
    return actionDictionary;
}

+ (MHDataAction *)reBuildActionData:(NSMutableArray *)actionList withDeviceId:(NSString *)did
{
    for (id action in actionList){
        if([[action valueForKey:@"device_did"] isEqualToString:did]){
            for(id obj in [action valueForKey:@"action_list"]){
                NSMutableDictionary *selectedObject = [NSMutableDictionary dictionaryWithCapacity:1];
                
                NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithCapacity:1];
                [payload setObject:[[obj valueForKey:@"payload"] valueForKey:@"command"] forKey:@"command"];
                [payload setObject:[[obj valueForKey:@"payload"] valueForKey:@"value"] forKey:@"value"];
                [payload setObject:[action valueForKey:@"device_did"] forKey:@"did"];
                if ([action valueForKey:@"plug_id"])[payload setObject:[action valueForKey:@"plug_id"] forKey:@"plug_id"];
                
                [selectedObject setObject:payload forKey:@"payload"];
                
                [selectedObject setObject:[action valueForKey:@"device_name"] forKey:@"name"];
                [selectedObject setObject:[obj valueForKey:@"model"] forKey:@"model"];
                [selectedObject setObject:[obj valueForKey:@"keyName"] forKey:@"keyName"];
                
                MHDataAction *newActionObj = [MHDataAction dataWithJSONObject:selectedObject];
                
                return newActionObj;
            }
        }
    }
    return nil;
}

#pragma mark - encoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.deviceModel forKey:@"deviceModel"];
    [aCoder encodeObject:self.deviceName forKey:@"deviceName"];
    [aCoder encodeObject:self.type forKey:@"type"];
    
    [aCoder encodeObject:self.command forKey:@"command"];
    [aCoder encodeObject:self.deviceDid forKey:@"deviceDid"];
    [aCoder encodeObject:self.total_length forKey:@"total_length"];
    [aCoder encodeObject:self.value forKey:@"value"];
    [aCoder encodeObject:self.extra forKey:@"extra"];
    [aCoder encodeObject:self.plug_id forKey:@"plug_id"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.deviceModel = [aDecoder decodeObjectForKey:@"deviceModel"];
        self.deviceName = [aDecoder decodeObjectForKey:@"deviceName"];
        self.type = [aDecoder decodeObjectForKey:@"type"];
        
        self.deviceDid = [aDecoder decodeObjectForKey:@"deviceDid"];
        self.total_length = [aDecoder decodeObjectForKey:@"total_length"];
        self.value = [aDecoder decodeObjectForKey:@"value"];
        self.command = [aDecoder decodeObjectForKey:@"command"];
        self.extra = [aDecoder decodeObjectForKey:@"extra"];
        self.plug_id = [aDecoder decodeObjectForKey:@"plug_id"];
    }
    return self;
}

@end
