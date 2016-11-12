//
//  MHLumiAryTool.m
//  MiHome
//
//  Created by ayanami on 16/6/3.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiAryTool.h"

@implementation MHLumiAryTool

+ (id)sharedInstance {
    static MHLumiAryTool *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[MHLumiAryTool alloc] init];
        }
    });
    return manager;
}
@end
