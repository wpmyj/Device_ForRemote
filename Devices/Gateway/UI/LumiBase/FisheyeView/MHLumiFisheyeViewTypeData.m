//
//  MHLumiFisheyeViewTypeData.m
//  SFFmpegIOSDecoder
//
//  Created by LM21Mac002 on 16/10/4.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiFisheyeViewTypeData.h"

@interface MHLumiFisheyeViewTypeData()
@property (nonatomic, assign) NSInteger maxTilt;
@property (nonatomic, assign) NSInteger minTilt;

@property (nonatomic, assign) NSInteger maxPan;
@property (nonatomic, assign) NSInteger minPan;

@property (nonatomic, assign) NSInteger maxZoom;
@property (nonatomic, assign) NSInteger minZoom;

@property (nonatomic, assign) NSInteger defaultTilt;
@property (nonatomic, assign) NSInteger defaultPan;
@property (nonatomic, assign) NSInteger defaultZoom;

@property (nonatomic, assign) MHLumiFisheyeViewType type;
@property (nonatomic, assign) FEMOUNTTYPE mountType;
@property (nonatomic, assign) FEDEWARPTYPE dewrapType;
@end

@implementation MHLumiFisheyeViewTypeData
+ (instancetype)fisheyeViewTypeDataWithType:(MHLumiFisheyeViewType)type
                                  mountType:(FEMOUNTTYPE)mountType
                                 dewrapType:(FEDEWARPTYPE)dewrapType{
    MHLumiFisheyeViewTypeData *data = nil;
    switch (dewrapType) {
        case FE_DEWARP_AROUNDVIEW:
            data = [MHLumiFisheyeViewTypeData fisheyeViewTypeDataInAroundViewWithViewType:type mountType:mountType];
            break;
        case FE_DEWARP_AERIALVIEW:
            data = [MHLumiFisheyeViewTypeData fisheyeViewTypeDataInAerialViewWithViewType:type mountType:mountType];
            break;
        default:
            break;
    }
    return data;
}

+ (instancetype)fisheyeViewTypeDataInAerialViewWithViewType:(MHLumiFisheyeViewType)type
                                                  mountType:(FEMOUNTTYPE)mountType{
    FEDEWARPTYPE dewrapType = FE_DEWARP_AERIALVIEW;
    MHLumiFisheyeViewTypeData *data = nil;
    switch (type) {
        case MHLumiFisheyeViewTypeA:{
            switch (mountType) {
                case FE_MOUNT_FLOOR:{
                    NSInteger aDefaultZoom = 2;
                    data = [[MHLumiFisheyeViewTypeData alloc] initWithType:type mountType:mountType dewrapType:dewrapType maxTilt:0 minTilt:-90 maxPan:360 minPan:0 maxZoom:8 minZoom:2 defaultTilt:-90/aDefaultZoom defaultPan:0 defaultZoom:aDefaultZoom];
                }
                    break;
                case FE_MOUNT_CEILING:{
                    NSInteger aDefaultZoom = 2;
                    data = [[MHLumiFisheyeViewTypeData alloc] initWithType:type mountType:mountType dewrapType:dewrapType maxTilt:90 minTilt:0 maxPan:360 minPan:0 maxZoom:8 minZoom:2 defaultTilt:90/aDefaultZoom defaultPan:0 defaultZoom:aDefaultZoom];
                }
                default:
                    break;
            }
        }
            break;
        default:{
            switch (mountType) {
                case FE_MOUNT_FLOOR:{
                    NSInteger aDefaultZoom = 1;
                    data = [[MHLumiFisheyeViewTypeData alloc] initWithType:type mountType:mountType dewrapType:dewrapType maxTilt:90 minTilt:90 maxPan:360 minPan:0 maxZoom:1 minZoom:1 defaultTilt:90/aDefaultZoom defaultPan:0 defaultZoom:aDefaultZoom];
                }
                    break;
                case FE_MOUNT_CEILING:{
                    data = [[MHLumiFisheyeViewTypeData alloc] initWithType:type mountType:mountType dewrapType:dewrapType maxTilt:-90 minTilt:-90 maxPan:360 minPan:0 maxZoom:1 minZoom:1 defaultTilt:-90 defaultPan:0 defaultZoom:1];
                }
                    break;
                default:
                    break;
            }
            
        }
            break;
    }
    return data;
}

