//
//  MHGatewayDoorLockViewController.m
//  MiHome
//
//  Created by LM21Mac002 on 16/10/15.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayDoorLockViewController.h"
#import "MHGatewayDoorLockSettingViewController.h"
#import "MHLumiLocalCacheManager.h"
#import "MHGatewayDoorLockModelGuideViewController.h"
#import "MHGatewayDoorLockModelControlViewController.h"

@interface MHGatewayDoorLockViewController()<MHGatewayDoorLockSettingViewControllerDelegate>
@property (nonatomic, strong) MHLumiLocalCacheManager *cacheManager;
@property (nonatomic, assign) BOOL firstLaunchFlag;
@property (nonatomic, copy) NSString *kFirstLaunchKey;
@property (nonatomic, strong)MHGatewayDoorLockModelGuideViewController *guideVC;
@end

@implementation MHGatewayDoorLockViewController
static NSString *kDoorLockCacheManagerKey = @"cacheManagerKey_MHGatewayDoorLockViewController";
- (id)initWithDevice:(MHDevice *)device{
    self = [super initWithDevice:device];
    if (self){
        _sensorDoorLock = (MHDeviceGatewaySensorDoorLock *)device;
        self.kFirstLaunchKey = [NSString stringWithFormat:@"%@_firstLaunchFlag",_sensorDoorLock.did];
//        NSNumber *flagNum = (NSNumber *)[self.cacheManager objectForKey:_kFirstLaunchKey];
//        if (flagNum){
//            self.firstLaunchFlag = flagNum.boolValue;
//        }else{
//            self.firstLaunchFlag = YES;
//        }
        self.firstLaunchFlag = YES;

    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.firstLaunchFlag){
//        self.firstLaunchFlag = NO;
//        [self.cacheManager setObject:[NSNumber numberWithBool:NO] forKey:_kFirstLaunchKey];
//        MHGatewayDoorLockModelControlViewController *vc = [[MHGatewayDoorLockModelControlViewController alloc] init];
//        vc.sensorDoorLock = self.sensorDoorLock;
//        vc.title = @"请选择模式";
//        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)onMore:(id)sender{
    MHGatewayDoorLockSettingViewController *vc = [[MHGatewayDoorLockSettingViewController alloc] init];
    vc.sensorDoorLock = self.sensorDoorLock;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)changeDeviceName:(MHGatewayDoorLockSettingViewController *)doorLockSettingViewController{
    [self deviceChangeName];
    [self gw_clickMethodCountWithStatType:@"actionSheetChangeName"];
    
}

- (void)FAQ:(MHGatewayDoorLockSettingViewController *)doorLockSettingViewController{
    [self openFAQ:[[self.sensorDoorLock class] getFAQUrl]];
    [self gw_clickMethodCountWithStatType:@"actionSheetFAQ"];
}

- (void)feedback:(MHGatewayDoorLockSettingViewController *)doorLockSettingViewController{
    [self onFeedback];
    [self gw_clickMethodCountWithStatType:@"actionSheetFeedback"];
}

- (MHLumiLocalCacheManager *)cacheManager{
    if (!_cacheManager) {
        MHLumiLocalCacheManager *manager = [[MHLumiLocalCacheManager alloc] initWithType:MHLumiLocalCacheManagerCommon andIdentifier:kDoorLockCacheManagerKey];
        _cacheManager = manager;
    }
    return _cacheManager;
}

- (MHGatewayDoorLockModelGuideViewController *)guideVC{
    if (!_guideVC) {
        _guideVC = [[MHGatewayDoorLockModelGuideViewController alloc] init];
    }
    return _guideVC;
}

@end
