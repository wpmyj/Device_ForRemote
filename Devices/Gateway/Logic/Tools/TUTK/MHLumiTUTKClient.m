

//
//  MHLumiTUTKClient.m
//  MiHome
//
//  Created by LM21Mac002 on 16/9/20.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiTUTKClient.h"
#import "NSDateFormatter+lumiDateFormatterHelper.h"
#import "AVFRAMEINFO.h"


const int kInitFFMpegFailure = -111111;
const int kIsFetchingVideoData = - 22222222;
const int kIsNotFetchingVideoData = - 44444444;
const int kIsFetchingAudioData = - 33333333;
const int kIsNotFetchingAudioData = - 66666666;
const int kIsBackwardTimeUnable = - 77777777;
#define kVideoBufSize 400000
#define kFrameInfoSize 64
@interface MHLumiTUTKClient()
@property (nonatomic, assign) int sessionId; //IOTC session ID
@property (nonatomic, assign) int avChannelId; //AV channel ID
@property (nonatomic, assign) int talkbackAVChannelId;
@property (nonatomic, assign) int talkbackServiceId; //talkbackServiceId

@property (atomic, assign) bool isFetchingVideoData;
@property (atomic, assign) bool isFetchingAudioData;
@property (atomic, assign) bool isFFMpegInited;
@property (nonatomic, strong) dispatch_queue_t clientQueue;
@property (nonatomic, strong) dispatch_queue_t fetchVideoDataQueue;
@property (nonatomic, strong) dispatch_queue_t fetchAudioDataQueue;
@property (nonatomic, strong) dispatch_queue_t talkBackQueue;
@property (nonatomic, assign) unsigned int prevFrameIndex;

@property (atomic, strong) NSMutableArray *aacDataSources;
@property (nonatomic, strong) NSMutableArray<MHLumiTUTKBackwordTimeData *> *backwordTimeDatas;
@property (nonatomic, assign) NSInteger isHaveSDCard; //0:未知 | >0：有sd卡 | <0: 没有sd卡

/* ffmpeg */
@property (nonatomic) AVCodec *pCodec;
@property (nonatomic) AVPacket packet;
@property (nonatomic) AVFrame *pVideoFrame;
@property (nonatomic) AVCodecContext *pCodecCtx;

@property (atomic, assign) MHLumiTUTKClientstatus clientStatus;
@property (atomic, assign) MHLumiTUTKStreamstatus videoStreamStatus;
@property (atomic, assign) MHLumiTUTKStreamstatus audioStreamStatus;
@property (atomic, assign) MHLumiTUTKTalkbackStatus talkbackServiceStatus;

@property (nonatomic, assign) MHLumiTUTKVideoMode videoMode;
@property (nonatomic, assign) MHLumiTUTKVideoQuality videoQuality;
@property (nonatomic, assign) CFTimeInterval audioTimeStamp;

@end

@implementation MHLumiTUTKClient{
    char *_videoBufferForP;
}
static BOOL flagForDeInitialize = NO;
- (MHLumiTUTKClient *)initWithConfiguration:(MHLumiTUTKConfiguration *)configurarion{
    self = [super init];
    if (self){
        flagForDeInitialize = NO;
        _configuration = configurarion;
        _clientStatus = MHLumiTUTKClientstatusStandby;
        _prevClientStatus = MHLumiTUTKClientstatusStandby;
        _videoStreamStatus = MHLumiTUTKStreamstatusOFF;
        _audioStreamStatus = MHLumiTUTKStreamstatusOFF;
        
        //TODO: 默认值要从网络读取啊阿啊阿啊阿
        _videoMode = MHLumiTUTKVideoModeORIGIN;
        //TODO: 默认值要从网络读取啊阿啊阿啊阿
        _videoQuality = MHLumiTUTKVideoQualityHigh;
        _videoUpdateInterval = 1.0/30.0;
        _isFetchingVideoData = NO;
        _isFetchingAudioData = NO;
        _isFFMpegInited = NO;
        _sessionId = -1;
        _avChannelId = -1;
        _talkbackAVChannelId = -1;
        _talkbackServiceId = -1;
        _canceled = NO;
        _talkbackServiceStatus = MHLumiTUTKTalkbackStatusDefault;
        _aacDataSources = [NSMutableArray new];
        _clientQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _fetchVideoDataQueue = dispatch_queue_create("fetchVideoDataQueue.MHLumiTUTKClient", DISPATCH_QUEUE_SERIAL);
        _fetchAudioDataQueue = dispatch_queue_create("fetchAudioDataQueue.MHLumiTUTKClient", DISPATCH_QUEUE_SERIAL);
        _talkBackQueue = dispatch_queue_create("talkBackQueue.MHLumiTUTKClient", DISPATCH_QUEUE_SERIAL);
        _prevFrameIndex = -1;
        _audioTimeStamp = CFAbsoluteTimeGetCurrent() - 0.020;
        _backwordTimeDatas = [NSMutableArray array];
        _isHaveSDCard = 0;
    }
    return self;
}

- (void)dealloc{
    NSLog(@"%@ 开始析构",self.description);
    flagForDeInitialize = YES;
    _canceled = YES;
    [self deinitConnection];
    if (!flagForDeInitialize){
        NSLog(@"%@ 半析构了",self.description);
        return;
    }
    [self tutkDeInitialize];
    [self deInitFFMpeg];
    av_frame_free(&_pVideoFrame);
    if (_videoBufferForP != NULL){
        free(_videoBufferForP);
    }
    NSLog(@"%@ 析构了",self.description);
}

#pragma mark - initConnection

