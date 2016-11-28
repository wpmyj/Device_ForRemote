 //
//  MHLumiUICameraHomeViewController.m
//  MiHome
//
//  Created by LM21Mac002 on 16/10/19.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiUICameraHomeViewController.h"
#import "MHLumiUITool.h"
#import "MHWeakTimerFactory.h"
#import "MHColorUtils.h"
#import "MHMusicTipsView.h"
#import <math.h>
#import "MHLumiCameraTimeLineView.h"
#import "NSDateFormatter+lumiDateFormatterHelper.h"
#import "MHLumiTUTKClient.h"
#import <ffmpegWrapper/MHVideoFrameYUV.h>
#import <ffmpegWrapper/MHEAGLView.h>
#import "MHLumiLocalCachePathHelper.h"
#import "MHLumiMuxer.h"
#import "MHLumiAudioPlayer.h"
#import "MHLumiRecorder2.h"
#import "NSDate+lumiDateHelper.h"
#import <Photos/Photos.h>
#import "MHLumiNeAACDecoder.h"
#import "MHLumiCameraMediaDataManager.h"
#import "MHLumiCameraPhotosViewController.h"
#import "MHLumiGLKViewController.h"
#import "MHLumiYUVBufferHelper.h"
#import "libavformat/avformat.h"
#import "libavformat/avio.h"
#import "MHLumiAACEncoder.h"
#import "MHLumiLocalCacheManager.h"
#import "MHLumiUICameraHomeSettingViewController.h"

typedef NS_ENUM(NSInteger, MHLumiUICameraHomeViewControllerStatus) {
    MHLumiUICameraHomeViewControllerStatusNormal       = 0,
    MHLumiUICameraHomeViewControllerStatusRecording,
    MHLumiUICameraHomeViewControllerStatusWithoutControlPaner,
    MHLumiUICameraHomeViewControllerStatusGuide,
    MHLumiUICameraHomeViewControllerStatusNoNet,
    MHLumiUICameraHomeViewControllerStatusLoading,
    MHLumiUICameraHomeViewControllerStatusWaitLiveLoading,
    MHLumiUICameraHomeViewControllerStatusWaitBackwardLoading,
    MHLumiUICameraHomeViewControllerStatusBackward,
};
//AudioRecorderDelegate
@interface MHLumiUICameraHomeViewController()<MHLumiCameraTimeLineViewDelegate,MHLumiTUTKClientDelegate,MHLumiGLKViewControllerDataSource,MHLumiRecorder2Delegate,MHLumiUICameraHomeSettingViewControllerDelegate>
/**
 *  图库按钮
 */
@property (nonatomic, strong) UIButton *previewButton;

/**
 *  录像按钮
 */
@property (nonatomic, strong) UIButton *recordButton;

/**
 *  截图按钮
 */
@property (nonatomic, strong) UIButton *photoButton;

/**
 *  对讲按钮
 */
@property (nonatomic, strong) UIButton *talkbackButton;

/**
 *  体感控制
 */
@property (nonatomic, strong) UIButton *motionButton;

/**
 *  静音按钮
 */
@property (nonatomic, strong) UIButton *muteButton;

/**
 *  四分屏
 */
@property (nonatomic, strong) UIButton *fourRButton;

/**
 *  横屏
 */
@property (nonatomic, strong) UIButton *rotationButton;

/**
 *  视频清晰度
 */
@property (nonatomic, strong) UIButton *qualityButton;

/**
 *  全屏下的返回按鈕
 */
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) MHDeviceCamera *cameraDevice;
@property (nonatomic, strong) MHLumiNeAACDecoder *lumiNeAACDecoder;
@property (nonatomic, strong) UIView *controlPanelContanerView;//toolbar不在上面
@property (nonatomic, strong) UIView *buttonsContanerView;
@property (nonatomic, strong) MHLumiCameraTimeLineView *timeLineView;
@property (nonatomic, strong) UIView *qualityOpitionView;
@property (nonatomic, strong) NSMutableArray *mainButtonArray; //大的那种控制按钮
@property (nonatomic, strong) NSMutableArray *subButtonArray; //小的那种控制按钮
@property (nonatomic, strong) UIButton *recordingButton;
@property (nonatomic, strong) UIView *noNetView;
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) UILabel *loadingTipsLabel;
@property (nonatomic, strong) UILabel *recordingTimeLabel;
@property (nonatomic, strong) NSTimer *recordingTimer;
@property (nonatomic, assign) int logTimeNum;
@property (nonatomic, assign) MHLumiUICameraHomeViewControllerStatus viewStatus;
@property (nonatomic, assign) MHLumiUICameraHomeViewControllerStatus preViewStatus;

@property (nonatomic, assign) CGFloat radio_W_h;
@property (nonatomic, strong) NSArray <NSString *> *opitionTitles;
@property (nonatomic, assign) CGRect rectForVideoView;
@property (nonatomic, assign) BOOL isHiddenControlPanel;

@property (nonatomic, strong) MHLumiTUTKClient *lumiTUTKClient;
@property (nonatomic, strong) PHAssetCollection *lumiCameraAssetCollection;

@property (nonatomic, copy) NSString *h264Filename_V;
@property (nonatomic, strong) NSFileHandle *h264FileHandle;
@property (nonatomic, copy) NSString *aacFilename_A;
@property (nonatomic, strong) NSFileHandle *aacFileHandle;

@property (nonatomic, strong) MHLumiAudioPlayer *audioPlayer;
@property (nonatomic, strong) MHLumiRecorder2 *lumiRecorder;
@property (nonatomic, assign) CGSize videoDataSize;
@property (nonatomic, strong) NSDate *cameraCurrentDate;
@property (nonatomic, strong) MHLumiGLKViewController *glkViewController;
@property (nonatomic, strong) NSData *yuvData;
@property (nonatomic, assign) BOOL shouldUpdate;
@property (nonatomic, strong) dispatch_group_t cameraGroup;
@property (nonatomic, strong) UITapGestureRecognizer *viewTap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapOnGLK;
@property (nonatomic, strong) MHLumiAACEncoder *aacEncoder;
@property (nonatomic, assign, getter=isTimeLineDraging) BOOL timeLineDraging;
//test
@property (nonatomic, strong) NSFileHandle *pcmFileHandle;
@property (nonatomic, strong) NSMutableArray <NSData *>*aaaaaada;

//timeLineView指针的更新和可回看区域，timeLineView的总区域的更新
@property (nonatomic, strong) NSTimer *timerForTimeLineView;
//记录时间点，算偏移
@property (nonatomic, assign) NSTimeInterval markForTimer;
//手机时间和摄像头时间的同步
@property (nonatomic, assign) NSTimeInterval deltaTime_Camera_Sys; //sys + delta = camera
//声音的本地记录
@property (nonatomic, assign) BOOL logForMute;
@property (nonatomic, strong) MHLumiLocalCacheManager *cacheManager;
@property (nonatomic, copy) NSString *kCameraMuteKey;
@property (nonatomic, assign) BOOL isInitCamera;

//回放时顶部显示的label
@property (nonatomic, strong) UILabel *backwardTimeLabel;
@property (nonatomic, strong) NSTimer *backwardTimer; //用于刷新的回放时的时间
@property (nonatomic, strong) NSDate *backwardLogDate; //记录回放时的时间

//记录滑动前的时间
@property (nonatomic, strong) NSDate *dateLogForWillDrag;
@end

@implementation MHLumiUICameraHomeViewController{
    AVFrame *_todoFrame;
    LumiTUTKFrameInfo _todoFrameInfo;
}
static CGFloat kButtonsContanerViewHeight = 80;
static CGFloat kTimeLineViewHeight = 60;
static CGFloat kButtonHeight = 95;
static CGFloat kRecordingTimeLabelHeight = 38;
static CGFloat kControlPanelContanerView = 45;
- (id)initWithDevice:(MHDevice *)device{
    self = [super initWithDevice:device];
    if (self){
        _cameraDevice = (MHDeviceCamera*)device;
        _videoDataSize = CGSizeZero;
        _shouldUpdate = NO;
        _todoFrame = avcodec_alloc_frame();
        _timeLineDraging = NO;
        _deltaTime_Camera_Sys = 0;
        _isInitCamera = NO;
        
        _kCameraMuteKey = [NSString stringWithFormat:@"%@_CameraMute",_cameraDevice.did];
        _cacheManager = [[MHLumiLocalCacheManager alloc] initWithType:MHLumiLocalCacheManagerCommon andIdentifier:[MHPassportManager sharedSingleton].currentAccount.userId];
        NSNumber *cameraMuteNum = (NSNumber *)[_cacheManager objectForKey:_kCameraMuteKey];
        if (cameraMuteNum){
            _logForMute = NO;//cameraMuteNum.boolValue;
        }else{
            _logForMute = NO;
        }
    }
    return self;
}

- (instancetype)initWithCameraDevice:(MHDeviceCamera *)device{
    return [self initWithDevice:device];
}

- (void)dealloc{
    NSLog(@"%@ VC开始析构",self.description);
    [_timerForTimeLineView invalidate];
    _timerForTimeLineView = nil;
    [_recordingTimer invalidate];
    _recordingTimer = nil;
    [_backwardTimer invalidate];
    _backwardTimer = nil;
    _shouldUpdate = NO;
    _lumiTUTKClient.canceled = YES;
    [_audioPlayer stopPlay];
    [_audioPlayer reset];
    [_lumiTUTKClient deinitConnection];
    avcodec_free_frame(&_todoFrame);
    NSLog(@"%@ VC析构了",self.description);
}

- (void)onBack{
    _glkViewController.dataSource = nil;
    _glkViewController.delegate = nil;
    _lumiTUTKClient.canceled = YES;
    [_audioPlayer stopPlay];
    [_audioPlayer reset];
}

#pragma mark - view life cycle
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.isTabBarHidden = YES;
    self.logTimeNum = 0;
    self.viewStatus = MHLumiUICameraHomeViewControllerStatusNormal;
    _radio_W_h = 16.0/9.0;
    _isHiddenControlPanel = NO;
    [self initCamera];
}


- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self updateVideoViewFrame];
    CGFloat viewWidth = CGRectGetWidth(self.view.bounds);
    CGFloat viewHeight = CGRectGetHeight(self.view.bounds);
    CGFloat labelY = self.navigationController.navigationBarHidden ? 18 : 64 + 18;
    CGFloat labelY2 = self.navigationController.navigationBarHidden ? 0 : 64;
    self.recordingTimeLabel.frame = CGRectMake(0, labelY, viewWidth, kRecordingTimeLabelHeight);
    if (self.glkViewController.view.superview){
        labelY2 = CGRectGetMinY(self.glkViewController.view.frame);
    }
    self.backwardTimeLabel.frame = CGRectMake(0, labelY2, viewWidth, kRecordingTimeLabelHeight);
    //针对横屏竖屏处理
    if ([self isLandscapeRight]){
        self.recordingButton.frame = CGRectMake(viewWidth - kButtonHeight - 10, (viewHeight-kButtonHeight)/2, kButtonHeight, kButtonHeight);
        self.backButton.frame = CGRectMake(0, 0, 50, 50);
    }else{
        self.recordingButton.frame = CGRectMake((viewWidth - kButtonHeight)/2, viewHeight-kButtonHeight, kButtonHeight, kButtonHeight);
    }
    
    if (self.noNetView.superview){
        self.noNetView.frame = self.view.bounds;
        self.noNetView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    if (self.loadingView.superview){
        self.loadingView.frame = self.view.bounds;
        self.loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.glkViewController setCurrentContext];
    [self setNeedsStatusBarAppearanceUpdate];
    [self.lumiTUTKClient cleanLocalBuffer];
    [self.lumiTUTKClient setRequestAudioDataOrNotWithFlag:YES];
//    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
//    path = [path stringByAppendingPathComponent:@"ffffff"];
//    NSArray *arr = [NSArray arrayWithContentsOfFile:path];
//    if (arr){
//        self.aaaaaada = [NSMutableArray arrayWithArray:arr];
//        [self prepareAudio];
//        [self.audioPlayer startPlay];
//        for (NSData *todo in self.aaaaaada) {
////            [_audioPlayer addAudioBuffer:todo];
////            [self client:self.lumiTUTKClient onAudioReceived:todo.bytes length:todo.length];
//        }
//    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[MHTipsView shareInstance] setTipsOrientation:UIInterfaceOrientationPortrait];
    [[MHMusicTipsView shareInstance] setTipsOrientation:UIInterfaceOrientationPortrait];
    [self.lumiTUTKClient setRequestAudioDataOrNotWithFlag:NO];
    [self.audioPlayer flushAudio];
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - MHLumiCameraTimeLineViewDelegate
- (void)cameraTimeLineViewEndDragging:(MHLumiCameraTimeLineView *)cameraTimeLineView{
    if (_timeLineDraging){
        NSLog(@"触发了-EndDragging");
        NSDate *catchDate = cameraTimeLineView.currentDate;
        __weak typeof(self) weakself = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([catchDate isEqualToDate:cameraTimeLineView.currentDate]) {
                NSLog(@"真正执行了-EndDragging");
                [weakself realCameraTimeLineViewEndDragging:cameraTimeLineView];
            }
        });
    }else{
        [self realCameraTimeLineViewEndDragging:cameraTimeLineView];
    }

}

