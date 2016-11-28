//
//  MHLumiLocalCachePathHelper.m
//  MiHome
//
//  Created by LM21Mac002 on 16/10/17.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiLocalCachePathHelper.h"

@interface MHLumiLocalCachePathHelper()
@property (strong, nonatomic) NSFileManager *fileMangager;
@end


@implementation MHLumiLocalCachePathHelper

static MHLumiLocalCachePathHelper *_instance = nil;
+ (MHLumiLocalCachePathHelper *)defaultHelper{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (NSString *)pathWithLocalCacheType:(MHLumiLocalCacheType)type andFilename:(NSString *)filename{
    NSString *path = nil;
    switch (type) {
        case MHLumiLocalCacheTypeLumiLibraryCachesHome:
            path = [self lumiLibraryCachesPath];
            break;
        case MHLumiLocalCacheTypeTUTKPath:
            path = [self lumiTUTKPath];
            break;
        case MHLumiLocalCacheTypeCommon:
            path = [self commonPath];
            break;
        case MHLumiLocalCacheManagerAlarmVideoPath:
            path = [self alarmVideoPath];
            break;
        default:
            break;
    }
    if (filename != nil){
        path = [path stringByAppendingPathComponent:filename];
    }
    return path;
}

+ (BOOL)removeAllAtPathWithType:(MHLumiLocalCacheType)type{
    NSString *tutkPath = [[MHLumiLocalCachePathHelper defaultHelper] pathWithLocalCacheType:type andFilename:nil];
    NSError *error = nil;
    NSArray<NSString *> * paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tutkPath error:&error];
    if (error) {
        NSLog(@"RemoveAllAtTUTKPath error = %@",error.localizedDescription);
        return NO;
    }
    for (NSString *todoPath in paths) {
        NSString *toDeletePath = [tutkPath stringByAppendingPathComponent:todoPath];
        [[NSFileManager defaultManager] removeItemAtPath:toDeletePath error:&error];
    }
    if (error) {
        NSLog(@"RemoveAllAtTUTKPath error = %@",error.localizedDescription);
        return NO;
    }
    return YES;
}

//AlarmVideo Library/Caches/LumiLocalCacheFile/AlarmVideo
- (NSString *)alarmVideoPath{
    NSString *path = [self lumiLibraryCachesPath];
    path = [path stringByAppendingPathComponent:@"AlarmVideo"];
    if (![self.fileMangager fileExistsAtPath:path]){
        NSError *error = nil;
        [self.fileMangager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        NSLog(@"error: %@",error);
    }
    return path;
}

//Lumi Library/Caches/LumiLocalCacheFile/common
- (NSString *)commonPath{
    NSString *path = [self lumiLibraryCachesPath];
    path = [path stringByAppendingPathComponent:@"common"];
    if (![self.fileMangager fileExistsAtPath:path]){
        NSError *error = nil;
        [self.fileMangager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        NSLog(@"error: %@",error);
    }
    return path;
}

//TUTK Library/Caches/LumiLocalCacheFile/TUTK
- (NSString *)lumiTUTKPath{
    NSString *path = [self lumiLibraryCachesPath];
    path = [path stringByAppendingPathComponent:@"TUTK"];
    if (![self.fileMangager fileExistsAtPath:path]){
        NSError *error = nil;
        [self.fileMangager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        NSLog(@"error: %@",error);
    }
    return path;
}

//Lumi Library/Caches/LumiLocalCacheFile
- (NSString *)lumiLibraryCachesPath{
    NSString *path = [self liararyCachesPath];
    path = [path stringByAppendingPathComponent:@"com.lumiunited"];
    if (![self.fileMangager fileExistsAtPath:path]){
        NSError *error = nil;
        [self.fileMangager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        NSLog(@"error: %@",error);
    }
    return path;
}

// location of discardable cache files (Library/Caches)
- (NSString *)liararyCachesPath{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    return path;
}

- (NSFileManager *)fileMangager{
    return [NSFileManager defaultManager];
}

@end