- (void)initConnectionWithCompletedHandler:(void (^)(MHLumiTUTKClient *, int))completedHandler{
    if (_clientStatus == MHLumiTUTKClientstatusConnecting || _clientStatus == MHLumiTUTKClientstatusConnected){
        if (completedHandler){
            completedHandler(self,0);
        }
        return;
    }
    __weak typeof(self) weakself = self;
    BOOL(^logMessageAndReturn)(NSString *, int) = ^(NSString *message, int retCode){
        if (retCode < 0 || self.canceled == YES) {
            NSLog(@"%@ error:%d",message ,retCode);
            [weakself deinitConnection];
            if (completedHandler){
                dispatch_async(dispatch_get_main_queue(), ^{
                    completedHandler(weakself, retCode);
                });
            }
            return NO;
        }
        return YES;
    };
    _canceled = NO;
    dispatch_async(self.clientQueue, ^{
        __strong typeof(weakself) strongself = weakself;
        NSLog(@"真正initConnection %@",[NSThread currentThread]);
        strongself.clientStatus = MHLumiTUTKClientstatusConnecting;
        int retCode = IOTC_Initialize2(0);
        if (!logMessageAndReturn(@"IOTC_Initialize2 failure",retCode)) return;
        NSLog(@"IOTC_Initialize2 success");
        
        retCode = avInitialize(strongself.configuration.nMaxChannelNum);
        if (!logMessageAndReturn(@"avInitialize failure",retCode)) return;
        NSLog(@"avInitialize success");
        
        if (strongself.sessionId < 0){
            retCode = IOTC_Get_SessionID();
            if (!logMessageAndReturn(@"IOTC_Get_SessionID failure",retCode)) return;
            strongself.sessionId = retCode;
            NSLog(@"IOTC_Get_SessionID success");
        }
        
        /** A client fails to connect to a device via relay mode */
        //#define IOTC_ER_FAIL_SETUP_RELAY					-42
        
        /** All Server response can not find device */
        //#define IOTC_ER_DEVICE_OFFLINE				    -90
        
        retCode = IOTC_Connect_ByUID_Parallel([strongself.configuration.udid UTF8String],strongself.sessionId);
        if (!logMessageAndReturn(@"IOTC_Connect_ByUID_Parallel failure",retCode)) return;
        NSLog(@"IOTC_Connect_ByUID_Parallel success");
        struct st_SInfo sInfo;
        retCode = IOTC_Session_Check(strongself.sessionId, &sInfo);
        if (!logMessageAndReturn(@"IOTC_Session_Check failure",retCode)) return;
        NSLog(@"IOTC_Session_Check success");
        unsigned int servType[1];
        int pnResend = 1;
//        retCode = avClientStart(strongself.sessionId,
//                                [strongself.configuration.account UTF8String],
//                                [strongself.configuration.password UTF8String],
//                                strongself.configuration.nTimeout,
//                                servType, 0);
        retCode = avClientStart2(strongself.sessionId,
                                 [strongself.configuration.account UTF8String],
                                 [strongself.configuration.password UTF8String],
                                 strongself.configuration.nTimeout,
                                 servType,
                                 0,
                                 &pnResend);
        NSLog(@"avClientStart2-> pnResend = %d",pnResend);
        if (!logMessageAndReturn(@"avClientStart failure",retCode)) return;
        NSLog(@"avClientStart success");
        
        if (retCode == AV_ER_SESSION_CLOSE_BY_REMOTE){
            IOTC_Session_Close(strongself.sessionId);
            NSLog(@"AV_ER_SESSION_CLOSE_BY_REMOTE");
            [strongself initConnectionWithCompletedHandler:completedHandler];
        }
        
        strongself.avChannelId = retCode;
        
        unsigned short val = 0;
        retCode = avSendIOCtrl(strongself.avChannelId, IOTYPE_INNER_SND_DATA_DELAY, (char *)&val, sizeof(int));
        if (!logMessageAndReturn(@"avSendIOCtrl failure",retCode)) return;
        
        weakself.clientStatus = MHLumiTUTKClientstatusConnected;
        if (completedHandler){
            dispatch_async(dispatch_get_main_queue(), ^{
                completedHandler(weakself, 0);
            });
        }
    });
}

- (void)deinitConnection{
    _canceled = YES;
    _videoStreamStatus = MHLumiTUTKStreamstatusOFF;
    _audioStreamStatus = MHLumiTUTKStreamstatusOFF;
    [self resetAccData];
    if(_avChannelId>=0 && _sessionId>=0){
        IOTC_Connect_Stop_BySID(_sessionId);
    }
    if(_avChannelId >= 0){
        avClientStop(_avChannelId);
    }
    if(_sessionId >= 0){
        IOTC_Session_Close(_sessionId);
    }
    if(_talkbackServiceId >= 0){
        NSString *jsonString = [MHLumiTUTKClientHelper ioCtrlTalkBackStopJSonStringWithAVChannelId:_talkbackAVChannelId];
        const char *cstr = [jsonString cStringUsingEncoding:NSUTF8StringEncoding];
        avSendIOCtrl(_sessionId, IOTYPE_USER_IPCAM_SPEAKERSTOP_LUMI, cstr, (int)jsonString.length);
        avServExit(_sessionId, _talkbackAVChannelId);
        avClientStop(_talkbackAVChannelId);
        _talkbackServiceStatus = MHLumiTUTKTalkbackStatusDefault;
    }
    _talkbackAVChannelId = -1;
    _avChannelId = -1;
    _sessionId = -1;
    _clientStatus = MHLumiTUTKClientstatusStandby;
}

- (void)tutkDeInitialize{
    avDeInitialize();
    IOTC_DeInitialize();
}

