//
//  MHLumiLocalCacheManager.h
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/2.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, MHLumiLocalCacheManagerType){
    MHLumiLocalCacheManagerCommon,
};

//线程不安全
@interface MHLumiLocalCacheManager : NSMutableDictionary
@property (nonatomic, copy, readonly) NSString *todoPath;
@property (atomic, strong, readonly) NSMutableDictionary *todoDic;
@property (nonatomic, assign, readonly) MHLumiLocalCacheManagerType type;
@property (nonatomic, copy, readonly) NSString *identifier;
- (instancetype)initWithType:(MHLumiLocalCacheManagerType) type andIdentifier:(NSString *)identifier;
- (void)removeObjectForKey:(NSString *)aKey;
- (void)setObject:(NSObject *)anObject forKey:(NSString *)aKey;
- (NSObject *)objectForKey:(NSString *)aKey;
@end
