//
//  MHLumiCameraPhotosViewController.h
//  Lumi_demo_OC
//
//  Created by LM21Mac002 on 2016/10/25.
//  Copyright © 2016年 LM21Mac002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/PHPhotoLibrary.h>
#import "MHLuDeviceViewControllerBase.h"
#import "MHDeviceCamera.h"


@interface MHLumiCameraPhotosViewController : MHLuDeviceViewControllerBase
@property (nonatomic, assign) NSInteger currentIndex;
@property (readonly ,strong, nonatomic) MHDeviceCamera *cameraDevice;
- (instancetype)initWithCameraDevice:(MHDeviceCamera *)device;
+ (PHAuthorizationStatus)authorizationStatus;
+ (void)requestAuthorization:(void(^)(PHAuthorizationStatus status))handler;
@end
