//
//  MHLumiXMRadio.m
//  MiHome
//
//  Created by Lynn on 11/23/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLumiXMAnnouncer.h"

@implementation MHLumiXMAnnouncer

+ (instancetype)dataWithJSONObject:(id)object
{
    MHLumiXMAnnouncer* announcer = [[self alloc] init];
    
    announcer.announcer_id = [object valueForKey:@"id"];
    announcer.nickname = [object valueForKey:@"nickname"];
    announcer.avatar_url = [object valueForKey:@"avatar_url"];

    return announcer;
}

- (BOOL)isEqual:(id)object
{
    MHLumiXMAnnouncer *ann = (MHLumiXMAnnouncer *)object;
    
    if(![ann isKindOfClass:[self class]]){
        return NO;
    }
    
    return ([ann.announcer_id isEqualToString:self.announcer_id] &&
            [ann.nickname isEqualToString:self.nickname]);
}

#pragma mark - 支持序列化存储
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.announcer_id forKey:@"announcer_id"];
    [aCoder encodeObject:self.nickname forKey:@"nickname"];
    [aCoder encodeObject:self.avatar_url forKey:@"avatar_url"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.announcer_id = [aDecoder decodeObjectForKey:@"announcer_id"];
        self.nickname = [aDecoder decodeObjectForKey:@"nickname"];
        self.avatar_url = [aDecoder decodeObjectForKey:@"avatar_url"];
    }
    return self;
}
@end