#pragma mark -  avSendIOCtrl
#pragma mark -  - 开启视频
- (void)startVideoStreamWithJsonString:(NSString *)jsonString
                      startRequestData:(BOOL) yesOrNot
                      completedHandler:(void(^)(MHLumiTUTKClient *client,int retCode)) completedHandler{
    __weak typeof(self) weakself = self;
    void (^returnWithRetcode)(int retcode) = ^(int retcode){
        if (completedHandler){
            completedHandler(weakself,retcode);
        }
    };
    if (self.clientStatus != MHLumiTUTKClientstatusConnected) {
        returnWithRetcode(AV_ER_NOT_INITIALIZED);
        return;
    }
    
    if (self.videoStreamStatus != MHLumiTUTKStreamstatusOFF){
        returnWithRetcode(kIsFetchingVideoData);
        return;
    }
    dispatch_async(self.fetchVideoDataQueue, ^{
        const char *cstr = [jsonString cStringUsingEncoding:NSUTF8StringEncoding];
        int retCode = -1;
        if ([weakself initFFMpeg]){
            retCode = avSendIOCtrl(weakself.avChannelId, IOTYPE_USER_IPCAM_START, cstr, (int)jsonString.length);
            if (retCode >= 0){
                weakself.videoStreamStatus = yesOrNot ? MHLumiTUTKStreamstatusONAndRequest : MHLumiTUTKStreamstatusON;
                if (completedHandler){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completedHandler(weakself,retCode);
                    });
                }
                [weakself fetchVideoDataWithTUTK];
                return;
            }else{
                weakself.videoStreamStatus = MHLumiTUTKStreamstatusOFF;
                NSLog(@"start_ipcam_stream_failed[%d]", retCode);
            }
        }
        weakself.videoStreamStatus = MHLumiTUTKStreamstatusOFF;
        if (completedHandler){
            dispatch_async(dispatch_get_main_queue(), ^{
                completedHandler(weakself,retCode);
            });
        }
    });
}

//IOTYPE_USER_IPCAM_STOP 0x02FF
#pragma mark -  - 关闭视频
- (void)stopVideoStreamWithJsonString:(NSString *)jsonString completedHandler:(void (^)(MHLumiTUTKClient *, int))completedHandler{
    __weak typeof(self) weakself = self;
    void (^returnWithRetcode)(int retcode) = ^(int retcode){
        if (completedHandler){
            completedHandler(weakself,retcode);
        }
    };
    if (self.clientStatus != MHLumiTUTKClientstatusConnected) {
        returnWithRetcode(AV_ER_NOT_INITIALIZED);
        return;
    }
    
    if (self.videoStreamStatus == MHLumiTUTKStreamstatusOFF){
        returnWithRetcode(kIsNotFetchingVideoData);
        return;
    }
    dispatch_async(self.clientQueue, ^{
        const char *cstr = [jsonString cStringUsingEncoding:NSUTF8StringEncoding];
        int retCode = -1;
        retCode = avSendIOCtrl(weakself.avChannelId, IOTYPE_USER_IPCAM_STOP, cstr, (int)jsonString.length);
        if (retCode >= 0){
            weakself.videoStreamStatus = MHLumiTUTKStreamstatusOFF;
            if (completedHandler){
                dispatch_async(dispatch_get_main_queue(), ^{
                    completedHandler(weakself,retCode);
                });
            }
            return;
        }
        if (completedHandler){
            dispatch_async(dispatch_get_main_queue(), ^{
                completedHandler(weakself,retCode);
            });
        }
    });
}

#pragma mark -  - 开启声音
- (void)startAudioStreamWithJsonString:(NSString *)jsonString
                      startRequestData:(BOOL) yesOrNot
                      completedHandler:(void(^)(MHLumiTUTKClient *client,int retCode)) completedHandler{
    void (^returnWithRetcode)(int retcode) = ^(int retcode){
        if (completedHandler){
            completedHandler(self,retcode);
        }
    };
    if (self.clientStatus != MHLumiTUTKClientstatusConnected) {
        returnWithRetcode(AV_ER_NOT_INITIALIZED);
        return;
    }
    
    if (self.audioStreamStatus != MHLumiTUTKStreamstatusOFF){
        returnWithRetcode(kIsFetchingAudioData);
        return;
    }
    
    __weak typeof(self) weakself = self;
    dispatch_async(self.fetchAudioDataQueue, ^{
        NSLog(@"真正startAudioStreamWithJsonString %@",[NSThread currentThread]);
        const char *cstr = [jsonString cStringUsingEncoding:NSUTF8StringEncoding];
        int retCode = -1;
        retCode = avSendIOCtrl(weakself.avChannelId, IOTYPE_USER_IPCAM_AUDIOSTART, cstr, (int)jsonString.length);
        if (retCode >= 0){
            weakself.audioStreamStatus = yesOrNot ? MHLumiTUTKStreamstatusONAndRequest : MHLumiTUTKStreamstatusON;
            if (completedHandler){
                dispatch_async(dispatch_get_main_queue(), ^{
                    completedHandler(weakself,retCode);
                });
            }
            [weakself fetchAudioDataWithTUTK];
            return;
        }
        weakself.audioStreamStatus = MHLumiTUTKStreamstatusOFF;
        if (completedHandler){
            dispatch_async(dispatch_get_main_queue(), ^{
                completedHandler(weakself,retCode);
            });
        }
    });
}

//IOTYPE_USER_IPCAM_AUDIOSTOP 0x0301
#pragma mark -  - 关闭声音
- (void)stopAudioStreamWithJsonString:(NSString *)jsonString completedHandler:(void (^)(MHLumiTUTKClient *, int))completedHandler{
    __weak typeof(self) weakself = self;
    void (^returnWithRetcode)(int retcode) = ^(int retcode){
        if (completedHandler){
            completedHandler(weakself,retcode);
        }
    };
    if (self.clientStatus != MHLumiTUTKClientstatusConnected) {
        returnWithRetcode(AV_ER_NOT_INITIALIZED);
        return;
    }
    
    if (self.audioStreamStatus == MHLumiTUTKStreamstatusOFF){
        returnWithRetcode(kIsNotFetchingVideoData);
        return;
    }
    dispatch_async(self.clientQueue, ^{
        const char *cstr = [jsonString cStringUsingEncoding:NSUTF8StringEncoding];
        int retCode = -1;
        retCode = avSendIOCtrl(weakself.avChannelId, IOTYPE_USER_IPCAM_AUDIOSTOP, cstr, (int)jsonString.length);
        if (retCode >= 0){
            weakself.audioStreamStatus = MHLumiTUTKStreamstatusOFF;
            if (completedHandler){
                dispatch_async(dispatch_get_main_queue(), ^{
                    completedHandler(weakself,retCode);
                });
            }
            return;
        }
        if (completedHandler){
            dispatch_async(dispatch_get_main_queue(), ^{
                completedHandler(weakself,retCode);
            });
        }
    });
}

