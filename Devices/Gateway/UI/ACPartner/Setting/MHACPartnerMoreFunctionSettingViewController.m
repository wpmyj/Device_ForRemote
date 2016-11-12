//
//  MHACPartnerMoreFunctionSettingViewController.m
//  MiHome
//
//  Created by ayanami on 16/5/21.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerMoreFunctionSettingViewController.h"
#import "MHLumiAccessSettingCell.h"
#import "MHACPartnerTimerNewSettingViewController.h"
#import "MHACPartnerChooseIrViewController.h"
#import "MHACPartnerAddTipsViewController.h"
#import "MHACPartnerCountdownViewController.h"

@interface MHACPartnerMoreFunctionSettingViewController ()<ACPartnerCountdownDelegate>

@property (nonatomic, strong) MHDeviceAcpartner *acpartner;

@end

@implementation MHACPartnerMoreFunctionSettingViewController
- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner
{
    self = [super init];
    if (self) {
        self.isTabBarHidden = YES;
        self.acpartner = acpartner;
        [self dataConstruct];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedStringFromTable(@"mydevice.actionsheet.more",@"plugin_gateway","更多");
}

-(void)dataConstruct{
    //    [_gateway getTimerListWithSuccess:nil failure:nil];
    XM_WS(weakself);
    //    NSString* strIfttt = NSLocalizedStringFromTable(@"profile.entry.triggerAction",@"plugin_gateway","自动化");
    //    NSString* strInstallation = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.installationtutorial",@"plugin_gateway","安装教程");
    //    NSString* strDirection = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.directionchoice",@"plugin_gateway","方向选择");
    //    NSString *strForward = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.directionchoice.forward",@"plugin_gateway","正向");
    //    NSString *strReverse = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.directionchoice.reverse",@"plugin_gateway","反向");
    //
    //    NSString* strClear = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.clearitinerary",@"plugin_gateway","清楚行程(慎点)");
    //    NSString* strManual = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.manualcontrol",@"plugin_gateway","手动开/关窗帘");
    //
    //    NSString* strChangeTitle = [NSString stringWithFormat:@"%@", NSLocalizedStringFromTable(@"mydevice.actionsheet.changename",@"plugin_gateway","修改设备名称")];
    //    NSString* strShowMode = _deviceCurtain.showMode ? NSLocalizedStringFromTable(@"mydevice.gateway.delsub.rmvlist",@"plugin_gateway","撤销显示") : NSLocalizedStringFromTable(@"mydevice.gateway.delsub.addlist",@"plugin_gateway","添加显示");
    //    NSString *strFAQ = NSLocalizedStringFromTable(@"mydevice.gateway.about.freFAQ",@"plugin_gateway","常见问题");
    //    NSString* strFeedback = NSLocalizedStringFromTable(@"mydevice.actionsheet.feedback",@"plugin_gateway","反馈");

    
    MHLuDeviceSettingGroup* group1 = [[MHLuDeviceSettingGroup alloc] init];
    group1.title = nil;
    NSMutableArray *acSettings = [NSMutableArray new];
    
    //换码库
    MHLumiSettingCellItem *itemTimer = [[MHLumiSettingCellItem alloc] init];
    itemTimer.identifier = @"mydevice.gateway.sensor.curtain.timer";
    itemTimer.lumiType = MHLumiSettingItemTypeAccess;
    itemTimer.hasAcIndicator = YES;
    itemTimer.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.timer.title",@"plugin_gateway","空调定时");
    itemTimer.customUI = YES;
    itemTimer.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
    itemTimer.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
            MHACPartnerTimerNewSettingViewController *tVC = [[MHACPartnerTimerNewSettingViewController alloc] initWithDevice:weakself.acpartner andIdentifier:kACPARTNERTIMERID];
            tVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.timer.title",@"plugin_gateway","空调定时");
            tVC.controllerIdentifier = kACPARTNERTIMERID;
            [weakself.navigationController pushViewController:tVC animated:YES];
            [weakself gw_clickMethodCountWithStatType:@"openACPartnerTimerSetting"];
    };
    [acSettings addObject:itemTimer];

    
    
    //换码库
    MHLumiSettingCellItem *itemCode = [[MHLumiSettingCellItem alloc] init];
    itemCode.identifier = @"mydevice.gateway.sensor.curtain.directionchoice";
    itemCode.lumiType = MHLumiSettingItemTypeAccess;
    itemCode.hasAcIndicator = YES;
    itemCode.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.more.newir",@"plugin_gateway","重新匹配空调");
    
    itemCode.customUI = YES;
    itemCode.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
    itemCode.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
        
        MHACPartnerAddTipsViewController *addTipsVC = [[MHACPartnerAddTipsViewController alloc] initWithAcpartner:weakself.acpartner];
        [weakself.navigationController pushViewController:addTipsVC animated:YES];

        [weakself gw_clickMethodCountWithStatType:@"openACPartnerAddTips"];
    };
    [acSettings addObject:itemCode];
    
