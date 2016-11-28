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

@class MHLumiAlarmVideoPreviewViewController;

@protocol MHLumiAlarmVideoPreviewViewControllerDataSource <NSObject>

- (void)alarmVideoPreviewViewController:(MHLumiAlarmVideoPreviewViewController *)alarmVideoPreviewViewController
                          fetchVideoUrl:(void(^)(NSString *url,NSString *videoUrlIdentifier))fetchVideoUrlCompleteHandler;

@end

@interface MHLumiAlarmVideoPreviewViewController : MHLuDeviceViewControllerBase
@property (nonatomic, copy, readonly) NSString *videoUrl;
@property (readonly ,strong, nonatomic) MHDeviceCamera *cameraDevice;
@property (nonatomic, weak) id<MHLumiAlarmVideoPreviewViewControllerDataSource> dataSource;
- (instancetype)initWithCameraDevice:(MHDeviceCamera *)device;
@end
