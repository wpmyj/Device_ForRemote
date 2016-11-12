 //
//  MHTutkClient.m
//  TutkOperation
//
//  Created by huchundong on 2016/8/23.
//  Copyright © 2016年 huchundong. All rights reserved.
//

#import "TUTKClient.h"
#import "TUTKCommandOperation.h"
#import "IOTCAPIs.h"
#import "AVAPIs.h"
#import "AVIOCTRLDEFs.h"
#import "AVFRAMEINFO.h"
//#import "MHAvEvent.h"
#import "RDTAPIs.h"
//#import "MHXiaoBaiConstant.h"
#import "P2PTunnelAPIs.h"
#import "AVAPIs.h"
//#import "MHTicker.h"
#import "MHGetP2PIdRequest.h"
#import "MHGetP2PIdResponse.h"

#include "libavformat/avformat.h"
#include "libavformat/avio.h"
#import <ffmpegWrapper/MHVideoFrameYUV.h>

#define XM_SS_BOOL(strongself, weakself) __strong typeof(weakself) strongself = weakself; \
if (strongself == nil) return NO;
@implementation TUTKClient{
    NSOperationQueue*   _queue;
    NSRecursiveLock*    _lock;
    
    
    unsigned int _audioFrameIndex; //音频帧序列号
    unsigned int _recvFrameIndex; //当前收到的帧序列号
    unsigned int _prevFrameIndex; //收到的上一个帧序列号
    
    /* ffmpeg */
    AVCodec*        _pCodec;
    AVPacket        _packet;
    AVFrame*        _pVideoFrame;
    AVCodecContext*    _pCodecCtx;
    
    /**/
    BOOL            _needDecode;
    
    BOOL            _hasGetUid;
    int       _mGetSessionId;
}
@synthesize clientInit = _clientInit;
@synthesize isRecvVideo = _isRecvVideo;
- (instancetype)init{
    self = [super init];
    if (self){
        _queue = [[NSOperationQueue alloc] init];
        _clientInit = NO;
        _avChannel = -1;
        _session = -1;
        _mGetSessionId = -1;
        
    }
    return self;
}

- (void)sendAudioCommand:(TUTKCommandSuccess) success fail:(TUTKCommandFail)fail{
    TUTKCommandOperation * operation = [[TUTKCommandOperation alloc] initWithClient:self];
    XM_WS(ws);
    operation.handle = ^BOOL(MHBaseClient* baseClient){
        XM_SS_BOOL(ss,ws);
        TUTKClient* client = (TUTKClient*)baseClient;
        NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
        paramsDic[@"channel"] = @(client.avChannel);
        NSData *data = [NSJSONSerialization dataWithJSONObject:paramsDic options:0 error:nil];
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        const char *cstr = [str cStringUsingEncoding:NSUTF8StringEncoding];
        //            SMsgAVIoctrlAVStream ioMsg;
        //            memset(&ioMsg, 0, sizeof(SMsgAVIoctrlAVStream));
        int ret = -1;
        if ((ret = avSendIOCtrl(ss.avChannel, IOTYPE_USER_IPCAM_AUDIOSTART,cstr, (int)data.length) < 0))
        {
            NSLog(@"start_ipcam_stream_failed[%d]", ret);
            return NO;
        }
        if (ret < 0) {
            fail(ret);
            ss.isRecvAudio = NO;
            return NO;
        } else {
            ss.isRecvAudio = YES;
            [ss decodeAudioThread];
            success();
            return YES;
        }
    };
    [_queue addOperation:operation];
}


