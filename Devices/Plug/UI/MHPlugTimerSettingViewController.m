//
//  MHPlugTimerSettingViewController.m
//  MiHome
//
//  Created by hanyunhui on 15/9/24.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//

#import "MHPlugTimerSettingViewController.h"
#import "MHDevicePlug.h"
#import "MHDeviceTimerView.h"
#import "MHTimerDetailViewController.h"
#import "MHPlugView.h"

@interface MHPlugTimerSettingViewController ()

@end

@implementation MHPlugTimerSettingViewController {
    MHDevicePlug*           _device;
    
    MHDeviceTimerView*  _deviceTimerView;
    NSMutableArray*     _powerTimerListCopy;
    
    MHDeviceTimerView*  _usbTimerView;
    NSMutableArray*     _usbPowerTimerListCopy;
    int                 _plugItem;
}

- (id)initWithDevice:(MHDevice*)device plugItem:(int)plugItem{
    if (self = [super init]) {
        _device = device;
        [self resetTimerList];
        [self resetUsbTimerList];
        _plugItem = plugItem;
        
    }
    return self;
}

- (void)resetTimerList {
    _powerTimerListCopy = [[NSMutableArray alloc] init];
    for (id timer in _device.powerTimerList) {
        [_powerTimerListCopy addObject:[timer copy]];
    }
}

- (void)resetUsbTimerList {
    _usbPowerTimerListCopy = [[NSMutableArray alloc] init];
    for (id timer in _device.usbPowerTimerList) {
        [_usbPowerTimerListCopy addObject:[timer copy]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isTabBarHidden = YES;
//    self.title = NSLocalizedString(@"mydevice.airpurifier.setting.timer", @"定时开关机");
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    //先读取定时的缓存
    [_device restoreTimerListWithFinish:^(id v) {
        [self resetTimerList];
        [self resetUsbTimerList];
        [self updatePowerTimerView:YES];
        [self updateUsbPowerTimerView:YES];
        
        //然后从云端拉取
        [self getDeviceTimers];
    }];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_device saveTimerList];
}

- (void)buildSubviews {
    
    [super buildSubviews];
    
    __weak __typeof(self) weakSelf = self;
    
    //开关定时
    if (_plugItem == MHPlugItemPlug) {
        _deviceTimerView = [[MHDeviceTimerView alloc] initWithDevice:_device timerList:_powerTimerListCopy parentVC:self];
        _deviceTimerView.needBlankCup = YES;
        _deviceTimerView.frame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64) ;
        _deviceTimerView.refreshTimerList = ^{
            [weakSelf getDeviceTimers];
        };
        //点击事件的回调
        _deviceTimerView.onAddTimer = ^{
            [weakSelf onAddTimer:NO];
        };
        _deviceTimerView.onModifyTimer = ^(MHDataDeviceTimer* timer, BOOL isNeedOpenEditPage) {
            [weakSelf onModifyTimer:timer isUsb:NO isNeedOpenEditPage:isNeedOpenEditPage];
        };
        _deviceTimerView.onDelTimer = ^(MHDataDeviceTimer* timer) {
            [weakSelf onDeleteTimer:timer isUsb:NO];
        };
        
        [self.view addSubview:_deviceTimerView];
    } else {
        //USB定时
        _usbTimerView = [[MHDeviceTimerView alloc] initWithDevice:_device timerList:_usbPowerTimerListCopy parentVC:self];
        _usbTimerView.needBlankCup = YES;
        _usbTimerView.frame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64) ;
        _usbTimerView.refreshTimerList = ^{
            [weakSelf getDeviceTimers];
        };
        
        //点击事件的回调
        _usbTimerView.onAddTimer = ^{
            [weakSelf onAddTimer:YES];
        };
        _usbTimerView.onModifyTimer = ^(MHDataDeviceTimer* timer, BOOL isNeedOpenEditPage) {
            [weakSelf onModifyTimer:timer isUsb:YES isNeedOpenEditPage:isNeedOpenEditPage];
        };
        _usbTimerView.onDelTimer = ^(MHDataDeviceTimer* timer) {
            [weakSelf onDeleteTimer:timer isUsb:YES];
        };
        
        [self.view addSubview:_usbTimerView];
    }
    
}

- (void)updatePowerTimerView:(BOOL)succeed {
    if (succeed) {
        [_deviceTimerView onRefreshTimerListDone:YES timerList:_powerTimerListCopy];
    } else {
        [_deviceTimerView onRefreshTimerListDone:NO timerList:nil];
    }
}

- (void)updateUsbPowerTimerView:(BOOL)succeed {
    if (succeed) {
        [_usbTimerView onRefreshTimerListDone:YES timerList:_usbPowerTimerListCopy];
    } else {
        [_usbTimerView onRefreshTimerListDone:NO timerList:nil];
    }
}

#pragma mark - 定时控制

//Logic 部分
- (void)getDeviceTimers {
    [_device getTimerListWithSuccess:^(id obj) {
        [self resetTimerList];
        [self updatePowerTimerView:YES];
        [self resetUsbTimerList];
        [self updateUsbPowerTimerView:YES];
    } failure:^(NSError *v) {
        [self updatePowerTimerView:NO];
        [self updateUsbPowerTimerView:NO];
    }];
}

