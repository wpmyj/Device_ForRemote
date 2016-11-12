//
//  MHDataGatewaySceneLog.m
//  MiHome
//
//  Created by guhao on 16/5/16.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHDataGatewaySceneLog.h"
#import "MHDataGatewaySceneLogMessage.h"

@implementation MHDataGatewaySceneLog

+ (instancetype)dataWithJSONObject:(id)object {
    MHDataGatewaySceneLog* history = [super dataWithJSONObject:object];
    if (history) {
        history.recordId = [[object objectForKey:@"userSceneId"] stringValue];
        history.recordName = [object objectForKey:@"name" class:[NSString class]];
        history.recordType = [object objectForKey:@"from" class:[NSString class]];
        history.recordIdentifier = [object objectForKey:@"identify" class:[NSString class]];
        history.executeTime = [[object objectForKey:@"time" class:[NSNumber class]] doubleValue];
        NSArray* msgs = [object objectForKey:@"msg" class:[NSArray class]];
        if ([msgs count]) {
            history.messages = [MHDataGatewaySceneLogMessage dataListWithJSONObjectList:msgs];
        }
    }
    return history;
}

#pragma mark - 支持序列化存储
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.recordId forKey:@"recordId"];
    [aCoder encodeObject:self.recordName forKey:@"recordName"];
    [aCoder encodeObject:self.recordType forKey:@"recordType"];
    [aCoder encodeObject:self.recordIdentifier forKey:@"recordIdentifier"];
    [aCoder encodeObject:@(self.executeTime) forKey:@"executeTime"];
    [aCoder encodeObject:self.messages forKey:@"messages"];

    [aCoder encodeBool:self.hasPrev forKey:@"hasPrev"];
    [aCoder encodeBool:self.hasNext forKey:@"hasNext"];
    [aCoder encodeBool:self.isFirst forKey:@"isFirst"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.recordId = [aDecoder decodeObjectForKey:@"recordId"];
        self.recordName = [aDecoder decodeObjectForKey:@"recordName"];
        self.recordType = [aDecoder decodeObjectForKey:@"recordType"];
        self.recordIdentifier = [aDecoder decodeObjectForKey:@"recordIdentifier"];
        self.executeTime = [[aDecoder decodeObjectForKey:@"executeTime"] longLongValue];
        self.messages = [aDecoder decodeObjectForKey:@"messages"];

        self.hasPrev = [aDecoder decodeBoolForKey:@"hasPrev"];
        self.hasNext = [aDecoder decodeBoolForKey:@"hasNext"];
        self.isFirst = [aDecoder decodeBoolForKey:@"isFirst"];
    }
    return self;
}

- (UIImage *)historyIcon {
    UIImage* historyIcon = nil;
    if ([self.recordType isEqualToString:@"click"]) {
        historyIcon = [UIImage imageNamed:@"ift_record_clicktolaunch"];
    } else if ([self.recordType isEqualToString:@"timeout"]) {
        historyIcon = [UIImage imageNamed:@"ift_record_timer"];
    } else if ([self.recordType isEqualToString:@"event"]) {
        historyIcon = [UIImage imageNamed:@"ift_record_event"];
    }
    return historyIcon;
}

- (BOOL)isSucceedExecuted {
    __block BOOL isSucceed = YES;
    [self.messages enumerateObjectsUsingBlock:^(MHDataGatewaySceneLogMessage* message, NSUInteger idx, BOOL * _Nonnull stop) {
        if (message.error != 0) {
            isSucceed = NO;
            *stop = YES;
        }
    }];
    return isSucceed;
}

- (BOOL)isShowFaiedDetails {
    __block BOOL isShow = NO;
    [self.messages enumerateObjectsUsingBlock:^(MHDataGatewaySceneLogMessage* message, NSUInteger idx, BOOL * _Nonnull stop) {
        if (message.devConState == NO) {
            isShow = YES;
            *stop = YES;
        }
    }];
    return isShow;
}

@end