- (void)realCameraTimeLineViewEndDragging:(MHLumiCameraTimeLineView *)cameraTimeLineView{
    if ([cameraTimeLineView.currentDate earlierDate:cameraTimeLineView.markDateA] == cameraTimeLineView.currentDate){
        [cameraTimeLineView scrollToDate:self.dateLogForWillDrag andAnimated:YES];
        _timeLineDraging = NO;
        return;
    }
    __weak typeof(self) weakself = self;
    if ([cameraTimeLineView.currentDate laterDate:cameraTimeLineView.markDateB] == cameraTimeLineView.currentDate){
        if (self.viewStatus == MHLumiUICameraHomeViewControllerStatusNormal){
            [cameraTimeLineView scrollToDate:self.dateLogForWillDrag andAnimated:YES];
        }else if (self.viewStatus == MHLumiUICameraHomeViewControllerStatusBackward && _timeLineDraging){
            NSLog(@"停止回看，回到实时");
            NSString *jsonStr = [MHLumiTUTKClientHelper ioCtrlBackwardStopJSonString];
            [weakself configureViewWithStatus:MHLumiUICameraHomeViewControllerStatusLoading withDuration:0.5];
            [self.lumiTUTKClient setBackwardWithJsonString:jsonStr startOrStop:NO success:^(MHLumiTUTKClient *client, int retcode, NSInteger realPlayTime) {
                NSLog(@"停止回看成功");
                [weakself.lumiTUTKClient cleanBothBuffer];
                [weakself.audioPlayer flushAudio];
                [weakself configureViewWithStatus:MHLumiUICameraHomeViewControllerStatusWaitLiveLoading withDuration:1];
//                NSDate *currentCameraDate = [[NSDate date] dateByAddingTimeInterval:weakself.deltaTime_Camera_Sys];
//                NSLog(@"%@",currentCameraDate.description);
//                weakself.dateLogForWillDrag = currentCameraDate;
//                [cameraTimeLineView scrollToDate:currentCameraDate andAnimated:YES];
//                weakself.markForTimer = cameraTimeLineView.currentDate.timeIntervalSince1970;
//                [weakself configureViewWithStatus:MHLumiUICameraHomeViewControllerStatusNormal withDuration:0.5];
            } failure:^(MHLumiTUTKClient *client, NSError *error) {
                if (error.code == kIsBackwardNotStart){
                    NSLog(@"回看没启动。要纠正");
                    [weakself.lumiTUTKClient cleanBothBuffer];
                    [weakself.audioPlayer flushAudio];
                    [weakself changCameraFormBackwardToLive];
                }else{
                    NSLog(@"停止回看失败");
                    [weakself showTipsInfo:@"操作失败，请重试" duration:0.8 modal:NO];
                    [cameraTimeLineView scrollToDate:weakself.dateLogForWillDrag andAnimated:YES];
                    [weakself configureViewWithStatus:MHLumiUICameraHomeViewControllerStatusBackward withDuration:0.5];
                }
            }];
        }
        _timeLineDraging = NO;
        return;
    }
    
    if (_timeLineDraging){
        _timeLineDraging = NO;
    }else{
        return;
    }
    
    NSLog(@"发起回看请求");
    NSString *dateStr = [[NSDateFormatter TUTKDateFormatter] stringFromDate:cameraTimeLineView.currentDate];
    NSString *jsonStr = [MHLumiTUTKClientHelper ioCtrlBackwardStartJSonStringWithTimeStr:dateStr];
    self.preViewStatus = self.viewStatus;
    [weakself configureViewWithStatus:MHLumiUICameraHomeViewControllerStatusLoading withDuration:0.5];
    [self.lumiTUTKClient setBackwardWithJsonString:jsonStr startOrStop:YES success:^(MHLumiTUTKClient *client, int retcode, NSInteger realPlayTime) {
        NSLog(@"回看成功,等待回看信息到来");
        NSLog(@"realPlayTime = %ld",(long)realPlayTime);
        [weakself.lumiTUTKClient cleanBothBuffer];
        [weakself.audioPlayer flushAudio];
        [weakself configureViewWithStatus:MHLumiUICameraHomeViewControllerStatusWaitBackwardLoading withDuration:0.5];
    } failure:^(MHLumiTUTKClient *client, NSError *error) {
        if (weakself.navigationController == nil){
            return ;
        }
        if (error.code == kIsBackwardTimeUnable) {
            [weakself showTipsInfo:@"该时间段不可回看" duration:0.8 modal:NO];
        }else{
            [weakself showTipsInfo:@"操作失败，请重试" duration:0.8 modal:NO];
        }
        [cameraTimeLineView scrollToDate:weakself.dateLogForWillDrag  andAnimated:YES];
        [weakself configureViewWithStatus:weakself.preViewStatus withDuration:0.5];
    }];
}

- (void)cameraTimeLineViewWillBeginDragging:(MHLumiCameraTimeLineView *)cameraTimeLineView{
    NSLog(@"开始拖动");
    if (!_timeLineDraging){
        NSLog(@"开始拖动-记录了时间");
        _dateLogForWillDrag = cameraTimeLineView.currentDate;
    }
    NSLog(@"开始拖动-_timeLineDraging 置为1");
    _timeLineDraging = YES;

}
#pragma mark - MHLumiRecorder2Delegate
- (void)lumiRecorder2:(MHLumiRecorder2 *)recorder didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    static int count = 0;
    if (self.aacEncoder == nil){
        self.aacEncoder = [[MHLumiAACEncoder alloc] init];
    }
    __weak typeof(self) weakself = self;
    [self.aacEncoder encodeSampleBuffer:sampleBuffer callBackQueue:dispatch_get_main_queue() completionBlock:^(NSData *encodedData, NSError *error) {
        if (!error) {
            if (weakself.talkbackButton.selected){
                if (count >= 13 ){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        int randomVolume = arc4random_uniform(100);
                        [[MHMusicTipsView shareInstance] setVolume:randomVolume];
                    });
                    count = 0;
                }else{
                    count ++ ;
                }
            }
            [weakself.lumiTUTKClient addAccData:encodedData];
        }
    }];
}

- (void)writePCMData:(NSData *)data{
    if (!self.pcmFileHandle){
        NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        path = [path stringByAppendingPathComponent:@"pcmdata"];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
        self.pcmFileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
    }
//    NSLog(@"写入了");
    [self.pcmFileHandle writeData:data];
}

- (void)writeAACData:(NSData *)data{
    if (!self.aacFileHandle){
        NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        path = [path stringByAppendingPathComponent:@"backward.aac"];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
        self.aacFileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
    }
//    NSLog(@"写入了");
    [self.aacFileHandle writeData:data];
}

#pragma mark - MHLumiTUTKClientDelegate
- (void)client:(MHLumiTUTKClient *)client onVideoReceived:(AVFrame*)frame
avcodecContext:(AVCodecContext*)avcodecContext
 gotPicturePtr:(int)gotPicturePtr{
//    MHVideoFrameYUV* yuvFrame = [[MHVideoFrameYUV alloc] initWithFrame: frame
//                                                              withSize:CGSizeMake(avcodecContext->width, avcodecContext->height)];
//    if (yuvFrame.size.width > 0 && yuvFrame.size.height > 0)
//    {
//        [self.videoView setDataSize:(int)yuvFrame.size.width andHeight:(int)yuvFrame.size.height];
//    }
//    
//    __weak typeof(self) weakself = self;
//    dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"更新画面");
//        [weakself.videoView drawVideoFrame:yuvFrame];
////        [weakself updateTimeLineViewByVideoViewTimeStamp:frame->pts];
//        if (!CGSizeEqualToSize(weakself.videoDataSize, yuvFrame.size)){
//            weakself.videoDataSize = yuvFrame.size;
//            [weakself updateVideoViewFrame];
//        }
//    });
}

- (void)client:(MHLumiTUTKClient *)client videoBuffer:(const void *)videoBuffer length:(int)length frameInfo:(LumiTUTKFrameInfo)frameInfo{
    if (self.viewStatus == MHLumiUICameraHomeViewControllerStatusRecording){
        NSData *data = [NSData dataWithBytes:videoBuffer length:length];
        NSLog(@"h264FileHandle writeData %d",length);
        [self.h264FileHandle writeData:data];
    }
}

- (void)client:(MHLumiTUTKClient *)client onAudioReceived:(void *)audiobuffer length:(int)length frameInfo:(LumiTUTKFrameInfo)frameInfo{
    if (self.viewStatus == MHLumiUICameraHomeViewControllerStatusRecording){
        NSData *audioData = [[NSData alloc] initWithBytes:audiobuffer length:length];
        [self.aacFileHandle writeData:audioData];
    }

    if (!self.lumiNeAACDecoder){
        self.lumiNeAACDecoder = [[MHLumiNeAACDecoder alloc] initWithaudioData:audiobuffer length:length samplerate:44100 channelNum:2];
    }
    void *audioOutBuffe1r = [self.lumiNeAACDecoder decodeAudioData:audiobuffer length:length];
    unsigned long dataLength = [self.lumiNeAACDecoder dataLengthWithFormatId];
    if (dataLength > 0){
        NSData *audioData = [[NSData alloc] initWithBytes:audioOutBuffe1r length:dataLength];

        [_audioPlayer addAudioBuffer:audioData];
    }
}

#pragma mark - MHLumiGLKViewControllerDataSource
- (MHLumiGLKViewData)fetchBufferData:(MHLumiGLKViewController *)glkViewController{
    MHLumiGLKViewData glkViewData;
    _yuvData = [MHLumiYUVBufferHelper yuvBufferWithYData:_todoFrame->data
                                                linesize:_todoFrame->linesize
                                              frameWidth:_todoFrame->width
                                             frameHeight:_todoFrame->height];
    glkViewData.buffer = _yuvData.bytes;
    glkViewData.width = _todoFrame->width;
    glkViewData.height = _todoFrame->height;
    return glkViewData;
}

