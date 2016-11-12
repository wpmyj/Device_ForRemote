//
//  MHLumiActivitiesHelper.h
//  MiHome
//
//  Created by LM21Mac002 on 16/10/10.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHLumiIFTTTHelper.h"
#import "MHLumiRequestLogHelper.h"
#import "MHDeviceGateway.h"
#import "MHLumiIFTTTHelper.h"

@interface MHLumiActivitiesHelper : NSObject

@property (nonatomic, strong) MHDeviceGateway *gateway;
@property (nonatomic, assign) MHLumiActivitiesType activitiesType;

- (instancetype)initWithType:(MHLumiActivitiesType)type
                     gateway:(MHDeviceGateway *)gateway
                   logHelper:(MHLumiRequestLogHelper *)helper;
- (void)setDefaultconfigurationWithSuccess:(void(^)())success failure:(void(^)())failure;
@end
