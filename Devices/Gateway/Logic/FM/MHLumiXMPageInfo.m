//
//  MHLumiXMPageInfo.m
//  MiHome
//
//  Created by Lynn on 11/24/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLumiXMPageInfo.h"

@implementation MHLumiXMPageInfo

+ (instancetype)dataWithJSONObject:(id)object
{
    MHLumiXMPageInfo* page = [[self alloc] init];
    
    page.totalCount = [object valueForKey:@"total_count"];
    page.totalPage = [object valueForKey:@"total_page"];
    page.currentPage = [object valueForKey:@"current_page"];
    
    return page;
}

#pragma mark - 支持序列化存储
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.totalCount forKey:@"totalCount"];
    [aCoder encodeObject:self.totalPage forKey:@"totalPage"];
    [aCoder encodeObject:self.currentPage forKey:@"currentPage"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.totalCount = [aDecoder decodeObjectForKey:@"totalCount"];
        self.totalPage = [aDecoder decodeObjectForKey:@"totalPage"];
        self.currentPage = [aDecoder decodeObjectForKey:@"currentPage"];
    }
    return self;
}

@end
