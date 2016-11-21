//
//  MHLumiAACEncoder.m
//  SFFmpegIOSDecoder
//
//  Created by LM21Mac002 on 16/10/13.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiAACEncoder.h"

@interface MHLumiAACEncoder()
@property (nonatomic) AudioConverterRef audioConverter;
@property (nonatomic) uint8_t *aacBuffer;
@property (nonatomic) NSUInteger aacBufferSize;
@property (nonatomic) char *pcmBuffer;
@property (nonatomic) size_t pcmBufferSize;
@property (nonatomic, strong) NSMutableData *pcmData;
@property (nonatomic, assign) AudioStreamBasicDescription inAudioStreamBasicDescription;
@property (nonatomic, assign) AudioStreamBasicDescription outAudioStreamBasicDescription;
@end

@implementation MHLumiAACEncoder

- (void) dealloc {
    AudioConverterDispose(_audioConverter);
    free(_aacBuffer);
}


- (instancetype) init{
    if (self = [super init]) {
        _audioConverter = NULL;
        _pcmBufferSize = 0;
        _pcmBuffer = NULL;
        _aacBufferSize = 1024;
        _aacBuffer = NULL;
        _pcmData = [NSMutableData data];
    }
    return self;
}

- (void) setupEncoderFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    AudioStreamBasicDescription inAudioStreamBasicDescription = *CMAudioFormatDescriptionGetStreamBasicDescription((CMAudioFormatDescriptionRef)CMSampleBufferGetFormatDescription(sampleBuffer));
    AudioStreamBasicDescription outAudioStreamBasicDescription = {0}; // Always initialize the fields of a new audio stream basic description structure to zero, as shown here: ...
    outAudioStreamBasicDescription.mSampleRate = inAudioStreamBasicDescription.mSampleRate; // The number of frames per second of the data in the stream, when the stream is played at normal speed. For compressed formats, this field indicates the number of frames per second of equivalent decompressed data. The mSampleRate field must be nonzero, except when this structure is used in a listing of supported formats (see “kAudioStreamAnyRate”).
    outAudioStreamBasicDescription.mFormatID = kAudioFormatMPEG4AAC; // kAudioFormatMPEG4AAC_HE does not work. Can't find `AudioClassDescription`. `mFormatFlags` is set to 0.
    outAudioStreamBasicDescription.mFormatFlags = kMPEG4Object_AAC_LC; // Format-specific flags to specify details of the format. Set to 0 to indicate no format flags. See “Audio Data Format Identifiers” for the flags that apply to each format.
    outAudioStreamBasicDescription.mBytesPerPacket = 0; // The number of bytes in a packet of audio data. To indicate variable packet size, set this field to 0. For a format that uses variable packet size, specify the size of each packet using an AudioStreamPacketDescription structure.
    outAudioStreamBasicDescription.mFramesPerPacket = 1024; // The number of frames in a packet of audio data. For uncompressed audio, the value is 1. For variable bit-rate formats, the value is a larger fixed number, such as 1024 for AAC. For formats with a variable number of frames per packet, such as Ogg Vorbis, set this field to 0.
    outAudioStreamBasicDescription.mBytesPerFrame = 0; // The number of bytes from the start of one frame to the start of the next frame in an audio buffer. Set this field to 0 for compressed formats. ...
    outAudioStreamBasicDescription.mChannelsPerFrame = inAudioStreamBasicDescription.mChannelsPerFrame; // The number of channels in each frame of audio data. This value must be nonzero.
    outAudioStreamBasicDescription.mBitsPerChannel = 0; // ... Set this field to 0 for compressed formats.
    outAudioStreamBasicDescription.mReserved = 0; // Pads the structure out to force an even 8-byte alignment. Must be set to 0.
    AudioClassDescription *description = [self
                                          getAudioClassDescriptionWithType:kAudioFormatMPEG4AAC
                                          fromManufacturer:kAppleSoftwareAudioCodecManufacturer];
    
    OSStatus status = AudioConverterNewSpecific(&inAudioStreamBasicDescription, &outAudioStreamBasicDescription, 1, description, &_audioConverter);
    if (status != 0) {
        NSLog(@"setup converter: %d", (int)status);
    }
    
    UInt32 ulBitRate = 64000;
    UInt32 ulSize = sizeof(ulBitRate);
    status = AudioConverterSetProperty(_audioConverter, kAudioConverterEncodeBitRate, ulSize, &ulBitRate);
    
    if (status != 0) {
        NSLog(@"AudioConverterSetProperty failure: %d", (int)status);
    }
    
    UInt32 value = 0;
    UInt32 size = sizeof(value);
    AudioConverterGetProperty(_audioConverter, kAudioConverterPropertyMaximumOutputPacketSize, &size, &value);
    _aacBufferSize = value;
    _aacBuffer = malloc(_aacBufferSize * sizeof(uint8_t));
    memset(_aacBuffer, 0, _aacBufferSize);
    self.inAudioStreamBasicDescription = inAudioStreamBasicDescription;
    self.outAudioStreamBasicDescription = outAudioStreamBasicDescription;
}

