//
//  MHLumiRecorder2.m
//  SFFmpegIOSDecoder
//
//  Created by LM21Mac002 on 16/10/13.
//  Copyright © 2016年 Lei Xiaohua. All rights reserved.
//

#import "MHLumiRecorder2.h"
#import "MHLumiAVAudioConverter.h"
#import "MHLumiAACEncoder.h"
//#import "AACEncoder.h"

@interface MHLumiRecorder2()<AVCaptureAudioDataOutputSampleBufferDelegate>
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) dispatch_queue_t audioQueue;
@property (strong, nonatomic) MHLumiAACEncoder *lumiAACEncoder;
//@property (strong, nonatomic) AACEncoder *aacEncoder;
@property (strong, nonatomic) MHLumiAVAudioConverter *aacConverter;
@property (strong, nonatomic) NSFileHandle *fileHandle;
@property (strong, nonatomic) dispatch_queue_t encodeQueue;
@end

@implementation MHLumiRecorder2

+ (void)requestRecordPermission:(PermissionBlock)response{
    [[AVAudioSession sharedInstance] requestRecordPermission:response];
}

+ (AVAudioSessionRecordPermission)recordPermission{
    return [[AVAudioSession sharedInstance] recordPermission];
}

- (BOOL)open{
    NSError *error;
    self.captureSession = [[AVCaptureSession alloc]init];
    AVCaptureDevice *audioDev = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    if (audioDev && audioDev.connected) {
        // Get the device name
        NSLog(@"Audio Device Name: %@", audioDev.localizedName);
    } else {
        NSLog(@"AVCaptureDevice defaultDeviceWithMediaType failed or device not connected!");
        return NO;
    }
    
    // create mic device
    AVCaptureDeviceInput *audioIn = [AVCaptureDeviceInput deviceInputWithDevice:audioDev error:&error];
    if (error != nil){
        NSLog(@"Couldn't create audio input");
        return NO;
    }
    
    // add mic device in capture object
    if ([self.captureSession canAddInput:audioIn] == NO){
        NSLog(@"Couldn't add audio input");
        return NO;
    }
    [self.captureSession addInput:audioIn];
    
    // export audio data
    AVCaptureAudioDataOutput *audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    if ([self.captureSession canAddOutput:audioOutput] == NO){
        NSLog(@"Couldn't add audio output");
        return NO;
    }
    [self.captureSession addOutput:audioOutput];
    [audioOutput setSampleBufferDelegate:self queue:self.audioQueue];
    [audioOutput connectionWithMediaType:AVMediaTypeAudio];
    [self.captureSession startRunning];
    return YES;
}

- (void)close {
    if (self.captureSession != nil && [self.captureSession isRunning]){
        [self.captureSession stopRunning];
    }
    return;
}

- (BOOL)isOpen {
    if (self.captureSession == nil){
        return NO;
    }
    
    return [self.captureSession isRunning];
}

