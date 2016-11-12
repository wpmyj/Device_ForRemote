//
//  MiHLumiGLKViewController.m
//  MHome
//
//  Created by LM21Mac002 on 16/9/27.
//  Copyright © 2016年 小米科技. All rights reserved.
//

#import "MHLumiGLKViewController.h"
#import <OpenGLES/ES2/glext.h>
#import <CoreMedia/CMTime.h>
#import <CoreMedia/CMTimeRange.h>
#import "MHLumiFisheyeViewTypeData.h"

#define RAD_TO_DEG( rad ) ( (rad) * 57.29577951f )
#define RANG(A, max, min) (MIN(MAX(A,min),max))

static const float kMinimalConstant = 0.001;
static const float kMaximalPanConstant = 20;
static const float kMaximalTiltConstant = 10;
static const NSInteger kSampleCount = 5;
static const CGFloat kNoConstant = 0.8;
static const CGFloat kNuConstant = 0;
typedef NS_ENUM(NSUInteger, MHLumiFishBackWardActionType) {
    MHLumiFishBackWardActionTypeNot,
    MHLumiFishBackWardActionTypeUp,
    MHLumiFishBackWardActionTypeDown,
};

@interface MHLumiGLKViewController()
@property (nonatomic, strong)EAGLContext *context;
@property (nonatomic, assign)MHLumiFisheyeViewType currentViewType;
@property (nonatomic, strong)MHLumiFisheyeViewTypeData *currentViewData;
@property (nonatomic, strong)UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong)CADisplayLink  *displayLink;
@property (nonatomic, strong)NSMutableArray *pointYArray;
@property (nonatomic, strong)NSMutableArray *pointXArray;
@property (nonatomic, strong)NSMutableArray *timeStampArray;
@property (nonatomic, assign)MHLumiFishBackWardActionType backWardType;
@property (nonatomic, assign)CGFloat markPan;
@property (nonatomic, assign)CGFloat markTilt;
@property (nonatomic, assign)CGFloat markZoom;
@end

@implementation MHLumiGLKViewController{
    HANDLE          _hFECtx;
    FEOPTION        _tFEOption;
    CGPoint         _touchBegPoint;
    CGPoint         _touchEndPoint;
    BOOL            _touched;
    BOOL            _AssertFlag;
    BOOL            _hasInitedAndLoaded;
    CFTimeInterval  _lastTimeStamp;
    BOOL            _hasSetDefaultPanTiltZoom;
    CGFloat         _fDistanceX;
    CGFloat         _fDistanceY;
    CFTimeInterval  _deltaTime;
    CGFloat         _originVonX;
    CGFloat         _originVonY;
    CFTimeInterval  _startTime;
    CGFloat         _kNo;
    CGFloat         _minmalVonX;
    CGFloat         _backWardVonY;
}

- (instancetype)initWithDewrapType:(FEDEWARPTYPE)dewrapType
                         mountType:(FEMOUNTTYPE)mountType
                          viewType:(MHLumiFisheyeViewType)viewType{
    self = [super init];
    if (self){
        _dewrapType = dewrapType;
        _mountType = mountType;
        _AssertFlag = YES;
        _hasInitedAndLoaded = NO;
        _hasSetDefaultPanTiltZoom = NO;
        _motionControllerAble = NO;
        _currentViewType = viewType;
        _backWardType = MHLumiFishBackWardActionTypeNot;
        _currentViewData = [MHLumiFisheyeViewTypeData fisheyeViewTypeDataWithType:_currentViewType mountType:_mountType dewrapType:_dewrapType];
        _timeStampArray = [NSMutableArray arrayWithCapacity:kSampleCount];
        _pointXArray = [NSMutableArray arrayWithCapacity:kSampleCount];
        _pointYArray = [NSMutableArray arrayWithCapacity:kSampleCount];
        _centerPointOffsetR = 0;
        _centerPointOffsetX = 0;
        _centerPointOffsetY = 0;
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    NSAssert(_AssertFlag, @"请使用initWithDewrapType:dewrapType:mountType 初始化MHLumiGLKViewController");
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    self.preferredFramesPerSecond = 30;
    // Handle zoom control
    UIPinchGestureRecognizer *twoFingerPinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(touchesPinch:)];
    [self.view addGestureRecognizer:twoFingerPinch];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonAction:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    [EAGLContext setCurrentContext:self.context];
    
    [self setupFisheyeLibraryWithDewrapType:self.dewrapType mountType:self.mountType];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (_displayLink){
        [_displayLink invalidate];
        _displayLink = nil;
    }
}

- (void)buttonAction:(id )sender{
    float fPan = 0, fTilt = 0, fZoom = 0;
    Fisheye_GetPanTiltZoom(_hFECtx, &fPan, &fTilt, &fZoom);
    if (_currentViewType != MHLumiFisheyeViewTypeDefault){
        _currentViewType = MHLumiFisheyeViewTypeDefault;
        _currentViewData = [MHLumiFisheyeViewTypeData fisheyeViewTypeDataWithType:_currentViewType mountType:_mountType dewrapType:_dewrapType];
        Fisheye_SetPanTiltZoom(_hFECtx, FE_POSITION_ABSOLUTE, fPan, _currentViewData.defaultTilt, _currentViewData.defaultZoom);
    }else{
        _currentViewType = MHLumiFisheyeViewTypeA;
        _currentViewData = [MHLumiFisheyeViewTypeData fisheyeViewTypeDataWithType:_currentViewType mountType:_mountType dewrapType:_dewrapType];
        Fisheye_SetPanTiltZoom(_hFECtx, FE_POSITION_ABSOLUTE, fPan, _currentViewData.defaultTilt, _currentViewData.defaultZoom);
    }
    _touched = NO;
}