- (AudioClassDescription *)getAudioClassDescriptionWithType:(UInt32)type
                                           fromManufacturer:(UInt32)manufacturer
{
    static AudioClassDescription desc;
    
    UInt32 encoderSpecifier = type;
    OSStatus st;
    
    UInt32 size;
    st = AudioFormatGetPropertyInfo(kAudioFormatProperty_Encoders,
                                    sizeof(encoderSpecifier),
                                    &encoderSpecifier,
                                    &size);
    if (st) {
        NSLog(@"error getting audio format propery info: %d", (int)(st));
        return nil;
    }
    
    unsigned int count = size / sizeof(AudioClassDescription);
    AudioClassDescription descriptions[count];
    st = AudioFormatGetProperty(kAudioFormatProperty_Encoders,
                                sizeof(encoderSpecifier),
                                &encoderSpecifier,
                                &size,
                                descriptions);
    if (st) {
        NSLog(@"error getting audio format propery: %d", (int)(st));
        return nil;
    }
    
    for (unsigned int i = 0; i < count; i++) {
        if ((type == descriptions[i].mSubType) &&
            (manufacturer == descriptions[i].mManufacturer)) {
            memcpy(&desc, &(descriptions[i]), sizeof(desc));
            return &desc;
        }
    }
    
    return nil;
}

static OSStatus inInputDataProc(AudioConverterRef inAudioConverter, UInt32 *ioNumberDataPackets, AudioBufferList *ioData, AudioStreamPacketDescription **outDataPacketDescription, void *inUserData)
{
    MHLumiAACEncoder *encoder = (__bridge MHLumiAACEncoder *)(inUserData);
    UInt32 requestedPackets = *ioNumberDataPackets * 2;
    size_t copiedSamples = [encoder copyPCMSamplesIntoBuffer:ioData withLength:requestedPackets];
    if (copiedSamples < requestedPackets) {
        *ioNumberDataPackets = 0;
        return -1990;
    }
    *ioNumberDataPackets = 1;
    return noErr;
}

/**
 *  填充PCM到缓冲区
 */
- (size_t)copyPCMSamplesIntoBuffer:(AudioBufferList *)ioData withLength:(UInt32)length{
    if (self.pcmData.length < length) {
        return 0;
    }
    _pcmBufferSize = length;
    [self.pcmData getBytes:_pcmBuffer length:length];
    ioData->mBuffers[0].mData = _pcmBuffer;
    ioData->mBuffers[0].mDataByteSize = (uint32_t)_pcmBufferSize;
    _pcmBuffer = NULL;
    _pcmBufferSize = 0;
    NSData *todoData = [self.pcmData subdataWithRange:NSMakeRange(length, self.pcmData.length-length)];
    if (todoData == nil){
        todoData = [NSData data];
    }
    self.pcmData = [NSMutableData dataWithData:todoData];
//    NSLog(@"pcmDataLength = %lu",(unsigned long)self.pcmData.length);
    return length;
}

