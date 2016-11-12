//
//  MHLumiXMProvince.m
//  MiHome
//
//  Created by Lynn on 11/20/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLumiXMProvince.h"

@implementation MHLumiXMProvince

+ (instancetype)dataWithJSONObject:(id)object
{
    MHLumiXMProvince* province = [[self alloc] init];

    province.provinceId = [[object objectForKey:@"id"] stringValue];
    province.name = [[object objectForKey:@"province_name"] stringValue];
    province.code = [[object objectForKey:@"province_code"]  stringValue];

    double interval = [[object objectForKey:@"created_at"] doubleValue] / 1000;
    province.createtime = [NSDate dateWithTimeIntervalSince1970:interval];
    
    province.isCurrentLocal = NO; //默认为NO，后期设置
    
    return province;
}

-(BOOL)isEqual:(id)object
{
    MHLumiXMProvince *province = (MHLumiXMProvince *)object;
    
    if(![province isKindOfClass:[self class]]){
        return NO;
    }
    
    return ([province.name isEqualToString:self.name] &&
            [province.code isEqualToString:self.code]);
}

#pragma mark - 支持序列化存储
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.code forKey:@"code"];
    [aCoder encodeObject:self.provinceId forKey:@"provinceId"];
    [aCoder encodeObject:@(self.isCurrentLocal) forKey:@"isCurrentLocal"];
    [aCoder encodeDouble:[self.createtime timeIntervalSince1970] forKey:@"createtime"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.provinceId = [aDecoder decodeObjectForKey:@"provinceId"];
        self.code = [aDecoder decodeObjectForKey:@"code"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.isCurrentLocal = [[aDecoder decodeObjectForKey:@"isCurrentLocal"] boolValue];
        self.createtime = [NSDate dateWithTimeIntervalSince1970:[aDecoder decodeDoubleForKey:@"createtime"]];
    }
    return self;
}

@end
