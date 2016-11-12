//
//  MHCameraDemoViewController.h
//  MiHome
//
//  Created by huchundong on 2016/8/23.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHDeviceViewControllerBase.h"
//#import "MHTutkDemoClient.h"
#import "TUTKClient.h"

@interface MHCameraDemoViewController : MHDeviceViewControllerBase
@property(nonatomic, strong)TUTKClient*      client;
@end
