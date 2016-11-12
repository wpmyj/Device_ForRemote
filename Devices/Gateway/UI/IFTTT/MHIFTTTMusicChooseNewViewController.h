//
//  MHIFTTTMusicChooseNewViewController.h
//  MiHome
//
//  Created by guhao on 16/5/9.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceGateway.h"

@interface MHIFTTTMusicChooseNewViewController : MHLuViewController

@property (nonatomic, copy) void(^onSelectMusicMid)(NSInteger mid);
@property (nonatomic, copy) void(^onSelectMusicVolume)(NSInteger volume);

- (id)initWithGateway:(MHDeviceGateway*)gateway musicGroup:(NSInteger)group;

@end
