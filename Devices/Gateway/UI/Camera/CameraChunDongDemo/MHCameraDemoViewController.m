//
//  MHCameraDemoViewController.m
//  MiHome
//
//  Created by huchundong on 2016/8/23.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHCameraDemoViewController.h"
#import "MHDeviceCameraDemo.h"
//#import "MHTutkDemoClient.h"
//#import "MHTutkCommand.h"
#import "TUTKClient.h"
#import "MHLumiRecorder2.h"

#import <ffmpegWrapper/MHVideoFrameYUV.h>
#import <ffmpegWrapper/MHEAGLView.h>

#import "MHTipsView.h"
#include "neaacdec.h"
//#import "AudioUtility/PlayAudio.h"

#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>
#import <AVFoundation/AVAssetWriterInput.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#include "libavformat/avformat.h"
#include "libavformat/avio.h"
#import <ffmpegWrapper/MHVideoFrameYUV.h>
#import <ffmpegWrapper/MHVideoMaker.h>
#include "libavcodec/avcodec.h"
#import "AudioRecorder.h"
#import "aacdecoder_lib.h"
#import "PlayAudio.h"
#import "MHLumiTUTKClient.h"
#import "MHLumiNeAACDecoder.h"
#import "MHLumiGLKViewController.h"
#import "MHLumiYUVBufferHelper.h"
#import "MHLumiMuxer.h"
#import <Photos/Photos.h>
#import "MHLumiLocalCachePathHelper.h"
#define AUDIO_OUTBUFFER_LENGTH 10000
#define AUDIO_INBUFFER_LENGH 1000

@interface MHCameraDemoViewController()<MHLumiTUTKClientDelegate,MHLumiGLKViewControllerDataSource,MHLumiRecorder2Delegate>
@property (nonatomic, strong) MHLumiTUTKClient *lumiTUTKClient;
@property (nonatomic, strong) MHLumiNeAACDecoder *lumiNeAACDecoder;
@property (nonatomic, strong) MHLumiGLKViewController *glkViewController;
@property (nonatomic, strong) NSData *yuvData;
@property (nonatomic, strong) MHLumiRecorder2 *recorder;
@property (nonatomic, assign) NSInteger isGranted;
@property (nonatomic, strong) NSMutableData *aacAllData;
@property (nonatomic, strong) NSFileHandle *h264FileHandle;

//

@property (copy, nonatomic) NSString *h264Filename_V;
@property (copy, nonatomic) NSString *inputFilename_A;
@property (copy, nonatomic) NSString *outputFilename;

@end