- (void) encodeSampleBuffer:(CMSampleBufferRef)sampleBuffer
              callBackQueue:(dispatch_queue_t)queue
            completionBlock:(void (^)(NSData * encodedData, NSError* error))completionBlock {
    CFRetain(sampleBuffer);
    if (!_audioConverter) {
        [self setupEncoderFromSampleBuffer:sampleBuffer];
    }
    CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    CFRetain(blockBuffer);
    OSStatus status = CMBlockBufferGetDataPointer(blockBuffer, 0, NULL, &self->_pcmBufferSize, &self->_pcmBuffer);
    [self.pcmData appendBytes:self.pcmBuffer length:self.pcmBufferSize];
    NSError *error = nil;
    if (status != kCMBlockBufferNoErr) {
        error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
    }
    
    memset(_aacBuffer, 0, _aacBufferSize);
    AudioBufferList outAudioBufferList = {0};
    outAudioBufferList.mNumberBuffers = 1;
    outAudioBufferList.mBuffers[0].mNumberChannels = self.outAudioStreamBasicDescription.mChannelsPerFrame;
    outAudioBufferList.mBuffers[0].mDataByteSize = (UInt32)_aacBufferSize;
    outAudioBufferList.mBuffers[0].mData = _aacBuffer;
    AudioStreamPacketDescription *outPacketDescription = NULL;
    UInt32 ioOutputDataPacketSize = 1;
    status = AudioConverterFillComplexBuffer(_audioConverter, inInputDataProc, (__bridge void *)(self), &ioOutputDataPacketSize, &outAudioBufferList, outPacketDescription);
    //NSLog(@"ioOutputDataPacketSize: %d", (unsigned int)ioOutputDataPacketSize);
    NSData *data = nil;
    if (status == 0) {
        NSData *rawAAC = [NSData dataWithBytes:outAudioBufferList.mBuffers[0].mData length:outAudioBufferList.mBuffers[0].mDataByteSize];
        NSData *adtsHeader = [self adtsDataForPacketLength:rawAAC.length
                                            withSamplerate:self.outAudioStreamBasicDescription.mSampleRate
                                          withChannelCount:self.outAudioStreamBasicDescription.mChannelsPerFrame];
        NSMutableData *fullData = [NSMutableData dataWithData:adtsHeader];
        [fullData appendData:rawAAC];
        data = fullData;
    } else {
        error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
    }
    CFRelease(sampleBuffer);
    CFRelease(blockBuffer);
    if (completionBlock) {
//        dispatch_async(queue, ^{
//            completionBlock(data, error);
//        });
        completionBlock(data, error);
    }
}

- (void) encodeData:(NSData *)audioData
      callBackQueue:(dispatch_queue_t)queue
    completionBlock:(void (^)(NSData * encodedData, NSError* error))completionBlock{
    _pcmBuffer = malloc(audioData.length);
    memcpy(_pcmBuffer, audioData.bytes, audioData.length);
    _pcmBufferSize = audioData.length;
    memset(_aacBuffer, 0, _aacBufferSize);
    [self.pcmData appendBytes:self.pcmBuffer length:self.pcmBufferSize];
    AudioBufferList outAudioBufferList = {0};
    outAudioBufferList.mNumberBuffers = 1;
    outAudioBufferList.mBuffers[0].mNumberChannels = 1;
    outAudioBufferList.mBuffers[0].mDataByteSize = (UInt32)_aacBufferSize;
    outAudioBufferList.mBuffers[0].mData = _aacBuffer;
    AudioStreamPacketDescription *outPacketDescription = NULL;
    UInt32 ioOutputDataPacketSize = 1;
    OSStatus status = 0;
    NSError *error = nil;
    status = AudioConverterFillComplexBuffer(_audioConverter, inInputDataProc, (__bridge void *)(self), &ioOutputDataPacketSize, &outAudioBufferList, outPacketDescription);
    //NSLog(@"ioOutputDataPacketSize: %d", (unsigned int)ioOutputDataPacketSize);
    NSData *data = nil;
    if (status == 0) {
        NSData *rawAAC = [NSData dataWithBytes:outAudioBufferList.mBuffers[0].mData length:outAudioBufferList.mBuffers[0].mDataByteSize];
        NSData *adtsHeader = [self adtsDataForPacketLength:rawAAC.length withSamplerate:44100 withChannelCount:1];
        NSMutableData *fullData = [NSMutableData dataWithData:adtsHeader];
        [fullData appendData:rawAAC];
        data = fullData;
    } else {
        error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
    }
    if (completionBlock) {
        //        dispatch_async(queue, ^{
        //            completionBlock(data, error);
        //        });
        completionBlock(data, error);
    }

}

