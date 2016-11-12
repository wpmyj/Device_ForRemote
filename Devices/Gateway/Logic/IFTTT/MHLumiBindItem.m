//
//  MHLumiBindItem.m
//  MiHome
//
//  Created by Lynn on 1/11/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLumiBindItem.h"

@implementation MHLumiBindItem  

- (BOOL)isEqualTo:(MHLumiBindItem* )item {
    return ([self.event isEqualToString:item.event] &&
            [self.from_sid isEqualToString:item.from_sid ] &&
            [self.method isEqualToString:item.method]);
}

#pragma mark - encoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.from_sid forKey:@"from_sid"];
    [aCoder encodeObject:self.to_sid forKey:@"to_sid"];
    [aCoder encodeObject:self.method forKey:@"method"];
    [aCoder encodeObject:self.params forKey:@"params"];
    [aCoder encodeObject:self.event forKey:@"event"];
    [aCoder encodeObject:@(self.enable) forKey:@"enable"];
    [aCoder encodeObject:@(self.index) forKey:@"index"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.from_sid = [aDecoder decodeObjectForKey:@"from_sid"];
        self.to_sid = [aDecoder decodeObjectForKey:@"to_sid"];
        self.method = [aDecoder decodeObjectForKey:@"method"];
        self.params = [aDecoder decodeObjectForKey:@"params"];
        self.event = [aDecoder decodeObjectForKey:@"event"];
        self.enable = [[aDecoder decodeObjectForKey:@"enable"] boolValue];
        self.index = [[aDecoder decodeObjectForKey:@"index"] integerValue];

    }
    return self;
}

@end
