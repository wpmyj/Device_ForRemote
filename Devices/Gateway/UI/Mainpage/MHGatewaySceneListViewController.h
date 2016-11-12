//
//  MHGatewaySceneListViewController.h
//  MiHome
//
//  Created by Lynn on 2/16/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceGateway.h"
#import "MHIFTTTManager.h"

typedef enum : NSInteger{
    Gateway_System_Scene_Alarm = 0,
    Gateway_System_Scene_NightLight,
    Gateway_System_Scene_TimerLight,
    Gateway_System_Scene_AlarmClock,
    Gateway_System_Scene_DoorBell,
}SysIftType;

@interface MHGatewaySceneListViewController : MHLuViewController

@property (nonatomic, copy) void (^sysIftCellClicked)(SysIftType type);
@property (nonatomic, copy) void (^customIftCellClicked)(MHDataIFTTTRecord *record);
@property (nonatomic, copy) void (^offlineRecord)(MHDataIFTTTRecord *record);
@property (nonatomic, copy) void (^sceneLogClicked)(void);

- (id)initWithFrame:(CGRect)frame sensor:(MHDeviceGateway* )gateway ;
- (void)loadIFTTTRecords;

@end
