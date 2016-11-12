//
//  MHLumiAVPlayerView.h
//  Lumi_demo_OC
//
//  Created by Noverre on 2016/10/30.
//  Copyright © 2016年 LM21Mac002. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AVPlayer;
@interface MHLumiAVPlayerView : UIView
- (instancetype)initWithFrame:(CGRect)frame withPlayer:(AVPlayer *)player;
- (AVPlayer *)player;
@end