- (void)initConnection:(TUTKCommandSuccess) success fail:(TUTKCommandFail)fail{
    TUTKCommandOperation* operation = [[TUTKCommandOperation alloc] initWithClient:self];
    XM_WS(ws);
    operation.handle = ^BOOL(MHBaseClient* baseClient){
        XM_SS_BOOL(ss,ws);
        NSLog(@"initConnection========");
        TUTKClient* client = (TUTKClient*)baseClient;
        client.clientInit = YES;
        int ret = IOTC_Initialize2(0);
        if (ret != IOTC_ER_NoERROR && ret != IOTC_ER_ALREADY_INITIALIZED) {
            DCDLog(@"IOTC_Initialize2 error:%d", ret);
            if(fail){
                fail(ret);
            }
            return NO;
        }
        // 初始化av模块，设置av最多通道数为4
        ret = avInitialize(3);
        if (ret < 0) {
            DCDLog(@"avInitialize error:%d", ret);
            if(fail){
                fail(ret);
            }
            return NO;
        }
        
        ss->_mGetSessionId = IOTC_Get_SessionID();
        DCDLog(@"IOTC_Get_SessionID: mGetSessionId= %d",ss->_mGetSessionId);
        ss->_hasGetUid = NO;
        [[MHTicker sharedInstance] addTaskWithIdentifier:kTutkDemoGetUIDTickerID delay:30.0 repeat:NO onMainThread:YES block:^(){
            if(ss->_hasGetUid == NO){
                IOTC_Connect_Stop_BySID(ss->_mGetSessionId);
            }
        }];
        int sidRet = -1;
        sidRet = IOTC_Connect_ByUID_Parallel([ss.udid UTF8String],ss->_mGetSessionId);
        ss->_hasGetUid = YES;
        if(sidRet < 0 ){
            
        }else{
            ss.session = ss->_mGetSessionId;
        }
        [[MHTicker sharedInstance] removeTaskWithIdentifier:kTutkDemoGetUIDTickerID];
        struct st_SInfo sInfo;
        ret = -1;
        ret = IOTC_Session_Check(ss.session, &sInfo);
        if(ret < 0){
            if(fail){
                fail(ret);
            }
            return NO;
        }
        
        unsigned int servType = 1;
        //        int resend = 0;
        int channel = -1;
        channel = avClientStart(ss.session, "admin", [ss.password UTF8String], 20000, &servType, 0);
        
        //        channel = avClientStart2(ss.session, "admin", [ss.password UTF8String], 2000, &servType, 0, &resend);
        if (channel == AV_ER_WRONG_VIEWACCorPWD) {
            IOTC_Connect_Stop_BySID(ss.session);
        }
        
        if (channel == AV_ER_SESSION_CLOSE_BY_REMOTE){
            IOTC_Session_Close(ss.session);
        }
        
        if(channel>=0){
            ss.avChannel = channel;
            
            int ret;
            unsigned short val = 0;
            
            if ((ret = avSendIOCtrl(ss.avChannel, IOTYPE_INNER_SND_DATA_DELAY, (char *)&val, sizeof(unsigned short)) < 0))
            {
                NSLog(@"start_ipcam_stream_failed[%d]", ret);
                return NO;
            }
            NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
            paramsDic[@"channel"] = @(ss.avChannel);
            NSLog(@"%@",paramsDic);
            NSData *data = [NSJSONSerialization dataWithJSONObject:paramsDic options:0 error:nil];
            NSLog(@"%@",data);
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str);
            const char *cstr = [str cStringUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"%s",cstr);
            
            if ((ret = avSendIOCtrl(ss.avChannel, IOTYPE_USER_IPCAM_START, cstr, (int)data.length) < 0))
            {
                NSLog(@"start_ipcam_stream_failed[%d]", ret);
                return NO;
            }
            
            [self dataThread];
            return YES;
            
        }
        if(fail){
            fail(ret);
        }
        DCDLog(@"initConnection======== end");
        return NO;
    };
    [_queue addOperation:operation];
}
- (void)deinitConnectoin:(TUTKCommandSuccess) success fail:(TUTKCommandFail)fail{
    [_lock lock];
    DCDLog(@"deinitConnectoin =");
    TUTKCommandOperation* operation = [[TUTKCommandOperation alloc] initWithClient:self];
    
    XM_WS(ws);
    if(_hasGetUid == NO && ws.session >= 0){
        IOTC_Connect_Stop_BySID(ws.session);
    }
    operation.handle = ^BOOL(MHBaseClient* baseClient){
        DCDLog(@"deinitConnectoin======");
        XM_SS_BOOL(ss,ws);
        ss.isRecvAudio = NO;
        ss.isRecvVideo = NO;
        
        [[MHTicker sharedInstance] removeTaskWithIdentifier:kTutkDemoGetUIDTickerID];
        [ss cancelAllRequest];
        
        // 停止av通道
        if(ss.avChannel >= 0){
            avClientStop(self.avChannel);
        }
        ss.avChannel = -1;
        // 关闭IOTC会话
        if(ss.session >= 0){
            IOTC_Session_Close(ss.session);
        }
        ss.session = - 1;
        
        DCDLog(@"deinitConnectoin = 2");
        // 停止连接设备
        //    IOTC_Connect_Stop();
        // Deinitialize av模块
        
        DCDLog(@"deinitConnectoin = 3");
        avDeInitialize();
        // Deinitialize IOTC模块
        IOTC_DeInitialize();
        //    self.delegate = nil;
        ss.clientInit = NO;
        return YES;
    };
    [_queue addOperation:operation];
    
    [_lock lock];
    //    TUTKCommandOperation* operation =
    //    usleep(1000*1500);
    success();
    DCDLog(@"deinitConnectoin finish");
}


