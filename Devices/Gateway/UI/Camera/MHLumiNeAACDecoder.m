//
//  MHLumiNeAACDecoder.m
//  MiHome
//
//  Created by LM21Mac002 on 16/9/21.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiNeAACDecoder.h"
static const unsigned long kAudioOutBufferLength = 10000;

@interface MHLumiNeAACDecoder ()
@property (nonatomic) NeAACDecHandle *aachandle;
@property (nonatomic, assign) unsigned long samplerate;
@property (nonatomic, assign) unsigned char channelNum;
@property (nonatomic) NeAACDecFrameInfo frameInfo;
@end

@implementation MHLumiNeAACDecoder
- (instancetype)initWithaudioData:(const void *)audioData
                           length:(int)length
                       samplerate:(unsigned long)samplerate
                       channelNum:(unsigned char)channelNum{
    self = [super init];
    if (self) {
        _samplerate = samplerate;
        _channelNum = channelNum;
        _aachandle = NeAACDecOpen();
        memset(&_frameInfo, 0, sizeof(NeAACDecFrameInfo));
        NeAACDecInit(_aachandle, (unsigned char *)audioData, length, &samplerate, &_channelNum);
        _audioOutBuffer = (unsigned char*)malloc(kAudioOutBufferLength);
    }
    return self;
}

- (void *)decodeAudioData:(const void *)audioData length:(int)length{
    void *voicebuff = malloc(length);
    memcpy(voicebuff, audioData, length);
    memset(&_frameInfo, 0, sizeof(NeAACDecFrameInfo));
    NeAACDecDecode2(_aachandle, &_frameInfo, (unsigned char *)voicebuff, length, &_audioOutBuffer, kAudioOutBufferLength);
    free(voicebuff);
    unsigned long outsize = [self dataLengthWithFormatId];
    if (outsize>0)
    {
        return _audioOutBuffer;
    }
    return nil;
}

- (unsigned long)dataLengthWithFormatId{
    unsigned long outsize = 0;
    NeAACDecConfigurationPtr config  = NeAACDecGetCurrentConfiguration(_aachandle);
    switch (config->outputFormat)
    {
        case FAAD_FMT_16BIT:
            outsize = 2 * _frameInfo.samples;
            break;
        case FAAD_FMT_24BIT:
            outsize = 3 * _frameInfo.samples;
            break;
        case FAAD_FMT_32BIT:
            outsize = 4 * _frameInfo.samples;
            break;
        case FAAD_FMT_FLOAT:
            outsize = sizeof(short) * _frameInfo.samples;
            break;
        case FAAD_FMT_DOUBLE:
            outsize = sizeof(double) * _frameInfo.samples;
            break;
    }
    return outsize;
}

@end
