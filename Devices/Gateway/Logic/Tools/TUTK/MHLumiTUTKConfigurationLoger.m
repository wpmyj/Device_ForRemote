//
//  MHLumiTUTKConfigurationLoger.m
//  MiHome
//
//  Created by LM21Mac002 on 16/10/14.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiTUTKConfigurationLoger.h"

@interface MHLumiTUTKConfigurationLoger()

@property (copy, nonatomic) NSString *todoPath;
@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *deviceId;
@property (strong, nonatomic) NSMutableDictionary *todoDic;
@end

@implementation MHLumiTUTKConfigurationLoger

- (instancetype)initWithUserId:(NSString *)userId deviceId:(NSString *)deviceId{
    self = [super init];
    if (self){
        NSString *cachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        _todoPath = [cachesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"TUTKConfiguration_%@_%@.dic",userId,deviceId]];
        _userId = userId;
        _deviceId = _deviceId;
    }
    return self;
}

//- (NSMutableDictionary *)todoDic{
//    
//}
@end
