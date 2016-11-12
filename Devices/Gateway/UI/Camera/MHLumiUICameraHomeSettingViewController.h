//
//  MHLumiUICameraHomeSettingViewController.h
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/10.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayBaseSettingViewController.h"
#import "MHDeviceCamera.h"

@class MHLumiUICameraHomeSettingViewController;
@protocol MHLumiUICameraHomeSettingViewControllerDelegate <NSObject>

- (void)cameraHomeSettingViewController:(MHLumiUICameraHomeSettingViewController *)cameraHomeSettingViewController
                      didChangDeviceName:(NSString *)name;

@end

@interface MHLumiUICameraHomeSettingViewController : MHGatewayBaseSettingViewController
@property (nonatomic, strong) MHDeviceCamera *cameraDevice;
@property (nonatomic, weak) id<MHLumiUICameraHomeSettingViewControllerDelegate> delegate;
@end
