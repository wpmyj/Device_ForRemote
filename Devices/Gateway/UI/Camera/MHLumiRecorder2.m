//
//  MHLumiRecorder2.m
//  SFFmpegIOSDecoder
//
//  Created by LM21Mac002 on 16/10/13.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiRecorder2.h"

@interface MHLumiRecorder2()<AVCaptureAudioDataOutputSampleBufferDelegate>
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) dispatch_queue_t audioQueue;
@end

@implementation MHLumiRecorder2

+ (void)requestRecordPermission:(PermissionBlock)response{
    [[AVAudioSession sharedInstance] requestRecordPermission:response];
}

+ (AVAudioSessionRecordPermission)recordPermission{
    return [[AVAudioSession sharedInstance] recordPermission];
}

+ (void)configureAudioSession{
    BOOL ret = NO;
    NSError* error = nil;
    ret = [[AVAudioSession sharedInstance] setActive:NO error:&error];
    if (!ret) {
        NSLog(@"setActive(NO) failed:%@", error);
    }
    ret = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&error];
    if (!ret) {
        NSLog(@"setCategory failed:%@", error);
    }
    ret = [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (!ret) {
        NSLog(@"setActive(YES) failed:%@", error);
    }
}

- (instancetype)init{
    self = [super init];
    if (self) {
        
        NSError* error = nil;
        
        _captureSession = [[AVCaptureSession alloc] init];
        [_captureSession beginConfiguration];
        
        // Input
        AVCaptureDevice* audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        AVCaptureDeviceInput* audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];
        if (audioInput) {
            [_captureSession addInput:audioInput];
        } else {
            NSLog(@"Failed:%@", error);
        }
        
        // Output
        AVCaptureAudioDataOutput* audioOutput = [[AVCaptureAudioDataOutput alloc] init];
        [audioOutput setSampleBufferDelegate:self queue:self.audioQueue];
        [_captureSession addOutput:audioOutput];
        
        [_captureSession commitConfiguration];
    }
    return self;
}

- (BOOL)isRecording {
    if (self.captureSession == nil){
        return NO;
    }
    
    return [self.captureSession isRunning];
}

- (void)startRecording{
    NSLog(@"%s", __FUNCTION__);
    
    if ([_captureSession isRunning]) {
        return;
    }
    dispatch_async(self.audioQueue/*dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)*/, ^{
        [self->_captureSession startRunning];
    });
}

- (void)stopRecording{
    NSLog(@"%s", __FUNCTION__);
    
    if (![_captureSession isRunning]) {
        return;
    }
    dispatch_async(self.audioQueue/*dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)*/, ^{
        [self->_captureSession stopRunning];
    });
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

#pragma mark - AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
//    CMFormatDescriptionRef formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer);
//    const AudioStreamBasicDescription* basicDesc = CMAudioFormatDescriptionGetStreamBasicDescription(formatDesc);
//    if (basicDesc) {
//        [self printASBD:*basicDesc];
//    }
//    CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
//    size_t dataLen = CMBlockBufferGetDataLength(blockBuffer);
//    char* audioData = (char *)malloc(dataLen);
//    CMBlockBufferGetDataPointer(blockBuffer, 0, NULL, NULL, &audioData);
//    OSStatus err = CMBlockBufferCopyDataBytes(blockBuffer, 0, dataLen, audioData);
//    CFRelease(blockBuffer);
//    if (err == kCMBlockBufferNoErr) {
//        if ([self.delegate respondsToSelector:@selector(lumiRecorder2:audioData:streamBasicDescription:)]) {
//            NSData *data = [NSData dataWithBytes:audioData length:dataLen];
//            [self.delegate lumiRecorder2:self audioData:data streamBasicDescription:*basicDesc];
//        }
//    } else {
//        NSLog(@"copy failed:%d", err);
//    }
//    
//    free(audioData);
    
    if ([self.delegate respondsToSelector:@selector(lumiRecorder2:didOutputSampleBuffer:)]){
        [self.delegate lumiRecorder2:self didOutputSampleBuffer:sampleBuffer];
    }
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