//    MHLumiSettingCellItem *itemCutDown = [[MHLumiSettingCellItem alloc] init];
//    itemCutDown.identifier = @"mydevice.gateway.sensor.curtain.directionchoice";
//    itemCutDown.lumiType = MHLumiSettingItemTypeAccess;
//    itemCutDown.hasAcIndicator = YES;
//    itemCutDown.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.countdown",@"plugin_gateway","倒计时");
//    itemCutDown.customUI = YES;
//    itemCutDown.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
//    itemCutDown.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
//       
//        MHACPartnerCountdownViewController *countdownVC = [[MHACPartnerCountdownViewController alloc] init];
//        countdownVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.countdown",@"plugin_gateway","倒计时");
//        countdownVC.isOn = YES;
//        countdownVC.countdownTimer = weakself.acpartner.countDownTimer;
//        countdownVC.hour = weakself.acpartner.countDownTimer.isEnabled ? weakself.acpartner.pwHour : 0;
//        countdownVC.minute = weakself.acpartner.countDownTimer.isEnabled ? weakself.acpartner.pwMinute : 0;
//        countdownVC.delegate = weakself;
//        [weakself.navigationController pushViewController:countdownVC animated:YES];
//        [weakself gw_clickMethodCountWithStatType:@"openACPartnerCountDown"];
//    };
//    [acSettings addObject:itemCutDown];

//    
//    MHLumiSettingCellItem *itemSleep = [[MHLumiSettingCellItem alloc] init];
//    itemSleep.identifier = @"mydevice.gateway.sensor.curtain.directionchoice";
//    itemSleep.lumiType = MHLumiSettingItemTypeAccess;
//    itemSleep.hasAcIndicator = YES;
//    itemSleep.caption = @"睡眠模式";
//    itemSleep.customUI = YES;
//    itemSleep.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
//    itemSleep.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
//       
//        MHACPartnerAddTipsViewController *addTipsVC = [[MHACPartnerAddTipsViewController alloc] initWithAcpartner:weakself.acpartner];
//        [weakself.navigationController pushViewController:addTipsVC animated:YES];
//        
//        [weakself gw_clickMethodCountWithStatType:@"openACPartnerAddTips"];
//    };
//    [acSettings addObject:itemSleep];

    
//    MHDeviceSettingItem *itemFastCool = [[MHDeviceSettingItem alloc] init];
//    itemFastCool.identifier = @"mydevice.gateway.sensor.curtain.directionchoice";
//    itemFastCool.type = MHDeviceSettingItemTypeDefault;
//    itemFastCool.hasAcIndicator = NO;
//    itemFastCool.caption = @"速冷模式";
//    itemFastCool.customUI = YES;
//    itemFastCool.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
//    itemFastCool.callbackBlock = ^(MHDeviceSettingCell *cell) {
//        weakself.acpartner.modeState = 0;
//        weakself.acpartner.windPower = 3;
//        weakself.acpartner.windState = 0;
//        weakself.acpartner.temperature = 20;
//        if (weakself.acpartner.ACType == 2) {
//            [weakself.acpartner.kkAcManager changePowerStateWithPowerstate:AC_POWER_ON];
//            [weakself.acpartner.kkAcManager getPowerState];
//            [weakself.acpartner judgeModeCanControl:PROP_POWER];
//            [weakself.acpartner judgeWindsCanControl:PROP_POWER];
//            [weakself.acpartner judgeSwipCanControl:PROP_POWER];
//            [weakself.acpartner judgeTempratureCanControl:PROP_POWER];
//
//        }
//       NSString *strCmd = [weakself.acpartner getACCommand:POWER_ON_INDEX commandIndex:POWER_COMMAND isTimer:NO];
//        [weakself.acpartner sendCommand:strCmd success:^(id obj) {
//            [[MHTipsView shareInstance] showTipsInfo:@"速冷已开始" duration:1.5f modal:YES];
//        } failure:^(NSError *v) {
//            [[MHTipsView shareInstance] showTipsInfo:@"设置失败,请检查网络后重试" duration:1.5f modal:YES];
//        }];
//        
//        [weakself gw_clickMethodCountWithStatType:@"openACPartnerSpeedCool"];
//    };
//    [acSettings addObject:itemFastCool];

    
    
    
    group1.items = acSettings;
    self.settingGroups = [NSMutableArray arrayWithObjects:group1,nil];
}


