//
//  MHGatewayClockFMCollectViewController.h
//  MiHome
//
//  Created by guhao on 16/4/27.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceGateway.h"
#import "MHLumiXMDataManager.h"

@interface MHGatewayClockFMCollectViewController : MHLuViewController

- (id)initWithRadioDevice:(MHDeviceGateway *)radioDevice;

@property (nonatomic, copy) void(^onDone)(MHLumiXMRadio *selectedRadio);

@end
