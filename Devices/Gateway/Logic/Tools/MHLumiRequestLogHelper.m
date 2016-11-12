//
//  MHLumiRequestLogHelper.m
//  MiHome
//
//  Created by LM21Mac002 on 16/10/10.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiRequestLogHelper.h"

@interface MHLumiRequestLogHelper()
@property (nonatomic, copy) NSString *todoPath;
@property (nonatomic, strong) NSMutableDictionary *todoDic;
@property (nonatomic, assign) MHLumiActivitiesType type;
@property (nonatomic, assign) NSInteger stepCount;
@property (nonatomic, copy) NSString *identifier;
@end

@implementation MHLumiRequestLogHelper

- (void)setLogStatusWithStepKey:(NSString *)key toStatus:(MHLumiRequestLogStepStatus)status{
    self.todoDic[key] = [NSNumber numberWithInteger:status];
}

- (bool)isCompleted{
    bool flag = YES;
    for (NSNumber *num in self.todoDic.allValues) {
        if ([num integerValue] != 1){
            flag = NO;
            break;
        }
    }
    return flag;
}

- (bool)isLogExisted{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self todoPathWithType:self.type andIdentifier:self.identifier]];
}

- (bool)removeLogDic{
    NSError *error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:_todoPath]){
        [[NSFileManager defaultManager] removeItemAtPath:_todoPath error:&error];
    }
    if (error == nil) {
        return YES;
    }
    return NO;
}

- (instancetype)initWithType:(MHLumiActivitiesType)type andIdentifier:(NSString *)identifier {
    self = [super init];
    if (self){
        _identifier = identifier;
        _type = type;
        _todoPath = [self todoPathWithType:type andIdentifier:identifier];
        switch(type) {
            case MHLumiActivitiesTypeDouble11:
                _stepCount = 6+2;//双11一共要有六步需要设置加两个个自动化场景
                break;
            default:
                _stepCount = 0;
                break;
        }
        _todoDic = [NSMutableDictionary dictionaryWithDictionary:[self getLogDicAtPath:_todoPath creatIfNotExisted:YES]];

    }
    return self;
}

- (NSDictionary *)getLogDicAtPath:(NSString *)path creatIfNotExisted:(BOOL) yesOrNot{
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    if (dic){
        return dic;
    }
    if (yesOrNot){
        dic = [self getInitDictionaryWithType:self.type];
    }
    return dic;
}

- (NSDictionary *)getInitDictionaryWithType:(MHLumiActivitiesType)type{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (NSInteger index = 0; index < _stepCount; index ++) {
        NSString *key = [self keyFromIndex:index];
        dic[key] = @0;
    }
    return dic;
}

- (NSString *)todoPathWithType:(MHLumiActivitiesType)type andIdentifier:(NSString *)identifier{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *fileName = [NSString stringWithFormat:@"lumiRequestLogHelper_type_%ld_%@.dic",(long)type,identifier];
    return [path stringByAppendingPathComponent:fileName];
}

- (void)writeDic:(NSDictionary *)dic toPath:(NSString *)path{
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]){
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    [dic writeToFile:path atomically:YES];
}

- (void)markToSuccess{
    for (NSString *key in _todoDic.allKeys) {
        _todoDic[key] = @1;
    }
    [self writeDic:_todoDic toPath:_todoPath];
}

- (void)markToFailue{
    for (NSString *key in _todoDic.allKeys) {
        _todoDic[key] = @(-1);
    }
    [self writeDic:_todoDic toPath:_todoPath];
}

- (void)resetLogDic{
    for (NSString *key in _todoDic.allKeys) {
        _todoDic[key] = @0;
    }
    [self writeDic:_todoDic toPath:_todoPath];
}

- (void)setRequestStatus:(MHLumiRequestLogStepStatus)status indexKey:(NSInteger)indexKey{
    if (indexKey <0 || indexKey>=_stepCount){
        return;
    }
    NSString *key = [self keyFromIndex:indexKey];
    _todoDic[key] = @(status);
    [self writeDic:_todoDic toPath:_todoPath];
}

- (NSString *)keyFromIndex:(NSInteger)index{
    return [NSString stringWithFormat:@"step-%ld",(long)index];
}

- (NSArray *)todoIndexArray{
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger index = 0; index < _todoDic.count; index++) {
        if ([_todoDic[[self keyFromIndex:index]] integerValue] != 1){
            [array addObject:@(index)];
        }
    }
    return array;
}

@end
