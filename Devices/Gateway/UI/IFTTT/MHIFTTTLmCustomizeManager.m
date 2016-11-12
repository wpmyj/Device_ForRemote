//
//  MHIFTTTLmCustomizeManager.m
//  MiHome
//
//  Created by Lynn on 1/28/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHIFTTTLmCustomizeManager.h"
#import "MHIFTTTCustomizeViewController.h"

@implementation MHIFTTTLmCustomizeManager

+ (id)sharedInstance {
    static MHIFTTTLmCustomizeManager *obj = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        obj = [[MHIFTTTLmCustomizeManager alloc] init];
    });
    return obj;
}

- (NSString *)fetchSpecificActionCommand:(MHDataIFTTTAction *)action {
    NSString *key = [action.payload valueForKey:@"command"];
    NSRange range_Doorbell = [key rangeOfString:Gateway_IFTTT_DoorBell];
    if (range_Doorbell.length) return Gateway_IFTTT_DoorBell;
    NSRange range_PlayFm = [key rangeOfString:Gateway_IFTTT_PlayFm];
    if (range_PlayFm.length) return Gateway_IFTTT_PlayFm;
    NSRange range_PlayMusic = [key rangeOfString:Gateway_IFTTT_PlayMusic];
    if (range_PlayMusic.length) return Gateway_IFTTT_PlayMusic;
    
    return key;
}

- (NSString *)fetchSpecificLaunchKey:(id)launch {
    NSString *key = [launch valueForKey:@"key"];
    NSRange range = [key rangeOfString:Humiture_IFTTT_Temperature];
    if(range.length) return Humiture_IFTTT_Temperature;
    range = [key rangeOfString:Humiture_IFTTT_Humidity];
    if(range.length) return Humiture_IFTTT_Humidity;
    return key;
}


@end
