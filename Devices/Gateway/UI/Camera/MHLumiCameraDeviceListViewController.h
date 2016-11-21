//
//  MHLumiCameraDeviceListViewController.h
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/1.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHLuDeviceViewControllerBase.h"
#import "MHDeviceGateway.h"
#import "MHDeviceGatewayBase.h"

@class MHLumiCameraDeviceListViewController;

@protocol MHLumiCameraDeviceListViewControllerDelegate <NSObject>
@optional
- (void)cameraDeviceListViewControllerCallWhenDeviceCountChange:(MHLumiCameraDeviceListViewController *)cameraDeviceListViewController;

@end

/**
 *  主要代码都是从MHGatewayDeviceListViewController复制过来，有时间再重构
 */
@interface MHLumiCameraDeviceListViewController : MHLuDeviceViewControllerBase

@property (nonatomic, copy) void (^clickAddDeviceBtn)();
@property (nonatomic, copy) void (^clickDeviceCell)(MHDeviceGatewayBase *device);
@property (nonatomic, copy) void (^clickChangeBattery)(MHDeviceGatewayBase *device);
@property (nonatomic, copy) void (^deviceCountChange)();
@property (nonatomic, strong, readonly) UIButton *btnAddDevice;
@property (nonatomic, weak) id<MHLumiCameraDeviceListViewControllerDelegate> delegate;
- (void)startRefresh;
- (id)initWithDevice:(MHDeviceGateway* )device;

@end
