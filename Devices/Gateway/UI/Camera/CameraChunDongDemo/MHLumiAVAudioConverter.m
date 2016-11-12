//
//  MHLumiAVAudioConverter.m
//  SFFmpegIOSDecoder
//
//  Created by LM21Mac002 on 16/10/13.
//  Copyright © 2016年 Lei Xiaohua. All rights reserved.
//

#import "MHLumiAVAudioConverter.h"

@interface MHLumiAVAudioConverter()
@end

@implementation MHLumiAVAudioConverter{
    AudioConverterRef  _audioConverter;
}

-(BOOL)createAudioConvert:(CMSampleBufferRef)sampleBuffer { //根据输入样本初始化一个编码转换器
    if (_audioConverter != nil){
        return YES;
    }
    
    AudioStreamBasicDescription inputFormat = *(CMAudioFormatDescriptionGetStreamBasicDescription(CMSampleBufferGetFormatDescription(sampleBuffer))); // 输入音频格式
    AudioStreamBasicDescription outputFormat = {0};
    outputFormat.mSampleRate        = inputFormat.mSampleRate; // 采样率保持一致
    outputFormat.mFormatFlags       = kMPEG4Object_AAC_LC;
    outputFormat.mFormatID          = kAudioFormatMPEG4AAC;    // AAC编码
    outputFormat.mBytesPerPacket    = 0;
    outputFormat.mChannelsPerFrame  = 1;
    outputFormat.mBytesPerFrame     = 0;
    outputFormat.mFramesPerPacket   = 1024;                    // AAC一帧是1024个字节
    outputFormat.mBitsPerChannel = 0;
    outputFormat.mReserved = 0;
    AudioClassDescription *desc = [self getAudioClassDescriptionWithType:kAudioFormatMPEG4AAC fromManufacturer:kAppleSoftwareAudioCodecManufacturer];
    if (AudioConverterNewSpecific(&inputFormat, &outputFormat, 1, desc, &_audioConverter) != noErr){
        NSLog(@"AudioConverterNewSpecific failed");
        return NO;
    }
    
    return YES;
}

-(BOOL)encoderAAC:(CMSampleBufferRef)sampleBuffer aacData:(char*)aacData aacLen:(int*)aacLen { // 编码PCM成AAC
    if ([self createAudioConvert:sampleBuffer] != YES){
        return NO;
    }
    
    CMBlockBufferRef blockBuffer = nil;
    AudioBufferList  inBufferList;
    OSStatus status = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, NULL, &inBufferList, sizeof(inBufferList), NULL, NULL, 0, &blockBuffer);
    if (status != noErr){
        NSLog(@"CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer failed");
        return NO;
    }
    // 初始化一个输出缓冲列表
    AudioBufferList outBufferList;
    outBufferList.mNumberBuffers              = 1;
    outBufferList.mBuffers[0].mNumberChannels = 2;
    outBufferList.mBuffers[0].mDataByteSize   = *aacLen; // 设置缓冲区大小
    outBufferList.mBuffers[0].mData           = aacData; // 设置AAC缓冲区
    UInt32 outputDataPacketSize               = 1;
    status = AudioConverterFillComplexBuffer(_audioConverter, inputDataProc, &inBufferList, &outputDataPacketSize, &outBufferList, NULL);
    if (status != noErr) {
        NSLog(@"error getting audio format propery: %d", (int)(status));
        return nil;
    }
    
    *aacLen = outBufferList.mBuffers[0].mDataByteSize; //设置编码后的AAC大小
    CFRelease(blockBuffer);
    NSLog(@"currentThread %@",[NSThread currentThread]);
    return YES;
}

-(AudioClassDescription*)getAudioClassDescriptionWithType:(AudioFormatID)type fromManufacturer:(UInt32)manufacturer { // 获得相应的编码器
    static AudioClassDescription audioDesc;
    
    UInt32 encoderSpecifier = type, size = 0;
    OSStatus status;
    
    memset(&audioDesc, 0, sizeof(audioDesc));
    status = AudioFormatGetPropertyInfo(kAudioFormatProperty_Encoders, sizeof(encoderSpecifier), &encoderSpecifier, &size);
    if (status){
        NSLog(@"error getting audio format propery info: %d", (int)(status));
        return nil;
    }
    
    uint32_t count = size / sizeof(AudioClassDescription);
    AudioClassDescription descs[count];
    status = AudioFormatGetProperty(kAudioFormatProperty_Encoders, sizeof(encoderSpecifier), &encoderSpecifier, &size, descs);
    if (status) {
        NSLog(@"error getting audio format propery: %d", (int)(status));
        return nil;
    }
    for (uint32_t i = 0; i < count; i++)
    {
        if ((type == descs[i].mSubType) && (manufacturer == descs[i].mManufacturer))
        {
            memcpy(&audioDesc, &descs[i], sizeof(audioDesc));
            break;
        }
    }
    return &audioDesc;
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
- (NSData*)adtsDataForPacketLength:(NSUInteger)packetLength {
    int adtsLength = 7;
    char *packet = malloc(sizeof(char) * adtsLength);
    // Variables Recycled by addADTStoPacket
    int profile = 1;  //AAC LC
    //39=MediaCodecInfo.CodecProfileLevel.AACObjectELD;
    int freqIdx = 4;  //44.1KHz
    int chanCfg = 2;  //MPEG-4 Audio Channel Configuration. 1 Channel front-center
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

OSStatus inputDataProc(AudioConverterRef inConverter,
                       UInt32 *ioNumberDataPackets,
                       AudioBufferList *ioData,
                       AudioStreamPacketDescription **outDataPacketDescription,
                       void *inUserData) {
    //AudioConverterFillComplexBuffer 编码过程中，会要求这个函数来填充输入数据，也就是原始PCM数据</span>
    AudioBufferList bufferList = *(AudioBufferList*)inUserData;
    ioData->mBuffers[0].mNumberChannels = 2;
    ioData->mBuffers[0].mData           = bufferList.mBuffers[0].mData;
    ioData->mBuffers[0].mDataByteSize   = bufferList.mBuffers[0].mDataByteSize;
    return noErr;
}



@end
