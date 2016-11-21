//
//  MHLumiAlarmVideoPreviewViewController.h
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/15.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHLuDeviceViewControllerBase.h"
#import "MHDeviceCamera.h"

@interface MHLumiAlarmVideoPreviewViewController : MHLuDeviceViewControllerBase
@property (nonatomic, copy) NSString *videoUrl;
@property (readonly ,strong, nonatomic) MHDeviceCamera *cameraDevice;
- (instancetype)initWithCameraDevice:(MHDeviceCamera *)device;
@end