@implementation MHCameraDemoViewController{
    MHEAGLView*         _eaglView;
    TUTKClient*         _client;
    
    dispatch_queue_t _audioDecoderQueue;
    NeAACDecHandle *aachandle;
    
    NeAACDecFrameInfo hinfo;//使用FAAD解码音频后的的属性结构体
    
    void *outbuffer;
    
    unsigned char *audioinbuffer;//音频输入数据
    
    void* audioOutBuffer;//解码后的音频数据缓存
    
    PlayAudio *_audioPlayer;
    
    BOOL    isinit;
    AudioRecorder *audioRecorder;
    struct AAC_DECODER_INSTANCE *FDKAACHandle;
    
    NSMutableData *_cacheBuffer;
    unsigned long long _cacheOutSize;
    
    BOOL _isNeedDropFrames;
    
    BOOL _isAudioPlay;
    FILE *_outputFile;
    int num;
    unsigned char *pbyYUV;
    AVFrame *_todoFrame;
    BOOL _shouldUpdate;
    
    
    //声明变量
    AVFormatContext     *pFormatCtx;
    AVCodecContext      *pCodecCtx;
    AVCodec             *pCodec;
    AVFrame             *pFrame;
    AVPacket            *packet;
    void *              outBuffer;
    int                 videoStreamIndex;
    unsigned char       *buf;
    int                 _frameWidth;
    int                 _frameHeight;
    bool                _writeAble;
}
@synthesize client = _client;
- (instancetype)initWithDevice:(MHDevice *)device{
    self = [super initWithDevice:device];
    if(self){
        self.device = device;
        [self initTUTKClient];
        //        self.glkViewController = [[MHLumiGLKViewController alloc] initWithDewrapType: FE_DEWARP_AROUNDVIEW mountType: FE_MOUNT_FLOOR];
        //        self.glkViewController.dataSource = self;
        CGFloat w = CGRectGetWidth([[UIScreen mainScreen] bounds]);
        CGFloat h = w/1280.0*720;
        //        [self addChildViewController:self.glkViewController];
        //        self.glkViewController.view.frame = CGRectMake(0, h + 10, w ,w );
        //        [self.view addSubview:self.glkViewController.view];
        //        [self.glkViewController didMoveToParentViewController:self];
        
        _eaglView = [[MHEAGLView alloc] initWithFrame:CGRectMake(0, 64, w ,h ) ];
        [_eaglView setOpaque:YES];
        [_eaglView setDataSize:1280.0 andHeight:720.0];
        [self.view addSubview:_eaglView];
        
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"声音开关" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(toggleAudio:) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 20;
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = [UIColor blackColor].CGColor;
        [btn sizeToFit];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.frame = CGRectMake( 0,CGRectGetHeight(self.view.frame)-60,CGRectGetWidth(self.view.frame),40);
        [self.view addSubview:btn];
        
        UIButton* btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn1 setTitle:@"画面模式" forState:UIControlStateNormal];
        [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn1 addTarget:self action:@selector(changVideoMode:) forControlEvents:UIControlEventTouchUpInside];
        btn1.layer.cornerRadius = 20;
        btn1.layer.borderWidth = 1;
        btn1.layer.borderColor = [UIColor blackColor].CGColor;
        [btn1 sizeToFit];
        btn1.tag = 0;
        btn1.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn1.frame = CGRectMake( 0,CGRectGetHeight(self.view.frame)-130,CGRectGetWidth(self.view.frame)/3,40);
        [self.view addSubview:btn1];
        CGFloat btnw = CGRectGetWidth(self.view.frame)/3;
        UIButton* btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn2 setTitle:@"想对讲" forState:UIControlStateNormal];
        [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn2 addTarget:self action:@selector(talkback:) forControlEvents:UIControlEventTouchUpInside];
        btn2.layer.cornerRadius = 20;
        btn2.layer.borderWidth = 1;
        btn2.layer.borderColor = [UIColor blackColor].CGColor;
        btn2.tag = 0;
        [btn2 sizeToFit];
        btn2.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn2.frame = CGRectMake( btnw,CGRectGetHeight(self.view.frame)-130,btnw,40);
        [self.view addSubview:btn2];
        
        UIButton* btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn3 setTitle:@"摄像头模式" forState:UIControlStateNormal];
        [btn3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn3 addTarget:self action:@selector(recordButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        btn3.layer.cornerRadius = 20;
        btn3.layer.borderWidth = 1;
        btn3.layer.borderColor = [UIColor blackColor].CGColor;
        btn3.tag = 0;
        [btn3 sizeToFit];
        btn3.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn3.frame = CGRectMake( btnw*2,CGRectGetHeight(self.view.frame)-130,btnw,40);
        [self.view addSubview:btn3];
        
        UIButton* btn4 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn4 setTitle:@"清晰度" forState:UIControlStateNormal];
        [btn4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn4 addTarget:self action:@selector(changVideoQuality:) forControlEvents:UIControlEventTouchUpInside];
        btn4.layer.cornerRadius = 20;
        btn4.layer.borderWidth = 1;
        btn4.layer.borderColor = [UIColor blackColor].CGColor;
        btn4.tag = 0;
        [btn4 sizeToFit];
        btn4.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn4.frame = CGRectMake( (CGRectGetWidth(self.view.frame)-btnw)/2,CGRectGetHeight(self.view.frame)-200,btnw,40);
        [self.view addSubview:btn4];
        self.aacAllData = [NSMutableData data];
        num = 0;
        self.isNavBarHidden = NO;
        self.isNavBarTranslucent = NO;
        _todoFrame = avcodec_alloc_frame();
        _shouldUpdate = NO;
        _isGranted = 0;
        _writeAble = NO;
       
    }
    return self;
}

