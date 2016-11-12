//
//  MHGatewayCloudMusicViewController.h
//  MiHome
//
//  Created by Lynn on 8/31/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceGateway.h"


@interface MHGatewayCloudMusicViewController : MHViewController


typedef void (^ReturnStateBlock)(BOOL isSucceed);


@property (nonatomic, copy) ReturnStateBlock returnStateBlock;
- (id)initWithGateway:(MHDeviceGateway*)gateway;



@end
