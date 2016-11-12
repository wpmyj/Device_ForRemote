//
//  MHLumiXMRadio.m
//  MiHome
//
//  Created by Lynn on 11/23/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLumiXMProgram.h"
#import "MHLumiXMAnnouncer.h"

@implementation MHLumiXMProgram

+ (instancetype)dataWithJSONObject:(id)object
{
    MHLumiXMProgram* program = [[self alloc] init];
    
    program.program_id = [[object valueForKey:@"id"] stringValue];
    program.listen_back_url = [object valueForKey:@"listen_back_url"];
    program.programStartTime = [[object valueForKey:@"start_time"] stringValue];
    program.programEndTime = [[object valueForKey:@"end_time"] stringValue];
    program.updated_at = [[object valueForKey:@"updated_at"] stringValue];

    NSDictionary *relateProgram = [object valueForKey:@"related_program"];
    if([relateProgram isKindOfClass:[NSDictionary class]]) {

        program.program_name = [[relateProgram valueForKey:@"program_name"] stringValue];
        program.rate64_aac_url = [relateProgram valueForKey:@"rate64_aac_url"];
        program.live_announcers = [MHLumiXMAnnouncer dataListWithJSONObjectList:
                                   [relateProgram valueForKey:@"live_announcers"]];
    }

    return program;
}

- (BOOL)isEqual:(id)object
{
    MHLumiXMProgram *program = (MHLumiXMProgram *)object;
    
    if(![program isKindOfClass:[self class]]){
        return NO;
    }
    
    return ([program.program_id isEqualToString:self.program_id] &&
            [program.program_name isEqualToString:self.program_name]);
}

#pragma mark - 支持序列化存储
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.program_id forKey:@"program_id"];
    [aCoder encodeObject:self.program_name forKey:@"program_name"];
    [aCoder encodeObject:self.programStartTime forKey:@"programStartTime"];
    [aCoder encodeObject:self.programEndTime forKey:@"programEndTime"];
    [aCoder encodeObject:self.listen_back_url forKey:@"listen_back_url"];
    [aCoder encodeObject:self.rate64_aac_url forKey:@"rate64_aac_url"];
    [aCoder encodeObject:self.live_announcers forKey:@"live_announcers"];
    [aCoder encodeObject:self.updated_at forKey:@"updated_at"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.program_id = [aDecoder decodeObjectForKey:@"program_id"];
        self.program_name = [aDecoder decodeObjectForKey:@"program_name"];
        self.programStartTime = [aDecoder decodeObjectForKey:@"programStartTime"];
        self.programEndTime = [aDecoder decodeObjectForKey:@"programEndTime"];
        self.listen_back_url = [aDecoder decodeObjectForKey:@"listen_back_url"];
        self.rate64_aac_url = [aDecoder decodeObjectForKey:@"rate64_aac_url"];
        self.live_announcers = [aDecoder decodeObjectForKey:@"live_announcers"];
        self.updated_at = [aDecoder decodeObjectForKey:@"updated_at"];
    }
    return self;
}
@end
