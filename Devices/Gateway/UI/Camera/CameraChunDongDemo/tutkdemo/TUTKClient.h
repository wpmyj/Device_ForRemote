//
//  MHTutkClient.h
//  TutkOperation
//
//  Created by huchundong on 2016/8/23.
//  Copyright © 2016年 huchundong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TUTKCommandOperation.h"
#import "TUTKCommandOperation.h"
#import "MHBaseClient.h"
#import <ffmpegWrapper/MHVideoFrameYUV.h>

@protocol TUTKClientDelegate
- (void)decodeVideoBuffer:(MHVideoFrameYUV*)frame;
- (void)onAudioReceived:(void *)audiobuff length:(int)length;
@end

@interface TUTKClient : MHBaseClient

@property(nonatomic, assign)BOOL clientInit;

@property (nonatomic, copy)  NSString* udid;
@property (nonatomic, strong) NSString* password;
@property (nonatomic, assign) int session; //IOTC session ID
@property (nonatomic, assign) int avChannel; //AV channel ID
@property (nonatomic, assign) BOOL isRecvVideo;

@property (nonatomic, assign) BOOL isRecvAudio;

@property(nonatomic, weak)id<TUTKClientDelegate> delegate;

- (void)initConnection:(TUTKCommandSuccess)success fail:(TUTKCommandFail)fail;
- (void)deinitConnectoin:(TUTKCommandSuccess)success fail:(TUTKCommandFail)fail;
- (void)cancelAllRequest;

- (void)sendAudioCommand:(TUTKCommandSuccess) success fail:(TUTKCommandFail)fail;

@end