#pragma mark - CountDownDelegate
- (void)countdownDidStart:(MHDataDeviceTimer*)countdownTimer {
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"setting",@"plugin_gateway","添加中，请稍候...") modal:YES];
    
    countdownTimer.identify = kACPARTNERCOUNTDOWNTIMERID;
    countdownTimer.onMethod = @"set_ac";
    countdownTimer.onParam = @[ @(285479426) ];
    countdownTimer.offMethod = @"set_off";
//    NSString *strOffCmd = [self.acpartner getACCommand:SCENE_OFF_INDEX commandIndex:TIMER_COMMAND isTimer:YES];
//    NSString *strOffHex = [strOffCmd substringWithRange:NSMakeRange(10, 8)];
//    uint32_t offValue = (uint32_t)strtoul([strOffHex UTF8String], 0, 16);
    countdownTimer.offParam = @[ @(268435202) ];
    countdownTimer.isEnabled = YES;
    
    XM_WS(weakself);
    [self.acpartner editTimer:countdownTimer success:^(id obj) {
        weakself.acpartner.countDownTimer = countdownTimer;
        [weakself.acpartner saveTimerList];
        [[MHTipsView shareInstance] showFinishTips:NSLocalizedStringFromTable(@"adding.successed",@"plugin_gateway", "添加成功") duration:1.0 modal:NO];
        
    } failure:^(NSError *v) {
        [[MHTipsView shareInstance]showFailedTips:NSLocalizedStringFromTable(@"adding.failed",@"plugin_gateway", "添加失败") duration:1.0 modal:NO];
    }];
}



- (void)modifyTimer:(MHDataDeviceTimer *)countdownTimer {
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"setting",@"plugin_gateway","设置中，请稍候...") modal:YES];
    
    countdownTimer.identify = kACPARTNERCOUNTDOWNTIMERID;
    countdownTimer.onMethod = @"set_ac";
    countdownTimer.onParam = @[ @(285479426) ];
    countdownTimer.offMethod = @"set_off";
    //    NSString *strOffCmd = [self.acpartner getACCommand:SCENE_OFF_INDEX commandIndex:TIMER_COMMAND isTimer:YES];
    //    NSString *strOffHex = [strOffCmd substringWithRange:NSMakeRange(10, 8)];
    //    uint32_t offValue = (uint32_t)strtoul([strOffHex UTF8String], 0, 16);
    countdownTimer.offParam = @[ @(268435202) ];
    
    XM_WS(weakself);
    [weakself.acpartner editTimer:countdownTimer success:^(id obj) {
        [weakself.acpartner saveTimerList];
        weakself.acpartner.countDownTimer = countdownTimer;
        [[MHTipsView shareInstance]showFinishTips:NSLocalizedStringFromTable(@"modify.successed", @"plugin_gateway","修改定时成功") duration:1.5f modal:NO];
        [weakself.acpartner saveACStatus];
    } failure:^(NSError *v) {
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"modify.failed", @"plugin_gateway","修改失败") duration:1.5f modal:NO];
    }];
}

- (void)countdownDidReStart:(MHDataDeviceTimer *)countdownTimer {
    [self modifyTimer:countdownTimer];
}

- (void)countdownDidStop:(MHDataDeviceTimer *)countdownTimer {
    [self modifyTimer:countdownTimer];
}

- (void)countdownDidDelete:(MHDataDeviceTimer *)countdownTimer {
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"setting",@"plugin_gateway","删除定时中，请稍候...") modal:YES];
    
    XM_WS(weakself);
    [self.acpartner deleteTimerId:countdownTimer.timerId success:^(id obj) {
        [[MHTipsView shareInstance] showFinishTips:NSLocalizedStringFromTable(@"delete.succeed", @"plugin_gateway","修改定时成功") duration:1.5f modal:NO];
        weakself.acpartner.countDownTimer = nil;
        [weakself.acpartner saveTimerList];
        [weakself.acpartner saveACStatus];
        
    } failure:^(NSError *v) {
        [[MHTipsView shareInstance]showFailedTips:NSLocalizedStringFromTable(@"delete.failed",@"plugin_gateway", "修改定时失败") duration:1.5f modal:NO];
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
