//
//  MHDataGatewaySceneLogMessage.m
//  MiHome
//
//  Created by guhao on 16/5/17.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHDataGatewaySceneLogMessage.h"

@implementation MHDataGatewaySceneLogMessage

+ (instancetype)dataWithJSONObject:(id)object {
    MHDataGatewaySceneLogMessage* message = [super dataWithJSONObject:object];
    if (message) {
        message.devConState = [[object objectForKey:@"dev_con_state" class:[NSNumber class]] boolValue];
        message.error = [[object objectForKey:@"error" class:[NSNumber class]] integerValue];
        message.methodDesc = [object objectForKey:@"methodDesc" class:[NSString class]];
        message.targetDesc = [object objectForKey:@"targetDesc" class:[NSString class]];
        message.target = [object objectForKey:@"target" class:[NSString class]];
        message.note = [object objectForKey:@"note" class:[NSString class]];
        message.t = [[object objectForKey:@"t" class:[NSNumber class]] integerValue];
    }
    return message;
}

#pragma mark - 支持序列化存储
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.devConState) forKey:@"devConState"];
    [aCoder encodeObject:self.methodDesc forKey:@"methodDesc"];
    [aCoder encodeObject:self.targetDesc forKey:@"targetDesc"];
    [aCoder encodeObject:self.target forKey:@"target"];
    [aCoder encodeObject:self.note forKey:@"note"];
    [aCoder encodeObject:@(self.error) forKey:@"error"];
    [aCoder encodeObject:@(self.t) forKey:@"t"];
    
  
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.devConState = [[aDecoder decodeObjectForKey:@"devConState"] boolValue];
        self.methodDesc = [aDecoder decodeObjectForKey:@"methodDesc"];
        self.targetDesc = [aDecoder decodeObjectForKey:@"targetDesc"];
        self.target = [aDecoder decodeObjectForKey:@"target"];
        self.note = [aDecoder decodeObjectForKey:@"note"];
        self.error = [[aDecoder decodeObjectForKey:@"error"] integerValue];
        self.t = [[aDecoder decodeObjectForKey:@"t"] integerValue];
       
    }
    return self;
}

- (NSString* )errorDetail {
    switch (self.error) {
        case 0:
            return NSLocalizedStringFromTable(@"ifttt.scene.execute.result.succeed", @"plugin_gateway", "执行成功");
        case -2:
            return NSLocalizedStringFromTable(@"ifttt.scene.execute.result.offline", @"plugin_gateway", "执设备离线");
        case -3:
            return NSLocalizedStringFromTable(@"ifttt.scene.execute.result.timeout", @"plugin_gateway", "执行超时");
        default:
            return NSLocalizedStringFromTable(@"ifttt.scene.execute.result.others", @"plugin_gateway", "异常错误");
    }
}

@end