- (void)getP2PId:(NSString*)did callback:(void(^)(MHGetP2PIdResponse*))handle
{
    MHGetP2PIdRequest *request = [[MHGetP2PIdRequest alloc] init];
    request.did = did;
    
    XM_WS(ws);
    [[MHNetworkEngine sharedInstance] sendRequest:request success:^(id response) {
        XM_SS(ss, ws);
        MHGetP2PIdResponse *p2pResponse = [MHGetP2PIdResponse responseWithJSONObject:response];
        
        ss.udid = p2pResponse.p2pId;
        ss.password = p2pResponse.password;
        if (handle) {
            handle(p2pResponse);
        }
        
    } failure:^(NSError * error) {
        DCDLog(@"getP2PId fail error = %@",error);
        XM_SS(ss, ws);
        if(handle){
            handle(nil);
        }
    }];
}

- (int)checkIOTCSession
{
    if (self.session == 0) {
        return IOTC_ER_INVALID_SID;
    }
    int ret = IOTC_ER_NoERROR;
    struct st_SInfo sessionInfo;
    ret = IOTC_Session_Check(self.session, &sessionInfo);
    return ret;
}

- (void)cancelAllRequest{
    [_queue cancelAllOperations];
}
#pragma mark datathread -
static NSThread* videoThread = nil;
- (NSThread*)dataThread{
    [_lock lock];
    if(videoThread == nil){
        videoThread = [[NSThread alloc] initWithTarget:self selector:@selector(handleVideoData:) object:nil];
        [videoThread start];
    }
    [_lock unlock];
    return videoThread;
}
static double const kHandleTime = 0.03;
- (void)handleVideoData:(id) obj{
    
    
    int ret = AV_ER_NoERROR;
    //    int prevRet = AV_ER_NoERROR;
    //    int data_noready_count = 0;
    FRAMEINFO_t frameInfo;
    
#define kVideoBufSize 400000
    char* videoBuf = (char*)malloc(kVideoBufSize); //接收视频的bu
    int expectedFrameSize = sizeof(videoBuf);
    int actualFrameSize = sizeof(videoBuf);
    int actualFrameInfoSize = sizeof(FRAMEINFO_t);
    int gotten = 0;
    [self initFFMpeg];
    self.isRecvVideo = YES;
    while(self.isRecvVideo){
        @autoreleasepool {
            CFAbsoluteTime runtime = CFAbsoluteTimeGetCurrent();
            //        ret = avRecvFrameData2(self.avChannel,videoBuf,kVideoBufSize,&actualFrameSize, &expectedFrameSize,(char *)&frameInfo,sizeof(FRAMEINFO_t),&actualFrameInfoSize,&(_recvFrameIndex));
            ret = avRecvFrameData(self.avChannel, videoBuf, kVideoBufSize, (char *)&frameInfo, sizeof(FRAMEINFO_t), &_recvFrameIndex);
            if(frameInfo.flags == IPC_FRAME_FLAG_IFRAME)
            {
                NSLog(@"got");
            }
            if(ret >= 0){
                av_init_packet(&_packet);
                _packet.data = (uint8_t *)videoBuf;
                _packet.size = ret;
                gotten = 0;
                int decLen =avcodec_decode_video2(_pCodecCtx, _pVideoFrame, &gotten, &_packet);
                av_free_packet(&_packet);
                if(decLen > 0 && gotten){
                    
                    MHVideoFrameYUV* yuvFrame = [[MHVideoFrameYUV alloc] initWithFrame: _pVideoFrame withSize:CGSizeMake(_pCodecCtx->width, _pCodecCtx->height)];
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        [self.delegate  decodeVideoBuffer:yuvFrame];
                    });
                    
                }
            }else{
                
            }
            if (ret == AV_ER_DATA_NOREADY){
                [NSThread sleepForTimeInterval:0.03f];
            }
        }
        
        
        //        double costTime = CFAbsoluteTimeGetCurrent() - runtime;
        //        double sleepTime = kHandleTime - costTime;
        //        if(ret > 0){
        //            DCDLog(@"ret = %d costTime = %lf sleepTime = %lf",ret ,costTime,sleepTime);
        //        }
        //
        //        if(sleepTime > 0){
        //            sleep(sleepTime);
        //        }else{
        //            sleep(0.1);
        //        }
        
    }
    videoThread = nil;
    free(videoBuf);
    [self deInitFFMpeg];
}

