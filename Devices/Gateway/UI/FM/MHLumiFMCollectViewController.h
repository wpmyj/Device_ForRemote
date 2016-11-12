//
//  MHLumiFMViewController.h
//  MiHome
//
//  Created by Lynn on 11/16/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceGateway.h"
#import "MHLumiXMDataManager.h"
#import "MHLumiFmPlayer.h"

@interface MHLumiFMCollectViewController : MHLuViewController

@property (nonatomic, strong) MHLumiFmPlayer *fmPlayer;

- (id)initWithRadioDevice:(MHDeviceGateway *)radioDevice;

@end