/**
 *  Add ADTS header at the beginning of each and every AAC packet.
 *  This is needed as MediaCodec encoder generates a packet of raw
 *  AAC data.
 *
 *  Note the packetLen must count in the ADTS header itself.
 *  See: http://wiki.multimedia.cx/index.php?title=ADTS
 *  Also: http://wiki.multimedia.cx/index.php?title=MPEG-4_Audio#Channel_Configurations
 **/
- (NSData*) adtsDataForPacketLength:(NSUInteger)packetLength withSamplerate:(int)samplerate withChannelCount:(int)channelCount{
    int adtsLength = 7;
    char *packet = malloc(sizeof(char) * adtsLength);
    // Variables Recycled by addADTStoPacket
    //    int profile = 2;  //AAC LC
    //    //39=MediaCodecInfo.CodecProfileLevel.AACObjectELD;
    //    int freqIdx = 4;  //44.1KHz
    //    int chanCfg = 1;  //MPEG-4 Audio Channel Configuration. 1 Channel front-center
    
    /*andriod 那边的配置**/
    int profile = 1;  //AAC LC
    int freqIdx = [self freqIdxForAdtsHeader:samplerate];  //4-4.4KHz
    int chanCfg = [self channelIdxForAdtsHeader:channelCount];  //CPE20
    
    NSUInteger fullLength = adtsLength + packetLength;
    // fill in ADTS data
    packet[0] = (char)0xFF; // 11111111     = syncword
    packet[1] = (char)0xF9; // 1111 1 00 1  = syncword MPEG-2 Layer CRC
    packet[2] = (char)(((profile)<<6) + (freqIdx<<2) +(chanCfg>>2));
    packet[3] = (char)(((chanCfg&3)<<6) + (fullLength>>11));
    packet[4] = (char)((fullLength&0x7FF) >> 3);
    packet[5] = (char)(((fullLength&7)<<5) + 0x1F);
    packet[6] = (char)0xFC;
    NSData *data = [NSData dataWithBytesNoCopy:packet length:adtsLength freeWhenDone:YES];
    return data;
}

- (int)freqIdxForAdtsHeader:(int)samplerate{
    /**
     0: 96000 Hz
     1: 88200 Hz
     2: 64000 Hz
     3: 48000 Hz
     4: 44100 Hz
     5: 32000 Hz
     6: 24000 Hz
     7: 22050 Hz
     8: 16000 Hz
     9: 12000 Hz
     10: 11025 Hz
     11: 8000 Hz
     12: 7350 Hz
     13: Reserved
     14: Reserved
     15: frequency is written explictly
     */
    int idx = 4;
    if (samplerate >= 7350 && samplerate < 8000) {
        idx = 12;
    }
    else if (samplerate >= 8000 && samplerate < 11025) {
        idx = 11;
    }
    else if (samplerate >= 11025 && samplerate < 12000) {
        idx = 10;
    }
    else if (samplerate >= 12000 && samplerate < 16000) {
        idx = 9;
    }
    else if (samplerate >= 16000 && samplerate < 22050) {
        idx = 8;
    }
    else if (samplerate >= 22050 && samplerate < 24000) {
        idx = 7;
    }
    else if (samplerate >= 24000 && samplerate < 32000) {
        idx = 6;
    }
    else if (samplerate >= 32000 && samplerate < 44100) {
        idx = 5;
    }
    else if (samplerate >= 44100 && samplerate < 48000) {
        idx = 4;
    }
    else if (samplerate >= 48000 && samplerate < 64000) {
        idx = 3;
    }
    else if (samplerate >= 64000 && samplerate < 88200) {
        idx = 2;
    }
    else if (samplerate >= 88200 && samplerate < 96000) {
        idx = 1;
    }
    else if (samplerate >= 96000) {
        idx = 0;
    }
    
    return idx;
}

