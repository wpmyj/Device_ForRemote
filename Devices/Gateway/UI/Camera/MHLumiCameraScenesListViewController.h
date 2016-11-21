//
//  MHLumiCameraScenesListViewController.h
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/1.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHLuDeviceViewControllerBase.h"
typedef enum : NSInteger{
    CameraGateway_System_Scene_Alarm = 0,
    CameraGateway_System_Scene_DoorBell,
    CameraGateway_System_Scene_AlarmClock,
}CameraSysIftType;

/**
 *  主要代码都是从MHGatewaySceneListViewController复制过来，有时间再重构
 */
@interface MHLumiCameraScenesListViewController : MHLuDeviceViewControllerBase

@property (nonatomic, copy) void (^sysIftCellClicked)(CameraSysIftType type);
@property (nonatomic, copy) void (^customIftCellClicked)(MHDataIFTTTRecord *record);
@property (nonatomic, copy) void (^offlineRecord)(MHDataIFTTTRecord *record);
@property (nonatomic, copy) void (^sceneLogClicked)(void);
@property (nonatomic, strong, readonly) UIButton *btnSetting;
@property (nonatomic, strong, readonly) UIButton *btnAddDevice;

- (id)initWithDevice:(MHDeviceGateway* )device ;
- (void)loadIFTTTRecords;

@end