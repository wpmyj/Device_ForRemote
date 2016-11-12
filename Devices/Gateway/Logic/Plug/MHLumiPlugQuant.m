//
//  MHLumiPlugQuant.m
//  MiHome
//
//  Created by Lynn on 12/26/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLumiPlugQuant.h"

@implementation MHLumiPlugQuant

+ (instancetype)dataWithJSONObject:(id)object
{
    MHLumiPlugQuant* quant = [[self alloc] init];
    
    quant.deviceId = [object valueForKey:@"deviceId"];
    quant.dateString = [object valueForKey:@"dateString"];
    quant.quantValue = [object valueForKey:@"quantValue"];
    quant.dateType = [object valueForKey:@"dateType"];
    return quant;
}

#pragma mark - 支持序列化存储
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.deviceId forKey:@"deviceId"];
    [aCoder encodeObject:self.dateString forKey:@"dateString"];
    [aCoder encodeObject:self.quantValue forKey:@"quantValue"];
    [aCoder encodeObject:self.dateType forKey:@"dateType"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.deviceId = [aDecoder decodeObjectForKey:@"deviceId"];
        self.dateString = [aDecoder decodeObjectForKey:@"dateString"];
        self.quantValue = [aDecoder decodeObjectForKey:@"quantValue"];
        self.dateType = [aDecoder decodeObjectForKey:@"dateType"];
    }
    return self;
}


@end
