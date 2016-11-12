//
//  MHLumiAVPlayerView.m
//  Lumi_demo_OC
//
//  Created by Noverre on 2016/10/30.
//  Copyright © 2016年 LM21Mac002. All rights reserved.
//

#import "MHLumiAVPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@interface MHLumiAVPlayerView()
@end

@implementation MHLumiAVPlayerView
- (void)dealloc{
    [self.player pause];
}

- (instancetype)initWithFrame:(CGRect)frame withPlayer:(AVPlayer *)player{
    self = [super initWithFrame:frame];
    if (self){
        [self playerLayer].player = player;
    }
    return self;
}

+ (Class)layerClass{
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)playerLayer{
    return (AVPlayerLayer *)self.layer;
}

- (AVPlayer *)player{
    return [self playerLayer].player;
}

@end