- (void)changeViewType:(MHLumiFisheyeViewType)type{
    float fPan = 0, fTilt = 0, fZoom = 0;
    Fisheye_GetPanTiltZoom(_hFECtx, &fPan, &fTilt, &fZoom);
    _currentViewType = type;
    _currentViewData = [MHLumiFisheyeViewTypeData fisheyeViewTypeDataWithType:_currentViewType mountType:_mountType dewrapType:_dewrapType];
    Fisheye_SetPanTiltZoom(_hFECtx, FE_POSITION_ABSOLUTE, fPan, _currentViewData.defaultTilt, _currentViewData.defaultZoom);
}

//-------------------------------------------------------------------
// Handle ePTZ controls
- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    // Only handle single touch
    if (event.allTouches.count >= 2)
    {
        return;
    }
    
    if (self.displayLink){
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    
    // Setup the begin position
    _touchBegPoint= [touches.anyObject locationInView:self.view];
    _touched = true;
    _lastTimeStamp = CACurrentMediaTime();
    [_timeStampArray removeAllObjects];
    [_timeStampArray addObject:@(_lastTimeStamp)];
    [_pointXArray removeAllObjects];
    [_pointXArray addObject:@(_touchBegPoint.x)];
    [_pointYArray removeAllObjects];
    [_pointYArray addObject:@(_touchBegPoint.y)];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_touched != true)
    {
        return;
    }
    
    // Get current touched position
    _touchEndPoint = [touches.anyObject locationInView:self.view];
    
    // Calculate the difference between begin position and current position
    float fDistanceX = _touchEndPoint.x - _touchBegPoint.x;
    float fDistanceY = _touchEndPoint.y - _touchBegPoint.y;
    [self setPanTiltZoomWithDx:fDistanceX fDistanceY:fDistanceY isDragOrNot:YES];
    [self addSampleDataWithTime:_lastTimeStamp fDistanceX:fDistanceX fDistanceY:fDistanceY];
    
    // Update points
    _touchBegPoint = _touchEndPoint;
    _lastTimeStamp = CACurrentMediaTime();
    
    float fPan = 0, fTilt = 0, fZoom = 0;
    Fisheye_GetPanTiltZoom(_hFECtx, &fPan, &fTilt, &fZoom);
    NSLog(@"fPan: %f",fPan);
    NSLog(@"fTilt: %f",fTilt);
    NSLog(@"fZoom: %f",fZoom);
    
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesEnded = %f",_lastTimeStamp - CACurrentMediaTime());
    [self addSampleDataWithTime:_lastTimeStamp
                     fDistanceX:_touchEndPoint.x - _touchBegPoint.x
                     fDistanceY:_touchEndPoint.y - _touchBegPoint.y];
    
    if (_timeStampArray.count >= 2 && self.displayLink == nil && !_motionControllerAble){
        //启动计时器
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(timerAction:)];
        self.displayLink.frameInterval = 60 / self.preferredFramesPerSecond;
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
        //从取样数组中计算初始速度
        _originVonX = 0;
        _originVonY = 0;
        CGFloat sumX = 0;
        float tt = [_timeStampArray.lastObject floatValue] - [_timeStampArray[0] floatValue];
        for (NSNumber *xobj in _pointXArray) {
            sumX += xobj.floatValue;
        }
        for (NSNumber *xobj in _pointYArray) {
            _originVonY += xobj.floatValue;
        }
        NSLog(@"Pan-V: %f, Tilt-V: %f",_originVonX/tt,_originVonY/tt);
        _originVonX = sumX/tt * (1.0/self.preferredFramesPerSecond)* 0.8;
        _originVonX = MAX(-kMaximalPanConstant, MIN(_originVonX, kMaximalPanConstant)) ;
        _originVonY = _originVonY/tt * (1.0/self.preferredFramesPerSecond)* 0.8;
        _originVonY = MAX(-kMaximalTiltConstant, MIN(_originVonY, kMaximalTiltConstant)) ;
        NSLog(@"dxrrrrrr = %f",_originVonX);
        NSLog(@"dyrrrrrr = %f",_originVonY);
        _startTime = CACurrentMediaTime();
        
        //计算最小维持速度
        if (fabs(sumX)/_pointXArray.count >= 3){
            _minmalVonX = 3;
        }else{
            _minmalVonX = 0;
        }
        
        //正态分布的标准差，取1就好
        _kNo = kNoConstant;// MIN(20/fabs(_originVonX)*kNoConstant, kNoConstant);
        NSLog(@"_kNorrrrrr = %f",_kNo);
        
        //处理回弹：
        //有无正的初速度（导致黑边的方向），弹簧效果
        //计算_backWardVonY回弹速度
        _backWardVonY = 0;
        _backWardType = MHLumiFishBackWardActionTypeNot;
        if (!_motionControllerAble){
            switch (_mountType) {
                case FE_MOUNT_FLOOR:{
                    switch (_currentViewType) {
                        case MHLumiFisheyeViewTypeA:{
                            float fPan = 0, fTilt = 0, fZoom = 0;
                            Fisheye_GetPanTiltZoom(_hFECtx, &fPan, &fTilt, &fZoom);
                            if (fTilt < _currentViewData.defaultTilt){
                                NSLog(@"需要处理回弹");
                                CGFloat vd = 0;
                                //系数
                                if (_currentViewData.maxTilt != _currentViewData.defaultTilt){
                                    vd = (_currentViewData.defaultTilt - fTilt) / (labs(_currentViewData.maxTilt) - labs(_currentViewData.defaultTilt));
                                }
                                _backWardVonY = 20 * vd * (fZoom /_currentViewData.defaultZoom); //根据系数求出速度
                                _backWardType = MHLumiFishBackWardActionTypeUp;
                            }else if(_originVonY < -kMinimalConstant){
                                _backWardType = MHLumiFishBackWardActionTypeDown;
                            }
                        }
                            break;
                        default:
                            break;
                    }
                }
                    break;
                case FE_MOUNT_CEILING:{
                    switch (_currentViewType) {
                        case MHLumiFisheyeViewTypeA:{
                            float fPan = 0, fTilt = 0, fZoom = 0;
                            Fisheye_GetPanTiltZoom(_hFECtx, &fPan, &fTilt, &fZoom);
                            if (fTilt > _currentViewData.defaultTilt){
                                NSLog(@"需要处理回弹");
                                CGFloat vd = 0;
                                //系数
                                if (_currentViewData.maxTilt != _currentViewData.defaultTilt){
                                    vd = (fabsf(fTilt) - labs(_currentViewData.defaultTilt) ) / (labs(_currentViewData.maxTilt) - labs(_currentViewData.defaultTilt));
                                }
                                _backWardVonY = 20 * vd * (fZoom /_currentViewData.defaultZoom); //根据系数求出速度
                                _backWardType = MHLumiFishBackWardActionTypeDown;
                            }else if(_originVonY > kMinimalConstant){
                                _backWardType = MHLumiFishBackWardActionTypeUp;
                            }
                        }
                            break;
                        default:
                            break;
                    }
                }
                    break;
                default:
                    break;
            }
            
        }
    }
    if ([self.dataSource respondsToSelector:@selector(needUpdateMarkPoint:)]){
        [self.dataSource needUpdateMarkPoint:self];
    }
    [self updateDataMarkPointWithPan:0 tilt:0];
    _touched = NO;
}