- (void)timerAction{
    
//    self.inputFileName = @"p360fec2.h264";
//    self.inputFilePath = [[NSBundle mainBundle] pathForResource:self.inputFileName ofType:nil];
//    [self initffmpeg];
//    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    int width = 0;
    int heigth = 0;
    if ([self readAVFrameFileWithFrame:pFrame width:&width height:&heigth]){
        NSLog(@"width: %d, height: %d",width,heigth);
        MHVideoFrameYUV* yuvFrame = [[MHVideoFrameYUV alloc] initWithFrame: pFrame
                                                                  withSize:CGSizeMake(width, heigth)];
        if (yuvFrame.size.width > 0 && yuvFrame.size.height > 0)
        {
            //        NSLog(@"更新画面");
            [_eaglView setDataSize:(int)yuvFrame.size.width andHeight:(int)yuvFrame.size.height];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_eaglView drawVideoFrame:yuvFrame];
            CGFloat w = [[UIScreen mainScreen] bounds].size.width;
            CGFloat h = w/(yuvFrame.size.width)*(yuvFrame.size.height);
            CGRect rect = CGRectMake(0, 64, w, h);
            self->_eaglView.frame = rect;
        });
    }
}

- (void)dealloc{
    [_lumiTUTKClient deinitConnection];
    [self stopAudioPlay];
    [_audioPlayer reset];
    avcodec_free_frame(&_todoFrame);
    NSLog(@"%@ 析构了",self.description);
}

- (void)initTUTKClient{
    XM_WS(ws);
    MHDeviceCameraDemo* demoDevice =(MHDeviceCameraDemo*)self.device;
    [[MHTipsView shareInstance] showTips:@"开始获取UDID" modal:NO];
    [demoDevice getUidSuccess:^(NSString *udid, NSString *password) {
        XM_SS(ss,ws);
        [[MHTipsView shareInstance] showTips:@"开始setVideoWithOnOff" modal:NO];
        [demoDevice setVideoWithOnOff:YES uid:udid success:^(BOOL currentOnOrOff) {
            MHLumiTUTKConfiguration *cfg = [MHLumiTUTKConfiguration defaultConfiguration];
            cfg.udid = udid;
            ss.lumiTUTKClient = [[MHLumiTUTKClient alloc] initWithConfiguration:cfg];
            ss.lumiTUTKClient.delegate = ws;
            [[MHTipsView shareInstance] showTips:@"开始initConnectionWithCompletedHandler" modal:NO];
            [ss.lumiTUTKClient initConnectionWithCompletedHandler:^(MHLumiTUTKClient *client, int retCode) {
                if (retCode < 0){
                    [[MHTipsView shareInstance] showFailedTips:@"initConnectionWithCompletedHandler 失败" duration:2 modal:YES];
                    return;
                }
                NSString *jsonStr = [MHLumiTUTKClientHelper ioCtrlJSonStringWithAVChannelId:client.avChannelId];
                [[MHTipsView shareInstance] showTips:@"开始startVideoStreamWithJsonString" modal:NO];
                [client startVideoStreamWithJsonString:jsonStr startRequestData:YES completedHandler:^(MHLumiTUTKClient *client, int retCode) {
                    if (retCode < 0){
                        [[MHTipsView shareInstance] showFailedTips:@"startVideoStreamWithJsonString 失败" duration:2 modal:YES];
                        return;
                    }else{
                        [[MHTipsView shareInstance] showFinishTips:@"连接完成" duration:1 modal:YES];
                    }
                }];
            }];
        } failure:^(NSError *error) {
            [[MHTipsView shareInstance] showFailedTips:@"setVideoWithOnOff 失败" duration:2 modal:YES];
        }];
        
    } failure:^(NSError *error) {
        [[MHTipsView shareInstance] showFailedTips:@"getUidSuccess 失败" duration:2 modal:YES];
    }];
}
#pragma mark - MHLumiTUTKClientDelegate
- (void)client:(MHLumiTUTKClient *)client onVideoReceived:(AVFrame*)frame
avcodecContext:(AVCodecContext*)avcodecContext
 gotPicturePtr:(int)gotPicturePtr{
    MHVideoFrameYUV* yuvFrame = [[MHVideoFrameYUV alloc] initWithFrame: frame
                                                              withSize:CGSizeMake(avcodecContext->width, avcodecContext->height)];
    if (yuvFrame.size.width > 0 && yuvFrame.size.height > 0)
    {
        [_eaglView setDataSize:(int)yuvFrame.size.width andHeight:(int)yuvFrame.size.height];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"更新画面");
        [self->_eaglView drawVideoFrame:yuvFrame];
        CGFloat w = [[UIScreen mainScreen] bounds].size.width;
        CGFloat h = w/(yuvFrame.size.width)*(yuvFrame.size.height);
        CGRect rect = CGRectMake(0, 64, w, h);
        self->_eaglView.frame = rect;
    });
}

