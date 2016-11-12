//
//  MHLumiXMTopWord.m
//  MiHome
//
//  Created by Lynn on 1/19/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLumiXMTopWord.h"

@implementation MHLumiXMTopWord

+ (instancetype)dataWithJSONObject:(id)object
{
    MHLumiXMTopWord* topWord = [[self alloc] init];
    
    topWord.search_word = [[object valueForKey:@"search_word"] stringValue];
    topWord.count = @([[object valueForKey:@"count"] integerValue]);
    topWord.degree = [[object valueForKey:@"degree"] stringValue];
    
    return topWord;
}

- (BOOL)isEqual:(id)object
{
    MHLumiXMTopWord *ann = (MHLumiXMTopWord *)object;
    
    if(![ann isKindOfClass:[self class]]){
        return NO;
    }
    
    return [ann.search_word isEqualToString:self.search_word];
}

#pragma mark - 支持序列化存储
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.search_word forKey:@"search_word"];
    [aCoder encodeObject:self.count forKey:@"count"];
    [aCoder encodeObject:self.degree forKey:@"degree"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.search_word = [aDecoder decodeObjectForKey:@"search_word"];
        self.degree = [aDecoder decodeObjectForKey:@"degree"];
        self.count = [aDecoder decodeObjectForKey:@"count"];
    }
    return self;
}

@end