- (bool)shouldUpdateBuffer:(MHLumiGLKViewController *)glkViewController{
    static int count;
    _shouldUpdate = [self.lumiTUTKClient proactiveFetchVideoDataWithABAVFrame:_todoFrame frameInfo:&_todoFrameInfo gotPicturePtr:&count];
    if (_shouldUpdate == NO){
        return NO;
    }
    
    //帧信息大小为零，直接返回
    if (_todoFrame->height * _todoFrame->width <= 0) {
        _shouldUpdate = NO;
        return _shouldUpdate;
    }
    
    //判断图像长宽是否变化，如果变化，调整glkView的位置和大小
    CGSize newSize = CGSizeMake(_todoFrame->width, _todoFrame->height);
    if (!CGSizeEqualToSize(self.videoDataSize, newSize)){
        self.videoDataSize = newSize;
        [self updateVideoViewFrame];
    }
    
    //启动定时，用于指针的移动和重新获取回看时间段
    if (_shouldUpdate && !self.timerForTimeLineView) {
        [self fireTimerForTimeLineView];
    }
    
    NSLog(@"_todoFrameInfo.isLive = %d", _todoFrameInfo.isLive);
    //从帧信息获取是实时还是回放
    //是回放，且原来是实时
    if (_shouldUpdate && _todoFrameInfo.isLive == 0 && self.viewStatus == MHLumiUICameraHomeViewControllerStatusWaitBackwardLoading){
        [self changCameraFormLiveToBackward];
        //是实时，且原来是回放
    }else if(_shouldUpdate && _todoFrameInfo.isLive == 1 && self.viewStatus == MHLumiUICameraHomeViewControllerStatusWaitLiveLoading){
        [self changCameraFormBackwardToLive];
    }
    
    //初始的loding结束
    if (_isInitCamera){
        _isInitCamera = NO;
        NSLog(@"GLK初始化结束");
        dispatch_group_leave(self.cameraGroup); //初始化GLK
    }
    
    return _shouldUpdate;
//    if (_isInitCamera){
//        _isInitCamera = NO;
//        NSLog(@"GLK初始化结束");
//        dispatch_group_leave(self.cameraGroup); //初始化GLK
//    }
//    return NO;
}

- (void)needUpdateMarkPoint:(MHLumiGLKViewController *)glkViewController{
    
}

#pragma mark - MHLumiUICameraHomeSettingViewControllerDelegate
- (void)cameraHomeSettingViewController:(MHLumiUICameraHomeSettingViewController *)cameraHomeSettingViewController
                     didChangDeviceName:(NSString *)name{
    //有空改为delegate抛出去
    [(MHLuDeviceViewControllerBase *)(self.parentViewController) buildTitle];
    [(MHLuDeviceViewControllerBase *)(self.parentViewController) refreshTitle];
}

#pragma mark - event response
- (void)onMore:(id)sender{
    MHLumiUICameraHomeSettingViewController *todoVC = [[MHLumiUICameraHomeSettingViewController alloc] init];
    todoVC.cameraDevice = self.cameraDevice;
    todoVC.delegate = self;
    [self.navigationController pushViewController:todoVC animated:YES];
}

- (void)doubleTapAction:(UITapGestureRecognizer *)sender{
    if (self.glkViewController.currentViewType == MHLumiFisheyeViewTypeDefault){
        [self.glkViewController changeViewType:MHLumiFisheyeViewTypeA];
    }else if (self.glkViewController.currentViewType == MHLumiFisheyeViewTypeA){
        [self.glkViewController changeViewType:MHLumiFisheyeViewTypeDefault];
    }
}

- (void)showQualityOpitionWithFlag:(BOOL)flag andSender:(UIButton *)sender{
    if (flag){
        CGRect tRect = [sender convertRect:sender.bounds toView:self.view];
        [self.view addSubview:self.qualityOpitionView];
        self.qualityOpitionView.center = CGPointMake(CGRectGetMidX(tRect), CGRectGetMinY(tRect)-30);
        self.qualityOpitionView.layer.anchorPoint = CGPointMake(0.5, 1);
        self.qualityOpitionView.transform = CGAffineTransformMakeScale(1, 0.1);
        [UIView animateWithDuration:0.2 animations:^{
            self.qualityOpitionView.transform = CGAffineTransformIdentity;
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            self.qualityOpitionView.transform = CGAffineTransformMakeScale(1, 0.1);
        } completion:^(BOOL finished) {
            [self.qualityOpitionView removeFromSuperview];
            self.qualityOpitionView.transform = CGAffineTransformIdentity;
        }];
    }
}

- (void)previewButtonAction:(UIButton *)sender{
    if (self.qualityButton.selected){
        [self qualityButtonAction:self.qualityButton];
    }
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized){
        
    }else if([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied
             || [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusRestricted){
        NSLog(@"处理拒绝");
        [self showFailedTips:@"用户没有授权操作相册" duration:1 modal:YES];
        return;
    }else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined){
        __weak typeof(self) weakself = self;
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself previewButtonAction:sender];
            });
        }];
        return;
    }
    
    MHLumiCameraPhotosViewController *vc = [[MHLumiCameraPhotosViewController alloc] initWithCameraDevice:self.cameraDevice];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)recordButtonAction:(UIButton *)sender{
    if (self.qualityButton.selected){
        [self qualityButtonAction:self.qualityButton];
    }
    self.preViewStatus = self.viewStatus;
    [self configureViewWithStatus:MHLumiUICameraHomeViewControllerStatusRecording withDuration:0.3];
    self.logTimeNum = 0;
    __weak typeof(self) weakself = self;
    [self updateRecordingTimeLabelWithLogNum:self.logTimeNum];
    if (_recordingTimer){
        [_recordingTimer invalidate];
    }
    _recordingTimer = [MHWeakTimerFactory scheduledTimerWithBlock:1 callback:^{
        weakself.logTimeNum ++;
        [weakself updateRecordingTimeLabelWithLogNum:weakself.logTimeNum];
    }];
    
    NSString *uniqueString = [[[NSProcessInfo processInfo] globallyUniqueString] substringToIndex:8];
    //h264文件路径
    _h264Filename_V = [[MHLumiLocalCachePathHelper defaultHelper] pathWithLocalCacheType:MHLumiLocalCacheTypeTUTKPath
                                                                             andFilename:[NSString stringWithFormat:@"%@_tutk.h264",uniqueString]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:_h264Filename_V]){
        [[NSFileManager defaultManager] removeItemAtPath:_h264Filename_V error:nil];
    }
    [[NSFileManager defaultManager] createFileAtPath:_h264Filename_V contents:nil attributes:nil];
    
    //aac文件路径
    _aacFilename_A = [[MHLumiLocalCachePathHelper defaultHelper] pathWithLocalCacheType:MHLumiLocalCacheTypeTUTKPath
                                                                            andFilename:[NSString stringWithFormat:@"%@_tutk.aac",uniqueString]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:_aacFilename_A]){
        [[NSFileManager defaultManager] removeItemAtPath:_aacFilename_A error:nil];
    }
    [[NSFileManager defaultManager] createFileAtPath:_aacFilename_A contents:nil attributes:nil];
    
    NSLog(@"_h264Filename_V: %@",_h264Filename_V);
    NSLog(@"_aacFilename_A: %@",_aacFilename_A);
    self.h264FileHandle = [NSFileHandle fileHandleForWritingAtPath:_h264Filename_V];
    self.aacFileHandle = [NSFileHandle fileHandleForWritingAtPath:_h264Filename_V];
    
    if ([self.delegate respondsToSelector:@selector(homeViewControllerDidOnRecording:)]){
        [self.delegate homeViewControllerDidOnRecording:self];
    }
}

- (void)photoButtonAction:(UIButton *)sender{
    if (self.qualityButton.selected){
        [self qualityButtonAction:self.qualityButton];
    }
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized){

    }else if([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied
             || [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusRestricted){
        NSLog(@"处理拒绝");
        [self showFailedTips:@"用户没有授权操作相册" duration:1 modal:YES];
        return;
    }else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined){
        __weak typeof(self) weakself = self;
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself photoButtonAction:sender];
            });
        }];
        return;
    }
    
    NSError *error = nil;
    [self screenshotGLKViewWithError:&error];
    if (error != nil){
         [self showFailedTips:@"保存失败" duration:1 modal:YES];
    }
    [self screenshotWhiteAnimationInView:self.glkViewController.view];
}

- (void)screenshotWhiteAnimationInView:(UIView *)targetView{
    UIView *whiteView = [[UIView alloc] initWithFrame:targetView.bounds];
    whiteView.backgroundColor = [UIColor whiteColor];
    [targetView addSubview:whiteView];
    whiteView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        whiteView.alpha = 0.6;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            whiteView.alpha = 0;
        } completion:^(BOOL finished) {
            [whiteView removeFromSuperview];
        }];
    }];
}

- (void)screenshotGLKViewWithError:(NSError **)error{
    UIView *todoView = self.glkViewController.view;
    //    UIView *todoView = self.videoView;
    CGFloat videoWidth = CGRectGetWidth(todoView.frame);
    CGFloat videoHeight = CGRectGetHeight(todoView.frame);
    CGFloat iconWidth = self.previewButton.imageView.image.size.width;
    CGFloat ratio = videoWidth/videoHeight;
    CGFloat todoHeight = iconWidth/sqrt((1+pow(ratio, 2)));
    todoHeight = todoHeight - 4;
    CGFloat todoWidth = todoHeight * ratio;
    
    //真正需要保存的图
    UIGraphicsBeginImageContextWithOptions(todoView.bounds.size, NO, [UIScreen mainScreen].scale);
    [todoView drawViewHierarchyInRect:todoView.bounds afterScreenUpdates:YES];
    UIImage *todoImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [MHLumiCameraMediaDataManager saveImage:todoImage toAssetColletion:self.lumiCameraAssetCollection andError:error];
    if (*error){
        return;
    }
    
    //预览图
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(todoWidth, todoHeight), NO, [UIScreen mainScreen].scale);
    [todoView drawViewHierarchyInRect:CGRectMake(0, 0, todoWidth, todoHeight) afterScreenUpdates:YES];
    UIImage *preViewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //预览图加圈圈
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(iconWidth, iconWidth), NO, [UIScreen mainScreen].scale);
    CGRect rect = CGRectMake((iconWidth-todoWidth)/2.0, (iconWidth-todoHeight)/2.0, todoWidth, todoHeight);
    [[self previewButtonWhiteImage] drawInRect:CGRectMake(0, 0, iconWidth, iconWidth)];
    [todoView drawViewHierarchyInRect:rect afterScreenUpdates:YES];
    UIImage *preViewPlusImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.previewButton setImage:[self previewButtonBlackImage] forState:UIControlStateNormal];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:preViewImage];
    [self.previewButton.superview addSubview:imageView];
    imageView.center = self.previewButton.center;
    imageView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [UIView animateWithDuration:0.3 animations:^{
        imageView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self.previewButton setImage:preViewPlusImage forState:UIControlStateNormal];
        [imageView removeFromSuperview];
    }];
}

- (void)showScreenshotAnimationInButton:(UIButton *)button andImage:(UIImage *)previewImage{
    
}

- (void)talkbackButtonTouchUpOutside:(UIButton *)sender{
    NSLog(@"%s",__func__);
    [self talkbackButtonTouchUpInside:sender];
}

- (void)talkbackButtonTouchUpInside:(UIButton *)sender{
    NSLog(@"%s",__func__);
    self.talkbackButton.selected = NO;
    [self.lumiRecorder stopRecording];
    [[MHMusicTipsView shareInstance] hide];
    
    __weak typeof(self) weakself = self;
    if (self.lumiTUTKClient.audioStreamStatus == MHLumiTUTKStreamstatusON) {
        [self enableCameraAudioWithSuccess:nil failure:^(NSError *error) {
            weakself.muteButton.selected = NO;
        }];
    }
    
    if (self.lumiTUTKClient.talkbackServiceStatus == MHLumiTUTKTalkbackStatusConnected){
        NSString *stopTalkbackJson = [MHLumiTUTKClientHelper ioCtrlTalkBackStartJSonStringWithAVChannelId:self.lumiTUTKClient.talkbackAVChannelId];
        [self.lumiTUTKClient stopTalkBackWithJsonString:stopTalkbackJson
                                       completedHandler:^(MHLumiTUTKClient *client, int retcode) {
                                           if (retcode < 0){
                                               NSLog(@"手指离开时，关对讲失败");
                                               [weakself.lumiTUTKClient stopTalkBackWithJsonString:stopTalkbackJson completedHandler:nil];
                                           }else{
                                               NSLog(@"手指离开时，关对讲成功");
                                           }
                                       }];
    }
}

