//
//  MHIFTTTMusicChooseViewController.h
//  MiHome
//
//  Created by Lynn on 1/28/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceGateway.h"

@interface MHIFTTTMusicChooseViewController : MHLuViewController

@property (nonatomic, copy) void(^onSelectMusicMid)(NSInteger mid);
@property (nonatomic, copy) void(^onSelectMusicVolume)(NSInteger volume);

- (id)initWithGateway:(MHDeviceGateway*)gateway musicGroup:(NSInteger)group;

@end
