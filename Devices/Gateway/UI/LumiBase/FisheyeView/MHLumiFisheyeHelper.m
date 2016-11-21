//
//  MHLumiFisheyeHelper.m
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/14.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiFisheyeHelper.h"

@implementation MHLumiFisheyeHelper
static NSString *kFE_MOUNT_WALL = @"FEMountWall";
static NSString *kFE_MOUNT_FLOOR = @"FEMountFloor";
static NSString *kFE_MOUNT_CEILING = @"FEMountCeiling";
static NSString *kFE_DEWARP_AERIALVIEW = @"FEDewarpAerialView";
static NSString *kFE_DEWARP_AROUNDVIEW = @"FEDewarpAroundView";
+ (NSString *)nameFromMountType:(FEMOUNTTYPE)mountType{
    NSString *name = nil;
    switch (mountType) {
        case FE_MOUNT_WALL:
            name = kFE_MOUNT_WALL;
            break;
        case FE_MOUNT_FLOOR:
            name = kFE_MOUNT_FLOOR;
            break;
        case FE_MOUNT_CEILING:
            name = kFE_MOUNT_CEILING;
            break;
        default:
            name = kFE_MOUNT_CEILING;
            break;
    }
    return name;
}

+ (NSString *)nameFromDewrapType:(FEDEWARPTYPE)dewrapType{
    NSString *name = nil;
    switch (dewrapType) {
        case FE_DEWARP_AERIALVIEW:
            name = kFE_DEWARP_AERIALVIEW;
            break;
        case FE_DEWARP_AROUNDVIEW:
            name = kFE_DEWARP_AROUNDVIEW;
            break;
        default:
            name = kFE_DEWARP_AERIALVIEW;
            break;
    }
    return name;
}

+ (FEDEWARPTYPE)dewrapTypeFromString:(NSString *)string{
    FEDEWARPTYPE dewrapType = FE_DEWARP_AERIALVIEW;
    if ([string isEqualToString:kFE_DEWARP_AERIALVIEW]) {
        dewrapType = FE_DEWARP_AERIALVIEW;
    }
    
    if ([string isEqualToString:kFE_DEWARP_AROUNDVIEW]) {
        dewrapType = FE_DEWARP_AROUNDVIEW;
    }
    
    return dewrapType;
}


+ (FEMOUNTTYPE)mountTypeFromString:(NSString *)string{
    FEMOUNTTYPE mountType = FE_MOUNT_CEILING;
    if ([string isEqualToString:kFE_MOUNT_CEILING]) {
        mountType = FE_MOUNT_CEILING;
    }
    if ([string isEqualToString:kFE_MOUNT_FLOOR]) {
        mountType = FE_MOUNT_FLOOR;
    }
    if ([string isEqualToString:kFE_MOUNT_WALL]) {
        mountType = FE_MOUNT_WALL;
    }
    return mountType;
}
@end
