//
//  MHLumiLocalCacheManager.m
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/2.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiLocalCacheManager.h"
#import "MHLumiLocalCachePathHelper.h"

@interface MHLumiLocalCacheManager()
@property (nonatomic, copy) NSString *todoPath;
@property (atomic, strong) NSMutableDictionary *todoDic;
@property (nonatomic, assign) MHLumiLocalCacheManagerType type;
@property (nonatomic, copy) NSString *identifier;
@end

@implementation MHLumiLocalCacheManager
- (instancetype)initWithType:(MHLumiLocalCacheManagerType) type andIdentifier:(NSString *)identifier{
    self = [super init];
    if (self){
        self.todoPath = [self pathWithType:type andIdentifier:identifier];
//        if (![[NSFileManager defaultManager] fileExistsAtPath:self.todoPath]){
//            [[NSFileManager defaultManager] createFileAtPath:self.todoPath contents:nil attributes:nil];
//        }
        self.type = type;
        self.identifier = identifier;
        [self synchronize];
    }
    return self;
}

- (NSString *)pathWithType:(MHLumiLocalCacheManagerType) type andIdentifier:(NSString *)identifier{
    NSString *path = nil;
    switch (type) {
        case MHLumiLocalCacheManagerCommon:{
            NSString *fileName = [NSString stringWithFormat:@"%@_%@_MHLumiLocalCacheManager.dic",@"common",identifier];
            path = [[MHLumiLocalCachePathHelper defaultHelper] pathWithLocalCacheType:MHLumiLocalCacheTypeCommon andFilename:fileName];
        }
            break;
        default:{
            NSString *fileName = [NSString stringWithFormat:@"%@_%@_MHLumiLocalCacheManager.dic",@"lumi",identifier];
            path = [[MHLumiLocalCachePathHelper defaultHelper] pathWithLocalCacheType:MHLumiLocalCacheTypeLumiLibraryCachesHome andFilename:fileName];
        }
            break;
    }
    return path;
}

- (void)removeObjectForKey:(NSString *)aKey{
    [self synchronize];
    [self.todoDic removeObjectForKey:aKey];
    [self save];
}

- (void)setObject:(NSObject *)anObject forKey:(NSString *)aKey{
    [self synchronize];
    [self.todoDic setObject:anObject forKey:aKey];
    [self save];
}

- (NSObject *)objectForKey:(NSString *)aKey{
    [self synchronize];
    return [self.todoDic objectForKey:aKey];
}

- (void)synchronize{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:self.todoPath];
    if (dic){
        self.todoDic = dic;
    }else{
        self.todoDic = [NSMutableDictionary dictionary];
        [self save];
    }
}

- (void)save{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.todoPath]){
        [[NSFileManager defaultManager] removeItemAtPath:self.todoPath error:nil];
    }
    [self.todoDic writeToFile:self.todoPath atomically:YES];
}
@end