#pragma mark -  - 视频模式
- (void)setVideoMode:(MHLumiTUTKVideoMode)mode
      WithJsonString:(NSString *)jsonString
    completedHandler:(void (^)(MHLumiTUTKClient *, int))completedHandler{
    void (^returnWithRetcode)(int retcode) = ^(int retcode){
        if (completedHandler){
            completedHandler(self,retcode);
        }
    };
    if (self.clientStatus != MHLumiTUTKClientstatusConnected) {
        returnWithRetcode(AV_ER_NOT_INITIALIZED);
        return;
    }
    //    if (self.videoMode == mode){
    //        returnWithRetcode(0);
    //        return;
    //    }
    
    __weak typeof(self) weakself = self;
    dispatch_async(self.clientQueue, ^{
        const char *cstr = [jsonString cStringUsingEncoding:NSUTF8StringEncoding];
        int retCode = -1;
        retCode = avSendIOCtrl(weakself.avChannelId, IOTYPE_USER_IPCAM_SET_VIDEO_MODE, cstr, (int)jsonString.length);
        if (retCode >= 0){
            weakself.videoMode = mode;
        }
        if (completedHandler){
            dispatch_async(dispatch_get_main_queue(), ^{
                completedHandler(weakself,retCode);
            });
        }
    });
}

#pragma mark -  - 视频清晰度
- (void)setVideoQuality:(MHLumiTUTKVideoQuality)quality
         WithJsonString:(NSString *)jsonString
       completedHandler:(void (^)(MHLumiTUTKClient *, int))completedHandler{
    void (^returnWithRetcode)(int retcode) = ^(int retcode){
        if (completedHandler){
            completedHandler(self,retcode);
        }
    };
    if (self.clientStatus != MHLumiTUTKClientstatusConnected) {
        returnWithRetcode(AV_ER_NOT_INITIALIZED);
        return;
    }
    __weak typeof(self) weakself = self;
    dispatch_async(self.clientQueue, ^{
        const char *cstr = [jsonString cStringUsingEncoding:NSUTF8StringEncoding];
        int retCode = -1;
        retCode = avSendIOCtrl(weakself.avChannelId, IOTYPE_USER_IPCAM_SET_VIDEO_QUALITY, cstr, (int)jsonString.length);
        if (retCode >= 0){
            weakself.videoQuality = quality;
        }
        if (completedHandler){
            dispatch_async(dispatch_get_main_queue(), ^{
                completedHandler(weakself,retCode);
            });
        }
    });
}

#pragma mark -  - 回看
- (void)setBackwardWithJsonString:(NSString *)jsonString
                      startOrStop:(bool)startOrStop
                 completedHandler:(void (^)(MHLumiTUTKClient *, int))completedHandler{
    void (^returnWithRetcode)(int retcode) = ^(int retcode){
        if (completedHandler){
            completedHandler(self,retcode);
        }
    };
    if (self.clientStatus != MHLumiTUTKClientstatusConnected) {
        returnWithRetcode(AV_ER_NOT_INITIALIZED);
        return;
    }
    __weak typeof(self) weakself = self;
    dispatch_async(self.clientQueue, ^{
        unsigned int nIOCtrlType = 0;
        if (startOrStop){
            nIOCtrlType = IOTYPE_USER_IPCAM_PLAYRECORDSTART;
        }else{
            nIOCtrlType = IOTYPE_USER_IPCAM_PLAYRECORDSTOP;
        }
        const char *cstr = [jsonString cStringUsingEncoding:NSUTF8StringEncoding];
        int retCode = -1;
        retCode = avSendIOCtrl(weakself.avChannelId, nIOCtrlType, cstr, (int)jsonString.length);
        if (retCode >= 0){
            int nIOCtrlMaxDataSize = 1000;
            char *abIOCtrlData = malloc(nIOCtrlMaxDataSize);
            retCode = avRecvIOCtrl(weakself.avChannelId, &nIOCtrlType, abIOCtrlData, nIOCtrlMaxDataSize, 5000);
            if (retCode >= 0){
                NSData *responseData = [NSData dataWithBytes:abIOCtrlData length:retCode];
                NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
                NSString *resultMsg = responseDic[@"result"];
                if ([resultMsg isEqualToString:@"ok"]){
                    retCode = 0;
                }else{
                    retCode = kIsBackwardTimeUnable;
                }
            }
        }
        if (completedHandler){
            dispatch_async(dispatch_get_main_queue(), ^{
                completedHandler(weakself,retCode);
            });
        }
    });
}

