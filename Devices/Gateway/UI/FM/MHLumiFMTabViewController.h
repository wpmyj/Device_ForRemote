//
//  MHLumiFMTabViewController.h
//  MiHome
//
//  Created by Lynn on 11/23/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceGateway.h"
#import "MHLumiFmPlayer.h"

@interface MHLumiFMTabViewController : MHLuViewController

@property (nonatomic, strong) MHLumiFmPlayer *fmPlayer;

- (id)initWithRadio:(MHDeviceGateway *)radio ;

@end
