//
//  MHLumiAudioPlayer.m
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/21.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiAudioPlayer.h"
#define AVCODEC_MAX_AUDIO_FRAME_SIZE  4096*2// (0x10000)/4
static UInt32 gBufferSizeBytes=0x10000;//It must be pow(2,x)

//回调函数(Callback)的实现
static void BufferCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef buffer)
{
    MHLumiAudioPlayer* player = (__bridge MHLumiAudioPlayer*)inUserData;
    [player audioQueueOutputWithQueue:inAQ queueBuffer:buffer];
}

@implementation MHLumiAudioPlayer
{
    //音频格式描述
    AudioStreamBasicDescription     dataFormat;
    //音频队列
    AudioQueueRef                   _audioQueue;
    //音频缓冲区
    AudioQueueBufferRef             buffers[NUM_BUFFERS];
    //音频数据帧
    NSMutableArray                  *_audioFrames;
    BOOL                            _flagNOP;
    NSInteger                       _jumpCount;
    //    unsigned char *audiobuff;
}

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static MHLumiAudioPlayer* g_instance;
    dispatch_once(&onceToken, ^{
        g_instance = [[MHLumiAudioPlayer alloc] init];
    });
    return g_instance;
}


//缓存数据读取方法的实现
-(void) audioQueueOutputWithQueue:(AudioQueueRef)audioQueue queueBuffer:(AudioQueueBufferRef)audioQueueBuffer
{
    //读取包数据
    @synchronized(_audioFrames) {
        @autoreleasepool {
            //            NSLog(@"目前_audioFrames个数：%lu",(unsigned long)_audioFrames.count);
            AudioQueueBufferRef outBufferRef=audioQueueBuffer;
            BOOL oldFlag = _flagNOP;
            if (_audioFrames.count >= 25){
                _flagNOP = YES;
            }else if (_audioFrames.count <= 0){
                _flagNOP = NO;
            }
            if (oldFlag != _flagNOP || _jumpCount > 0 ){
                if (_flagNOP) {
                    _jumpCount = _jumpCount + 1;
                    NSLog(@"_jumpCount = %ld",_jumpCount);
                }else{
                    _jumpCount = 0;
                }
                Float32 gain= _flagNOP ? (_jumpCount>=4 ? 2.0 : 0.0): 0.0;
                AudioQueueSetParameter(_audioQueue, kAudioQueueParam_Volume, gain);
                if (_jumpCount >= 4){
                    _jumpCount = 0;
                }
            }
            if (!_flagNOP) {
                unsigned char *audiobuff = (unsigned char *)malloc(AVCODEC_MAX_AUDIO_FRAME_SIZE);
                memset(audiobuff, 0, AVCODEC_MAX_AUDIO_FRAME_SIZE);
                memcpy(outBufferRef->mAudioData, audiobuff, AVCODEC_MAX_AUDIO_FRAME_SIZE);
                outBufferRef->mAudioDataByteSize=AVCODEC_MAX_AUDIO_FRAME_SIZE;
                AudioQueueEnqueueBuffer(audioQueue, outBufferRef, 0, NULL);
                free(audiobuff);
            }else{
                //                NSLog(@"播放队列可以播了");
                NSData* aData = [_audioFrames objectAtIndex:0];
                
                const void * databuff = aData.bytes;
                UInt32 numBytes = (int)(aData.length);
                
                if (numBytes>0) {
                    memcpy(outBufferRef->mAudioData, databuff, aData.length);
                    outBufferRef->mAudioDataByteSize=numBytes;
                    AudioQueueEnqueueBuffer(audioQueue, outBufferRef, 0, NULL);
                }
                [_audioFrames removeObjectAtIndex:0];
            }
        }
    }
    
}

- (void)addAudioBuffer:(NSData *)bufferdata
{
    NSData* databuff = nil;
    if ([bufferdata length] > gBufferSizeBytes) {
        databuff = [[NSData alloc] initWithData:[bufferdata subdataWithRange:NSMakeRange(0, gBufferSizeBytes)]];
    } else {
        databuff = [[NSData alloc] initWithData:bufferdata];
    }
    
    if (!_audioFrames) {
        _audioFrames = [[NSMutableArray alloc]init];
    }
    
    @synchronized(_audioFrames) {
        if (_audioFrames.count >= 256) {
            [_audioFrames removeObjectAtIndex:0];
        }
        [_audioFrames addObject:databuff];
        //        NSLog(@"放了一个进去，目前_audioFrames个数：%lu",(unsigned long)_audioFrames.count);
    }
}

