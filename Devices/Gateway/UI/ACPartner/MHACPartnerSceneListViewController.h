//
//  MHACPartnerSceneListViewController.h
//  MiHome
//
//  Created by ayanami on 16/5/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceAcpartner.h"
#import "MHDataIFTTTRecomRecord.h"
typedef enum : NSInteger{
    Acpartner_System_Scene_Alarm = 0,
    Acpartner_System_Scene_DoorBell,
}ACSysIftType;

@interface MHACPartnerSceneListViewController : MHLuViewController

@property (nonatomic,copy) void (^sysIftCellClicked)(ACSysIftType type);
@property (nonatomic,copy) void (^iftttCellClicked)(id sender);
@property (nonatomic,copy) void (^sceneLogClicked)(void);
@property (nonatomic,copy) void (^offlineRecord)(MHDataIFTTTRecord *record);

- (id)initWithFrame:(CGRect)frame sensor:(MHDeviceAcpartner* )acpartner;
- (void)loadIFTTTRecords;

@end