- (void)addTimer:(MHDataDeviceTimer*) newTimer isUsb:(BOOL)isUsb{
    
    [[MHTipsView shareInstance] showTips:NSLocalizedString(@"mydevice.timersetting.adding","添加定时中，请稍候...") modal:YES];
    
    if (isUsb) {
        [_usbPowerTimerListCopy addObject:newTimer];
    } else {
        [_powerTimerListCopy addObject:newTimer];
    }
    
    __weak __typeof(self) weakSelf = self;
    
    [_device setTimerList:[NSDictionary dictionaryWithObjectsAndKeys:_powerTimerListCopy, @"Power", _usbPowerTimerListCopy, @"Usb", nil] success:^(id obj) {

        if (isUsb) {
            [weakSelf updateUsbPowerTimerView:YES];
        } else {
            [weakSelf updatePowerTimerView:YES];
        }
        [[MHTipsView shareInstance]showFinishTips:NSLocalizedString(@"mydevice.timersetting.add.succeed", "添加定时成功") duration:1.0 modal:NO];
    } failure:^(NSError *v) {
        
        if (isUsb) {
            [weakSelf resetUsbTimerList];
        } else {
            [weakSelf resetTimerList];
        }
        [[MHTipsView shareInstance]showFailedTips:NSLocalizedString(@"mydevice.timersetting.add.failed", "添加定时失败") duration:1.0 modal:NO];
    }];
}

- (void)modifyTimer:(MHDataDeviceTimer*) timer isUsb:(BOOL)isUsb{
    [[MHTipsView shareInstance] showTips:NSLocalizedString(@"mydevice.timersetting.modifying","修改定时中，请稍候...") modal:YES];
    
    __weak __typeof(self) weakSelf = self;
    
    [_device setTimerList:[NSDictionary dictionaryWithObjectsAndKeys:_powerTimerListCopy, @"Power", _usbPowerTimerListCopy, @"Usb", nil] success:^(id obj) {
    
        if (isUsb) {
            [weakSelf updateUsbPowerTimerView:YES];
        } else {
            [weakSelf updatePowerTimerView:YES];
        }
        [[MHTipsView shareInstance]showFinishTips:NSLocalizedString(@"mydevice.timersetting.modify.succeed", "修改定时成功") duration:1.0 modal:NO];
    } failure:^(NSError *v) {
        
        if (isUsb) {
            [weakSelf resetUsbTimerList];
        } else {
            [weakSelf resetTimerList];
        }
        [[MHTipsView shareInstance]showFailedTips:NSLocalizedString(@"mydevice.timersetting.modify.failed", "修改定时失败") duration:1.0 modal:NO];
    }];
    
}

- (void)deleteTimer:(MHDataDeviceTimer*) timer isUsb:(BOOL)isUsb{
    
    [[MHTipsView shareInstance] showTips:NSLocalizedString(@"mydevice.timersetting.deling","删除定时中，请稍候...") modal:YES];
    
    if (isUsb) {
        [_usbPowerTimerListCopy removeObject:timer];
        
    } else {
        [_powerTimerListCopy removeObject:timer];
    }
    
    __weak __typeof(self) weakSelf = self;
    [_device setTimerList:[NSDictionary dictionaryWithObjectsAndKeys:_powerTimerListCopy, @"Power", _usbPowerTimerListCopy, @"Usb", nil] success:^(id obj) {
        
        if (isUsb) {
            [weakSelf updateUsbPowerTimerView:YES];
        } else {
            [weakSelf updatePowerTimerView:YES];
        }
        [[MHTipsView shareInstance]showFinishTips:NSLocalizedString(@"mydevice.timersetting.del.succeed", "修改定时成功") duration:1.0 modal:NO];
    } failure:^(NSError *v) {
        if (isUsb) {
            [weakSelf resetUsbTimerList];
        } else {
            [weakSelf resetTimerList];
        }
        [[MHTipsView shareInstance]showFailedTips:NSLocalizedString(@"mydevice.timersetting.del.failed", "修改定时失败") duration:1.0 modal:NO];
    }];
}

//UI 部分
- (void)onAddTimer:(BOOL)isUsb {
    __weak __typeof(self) weakSelf = self;
    MHTimerDetailViewController* timerVC = [[MHTimerDetailViewController alloc] initWithTimer:nil];
    timerVC.onDone = ^(MHDataDeviceTimer* newTimer) {
        [weakSelf addTimer:newTimer isUsb:isUsb];
    };
    [self.navigationController pushViewController:timerVC animated:YES];
}

- (void)onModifyTimer:(MHDataDeviceTimer*) timer isUsb:(BOOL)isUsb isNeedOpenEditPage:(BOOL)isNeedOpenEditPage{
    if (isNeedOpenEditPage) {
        __weak __typeof(self) weakSelf = self;
        MHTimerDetailViewController* timerVC = [[MHTimerDetailViewController alloc] initWithTimer:timer];
        timerVC.onDone = ^(MHDataDeviceTimer* timer) {
            if (!timer.isOnOpen && !timer.isOffOpen) {
                [weakSelf deleteTimer:timer isUsb:isUsb];
            } else {
                [weakSelf modifyTimer:timer isUsb:isUsb];
            }
        };
        [self.navigationController pushViewController:timerVC animated:YES];
    } else {
        if (!timer.isOnOpen && !timer.isOffOpen) {
            [self deleteTimer:timer isUsb:isUsb];
        } else {
            [self modifyTimer:timer isUsb:isUsb];
        }
    }
}

- (void)onDeleteTimer:(MHDataDeviceTimer*) timer isUsb:(BOOL)isUsb{
    [self deleteTimer:timer isUsb:isUsb];
}

@end