- (void)flushAudio
{
    @synchronized(_audioFrames) {
        [_audioFrames removeAllObjects];
    }
}

-(void)setupAudioPlay
{
    //取得音频数据格式
    dataFormat.mSampleRate=44100;//44100;//采样频率
    dataFormat.mFormatID=kAudioFormatLinearPCM;
    dataFormat.mFormatFlags=kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    dataFormat.mChannelsPerFrame=2;//2通道数
    dataFormat.mFramesPerPacket=1;//wav 通常为1
    dataFormat.mBitsPerChannel=16;//16;//采样的位数
    dataFormat.mBytesPerFrame=(dataFormat.mBitsPerChannel/8) * dataFormat.mChannelsPerFrame;//4;
    dataFormat.mBytesPerPacket=4;
    dataFormat.mReserved=0;
    //创建播放用的音频队列
    AudioQueueNewOutput(&dataFormat,
                        BufferCallback,
                        (__bridge void *)self,
                        NULL, // If you specify NULL, the callback is invoked on one of the audio queue’s internal threads.
                        NULL, // Typically, you pass kCFRunLoopCommonModes or use NULL, which is equivalent
                        0, // Reserved for future use. Must be 0.
                        &_audioQueue); // On output, the newly created playback audio queue object.
    //创建并分配缓冲控件
    for (int i=0; i<NUM_BUFFERS; i++) {
        AudioQueueAllocateBuffer(_audioQueue, gBufferSizeBytes, &buffers[i]);
        //读取包数据
        if ([self readPacketsIntoBuffer:buffers[i]]==1) {
            break;
        }
        AudioQueueEnqueueBuffer(_audioQueue, buffers[i], 0, nil);
    }
    
    //设置音量
    Float32 gain=2.0;
    AudioQueueSetParameter(_audioQueue, kAudioQueueParam_Volume, gain);
    _flagNOP = NO;
    _jumpCount = 0;
}

-(void)startPlay
{
    NSLog(@"初始化声音播放器...");
    if (_audioQueue) {
        return;
    }
    
    [self setupAudioPlay];
    
    NSLog(@"启动声音队列...");
    //队列处理开始，此后系统开始自动调用回调(Callback)函数
    OSStatus status = AudioQueueStart(_audioQueue, NULL);
    if (status) {
        NSLog(@"AudioQueueStart failed:%d", (int)status);
    }
}

-(void)stopPlay
{
    NSLog(@"暂停声音播放");
    if (_audioQueue == NULL) {
        return;
    }
    
    @synchronized(_audioFrames) {
        [_audioFrames removeAllObjects];
    }
    
    Float32 gain=0.1;
    AudioQueueSetParameter(_audioQueue, kAudioQueueParam_Volume, gain);
    AudioQueueStop(_audioQueue, YES);
    AudioQueueDispose(_audioQueue, YES);
    _audioQueue = NULL;
    
}

-(void)reset
{
    if (_audioQueue) {
        AudioQueueReset(_audioQueue);
    }
}

//音频播放方法的实现
-(id)initWithAudio:(NSString *)path
{
    if (!(self=[super init]))
        return nil;
    
    _audioFrames = [[NSMutableArray alloc]init];
    
    return self;
}

-(UInt32)readPacketsIntoBuffer:(AudioQueueBufferRef)buffer
{
    AudioQueueBufferRef outBufferRef=buffer;
    
    NSData* framedata = nil;
    @synchronized(_audioFrames) {
        NSUInteger count = _audioFrames.count;
        if (count > 0) {
            framedata = _audioFrames[0];
            [_audioFrames removeObjectAtIndex:0];
        } else {
            unsigned char *audiobuff = (unsigned char *)malloc(AVCODEC_MAX_AUDIO_FRAME_SIZE);
            memset(audiobuff, 0, AVCODEC_MAX_AUDIO_FRAME_SIZE);
            framedata = [[NSData alloc]initWithBytes:audiobuff length:AVCODEC_MAX_AUDIO_FRAME_SIZE];
            free(audiobuff);
        }
    }
    
    UInt32 numBytes = (int)(framedata.length);
    if(numBytes>0){
        memcpy(outBufferRef->mAudioData, framedata.bytes, numBytes);
        outBufferRef->mAudioDataByteSize=numBytes;
    }
    else{
        return 1;//意味着我们没有读到任何的包
    }
    
    return 0;//0代表正常的退出
}

@end