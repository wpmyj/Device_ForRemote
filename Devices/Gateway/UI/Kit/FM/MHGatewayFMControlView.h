//
//  MHGatewayFMControlView.h
//  MiHome
//
//  Created by guhao on 2/22/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHLumiFmPlayer.h"

@interface MHGatewayFMControlView : UIControl

@property (nonatomic, strong) MHLumiFmPlayer *fmPlayer;

//更新FM状态
- (void)updateStastus;
- (instancetype)initWithFrame:(CGRect)frame sensor:(MHDeviceGateway *)gateway;

@end
