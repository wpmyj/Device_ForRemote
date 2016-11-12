//
//  MHLumiFMSearchViewController.h
//  MiHome
//
//  Created by Lynn on 1/19/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceGateway.h"
#import "MHLumiFmPlayer.h"

@interface MHLumiFMSearchViewController : MHLuViewController

@property (nonatomic,strong) MHDeviceGateway *radioDevice;
@property (nonatomic,strong) MHLumiFmPlayer *fmPlayer;

@end
