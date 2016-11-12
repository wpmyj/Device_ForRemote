//
//  MHACPartnerTimerNewSettingViewController.m
//  MiHome
//
//  Created by ayanami on 16/5/20.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerTimerNewSettingViewController.h"
#import "MHACPartnerTimerDetailViewController.h"
#import "MHACPartnerTimerView.h"
#import <MiHomeKit/MHEditDeviceSceneNewResponse.h>

@interface MHACPartnerTimerNewSettingViewController ()
@property (nonatomic,strong) MHDeviceAcpartner *acpartner;
@property (nonatomic, strong) MHACPartnerTimerView *timerListView;

@end

@implementation MHACPartnerTimerNewSettingViewController

{
    NSString*           _identifier;
    NSMutableArray*     _powerTimerListCopy;
}

- (id)initWithDevice:(MHDeviceAcpartner *)acpartner andIdentifier:(NSString *)identifier{
    if (self = [super init]) {
        self.acpartner = acpartner;
        _identifier = identifier;
        [self resetTimerList];
    }
    return self;
}

- (void)resetTimerList {
    _powerTimerListCopy = [[NSMutableArray alloc] init];
    for (MHDataDeviceTimer *timer in _acpartner.powerTimerList) {
        if ([timer.identify isEqualToString:_identifier])
            [_powerTimerListCopy addObject:[timer copy]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isTabBarHidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [_acpartner getTimerListWithSuccess:nil failure:nil];
    
    //先读取定时的缓存
    [_acpartner restoreTimerListWithFinish:^(id obj) {
//        NSLog(@"%@", obj);
//        NSArray *userTimer = obj;
//        [userTimer enumerateObjectsUsingBlock:^(MHDataDeviceTimer* timer, NSUInteger idx, BOOL * _Nonnull stop) {
//            NSLog(@"缓存的%ld, %@", timer.timerId, timer.onParam);
//        }];
        [self resetTimerList];
        [self updatePowerTimerView:YES];
        
        //然后从云端拉取
        [self getDeviceTimers];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_acpartner saveTimerList];
}

- (void)buildSubviews {
    
    [super buildSubviews];
    
    XM_WS(weakself);
    _timerListView = [[MHACPartnerTimerView alloc] initWithDevice:self.acpartner timerList:_powerTimerListCopy];
    _timerListView.needBlankCup = YES;
    _timerListView.timerIdentify = _acpartner.did;
    _timerListView.frame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64) ;
    
    //点击事件的回调
    _timerListView.onAddTimer = ^{
        [weakself onAddTimer];
    };
    _timerListView.onModifyTimer = ^(MHDataDeviceTimer* timer, BOOL isNeedOpenEditPage) {
//        NSLog(@"编辑回调前%ld, %@", timer.timerId, timer.onParam);
        [weakself onModifyTimer:timer isNeedOpenEditPage:isNeedOpenEditPage];
    };
    _timerListView.onDelTimer = ^(MHDataDeviceTimer* timer) {
        [weakself onDeleteTimer:timer];
    };
    _timerListView.onNewDelTimer = ^(NSInteger index){
        [weakself onNewDeleteTimer:index];
    };
    _timerListView.refreshTimerList = ^{
        [weakself getDeviceTimers];
    };
    [self.view addSubview:_timerListView];
}

- (void)updatePowerTimerView:(BOOL)succeed {
    if (succeed) {
        [_timerListView onRefreshTimerListDone:YES timerList:_powerTimerListCopy];
    } else {
        [_timerListView onRefreshTimerListDone:NO timerList:nil];
    }
}


#pragma mark - 定时控制
//UI 部分
- (void)onAddTimer {
    XM_WS(weakself);
    MHACPartnerTimerDetailViewController *timerVC = [[MHACPartnerTimerDetailViewController alloc] initWithTimer:nil andAcpartner:self.acpartner];
    timerVC.onDone = ^(MHDataDeviceTimer* newTimer) {
        
//        NSLog(@"%@", weakself.acpartner.kkAcManager);
//        NSLog(@"%@", weakself.acpartner.kkAcManager.airDataDict);
//        NSLog(@"%@", weakself.acpartner.kkAcManager.AC_RemoteId);
//        NSLog(@"%@", weakself.acpartner.kkAcManager);

        
        newTimer.identify = kACPARTNERTIMERID;
        newTimer.isEnabled = YES;
        NSString *strCommand = [weakself editTimer:newTimer];
        if (strCommand) {
            [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.timersetting.adding",@"plugin_gateway","添加定时中，请稍候...") modal:YES];
            NSLog(@"保存的定时命令%@", strCommand);
            [weakself.acpartner saveCommandMap:strCommand success:^(id obj) {
                [weakself addTimer:newTimer];
            } failure:^(NSError *v) {
                [[MHTipsView shareInstance]showFailedTips:NSLocalizedStringFromTable(@"mydevice.timersetting.add.failed",@"plugin_gateway", "添加定时失败") duration:1.0 modal:NO];
            }];
        }
        else {
            [self addTimer:newTimer];
        }

      
        
    };
    [self.navigationController pushViewController:timerVC animated:YES];
    
    [self gw_clickMethodCountWithStatType:@"openAddAcpartnerTimerPage:"];

}


- (void)onModifyTimer:(MHDataDeviceTimer*)timer isNeedOpenEditPage:(BOOL)isNeedOpenEditPage{
    if (isNeedOpenEditPage) {
        XM_WS(weakself);
        MHACPartnerTimerDetailViewController *timerVC = [[MHACPartnerTimerDetailViewController alloc] initWithTimer:timer andAcpartner:self.acpartner];

        timerVC.onDone = ^(MHDataDeviceTimer* timer) {
            if (!timer.isOnOpen && !timer.isOffOpen) {
                [weakself deleteTimer:timer];
            } else {
                //空调参数改变可能需要重新保存明密文
                NSString *strCommand = [weakself editTimer:timer];
                if (strCommand) {
                    [self.acpartner saveCommandMap:strCommand success:^(id obj) {
                        [weakself modifyTimer:timer];
                    } failure:^(NSError *error) {
                        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.timersetting.modify.failed", @"plugin_gateway","修改定时失败") duration:1.0 modal:NO];
                        
                    }];
                }
                else {
                    [weakself modifyTimer:timer];
                }
                
            }
        };
        [self.navigationController pushViewController:timerVC animated:YES];
    }
    else{
        if (!timer.isOnOpen && !timer.isOffOpen) {
            [self deleteTimer:timer];
        } else {
            [self modifyTimer:timer];
        }
    }
}

- (void)onDeleteTimer:(MHDataDeviceTimer*) timer {
    [self deleteTimer:timer];
}

-(void)onNewDeleteTimer:(NSInteger )index{
    MHDataDeviceTimer * timer = _powerTimerListCopy[index];
    [self deleteTimer:timer];
}

- (void)getDeviceTimers {
    XM_WS(weakself);
    [self.acpartner getTimerListWithIdentify:_identifier success:^(id obj){
        weakself.acpartner.powerTimerList = [NSMutableArray arrayWithArray:obj];
        [weakself.acpartner saveTimerList];
        
        [self resetTimerList];
        [self updatePowerTimerView:YES];
        
    }failure:^(NSError *error){
        [self updatePowerTimerView:NO];
    }];
    
   
}

- (void)addTimer:(MHDataDeviceTimer*)newTimer{
    
    
    [_powerTimerListCopy addObject:newTimer];
    newTimer.identify = _identifier;
    
    NSLog(@"%ld, %ld, %@, %@, %@, %@", newTimer.onHour, newTimer.offHour, newTimer.identify, newTimer.onParam, newTimer.offParam, newTimer.onMethod);
    
    XM_WS(weakself);
    [_acpartner editTimer:newTimer success:^(id obj) {
        NSLog(@"%@", obj);
        MHEditDeviceSceneNewResponse *newRsp = obj;
        NSLog(@"%@", newRsp.message);
        NSLog(@"%@", newRsp.error);
        NSLog(@"%ld", newRsp.status);
        NSLog(@"%ld", newRsp.code);

        [weakself updatePowerTimerView:YES];
        if (weakself.acpartner.ACType == 2) {
            [weakself.acpartner resetAcStatus];
        }
        [[MHTipsView shareInstance]showFinishTips:NSLocalizedStringFromTable(@"mydevice.timersetting.add.succeed",@"plugin_gateway", "添加定时成功") duration:1.0 modal:NO];
        
    } failure:^(NSError *error) {
        [weakself resetTimerList];
        if (weakself.acpartner.ACType == 2) {
            [weakself.acpartner resetAcStatus];
        }
        NSLog(@"%@", error);
        [[MHTipsView shareInstance]showFailedTips:NSLocalizedStringFromTable(@"mydevice.timersetting.add.failed",@"plugin_gateway", "添加定时失败") duration:1.0 modal:NO];
    }];
}

- (void)modifyTimer:(MHDataDeviceTimer*)timer {
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.timersetting.modifying",@"plugin_gateway","修改定时中，请稍候...") modal:YES];
    XM_WS(weakself);
    [_acpartner editTimer:timer success:^(id obj) {
        [weakself updatePowerTimerView:YES];
        [[MHTipsView shareInstance]showFinishTips:NSLocalizedStringFromTable(@"mydevice.timersetting.modify.succeed", @"plugin_gateway","修改定时成功") duration:1.0 modal:NO];
        if (weakself.acpartner.ACType == 2) {
            [weakself.acpartner resetAcStatus];
        }
    } failure:^(NSError *v) {
        [weakself resetTimerList];
        if (weakself.acpartner.ACType == 2) {
            [weakself.acpartner resetAcStatus];
        }
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.timersetting.modify.failed", @"plugin_gateway","修改定时失败") duration:1.0 modal:NO];
    }];
//    NSLog(@"定时编号%ld 定时开启参数%@", timer.timerId, timer.onParam);
//    NSLog(@"%@", timer.offParam);

    
    [self gw_clickMethodCountWithStatType:@"openEditAcpartnerTimerPage:"];
    
}



- (NSString *)editTimer:(MHDataDeviceTimer*)timer {
     [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.timersetting.modifying",@"plugin_gateway","修改定时中，请稍候...") modal:YES];
    NSString *strCommand = nil;
        if (timer.isOnOpen) {
            timer.onMethod = @"set_ac";
            if (self.acpartner.ACType == 2) {
                self.acpartner.timerPowerState = 1;
                [self.acpartner.kkAcManager changePowerStateWithPowerstate:AC_POWER_ON];
                [self.acpartner.kkAcManager getPowerState];
                [self.acpartner.kkAcManager getAirConditionInfrared];
                [self.acpartner judgeModeCanControl:PROP_TIMER];
                [self.acpartner judgeWindsCanControl:PROP_TIMER];
                [self.acpartner judgeSwipCanControl:PROP_TIMER];
                [self.acpartner judgeTempratureCanControl:PROP_TIMER];
            }
            strCommand = [self.acpartner getACCommand:SCENE_AC_INDEX commandIndex:TIMER_COMMAND isTimer:YES];
            NSString *strHex = [strCommand substringWithRange:NSMakeRange(10, 8)];
            uint32_t value = (uint32_t)strtoul([strHex UTF8String], 0, 16);
            timer.onParam = @[ @(value) ];
    
        }
        if (timer.isOffOpen) {
            timer.offMethod = @"set_off";
            NSString *strOffCmd = [self.acpartner getACCommand:SCENE_OFF_INDEX commandIndex:TIMER_COMMAND isTimer:YES];
            //        [self.acpartner saveCommandMap:strOffCmd success:nil failure:nil];
            NSString *strOffHex = [strOffCmd substringWithRange:NSMakeRange(10, 8)];
            uint32_t offValue = (uint32_t)strtoul([strOffHex UTF8String], 0, 16);
            timer.offParam = @[ @(offValue) ];
        }
    return strCommand;
}

- (void)deleteTimer:(MHDataDeviceTimer*) timer {
    
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.timersetting.deling",@"plugin_gateway","删除定时中，请稍候...") modal:YES];
    [_powerTimerListCopy removeObject:timer];
    
    XM_WS(weakself);
    [_acpartner deleteTimerId:timer.timerId success:^(id obj) {
        
        [weakself updatePowerTimerView:YES];
        
        [[MHTipsView shareInstance]showFinishTips:NSLocalizedStringFromTable(@"mydevice.timersetting.del.succeed", @"plugin_gateway","修改定时成功") duration:1.0 modal:NO];
    } failure:^(NSError *v) {
        
        [weakself resetTimerList];
        
        [[MHTipsView shareInstance]showFailedTips:NSLocalizedStringFromTable(@"mydevice.timersetting.del.failed",@"plugin_gateway", "修改定时失败") duration:1.0 modal:NO];
    }];
    [self gw_clickMethodCountWithStatType:@"deleteAcpartnerTimer:"];

}


@end