- (void)talkbackButtonTouchDown:(UIButton *)sender{
    if (self.qualityButton.selected){
        [self qualityButtonAction:self.qualityButton];
    }
    
    if (self.viewStatus == MHLumiUICameraHomeViewControllerStatusBackward) {
        [self showTipsInfo:@"回放过程中，无法对讲" duration:1 modal:YES];
        return;
    }
    
    __weak typeof(self) weakself = self;
    if ([MHLumiRecorder2 recordPermission] == AVAudioSessionRecordPermissionUndetermined){
        [MHLumiRecorder2 requestRecordPermission:^(BOOL granted) {

        }];
        return;
    }else if ([MHLumiRecorder2 recordPermission] == AVAudioSessionRecordPermissionDenied){
        [self showFailedTips:@"用户没授权麦克风操作" duration:1 modal:YES];
        return;
    }
    
    if (self.lumiTUTKClient.talkbackServiceStatus == MHLumiTUTKTalkbackStatusDefault){
        [self showVolumeViewWithTips:@"按住对讲"];
        self.talkbackButton.selected = YES;
        [self.lumiTUTKClient setRequestAudioDataOrNotWithFlag:NO];
        [self.audioPlayer stopPlay];
        [MHLumiRecorder2 configureAudioSession];
        [self.lumiRecorder startRecording];
        [self.lumiTUTKClient startAndfetchTalkBackServIdWithJsonString:[MHLumiTUTKClientHelper ioCtrlTalkBackStartJSonStringWithAVChannelId:1]
                                                          completedHandler:^(MHLumiTUTKClient *client, int retcode) {
                                                              if (retcode<0){
                                                                  NSLog(@"开启对讲失败");
                                                                  [weakself.lumiRecorder stopRecording];
                                                                  [weakself.lumiTUTKClient resetAccData];
                                                              }else{
                                                                  if (!weakself.talkbackButton.selected){
                                                                      NSLog(@"开启对讲成功，但手指已离开");
                                                                      NSString *stopTalkbackJson = [MHLumiTUTKClientHelper ioCtrlTalkBackStartJSonStringWithAVChannelId:weakself.lumiTUTKClient.talkbackAVChannelId];
                                                                      [weakself.lumiTUTKClient stopTalkBackWithJsonString:stopTalkbackJson completedHandler:nil];
                                                                  }else{
                                                                      NSLog(@"开启对讲成功");
                                                                  }
                                                              }
                                                          }];
    }
    
    NSLog(@"%s",__func__);
}

- (void)recordingButtonAction:(UIButton *)sender{
    [_recordingTimer invalidate];
    [self configureViewWithStatus:self.preViewStatus withDuration:0.3];
    [self.h264FileHandle closeFile];
    [self.aacFileHandle closeFile];
    MHLumiMuxer *muxer = [[MHLumiMuxer alloc] init];
    NSString *fileName = [self recordFileNameWithDate:[NSDate date]
                                           dewrapType:self.glkViewController.dewrapType
                                            mountType:self.glkViewController.mountType
                                   centerPointOffsetX:self.glkViewController.centerPointOffsetX
                                   centerPointOffsetY:self.glkViewController.centerPointOffsetY
                                   centerPointOffsetR:self.glkViewController.centerPointOffsetR];
    NSString *outputFilename = [[MHLumiLocalCachePathHelper defaultHelper] pathWithLocalCacheType:MHLumiLocalCacheTypeTUTKPath andFilename:fileName];
    [self showTips:@"保存中…" modal:YES];
    __weak typeof(self) weakself = self;
    [muxer muxWithInputVideoName:self.h264Filename_V
                  inputAudioName:nil
               andOutputFileName:outputFilename
                 completeHandler:^(int retcode) {
        NSError *error = nil;
        if (retcode >= 0){
            [MHLumiCameraMediaDataManager saveVideoWithPath:outputFilename toAssetCollection:weakself.lumiCameraAssetCollection andError:&error];
        }
        if (error || retcode<0){
            [weakself showFailedTips:@"保存失败" duration:1 modal:YES];
        }else if(retcode>=0 && error == nil){
            if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilename]){
                [[NSFileManager defaultManager] removeItemAtPath:outputFilename error:nil];
            }
            [weakself showFinishTips:@"保存成功" duration:1 modal:YES];
        }
        
        if ([weakself.delegate respondsToSelector:@selector(homeViewControllerDidOffRecording:)]){
            [weakself.delegate homeViewControllerDidOffRecording:weakself];
        }
    }];

}

- (void)motionButtonAction:(UIButton *)sender{
//    NSString *jsonStr = [MHLumiTUTKClientHelper ioCtrlVideoModeJSonStringWithAVChannelId:self.lumiTUTKClient.avChannelId
//                                                                            andVideoMode:MHLumiTUTKVideoModeORIGIN];
//    if (!self.lumiTUTKClient){
//        [[MHTipsView shareInstance] showFailedTips:@"切换失败" duration:1 modal:YES];
//        return;
//    }
//    [[MHTipsView shareInstance] showTips:@"切换中" modal:YES];
//    [self.lumiTUTKClient setVideoMode:MHLumiTUTKVideoModeORIGIN
//                       WithJsonString:jsonStr
//                     completedHandler:^(MHLumiTUTKClient *client, int retcode) {
//                         if (retcode >= 0){
//                             [[MHTipsView shareInstance] showTipsInfo:@"切换成功" duration:1 modal:YES];
//                         }else{
//                             [[MHTipsView shareInstance] showFailedTips:@"切换失败" duration:1 modal:YES];
//                         }
//                     }];
}

- (void)muteButtonAction:(UIButton *)sender{
    __weak typeof(self) weakself = self;
    if (self.lumiTUTKClient.audioStreamStatus != MHLumiTUTKStreamstatusONAndRequest){
        [self showTips:@"声音开启中"modal:YES];
        [self enableCameraAudioWithSuccess:^{
            [weakself showTipsInfo:@"开启声音成功" duration:1 modal:NO];
            weakself.muteButton.selected = YES;
            [weakself.cacheManager setObject:@1 forKey:weakself.kCameraMuteKey];
        } failure:^(NSError *error) {
            [weakself showTipsInfo:@"开启声音失败" duration:1 modal:NO];
            weakself.muteButton.selected = NO;
        }];
    }else {
        [self showTips:@"声音关闭中" modal:YES];
        [self disableCameraAudioWithSuccess:^{
            [weakself showTipsInfo:@"关闭声音成功" duration:1.5 modal:NO];
            weakself.muteButton.selected = NO;
            [weakself.cacheManager setObject:@0 forKey:weakself.kCameraMuteKey];
        } failure:^(NSError *error) {
            [weakself showTipsInfo:@"声音关闭失败" duration:1.5 modal:NO];
            weakself.muteButton.selected = YES;
        }];
    }

}

- (void)fourRButtonAction:(UIButton *)sender{

//    self.markForTimer = self.timeLineView.currentDate.timeIntervalSince1970;
//    [self configureViewWithStatus:MHLumiUICameraHomeViewControllerStatusBackward withDuration:0.5];
//    [self fireTimerForBackwardWithDate:self.timeLineView.currentDate];
        
    
    //    NSString *jsonStr = [MHLumiTUTKClientHelper ioCtrlVideoModeJSonStringWithAVChannelId:self.lumiTUTKClient.avChannelId
//                                                                            andVideoMode:MHLumiTUTKVideoMode4R];
//    if (!self.lumiTUTKClient){
//        [[MHTipsView shareInstance] showFailedTips:@"切换失败" duration:1 modal:YES];
//        return;
//    }
//    [[MHTipsView shareInstance] showTips:@"切换中" modal:YES];
//    [self.lumiTUTKClient setVideoMode:MHLumiTUTKVideoMode4R
//                       WithJsonString:jsonStr
//                     completedHandler:^(MHLumiTUTKClient *client, int retcode) {
//                         if (retcode >= 0){
//                             [[MHTipsView shareInstance] showTipsInfo:@"切换成功" duration:1 modal:YES];
//                         }else{
//                             [[MHTipsView shareInstance] showFailedTips:@"切换失败" duration:1 modal:YES];
//                         }
//    }];
}

- (void)backButtonAction:(UIButton *)sender{
    [self rotationButtonAction:self.recordButton];
}

- (void)rotationButtonAction:(UIButton *)sender{
    if (self.qualityButton.selected){
        [self qualityButtonAction:self.qualityButton];
    }
    UIInterfaceOrientation todo = UIInterfaceOrientationPortrait;
    if ([self isLandscapeRight]){
        todo = UIInterfaceOrientationPortrait;
        [self.backButton removeFromSuperview];
    }else{
        todo = UIInterfaceOrientationLandscapeRight;
        [self.view addSubview:self.backButton];
    }
    [self setupMainButtonsWithOrientation:todo];
    [self configureLayoutWithOrientation:todo];
    if ([self.delegate respondsToSelector:@selector(homeViewController:shouldAutorotateToInterfaceOrientation:)]){
        [self.delegate homeViewController:self shouldAutorotateToInterfaceOrientation:todo];
    }
}

- (void)qualityButtonAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    [self showQualityOpitionWithFlag:sender.selected andSender:sender];
}

- (void)qualityOpitionViewAction:(UIButton *)sender{
    NSLog(@"%s tag: %ld",__func__, sender.tag);
    MHLumiTUTKVideoQuality quality = MHLumiTUTKVideoQualityAuto;
    sender.tag = (sender.tag)%3;
    switch (sender.tag) {
        case 0:
            quality = MHLumiTUTKVideoQualityAuto;
            break;
        case 1:
            quality = MHLumiTUTKVideoQualityStandard;
            break;
        case 2:
            quality = MHLumiTUTKVideoQualityHigh;
            break;
        default:
            break;
    }
    NSString *json = [MHLumiTUTKClientHelper ioCtrlVideoQualityJSonStringWithAVChannelId:self.lumiTUTKClient.avChannelId
                                                                              andQuality:quality];
    if (!self.lumiTUTKClient){
        [self showTipsInfo:@"切换失败" duration:1 modal:YES];
        [self qualityButtonAction:self.qualityButton];
        return;
    }
    [self showTips:@"切换中" modal:YES];
    __weak typeof(self) weakself = self;
    [self.lumiTUTKClient setVideoQuality:quality WithJsonString:json completedHandler:^(MHLumiTUTKClient *client, int retcode) {
        if (retcode >= 0){
            [weakself showTipsInfo:@"切换成功" duration:1 modal:YES];
            [weakself qualityButtonAction:weakself.qualityButton];
            [weakself.qualityButton setTitle:weakself.opitionTitles[sender.tag] forState:UIControlStateNormal];
        }else{
            [weakself showTipsInfo:@"切换失败" duration:1 modal:YES];
            [weakself qualityButtonAction:weakself.qualityButton];
        }
    }];
}

- (void)videoViewTapAction:(UITapGestureRecognizer *)sender{
    if (sender.view == self.loadingView){
        return;
    }
    if (self.viewStatus == MHLumiUICameraHomeViewControllerStatusRecording){
        return;
    }
    BOOL hidden = YES;
    NSTimeInterval duration = 0.3;
    if (self.viewStatus != MHLumiUICameraHomeViewControllerStatusWithoutControlPaner){
        hidden = YES;
        self.preViewStatus = self.viewStatus;
        [self configureViewWithStatus:MHLumiUICameraHomeViewControllerStatusWithoutControlPaner withDuration:duration];
    }else if (self.viewStatus == MHLumiUICameraHomeViewControllerStatusWithoutControlPaner){
        hidden = NO;
        [self configureViewWithStatus:_preViewStatus withDuration:duration];
    }else{
        return;
    }
    if ([self.delegate respondsToSelector:@selector(homeViewController:willHiddenControlPanel:withDuration:)]){
        [self.delegate homeViewController:self willHiddenControlPanel:hidden withDuration:duration];
    }
}

