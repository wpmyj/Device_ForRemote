//
//  MHLumiAACEncoder2.h
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/8.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
@interface MHLumiAACEncoder2 : NSObject
-(void)encodeSmapleBuffer:(CMSampleBufferRef)sampleBuffer;
@end
