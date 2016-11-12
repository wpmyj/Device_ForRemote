//
//  MHLumiFisheyeViewTypeData.h
//  SFFmpegIOSDecoder
//
//  Created by LM21Mac002 on 16/10/4.
//  Copyright © 2016年 Lei Xiaohua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHLumiFisheyeHeader.h"
#import "fisheye.h"

@interface MHLumiFisheyeViewTypeData : NSObject
@property (nonatomic, assign, readonly) NSInteger maxTilt;
@property (nonatomic, assign, readonly) NSInteger minTilt;

@property (nonatomic, assign, readonly) NSInteger maxPan;
@property (nonatomic, assign, readonly) NSInteger minPan;

@property (nonatomic, assign, readonly) NSInteger maxZoom;
@property (nonatomic, assign, readonly) NSInteger minZoom;

@property (nonatomic, assign, readonly) NSInteger defaultTilt;
@property (nonatomic, assign, readonly) NSInteger defaultPan;
@property (nonatomic, assign, readonly) NSInteger defaultZoom;

+ (instancetype)fisheyeViewTypeDataWithType:(MHLumiFisheyeViewType)type mountType:(FEMOUNTTYPE)mountType dewrapType:(FEDEWARPTYPE)dewrapType;
- (void)updateWithZoom:(NSInteger)zoom;
@end