- (void)client:(MHLumiTUTKClient *)client videoBuffer:(const void *)videoBuffer length:(int)length{
    NSData *todoData = [NSData dataWithBytes:videoBuffer length:length];
    if (_writeAble){
        NSLog(@"写入了");
        [self.h264FileHandle writeData:todoData];
    }
}

- (MHLumiGLKViewData)fetchBufferData:(MHLumiGLKViewController *)glkViewController{
    MHLumiGLKViewData glkViewData;
    _yuvData = [MHLumiYUVBufferHelper yuvBufferWithYData:_todoFrame->data
                                                linesize:_todoFrame->linesize
                                              frameWidth:_todoFrame->width
                                             frameHeight:_todoFrame->height];
    glkViewData.buffer = _yuvData.bytes;//[self readAVFrameFile];
    glkViewData.width = _todoFrame->width;
    glkViewData.height = _todoFrame->height;
    return glkViewData;
}

- (bool)shouldUpdateBuffer:(MHLumiGLKViewController *)glkViewController{
    static int count;
//    _shouldUpdate = [self.lumiTUTKClient proactiveFetchVideoDataWithABAVFrame:_todoFrame gotPicturePtr:&count];
    int picSize = _todoFrame->height * _todoFrame->width;
    if (picSize <= 0) {
        _shouldUpdate = NO;
        return _shouldUpdate;
    }
    return _shouldUpdate;
}

- (void)client:(MHLumiTUTKClient *)client onAudioReceived:(void *)audiobuffer length:(int)length{
    NSData *todoData = [NSData dataWithBytes:audiobuffer length:length];
    [self.aacAllData appendData:todoData];
    if (!self.lumiNeAACDecoder){
        self.lumiNeAACDecoder = [[MHLumiNeAACDecoder alloc] initWithaudioData:audiobuffer length:length samplerate:44100 channelNum:2];
    }
    
    void *audioOutBuffe1r = [self.lumiNeAACDecoder decodeAudioData:audiobuffer length:length];
    unsigned long dataLength = [self.lumiNeAACDecoder dataLengthWithFormatId];
    if (dataLength > 0){
        NSLog(@"IIIIIIIIIIIIIIIII");
        NSData *audioData = [[NSData alloc] initWithBytes:audioOutBuffe1r length:dataLength];
        [_audioPlayer addAudioBuffer:audioData];
    }
}

