//
//  MHLumiAudioPlayer.h
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/21.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioFile.h>
#define NUM_BUFFERS 4

/**
 *  从小米PlayAudio复制过来主要代码。修改了播放参数，优化了缓冲机制，解决网络卡，有嗒嗒的杂音
 */
@interface MHLumiAudioPlayer : NSObject

//定义队列为实例属性
@property AudioQueueRef queue;

+ (instancetype)shareInstance;
//播放方法定义
-(id)initWithAudio:(NSString *) path;
//定义缓存数据读取方法
-(void) audioQueueOutputWithQueue:(AudioQueueRef)audioQueue
                      queueBuffer:(AudioQueueBufferRef)audioQueueBuffer;
-(UInt32)readPacketsIntoBuffer:(AudioQueueBufferRef)buffer;

-(void)addAudioBuffer:(NSData *)bufferdata;

-(void)startPlay;

-(void)stopPlay;

- (void)flushAudio;

- (void)reset;

@end