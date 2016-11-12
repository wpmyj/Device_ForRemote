//
//  MHLumiAACEncoder.h
//  SFFmpegIOSDecoder
//
//  Created by LM21Mac002 on 16/10/13.
//  Copyright © 2016年 Lei Xiaohua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface MHLumiAACEncoder : NSObject
@property (nonatomic) dispatch_queue_t encodeQueue;
- (void) encodeSampleBuffer:(CMSampleBufferRef)sampleBuffer
              callBackQueue:(dispatch_queue_t)queue
            completionBlock:(void (^)(NSData * encodedData, NSError* error))completionBlock;

- (void)creatEncoderWithAudioStreamBasicDescription:(AudioStreamBasicDescription)inAudioStreamBasicDescription;
- (void) encodeData:(NSData *)audioData
      callBackQueue:(dispatch_queue_t)queue
    completionBlock:(void (^)(NSData * encodedData, NSError* error))completionBlock;
@end
