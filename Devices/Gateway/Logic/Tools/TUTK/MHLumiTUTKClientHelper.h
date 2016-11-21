//
//  MHLumiTUTKClientHelper.h
//  MiHome
//
//  Created by LM21Mac002 on 16/9/20.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHLumiTUTKHeader.h"

//@protocol MHLumiTUTKClientHelperDeleagate <NSObject>
//+ (NSString *)ioCtrlJSonStringWithAVChannelId:(int) avChannelId;
//
//+ (NSString *)ioCtrlVideoModeJSonStringWithAVChannelId:(int) avChannelId andVideoMode:(MHLumiTUTKVideoMode)mode;
//
//+ (NSString *)ioCtrlVideoQualityJSonStringWithAVChannelId:(int) avChannelId andQuality:(MHLumiTUTKVideoQuality)quality;
//
//+ (NSString *)ioCtrlBackwardStopJSonString;
//
//+ (NSString *)ioCtrlTalkBackStopJSonStringWithAVChannelId:(int)avChannelId;
//
//+ (NSString *)ioCtrlTalkBackStartJSonStringWithAVChannelId:(int)avChannelId;
//
//+ (NSString *)ioCtrlBackwardStartJSonStringWithTimeStr:(NSString *)timeStr;
//@end



@interface MHLumiTUTKClientHelper<MHLumiTUTKClientHelperDeleagate> : NSObject
+ (NSString *)ioCtrlJSonStringWithAVChannelId:(int) avChannelId;

+ (NSString *)ioCtrlVideoModeJSonStringWithAVChannelId:(int) avChannelId andVideoMode:(MHLumiTUTKVideoMode)mode;

+ (NSString *)ioCtrlVideoQualityJSonStringWithAVChannelId:(int) avChannelId andQuality:(MHLumiTUTKVideoQuality)quality;

+ (NSString *)ioCtrlBackwardStopJSonString;

+ (NSString *)ioCtrlTalkBackStopJSonStringWithAVChannelId:(int)avChannelId;

+ (NSString *)ioCtrlTalkBackStartJSonStringWithAVChannelId:(int)avChannelId;

+ (NSString *)ioCtrlBackwardStartJSonStringWithTimeStr:(NSString *)timeStr;

+ (NSString *)ioCtrlGetBackwardTimeJSonString;
@end
