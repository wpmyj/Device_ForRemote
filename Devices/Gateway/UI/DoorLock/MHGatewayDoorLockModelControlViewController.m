//
//  MHGatewayDoorLockModelControlViewController.m
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/7.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayDoorLockModelControlViewController.h"
#import "MHGatewayDoorLockModelGuideViewController.h"

@interface MHGatewayDoorLockModelControlViewController()<MHGatewayDoorLockModelGuideViewControllerDelegate>
@property (nonatomic, strong)MHGatewayDoorLockModelGuideViewController *guideVC;
@property (nonatomic, assign) MHDeviceGatewaySensorDoorLockModel selectedModel;
@end

@implementation MHGatewayDoorLockModelControlViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    NSString *title = NSLocalizedStringFromTable(@"mydevice.actionsheet.more",@"plugin_gateway","更多");
    self.title = title;
    __weak typeof(self) weakself = self;
    [_sensorDoorLock fetchDoorLockModelwithSuccess:^(MHDeviceGatewaySensorDoorLock *sensor) {
        [weakself settingDatasource];
    } failure:^(NSError *error) {
        [[MHTipsView shareInstance] showFailedTips:@"网络出错，请退出重试" duration:1.5 modal:YES];
    }];
}

#pragma mark - MHGatewayDoorLockModelGuideViewControllerDelegate
- (void)doorLockModelGuideViewController:(MHGatewayDoorLockModelGuideViewController *)doorLockModelGuideViewController
                       handlerWithResult:(BOOL)result{
    [self.navigationController popViewControllerAnimated:YES];
    if ([self.delegate respondsToSelector:@selector(doorLockModelControlViewController:didSelectedModel:commitOrNor:)]){
        [self.delegate doorLockModelControlViewController:self didSelectedModel:self.selectedModel commitOrNor:result];
    }
}

- (void)buildSubviews {
    [super buildSubviews];
    [self settingDatasource];
}

- (void)settingDatasource{
    XM_WS(weakself);
    NSString* safeGuardStr = @"安防";//NSLocalizedStringFromTable(@"mydevice.actionsheet.changename",@"plugin_gateway","修改设备名称");
    NSString* concernStr = @"关怀";
    NSString* normalStr = @"控制";
    MHLuDeviceSettingGroup* group1 = [[MHLuDeviceSettingGroup alloc] init];
    NSMutableArray *curtainSettings = [NSMutableArray new];
    
    //安防
    MHDeviceSettingItem *itemSafeGuardModel = [[MHDeviceSettingItem alloc] init];
    itemSafeGuardModel.identifier = @"mydevice.actionsheet.changename";
    itemSafeGuardModel.type = MHDeviceSettingItemTypeCheckmark;
    itemSafeGuardModel.hasAcIndicator = self.sensorDoorLock.doorLockModel == MHDeviceGatewaySensorDoorLockModelSafeGuard;
    itemSafeGuardModel.caption = safeGuardStr;
    itemSafeGuardModel.comment = @"";
    itemSafeGuardModel.customUI = YES;
    itemSafeGuardModel.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
    itemSafeGuardModel.callbackBlock = ^(MHDeviceSettingCell *cell) {
        weakself.selectedModel = MHDeviceGatewaySensorDoorLockModelSafeGuard;
        [weakself setDoorLockMoModel:MHDeviceGatewaySensorDoorLockModelSafeGuard
                         withSuccess:^{
                             
                         }
                             failure:^(NSError *error){

                             }];
    };

    [curtainSettings addObject:itemSafeGuardModel];
    
    //控制
    MHDeviceSettingItem *itemNormalModel = [[MHDeviceSettingItem alloc] init];
    itemNormalModel.identifier = @"mydevice.actionsheet.changename";
    itemNormalModel.type = MHDeviceSettingItemTypeCheckmark;
    itemNormalModel.hasAcIndicator = self.sensorDoorLock.doorLockModel == MHDeviceGatewaySensorDoorLockModelNormal;
    itemNormalModel.caption = normalStr;
    itemNormalModel.comment = @"";
    itemNormalModel.customUI = YES;
    itemNormalModel.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
    itemNormalModel.callbackBlock = ^(MHDeviceSettingCell *cell) {
        weakself.selectedModel = MHDeviceGatewaySensorDoorLockModelNormal;
        [weakself setDoorLockMoModel:MHDeviceGatewaySensorDoorLockModelNormal
                         withSuccess:^{
                             
                         }
                             failure:^(NSError *error){

                             }];
    };
    
    [curtainSettings addObject:itemNormalModel];
    
    
    //关怀
    MHDeviceSettingItem *itemConcernModel = [[MHDeviceSettingItem alloc] init];
    itemConcernModel.identifier = @"mydevice.actionsheet.changename";
    itemConcernModel.type = MHDeviceSettingItemTypeCheckmark;
    itemConcernModel.hasAcIndicator = self.sensorDoorLock.doorLockModel == MHDeviceGatewaySensorDoorLockModelConcern;
    itemConcernModel.caption = concernStr;
    itemConcernModel.comment = @"";
    itemConcernModel.customUI = YES;
    itemConcernModel.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
    itemConcernModel.callbackBlock = ^(MHDeviceSettingCell *cell) {
        weakself.selectedModel = MHDeviceGatewaySensorDoorLockModelConcern;
        [weakself setDoorLockMoModel:MHDeviceGatewaySensorDoorLockModelConcern
                         withSuccess:^{
                             
                         }
                             failure:^(NSError *error){
                                 
                             }];
    };
    
    [curtainSettings addObject:itemConcernModel];
    

    
    group1.items = curtainSettings;
    self.settingGroups = [NSMutableArray arrayWithObjects:group1,nil];
    [self.settingTableView reloadData];
}

- (void)setDoorLockMoModel:(MHDeviceGatewaySensorDoorLockModel)model
               withSuccess:(void (^)())success
                   failure:(void (^)(NSError *))failure{
    [[MHTipsView shareInstance] showTips:@"" modal:YES];
    __weak typeof(self) weakself = self;
    [self.sensorDoorLock setDoorLockModel:model
                              withSuccess:^{
                                  [[MHTipsView shareInstance] hide];
                                  [weakself settingDatasource];
                                  if (success) {
                                      success();
                                  }
                                  [weakself.navigationController pushViewController:weakself.guideVC animated:YES];
                              }
                                  failure:^(NSError *error){
                                      [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"setting.failed", @"plugin_gateway","") duration:1.f modal:YES];
                                      [weakself settingDatasource];
                                      if (failure) {
                                          failure(error);
                                      }
                                  }];
}

- (MHGatewayDoorLockModelGuideViewController *)guideVC{
    if (!_guideVC) {
        _guideVC = [[MHGatewayDoorLockModelGuideViewController alloc] init];
        _guideVC.delegate = self;
    }
    return _guideVC;
}

@end