- (void)getBackwardRecordTimeWithJsonString:(NSString *)jsonString
                            completeHandler:(void (^)(MHLumiTUTKClient *,int retcode))completedHandler{
    void (^returnWithRetcode)(int retcode) = ^(int retcode){
        if (completedHandler){
            completedHandler(self,retcode);
        }
    };
    if (self.clientStatus != MHLumiTUTKClientstatusConnected && self.avChannelId >= 0) {
        returnWithRetcode(AV_ER_NOT_INITIALIZED);
        return;
    }
    __weak typeof(self) weakself = self;
    dispatch_async(self.clientQueue, ^{
        const char *cstr = [jsonString cStringUsingEncoding:NSUTF8StringEncoding];
        int retCode = -1;
        retCode = avSendIOCtrl(weakself.avChannelId, IOTYPE_USER_IPCAM_GETRECORDTIME, cstr, (int)jsonString.length);
        if (retCode >= 0){
            int nIOCtrlMaxDataSize = 1000;
            char *abIOCtrlData = malloc(nIOCtrlMaxDataSize);
            unsigned int pnIOCtrlType = IOTYPE_USER_IPCAM_GETRECORDTIMERSP;
            retCode = avRecvIOCtrl(weakself.avChannelId, &pnIOCtrlType, abIOCtrlData, nIOCtrlMaxDataSize, 5000);
            if (retCode >= 0){
                NSData *responseData = [NSData dataWithBytes:abIOCtrlData length:retCode];
                NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
                NSLog(@"可回看时间段Dic：%@",responseDic);
                [weakself updateBackwordTimeDatasWithDictionary:responseDic];
            }
        }
        if (completedHandler){
            dispatch_async(dispatch_get_main_queue(), ^{
                completedHandler(weakself,retCode);
            });
        }
    });
}

- (void)updateBackwordTimeDatasWithDictionary:(NSDictionary *)dic{
    NSArray<NSString *> *recordtimeStrArray = [dic objectForKey:@"recordtime"];
    NSString *errorMessage = [dic objectForKey:@"error"];
    if (recordtimeStrArray != nil) {
        _isHaveSDCard = 1;
        [self.backwordTimeDatas removeAllObjects];
        NSDateFormatter *dateFormatter = [NSDateFormatter TUTKDateFormatter];
        NSLog(@"可回看时间段：");
        for (NSString *timeStr in recordtimeStrArray) {
            NSLog(@"%@",timeStr);
            NSString *startTimeStr = [timeStr substringToIndex:14];
            NSString *endTimeStr = [timeStr substringFromIndex:15];
            NSDate *startDate = [dateFormatter dateFromString:startTimeStr];
            NSDate *endDate = [dateFormatter dateFromString:endTimeStr];
            MHLumiTUTKBackwordTimeData *todoBackwordTimeData = [[MHLumiTUTKBackwordTimeData alloc] init];
            todoBackwordTimeData.startDate = startDate;
            todoBackwordTimeData.endDate = endDate;
            [self.backwordTimeDatas addObject:todoBackwordTimeData];
        }
        NSLog(@"()()()()()()()()()()()");
    }
    
    if (errorMessage != nil && [errorMessage.lowercaseString containsString:@"sd"]) {
        _isHaveSDCard = -1;
        [self.backwordTimeDatas removeAllObjects];
    }
}

#pragma mark -  - 开启并获取对讲Id
- (void)startAndfetchTalkBackServIdWithJsonString:(NSString *)jsonString
                                 completedHandler:(void (^)(MHLumiTUTKClient *, int))completedHandler{
    if (self.clientStatus != MHLumiTUTKClientstatusConnected || self.talkbackServiceStatus != MHLumiTUTKTalkbackStatusDefault) {
        completedHandler(self,AV_ER_NOT_INITIALIZED);
        return ;
    }
    _talkbackServiceStatus = MHLumiTUTKTalkbackStatusConnectting;
    __weak typeof(self) weakself = self;
    dispatch_async(self.clientQueue, ^{
        int retCode = 0;
        if (weakself.talkbackAVChannelId < 0){
            retCode = IOTC_Session_Get_Free_Channel(weakself.sessionId);
        }
        if (retCode < 0){
            weakself.talkbackServiceStatus = MHLumiTUTKTalkbackStatusDefault;
            completedHandler(weakself,retCode);
            return ;
        }
        weakself.talkbackAVChannelId = retCode;
        NSLog(@"获取了对话的channelId：%d",weakself.talkbackAVChannelId);
        const char *cstr = [[MHLumiTUTKClientHelper ioCtrlTalkBackStartJSonStringWithAVChannelId:weakself.talkbackAVChannelId]
                            cStringUsingEncoding:NSUTF8StringEncoding];
        retCode = avSendIOCtrl(weakself.avChannelId, IOTYPE_USER_IPCAM_SPEAKERSTART_LUMI, cstr, (int)jsonString.length);
        if (retCode < 0){
            weakself.talkbackServiceStatus = MHLumiTUTKTalkbackStatusDefault;
            completedHandler(weakself,retCode);
            return ;
        }
        NSLog(@"avSendIOCtrl 对讲命令success");
        retCode = avServStart(weakself.sessionId, NULL, NULL, weakself.configuration.nLaunchServeTimeout, TYPE_SERVER_STREAMING, weakself.talkbackAVChannelId);
        if (retCode >= 0) {
            weakself.talkbackServiceStatus = MHLumiTUTKTalkbackStatusConnected;
            weakself.talkbackServiceId = retCode;
            dispatch_async(weakself.talkBackQueue, ^{
                [weakself launchSendTalkbackData];
            });
            completedHandler(weakself,retCode);
        }else{
            weakself.talkbackServiceStatus = MHLumiTUTKTalkbackStatusDefault;
            completedHandler(weakself,retCode);
            [weakself stopTalkBackWithJsonString:[MHLumiTUTKClientHelper ioCtrlTalkBackStartJSonStringWithAVChannelId:weakself.talkbackAVChannelId] completedHandler:^(MHLumiTUTKClient *client, int rt) {
                completedHandler(weakself, retCode);
            }];
            NSLog(@"avServStart 对讲失败： %d",retCode);
        }
    });
}

