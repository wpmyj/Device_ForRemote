//
//  MHLumiUICameraHomeSetOperatingModeViewController.m
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/10.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiUICameraHomeSetOperatingModeViewController.h"

@implementation MHLumiUICameraHomeSetOperatingModeViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    NSString *title = NSLocalizedStringFromTable(@"mydevice.actionsheet.more",@"plugin_gateway","更多");
    self.title = title;
}

- (void)buildSubviews {
    [super buildSubviews];
    [self settingDatasource];
}

- (void)settingDatasource{
    __weak typeof(self) weakself = self;
    NSString* mode1 = @"MHLumiDeviceCameraModeFloor";//NSLocalizedStringFromTable(@"mydevice.actionsheet.changename",@"plugin_gateway","修改设备名称");
    NSString* mode2 = @"MHLumiDeviceCameraModeCeiling";
    NSString* mode3 = @"MHLumiDeviceCameraModeWall";
    MHLuDeviceSettingGroup* group1 = [[MHLuDeviceSettingGroup alloc] init];
    NSMutableArray *curtainSettings = [NSMutableArray new];
    
    //mode1
    MHDeviceSettingItem *itemSafeGuardModel = [[MHDeviceSettingItem alloc] init];
    itemSafeGuardModel.identifier = @"camera_changeMode_MHLumiDeviceCameraModeFloor";
    itemSafeGuardModel.type = MHDeviceSettingItemTypeCheckmark;
    itemSafeGuardModel.hasAcIndicator = self.cameraDevice.OperatingMode == MHLumiDeviceCameraModeFloor;
    itemSafeGuardModel.caption = mode1;
    itemSafeGuardModel.comment = @"";
    itemSafeGuardModel.customUI = YES;
    itemSafeGuardModel.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
    itemSafeGuardModel.callbackBlock = ^(MHDeviceSettingCell *cell) {
        [weakself cameraChangeOperatingMode:MHLumiDeviceCameraModeFloor success:^{

        } failure:^(NSError *error) {
            
        }];
    };
    
    [curtainSettings addObject:itemSafeGuardModel];

    //mode2
    MHDeviceSettingItem *itemModel2 = [[MHDeviceSettingItem alloc] init];
    itemModel2.identifier = @"camera_changeMode_MHLumiDeviceCameraModeCeiling";
    itemModel2.type = MHDeviceSettingItemTypeCheckmark;
    itemModel2.hasAcIndicator = self.cameraDevice.OperatingMode == MHLumiDeviceCameraModeCeiling;
    itemModel2.caption = mode2;
    itemModel2.comment = @"";
    itemModel2.customUI = YES;
    itemModel2.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
    itemModel2.callbackBlock = ^(MHDeviceSettingCell *cell) {
        [weakself cameraChangeOperatingMode:MHLumiDeviceCameraModeCeiling success:^{

        } failure:^(NSError *error) {
            
        }];
    };
    
    [curtainSettings addObject:itemModel2];
    
    //mode3
    MHDeviceSettingItem *itemModel3 = [[MHDeviceSettingItem alloc] init];
    itemModel3.identifier = @"camera_changeMode_MHLumiDeviceCameraModeWall";
    itemModel3.type = MHDeviceSettingItemTypeCheckmark;
    itemModel3.hasAcIndicator = self.cameraDevice.OperatingMode == MHLumiDeviceCameraModeWall;
    itemModel3.caption = mode3;
    itemModel3.comment = @"";
    itemModel3.customUI = YES;
    itemModel3.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
    itemModel3.callbackBlock = ^(MHDeviceSettingCell *cell) {
        [weakself cameraChangeOperatingMode:MHLumiDeviceCameraModeWall success:^{

        } failure:^(NSError *error) {
            
        }];
    };
    
    [curtainSettings addObject:itemModel3];
    
    group1.items = curtainSettings;
    self.settingGroups = [NSMutableArray arrayWithObjects:group1,nil];
    [self.settingTableView reloadData];
}

- (void)cameraChangeOperatingMode:(MHLumiDeviceCameraMode)mode
                          success:(void(^)())success
                          failure:(void(^)(NSError *))failure{
    [[MHTipsView shareInstance] showTips:@"设置中……" modal: YES];
    __weak typeof(self) weakself = self;
    [self.cameraDevice setCameraMode:mode success:^(MHDeviceCamera *deviceCamera, MHLumiDeviceCameraMode mode) {
        if (success) {
            success();
        }
        [weakself settingDatasource];
        [[MHTipsView shareInstance] showFinishTips:@"设置成功" duration:0.5 modal:YES];
    } failure:^(NSError *error) {
        [[MHTipsView shareInstance] showFailedTips:@"设置失败，请重试" duration:1 modal:YES];
        if (failure) {
            failure(error);
        }
    }];
}
@end