- (void)noNetViewTapAction:(UITapGestureRecognizer *)sender{
    [self initCamera];
}

/**
 *  所有控制面板View的显示和隐藏
 */
- (void)setControlPanelHidden:(BOOL)hidden withDuration:(NSTimeInterval)duration{
    if (hidden){
        [UIView animateWithDuration:duration animations:^{
            self.controlPanelContanerView.alpha = 0;
            self.timeLineView.alpha = 0;
            self.buttonsContanerView.alpha = 0;
        } completion:^(BOOL finished) {
            self.controlPanelContanerView.hidden = YES;
            self.timeLineView.hidden = YES;
            self.buttonsContanerView.hidden = YES;
        }];
    }else {
        self.controlPanelContanerView.hidden = NO;
        self.timeLineView.hidden = NO;
        self.buttonsContanerView.hidden = NO;
        [UIView animateWithDuration:duration animations:^{
            self.controlPanelContanerView.alpha = 1;
            self.timeLineView.alpha = 1;
            self.buttonsContanerView.alpha = 1;
        } completion:nil];
    }
}

#pragma mark private function

- (void)enableCameraAudioWithSuccess:(void(^)())successHandler failure:(void(^)(NSError *))failureHandler{
    void(^localSuccessHandler)() = ^{
        if (successHandler) {
            successHandler();
        }
    };
    [self prepareAudio];
    [self.audioPlayer startPlay];
    switch (self.lumiTUTKClient.audioStreamStatus) {
        case MHLumiTUTKStreamstatusON:
            [self.lumiTUTKClient setRequestAudioDataOrNotWithFlag:YES];
            localSuccessHandler();
            break;
        case MHLumiTUTKStreamstatusOFF:{
            __weak typeof(self) weakself = self;
            NSString *jsonStr = [MHLumiTUTKClientHelper ioCtrlJSonStringWithAVChannelId:self.lumiTUTKClient.avChannelId];
            [self.lumiTUTKClient cleanAudioBuffer];
            [self.lumiTUTKClient startAudioStreamWithJsonString:jsonStr startRequestData:YES completedHandler:^(MHLumiTUTKClient *client, int retCode) {
                if (retCode >= 0){
                    localSuccessHandler();
                }else{
                    if (failureHandler) {
                        [weakself.audioPlayer stopPlay];
                        NSError *error = [NSError errorWithDomain:@"com.lumiunited" code:retCode userInfo:nil];
                        failureHandler(error);
                    }
                }
            }];
        }
            break;
        default:
            localSuccessHandler();
            break;
    }
}

- (void)disableCameraAudioWithSuccess:(void(^)())successHandler failure:(void(^)(NSError *))failureHandler{
    void(^localSuccessHandler)() = ^{
        [self.audioPlayer flushAudio];
        [self.audioPlayer stopPlay];
        if (successHandler) {
            successHandler();
        }
    };
    switch (self.lumiTUTKClient.audioStreamStatus) {
        case MHLumiTUTKStreamstatusOFF:
            localSuccessHandler();
            break;
        case MHLumiTUTKStreamstatusON:
        case MHLumiTUTKStreamstatusONAndRequest:{
            NSString *jsonStr = [MHLumiTUTKClientHelper ioCtrlJSonStringWithAVChannelId:self.lumiTUTKClient.avChannelId];
            __weak typeof(self) weakself = self;
            [self.lumiTUTKClient stopAudioStreamWithJsonString:jsonStr completedHandler:^(MHLumiTUTKClient *client , int retcode) {
                if (retcode >= 0 || retcode == AV_ER_NOT_INITIALIZED || retcode == kIsNotFetchingVideoData){
                    [weakself.lumiTUTKClient cleanAudioBuffer];
                     localSuccessHandler();
                }else{
                    if (failureHandler) {
                        NSError *error = [NSError errorWithDomain:@"com.lumiunited" code:retcode userInfo:nil];
                        failureHandler(error);
                    }
                }
            }];
        }
        default:
            localSuccessHandler();
            break;
    }
}

- (void)adjustTipsOrientation{
    if ([self isLandscapeRight]){
        [[MHTipsView shareInstance] setTipsOrientation:UIInterfaceOrientationLandscapeRight];
    }else{
        [[MHTipsView shareInstance] setTipsOrientation:UIInterfaceOrientationPortrait];
    }
}

- (void)showTipsInfo:(NSString *)info duration:(NSTimeInterval)duration modal:(BOOL)isModal{
    [self adjustTipsOrientation];
    [[MHTipsView shareInstance] showTipsInfo:info duration:duration modal:isModal];
}
- (void)showTips:(NSString *)info modal:(BOOL)isModal{
    [self adjustTipsOrientation];
    [[MHTipsView shareInstance] showTips:info modal:isModal];
}

- (void)showFailedTips:(NSString *)info duration:(NSTimeInterval)duration modal:(BOOL)isModal{
    [self adjustTipsOrientation];
    [[MHTipsView shareInstance] showFailedTips:info duration:duration modal:isModal];
}

- (void)showFinishTips:(NSString *)info duration:(NSTimeInterval)duration modal:(BOOL)isModal{
    [self adjustTipsOrientation];
    [[MHTipsView shareInstance] showFinishTips:info duration:duration modal:isModal];
}

- (void)showVolumeViewWithTips:(NSString *)tips{
    if ([self isLandscapeRight]){
        [[MHMusicTipsView shareInstance] setTipsOrientation:UIInterfaceOrientationLandscapeRight];
    }else{
        [[MHMusicTipsView shareInstance] setTipsOrientation:UIInterfaceOrientationPortrait];
    }
    
    [[MHMusicTipsView shareInstance] showVolumeViewWithTips:tips];
}


- (NSString *)recordFileNameWithDate:(NSDate *)date
                          dewrapType:(FEDEWARPTYPE)dewrapType
                           mountType:(FEMOUNTTYPE)mountType
                  centerPointOffsetX:(CGFloat)centerPointOffsetX
                  centerPointOffsetY:(CGFloat)centerPointOffsetY
                  centerPointOffsetR:(CGFloat)centerPointOffsetR{
    NSDateFormatter *dateFormatter = [NSDateFormatter TUTKDateFormatter];
    NSString *timerStr = [dateFormatter stringFromDate:date];
    NSString *dewrapTypeName = [MHLumiFisheyeHelper nameFromDewrapType:dewrapType];
    NSString *mountTypeName = [MHLumiFisheyeHelper nameFromMountType:mountType];
    NSString *cameraDid = self.cameraDevice.did;
    NSString *fileName = [NSString stringWithFormat:@"%@_%@_%@_%@_%.0f_%.0f_%.0f.mp4",
                          timerStr,
                          cameraDid,
                          dewrapTypeName,
                          mountTypeName,
                          centerPointOffsetX,
                          centerPointOffsetY,
                          centerPointOffsetR];
    return fileName;
}

/**
 *  初始化TUTK连接和获取摄像头属性值
 *            |摄像头时间  |
 *  TUTK连接 -|            |- TimeLineView的初始化
 *            |可回看区域  |
 *
 *  TUTK连接   |
 *            |- GLK初始化
 *  中心点获取  |
 *
 */
- (void)initCamera{
    [self configureViewWithStatus:MHLumiUICameraHomeViewControllerStatusLoading withDuration:1];
    __weak typeof(self) weakself = self;
    __block NSString *tip = nil;
    self.cameraGroup = dispatch_group_create();                     //总的group
    dispatch_group_t glkInitGroup = dispatch_group_create();        //GLK初始化
    dispatch_group_t timeLineInitGroup = dispatch_group_create();   //TimeLineView初始化
    
    __block BOOL flagForGLK = NO;
    __block BOOL flagForTimeLine = NO;
    dispatch_group_async(self.cameraGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_group_enter(weakself.cameraGroup);        //开始GLK初始化 :cameraGroup
        dispatch_group_enter(weakself.cameraGroup);        //开始TimeLineView初始化 :cameraGroup
        
        dispatch_group_notify(weakself.cameraGroup, dispatch_get_main_queue(), ^{
            NSLog(@"最后结果flagForGLK=%d,flagForTimeLine=%d",flagForGLK,flagForTimeLine);
            if (flagForGLK && flagForTimeLine){
                weakself.loadingTipsLabel.text = @"加载完成";
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakself configureViewWithStatus:MHLumiUICameraHomeViewControllerStatusNormal withDuration:0.5];
                });
            }else{
                weakself.loadingTipsLabel.text = @"连接失败";
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakself configureViewWithStatus:MHLumiUICameraHomeViewControllerStatusNoNet withDuration:2];
                });
            }
        });
    });

    __block BOOL flagForTUTK = NO;
    __block BOOL flagForCenterPointOffset = NO;

    __block BOOL flagForCameraTime = NO;
    __block BOOL flagForRecordTime = NO;
    
    dispatch_group_async(glkInitGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_group_enter(glkInitGroup);            //开始TUTK连接 :glkInitGroup
        dispatch_group_enter(glkInitGroup);            //开始获取中心点校正值 :glkInitGroup
        //开始TUTK连接
        __strong typeof(weakself) strongself = weakself;
        [weakself initTUTKClientWithCompleteHandler:^(NSString *aTip, NSInteger retcode) {
            tip = aTip;
            flagForTUTK = retcode >= 0;
            if (retcode>=0){
                flagForTUTK = YES;
                //TUTK连接成功后:
                /* +++++开始获取摄像头时间和可回看时间区域++++*/
                dispatch_group_async(timeLineInitGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    dispatch_group_enter(timeLineInitGroup);            //开始获取摄像头时间 :timeLineInitGroup
                    dispatch_group_enter(timeLineInitGroup);            //开始获取可回看时间区域 :timeLineInitGroup
                    NSDateFormatter *dateFormatter = [NSDateFormatter TUTKDateFormatter];
                    weakself.cameraCurrentDate =  [NSDate date];
                    weakself.deltaTime_Camera_Sys = weakself.cameraCurrentDate.timeIntervalSince1970 - [NSDate date].timeIntervalSince1970;
                    flagForCameraTime = YES;
                    dispatch_group_leave(timeLineInitGroup);        //摄像头时间获取成功
                    
                    NSString *jsonStr = [MHLumiTUTKClientHelper ioCtrlGetBackwardTimeJSonString];
                    [weakself.lumiTUTKClient getBackwardRecordTimeWithJsonString:jsonStr completeHandler:^(MHLumiTUTKClient *client, int retcode) {
                        if (retcode >= 0){
                            flagForRecordTime = YES;
                        }
                        dispatch_group_leave(timeLineInitGroup);        //获取可回看时间区域成功
                    }];
                });
                
                //timelineView初始化
                dispatch_group_notify(timeLineInitGroup, dispatch_get_main_queue(), ^{
                    NSLog(@"timelineView初始化,结果flagForRecordTime=%d,flagForCameraTime=%d",flagForRecordTime,flagForCameraTime);
                    //flagForRecordTime flagForCameraTime不管这两个标志位怎样都开始初始化
                    [weakself.view addSubview:weakself.timeLineView];
                    [weakself addTimeLineViewLayoutWithOrientation:UIInterfaceOrientationPortrait];
                    flagForTimeLine = YES;
                    NSLog(@"TimeLine初始化结束");
                    dispatch_group_leave(strongself.cameraGroup); //TimeLine初始化结束
                });
                /* +++++++++++++++++++++++++++++++++++++ */
                
            }else{
                dispatch_group_leave(strongself.cameraGroup); //TimeLine初始化结束
            }
            dispatch_group_leave(glkInitGroup);//TUTK连接结束 :glkInitGroup
        }];
        
        //开始获取中心点校正值
        [weakself.cameraDevice fetchCameraCenterPointOffsetSuccess:^(MHDeviceCamera *client) {
            flagForCenterPointOffset = YES;
            dispatch_group_leave(glkInitGroup);//获取中心点校正值结束 :glkInitGroup
        } failure:^(NSError *error) {
            flagForCenterPointOffset = NO;
            dispatch_group_leave(glkInitGroup);//获取中心点校正值结束 :glkInitGroup
        }];
        
        //GLK初始化
        dispatch_group_notify(glkInitGroup, dispatch_get_main_queue(), ^{
            NSLog(@"GLK初始化,结果flagForTUTK=%d,flagForCenterPointOffset=%d",flagForTUTK,flagForCenterPointOffset);
            if (flagForTUTK){
                //中心点没取到也初始化
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakself.isInitCamera = YES;
                    [weakself initGLKViewControllerWithWithmountType:FE_MOUNT_FLOOR dewrapType:FE_DEWARP_AERIALVIEW viewType:MHLumiFisheyeViewTypeA];
                });
                flagForGLK = YES;
            }else{
                dispatch_group_leave(strongself.cameraGroup); //GLK初始化结束
            }
        });
    });
}


