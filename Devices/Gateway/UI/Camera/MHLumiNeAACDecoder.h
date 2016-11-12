//
//  MHLumiNeAACDecoder.h
//  MiHome
//
//  Created by LM21Mac002 on 16/9/21.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "neaacdec.h"

@interface MHLumiNeAACDecoder : NSObject
- (instancetype)initWithaudioData:(const void *)audioData
                           length:(int)length
                       samplerate:(unsigned long)samplerate
                       channelNum:(unsigned char)channelNum;

- (void *)decodeAudioData:(const void *)audioData length:(int)length;
- (unsigned long)dataLengthWithFormatId;
@property (nonatomic, readonly) NeAACDecHandle *aachandle;
@property (nonatomic, assign, readonly) unsigned long samplerate;
@property (nonatomic, assign, readonly) unsigned char channelNum;
@property (nonatomic, readonly) NeAACDecFrameInfo frameInfo;
@property (nonatomic) void *audioOutBuffer;
@end