#pragma mark ffmpeg -
- (BOOL)initFFMpeg
{
    av_register_all();
    _pCodec = avcodec_find_decoder(AV_CODEC_ID_H264);
    if (_pCodec == NULL)
    {
        DCDLog(@"Can not find H264 decoder.");
        return NO;
    }
    _pCodecCtx = avcodec_alloc_context3(_pCodec);
    if (_pCodecCtx == NULL)
    {
        DCDLog(@"Can not create codec context.");
        return NO;
    }
    if (avcodec_open2(_pCodecCtx, _pCodec, NULL) < 0)
    {
        DCDLog(@"Can not open codec.");
        return NO;
    }
    // allocate frame
    _pVideoFrame = avcodec_alloc_frame();
    if (_pVideoFrame == NULL)
    {
        DCDLog(@"Can not allocate frame");
        return NO;
    }
    _pCodecCtx->flags |= CODEC_FLAG_EMU_EDGE | CODEC_FLAG_LOW_DELAY;
    _pCodecCtx->debug |= FF_DEBUG_MMCO;
    _pCodecCtx->pix_fmt = PIX_FMT_YUV420P;
    return YES;
}

- (BOOL)deInitFFMpeg
{
    if (_pVideoFrame)
    {
        avcodec_free_frame(&_pVideoFrame);
        _pVideoFrame = NULL;
    }
    if (_pCodecCtx)
    {
        avcodec_close(_pCodecCtx);
        av_free(_pCodecCtx);
        _pCodecCtx = NULL;
    }
    
    return YES;
}
#pragma mark audio decode
static NSThread* audioThread = nil;
- (NSThread*)decodeAudioThread{
    [_lock lock];
    if(audioThread == nil){
        audioThread = [[NSThread alloc] initWithTarget:self selector:@selector(handleAudioData) object:nil];
        [audioThread start];
    }
    [_lock unlock];
    return audioThread;
}

#define kAudioBufSize 500
- (void)handleAudioData{
    self.isRecvAudio = YES;
    char audioBuf[kAudioBufSize];
    FRAMEINFO_t frameInfo;
    unsigned int recvFrameIndex = 0;
    unsigned int prevFrameIndex = 0;
    while(self.isRecvAudio){
        //        DCDLog(@"");
        // 获取音频接收队列中的帧数
        int audioFrameCount = avCheckAudioBuf(self.avChannel);
        if (audioFrameCount < 0) {
            break;
        }
        else if (audioFrameCount < 3) {
            usleep(120000); //120ms
            continue;
        }
        // 接收音频
        int ret = avRecvAudioData(self.avChannel, audioBuf, kAudioBufSize,
                                  (char *)&frameInfo, sizeof(FRAMEINFO_t), &recvFrameIndex);
        if (ret == AV_ER_SESSION_CLOSE_BY_REMOTE ||
            ret == AV_ER_REMOTE_TIMEOUT_DISCONNECT ||
            ret == IOTC_ER_INVALID_SID)
        {
            //            NSLog(@"avRecvAudioData failed:%d", ret);
            break;
        }
        else if (ret < 0)
        {
            continue;
        }
        // 收到的帧序列号大于上一个帧序列号或者收到的帧是第0帧
        if (recvFrameIndex > prevFrameIndex || recvFrameIndex == 0) {
            char* frameData = (char *)malloc(ret);
            memcpy(frameData, audioBuf, ret);
            XM_WS(ws);
            dispatch_async(dispatch_get_main_queue(), ^(){
                XM_SS(ss,ws);
                [ss.delegate onAudioReceived:frameData length:ret];
                free(frameData);
            });
//            free(frameData);
        }
        
        prevFrameIndex = recvFrameIndex;
    }
    audioThread = nil;
    free(audioBuf);
}
- (void)dealloc{
    DCDLog(@"tutk dealloc");
}
#pragma mark ticker -

@end
