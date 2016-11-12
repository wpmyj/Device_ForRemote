//
//  MHLumiGLKViewController.h
//  SFFmpegIOSDecoder
//
//  Created by LM21Mac002 on 16/9/27.
//  Copyright © 2016年 Lei Xiaohua. All rights reserved.
//

#import <GLKit/GLKit.h>
#include "fisheye.h"
#include "fisheye_opengl.h"
#include "fisheye_errordef.h"
#import "MHLumiFisheyeHeader.h"

typedef struct MHLumiGLKViewData
{
    /* Header field */
    unsigned int    width;    // Width
    unsigned int    height;   // Height
    /* Buffer field */
    const void      *buffer;  // Buffer
}MHLumiGLKViewData;

@class MHLumiGLKViewController;
@protocol MHLumiGLKViewControllerDataSource <NSObject>

- (MHLumiGLKViewData)fetchBufferData:(MHLumiGLKViewController *)glkViewController;

- (bool)shouldUpdateBuffer:(MHLumiGLKViewController *)glkViewController;

@optional
- (void)needUpdateMarkPoint:(MHLumiGLKViewController *)glkViewController;
@end

@interface MHLumiGLKViewController : GLKViewController
@property (nonatomic, weak) id<MHLumiGLKViewControllerDataSource> dataSource;
@property (nonatomic, assign, readonly) FEDEWARPTYPE dewrapType;
@property (nonatomic, assign, readonly) FEMOUNTTYPE mountType;
@property (nonatomic, assign, readonly) MHLumiFisheyeViewType currentViewType;
@property (nonatomic, assign) BOOL motionControllerAble;
@property (nonatomic, assign) CGFloat centerPointOffsetX;
@property (nonatomic, assign) CGFloat centerPointOffsetY;
@property (nonatomic, assign) CGFloat centerPointOffsetR;


- (instancetype)initWithDewrapType:(FEDEWARPTYPE)dewrapType mountType:(FEMOUNTTYPE)mountType viewType:(MHLumiFisheyeViewType)viewType;

//pitch:0~360
//roll:0~360
- (void)setPanTiltZoomWithRoll:(CGFloat)roll pitch:(CGFloat)pitch;
- (void)updateDataMarkPointWithPan:(CGFloat) pan tilt:(CGFloat) tilt;
- (void)changeViewType:(MHLumiFisheyeViewType)type;
@end