/**
 *  初始化TUTK连接
 */
- (void)initTUTKClientWithCompleteHandler:(void(^)(NSString *tip,NSInteger retcode))completeHandler{
    __weak typeof(self) weakself = self;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        completeHandler(@"连接失败",-1);
//    });
//    return;
    [self.cameraDevice getUidSuccess:^(NSString *udid, NSString *password) {
        [weakself.cameraDevice setVideoWithOnOff:YES uid:udid success:^(BOOL flag) {
            MHLumiTUTKConfiguration *cfg = [MHLumiTUTKConfiguration defaultConfiguration];
            cfg.udid = udid;
            weakself.lumiTUTKClient = [[MHLumiTUTKClient alloc] initWithConfiguration:cfg];
            weakself.lumiTUTKClient.delegate = weakself;
            [weakself.lumiTUTKClient initConnectionWithCompletedHandler:^(MHLumiTUTKClient *client, int retCode) {
                if (retCode < 0){
                    //noNetView（可重试，且有提示语)
                    completeHandler(@"initTUTKConnection failure", retCode);
                    return;
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSString *jsonStr = [MHLumiTUTKClientHelper ioCtrlJSonStringWithAVChannelId:client.avChannelId];
                    [client startVideoStreamWithJsonString:jsonStr startRequestData:NO completedHandler:^(MHLumiTUTKClient *client, int retCode) {
                        if (retCode<0){
                            completeHandler(@"startVideoStream failure",retCode);
                            return;
                        }
                        if (weakself.logForMute){
                            [weakself enableCameraAudioWithSuccess:^{
                                completeHandler(@"startVideoStream",retCode);
                            } failure:^(NSError *error) {
                                weakself.muteButton.selected = NO;
                                completeHandler(@"startVideoStream",retCode);
                            }];
                        }else{
                            completeHandler(@"startVideoStream",retCode);
                        }
                    }];
                });
            }];
        } failure:^(NSError *error) {
            //noNetView（可重试，且有提示语)
            completeHandler(error.localizedDescription,-1);
        }];
    } failure:^(NSError *error) {
        //noNetView（可重试，且有提示语）
        completeHandler(error.localizedDescription,-1);
    }];
}

- (void)initGLKViewControllerWithWithmountType:(FEMOUNTTYPE)mountType
                                    dewrapType:(FEDEWARPTYPE)dewrapType
                                      viewType:(MHLumiFisheyeViewType)viewType{
    _videoDataSize = CGSizeMake(1536, 1536);//1536 * (1536 + 16)
    self.glkViewController = [[MHLumiGLKViewController alloc] initWithDewrapType:dewrapType
                                                                       mountType:mountType
                                                                    viewType:viewType];
    self.glkViewController.dataSource = self;
    self.glkViewController.centerPointOffsetX = self.cameraDevice.centerPointOffsetX;
    self.glkViewController.centerPointOffsetY = self.cameraDevice.centerPointOffsetY;
    self.glkViewController.centerPointOffsetR = self.cameraDevice.centerPointOffsetR;
    [self.glkViewController setCurrentContext];
    CGFloat w = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    CGFloat h = w/_videoDataSize.width*_videoDataSize.height;
    [self addChildViewController:self.glkViewController];
    self.glkViewController.view.frame = CGRectMake(0, 64, w ,h);
    [self.view insertSubview:self.glkViewController.view atIndex:0];
    [self.glkViewController didMoveToParentViewController:self];
    [self.glkViewController.view addGestureRecognizer:self.doubleTapOnGLK];
    self.glkViewController.view.userInteractionEnabled = YES;
}

- (void)updateVideoViewFrame{
    CGSize containerSize = CGSizeZero;
    CGRect rect = CGRectZero;
//    UIView *todoView = self.videoView;
    UIView *todoView = self.glkViewController.view;
    if (!todoView.superview){
        return;
    }
    if ([self isLandscapeRight]){
        containerSize = self.view.frame.size;
        CGSize todoSize = [self videoViewSizeInContainerSize:containerSize];
        rect = CGRectMake(0, 0, todoSize.width, todoSize.height);
        todoView.frame = rect;
        todoView.center = CGPointMake(containerSize.width/2, containerSize.height/2);
    }else{
        containerSize.height = self.view.frame.size.height - 64;
        containerSize.width = self.view.frame.size.width;
        CGSize todoSize = [self videoViewSizeInContainerSize:containerSize];
        rect = CGRectMake((containerSize.width-todoSize.width)/2, 64, todoSize.width, todoSize.height);
        todoView.frame = rect;
    }
}

- (CGSize)videoViewSizeInContainerSize:(CGSize)containerSize{
    CGSize size = CGSizeZero;
    CGFloat dataWidth = self.videoDataSize.width;
    CGFloat dataHeight = self.videoDataSize.height;
    CGFloat width = containerSize.width;
    CGFloat height = containerSize.height;
    if (containerSize.width < containerSize.height){
        height = width*(dataHeight/dataWidth);
        if (height > containerSize.height){
            height = containerSize.height;
            width = height*(dataWidth/dataHeight);
        }
    }else{
        width = height*(dataWidth/dataHeight);
        if(width > containerSize.width){
            width = containerSize.width;
            height = width*(dataHeight/dataWidth);
        }
    }
    size = CGSizeMake(width, height);
    return size;
}

- (void)prepareAudio{
    [self.audioPlayer reset];
    NSError *error = nil;
    BOOL ret = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    
    //启用audio session
    ret = [[AVAudioSession sharedInstance] setActive:YES error:&error];
}

- (void)updateTimeLineViewByDeltaTimeStamp:(NSTimeInterval)timeStamp{
    NSDate *todoDate = [self.timeLineView.currentDate dateByAddingTimeInterval:timeStamp];
    NSLog(@"%@",todoDate.description);
    if ([todoDate earlierDate:self.timeLineView.markDateB] == todoDate){
        [self.timeLineView scrollToDate:todoDate andAnimated:YES];
    }else{
        NSTimeInterval diff = timeStamp - self.timeLineView.markDateB.timeIntervalSince1970;
        int n = diff / (60*10);
        if (n <= 0){
            return;
        }
        diff = 60*10*n;
        todoDate = [NSDate dateWithTimeIntervalSince1970:diff];
        [self.timeLineView markDateBAddTimeInterval:diff andAnimated:YES];
        [self.timeLineView scrollToDate:[self.timeLineView.currentDate dateByAddingTimeInterval:diff] andAnimated:YES];
    }
}

- (void)updateRecordingTimeLabelWithLogNum:(int )num{
    int second = num % 60;
    int minute = (int)((num - second)/60) % 60;
    int hour = (int)((num - second - minute*60)/60) % 60;
    NSString *secondStr = second >= 10 ? [NSString stringWithFormat:@"%d",second] : [NSString stringWithFormat:@"0%d",second];
    NSString *minuteStr = minute >= 10 ? [NSString stringWithFormat:@"%d",minute] : [NSString stringWithFormat:@"0%d",minute];
    NSString *hourdStr = hour >= 10 ? [NSString stringWithFormat:@"%d",hour] : [NSString stringWithFormat:@"0%d",hour];
    self.recordingTimeLabel.text = [NSString stringWithFormat:@"%@: %@: %@",hourdStr,minuteStr,secondStr];
}

- (void)configureViewWithStatus:(MHLumiUICameraHomeViewControllerStatus)status
                   withDuration:(NSTimeInterval)duration{
    if (self.qualityButton.selected){
        [self qualityButtonAction:self.qualityButton];
    }
    
    void(^hiddenLoadingView)(NSTimeInterval aTimeInerval) = ^(NSTimeInterval aTimeInerval){
        if (self.loadingView.superview){
//            if (aTimeInerval > 0){
//                [UIView animateWithDuration:aTimeInerval animations:^{
//                    self.loadingView.alpha = 0;
//                } completion:^(BOOL finished) {
//                    [self.loadingView removeFromSuperview];
//                    self.loadingView.alpha = 1;
//                }];
//            }else{
                [self.loadingView removeFromSuperview];
//            }
        }
    };
    
    
    switch (status) {
        case MHLumiUICameraHomeViewControllerStatusWaitBackwardLoading:
        case MHLumiUICameraHomeViewControllerStatusWaitLiveLoading:
        case MHLumiUICameraHomeViewControllerStatusLoading:
            self.loadingTipsLabel.text = @"加载中……";
            [self configureViewWithStatus:MHLumiUICameraHomeViewControllerStatusNormal withDuration:0];
            self.viewStatus = MHLumiUICameraHomeViewControllerStatusLoading;
            [self.view addSubview:self.loadingView];
            break;
        case MHLumiUICameraHomeViewControllerStatusNormal:
            hiddenLoadingView(duration);
            [self setControlPanelHidden:NO withDuration:duration];
            self.recordingTimeLabel.hidden = YES;
            [self.recordingButton removeFromSuperview];
            [self.noNetView removeFromSuperview];
            if ([self isLandscapeRight]){
                [self.view addSubview:self.backButton];
            }else{
                [self.backButton removeFromSuperview];
            }
            self.backwardTimeLabel.hidden = YES;
            [self.navigationController setNavigationBarHidden:[self isLandscapeRight] animated:YES];
            break;
        case MHLumiUICameraHomeViewControllerStatusRecording:
            hiddenLoadingView(duration);
            [self setControlPanelHidden:YES withDuration:duration];
            self.recordingTimeLabel.hidden = NO;
            [self.view addSubview:self.recordingButton];
            [self.noNetView removeFromSuperview];
            [self.backButton removeFromSuperview];
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            break;
        case MHLumiUICameraHomeViewControllerStatusNoNet:
            [self configureViewWithStatus:MHLumiUICameraHomeViewControllerStatusNormal withDuration:duration];
            self.viewStatus = MHLumiUICameraHomeViewControllerStatusNormal;
            [self.view addSubview:self.noNetView];
//            hiddenLoadingView(duration);
//            [self setControlPanelHidden:YES withDuration:duration];
//            self.recordingTimeLabel.hidden = YES;
//            [self.recordingButton removeFromSuperview];
//            [self.view addSubview:self.noNetView];
//            [self.backButton removeFromSuperview];
//            [self.navigationController setNavigationBarHidden:NO animated:YES];
            break;
        case MHLumiUICameraHomeViewControllerStatusWithoutControlPaner:
            hiddenLoadingView(duration);
            [self setControlPanelHidden:YES withDuration:duration];
            self.recordingTimeLabel.hidden = YES;
            [self.recordingButton removeFromSuperview];
            [self.noNetView removeFromSuperview];
            [self.backButton removeFromSuperview];
            self.backwardTimeLabel.hidden = YES;
            [self.navigationController setNavigationBarHidden:[self isLandscapeRight] animated:YES];
            break;
        case MHLumiUICameraHomeViewControllerStatusBackward:
            [self configureViewWithStatus:MHLumiUICameraHomeViewControllerStatusNormal withDuration:duration];
            self.backwardTimeLabel.hidden = NO;
            self.viewStatus = MHLumiUICameraHomeViewControllerStatusBackward;
            break;
        default:
            break;
    }
    self.viewStatus = status;
}