#pragma mark -  - 关闭对讲
- (void)stopTalkBackWithJsonString:(NSString *)jsonString
                  completedHandler:(void (^)(MHLumiTUTKClient *, int))completedHandler{
    if (self.clientStatus != MHLumiTUTKClientstatusConnected) {
        if (completedHandler) completedHandler(self,AV_ER_NOT_INITIALIZED);
        return;
    }
    
    if (self.talkbackAVChannelId < 0){
        if (completedHandler) completedHandler(self,-1912992);
        return;
    }
    __weak typeof(self) weakself = self;
    dispatch_async(self.clientQueue, ^{
        int retCode = -1;
        const char *cstr = [jsonString cStringUsingEncoding:NSUTF8StringEncoding];
        retCode = avSendIOCtrl(weakself.sessionId, IOTYPE_USER_IPCAM_SPEAKERSTOP_LUMI, cstr, (int)jsonString.length);
//        if (retCode >= 0){
            avServExit(weakself.sessionId, weakself.talkbackAVChannelId);
            avClientStop(weakself.talkbackAVChannelId);
            weakself.talkbackServiceStatus = MHLumiTUTKTalkbackStatusDefault;
            weakself.talkbackAVChannelId = -1;
            NSLog(@"成功关闭对话");
//        }
        if (completedHandler) completedHandler(weakself,retCode);
    });
    
}

#pragma mark - - 暂停对讲
- (void)suspendTalkbackWithCompletedHandler:(void (^)(MHLumiTUTKClient *, int))completedHandler{
    if (self.clientStatus != MHLumiTUTKClientstatusConnected) {
        if (completedHandler) completedHandler(self,AV_ER_NOT_INITIALIZED);
        return;
    }
    
    if (self.talkbackAVChannelId < 0){
        if (completedHandler) completedHandler(self,-1912992);
        return;
    }
    __weak typeof(self) weakself = self;
    dispatch_async(self.clientQueue, ^{
        int retCode = -1;
        avServStop(weakself.talkbackAVChannelId);
        weakself.talkbackServiceStatus = MHLumiTUTKTalkbackStatusDefault;
        NSLog(@"成功关闭对话");
        if (completedHandler) completedHandler(weakself,retCode);
    });
    
}

#pragma mark - - 发送对讲数据
- (void)addAccData:(NSData *)accData{
    @synchronized (_aacDataSources) {
        [_aacDataSources addObject:accData];
        if (_aacDataSources.count >512){
            [_aacDataSources removeObjectAtIndex:0];
        }
//        NSLog(@"插入数据，当前数：%lu",(unsigned long)_aacDataSources.count);
    };
}

- (void)resetAccData{
    @synchronized (_aacDataSources) {
        if (self.talkbackServiceStatus != MHLumiTUTKTalkbackStatusConnected){
            [_aacDataSources removeAllObjects];
        }
    };
}

- (void)launchSendTalkbackData{
    while (1) {
        NSMutableArray <NSData *> *todoDatas = [NSMutableArray array];
        @synchronized (_aacDataSources) {
            if (_aacDataSources.count >= 4){
                NSInteger d = _aacDataSources.count - _aacDataSources.count%4;
                todoDatas = [NSMutableArray arrayWithArray:[_aacDataSources subarrayWithRange:NSMakeRange(0, d)]];
                [_aacDataSources removeObjectsInArray:todoDatas];
            }
        }
        if (todoDatas.count>=4) {
            while (todoDatas.count >= 4) {
                NSMutableData *fullData = [NSMutableData data];
                for (int index = 0; index < 4; index ++) {
                    NSData *todoData = [todoDatas objectAtIndex:0];
                    [todoDatas removeObject:todoData];
                    [fullData appendBytes:todoData.bytes length:todoData.length];
                }
                __weak typeof(self) weakself = self;
                int infoLength = 4;
                char *info = malloc(sizeof(char) * infoLength);
                int retcode = avSendAudioData(weakself.talkbackServiceId, fullData.bytes, (int)fullData.length, info, infoLength);
                if (retcode < 0){
                    NSLog(@"发送失败");
                }else{
                    //NSLog(@"发送成功");
                }
            }
        }
        if (self.talkbackServiceStatus != MHLumiTUTKTalkbackStatusConnected && self.aacDataSources.count < 4){
            break;
        }
    }
    [self.aacDataSources removeAllObjects];
}

#pragma mark - fetchData
- (void)fetchVideoDataWithTUTK{
    int retcode = AV_ER_NoERROR;
    LumiTUTKFrameInfo frameInfo;
    char* videoBuffer = (char*)malloc(kVideoBufSize); //接收视频的buffer
    int gotten = 0;
    int pnActualFrameSize = 0;
    int pnExpectedFrameSize = kVideoBufSize;
    int pnActualFrameInfoSize = 0;
    while(!self.canceled){
        if (self.videoStreamStatus != MHLumiTUTKStreamstatusONAndRequest || self.clientStatus != MHLumiTUTKClientstatusConnected){break;}
        @autoreleasepool {
            //CFAbsoluteTime runtime = CFAbsoluteTimeGetCurrent();
            unsigned int tutkIndex = _prevFrameIndex;
            memset(&frameInfo, 0, sizeof(LumiTUTKFrameInfo));
            retcode = avRecvFrameData2(self.avChannelId, videoBuffer, kVideoBufSize, &pnActualFrameSize, &pnExpectedFrameSize, (char *)&frameInfo, sizeof(LumiTUTKFrameInfo), &pnActualFrameInfoSize, &_prevFrameIndex);
            NSLog(@"TYTK index: %d",_prevFrameIndex);
            NSLog(@"frameInfo.frmNo: %d",frameInfo.frmNo);
            NSLog(@"timestamp: %d",frameInfo.timestamp);
            if(retcode >= 0){
                av_init_packet(&_packet);
                _packet.data = (uint8_t *)videoBuffer;
                _packet.size = retcode;
                gotten = 0;
                int decLen = avcodec_decode_video2(_pCodecCtx, _pVideoFrame, &gotten, &_packet);
                av_free_packet(&_packet);
                if(decLen > 0 && gotten){
                    //                    switch(self.pVideoFrame->pict_type){
                    //                        case AV_PICTURE_TYPE_I:NSLog(@"index: %d  type : I",_prevFrameIndex);break;
                    //                        case AV_PICTURE_TYPE_P:NSLog(@"index: %d  type : P",_prevFrameIndex);break;
                    //                        case AV_PICTURE_TYPE_B:NSLog(@"index: %d  type : B",_prevFrameIndex);break;
                    //                        default:NSLog(@"index: %d  type : other %d",_prevFrameIndex,self.pVideoFrame->pict_type);break;
                    //                    }
                    [self.delegate client:self onVideoReceived:self.pVideoFrame avcodecContext:self.pCodecCtx gotPicturePtr:gotten];
                    [self.delegate client:self videoBuffer:videoBuffer length:retcode];
                }
            }
            if (retcode == AV_ER_DATA_NOREADY || _prevFrameIndex == tutkIndex){
                [NSThread sleepForTimeInterval:0.05f];
            }
        }
    }
    free(videoBuffer);
}

