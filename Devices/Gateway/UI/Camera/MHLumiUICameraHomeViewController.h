//
//  MHLumiUICameraHomeViewController.h
//  MiHome
//
//  Created by LM21Mac002 on 16/10/19.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLuDeviceViewControllerBase.h"
#import "MHDeviceCamera.h"
@class MHLumiUICameraHomeViewController;
@protocol MHLumiUICameraHomeViewControllerDelegate <NSObject>
@optional
- (void)homeViewControllerDidOnRecording:(MHLumiUICameraHomeViewController *)homeViewController;
- (void)homeViewControllerDidOffRecording:(MHLumiUICameraHomeViewController *)homeViewController;
- (void)homeViewController:(MHLumiUICameraHomeViewController *)homeViewController shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
- (UIInterfaceOrientation)homeViewControllerCurrentInterfaceOrientation:(MHLumiUICameraHomeViewController *)homeViewController;
- (void)homeViewController:(MHLumiUICameraHomeViewController *)homeViewController willHiddenControlPanel:(BOOL)hidden withDuration:(NSTimeInterval)duration;
@end

@interface MHLumiUICameraHomeViewController : MHLuDeviceViewControllerBase
@property (readonly ,strong, nonatomic) MHDeviceCamera *cameraDevice;
- (instancetype)initWithCameraDevice:(MHDeviceCamera *)device;
@property (weak, nonatomic) id<MHLumiUICameraHomeViewControllerDelegate> delegate;
@end
