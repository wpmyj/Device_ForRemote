//
//  MHLumiXMRadio.m
//  MiHome
//
//  Created by Lynn on 11/23/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLumiXMRadio.h"

@implementation MHLumiXMRadio

+ (instancetype)dataWithJSONObject:(id)object
{
    MHLumiXMRadio* radio = [[self alloc] init];
    
    radio.radioId = [[object valueForKey:@"id"] stringValue];
    radio.radioName = [[object valueForKey:@"radio_name"] stringValue];
    radio.radioCoverSmallUrl = [object valueForKey:@"cover_url_small"];
    radio.radioCoverLargeUrl = [object valueForKey:@"cover_url_large"];
    radio.radioPlayCount = [[object valueForKey:@"radio_play_count"] stringValue];
    radio.radioDesc = [[object valueForKey:@"radio_desc"] stringValue];
    radio.radioRateUrl = [[object valueForKey:@"rate64_aac_url"] stringValue];
    radio.radioLowRateUrl = [[object valueForKey:@"rate24_aac_url"] stringValue];
    radio.currentProgram = [[object valueForKey:@"program_name"] stringValue];
    radio.radioCollection = @"no";
    
    NSTimeInterval unixTime= [[NSDate date] timeIntervalSince1970];
    radio.updateaTimeStamp = [NSString stringWithFormat:@"%lld",(long long int)unixTime];

    return radio;
}

- (BOOL)isEqual:(id)object
{
    MHLumiXMRadio *radio = (MHLumiXMRadio *)object;
    
    if(![radio isKindOfClass:[self class]]){
        return NO;
    }
    
    return ([radio.radioId isEqualToString:self.radioId] &&
            [radio.radioName isEqualToString:self.radioName]);
}

- (NSString *)description {
    return  [NSString stringWithFormat:@"%@ - radioid:%@ - %@",self.radioName,self.radioId,self.radioDesc];
}

//收藏用
+ (MHLumiXMRadio *)jsonToObject:(NSDictionary *)object {
    MHLumiXMRadio* radio = [[self alloc] init];
    
    radio.radioId = [[object valueForKey:@"radioId"] stringValue];
    radio.radioName = [[object valueForKey:@"radioName"] stringValue];
    radio.radioCoverSmallUrl = [object valueForKey:@"radioCoverSmallUrl"];
    radio.radioCoverLargeUrl = [object valueForKey:@"radioCoverLargeUrl"];
    radio.radioRateUrl = [[object valueForKey:@"radioRateUrl"] stringValue];
    radio.radioLowRateUrl = [[object valueForKey:@"radioLowRateUrl"] stringValue];
    radio.radioCollection = [[object valueForKey:@"radioCollection"] stringValue];;
    
    if ([[object valueForKey:@"updateaTimeStamp"] length] > 0 ){
        radio.updateaTimeStamp = [[object valueForKey:@"updateaTimeStamp"] stringValue];
    }
    else {
        NSTimeInterval unixTime= [[NSDate date] timeIntervalSince1970];
        radio.updateaTimeStamp = [NSString stringWithFormat:@"%lld",(long long int)unixTime];
    }
    
    return radio;
}

//收藏用，序列化
- (id)toJson {
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    [json setObject:self.radioId forKey:@"radioId"];
    [json setObject:self.radioName forKey:@"radioName"];
    if(self.radioCoverSmallUrl)[json setObject:self.radioCoverSmallUrl forKey:@"radioCoverSmallUrl"];
    if(self.radioCoverLargeUrl)[json setObject:self.radioCoverLargeUrl forKey:@"radioCoverLargeUrl"];
    if(self.radioRateUrl)[json setObject:self.radioRateUrl forKey:@"radioRateUrl"];
    if(self.radioLowRateUrl)[json setObject:self.radioLowRateUrl forKey:@"radioLowRateUrl"];
    if(self.radioCollection)[json setObject:self.radioCollection forKey:@"radioCollection"];
    [json setObject:self.updateaTimeStamp forKey:@"updateaTimeStamp"];
    
    return json;
}

#pragma mark - 支持序列化存储
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.radioId forKey:@"radioId"];
    [aCoder encodeObject:self.radioName forKey:@"radioName"];
    [aCoder encodeObject:self.radioCoverSmallUrl forKey:@"radioCoverSmallUrl"];
    [aCoder encodeObject:self.radioCoverLargeUrl forKey:@"radioCoverLargeUrl"];
    [aCoder encodeObject:self.radioPlayCount forKey:@"radioPlayCount"];
    [aCoder encodeObject:self.radioDesc forKey:@"radioDesc"];
    [aCoder encodeObject:self.radioRateUrl forKey:@"radioRateUrl"];
    [aCoder encodeObject:self.radioLowRateUrl forKey:@"radioLowRateUrl"];
    [aCoder encodeObject:self.currentProgram forKey:@"currentProgram"];
    [aCoder encodeObject:self.radioCollection forKey:@"radioCollection"];
    [aCoder encodeObject:self.updateaTimeStamp forKey:@"updateaTimeStamp"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.radioId = [aDecoder decodeObjectForKey:@"radioId"];
        self.radioName = [aDecoder decodeObjectForKey:@"radioName"];
        self.radioCoverSmallUrl = [aDecoder decodeObjectForKey:@"radioCoverSmallUrl"];
        self.radioCoverLargeUrl = [aDecoder decodeObjectForKey:@"radioCoverLargeUrl"];
        self.radioPlayCount = [aDecoder decodeObjectForKey:@"radioPlayCount"];
        self.radioDesc = [aDecoder decodeObjectForKey:@"radioDesc"];
        self.radioRateUrl = [aDecoder decodeObjectForKey:@"radioRateUrl"];
        self.radioLowRateUrl = [aDecoder decodeObjectForKey:@"radioLowRateUrl"];
        self.currentProgram = [aDecoder decodeObjectForKey:@"currentProgram"];
        self.radioCollection = [aDecoder decodeObjectForKey:@"radioCollection"];
        self.updateaTimeStamp = [[aDecoder decodeObjectForKey:@"updateaTimeStamp"] stringValue];
    }
    return self;
}
@end
