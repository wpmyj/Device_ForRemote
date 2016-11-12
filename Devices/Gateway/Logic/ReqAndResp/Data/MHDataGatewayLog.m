//
//  MHDataGatewayLog.m
//  MiHome
//
//  Created by Woody on 15/4/10.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import "MHDataGatewayLog.h"
#import "MHStrongBox.h"

@implementation MHDataGatewayLog

+ (instancetype)dataWithJSONObject:(id)object
{
    NSDictionary *dic = object;
    
    NSLog(@"%@", dic.allKeys);
    NSLog(@"%@", dic.allValues);
    MHDataGatewayLog* log = [[self alloc] init];
    log.did = [object objectForKey:@"did" class:[NSString class]];
    NSLog(@"%@", log.did);
    log.key = [object objectForKey:@"key" class:[NSString class]];

    log.type = [object objectForKey:@"type" class:[NSString class]];
    log.value = [object objectForKey:@"value" class:[NSString class]];
    NSData *codeData = [[NSData alloc] initWithData:[log.value dataUsingEncoding:NSUTF8StringEncoding]];
    NSArray *tempArray = [NSJSONSerialization JSONObjectWithData:codeData options:NSJSONReadingMutableLeaves error:nil];
    if (tempArray.count > 0 && ![log.did containsString:@"lumi"]) {
        log.subDeviceDid = tempArray[0];
    }
    else {
        log.subDeviceDid = log.did;
    }
    double time = [[object objectForKey:@"time" class:[NSNumber class]] doubleValue];
    log.time = [NSDate dateWithTimeIntervalSince1970:time];
    return log;
}

#pragma mark - 支持序列化存储
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.did forKey:@"did"];
    [aCoder encodeObject:self.key forKey:@"key"];
    [aCoder encodeDouble:[self.time timeIntervalSince1970] forKey:@"time"];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.value forKey:@"value"];
    [aCoder encodeObject:self.subDeviceDid forKey:@"subDeviceDid"];

    [aCoder encodeBool:self.hasPrev forKey:@"hasPrev"];
    [aCoder encodeBool:self.hasNext forKey:@"hasNext"];
    [aCoder encodeBool:self.isFirst forKey:@"isFirst"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.did = [aDecoder decodeObjectForKey:@"did"];
        self.key = [aDecoder decodeObjectForKey:@"key"];
        self.time = [NSDate dateWithTimeIntervalSince1970:[aDecoder decodeDoubleForKey:@"time"]];
        self.type = [aDecoder decodeObjectForKey:@"type"];
        self.value = [aDecoder decodeObjectForKey:@"value"];
        self.subDeviceDid = [aDecoder decodeObjectForKey:@"subDeviceDid"];
        self.hasPrev = [aDecoder decodeBoolForKey:@"hasPrev"];
        self.hasNext = [aDecoder decodeBoolForKey:@"hasNext"];
        self.isFirst = [aDecoder decodeBoolForKey:@"isFirst"];
    }
    return self;
}


@end