- (void)timerAction:(NSObject *)sender{
    CGFloat dx = CACurrentMediaTime() - _startTime;
    CGFloat dy = CACurrentMediaTime() - _startTime;
    CGFloat todoDx = 0;
    CGFloat todoDy = 0;
    dx = _originVonX/(1/(sqrt(2.0 * M_PI)*_kNo)) * exp(-(pow(dx-kNuConstant, 2)/(2*_kNo*_kNo)));
    dy = _originVonY/(1/(sqrt(2.0 * M_PI)*_kNo)) * exp(-(pow(dy-kNuConstant, 2)/(2*_kNo*_kNo)));
    if (_minmalVonX > 0 && fabs(dx) > 0){
        todoDx = MAX(_minmalVonX, fabs(dx)) * dx / fabs(dx); //取绝对值最大的，且符号不变
    }else if (_minmalVonX > 0){
        todoDx = _originVonX > 0 ? fabs(_minmalVonX) : (-fabs(_minmalVonX)) ;
    }else{
        todoDx = dx;
    }
    
    if (_dewrapType == FE_DEWARP_AROUNDVIEW){
        switch (_mountType) {
            case FE_MOUNT_FLOOR:
                if (_backWardType == MHLumiFishBackWardActionTypeUp) {
                    dy = _backWardVonY;
                }
                break;
            case FE_MOUNT_CEILING:
                if (_backWardType == MHLumiFishBackWardActionTypeDown) {
                    dy = -_backWardVonY;
                }
            default:
                break;
        }
    }else if (_dewrapType == FE_DEWARP_AERIALVIEW){
        switch (_mountType) {
            case FE_MOUNT_FLOOR:
                if (_backWardType == MHLumiFishBackWardActionTypeUp) {
                    dy = -_backWardVonY;
                }
                break;
            case FE_MOUNT_CEILING:
                if (_backWardType == MHLumiFishBackWardActionTypeDown) {
                    dy = _backWardVonY;
                }
            default:
                break;
        }
    }

//    NSLog(@"正态分布后dxr = %f",dx);
//    NSLog(@"正态分布后dyr = %f",dy);
//    NSLog(@"todo Dx = %f",todoDx);
//    NSLog(@"todo Dy = %f",todoDy);
    [self setPanTiltZoomWithDx:todoDx fDistanceY:dy isDragOrNot:NO];
    if (fabs(todoDx) <= kMinimalConstant && fabs(dy) <= kMinimalConstant){
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

- (void)addSampleDataWithTime: (CFTimeInterval)lastTimeStamp
                   fDistanceX: (CGFloat)fDistanceX
                   fDistanceY: (CGFloat)fDistanceY{
    if (_timeStampArray.count >= kSampleCount){
        [_timeStampArray removeObjectAtIndex:0];
        [_pointXArray removeObjectAtIndex:0];
        [_pointYArray removeObjectAtIndex:0];
    }
    [_timeStampArray addObject:@(lastTimeStamp)];
    [_pointXArray addObject:@(fDistanceX)];
    [_pointYArray addObject:@(fDistanceY)];
}

- (void)setPanTiltZoomWithRoll:(CGFloat)roll pitch:(CGFloat)pitch{
    if (_touched || !_motionControllerAble) {
        return;
    }
    float fPan = 0, fTilt = 0, fZoom = 0;
    Fisheye_GetPanTiltZoom(_hFECtx, &fPan, &fTilt, &fZoom);
    CGFloat todopan = 0, todoTilt = 0;
    todopan = roll;
    todoTilt = [self toRangeWithdMarkTilt:pitch maxTilt:_currentViewData.maxTilt minTilt:_currentViewData.minTilt];
    NSLog(@"pitch: %f -> todoTilt = %f",fTilt, todoTilt);
    NSLog(@"roll: %f -> todoPan = %f",roll, todopan);
    Fisheye_SetPanTiltZoom(_hFECtx, FE_POSITION_ABSOLUTE, _markPan + todopan, _markTilt + todoTilt, fZoom);
}

- (void)setPanTiltZoomWithDx:(CGFloat)fDistanceX fDistanceY:(CGFloat)fDistanceY isDragOrNot:(BOOL) yesOrNO{
    // Fluent control
    float fDeltaPan = 0;
    float fDeltaTilt = 0;
    float fWidthInView = (_tFEOption.OutRoi.Right - _tFEOption.OutRoi.Left) * self.view.frame.size.width / _tFEOption.OutVPicture.Width;
    float fHeightInView = (_tFEOption.OutRoi.Bottom - _tFEOption.OutRoi.Top) * self.view.frame.size.height / _tFEOption.OutVPicture.Height;
    
    if (FE_DEWARP_RECTILINEAR == _tFEOption.DewarpType)
    {
        float fPan = 0, fTilt = 0, fZoom = 0;
        Fisheye_GetPanTiltZoom(_hFECtx, &fPan, &fTilt, &fZoom);
        
        // Move right/left
        if (FE_MOUNT_WALL == _tFEOption.MountType)
        {
            float fAspectRatio = fWidthInView / fHeightInView;
            float fD1 = ((float)_touchBegPoint.x / fWidthInView * 2.0f - 1.0f) / fZoom * fAspectRatio;
            float fD2 = ((float)_touchEndPoint.x / fWidthInView * 2.0f - 1.0f) / fZoom * fAspectRatio;
            float fTheta1 = RAD_TO_DEG(atanf(fD1));
            float fTheta2 = RAD_TO_DEG(atanf(fD2));
            fDeltaPan = (fTheta2 - fTheta1);
        }
        else
        {
            fDeltaPan = RAD_TO_DEG(atanf(fDistanceX / (fWidthInView * 0.5 * fZoom)));
        }
        
        // Move up/down
        fDeltaTilt = RAD_TO_DEG(atanf(fDistanceY / (fHeightInView * 0.5 * fZoom)));
    }
    else if (FE_DEWARP_AERIALVIEW == _tFEOption.DewarpType)
    {
        float fPan = 0, fTilt = 0, fZoom = 0;
        Fisheye_GetPanTiltZoom(_hFECtx, &fPan, &fTilt, &fZoom);
        
        // Move right/left
        if (FE_MOUNT_WALL == _tFEOption.MountType)
        {
            float fAspectRatio = fWidthInView / fHeightInView;
            float fD1 = ((float)_touchBegPoint.x / fWidthInView * 2.0f - 1.0f) / fZoom * fAspectRatio;
            float fD2 = ((float)_touchEndPoint.x / fWidthInView * 2.0f - 1.0f) / fZoom * fAspectRatio;
            float fTheta1 = RAD_TO_DEG(atanf(fD1));
            float fTheta2 = RAD_TO_DEG(atanf(fD2));
            fDeltaPan = (fTheta2 - fTheta1);
        }
        else
        {
            fDeltaPan = RAD_TO_DEG(atanf(fDistanceX / (fWidthInView * 0.5 * fZoom)));
        }
        
        // Move up/down
        fDeltaTilt = RAD_TO_DEG(atanf(fDistanceY / (fHeightInView * 0.5 * fZoom)));
    }
    else if (FE_DEWARP_AROUNDVIEW == _tFEOption.DewarpType)
    {
        float fPan = 0, fTilt = 0, fZoom = 0;
        Fisheye_GetPanTiltZoom(_hFECtx, &fPan, &fTilt, &fZoom);
        
        // Move right/left
        if (FE_MOUNT_WALL == _tFEOption.MountType)
        {
            float fAspectRatio = fWidthInView / fHeightInView;
            float fD1 = ((float)_touchBegPoint.x / fWidthInView * 2.0f - 1.0f) / fZoom * fAspectRatio;
            float fD2 = ((float)_touchEndPoint.x / fWidthInView * 2.0f - 1.0f) / fZoom * fAspectRatio;
            float fTheta1 = RAD_TO_DEG(atanf(fD1));
            float fTheta2 = RAD_TO_DEG(atanf(fD2));
            fDeltaPan = (fTheta2 - fTheta1);
        }
        else
        {
            fDeltaPan = RAD_TO_DEG(atanf(fDistanceX / (fWidthInView * 0.5 * fZoom)));
        }
        
        // Move up/down
        fDeltaTilt = RAD_TO_DEG(atanf(fDistanceY / (fHeightInView * 0.5 * fZoom)));
    }
    else if (FE_DEWARP_FULLVIEWPANORAMA == _tFEOption.DewarpType)
    {
        fDeltaPan = fDistanceX / fWidthInView * 360.0f;
    }
    else if (FE_DEWARP_DUALVIEWPANORAMA == _tFEOption.DewarpType)
    {
        fDeltaPan = fDistanceX / fWidthInView * 180.0f;
    }
    
    
    //不是手滑且方向需要矫正（floor是向上，ceiling是向下）
    if (!yesOrNO && fabs(fDeltaTilt) > kMinimalConstant && _backWardType != MHLumiFishBackWardActionTypeNot){
        switch (_mountType) {
            case FE_MOUNT_FLOOR:{
                BOOL upOrDown = !(_backWardType == MHLumiFishBackWardActionTypeDown);
                fDeltaTilt = [self tiltToBoundary:fDeltaTilt
                                     boundaryTilt:_currentViewData.defaultTilt
                                         upOrDown:upOrDown];
//                BOOL upOrDown = _backWardType == MHLumiFishBackWardActionTypeUp;
//                fDeltaTilt = [self tiltToBoundary:fDeltaTilt
//                                     boundaryTilt:_currentViewData.defaultTilt
//                                         upOrDown:upOrDown];
            }
                break;
            case FE_MOUNT_CEILING:{
                BOOL upOrDown = !(_backWardType == MHLumiFishBackWardActionTypeDown);
                fDeltaTilt = [self tiltToBoundary:fDeltaTilt
                                     boundaryTilt:_currentViewData.defaultTilt
                                         upOrDown:upOrDown];
            }
                
            default:
                break;
        }
//        BOOL upOrDown = _backWardType == MHLumiFishBackWardActionTypeUp;
//        fDeltaTilt = [self tiltToBoundary:fDeltaTilt
//                             boundaryTilt:_currentViewData.defaultTilt
//                                 upOrDown:upOrDown];
    }
    fDeltaTilt = [self toRangeWithdTilt:fDeltaTilt maxTilt:_currentViewData.maxTilt minTilt:_currentViewData.minTilt];
    Fisheye_SetPanTiltZoom(_hFECtx, FE_POSITION_RELATIVE, -fDeltaPan, fDeltaTilt, 0);
    
//    NSLog(@"fDeltaPan: %f,fDeltaTilt: %f",-fDeltaPan, fDeltaTilt);
    
}

//- (void)panAction:(UIPanGestureRecognizer *)pan{
//    switch (pan.state) {
//        case UIGestureRecognizerStateBegan:
//            NSLog(@"触摸开始");
//            _touchBegPoint = [pan locationInView:self.view];
//            _lastTimeStamp = CACurrentMediaTime();
//            if (self.displayLink){
//                [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
//                [self.displayLink invalidate];
//            }
//            break;
//        case UIGestureRecognizerStateChanged:
//            NSLog(@"触摸change");
//            _touchEndPoint = [pan locationInView:self.view];
//            _lastTimeStamp = CACurrentMediaTime();
//            break;
//        case UIGestureRecognizerStateEnded:
//        case UIGestureRecognizerStateCancelled:
//            NSLog(@"触摸结束");
//            _touchEndPoint = [pan locationInView:self.view];
//            _lastTimeStamp = CACurrentMediaTime();
////            CFTimeInterval deltaTime = CACurrentMediaTime() - _lastTimeStamp;
////            CGFloat dx = _touchEndPoint.x - _touchBegPoint.x;
////            CGFloat dy = _touchEndPoint.y - _touchBegPoint.y;
////            CGFloat xv = dx / deltaTime;
////            CGFloat yv = dy / deltaTime;
////            NSLog(@"dx: %f  dy; %f",dx,dy);
//            break;
//        default:
//            break;
//    }
//    CGPoint distance = [pan velocityInView:self.view];
//    _fDistanceX = _touchEndPoint.x - _touchBegPoint.x;//distance.x / 30.0;
//    _fDistanceY = _touchEndPoint.y - _touchBegPoint.y;//distance.y / 30.0;
//    NSLog(@"fDistanceX: %f  fDistanceY; %f",_fDistanceX,_fDistanceY);
//    _deltaTime = CACurrentMediaTime() - _lastTimeStamp;
//    NSLog(@"deltaTime: %f",_deltaTime);
//
//    [self setPanTiltZoomWithDx:_fDistanceX fDistanceY:_fDistanceY];
////    if (pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateEnded){
////        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(timerAction:)];
////        self.displayLink.frameInterval = 2;
////        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
////    }
//}
//
//- (void)timerAction:(NSObject *)sender{
//    static CFTimeInterval tt = 0;
//    NSLog(@"tt = %f",tt - CACurrentMediaTime());
//    tt = CACurrentMediaTime();
//    CGFloat todoDx = tt/_deltaTime * _fDistanceX;
//    CGFloat todoDy = tt/_deltaTime * _fDistanceY;
//    [self setPanTiltZoomWithDx:todoDx fDistanceY:todoDy];
//}
//
//- (void)setPanTiltZoomWithDx:(CGFloat)fDistanceX fDistanceY:(CGFloat)fDistanceY{
//    // Fluent control
//    float fDeltaPan = 0;
//    float fDeltaTilt = 0;
//    float fWidthInView = (_tFEOption.OutRoi.Right - _tFEOption.OutRoi.Left) * self.view.frame.size.width / _tFEOption.OutVPicture.Width;
//    float fHeightInView = (_tFEOption.OutRoi.Bottom - _tFEOption.OutRoi.Top) * self.view.frame.size.height / _tFEOption.OutVPicture.Height;
//
//    if (FE_DEWARP_RECTILINEAR == _tFEOption.DewarpType || FE_DEWARP_AROUNDVIEW == _tFEOption.DewarpType)
//    {
//        float fPan = 0, fTilt = 0, fZoom = 0;
//        Fisheye_GetPanTiltZoom(_hFECtx, &fPan, &fTilt, &fZoom);
//        //        NSLog(@"MMMMMMMMMMMMMMMMMMMMMMM");
//        //        NSLog(@"fPan = %f",fPan);
//        //        NSLog(@"fTilt = %f",fTilt);
//        //        NSLog(@"fZoom = %f",fZoom);
//        // Move right/left
//        if (FE_MOUNT_WALL == _tFEOption.MountType)
//        {
//            float fAspectRatio = fWidthInView / fHeightInView;
//            float fD1 = ((float)_touchBegPoint.x / fWidthInView * 2.0f - 1.0f) / fZoom * fAspectRatio;
//            float fD2 = ((float)_touchEndPoint.x / fWidthInView * 2.0f - 1.0f) / fZoom * fAspectRatio;
//            float fTheta1 = RAD_TO_DEG(atanf(fD1));
//            float fTheta2 = RAD_TO_DEG(atanf(fD2));
//            fDeltaPan = (fTheta2 - fTheta1);
//        }
//        else
//        {
//            fDeltaPan = RAD_TO_DEG(atanf(fDistanceX / (fWidthInView * 0.5 * fZoom)));
//        }
//
//        // Move up/down
//        fDeltaTilt = RAD_TO_DEG(atanf(fDistanceY / (fHeightInView * 0.5 * fZoom)));
//    }
//    else if (FE_DEWARP_FULLVIEWPANORAMA == _tFEOption.DewarpType)
//    {
//        fDeltaPan = fDistanceX / fWidthInView * 360.0f;
//    }
//    else if (FE_DEWARP_DUALVIEWPANORAMA == _tFEOption.DewarpType)
//    {
//        fDeltaPan = fDistanceX / fWidthInView * 180.0f;
//    }
//    //        else if (FE_DEWARP_AROUNDVIEW == _tFEOption.DewarpType)
//    //        {
//    //            fDeltaPan = fDistanceX;
//    //            fDeltaTilt = fDistanceY;
//    //        }
//
//    fDeltaTilt = [self toRangeWithdTilt:fDeltaTilt maxTilt:_maxTilt minTilt:_minTilt];
//    //    fDeltaPan = [self toRangeWithdPan:fDeltaPan maxPan:_maxPan minPan:_minPan];
//    //    NSLog(@"============================");
//    //    NSLog(@"fDeltaPan(x): %f",-fDeltaPan);
//    //    NSLog(@"fDeltaTilt(y): %f",fDeltaTilt);
//    //    NSLog(@"============================");
//    Fisheye_SetPanTiltZoom(_hFECtx, FE_POSITION_RELATIVE, -fDeltaPan, fDeltaTilt, 0);
//    float fPan = 0, fTilt = 0, fZoom = 0;
//    Fisheye_GetPanTiltZoom(_hFECtx, &fPan, &fTilt, &fZoom);
//    //    NSLog(@"fPan = %f",fPan);
//    //    NSLog(@"fTilt = %f",fTilt);
//    //    NSLog(@"fZoom = %f",fZoom);
//    //    NSLog(@"MMMMMMMMMMMMMMMMMMMMMMM");
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
    
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    if (_displayLink){
        [_displayLink invalidate];
        _displayLink = nil;
    }
}


- (void)setupFisheyeLibraryWithDewrapType:(FEDEWARPTYPE)dewrapType mountType:(FEMOUNTTYPE)mountType{
    
    // Initial fisheye library
    SCODE scRet = Fisheye_Initial(&_hFECtx, LIBFISHEYE_VERSION);
    if (scRet != FISHEYE_S_OK)
    {
        NSLog(@"Fisheye_Initial Failed. (%lx)", scRet);
    }
    
    // Set fisheye options
    [self setDewarpType:dewrapType];
    [self setMountType:mountType];
    
    Fisheye_SetPanTiltZoom(_hFECtx, FE_POSITION_ABSOLUTE, 0, 0, 1);
    
}

//FEMOUNTTYPE : This enumeration specifies the mount type of the installed fisheye camera.
- (void) setMountType:(FEMOUNTTYPE) mount
{
    _tFEOption.MountType = mount;
    _tFEOption.Flags = FE_OPTION_MOUNTTYPE;
    Fisheye_SetOption(_hFECtx, &_tFEOption);
}

//FEDEWARPTYPE : This enumeration specifies the dewarp type.
- (void) setDewarpType:(FEDEWARPTYPE) dewarpType
{
    _tFEOption.DewarpType = dewarpType;
    _tFEOption.Flags = FE_OPTION_DEWARPTYPE;
    Fisheye_SetOption(_hFECtx, &_tFEOption);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    // Release YUV buffer
    if (_tFEOption.InVPicture.Buffer)
    {
        free(_tFEOption.InVPicture.Buffer);
        _tFEOption.InVPicture.Buffer = NULL;
    }
    
    // Release fisheye library
    if (_hFECtx)
    {
        Fisheye_Release(&_hFECtx);
        _hFECtx = NULL;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    // Clear framebuffer
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
//    NSLog(@"AAAAAAAAA%f",CACurrentMediaTime()-_lastTimeStamp);
    _lastTimeStamp = CACurrentMediaTime();
    if (!self.dataSource) { return; }
    
    if ([self.dataSource shouldUpdateBuffer:self]){
        MHLumiGLKViewData data = [self.dataSource fetchBufferData:self];
        [self handleFisheyeInput:data.width height:data.height buffer:data.buffer];
    }
    
    // Update draw location
    [self handleDrawLocation:view];
    
    if (!_hasInitedAndLoaded){return;}
    
    if (!_hasSetDefaultPanTiltZoom){
        _hasSetDefaultPanTiltZoom = YES;
        Fisheye_SetPanTiltZoom(_hFECtx, FE_POSITION_ABSOLUTE, _currentViewData.defaultPan, _currentViewData.defaultTilt, _currentViewData.defaultZoom);
    }
    
    // Draw dewarped scense
    SCODE scRet = Fisheye_OneFrame(_hFECtx);
    if (scRet != FISHEYE_S_OK)
    {
        NSLog(@"Fisheye_OneFrame Failed. (%lx)\n", scRet);
    }
}


- (void)handleFisheyeInput:(unsigned int)width height:(unsigned int)height buffer:(const void *)buffer
{
    [self setupFisheyeOptionWithWidth:width height:height];
    
    if (_tFEOption.InVPicture.Buffer != (BYTE*)buffer && buffer != NULL)
    {
        //      NSLog(@"载入新图像");
        //载入新图像
        size_t size = width * height * 1.5;
        BYTE *todoBuffer = malloc(size);
        BYTE *oldBuffer = _tFEOption.InVPicture.Buffer;
        memcpy(todoBuffer, buffer, size);
        _tFEOption.InVPicture.Buffer = (BYTE*)todoBuffer;
        _tFEOption.Flags = (FE_OPTION_INIMAGEBUFFER);
        Fisheye_SetOption(_hFECtx, &_tFEOption);
        _hasInitedAndLoaded = YES;
        free(oldBuffer);
    }
}

- (void)setupFisheyeOptionWithWidth:(unsigned int)width height:(unsigned int)height{
    // Update InVPicture header
    if (_tFEOption.InVPicture.Width != width || _tFEOption.InVPicture.Height != height || _tFEOption.InVPicture.Format != FE_PIXELFORMAT_YUV420P)
    {
        NSLog(@"change _tFEOption");
        // Set input image information
        _tFEOption.InVPicture.Width = width;
        _tFEOption.InVPicture.Height = height;
        _tFEOption.InVPicture.Stride = width;
        _tFEOption.InVPicture.Format = FE_PIXELFORMAT_YUV420P;
        
        // Set center and radius
        _tFEOption.FOVCenter.X = (_tFEOption.InVPicture.Width >> 1) + _centerPointOffsetX;//28
        _tFEOption.FOVCenter.Y = (_tFEOption.InVPicture.Height >> 1) + _centerPointOffsetY;//5
        _tFEOption.FOVRadius = (_tFEOption.InVPicture.Width >> 1) + _centerPointOffsetR;//-80
        
        // Update parameters in fisheye library
        _tFEOption.Flags = (FE_OPTION_INIMAGEHEADER | FE_OPTION_FOVCENTER | FE_OPTION_FOVRADIUS);
        Fisheye_SetOption(_hFECtx, &_tFEOption);
    }
}

- (void) handleDrawLocation:(GLKView *)view
{
    unsigned int drawableWidth = (unsigned int)view.drawableWidth;
    unsigned int drawableHeight = (unsigned int)view.drawableHeight;
    
    if (_tFEOption.OutVPicture.Width != drawableWidth || _tFEOption.OutVPicture.Height != drawableHeight)
    {
        _tFEOption.OutVPicture.Width = drawableWidth;
        _tFEOption.OutVPicture.Height = drawableHeight;
        _tFEOption.OutVPicture.Format = FE_PIXELFORMAT_RGB32;
        
        _tFEOption.OutRoi.Left      = 0;
        _tFEOption.OutRoi.Top       = 0;
        _tFEOption.OutRoi.Right     = _tFEOption.OutVPicture.Width;
        _tFEOption.OutRoi.Bottom    = _tFEOption.OutVPicture.Height;
        
        _tFEOption.Flags = (FE_OPTION_OUTIMAGEHEADER | FE_OPTION_OUTROI);
        Fisheye_SetOption(_hFECtx, &_tFEOption);
    }
}

#pragma mark - 手势

- (void)touchesPinch:(UIPinchGestureRecognizer *)recognizer
{
    // Zoom in/out
    //recognizer.velocity /8.0 ,缩放速度
    CGFloat scale = recognizer.velocity/15.0;
    scale = [self toRangeWithdZoom:scale maxZoom:_currentViewData.maxZoom minZoom:_currentViewData.minZoom];
    Fisheye_SetPanTiltZoom(_hFECtx, FE_POSITION_RELATIVE, 0, 0, scale);
    [_currentViewData updateWithZoom:[self currentFZoom]];
    _touched = NO;
}

#pragma mark - getter and setter

- (void)setMotionControllerAble:(BOOL)motionControllerAble{
    _motionControllerAble = motionControllerAble;
    if (_motionControllerAble == YES && _displayLink){
        [_displayLink invalidate];
        _displayLink = nil;
    }
}

- (float)currentFZoom{
    float fPan = 0, fTilt = 0, fZoom = 0;
    Fisheye_GetPanTiltZoom(_hFECtx, &fPan, &fTilt, &fZoom);
    return fZoom;
}

- (float)toRangeWithdMarkTilt:(float)dValue maxTilt:(float)maxTilt minTilt:(float)minTilt{
    if ((_markTilt + dValue) < minTilt){
        return (minTilt - _markTilt);
    }
    
    if ((_markTilt + dValue) > maxTilt){
        return (maxTilt - _markTilt);
    }
    
    return dValue;
}

- (float)toRangeWithdTilt:(float)dValue maxTilt:(float)maxTilt minTilt:(float)minTilt{
    float fPan = 0, fTilt = 0, fZoom = 0;
    Fisheye_GetPanTiltZoom(_hFECtx, &fPan, &fTilt, &fZoom);
    if ((fTilt + dValue) < minTilt){
        return (minTilt - fTilt);
    }
    
    if ((fTilt + dValue) > maxTilt){
        return (maxTilt - fTilt);
    }
    
    return dValue;
}

- (float)tiltToBoundary:(float)dValue boundaryTilt:(float)boundaryTilt upOrDown:(bool) flag{
    float fPan = 0, fTilt = 0, fZoom = 0;
    Fisheye_GetPanTiltZoom(_hFECtx, &fPan, &fTilt, &fZoom);
    if (flag){
        if ((fTilt + dValue) > boundaryTilt){
            return (boundaryTilt - fTilt);
        }
    }else{
        if ((fTilt + dValue) < boundaryTilt){
            return (boundaryTilt - fTilt);
        }
    }
    
    return dValue;
}

- (float)toRangeWithdMarkPan:(float)dValue maxPan:(float)maxPan minPan:(float)minPan{
    if ((_markPan - dValue) < minPan){
        return -(minPan - _markPan);
    }
    
    if ((_markPan - dValue) > maxPan){
        return -(maxPan - _markPan);
    }
    return dValue;
}

- (float)toRangeWithdPan:(float)dValue maxPan:(float)maxPan minPan:(float)minPan{
    float fPan = 0, fTilt = 0, fZoom = 0;
    Fisheye_GetPanTiltZoom(_hFECtx, &fPan, &fTilt, &fZoom);
    if ((fPan - dValue) < minPan){
        return -(minPan - fPan);
    }
    
    if ((fPan - dValue) > maxPan){
        return -(maxPan - fPan);
    }
    return dValue;
}

- (float)toRangeWithdZoom:(float)dValue maxZoom:(float)maxZoom minZoom:(float)minZoom{
    float fPan = 0, fTilt = 0, fZoom = 0;
    Fisheye_GetPanTiltZoom(_hFECtx, &fPan, &fTilt, &fZoom);
    if ((fZoom + dValue) < minZoom){
        return (minZoom - fZoom);
    }
    
    if ((fZoom + dValue) > maxZoom){
        return (maxZoom - fZoom);
    }
    return dValue;
}

- (void)updateDataMarkPointWithPan:(CGFloat)pan tilt:(CGFloat)tilt{
    float fPan = 0, fTilt = 0, fZoom = 0;
    Fisheye_GetPanTiltZoom(_hFECtx, &fPan, &fTilt, &fZoom);
    _markTilt = fTilt;
    _markPan = fPan;
}
@end