/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
+ (NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    //设置录音格式
    [dicM setObject:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(44100) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(2) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(16) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //....其他设置等
    return dicM;
}


#pragma mark - getter,setter

- (AVCaptureSession *)captureSession{
    if (!_captureSession){
        _captureSession = [[AVCaptureSession alloc] init];
    }
    return _captureSession;
}

- (dispatch_queue_t)audioQueue{
    if (!_audioQueue){
        _audioQueue = dispatch_queue_create("audioQueue.MHLumiRecorder2", DISPATCH_QUEUE_SERIAL);
    }
    return _audioQueue;
}

- (dispatch_queue_t)encodeQueue{
    if (!_encodeQueue){
        _encodeQueue = dispatch_queue_create("encodeQueue.MHLumiRecorder2", DISPATCH_QUEUE_SERIAL);
    }
    return _encodeQueue;
}

#pragma mark - AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
//    CMFormatDescriptionRef formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer);
//    const AudioStreamBasicDescription* basicDesc = CMAudioFormatDescriptionGetStreamBasicDescription(formatDesc);
//    if (basicDesc) {
//        [self printASBD:*basicDesc];
//    }
    static CFTimeInterval a = 0;
    a = CACurrentMediaTime();
//    static  NSString *path = nil;
    if (!_lumiAACEncoder){
//        _aacConverter = [[MHLumiAVAudioConverter alloc] init];
//        path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
//        path = [path stringByAppendingPathComponent:@"ll.aac"];
//        NSLog(@"path: %@",path);
//        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
//        _aacEncoder = [[AACEncoder alloc] init];
        _lumiAACEncoder = [[MHLumiAACEncoder alloc] init];
    }
    
//    NSData *data = [NSData dataWithContentsOfFile:path];
//    if (data){
//        NSLog(@"文件大小：%ld",data.length);
//    }
//    NSLog(@"录音了");
    [_lumiAACEncoder encodeSampleBuffer:sampleBuffer callBackQueue:self.encodeQueue completionBlock:^(NSData *encodedData, NSError *error) {
        if (!error) {
//            NSLog(@"编码成功");
            if ([self.delegate respondsToSelector:@selector(recorderOutput:audioData:)]){
                [self.delegate recorderOutput:self audioData:encodedData];
            }
        }else if(error.code != -1990){
            NSLog(@"编码怎么了？error: %@",error);
        }
    }];
    NSLog(@"时间差%f",CACurrentMediaTime() - a);
//    [_aacEncoder encodeSampleBuffer:sampleBuffer completionBlock:^(NSData *encodedData, NSError *error) {
//        if (!error) {
//            NSLog(@"编码成功");
//        }else{
//            NSLog(@"编码怎么了？error: %@",error);
//        }
//    }];
//    
//    char szBuf[4028];
//    int  nSize = sizeof(szBuf);
//    if ([_aacConverter encoderAAC:sampleBuffer aacData:szBuf aacLen:&nSize]){
//            NSLog(@"编码成功");
//    }else{
//        NSLog(@"编码怎么了？");
//    }
//    NSData *rawAAC = [NSData dataWithBytes:szBuf length:nSize];
//    NSData *adtsHeader = [_aacConverter adtsDataForPacketLength:rawAAC.length];
//    NSMutableData *fullData = [NSMutableData dataWithData:adtsHeader];
//    [fullData appendData:rawAAC];
//    if ([self.delegate respondsToSelector:@selector(recorderOutput:audioData:)]){
//        [self.delegate recorderOutput:self audioData:fullData];
//    }
    
//    AudioStreamBasicDescription outputFormat = *(CMAudioFormatDescriptionGetStreamBasicDescription(CMSampleBufferGetFormatDescription(sampleBuffer)));
//    nSize = CMSampleBufferGetTotalSampleSize(sampleBuffer);
//    CMBlockBufferRef databuf = CMSampleBufferGetDataBuffer(sampleBuffer);
//    if (CMBlockBufferCopyDataBytes(databuf, 0, nSize, szBuf) == kCMBlockBufferNoErr){
//        NSLog(@"0k");
////        [g_pViewController sendAudioData:szBuf len:nSize channel:outputFormat.mChannelsPerFrame];
//    }
}

- (void) printASBD: (AudioStreamBasicDescription) asbd {
    
    char formatIDString[5];
    UInt32 formatID = CFSwapInt32HostToBig (asbd.mFormatID);
    bcopy (&formatID, formatIDString, 4);
    formatIDString[4] = '\0';
    
    NSLog (@"  Sample Rate:         %10.0f",  asbd.mSampleRate);
    NSLog (@"  Format ID:           %10s",    formatIDString);
    NSLog (@"  Format Flags:        %10X",    asbd.mFormatFlags);
    NSLog (@"  Bytes per Packet:    %10d",    asbd.mBytesPerPacket);
    NSLog (@"  Frames per Packet:   %10d",    asbd.mFramesPerPacket);
    NSLog (@"  Bytes per Frame:     %10d",    asbd.mBytesPerFrame);
    NSLog (@"  Channels per Frame:  %10d",    asbd.mChannelsPerFrame);
    NSLog (@"  Bits per Channel:    %10d",    asbd.mBitsPerChannel);
}

@end