- (void)decodeVideoBuffer:(MHVideoFrameYUV*)frame{
    [[MHTipsView shareInstance] hide];
    if (frame.size.width > 0 && frame.size.height > 0)
    {
        NSLog(@"更新画面");
        [_eaglView setDataSize:(int)frame.size.width andHeight:(int)frame.size.height];
    }
    [_eaglView drawVideoFrame:frame];
}

- (void)prepareAudio
{
    NSError *error = nil;
    BOOL ret = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    
    //启用audio session
    ret = [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (_audioPlayer == nil) {
        _audioPlayer = [PlayAudio shareInstance];
    }
    [_audioPlayer reset];
}

-(void)startAudioPlay
{
    if (!_isAudioPlay) {
        _isAudioPlay = YES;
        [_audioPlayer startPlay];
    }
}

-(void)stopAudioPlay
{
    if (_isAudioPlay) {
        _isAudioPlay = NO;
        [_audioPlayer stopPlay];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_eaglView enterForeground];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[MHTipsView shareInstance] hide];
    [self.h264FileHandle closeFile];
}
- (void)onBack:(id)sender{
    [super onBack:sender];
    [_client deinitConnectoin:^(){
        
    } fail:^(NSInteger errCode){
        
    }];
    
    //    [_client deinit]
}
#pragma mark audio -
- (void)toggleAudio:(UIButton*)sender{
    __weak typeof(self) weakself = self;
    NSString *jsonStr = [MHLumiTUTKClientHelper ioCtrlJSonStringWithAVChannelId:self.lumiTUTKClient.avChannelId];
    if(_isAudioPlay){
        NSString *todoPath = [[MHLumiLocalCachePathHelper defaultHelper] pathWithLocalCacheType:MHLumiLocalCacheTypeTUTKPath andFilename:@"tutk.aac"];
        NSLog(@"todopath: %@",todoPath);
        [self.aacAllData writeToFile:todoPath atomically:YES];
        self.aacAllData = [NSMutableData data];
        [self.lumiTUTKClient stopAudioStreamWithJsonString:jsonStr completedHandler:^(MHLumiTUTKClient *client , int retcode) {
            if (retcode >= 0 || retcode == AV_ER_NOT_INITIALIZED || retcode == kIsNotFetchingVideoData){
                [[MHTipsView shareInstance] showTipsInfo:@"关闭声音成功" duration:2 modal:NO];
                [weakself stopAudioPlay];
            }else{
                [[MHTipsView shareInstance] showTipsInfo:@"声音关闭失败" duration:2 modal:NO];
            }
        }];
        return;
    }
    [self prepareAudio];
    
    [self.lumiTUTKClient startAudioStreamWithJsonString:jsonStr startRequestData:YES completedHandler:^(MHLumiTUTKClient *client, int retCode) {
        if (retCode >= 0){
            [weakself startAudioPlay];
            [[MHTipsView shareInstance] showTipsInfo:@"开启声音成功" duration:1 modal:YES];
            
        }else{
            [[MHTipsView shareInstance] showTipsInfo:@"开启声音失败" duration:1 modal:YES];
            [weakself stopAudioPlay];
        }
    }];
}

