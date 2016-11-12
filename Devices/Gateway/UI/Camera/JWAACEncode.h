//
//  JWAACEncode.h
//  JWEncode - H.264
//
//  Created by 黄进文 on 16/9/7.
//  Copyright © 2016年 evenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface JWAACEncode : NSObject

@property (nonatomic) dispatch_queue_t jEncoderQueue;

@property (nonatomic) dispatch_queue_t jCallBackQueue;

- (void)encodeSampleBuffer:(CMSampleBufferRef)sampleBuffer completianBlock:(void (^)(NSData *encodedData, NSError *error))completionBlock;

@end































