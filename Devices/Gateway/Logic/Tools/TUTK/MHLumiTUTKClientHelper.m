//
//  MHLumiTUTKClientHelper.m
//  MiHome
//
//  Created by LM21Mac002 on 16/9/20.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiTUTKClientHelper.h"
#import "NSDateFormatter+lumiDateFormatterHelper.h"

static const NSString * channelKey = @"channel";
static const NSString * modeKey = @"mode";
static const NSString * qualityKey = @"quality";
static const NSString * startTimeKey = @"start_time";
@implementation MHLumiTUTKClientHelper
+ (NSString *)ioCtrlJSonStringWithAVChannelId:(int)avChannelId{
    NSDictionary *paramsDic = @{ channelKey : @(avChannelId) };
    NSData *data = [NSJSONSerialization dataWithJSONObject:paramsDic options:0 error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

+ (NSString *)ioCtrlVideoModeJSonStringWithAVChannelId:(int)avChannelId andVideoMode:(MHLumiTUTKVideoMode)mode{
    NSString *modeName = nil;
    switch (mode) {
        case MHLumiTUTKVideoModeP180:
            modeName = @"p180";
            break;
        case MHLumiTUTKVideoModeP360:
            modeName = @"p360";
            break;
        case MHLumiTUTKVideoMode1R:
            modeName = @"1r";
            break;
        case MHLumiTUTKVideoMode4R:
            modeName = @"4r";
            break;
        case MHLumiTUTKVideoModeVR:
            modeName = @"vr";
            break;
        case MHLumiTUTKVideoModeORIGIN:
            modeName = @"origin";
            break;
        default:
            break;
    }
    NSDictionary *paramsDic = @{ channelKey : @(avChannelId) ,modeKey : modeName};
    NSData *data = [NSJSONSerialization dataWithJSONObject:paramsDic options:0 error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

+ (NSString *)ioCtrlVideoQualityJSonStringWithAVChannelId:(int)avChannelId andQuality:(MHLumiTUTKVideoQuality)quality{
    NSString *qualityName = nil;
    switch (quality) {
        case MHLumiTUTKVideoQualityHigh:
            qualityName = @"high_quality";
            break;
        case MHLumiTUTKVideoQualityStandard:
            qualityName = @"std_quality";
            break;
        case MHLumiTUTKVideoQualityAuto:
            qualityName = @"auto";
            break;
        default:
            break;
    }
    NSDictionary *paramsDic = @{ channelKey : @(avChannelId) ,qualityKey : qualityName};
    NSData *data = [NSJSONSerialization dataWithJSONObject:paramsDic options:0 error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

+ (NSString *)ioCtrlBackwardStopJSonString{
    return [MHLumiTUTKClientHelper ioCtrlPlaceHolderJSonString];
}

+ (NSString *)ioCtrlTalkBackStopJSonStringWithAVChannelId:(int)avChannelId{
    NSDictionary *paramsDic = @{ channelKey : @(avChannelId) };
    NSData *data = [NSJSONSerialization dataWithJSONObject:paramsDic options:0 error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

+ (NSString *)ioCtrlTalkBackStartJSonStringWithAVChannelId:(int)avChannelId{
    NSDictionary *paramsDic = @{ channelKey : @(avChannelId) };
    NSData *data = [NSJSONSerialization dataWithJSONObject:paramsDic options:0 error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

+ (NSString *)ioCtrlBackwardStartJSonStringWithTimeStr:(NSString *)timeStr{
    NSDictionary *paramsDic = @{ startTimeKey : @"20161114095637"};
    NSData *data = [NSJSONSerialization dataWithJSONObject:paramsDic options:0 error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

+ (NSString *)ioCtrlPlaceHolderJSonString{
    NSDictionary *paramsDic = [NSDictionary dictionary];
    NSData *data = [NSJSONSerialization dataWithJSONObject:paramsDic options:0 error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

+ (NSString *)timeStrForBackwardWithRelativeTime:(NSTimeInterval)relativeTime{
    NSDateFormatter *dateFormatter = [NSDateFormatter TUTKDateFormatter];
    NSString *timeStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:relativeTime]];
    return timeStr;
}

+ (NSString *)ioCtrlGetBackwardTimeJSonString{
    return [MHLumiTUTKClientHelper ioCtrlPlaceHolderJSonString];
}
@end