- (void)changVideoMode:(UIButton *)sender{
    MHLumiTUTKVideoMode mode;
    sender.tag = (sender.tag + 1)%6;
    switch (sender.tag) {
        case 0:
            mode = MHLumiTUTKVideoModeP180;
            break;
        case 1:
            mode = MHLumiTUTKVideoModeP360;
            break;
        case 2:
            mode = MHLumiTUTKVideoMode1R;
            break;
        case 3:
            mode = MHLumiTUTKVideoMode4R;
            break;
        case 4:
            mode = MHLumiTUTKVideoModeVR;
            break;
        case 5:
            mode = MHLumiTUTKVideoModeORIGIN;
            break;
        default:
            break;
    }
    NSString *json = [MHLumiTUTKClientHelper ioCtrlVideoModeJSonStringWithAVChannelId:self.lumiTUTKClient.avChannelId
                                                                         andVideoMode:mode];
    [[MHTipsView shareInstance] showTips:@"切换中" modal:YES];
    [self.lumiTUTKClient setVideoMode:mode WithJsonString:json completedHandler:^(MHLumiTUTKClient *client, int retcode) {
        if (retcode >= 0){
            [[MHTipsView shareInstance] showTipsInfo:@"切换成功" duration:1 modal:YES];
        }else{
            [[MHTipsView shareInstance] showFailedTips:@"切换失败" duration:1 modal:YES];
        }
    }];
}

- (void)videoOnOff:(UIButton *)sender{
    MHLumiTUTKStreamstatus status = self.lumiTUTKClient.videoStreamStatus;
    BOOL flag = NO;
    if (status == MHLumiTUTKStreamstatusON){
        flag = YES;
    }else if (status == MHLumiTUTKStreamstatusONAndRequest){
        flag = NO;
    }
    [self.lumiTUTKClient setRequestVideoDataOrNotWithFlag:flag];
}

- (void)changVideoQuality:(UIButton *) sender{
    MHLumiTUTKVideoQuality quality = MHLumiTUTKVideoQualityAuto;
    sender.tag = (sender.tag + 1)%3;
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
    [[MHTipsView shareInstance] showTips:@"切换中" modal:YES];
    [self.lumiTUTKClient setVideoQuality:quality WithJsonString:json completedHandler:^(MHLumiTUTKClient *client, int retcode) {
        if (retcode >= 0){
            [[MHTipsView shareInstance] showTipsInfo:@"切换成功" duration:1 modal:YES];
        }else{
            [[MHTipsView shareInstance] showTipsInfo:@"切换失败" duration:1 modal:YES];
        }
    }];
}

- (void)recordButtonAction:(UIButton *)sender{
    if (!_writeAble){
        _writeAble = !_writeAble;
        _h264Filename_V = [[MHLumiLocalCachePathHelper defaultHelper] pathWithLocalCacheType:MHLumiLocalCacheTypeTUTKPath andFilename:@"tutk.h264"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_h264Filename_V]){
            [[NSFileManager defaultManager] removeItemAtPath:_h264Filename_V error:nil];
        }
        [[NSFileManager defaultManager] createFileAtPath:_h264Filename_V contents:nil attributes:nil];
        NSLog(@"_h264Filename_V: %@",_h264Filename_V);
        self.h264FileHandle = [NSFileHandle fileHandleForWritingAtPath:_h264Filename_V];
    }else{
        _writeAble = !_writeAble;
        [self.h264FileHandle closeFile];
        MHLumiMuxer *muxer = [[MHLumiMuxer alloc] init];
        self.outputFilename = [[MHLumiLocalCachePathHelper defaultHelper] pathWithLocalCacheType:MHLumiLocalCacheTypeTUTKPath andFilename:@"ttt.mp4"];
        if ([muxer muxWithInputVideoName:self.h264Filename_V inputAudioName:nil andOutputFileName:self.outputFilename ] >= 0){
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                NSURL *url = [NSURL URLWithString:self.outputFilename];
                [PHAssetCreationRequest creationRequestForAssetFromVideoAtFileURL:url];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (success){
                    NSLog(@"sss");
                }else{
                    NSLog(@"fff");
                }
            }];
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath:_h264Filename_V]){
            [[NSFileManager defaultManager] removeItemAtPath:_h264Filename_V error:nil];
        }
    }

}

