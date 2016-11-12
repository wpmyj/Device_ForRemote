//
//  MHLumiAVAudioConverter.h
//  SFFmpegIOSDecoder
//
//  Created by LM21Mac002 on 16/10/13.
//  Copyright © 2016年 Lei Xiaohua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface MHLumiAVAudioConverter : NSObject
- (BOOL)encoderAAC:(CMSampleBufferRef)sampleBuffer aacData:(char*)aacData aacLen:(int*)aacLen;
- (NSData*)adtsDataForPacketLength:(NSUInteger)packetLength;
@end