-(int)channelIdxForAdtsHeader:(int)channelCount{
    /**
     0: Defined in AOT Specifc Config
     1: 1 channel: front-center
     2: 2 channels: front-left, front-right
     3: 3 channels: front-center, front-left, front-right
     4: 4 channels: front-center, front-left, front-right, back-center
     5: 5 channels: front-center, front-left, front-right, back-left, back-right
     6: 6 channels: front-center, front-left, front-right, back-left, back-right, LFE-channel
     7: 8 channels: front-center, front-left, front-right, side-left, side-right, back-left, back-right, LFE-channel
     8-15: Reserved
     */
    int ret = 2;
    if (channelCount == 1) {
        ret = 1;
    }
    else if (channelCount == 2) {
        ret = 2;
    }
    
    return ret;
}

//
//- (void)creatEncoderWithAudioStreamBasicDescription:(AudioStreamBasicDescription)inAudioStreamBasicDescription{
//    AudioStreamBasicDescription outAudioStreamBasicDescription = {0}; // Always initialize the fields of a new audio stream basic description structure to zero, as shown here: ...
//    outAudioStreamBasicDescription.mSampleRate = inAudioStreamBasicDescription.mSampleRate; // The number of frames per second of the data in the stream, when the stream is played at normal speed. For compressed formats, this field indicates the number of frames per second of equivalent decompressed data. The mSampleRate field must be nonzero, except when this structure is used in a listing of supported formats (see “kAudioStreamAnyRate”).
//    outAudioStreamBasicDescription.mFormatID = kAudioFormatMPEG4AAC; // kAudioFormatMPEG4AAC_HE does not work. Can't find `AudioClassDescription`. `mFormatFlags` is set to 0.
//    outAudioStreamBasicDescription.mFormatFlags = kMPEG4Object_AAC_LC; // Format-specific flags to specify details of the format. Set to 0 to indicate no format flags. See “Audio Data Format Identifiers” for the flags that apply to each format.
//    outAudioStreamBasicDescription.mBytesPerPacket = 0; // The number of bytes in a packet of audio data. To indicate variable packet size, set this field to 0. For a format that uses variable packet size, specify the size of each packet using an AudioStreamPacketDescription structure.
//    outAudioStreamBasicDescription.mFramesPerPacket = 1024; // The number of frames in a packet of audio data. For uncompressed audio, the value is 1. For variable bit-rate formats, the value is a larger fixed number, such as 1024 for AAC. For formats with a variable number of frames per packet, such as Ogg Vorbis, set this field to 0.
//    outAudioStreamBasicDescription.mBytesPerFrame = 0; // The number of bytes from the start of one frame to the start of the next frame in an audio buffer. Set this field to 0 for compressed formats. ...
//    outAudioStreamBasicDescription.mChannelsPerFrame = 1; // The number of channels in each frame of audio data. This value must be nonzero.
//    outAudioStreamBasicDescription.mBitsPerChannel = 0; // ... Set this field to 0 for compressed formats.
//    outAudioStreamBasicDescription.mReserved = 0; // Pads the structure out to force an even 8-byte alignment. Must be set to 0.
//    AudioClassDescription *description = [self
//                                          getAudioClassDescriptionWithType:kAudioFormatMPEG4AAC
//                                          fromManufacturer:kAppleSoftwareAudioCodecManufacturer];
//
//    OSStatus status = AudioConverterNewSpecific(&inAudioStreamBasicDescription, &outAudioStreamBasicDescription, 1, description, &_audioConverter);
//    if (status != 0) {
//        NSLog(@"setup converter: %d", (int)status);
//    }
//
//    UInt32 ulBitRate = 64000;
//    UInt32 ulSize = sizeof(ulBitRate);
//    status = AudioConverterSetProperty(_audioConverter, kAudioConverterEncodeBitRate, ulSize, &ulBitRate);
//
//    if (status != 0) {
//        NSLog(@"AudioConverterSetProperty failure: %d", (int)status);
//    }
//
//    UInt32 value = 0;
//    UInt32 size = sizeof(value);
//    AudioConverterGetProperty(_audioConverter, kAudioConverterPropertyMaximumOutputPacketSize, &size, &value);
//    _aacBufferSize = value;
//    _aacBuffer = malloc(_aacBufferSize * sizeof(uint8_t));
//    memset(_aacBuffer, 0, _aacBufferSize);
//    self.inAudioStreamBasicDescription = inAudioStreamBasicDescription;
//    self.outAudioStreamBasicDescription = outAudioStreamBasicDescription;
//}


@end
