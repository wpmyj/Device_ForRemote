//
//  MHLumiTUTKConfiguration.m
//  MiHome
//
//  Created by LM21Mac002 on 16/9/20.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiTUTKConfiguration.h"

@implementation MHLumiTUTKConfiguration
- (instancetype)init{
    self = [super init];
    if (self){
        
    }
    return self;
}

+ (MHLumiTUTKConfiguration *)defaultConfiguration{
    MHLumiTUTKConfiguration *configuration = [[MHLumiTUTKConfiguration alloc] init];
    configuration.nMaxChannelNum = 3;
    configuration.udid = nil;
    configuration.account = @"admin";
    configuration.password = @"888888";
    configuration.nTimeout = 2000;
    configuration.nLaunchServeTimeout = 5;
    return configuration;
}

@end
