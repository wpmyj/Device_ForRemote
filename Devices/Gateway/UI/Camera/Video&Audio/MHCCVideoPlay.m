//
//  MHCCVideoPlay.m
//  MiHome
//
//  Created by ayanami on 8/25/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHCCVideoPlay.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <sys/time.h>


#import "IOTCAPIs.h"
#import "AVAPIs.h"
#import "AVIOCTRLDEFs.h"
#import "AVFRAMEINFO.h"
#import "EZVideoDecoder.h"

#define AUDIO_BUF_SIZE	1024
#define VIDEO_BUF_SIZE	2000000

@interface MHCCVideoPlay ()<MHEZVideoDecoderDelegate>

@property (nonatomic, copy) NSString *UID;
@property (nonatomic, assign) int SID;
@property (nonatomic, assign) int mainAVChannelID;
@property (nonatomic, strong) MHEZVideoDecoder *decoder; //视频解码器
@property (nonatomic, strong) PlayAudio *player; //音频播放器
@property (nonatomic, strong) MHDeviceCamera *camera;

@end


@implementation MHCCVideoPlay


- (instancetype)initWithSensor:(MHDeviceCamera *)camera
{
    self = [super init];
    if (self) {
        _camera = camera;
        _UID = @"FDPUBD5CK1VM8N6GY1C1";
        
//        _player = [[MLAudioRealTimePlayer alloc]init]; //初始化音频播放器
//        [player start];
//        
//        _decoder = [[SN264Decoder alloc] initWithCodec:kVCT_H264];  //初始化视频解码器

        }
    return self;
}


- (void)startFetchData {
    _player = [PlayAudio shareInstance];
//    [_player startPlay];
    
    _decoder = [[MHEZVideoDecoder alloc] initWithDelegate:self decoderQueue:nil];
    
    
    [self startIOTCService:_UID];

}

#pragma mark 开启服务
-(void)startIOTCService:(NSString *)UIDa{
    XM_WS(weakself);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        int ret;
        unsigned short nUdpPort = (unsigned short)(10000 + (_getTickCount() % 10000));
        
//        ret = IOTC_Initialize(0, "46.137.188.54", "122.226.84.253", "m2.iotcplatform.com", "m5.iotcplatform.com");
        ret = IOTC_Initialize2(0);
        
        
        //        ret = IOTC_Initialize(nUdpPort, "50.19.254.134", "122.248.234.207", "m4.iotcplatform.com", "m5.iotcplatform.com");
        
        //        ret = IOTC_Initialize2(0);
        
        NSLog(@"Step 1 : 初始化  = %d", ret);
        
        if (ret != IOTC_ER_NoERROR) {
            return;
        }
        
        avInitialize(4);
        
        weakself.SID = IOTC_Connect_ByUID((char *)[(NSString *)weakself.UID UTF8String]);
        
        NSLog(@"sid = %d",weakself.SID);
        
        if (weakself.SID < 0) {
            
            avDeInitialize();
            IOTC_DeInitialize();
            [self startIOTCService:@""];
            return;
        }
        
        NSLog(@"Step 2 : 连接服务器 %d", weakself.SID);
        
        struct st_SInfo Sinfo;
        ret = IOTC_Session_Check(weakself.SID, &Sinfo);
        
        if (ret >= 0)
        {
            if(Sinfo.Mode == 0)
                printf("Device is from %s:%d[%s] Mode=P2P\n",Sinfo.RemoteIP, Sinfo.RemotePort, Sinfo.UID);
            else if (Sinfo.Mode == 1)
                printf("Device is from %s:%d[%s] Mode=RLY\n",Sinfo.RemoteIP, Sinfo.RemotePort, Sinfo.UID);
            else if (Sinfo.Mode == 2)
                printf("Device is from %s:%d[%s] Mode=LAN\n",Sinfo.RemoteIP, Sinfo.RemotePort, Sinfo.UID);
        }else{
            
            avDeInitialize();
            IOTC_DeInitialize();
            [self startIOTCService:@""];
            return;
            
        }
        
        
        unsigned int srvType;
        
        int avIndex = avClientStart(weakself.SID, "admin", "888888", 20000, &srvType, 0);
        
        
        weakself.mainAVChannelID = avIndex;
        NSLog(@"Step 3 : 连接音频服务器 %d ", avIndex);
        
        if(avIndex < 0)
        {
            
            avDeInitialize();
            IOTC_DeInitialize();
            
            [self startIOTCService:@""];
            
            return ;
        }
        
        if (start_ipcam_stream(avIndex)>0)
        {
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                [self startAudioService:weakself.mainAVChannelID];
                
            });
            
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                [self startVideoService:weakself.mainAVChannelID];
                
            });
            
            
        }
        
    });
    
}




-(void)startAudioService:(int)avIndex{
    
    XM_WS(weakself);
    
    char buf[AUDIO_BUF_SIZE];
    unsigned int frmNo;
    int ret;
    FRAMEINFO_t frameInfo;
    
    while (1)
    {
        
        ret = avCheckAudioBuf(avIndex);
        if (ret < 0) break;
        if (ret < 3) // determined by audio frame rate
        {
            usleep(120000);
            continue;
        }
        
        ret = avRecvAudioData(avIndex, buf, AUDIO_BUF_SIZE, (char *)&frameInfo, sizeof(FRAMEINFO_t), &frmNo);
        if(ret == AV_ER_SESSION_CLOSE_BY_REMOTE)
        {
            NSLog(@"[thread_ReceiveAudio] AV_ER_SESSION_CLOSE_BY_REMOTE");
            break;
        }
        else if(ret == AV_ER_REMOTE_TIMEOUT_DISCONNECT)
        {
            NSLog(@"[thread_ReceiveAudio] AV_ER_REMOTE_TIMEOUT_DISCONNECT  ");
            break;
        }
        else if(ret == IOTC_ER_INVALID_SID)
        {
            NSLog(@"[thread_ReceiveAudio] Session cant be used anymore");
            break;
        }
        else if (ret == AV_ER_LOSED_THIS_FRAME)
        {
            continue;
        }
        
        if (ret>0) {
            
            NSData *data = [NSData dataWithBytes:buf length:ret];
            
            NSLog(@"音频数据%@", data);
            
            void (^executeBlock)() = ^{
                [weakself.player addAudioBuffer:data];
            
                
            };
            
            if (![[NSThread currentThread]isEqual:[NSThread mainThread]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    executeBlock();
                });
            }else{
                executeBlock();
            }
            
        }
        
    }
    
    [weakself.player stopPlay];
    
    NSLog(@"[thread_ReceiveAudio] thread exit");
    
    
}