+ (instancetype)fisheyeViewTypeDataInAroundViewWithViewType:(MHLumiFisheyeViewType)type
                                                  mountType:(FEMOUNTTYPE)mountType{
    FEDEWARPTYPE dewrapType = FE_DEWARP_AROUNDVIEW;
    MHLumiFisheyeViewTypeData *data = nil;
    switch (type) {
        case MHLumiFisheyeViewTypeA:{
            switch (mountType) {
                case FE_MOUNT_FLOOR:{
                    NSInteger aDefaultZoom = 2;
                    data = [[MHLumiFisheyeViewTypeData alloc] initWithType:type mountType:mountType dewrapType:dewrapType maxTilt:90 minTilt:0 maxPan:360 minPan:0 maxZoom:8 minZoom:2 defaultTilt:90/aDefaultZoom defaultPan:0 defaultZoom:aDefaultZoom];
                }
                    break;
                case FE_MOUNT_CEILING:{
                    NSInteger aDefaultZoom = 2;
                    data = [[MHLumiFisheyeViewTypeData alloc] initWithType:type mountType:mountType dewrapType:dewrapType maxTilt:0 minTilt:-90 maxPan:360 minPan:0 maxZoom:8 minZoom:2 defaultTilt:-90/aDefaultZoom defaultPan:0 defaultZoom:aDefaultZoom];
                }
                default:
                    break;
            }
            
            
        }
            break;
        default:{
            switch (mountType) {
                case FE_MOUNT_FLOOR:{
                    NSInteger aDefaultZoom = 1;
                    data = [[MHLumiFisheyeViewTypeData alloc] initWithType:type mountType:mountType dewrapType:dewrapType maxTilt:90 minTilt:90 maxPan:360 minPan:0 maxZoom:1 minZoom:1 defaultTilt:90/aDefaultZoom defaultPan:0 defaultZoom:aDefaultZoom];
                }
                    break;
                case FE_MOUNT_CEILING:{
                    data = [[MHLumiFisheyeViewTypeData alloc] initWithType:type mountType:mountType dewrapType:dewrapType maxTilt:-90 minTilt:-90 maxPan:360 minPan:0 maxZoom:1 minZoom:1 defaultTilt:-90 defaultPan:0 defaultZoom:1];
                }
                    break;
                default:
                    break;
            }
            
        }
            break;
    }
    return data;
}


- (instancetype)initWithType:(MHLumiFisheyeViewType)type
                   mountType:(FEMOUNTTYPE)mountType
                  dewrapType:(FEDEWARPTYPE)dewrapType
                     maxTilt:(NSInteger)maxTilt
                     minTilt:(NSInteger)minTilt
                      maxPan:(NSInteger)maxPan
                      minPan:(NSInteger)minPan
                     maxZoom:(NSInteger)maxZoom
                     minZoom:(NSInteger)minZoom
                 defaultTilt:(NSInteger)defaultTilt
                  defaultPan:(NSInteger)defaultPan
                 defaultZoom:(NSInteger)defaultZoom{
    MHLumiFisheyeViewTypeData *data = [[MHLumiFisheyeViewTypeData alloc] init];
    data.defaultTilt = defaultTilt;
    data.defaultPan = defaultPan;
    data.defaultZoom = defaultZoom;
    data.type = type;
    data.maxTilt = maxTilt;
    data.minTilt = minTilt;
    data.maxPan = maxPan;
    data.minPan = minPan;
    data.minZoom = minZoom;
    data.maxZoom = maxZoom;
    data.dewrapType = dewrapType;
    data.mountType = mountType;
    return data;
}

- (void)updateWithZoom:(NSInteger)zoom{
    switch (_dewrapType) {
        case FE_DEWARP_AERIALVIEW:
            [self updateInAerialViewWithZoom:zoom];
            break;
        case FE_DEWARP_AROUNDVIEW:
            [self updateInAroundViewWithZoom:zoom];
        default:
            break;
    }
}

- (void)updateInAroundViewWithZoom:(NSInteger)zoom{
    switch (_type) {
        case MHLumiFisheyeViewTypeA:
            switch (_mountType) {
                case FE_MOUNT_FLOOR:{
                    _minTilt = 0;
                    _defaultTilt = 90/zoom;
                }
                    break;
                case FE_MOUNT_CEILING:{
                    _defaultTilt = -90/zoom;
                }
                    break;
                default:
                    break;
            }
            
            break;
        default:
            break;
    }
}

- (void)updateInAerialViewWithZoom:(NSInteger)zoom{
    switch (_type) {
        case MHLumiFisheyeViewTypeA:
            switch (_mountType) {
                case FE_MOUNT_FLOOR:{
                    _defaultTilt = -(90.0-90.0/zoom);
                }
                    break;
                case FE_MOUNT_CEILING:{
                    _defaultTilt = (90.0-90.0/zoom);
                }
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
}


@end