- (BOOL)proactiveFetchVideoDataWithABAVFrame:(AVFrame *)frame frameInfo:(LumiTUTKFrameInfo *)frameInfo gotPicturePtr:(int *)pictureCout{
    
    if (self.canceled){
        return NO;
    }
    if (self.clientStatus != MHLumiTUTKClientstatusConnected || _isFFMpegInited == NO)
    {
        return NO;
    }
    LumiTUTKFrameInfo todoFrameInfo;
    int retcode = AV_ER_NoERROR;
    if (_videoBufferForP == NULL){
        _videoBufferForP = (char*)malloc(kVideoBufSize); //接收视频的buffer
    }
    int pnActualFrameSize = 0;
    int pnExpectedFrameSize = kVideoBufSize;
    int pnActualFrameInfoSize = 0;
    int count = 0;
    memset(&todoFrameInfo, 0, sizeof(LumiTUTKFrameInfo));
    retcode = avRecvFrameData2(self.avChannelId, _videoBufferForP, kVideoBufSize, &pnActualFrameSize, &pnExpectedFrameSize, (char *)&todoFrameInfo, sizeof(LumiTUTKFrameInfo), &pnActualFrameInfoSize, &_prevFrameIndex);
    memcpy(frameInfo, &todoFrameInfo, sizeof(LumiTUTKFrameInfo));
//    NSLog(@"videoFrameInfo %d",todoFrameInfo.timestamp);
    if(retcode >= 0){
        av_init_packet(&_packet);
        _packet.data = (uint8_t *)_videoBufferForP;
        _packet.size = retcode;
        int decLen = avcodec_decode_video2(_pCodecCtx, frame, &count, &_packet);
        av_free_packet(&_packet);
        if(decLen > 0 && count){
//            switch(frame->pict_type){
//                case AV_PICTURE_TYPE_I:NSLog(@"index: %d  type : I",_prevFrameIndex);break;
//                case AV_PICTURE_TYPE_P:NSLog(@"index: %d  type : P",_prevFrameIndex);break;
//                case AV_PICTURE_TYPE_B:NSLog(@"index: %d  type : B",_prevFrameIndex);break;
//                default:NSLog(@"index: %d  type : other %d",_prevFrameIndex,frame->pict_type);break;
//            }
            [self.delegate client:self videoBuffer:_videoBufferForP length:retcode];
            return YES;
        }
    }
    return NO;
}

#define kAudioBufSize 500
- (NSData *)proactiveFetchAudioData{
    NSData *audioData = nil;
    if (self.clientStatus != MHLumiTUTKClientstatusConnected){
        return nil;
    }
    int audioFrameCount = avCheckAudioBuf(self.avChannelId);
    if (audioFrameCount < 3){
        return nil;
    }
    char audioBuf[kAudioBufSize];
    FRAMEINFO_t frameInfo;
    unsigned int recvFrameIndex = 0;
    unsigned int prevFrameIndex = 0;
    int ret = avRecvAudioData(self.avChannelId, audioBuf, kAudioBufSize,
                              (char *)&frameInfo, sizeof(FRAMEINFO_t), &recvFrameIndex);
    if (ret == AV_ER_SESSION_CLOSE_BY_REMOTE ||
        ret == AV_ER_REMOTE_TIMEOUT_DISCONNECT ||
        ret == IOTC_ER_INVALID_SID){
        return nil;
    }
    if (recvFrameIndex > prevFrameIndex || recvFrameIndex == 0) {
        audioData = [NSData dataWithBytes:audioBuf length:ret];
    }
    prevFrameIndex = recvFrameIndex;
    return audioData;
}

- (void)fetchAudioDataWithTUTK{
    char audioBuf[kAudioBufSize];
    FRAMEINFO_t frameInfo;
    unsigned int recvFrameIndex = 0;
    unsigned int prevFrameIndex = 0;
    while(!self.canceled){
        if (self.audioStreamStatus != MHLumiTUTKStreamstatusONAndRequest || self.clientStatus != MHLumiTUTKClientstatusConnected){break;}
        int audioFrameCount = avCheckAudioBuf(self.avChannelId);

//        NSLog(@"TUTK的接收到的个数： %d",audioFrameCount);
        
        if (audioFrameCount < 0) {
            break;
        }else if (audioFrameCount < 3) {
            usleep(120000); //120ms
            continue;
        }
        // 接收音频
        int ret = avRecvAudioData(self.avChannelId, audioBuf, kAudioBufSize,
                                  (char *)&frameInfo, sizeof(FRAMEINFO_t), &recvFrameIndex);
        NSData *responseData = [NSData dataWithBytes:&frameInfo length:sizeof(FRAMEINFO_t)];
        responseData = [responseData subdataWithRange:NSMakeRange(12, 4)];
        int *a = (int *)responseData.bytes;
        NSLog(@"audioFrameInfo %d",*a);
        if (ret == AV_ER_SESSION_CLOSE_BY_REMOTE ||
            ret == AV_ER_REMOTE_TIMEOUT_DISCONNECT ||
            ret == IOTC_ER_INVALID_SID){ 
            break;
        }else if (ret < 0){
            continue;
        }
        // 收到的帧序列号大于上一个帧序列号或者收到的帧是第0帧
        if (recvFrameIndex > prevFrameIndex || recvFrameIndex == 0) {
            char* frameData = (char *)malloc(ret);
            memcpy(frameData, audioBuf, ret);
            [self.delegate client:self onAudioReceived:frameData length:ret];
            _audioTimeStamp = CFAbsoluteTimeGetCurrent();
            free(frameData);
        }
//        CFAbsoluteTimeGetCurrent()
        prevFrameIndex = recvFrameIndex;
    }
}