- (void)fireTimerForBackwardWithDate:(NSDate *)date{
    [self updateBackwardLabelWithDate:date];
    if (self.backwardTimer){
        [self.backwardTimer invalidate];
    }
    self.backwardLogDate = date;
    NSLog(@"启动回看Timer,date = %@",date.description);
    __weak typeof(self) weakself = self;
    self.backwardTimer = [MHWeakTimerFactory scheduledTimerWithBlock:1 callback:^{
        NSDate *todoDate = [weakself.backwardLogDate dateByAddingTimeInterval:1];
        weakself.backwardLogDate = todoDate;
        [weakself updateBackwardLabelWithDate:todoDate];
    }];
}

- (void)invalidateTimerForBackward{
    if (self.backwardTimer){
        [self.backwardTimer invalidate];
    }
}

- (void)updateBackwardLabelWithDate:(NSDate *)date{
    NSDateFormatter *timeLineFormatter = [NSDateFormatter cameraBackwardDateFormatter];
    NSString *timerStr = [timeLineFormatter stringFromDate:date];
    NSString *preText = @"回看 | ";
    self.backwardTimeLabel.text = [NSString stringWithFormat:@"%@%@",preText,timerStr];
}

- (void)fireTimerForTimeLineView{
    if (self.timerForTimeLineView){
        [self.timerForTimeLineView invalidate];
    }
    self.markForTimer = [NSDate date].timeIntervalSince1970;
    NSLog(@"启动5分钟Timer,date = %@",[NSDate date].description);
    __weak typeof(self) weakself = self;
    self.timerForTimeLineView = [MHWeakTimerFactory scheduledTimerWithBlock:5*60 callback:^{
        NSDate *currentDate = [NSDate date];
        NSTimeInterval delta = currentDate.timeIntervalSince1970 - weakself.markForTimer;
        NSLog(@"执行5分钟Timer");
        NSLog(@"markForTimer = %@ (%f)",[NSDate dateWithTimeIntervalSince1970:weakself.markForTimer].description,weakself.markForTimer);
        NSLog(@"delta = %f",delta);
        weakself.markForTimer = currentDate.timeIntervalSince1970;
        [weakself updateTimeLineViewByDeltaTimeStamp:delta];
        NSString *jsonStr = [MHLumiTUTKClientHelper ioCtrlGetBackwardTimeJSonString];
        [weakself.lumiTUTKClient getBackwardRecordTimeWithJsonString:jsonStr completeHandler:nil];
    }];
}

- (void)invalidateTimerForTimeLineView{
    if (self.timerForTimeLineView){
        [self.timerForTimeLineView invalidate];
    }
}

- (void)changCameraFormBackwardToLive{
    [self invalidateTimerForBackward];
    [self configureViewWithStatus:MHLumiUICameraHomeViewControllerStatusNormal withDuration:0.5];
    NSDate *currentCameraDate = [[NSDate date] dateByAddingTimeInterval:self.deltaTime_Camera_Sys];
    self.dateLogForWillDrag = currentCameraDate;
    self.markForTimer = currentCameraDate.timeIntervalSince1970;
    [self.timeLineView scrollToDate:currentCameraDate andAnimated:YES];
}

- (void)changCameraFormLiveToBackward{
    [self configureViewWithStatus:MHLumiUICameraHomeViewControllerStatusBackward withDuration:0.5];
    self.markForTimer = self.timeLineView.currentDate.timeIntervalSince1970;
    [self fireTimerForBackwardWithDate:self.timeLineView.currentDate];
//                [weakself configureViewWithStatus:MHLumiUICameraHomeViewControllerStatusBackward withDuration:0.5];
//                [weakself fireTimerForBackwardWithDate:cameraTimeLineView.currentDate];
//    
//                    NSDate *currentCameraDate = [[NSDate date] dateByAddingTimeInterval:weakself.deltaTime_Camera_Sys];
//                    NSLog(@"%@",currentCameraDate.description);
//                    weakself.dateLogForWillDrag = currentCameraDate;
//                    [cameraTimeLineView scrollToDate:currentCameraDate andAnimated:YES];
//                    [weakself configureViewWithStatus:MHLumiUICameraHomeViewControllerStatusNormal withDuration:0.5];
}

#pragma mark - buildSubviews
- (void)buildSubviews{
    [super buildSubviews];
    self.doubleTapOnGLK = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    self.doubleTapOnGLK.numberOfTapsRequired = 2;
    
    self.viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoViewTapAction:)];
    [self.viewTap requireGestureRecognizerToFail:self.doubleTapOnGLK];
    [self.view addGestureRecognizer:self.viewTap];
//    [self.view addSubview:self.videoView];
    [self.view addSubview:self.controlPanelContanerView];
    [self.view addSubview:self.buttonsContanerView];
    [self.view addSubview:self.recordingTimeLabel];
    [self.view addSubview:self.backwardTimeLabel];
    [self setupMainButtonsWithOrientation:UIInterfaceOrientationPortrait];
    
    //这个属性读取时……交互啊……
    [self setControlPanelContanerViewWithMode:0];
    [self.controlPanelContanerView addSubview:self.qualityButton];
    [self configureLayoutWithOrientation:UIInterfaceOrientationPortrait];
    
//    [self.view addSubview:self.loadingView];
}

- (void)setControlPanelContanerViewWithMode:(NSInteger)mode{
    if (self.subButtonArray){
        for (UIButton *button in self.subButtonArray) {
            [button removeFromSuperview];
        }
        [self.subButtonArray removeAllObjects];
    }else{
        self.subButtonArray = [NSMutableArray array];
    }

    switch (mode) {
        case 0:
            [self.subButtonArray addObject:self.rotationButton];
            [self.subButtonArray addObject:self.fourRButton];
            [self.subButtonArray addObject:self.muteButton];
            [self.subButtonArray addObject:self.motionButton];
            break;
        case 1:
            [self.subButtonArray addObject:self.rotationButton];
            [self.subButtonArray addObject:self.muteButton];
            [self.subButtonArray addObject:self.motionButton];
            break;
        default:
            break;
    }
    
    for (UIButton *button in _subButtonArray) {
        [self.controlPanelContanerView addSubview:button];
    }
    
    UIButton *lastButton = nil;
    for (UIButton *button in self.subButtonArray) {
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.controlPanelContanerView);
            if (lastButton){
                make.right.equalTo(lastButton.mas_left);
            }else{
                make.right.equalTo(self.controlPanelContanerView).mas_offset(-7.5);
            }
            make.width.mas_equalTo(48);
        }];
        lastButton = button;
    }
}

- (void)setupMainButtonsWithOrientation:(UIInterfaceOrientation)orientation{
    for (UIButton *button in self.mainButtonArray) {
        [button removeFromSuperview];
    }
    [self.mainButtonArray removeAllObjects];
    if (orientation == UIDeviceOrientationPortrait){
        self.buttonsContanerView.backgroundColor = [MHColorUtils colorWithRGB:0x141212 alpha:0.6];
        [self.recordButton setImage:[UIImage imageNamed:@"lumi_camera_record_line"] forState:UIControlStateNormal];
        [self.photoButton setImage:[UIImage imageNamed:@"lumi_camera_photos_line"] forState:UIControlStateNormal];
        [self.talkbackButton setImage:[UIImage imageNamed:@"lumi_camera_talkback_line"] forState:UIControlStateNormal];

        [self.mainButtonArray addObject:self.previewButton];
        [self.mainButtonArray addObject:self.recordButton];
        [self.mainButtonArray addObject:self.photoButton];
        [self.mainButtonArray addObject:self.talkbackButton];
    }else{
        self.buttonsContanerView.backgroundColor = [UIColor clearColor];
        [self.recordButton setImage:[UIImage imageNamed:@"lumi_camera_video_record"] forState:UIControlStateNormal];
        [self.photoButton setImage:[UIImage imageNamed:@"lumi_camera_video_photo"] forState:UIControlStateNormal];
        [self.talkbackButton setImage:[UIImage imageNamed:@"lumi_camera_video_talkback"] forState:UIControlStateNormal];
        
        [self.mainButtonArray addObject:self.recordButton];
        [self.mainButtonArray addObject:self.photoButton];
        [self.mainButtonArray addObject:self.talkbackButton];
    }
    
    for (UIButton *button in self.mainButtonArray) {
        [self.buttonsContanerView addSubview:button];
    }
}

#pragma mark - configureLayout
- (void)configureLayoutWithOrientation:(UIInterfaceOrientation)orientation{
    if (orientation != UIInterfaceOrientationLandscapeRight){
        [self.buttonsContanerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.height.mas_equalTo(kButtonsContanerViewHeight);
            make.bottom.equalTo(self.view);
        }];
        
        UIButton *lastButton = nil;
        for (UIButton *button in self.mainButtonArray) {
            [button mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(self.buttonsContanerView);
                if (lastButton){
                    make.left.equalTo(lastButton.mas_right);
                }else{
                    make.left.equalTo(self.buttonsContanerView.mas_left);
                }
                make.width.mas_equalTo(self.buttonsContanerView.mas_width).multipliedBy(1.0/self.mainButtonArray.count);
            }];
            lastButton = button;
        }
        
        [self.controlPanelContanerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.buttonsContanerView.mas_top).mas_offset(-kTimeLineViewHeight);
            make.height.mas_equalTo(kControlPanelContanerView + 10);
        }];
    }else{
        [self.buttonsContanerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.right.equalTo(self.view);
            make.width.mas_equalTo(kButtonsContanerViewHeight);
            make.bottom.equalTo(self.timeLineView.mas_top);
        }];
        
        UIButton *lastButton = nil;
        for (UIButton *button in self.mainButtonArray) {
            [button mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self.buttonsContanerView);
                if (lastButton){
                    make.top.equalTo(lastButton.mas_bottom);
                }else{
                    make.top.equalTo(self.buttonsContanerView);
                }
                make.height.mas_equalTo(self.buttonsContanerView.mas_height).multipliedBy(1.0/self.mainButtonArray.count);
            }];
            lastButton = button;
        }
        
        [self.controlPanelContanerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.right.equalTo(self.buttonsContanerView.mas_left);
            make.bottom.equalTo(self.view).mas_offset(-kTimeLineViewHeight);
            make.height.mas_equalTo(kControlPanelContanerView + 10);
        }];
    }
    
    [self addTimeLineViewLayoutWithOrientation:orientation];
    
    [self.qualityButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.controlPanelContanerView).mas_offset(25);
        make.centerY.equalTo(self.controlPanelContanerView);
        [self.qualityButton sizeToFit];
        make.size.mas_equalTo(CGSizeMake(self.qualityButton.bounds.size.width+10, self.qualityButton.bounds.size.height+2));
    }];
    
//    [self addVideoViewLayoutWithRadio:16.0/9.0];

}

- (void)addTimeLineViewLayoutWithOrientation:(UIInterfaceOrientation)orientation{
    if (orientation != UIInterfaceOrientationLandscapeRight){
        [self.timeLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.height.mas_equalTo(kTimeLineViewHeight);
            make.bottom.equalTo(self.buttonsContanerView.mas_top);
        }];
    }else{
        [self.timeLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.height.mas_equalTo(kTimeLineViewHeight);
            make.bottom.equalTo(self.view);
        }];
    }
}

- (void)addVideoViewLayoutWithRadio:(CGFloat)width_height{
//    CGFloat topPadding = 0;
//    if (self.navigationController.navigationBarHidden){
//        topPadding = 64;
//    }
//    CGFloat w = [self isLandscapeRight] ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width;
//    CGFloat h = w/width_height;
//    [self.videoView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake(w, h));
//        make.top.equalTo(self.view).offset(topPadding);
//        make.centerX.equalTo(self.view);
//    }];
}