-(void)startVideoService:(int)avIndex{
    NSLog(@"开启视频");
    
    char *buf = malloc(VIDEO_BUF_SIZE);
    unsigned int frmNo;
    int ret;
    FRAMEINFO_t frameInfo;
    int mSize = sizeof(buf);
    int fSize = sizeof(FRAMEINFO_t);
    
    NSData *data;
    
    
    while (1)
    {
        ret = avRecvFrameData2(avIndex, buf, VIDEO_BUF_SIZE, &mSize, &mSize,(char *)&frameInfo, sizeof(FRAMEINFO_t),&fSize,&frmNo);
        
        if(ret == AV_ER_DATA_NOREADY)
        {
            //NSLog(@"未准备好接收");
            //usleep(30000);
            continue;
        }
        else if(ret == AV_ER_LOSED_THIS_FRAME)
        {
            NSLog(@"Lost video frame NO[%d]", frmNo);
            continue;
        }
        else if(ret == AV_ER_INCOMPLETE_FRAME)
        {
            NSLog(@"Incomplete video frame NO[%d]", frmNo);
            continue;
        }
        else if(ret == AV_ER_SESSION_CLOSE_BY_REMOTE)
        {
            NSLog(@"[thread_ReceiveVideo] AV_ER_SESSION_CLOSE_BY_REMOTE");
            break;
        }
        else if(ret == AV_ER_REMOTE_TIMEOUT_DISCONNECT)
        {
            NSLog(@"[thread_ReceiveVideo] AV_ER_REMOTE_TIMEOUT_DISCONNECT");
            break;
        }
        else if(ret == IOTC_ER_INVALID_SID)
        {
            NSLog(@"[thread_ReceiveVideo] Session cant be used anymore");
            break;
        }else if(ret == AV_ER_NOT_INITIALIZED){
            NSLog(@"未初始化av");
            break;
        }else if(!buf){
            NSLog(@"buf 为空");
            break;
        }
        
        
        
        //if(frameInfo.flags == IPC_FRAME_FLAG_IFRAME)
        //{
        NSData *imageData = nil;
        
        data = [NSData dataWithBytes:buf length:ret];
        
        NSLog(@"视频数据%@", data);
        
//        imageData = [_decoder decodeFrame:data];
        CGColorSpaceRef colorSpaceRef = NULL;
        CGDataProviderRef provider = NULL;
        CGImageRef imageRef = NULL;
        
//        int width = decoder.imageWidth, height = _decoder.imageHeight;
        
//        provider = CGDataProviderCreateWithData(NULL,[imageData bytes],width*height*2,NULL);
        
        colorSpaceRef = CGColorSpaceCreateDeviceRGB();
        
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
        CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
        
//        imageRef = CGImageCreate(width,height,8,32,4*width,colorSpaceRef,bitmapInfo,provider,NULL,NO,renderingIntent);
        
        
        UIImage *newImage = [[UIImage alloc] initWithCGImage:imageRef]; //get image   *
        
        if (imageRef) {
            CGImageRelease( imageRef );
        }
        if ( provider ){
            CGDataProviderRelease( provider );
        }
        if ( colorSpaceRef ){
            CGColorSpaceRelease( colorSpaceRef );
        }
        
        
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
//            [[ControllerObj getViewController] updateImage:newImage];
            
        });
        
        //}
        
    }
    free(buf);
    
    NSLog(@"[thread_ReceiveVideo] thread exit");
    
    
}











int start_ipcam_stream (int avIndex) {
    
    int ret;
    unsigned short val = 0;
    
    if ((ret = avSendIOCtrl(avIndex, IOTYPE_INNER_SND_DATA_DELAY, (char *)&val, sizeof(unsigned short)) < 0))
    {
        NSLog(@"start_ipcam_stream_failed[%d]", ret);
        return 0;
    }
    
    SMsgAVIoctrlAVStream ioMsg;
    memset(&ioMsg, 0, sizeof(SMsgAVIoctrlAVStream));
    if ((ret = avSendIOCtrl(avIndex, IOTYPE_USER_IPCAM_START, (char *)&ioMsg, sizeof(SMsgAVIoctrlAVStream)) < 0))
    {
        NSLog(@"start_ipcam_stream_failed[%d]", ret);
        return 0;
    }
    
    if ((ret = avSendIOCtrl(avIndex, IOTYPE_USER_IPCAM_AUDIOSTART, (char *)&ioMsg, sizeof(SMsgAVIoctrlAVStream)) < 0))
    {
        NSLog(@"start_ipcam_stream_failed[%d]", ret);
        return 0;
    }
    
    return 1;
}


unsigned int _getTickCount() {
    
    struct timeval tv;
    
    if (gettimeofday(&tv, NULL) != 0)
        return 0;
    
    return (tv.tv_sec * 1000 + tv.tv_usec / 1000);
}

@end