- (void)changCameraMode:(UIButton *) sender{
    MHLumiDeviceCameraMode mode = MHLumiDeviceCameraModeCeiling;
    sender.tag = (sender.tag + 1)%3;
    switch (sender.tag) {
        case 0:
            mode = MHLumiDeviceCameraModeFloor;
            break;
        case 1:
            mode = MHLumiDeviceCameraModeCeiling;
            break;
        case 2:
            mode = MHLumiDeviceCameraModeWall;
            break;
        default:
            break;
    }
    [[MHTipsView shareInstance] showTips:@"切换中" modal:YES];
    MHDeviceCameraDemo *camera = (MHDeviceCameraDemo *)self.device;
    [camera setCameraMode:mode success:^(MHDeviceCameraDemo *deviceCamera, MHLumiDeviceCameraMode mode) {
        [[MHTipsView shareInstance] showTipsInfo:@"切换成功" duration:1 modal:YES];
    } failure:^(NSError *error) {
        [[MHTipsView shareInstance] showTipsInfo:@"切换失败" duration:1 modal:YES];
    }];
}

- (void)talkback:(UIButton *)button{
    if (button.tag == -99999) {
        return;
    }
    
    __weak typeof(self) weakself = self;
    NSInteger tag = button.tag;
    if (_isGranted == 0){
        [MHLumiRecorder2 requestRecordPermission:^(BOOL granted) {
            weakself.isGranted = granted ? 1 : -1;
            [weakself talkback:button];
        }];
    }else if (_isGranted == 1){
        button.tag = -99999;
        button.backgroundColor = [UIColor yellowColor];
        if (tag == 0){
            if (weakself.lumiTUTKClient.talkbackServiceStatus == MHLumiTUTKTalkbackStatusDefault){
                [button setTitle:@"开启中" forState:UIControlStateNormal];;
                [weakself.lumiTUTKClient startAndfetchTalkBackServIdWithJsonString:[MHLumiTUTKClientHelper ioCtrlTalkBackStartJSonStringWithAVChannelId:1]
                                                                  completedHandler:^(MHLumiTUTKClient *client, int retcode) {
                                                                      if (retcode<0){
                                                                          [[MHTipsView shareInstance] showFinishTips:@"开启失败" duration:1 modal:YES];
                                                                          button.tag = 0;
                                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                                              [button setTitle:@"想对讲" forState:UIControlStateNormal];;
                                                                              button.backgroundColor = [UIColor whiteColor];
                                                                          });
                                                                      }else{
                                                                          [weakself.recorder open];
                                                                          button.tag = 1;
                                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                                              [[MHTipsView shareInstance] showFinishTips:@"开启成功" duration:1 modal:YES];
                                                                              [button setTitle:@"对讲中" forState:UIControlStateNormal];;
                                                                              button.backgroundColor = [UIColor greenColor];
                                                                          });
                                                                      }
                                                                  }];
            }
        }else if(tag == 1){
            [weakself.recorder close];
            [button setTitle:@"关闭中" forState:UIControlStateNormal];;
            [weakself.lumiTUTKClient stopTalkBackWithJsonString:[MHLumiTUTKClientHelper ioCtrlTalkBackStartJSonStringWithAVChannelId:weakself.lumiTUTKClient.talkbackAVChannelId] completedHandler:^(MHLumiTUTKClient *client, int retcode) {
                button.tag = 0;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[MHTipsView shareInstance] showFinishTips:@"关闭成功" duration:1 modal:YES];
                    [button setTitle:@"想对讲" forState:UIControlStateNormal];;
                    button.backgroundColor = [UIColor whiteColor];
                });
            }];

        }
    }else if (_isGranted == -1){
        NSLog(@"用户不授权麦克风");
    }
}

#pragma mark - MHLumiRecorder2Delegate

