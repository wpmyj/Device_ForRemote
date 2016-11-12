//
//  MHMusicTipsView.h
//  MiHome
//
//  Created by Lynn on 10/27/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHTipsView.h"

#define CallBackPlayKey         @"play"
#define CallBackUploadKey       @"upload"
#define CallBackPauseKey        @"pause"
#define CallBackGiveUp          @"giveup"

typedef enum{
    Recording_Start,
    Recording_Stop,
    Recording_Cancel,
} RecordingStatus;

@interface MHMusicTipsView : MHTipsView

@property (nonatomic,assign) RecordingStatus rescordStatus;
@property (nonatomic,strong) NSString *currentStatus;

#pragma mark - play view
- (void)showRecordModal:(BOOL)isModal withTouchBlock:(void (^)(id))success andInfo:(NSString *)info;

#pragma mark - progresss
- (void)showProgressView:(CGFloat)progress withTips:(NSString *)tips;
- (void)setProgressCnt:(CGFloat)progress;

#pragma mark - play volume
- (void)showVolumeViewWithTips:(NSString *)tips;
- (void)setVolume:(int)volume;

#pragma mark - fm hardware volume
- (void)showFMHardwareVolumeProgress:(CGFloat)progress withTips:(NSString *)tips ;
- (void)setFMVolume:(CGFloat)progress;

- (void)showCancelView;

+ (MHMusicTipsView*)shareInstance;

@end
