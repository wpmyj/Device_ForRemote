//
//  MHLumiRecorder2.h
//  SFFmpegIOSDecoder
//
//  Created by LM21Mac002 on 16/10/13.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class MHLumiRecorder2;

@protocol MHLumiRecorder2Delegate <NSObject>
@optional
- (void)lumiRecorder2:(MHLumiRecorder2 *)recorder audioData:(NSData *)data streamBasicDescription:(AudioStreamBasicDescription)streamBasicDescription;
- (void)lumiRecorder2:(MHLumiRecorder2 *)recorder didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@end

@interface MHLumiRecorder2 : NSObject
@property (nonatomic, weak) id<MHLumiRecorder2Delegate> delegate;
//判断麦克风授权情况
+ (void)requestRecordPermission:(PermissionBlock)response;
+ (AVAudioSessionRecordPermission)recordPermission;
+ (void)configureAudioSession;
- (void)startRecording;
- (void)stopRecording;
- (BOOL)isRecording;
@end
