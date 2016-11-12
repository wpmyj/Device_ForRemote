//
//  MHLumiTUTKClient.h
//  MiHome
//
//  Created by LM21Mac002 on 16/9/20.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHLumiTUTKConfiguration.h"
#import "MHLumiTUTKClientHelper.h"
#import <ffmpegWrapper/MHVideoFrameYUV.h>
#import "IOTCAPIs.h"
#import "AVAPIs.h"
#import "AVIOCTRLDEFs.h"
#import "MHLumiTUTKHeader.h"

extern const int kInitFFMpegFailure;
extern const int kIsFetchingVideoData;
extern const int kIsFetchingAudioData;
extern const int kIsNotFetchingVideoData;
extern const int kIsNotFetchingAudioData;

@class MHLumiTUTKClient;
@protocol MHLumiTUTKClientDelegate
- (void)client:(MHLumiTUTKClient *)client onVideoReceived:(AVFrame*)frame
                                            avcodecContext:(AVCodecContext*)avcodecContext
                                            gotPicturePtr:(int)gotPicturePtr;

- (void)client:(MHLumiTUTKClient *)client videoBuffer:(const void *)videoBuffer length:(int)length;

- (void)client:(MHLumiTUTKClient *)client onAudioReceived:(void *)audiobuffer length:(int)length;

@end

@interface MHLumiTUTKClient : NSObject

- (MHLumiTUTKClient *)initWithConfiguration:(MHLumiTUTKConfiguration *)configurarion;
- (void)initConnectionWithCompletedHandler:(void(^)(MHLumiTUTKClient *client,int retCode)) completedHandler;
- (void)deinitConnection;

//Video
- (void)startVideoStreamWithJsonString:(NSString *)jsonString
                      startRequestData:(BOOL) yesOrNot
                      completedHandler:(void(^)(MHLumiTUTKClient *client,int retCode)) completedHandler;
- (BOOL)setRequestVideoDataOrNotWithFlag:(BOOL)flag;
- (void)stopVideoStreamWithJsonString:(NSString *)jsonString
                        completedHandler:(void(^)(MHLumiTUTKClient *client,int retCode)) completedHandler;

//audio
- (void)startAudioStreamWithJsonString:(NSString *)jsonString
                      startRequestData:(BOOL) yesOrNot
                      completedHandler:(void(^)(MHLumiTUTKClient *client,int retCode)) completedHandler;
- (BOOL)setRequestAudioDataOrNotWithFlag:(BOOL)flag;
- (void)stopAudioStreamWithJsonString:(NSString *)jsonString
                     completedHandler:(void (^)(MHLumiTUTKClient *, int))completedHandler;

//video mode
- (void)setVideoMode:(MHLumiTUTKVideoMode)mode
      WithJsonString:(NSString *)jsonString
    completedHandler:(void (^)(MHLumiTUTKClient *, int))completedHandler;

//video quality
- (void)setVideoQuality:(MHLumiTUTKVideoQuality)quality
      WithJsonString:(NSString *)jsonString
    completedHandler:(void (^)(MHLumiTUTKClient *, int))completedHandler;

//backward回看
- (void)setBackwardWithJsonString:(NSString *)jsonString
                      startOrStop:(bool)startOrStop
                 completedHandler:(void (^)(MHLumiTUTKClient *, int))completedHandler;
- (void)getBackwardRecordTimeWithJsonString:(NSString *)jsonString
                            completeHandler:(void(^)(MHLumiTUTKClient *,int))completedHandler;
//talkBack
- (void)startAndfetchTalkBackServIdWithJsonString:(NSString *)jsonString
                                 completedHandler:(void (^)(MHLumiTUTKClient *, int))completedHandler;
- (void)stopTalkBackWithJsonString:(NSString *)jsonString
                  completedHandler:(void (^)(MHLumiTUTKClient *, int))completedHandler;
- (void)addAccData:(NSData *)accData;
- (void)resetAccData;
//applicationDidEnterBackground
- (void)applicationDidEnterBackground;
- (void)applicationWillEnterForeground;

//property
@property (nonatomic, weak) id<MHLumiTUTKClientDelegate> delegate;
@property (nonatomic, strong, readonly) MHLumiTUTKConfiguration *configuration;
@property (nonatomic, assign, readonly) int sessionId; //IOTC session ID
@property (nonatomic, assign, readonly) int avChannelId; //AV channel ID
@property (nonatomic, assign, readonly) int talkbackAVChannelId;
@property (nonatomic, assign, readonly) int talkbackServiceId; //talkbackServiceId

@property (atomic, assign, readonly) MHLumiTUTKClientstatus prevClientStatus;
@property (atomic, assign, readonly) MHLumiTUTKStreamstatus prevVideoStreamStatus;
@property (atomic, assign, readonly) MHLumiTUTKStreamstatus prevAudioStreamStatus;

@property (atomic, assign, readonly) MHLumiTUTKClientstatus clientStatus;
@property (atomic, assign, readonly) MHLumiTUTKStreamstatus videoStreamStatus;
@property (atomic, assign, readonly) MHLumiTUTKStreamstatus audioStreamStatus;
@property (atomic, assign, readonly) MHLumiTUTKTalkbackStatus talkbackServiceStatus;
@property (nonatomic, assign, readonly) MHLumiTUTKVideoMode videoMode;
@property (nonatomic, assign, readonly) MHLumiTUTKVideoQuality videoQuality;
@property (assign, nonatomic) NSTimeInterval videoUpdateInterval;

//queue
@property (nonatomic, strong, readonly) dispatch_queue_t clientQueue;
@property (nonatomic, strong, readonly) dispatch_queue_t fetchVideoDataQueue;
@property (nonatomic, strong, readonly) dispatch_queue_t fetchAudioDataQueue;
@property (assign) bool canceled;

//fetch data
- (BOOL)proactiveFetchVideoDataWithABAVFrame:(AVFrame *)frame frameInfo:(LumiTUTKFrameInfo *)frameInfo gotPicturePtr:(int *)pictureCout;


@end
