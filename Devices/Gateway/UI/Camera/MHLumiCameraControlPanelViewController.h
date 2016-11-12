//
//  MHLumiCameraControlPanelViewController.h
//  MiHome
//
//  Created by LM21Mac002 on 16/10/19.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLuDeviceViewControllerBase.h"
#import "MHDeviceCamera.h"
@interface MHLumiCameraControlPanelViewController : MHLuDeviceViewControllerBase
@property (assign, nonatomic) NSInteger selectIndex;
@property (strong, nonatomic) MHDeviceCamera *cameraDevice;
@property (readonly, assign, nonatomic) BOOL isLandscapeRight;
- (void)setButtonsContanerViewHidden:(BOOL)hidden animation:(NSTimeInterval)animation;
@end
