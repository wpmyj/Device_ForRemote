//
//  MHIFTTTLmCustomizeManager.h
//  MiHome
//
//  Created by Lynn on 1/28/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#define Gateway_PlugInID        @"get_action_value"
#define Humiture_PlugInID       @"get_condition_value"

#define Humiture_IFTTT_Temperature    @"temperature"
#define Humiture_IFTTT_Humidity       @"humidity"
#define Gateway_IFTTT_DoorBell        @"door_bell"
#define Gateway_IFTTT_PlayFm          @"play_specify_fm"
#define Gateway_IFTTT_PlayMusic       @"play_music_new"

#import <Foundation/Foundation.h>
#import <MiHomeKit/MiHomeKit.h>
#import "MHDeviceGatewayBase.h"
#import "MHIFTTTGatewayCustomizeViewController.h"
#import "MHIFTTTHumitureCustomizeViewController.h"

@interface MHIFTTTLmCustomizeManager : NSObject

+ (id)sharedInstance ;

- (NSString *)fetchSpecificActionCommand:(id)action;

- (NSString *)fetchSpecificLaunchKey:(id)launch;

@end