- (void)recorderOutput:(MHLumiRecorder2 *)recorder audioData:(NSData *)data2{
//    if (!self.lumiNeAACDecoder){
//        self.lumiNeAACDecoder = [[MHLumiNeAACDecoder alloc] initWithaudioData:data2.bytes length:(int)data2.length samplerate:44100 channelNum:2];
//        //        [self prepareAudio];
//        //        [_audioPlayer startPlay];
//    }
    
    //    NSLog(@"收到数据");
    if (self.lumiTUTKClient.talkbackServiceStatus == MHLumiTUTKTalkbackStatusConnected){
        //            NSLog(@"插入数据");
        [self.lumiTUTKClient addAccData:data2];
    }
    //    void *audioOutBuffe1r = [self.lumiNeAACDecoder decodeAudioData:data2.bytes length:(int)data2.length];
    //    unsigned long dataLength = [self.lumiNeAACDecoder dataLengthWithFormatId];
    //    if (dataLength > 0){
    //        NSLog(@"解码开始播放");
    //        NSData *audioData = [[NSData alloc] initWithBytes:audioOutBuffe1r length:dataLength];
    //        [_audioPlayer addAudioBuffer:audioData];
    //    }
}

- (MHLumiRecorder2 *)recorder{
    if (!_recorder){
        _recorder = [[MHLumiRecorder2 alloc] init];
        _recorder.delegate = self;
    }
    return _recorder;
}

- (void)initffmpegWithInputFilePath:(NSString *)inputFilePath{
    //初始化
    av_register_all();
    avformat_network_init();//初始化网络部分
    pFormatCtx = avformat_alloc_context();
    
    //Open an input stream and read the header. The codecs are not opened.
    //打开媒体文件入口
    if(avformat_open_input(&pFormatCtx,[inputFilePath UTF8String],NULL,NULL)!=0){
        printf("Couldn't open input stream.\n");
        return ;
    }
    
    //没有头文件时候，打开。Read packets of a media file to get stream information.
    if(avformat_find_stream_info(pFormatCtx,NULL)<0){
        printf("Couldn't find stream information.\n");
        return;
    }
    
    videoStreamIndex = -1;
    for(int i=0; i<pFormatCtx->nb_streams; i++)//nb_streams，AVFormatContext的元素个数
        if(pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_VIDEO){
            videoStreamIndex=i;
            break;
        }
    if(videoStreamIndex == -1){//依旧为-1，则没找到stream
        printf("Couldn't find a video stream.\n");
        return;
    }
    
    //找到的流媒体赋值给AVCodecContext，准备解码
    pCodecCtx=pFormatCtx->streams[videoStreamIndex]->codec;
    
    //用于查找FFmpeg的解码器。参数为id，按照id查找解码器，返回解码器AVCodec
    pCodec=avcodec_find_decoder(pCodecCtx->codec_id);
    if(pCodec==NULL){
        printf("Couldn't find Codec.\n");
        return;
    }
    
    //avctx：需要初始化的AVCodecContext。 codec：输入的AVCodec
    if(avcodec_open2(pCodecCtx, pCodec,NULL)<0){
        printf("Couldn't open codec.\n");
        return;
    }
    
    //初始化frame
    pFrame=av_frame_alloc();
    outBuffer=(unsigned char *)av_malloc(pCodecCtx->width * pCodecCtx->height * 1.5);
    
    //AVPacket：解码前数据,存储压缩编码数据相关信息的结构体
    packet=(AVPacket *)av_malloc(sizeof(AVPacket));
    
}

//开始读取文件，读到文件解码
- (BOOL)readAVFrameFileWithFrame:(AVFrame *)kFrame width:(int *)kwitdh height:(int *)kheight{
    //开始读取文件
    int gotPictureCount = -1;
    while(av_read_frame(pFormatCtx, packet)>=0){
        if(packet->stream_index == videoStreamIndex){
            //下面开始真正的解码
            int ret = avcodec_decode_video2(pCodecCtx, kFrame, &gotPictureCount, packet);
            //成功解码
            if(ret >= 0 && gotPictureCount){
                *kwitdh = pCodecCtx->width;
                *kheight = pCodecCtx->height;
                return YES;
            }
        }
    }
    return NO;
}

@end
