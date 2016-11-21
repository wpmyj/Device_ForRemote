//
//  MHLumiMuxer.h
//  MiHome
//
//  Created by LM21Mac002 on 16/10/18.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface MHLumiMuxer : NSObject
- (void)muxWithInputVideoName:(NSString *)inputVideoName
               inputAudioName:(NSString *)inputAudioName
            andOutputFileName:(NSString *)outputFileName
                        queue:(dispatch_queue_t)queue
              completeHandler:(void(^)(int))completeHandler;

- (void)muxWithInputVideoName:(NSString *)inputVideoName
               inputAudioName:(NSString *)inputAudioName
            andOutputFileName:(NSString *)outputFileName
              completeHandler:(void(^)(int))completeHandler;

- (int)muxWithInputVideoName:(NSString *)inputVideoName
              inputAudioName:(NSString *)inputAudioName
           andOutputFileName:(NSString *)outputFileName;
@end
