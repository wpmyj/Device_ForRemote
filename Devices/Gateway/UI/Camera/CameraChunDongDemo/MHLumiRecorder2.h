//
//  MHLumiRecorder2.h
//  SFFmpegIOSDecoder
//
//  Created by LM21Mac002 on 16/10/13.
//  Copyright © 2016年 Lei Xiaohua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class MHLumiRecorder2;

@protocol MHLumiRecorder2Delegate <NSObject>

- (void)recorderOutput:(MHLumiRecorder2 *)recorder audioData:(NSData *)data;

@end

@interface MHLumiRecorder2 : NSObject
@property (nonatomic, weak) id<MHLumiRecorder2Delegate> delegate;
//判断麦克风授权情况
+ (void)requestRecordPermission:(PermissionBlock)response;
+ (AVAudioSessionRecordPermission)recordPermission;
- (BOOL)open;
- (void)close;
@end