#pragma mark - StreamDataControl
- (BOOL)setRequestVideoDataOrNotWithFlag:(BOOL)flag{
    if (self.clientStatus != MHLumiTUTKClientstatusConnected){
        return NO;
    }
    
    if (flag && self.videoStreamStatus != MHLumiTUTKStreamstatusOFF){
        self.videoStreamStatus = MHLumiTUTKStreamstatusONAndRequest;
        dispatch_async(self.fetchVideoDataQueue, ^{
            [self fetchVideoDataWithTUTK];
        });
        return YES;
    }
    
    if (!flag && self.videoStreamStatus == MHLumiTUTKStreamstatusONAndRequest){
        self.videoStreamStatus = MHLumiTUTKStreamstatusON;
        return YES;
    }
    
    return NO;
}

- (BOOL)setRequestAudioDataOrNotWithFlag:(BOOL)flag{
    if (self.clientStatus != MHLumiTUTKClientstatusConnected){
        return NO;
    }
    
    if (flag && self.audioStreamStatus != MHLumiTUTKStreamstatusOFF){
        self.audioStreamStatus = MHLumiTUTKStreamstatusONAndRequest;
        dispatch_async(self.fetchAudioDataQueue, ^{
            [self fetchAudioDataWithTUTK];
        });
        return YES;
    }
    
    if (!flag && self.audioStreamStatus == MHLumiTUTKStreamstatusONAndRequest){
        self.audioStreamStatus = MHLumiTUTKStreamstatusON;
        return YES;
    }
    
    return NO;
}

#pragma mark - ffmpeg
- (BOOL)initFFMpeg{
    if (self.isFFMpegInited) {return YES;}
    av_register_all();
    self.pCodec = avcodec_find_decoder(AV_CODEC_ID_H264);
    if (_pCodec == NULL){
        NSLog(@"Can not find H264 decoder.");
        return NO;
    }
    self.pCodecCtx = avcodec_alloc_context3(_pCodec);
    if (_pCodecCtx == NULL){
        NSLog(@"Can not create codec context.");
        return NO;
    }
    if (avcodec_open2(_pCodecCtx, _pCodec, NULL) < 0){
        NSLog(@"Can not open codec.");
        return NO;
    }
    // allocate frame
    self.pVideoFrame = avcodec_alloc_frame();
    if (_pVideoFrame == NULL){
        NSLog(@"Can not allocate frame");
        return NO;
    }
    self.pCodecCtx->flags |= CODEC_FLAG_LOW_DELAY;//CODEC_FLAG_EMU_EDGE |
    self.pCodecCtx->debug |= FF_DEBUG_MMCO;
    self.pCodecCtx->pix_fmt = PIX_FMT_YUV420P;
    NSLog(@"initFFMpeg !");
    _isFFMpegInited = YES;
    return YES;
}

- (BOOL)deInitFFMpeg
{
    if (_pVideoFrame){
        avcodec_free_frame(&_pVideoFrame);
        _pVideoFrame = NULL;
    }
    if (_pCodecCtx){
        avcodec_close(_pCodecCtx);
        av_free(_pCodecCtx);
        _pCodecCtx = NULL;
    }
    _isFFMpegInited = NO;
    return YES;
}

- (void)cleanLocalBuffer{
    if (self.avChannelId >= 0) {
        avClientCleanLocalBuf(self.avChannelId);
    }
}

- (void)cleanAudioBuffer{
    if (self.avChannelId >= 0) {
        avClientCleanAudioBuf(self.avChannelId);
    }
}

#pragma mark - applicationDidEnterBackground
- (void)applicationDidEnterBackground{
    _prevClientStatus = _clientStatus;
    _prevVideoStreamStatus = _videoStreamStatus;
    _prevAudioStreamStatus = _audioStreamStatus;
    if (_clientStatus == MHLumiTUTKClientstatusStandby ||
        _clientStatus == MHLumiTUTKClientstatusDisconnect){
        NSLog(@"applicationDidEnterBackground: client 没有连接 do Nothing");
        return;
    }
    __weak typeof(self) weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), self.clientQueue, ^{
        if (weakself.prevVideoStreamStatus != MHLumiTUTKStreamstatusOFF){
            NSLog(@"stopVideoStreamWithJsonString");
            [weakself stopVideoStreamWithJsonString:[MHLumiTUTKClientHelper ioCtrlJSonStringWithAVChannelId:0] completedHandler:nil];
        }
    });
}

- (void)applicationWillEnterForeground{
    if (_prevClientStatus == MHLumiTUTKClientstatusStandby ||
        _prevClientStatus == MHLumiTUTKClientstatusDisconnect){
        NSLog(@"applicationWillEnterForeground: client 原来没有连接 do Nothing");
        return;
    }
    if (self.prevVideoStreamStatus == MHLumiTUTKStreamstatusOFF){
        NSLog(@"applicationWillEnterForeground: client 有连接 但dataStream没连接 do Nothing");
        return;
    }
    BOOL flag = _prevVideoStreamStatus == MHLumiTUTKStreamstatusONAndRequest;
    [self startVideoStreamWithJsonString:[MHLumiTUTKClientHelper ioCtrlJSonStringWithAVChannelId:0] startRequestData:flag completedHandler:^(MHLumiTUTKClient *client, int retCode) {
        NSLog(@"applicationWillEnterForeground 启动成功: %d",flag);
    }];
    
}
@end