#pragma mark - setter and getter

- (UIView *)buttonsContanerView{
    if (!_buttonsContanerView){
        UIView *aView = [[UIView alloc] init];
        aView.backgroundColor = [MHColorUtils colorWithRGB:0x141212 alpha:0.6];
        _buttonsContanerView = aView;
    }
    return _buttonsContanerView;
}

- (MHLumiCameraTimeLineView *)timeLineView{
    if (!_timeLineView){
        if (_cameraCurrentDate == nil){
            return nil;
        }
        NSDate *markDate1 = [_cameraCurrentDate dateByAddingTimeInterval:-60*60*48];
        NSDate *markDate2 = _cameraCurrentDate;
        NSDate *startDate = [[markDate1 startDateInHour] dateByAddingTimeInterval:-30*60];
        NSDate *endDate = [[_cameraCurrentDate endDateInHour] dateByAddingTimeInterval:5*60*60+30*60];
        _timeLineView = [[MHLumiCameraTimeLineView alloc] initWithFrame:CGRectZero startDate:startDate andEndDate:endDate andDefaultDate:markDate2 andMarkDateA:markDate1 andMarkDateB:markDate2];
        _timeLineView.backgroundColor = [MHColorUtils colorWithRGB:0x141212 alpha:0.6];
        _timeLineView.delegate = self;
    }
    return _timeLineView;
}

- (UIButton *)previewButton{
    if (!_previewButton){
        UIButton *button = [[UIButton alloc] init];
        [button addTarget:self action:@selector(previewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[self previewButtonNormalImage] forState:UIControlStateNormal];
        _previewButton = button;
    }
    return _previewButton;
}

- (UIButton *)recordButton{
    if (!_recordButton){
        UIButton *button = [[UIButton alloc] init];
        [button addTarget:self action:@selector(recordButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"lumi_camera_record_line"] forState:UIControlStateNormal];
        _recordButton = button;
    }
    return _recordButton;
}

- (UIButton *)photoButton{
    if (!_photoButton){
        UIButton *button = [[UIButton alloc] init];
        [button addTarget:self action:@selector(photoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"lumi_camera_photos_line"] forState:UIControlStateNormal];
        _photoButton = button;
    }
    return _photoButton;
}

- (UIButton *)talkbackButton{
    if (!_talkbackButton){
        UIButton *button = [[UIButton alloc] init];
        [button addTarget:self action:@selector(talkbackButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(talkbackButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(talkbackButtonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        [button setImage:[UIImage imageNamed:@"lumi_camera_talkback_line"] forState:UIControlStateNormal];
        _talkbackButton = button;
    }
    return _talkbackButton;
}

- (UIButton *)recordingButton{
    if (!_recordingButton){
        UIButton *button = [[UIButton alloc] init];
        [button addTarget:self action:@selector(recordingButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"lumi_camera_recording_line"] forState:UIControlStateNormal];
        _recordingButton = button;
    }
    return _recordingButton;
}

- (UIButton *)backButton{
    if (!_backButton){
        UIButton *aButton = [[UIButton alloc] init];
        [aButton setImage:[UIImage imageNamed:@"lumi_camera_video_backbutton"] forState:UIControlStateNormal];
        [aButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _backButton = aButton;
    }
    return _backButton;
}

- (UIView *)controlPanelContanerView{
    if (!_controlPanelContanerView){
        UIView *aView = [[UIView alloc] init];
        _controlPanelContanerView = aView;
    }
    return _controlPanelContanerView;
}

- (UIView *)noNetView{
    if (!_noNetView){
        UIView *aView = [[UIView alloc] init];
        aView.backgroundColor = [UIColor blackColor];
        UIImage *nonetImage = [UIImage imageNamed:@"wifi"];
        UIImageView *logoImageView = [[UIImageView alloc] initWithImage:nonetImage];
        [aView addSubview:logoImageView];
        [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(aView);
        }];
        UILabel *tipLabel = [[UILabel alloc] init];
        tipLabel.tag = 789;
        tipLabel.text = @"连接失败，触摸重试";
        tipLabel.numberOfLines = 0;
        tipLabel.textColor = [UIColor whiteColor];
        [tipLabel sizeToFit];
        [aView addSubview:tipLabel];
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(logoImageView);
            make.top.equalTo(logoImageView.mas_bottom).mas_offset(8);
        }];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(noNetViewTapAction:)];
        [aView addGestureRecognizer:tap];
        _noNetView = aView;
    }
    return _noNetView;
}

- (UILabel *)loadingTipsLabel{
    if (!_loadingTipsLabel){
        UILabel *aLabel = [[UILabel alloc] init];
        aLabel.textColor = [UIColor whiteColor];
        aLabel.text = @"加载中……";
        _loadingTipsLabel = aLabel;
    }
    return _loadingTipsLabel;
}

- (UIView *)loadingView{
    if (!_loadingView){
        UIView *aView = [[UIView alloc] init];
        aView.userInteractionEnabled = YES;
        aView.backgroundColor = [MHColorUtils colorWithRGB:0x141212 alpha:0.6];
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [aView addSubview:indicatorView];
        UILabel *tipLabel = [self loadingTipsLabel];
        [aView addSubview:tipLabel];
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(aView);
        }];
        [indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(tipLabel.mas_top).offset(-8);
            make.centerX.equalTo(aView);
            make.size.mas_equalTo(CGSizeMake(50, 50));
        }];
        [indicatorView startAnimating];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoViewTapAction:)];
        [aView addGestureRecognizer:tap];
        _loadingView = aView;
    }
    return _loadingView;
}

- (UILabel *)recordingTimeLabel{
    if (!_recordingTimeLabel){
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [MHColorUtils colorWithRGB:0xff0000];
        label.hidden = YES;
        label.textAlignment = NSTextAlignmentCenter;
        _recordingTimeLabel = label;
    }
    return _recordingTimeLabel;
}

- (UIButton *)motionButton{
    if (!_motionButton){
        UIButton *button = [[UIButton alloc] init];
        [button addTarget:self action:@selector(motionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"lumi_camera_video_motion"] forState:UIControlStateNormal];
        _motionButton = button;
    }
    return _motionButton;
}

- (UIButton *)muteButton{
    if (!_muteButton){
        UIButton *button = [[UIButton alloc] init];
        [button addTarget:self action:@selector(muteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"lumi_camera_video_mute"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"lumi_camera_video_notmute"] forState:UIControlStateSelected];
        button.selected = _logForMute;
        _muteButton = button;
    }
    return _muteButton;
}

- (UIButton *)fourRButton{
    if (!_fourRButton){
        UIButton *button = [[UIButton alloc] init];
        [button addTarget:self action:@selector(fourRButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"lumi_camera_video_fourR"] forState:UIControlStateNormal];
        _fourRButton = button;
    }
    return _fourRButton;
}

- (UIButton *)rotationButton{
    if (!_rotationButton){
        UIButton *button = [[UIButton alloc] init];
        [button addTarget:self action:@selector(rotationButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"lumi_camera_video_rotation"] forState:UIControlStateNormal];
        _rotationButton = button;
    }
    return _rotationButton;
}

- (UIButton *)qualityButton{
    if (!_qualityButton){
        UIButton *button = [[UIButton alloc] init];
        [button addTarget:self action:@selector(qualityButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"清晰" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.layer.borderWidth = 0.5;
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.layer.cornerRadius = 5;
        _qualityButton = button;
    }
    return _qualityButton;
}

- (UIView *)qualityOpitionView{
    if (!_qualityOpitionView){
        if (self.opitionTitles.count <= 0){
            return nil;
        }
        CGFloat w = 70;
        CGFloat h = 99;
        UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 99)];
        UIButton *(^fetchButton)(NSString * title, NSInteger tag) = ^(NSString *title, NSInteger tag){
            UIButton *button = [[UIButton alloc] init];
            [button setTitle:title forState:UIControlStateNormal];
            button.tag = tag;
            [button addTarget:self action:@selector(qualityOpitionViewAction:) forControlEvents:UIControlEventTouchUpInside];
            return button;
        };
        for (NSInteger index = 0; index < self.opitionTitles.count; index ++) {
            UIButton *aButton = fetchButton(self.opitionTitles[index],index);
            aButton.frame = CGRectMake(0, index * h/3, w, h/3);
            [aView addSubview:aButton];
        }
        CGFloat lineWidth = w * 0.5;
        CGFloat lineX = (w - lineWidth)/2;
        for (NSInteger index = 0; index < self.opitionTitles.count-1; index ++) {
             UIView *line = [[UIView alloc] initWithFrame:CGRectMake(lineX, h/3*(index+1), lineWidth, 0.5)];
            line.backgroundColor = [UIColor whiteColor];
            [aView addSubview:line];
        }
        aView.backgroundColor = [MHColorUtils colorWithRGB:0x141212 alpha:0.6];
        aView.layer.cornerRadius = 3;
        _qualityOpitionView = aView;
    }
    return _qualityOpitionView;
}

//- (MHEAGLView *)videoView{
//    if (!_videoView){
//        _videoDataSize = CGSizeMake(1280.0, 720.0);
//        CGFloat w = [[UIScreen mainScreen] bounds].size.width ;
//        CGFloat h = w/_videoDataSize.width*_videoDataSize.height;
//        CGRect rect = CGRectMake(0, 64, w, h);
//        MHEAGLView *aView = [[MHEAGLView alloc] initWithFrame:rect];
//        [aView setOpaque:YES];
//        [aView setDataSize:_videoDataSize.width andHeight:_videoDataSize.height];
//        _videoView = aView;
//    }
//    return _videoView;
//}

- (MHLumiRecorder2 *)lumiRecorder{
    if (!_lumiRecorder){
        _lumiRecorder = [[MHLumiRecorder2 alloc] init];
        _lumiRecorder.delegate = self;
    }
    return _lumiRecorder;
}

- (UILabel *)backwardTimeLabel{
    if (!_backwardTimeLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 1;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [MHColorUtils colorWithRGB:0x141212 alpha:0.4];
        label.font = [UIFont systemFontOfSize:14];
        label.text = @"回放 | ";
        _backwardTimeLabel = label;
    }
    return _backwardTimeLabel;
}

- (NSMutableArray *)mainButtonArray{
    if (!_mainButtonArray){
        _mainButtonArray = [NSMutableArray array];
    }
    return _mainButtonArray;
}

- (UIImage *)previewButtonBlackImage{
    return [UIImage imageNamed:@"lumi_camera_previewButton_blackBG"];
}

- (UIImage *)previewButtonNormalImage{
    return [UIImage imageNamed:@"lumi_camera_preview_line"];
}

- (UIImage *)previewButtonWhiteImage{
    return [UIImage imageNamed:@"lumi_camera_previewButton_white"];
}

- (NSArray<NSString *> *)opitionTitles{
    if (!_opitionTitles){
        _opitionTitles = @[@"清晰",@"流畅",@"自动"];
    }
    return _opitionTitles;
}

- (BOOL)isLandscapeRight{
    if ([self.delegate respondsToSelector:@selector(homeViewControllerCurrentInterfaceOrientation:)]){
        if ([self.delegate homeViewControllerCurrentInterfaceOrientation:self] == UIInterfaceOrientationLandscapeRight){
            return YES;
        }
    }
    return NO;
}

- (PHAssetCollection *)lumiCameraAssetCollection{
    if (!_lumiCameraAssetCollection){
        _lumiCameraAssetCollection = [MHLumiCameraMediaDataManager lumiCameraAssetCollection];
    }
    return _lumiCameraAssetCollection;
}

- (MHLumiAudioPlayer *)audioPlayer{
    if (!_audioPlayer) {
        _audioPlayer = [MHLumiAudioPlayer shareInstance];
        [_audioPlayer reset];
    }
    return _audioPlayer;
}

@end
