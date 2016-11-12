//
//  MHACSleepSettingViewController.m
//  MiHome
//
//  Created by ayanami on 8/30/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHACSleepSettingViewController.h"
#import "MHACSleepTemperatureView.h"
#import "MHLumiAccessSettingCell.h"
#import "MHACSleepTimeSettingViewController.h"
#import "MHLMCrontabTime.h"
#import <MiHomeKit/MHTimeUtils.h>
#import "MHACSleepEndSettingViewController.h"
#import "MHACPartnerModeSettingViewController.h"
#import "MHLMDecimalBinaryTools.h"

#define kDefaultCrontab @"* * * * *"
#define kDefaultCode    @"00000000"

@interface MHACSleepSettingViewController ()

@property (nonatomic, strong) MHDeviceAcpartner *acpartner;
@property (nonatomic, strong) MHACSleepTemperatureView *tempView;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, copy) NSString *timeSpan;
@property (nonatomic, copy) NSString *endComment;
@property (nonatomic, assign) NSUInteger endoffTime;//睡眠结束后关机时间
@property (nonatomic, assign) NSUInteger endType;
@property (nonatomic, assign) int sleepACMode;//睡眠的空调模式


@property (nonatomic, copy) MHDataDeviceTimer *timer;
@property (nonatomic, copy) MHDataDeviceTimer *oldTimer;

//目前timer的数据 和 crontab不通用, 先相互转换着用
@property (nonatomic, assign) BOOL isSleepOn;
@property (nonatomic, assign) NSUInteger onHour;
@property (nonatomic, assign) NSUInteger offHour;
@property (nonatomic, assign) NSUInteger onMinute;
@property (nonatomic, assign) NSUInteger offMinute;
@property (nonatomic, assign) NSUInteger onDay;
@property (nonatomic, assign) NSUInteger onMonth;
@property (nonatomic, assign) NSUInteger offDay;
@property (nonatomic, assign) NSUInteger offMonth;
@property (nonatomic, assign) NSUInteger repeatType;

@property (nonatomic, assign) NSUInteger beginTemp;
@property (nonatomic, assign) NSUInteger afterTemp;
@property (nonatomic, assign) NSUInteger endBeforeTemp;
@property (nonatomic, assign) NSUInteger endTemp;

@property (nonatomic, assign) NSUInteger beginHour;
@property (nonatomic, assign) NSUInteger afterHour;
@property (nonatomic, assign) NSUInteger endBeforeHour;
@property (nonatomic, assign) NSUInteger endHour;

//结束后关闭的时分
@property (nonatomic, assign) NSUInteger endOffHour;
@property (nonatomic, assign) NSUInteger endOffMinute;
@property (nonatomic, copy) NSString *endOffCrontab;



@property (nonatomic, copy) NSString *beginCrontab;
@property (nonatomic, copy) NSString *afterCrontab;
@property (nonatomic, copy) NSString *endBeforeCrontab;
@property (nonatomic, copy) NSString *endCrontab;

//重复次数为一次时
@property (nonatomic, strong) NSNumber *beginTimeInterval;
@property (nonatomic, strong) NSNumber *afterTimeInterval;
@property (nonatomic, strong) NSNumber *endBeforeTimeInterval;
@property (nonatomic, strong) NSNumber *endTimeInterval;

@property (nonatomic, copy) void(^saveCmdBlock)(NSInteger);
@property (nonatomic, strong) NSMutableArray *cmdArray;

@end

@implementation MHACSleepSettingViewController

- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner
{
    self = [super init];
    if (self) {
        self.isTabBarHidden = YES;
        _acpartner = acpartner;
        _sleepACMode = _acpartner.modeState;
        _endoffTime = 5;
        _endType = 0;
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.sleepmode.caption",@"plugin_gateway","睡眠模式");
    [self initTimerWithCurrentTime];
    self.oldTimer = [_timer copy];
    [self restoreCoolData];
    [self updateUI];
    [self getSleepModeData];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUI];
}

- (void)buildSubviews {
    [super buildSubviews];
    
    [self buildTableView];
    XM_WS(weakself);
    self.tempView = [[MHACSleepTemperatureView alloc] initWithFrame:CGRectMake(0, 275 * ScaleHeight, WIN_WIDTH, WIN_HEIGHT - 275 * ScaleHeight) acpartner:self.acpartner];
    [self.view addSubview:self.tempView];
    
    [self.tempView setBeginTemp:^(int begin) {
        weakself.beginTemp = begin;
        [weakself gw_clickMethodCountWithStatType:[NSString stringWithFormat:@"setACPartnerSleepBeginTemp%d:", begin]];
    }];
    
    [self.tempView setAfterTemp:^(int after) {
        weakself.afterTemp = after;
        [weakself gw_clickMethodCountWithStatType:[NSString stringWithFormat:@"setACPartnerSleepAfterTemp%d:", after]];
    }];
    //    self.tempView.endBeforeTemp = ^(CGFloat endBefore) {
    //    };
    
    [self.tempView setEndBeforeTemp:^(int endBefore) {
        weakself.endBeforeTemp = endBefore;
        [weakself gw_clickMethodCountWithStatType:[NSString stringWithFormat:@"setACPartnerSleepEndBeforeTemp%d:", endBefore]];
        
    }];
    [self.tempView setEndTemp:^(int end) {
        weakself.endTemp = end;
        [weakself gw_clickMethodCountWithStatType:[NSString stringWithFormat:@"setACPartnerSleepEndTemp%d:", end]];
    }];
    
    
    self.tipsLabel = [[UILabel alloc] init];
    self.tipsLabel.textAlignment = NSTextAlignmentLeft;
    self.tipsLabel.textColor = [MHColorUtils colorWithRGB:0x888888];
    self.tipsLabel.font = [UIFont systemFontOfSize:14.0f];
    self.tipsLabel.numberOfLines = 0;
    self.tipsLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.sleepmode.tips",@"plugin_gateway","注: 只有空调打开时, 该功能才起作用");
    
    [self.view addSubview:self.tipsLabel];
    
    CGFloat leftSpacing = 15;
    CGFloat labelSpacing = 20;
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.view.mas_left).with.offset(leftSpacing);
        make.bottom.mas_equalTo(weakself.view.mas_bottom).with.offset(-labelSpacing);
    }];
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 44, 26);
    [btn setBackgroundColor:[MHColorUtils colorWithRGB:0x1dc58a]];
    [btn setTitle:NSLocalizedStringFromTable(@"Ok",@"plugin_gateway", "确定") forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13.f];
    btn.layer.cornerRadius = 3.0f;
    [btn addTarget:self action:@selector(onDone:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)buildTableView {
    XM_WS(weakself);
    
    MHLuDeviceSettingGroup* group1 = [[MHLuDeviceSettingGroup alloc] init];
    NSMutableArray *sleepSettings = [NSMutableArray new];
    
    MHDeviceSettingItem *volumSetting = [[MHDeviceSettingItem alloc] init];
    volumSetting.identifier = @"sleepSwitch";
    volumSetting.type = MHDeviceSettingItemTypeSwitch;
    volumSetting.hasAcIndicator = NO;
    volumSetting.isOn = self.isSleepOn;
    volumSetting.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.sleepmode.caption",@"plugin_gateway","睡眠模式");
    volumSetting.comment = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.sleepmode.comment",@"plugin_gateway","按照睡眠曲线, 以最低风速调整空调温度");
    volumSetting.customUI = YES;
    volumSetting.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(60), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    volumSetting.callbackBlock = ^(MHDeviceSettingCell *cell) {
        weakself.isSleepOn = !weakself.isSleepOn;
        cell.item.isOn  = weakself.isSleepOn;
        [cell fillWithItem:cell.item];
        [cell finish];
        [weakself updateUI];
        [weakself gw_clickMethodCountWithStatType:@"setACPartnerSleepSwitch:"];
    };
    [sleepSettings addObject:volumSetting];
    
    
    /**
     *  睡眠模式使能与否决定显示
     */
    if (self.isSleepOn) {
        MHLumiSettingCellItem *xmFM = [[MHLumiSettingCellItem alloc] init];
        xmFM.identifier = @"xmFM";
        xmFM.lumiType = MHLumiSettingItemTypeAccess;
        xmFM.hasAcIndicator = YES;
        xmFM.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.sleepmode.timespan",@"plugin_gateway","睡眠时段");
        xmFM.comment = self.timeSpan;
        xmFM.customUI = YES;
        xmFM.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(50), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
        xmFM.lumiCallbackBlock = ^(MHDeviceSettingCell *cell) {
            [weakself onTimespanSet];
        };
        [sleepSettings addObject:xmFM];
        
        MHLumiSettingCellItem *itemMode = [[MHLumiSettingCellItem alloc] init];
        itemMode.identifier = @"mydevice.gateway.sensor.curtain.directionchoice";
        itemMode.lumiType = MHLumiSettingItemTypeAccess;
        itemMode.hasAcIndicator = YES;
        //    itemSwept.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.addsubdeviceslist",@"plugin_gateway","子设备");
        itemMode.caption = @"空调模式";
        itemMode.comment = modeArray[_sleepACMode];
        itemMode.customUI = YES;
        itemMode.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(50), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
        itemMode.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
            [weakself onAcMode];
        };
        [sleepSettings addObject:itemMode];
        
        
        //添加子设备
        MHLumiSettingCellItem *itemSwept = [[MHLumiSettingCellItem alloc] init];
        itemSwept.identifier = @"mydevice.gateway.sensor.curtain.directionchoice";
        itemSwept.lumiType = MHLumiSettingItemTypeAccess;
        itemSwept.hasAcIndicator = YES;
        //    itemSwept.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.addsubdeviceslist",@"plugin_gateway","子设备");
        itemSwept.caption = @"睡眠结束后";
        itemSwept.comment = self.endComment;
        itemSwept.customUI = YES;
        itemSwept.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(50), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
        itemSwept.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
            [weakself onSleepEnd];
        };
        [sleepSettings addObject:itemSwept];
        
    }
    
    group1.items = sleepSettings;
    self.settingGroups = [NSMutableArray arrayWithObjects:group1,nil];
    [self.settingTableView reloadData];
    
}

- (void)onDone:(id)sender {
    XM_WS(weakself);
    [[MHTipsView shareInstance] showTips:@"" modal:YES];
    
    NSArray *payload = [self handleSleepCmd];
    //序列化发送4个温度对应的命令
    NSLog(@"准备下发的睡眠数据%@", payload);
    
    __block NSInteger count = 0;
    [self setSaveCmdBlock:^(NSInteger index) {
        if (count < weakself.cmdArray.count) {
            NSString *strCmd = weakself.cmdArray[count];
            NSLog(@"第%ld条命令 --- %@", count, strCmd);
            [weakself.acpartner saveCommandMap:strCmd success:^(id obj) {
                if (weakself.saveCmdBlock) {
                    weakself.saveCmdBlock(count);
                }
            } failure:^(NSError *v) {
                [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"operation.failed",@"plugin_gateway","操作失败, 请检查网络") duration:1.5f modal:NO];
            }];
        }
        else {
            [weakself setSleepModeData:payload Success:^(id obj) {
                [[MHTipsView shareInstance] hide];
                [weakself.acpartner resetAcStatus];
                [weakself.navigationController popViewControllerAnimated:YES];
            } failure:^(NSError *error) {
                NSLog(@"%@", error);
                [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"operation.failed",@"plugin_gateway","操作失败, 请检查网络") duration:1.5f modal:NO];
            }];
        }
        count++;
    }];
    //
    
    
    
    self.saveCmdBlock(0);
    [self gw_clickMethodCountWithStatType:@"setACPartnerSleep:"];
    
}

#pragma mark - 处理下发的睡眠数据
- (NSArray *)handleSleepCmd {
    XM_WS(weakself);
    
    NSMutableArray *payload = [NSMutableArray new];
    [payload addObject:@((int)self.isSleepOn)];
    self.beginCrontab = [self crontabStringWithHour:self.beginHour minute:self.onMinute repeatType:self.repeatType];
    self.afterCrontab = [self crontabStringWithHour:self.afterHour minute:self.onMinute repeatType:self.repeatType];
    self.endBeforeCrontab = [self crontabStringWithHour:self.endBeforeHour minute:self.offMinute repeatType:self.repeatType];
    self.endCrontab = [self crontabStringWithHour:self.endHour minute:self.offMinute repeatType:self.repeatType];
    
   
    
    //测试用
    //    self.beginCrontab = [self crontabStringWithHour:self.beginHour minute:self.onMinute repeatType:self.repeatType];
    //    self.afterCrontab = [self crontabStringWithHour:self.beginHour minute:self.onMinute + 2 repeatType:self.repeatType];
    //    self.endBeforeCrontab = [self crontabStringWithHour:self.beginHour minute:self.onMinute + 4 repeatType:self.repeatType];
    //    self.endCrontab = [self crontabStringWithHour:self.beginHour minute:self.onMinute + 6 repeatType:self.repeatType];
    
    NSArray *crontabArray = @[ self.beginCrontab,  self.afterCrontab, self.endBeforeCrontab, self.endCrontab ];
    
    NSArray *tempArray = @[ @(self.beginTemp),  @(self.afterTemp), @(self.endBeforeTemp), @(self.endTemp) ];
    
    NSLog(@"%@", tempArray);
    

    self.cmdArray = [NSMutableArray new];
    [tempArray enumerateObjectsUsingBlock:^(NSNumber *temp, NSUInteger idx, BOOL * _Nonnull stop) {
        weakself.acpartner.timerPowerState = 1;
        weakself.acpartner.timerModeState = self.sleepACMode;
        weakself.acpartner.timerWindPower = 1;
        weakself.acpartner.timerWindState = 1;
        NSLog(@"将要下发的温度%@", temp);
        weakself.acpartner.timerTemperature = [temp intValue];
        if (weakself.acpartner.ACType == 2) {
            [weakself.acpartner.kkAcManager changePowerStateWithPowerstate:AC_POWER_ON];
            [weakself.acpartner.kkAcManager getPowerState];
            [weakself.acpartner.kkAcManager getAirConditionInfrared];
            [weakself.acpartner judgeModeCanControl:PROP_TIMER];
            [weakself.acpartner judgeWindsCanControl:PROP_TIMER];
            [weakself.acpartner judgeSwipCanControl:PROP_TIMER];
            [weakself.acpartner judgeTempratureCanControl:PROP_TIMER];
        }
        NSString *strCmd = [weakself.acpartner getACCommand:POWER_ON_INDEX commandIndex:TIMER_COMMAND isTimer:NO];
        if (strCmd) {
            [weakself.cmdArray addObject:strCmd];
            [payload addObject:@[ crontabArray[idx], [strCmd substringWithRange:NSMakeRange(10, 8)]]];
        }
        
    }];
    
    
    
    if (self.endType) {
        [self countDelayOffTimeWith:self.endHour minute:self.offMinute];
        self.endOffCrontab = [self crontabStringWithHour:self.endOffHour minute:self.endOffMinute repeatType:self.repeatType];
        if (weakself.acpartner.ACType == 2) {
            [weakself.acpartner.kkAcManager changePowerStateWithPowerstate:AC_POWER_OFF];
            [weakself.acpartner.kkAcManager getPowerState];
            [weakself.acpartner.kkAcManager getAirConditionInfrared];
        }
        NSString *strOffCmd = [weakself.acpartner getACCommand:SPCIACL_OFF_INDEX commandIndex:TIMER_COMMAND isTimer:NO];
        if (strOffCmd) {
            [self.cmdArray addObject:strOffCmd];
        }
        [payload addObject:@[ self.endOffCrontab, kOFFCOMMAND]];
    }
    //固件那边要加默认值
    else {
        [payload addObject:@[ kDefaultCrontab, kDefaultCode]];
    }

    
    return payload;
}

- (void)initTimerWithCurrentTime {
    if (!_timer) {
        _timer = [[MHDataDeviceTimer alloc] init];
        _timer.isOffOpen = YES;
        _timer.isOnOpen = YES;
    }
    _timer.onRepeatType = self.repeatType;
    _timer.onHour = self.onHour;
    _timer.offHour = self.offHour;
    _timer.onMinute = self.onMinute;
    _timer.offMinute = self.offMinute;
    _timer.offRepeatType = self.repeatType;
    
}

#pragma mark- 设置睡眠时段
- (void)onTimespanSet {
    
    [self initTimerWithCurrentTime];
    
    MHACSleepTimeSettingViewController *timeVC = [[MHACSleepTimeSettingViewController alloc] initWithTimer:self.timer andAcpartner:self.acpartner];
    XM_WS(weakself);
    [timeVC setOnDone:^(MHDataDeviceTimer *newTimer) {
        weakself.timer = newTimer;
        weakself.onHour = newTimer.onHour;
        weakself.offHour = newTimer.offHour;
        weakself.onMinute = newTimer.onMinute;
        weakself.offMinute = newTimer.offMinute;
        
        weakself.onDay = newTimer.onDay;
        weakself.onMonth = newTimer.onMonth;
        
        weakself.offDay = newTimer.offDay;
        weakself.offMonth = newTimer.offMonth;
        
        weakself.repeatType = newTimer.onRepeatType;
        
        [weakself updateTimeSpan];
        NSLog(@"重复次数%ld", weakself.repeatType);
        NSLog(@"%ld, 开启月份%ld", newTimer.onDay, newTimer.onMonth);
        NSLog(@"%ld, 开启月份%ld", newTimer.offDay, newTimer.offMonth);
        [weakself updateUI];
    }];
    [self.navigationController pushViewController:timeVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"openACPartnerSleepTimeSpanPage:"];
}

- (void)updateTimeSpan {
    self.beginHour = self.onHour;
    self.afterHour = (self.onHour + 1) != 24 ?: 0;
    NSInteger newHour = self.onHour + 1;
    if (newHour == 24) {
        self.afterHour = 0;
    }
    else {
        self.afterHour = newHour;
    }
    NSLog(@"%ld", self.afterHour);
    NSInteger after = self.offHour - 1;
    if (after < 0) {
        self.endBeforeHour = 23;
    }
    else {
        self.endBeforeHour = after;
    }
    self.endHour = self.offHour;
    
}
#pragma mark - 空调模式选择
- (void)onAcMode {
    XM_WS(weakself);
    
    MHACPartnerModeSettingViewController *endVC = [[MHACPartnerModeSettingViewController alloc] initWithAcpartner:self.acpartner currentMode:_sleepACMode];
    endVC.isSleep = YES;
    [endVC setChooseMode:^(int mode) {
        weakself.sleepACMode = mode;
        [weakself updateUI];
    }];
    [self.navigationController pushViewController:endVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"openACPartnerSleepACModePage:"];
}


#pragma mark - 睡眠结束后操作
- (void)onSleepEnd {
    XM_WS(weakself);
    
    MHACSleepEndSettingViewController *endVC = [[MHACSleepEndSettingViewController alloc] initWithAcpartner:self.acpartner endType:self.endType];
    [endVC setEndSetBlock:^(NSUInteger type, NSUInteger delayOffTime) {
        weakself.endType = type;
        weakself.endoffTime = delayOffTime;
        [weakself updateUI];
    }];
    [self.navigationController pushViewController:endVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"openACPartnerSleepEndPage:"];

}



#pragma mark - 保存睡眠数据
- (void)setSleepModeData:(NSArray *)params Success:(SucceedBlock)success failure:(FailedBlock)failure {
    XM_WS(weakself);
    [self.acpartner setSleepMode:params success:^(id obj) {
        if (success) success(obj);
        
        [weakself updateUI];
        [weakself saveCoolData];
        
    } failure:^(NSError *error) {
        if (failure) failure(error);
        
        weakself.isSleepOn = !weakself.isSleepOn;
    }];
}

#pragma mark - 获取睡眠数据
- (void)getSleepModeData {
    
    XM_WS(weakself);
    [self.acpartner getSleepModeResultSuccess:^(id obj) {
        /*
         {
         code = 0;
         message = ok;
         result =     (
         0,
         (
         1471967340,
         11011a02
         ),
         (
         1471970940,
         11011a02
         ),
         (
         1471992660,
         11011a02
         ),
         (
         1471996260,
         11011902
         ),
         (
         11011902,
         d0d0d0d0
         )
         );
         }
         */
        NSLog(@"获取的睡眠数据%@", obj);
        if ([obj[@"result"] isKindOfClass:[NSArray class]] && [obj[@"result"] count] >= 6) {
            weakself.isSleepOn = [obj[@"result"][0] boolValue];
            
            weakself.beginCrontab = obj[@"result"][1][0];
            NSString *strBeginTemp = obj[@"result"][1][1];
            //00000000
            //未设置
            if ([weakself.beginCrontab isEqualToString:@""] || [weakself.beginCrontab isEqualToString:kDefaultCrontab] || [strBeginTemp isEqualToString:kDefaultCode]) {
                return;
            }
            
            //区分是一次还是重复多次
            if ([obj[@"result"][1][0] containsString:@"*"]) {
                weakself.afterCrontab = obj[@"result"][2][0];
                weakself.endBeforeCrontab = obj[@"result"][3][0];
                weakself.endCrontab = obj[@"result"][4][0];
    
                [weakself crontabStringToData];
                
                //默认值 不为kDefaultCrontab 说明设置了睡眠结束后关机
                if (![obj[@"result"][5][0] isEqualToString:kDefaultCrontab]) {
                    self.endType = 1;
                    weakself.endOffCrontab = obj[@"result"][5][0];
                    [weakself countEndOffTimeCrontabl:weakself.endOffCrontab];
                }
                else {
                    self.endType = 0;
                }
            }
            else {
                [weakself timeIntervalToDataWithBeginTime:[obj[@"result"][1][0] doubleValue] endTime:[obj[@"result"][4][0] doubleValue]];
                if (![obj[@"result"][5][0] isEqualToString:kDefaultCrontab]) {
                    self.endType = 1;
                    [weakself timeIntervalDelayOffTime:[obj[@"result"][5][0] doubleValue]];
                }
                else {
                    self.endType = 0;

                }
            }
            
            weakself.beginTemp = [weakself getTempWithCommand:obj[@"result"][1][1]];
            
            weakself.afterTemp = [weakself getTempWithCommand:obj[@"result"][2][1]];
            
            weakself.endBeforeTemp = [weakself getTempWithCommand:obj[@"result"][3][1]];
            
            weakself.endTemp = [weakself getTempWithCommand:obj[@"result"][4][1]];
            weakself.sleepACMode = [weakself getSleepModeWithCommand:obj[@"result"][4][1]];
            
        }
        [weakself updateUI];
        [weakself saveCoolData];
    } failure:^(NSError *error) {
        
    }];
}


#pragma mark - crontab 字符串的解析与生成
- (NSUInteger)getTempWithCommand:(NSString *)cmd {
    NSLog(@"分解命令%@", cmd);
    
    NSUInteger temp  = (NSUInteger)strtoul([[cmd substringWithRange:NSMakeRange(4, 2)] UTF8String], 0, 16);
    NSLog(@"温度的值%ld", temp);
    return temp;
    
}

- (int)getSleepModeWithCommand:(NSString *)cmd {
    NSLog(@"分解命令%@", cmd);
    
    int mode  = (int)strtoul([[cmd substringWithRange:NSMakeRange(1, 1)] UTF8String], 0, 16);
    
    mode = [self.acpartner writingToShowMode:mode];
    NSLog(@"模式的的值%d %@", mode, modeArray[mode]);
    return mode;
    
}

- (id)crontabStringWithHour:(NSUInteger)hour minute:(NSUInteger)minute repeatType:(NSUInteger)repeatType  {
    MHLMCrontabTime *crontabBegin = [[MHLMCrontabTime alloc] init];
    if (repeatType == MHCrontabDayOfWeekNone) {
        crontabBegin.minute = minute;
        crontabBegin.hour = hour;
        
        NSDate *requestDate = [self updateMonthAndDayRepeatOnceWithHour:hour minute:minute];
        NSCalendar* calendar = [NSCalendar currentCalendar];
        unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        NSDateComponents* comp2 = [calendar components:unitFlags fromDate:requestDate];
        //        comp2.hour = hour;
        //        comp2.minute = minute;
        //        comp2.second = 0;
        //    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:requestDate];
        NSLog(@"%ld, %ld, %ld, %ld, %ld", [comp2 year],[comp2 month], [comp2 day], [comp2 hour], [comp2 minute]);
        //转换时间和日期
        NSDate* localDate = [MHTimeUtils dateWithMonth:comp2.month day:comp2.day hour:comp2.hour minute:comp2.minute second:0 timeZone:nil refDate:requestDate];
        NSDateComponents* beijingComp = [MHTimeUtils componentsWithUnits:NSCalendarUnitYear | NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute inTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"] forDate:localDate];
        NSLog(@"北京时间%ld, %ld, %ld, %ld, %ld", [beijingComp year],[beijingComp month], [beijingComp day], [beijingComp hour], [beijingComp minute]);
        
        NSDate *newDate = [calendar dateFromComponents:beijingComp];
        
        double uct = [newDate timeIntervalSince1970];
        crontabBegin.dayOfMonth = [comp2 day];
        crontabBegin.month = [comp2 month];
        crontabBegin.daysOfWeek = [self timerRepeatBridgeTocrontabDay:repeatType];
        NSLog(@"%@", [crontabBegin repeatDescription]);
        NSLog(@"%lf", uct);
        NSString *uctTime = [NSString stringWithFormat:@"%.0f", uct];
        return uctTime;
    }
    else {
        NSString *strCrontab = nil;
        crontabBegin.minute = minute;
        crontabBegin.hour = hour;
        crontabBegin.daysOfWeek = [self timerRepeatBridgeTocrontabDay:repeatType];
        NSLog(@"%@", [crontabBegin repeatDescription]);
        strCrontab =  [crontabBegin beijingTimeCrontabString];
        NSLog(@"生成的时间格式%@", strCrontab);
        return strCrontab;
    }
    
    
    //    NSLog(@"重复描述%@", [crontab repeatDescription]);
    //    NSLog(@"定时,描述%@", [crontab timerDescription]);
}


- (NSDate *)updateMonthAndDayRepeatOnceWithHour:(NSUInteger)hour minute:(NSUInteger)minute {
    
    NSDate *newDate = [[NSDate alloc] init];
    NSDateComponents* newComp = [[NSDateComponents alloc] init];
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:[NSDate date]];
    
    
    //    NSLog(@"%ld, %ld, %ld,  %ld, %ld", [comp1 year],[comp1 month], [comp1 day] ,[comp1 hour], [comp1 minute]);
    if ((comp1.hour > hour) ||
        (comp1.hour == hour && comp1.minute > minute)) {
        NSTimeInterval secondsPerDay = 24 * 60 * 60;
        //明天时间
        NSDate *tomorrow = [[NSDate alloc] initWithTimeIntervalSinceNow:secondsPerDay];
        newComp = [calendar components:unitFlags fromDate:tomorrow];
        
    }
    else {
        newComp = [calendar components:unitFlags fromDate:[NSDate date]];
    }
    
    newComp.hour = hour;
    newComp.minute = minute;
    newComp.second = 0;
    //    NSDateComponents *newComp = [NSDateComponents ]
    newDate = [calendar dateFromComponents:newComp];
    return newDate;
}

- (NSDate *)countDelayOffTimeWith:(NSUInteger)hour minute:(NSUInteger)minute {
    NSDate *newDate = [[NSDate alloc] init];

    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:[NSDate date]];
    comp1.hour = hour;
    comp1.minute = minute;
    comp1.second = 0;
    
    newDate = [calendar dateFromComponents:comp1];
    
    NSTimeInterval secondsPerDay = self.endoffTime * 60;

    NSDate *endOffDate = [[NSDate alloc] initWithTimeInterval:secondsPerDay sinceDate:newDate];
    
    NSDateComponents *newComp = [calendar components:unitFlags fromDate:endOffDate];
    
    NSLog(@"关闭时间%ld", newComp.hour);
    NSLog(@"关闭分钟%ld", newComp.minute);
    
    self.endOffHour = newComp.hour;
    self.endOffMinute = newComp.minute;
    
    
    return endOffDate;
}


/**
 *  重复转换
 *
 *  @param repeatType timer的repeat
 *
 *  @return crontabTime的repeat
 */
- (NSUInteger)timerRepeatBridgeTocrontabDay:(NSInteger)repeatType {
    NSUInteger crontabDay = 0;
    if (repeatType & MHDeviceTimerRepeat_Mon) {
        crontabDay = crontabDay | MHCrontabMonday;
    }
    if (repeatType & MHDeviceTimerRepeat_Tues) {
        crontabDay = crontabDay | MHCrontabTuesday;
    }
    if (repeatType & MHDeviceTimerRepeat_Wed) {
        crontabDay = crontabDay | MHCrontabWednesday;
    }
    if (repeatType & MHDeviceTimerRepeat_Thur) {
        crontabDay = crontabDay | MHCrontabThursday;
    }
    if (repeatType & MHDeviceTimerRepeat_Fri) {
        crontabDay = crontabDay | MHCrontabFriday;
    }
    if (repeatType & MHDeviceTimerRepeat_Sat) {
        crontabDay = crontabDay | MHCrontabSaturday;
    }
    if (repeatType & MHDeviceTimerRepeat_Sun) {
        crontabDay = crontabDay | MHCrontabSunday;
    }
    
    return crontabDay;
}
- (NSUInteger)crontabDayBridgeToTimerRepeat:(NSInteger)repeatType {
    NSUInteger crontabDay = 0;
    if (repeatType & MHCrontabMonday) {
        crontabDay = crontabDay | MHDeviceTimerRepeat_Mon;
    }
    if (repeatType & MHCrontabTuesday) {
        crontabDay = crontabDay | MHDeviceTimerRepeat_Tues;
    }
    if (repeatType & MHCrontabWednesday) {
        crontabDay = crontabDay | MHDeviceTimerRepeat_Wed;
    }
    if (repeatType & MHCrontabThursday) {
        crontabDay = crontabDay | MHDeviceTimerRepeat_Thur;
    }
    if (repeatType & MHCrontabFriday) {
        crontabDay = crontabDay | MHDeviceTimerRepeat_Fri;
    }
    if (repeatType & MHCrontabSaturday) {
        crontabDay = crontabDay | MHDeviceTimerRepeat_Sat;
    }
    if (repeatType & MHCrontabSunday) {
        crontabDay = crontabDay | MHDeviceTimerRepeat_Sun;
    }
    
    return crontabDay;
}

#pragma mark- 处理crontab字符串
- (void)crontabStringToData {
    if ([self.beginCrontab isEqualToString:@""]) {
        return;
    }
    MHLMCrontabTime *begin = [MHLMCrontabTime timeFromBeijingCrontabString:self.beginCrontab];
    self.beginHour = begin.hour;
    self.onHour = begin.hour;
    self.onMinute = begin.minute;
    self.repeatType =  [self crontabDayBridgeToTimerRepeat:begin.daysOfWeek];
    
    MHLMCrontabTime *end = [MHLMCrontabTime timeFromBeijingCrontabString:self.endCrontab];
    self.endHour = end.hour;
    self.offHour = end.hour;
    self.offMinute = end.minute;
    
    NSLog(@"开启小时%ld", begin.hour);
    NSLog(@"开启分钟%ld", begin.minute);
    NSLog(@"重复的类型%ld", begin.daysOfWeek);
    
}

//解析重复一次的开始和结束时间
- (void)timeIntervalToDataWithBeginTime:(double)beginTnterval endTime:(double)endInterval {
    //   NSDate *beginDate =  [NSDate dateWithTimeIntervalSinceNow:beginTnterval];
    //    NSDate *endDate =  [NSDate dateWithTimeIntervalSinceNow:endInterval];
    
    //    NSLog(@"%ld, %ld, %ld,  %ld, %ld", [comp1 year],[comp1 month], [comp1 day] ,[comp1 hour], [comp1 minute]);
    NSDateComponents *beginComp = [self timeIntervalToComponents:beginTnterval];
    self.onHour = beginComp.hour;
    self.onMinute = beginComp.minute;
    self.repeatType = MHDeviceTimerRepeat_Once;
    
    NSDateComponents *endComp = [self timeIntervalToComponents:endInterval];
    self.offHour = endComp.hour;
    self.offMinute = endComp.minute;
    
    NSLog(@"%ld", self.onHour);
}

//时间转换
- (NSDateComponents *)timeIntervalToComponents:(NSTimeInterval)timeInterval {
    NSDate *beginDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *beginComp = [calendar components:unitFlags fromDate:beginDate];
    
    return beginComp;
}

//解析crontab有关机命令的关机时间
- (void)countEndOffTimeCrontabl:(NSString *)strCrontab {
    MHLMCrontabTime *endOff = [MHLMCrontabTime timeFromBeijingCrontabString:strCrontab];
    self.endOffHour = endOff.hour;
    self.endOffMinute = endOff.minute;
    
    self.endoffTime = [self timeSpacnDelayOffTime];
    
}

//解析一次性的关机命令的关机时间
- (void)timeIntervalDelayOffTime:(NSTimeInterval)timeInterval {
    NSDateComponents *endOff = [self timeIntervalToComponents:timeInterval];
    self.endOffHour = endOff.hour;
    self.endOffMinute = endOff.minute;
    
    self.endoffTime = [self timeSpacnDelayOffTime];
}


//计算2个时间之间的时间差
- (NSUInteger)timeSpacnDelayOffTime {
    NSInteger hourSpan = 0;
    NSDate *onDate = [NSDate date];
    NSDate *offDate = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // 需要对比的时间数据
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth
    | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    NSDateComponents *onComp = [calendar components:unit fromDate:onDate];
    NSDateComponents *offComp = [calendar components:unit fromDate:offDate];
    
    onComp.hour = self.endHour;
    onComp.minute = self.offMinute;
    
    offComp.hour = self.endOffHour;
    offComp.minute = self.endOffMinute;
    
    onDate = [calendar dateFromComponents:onComp];
    offDate = [calendar dateFromComponents:offComp];
    
    NSCalendarUnit unitMinute = NSCalendarUnitMinute;

    
    // 对比时间差
    NSDateComponents *Compare = [calendar components:unitMinute fromDate:onDate toDate:offDate options:0];
    hourSpan = Compare.minute;
    
    NSLog(@"时间差%ld", hourSpan);
    return Compare.minute;
}


#pragma mark - 刷新界面
- (void)updateUI {
    
 
    [self initTimerWithCurrentTime];
   
    self.tempView.hidden = !self.isSleepOn;
    self.tipsLabel.hidden = !self.isSleepOn;
    
    self.endComment = self.endType ? [NSString stringWithFormat:@"%ld分钟后关闭空调", self.endoffTime] : @"保持现状";
    
    NSString *strRepeat = [_timer getOnRepeatTypeString];
    if (self.repeatType == MHDeviceTimerRepeat_Workday) {
        strRepeat =  NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.workday",@"plugin_gateway","周一到周五");
    }
    if (self.repeatType == MHDeviceTimerRepeat_Once) {
        strRepeat = NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.once",@"plugin_gateway","执行一次");
    }
    
    NSString *strTime = [_timer getOnTimeString];
    NSString *strOffTime = [_timer getOffTimeString];
    NSLog(@"%@ %@", strRepeat, strTime);
    
    self.timeSpan = [NSString stringWithFormat:@"%@ %@ - %@", strRepeat, strTime, strOffTime];
    [self.tempView reloadView:@[ @(self.beginTemp),  @(self.afterTemp), @(self.endBeforeTemp), @(self.endTemp) ] timeArray:@[ @(self.onHour),  @(self.offHour), @(self.onMinute), @(self.offMinute) ]];
    
    [self buildTableView];
    
}

- (void)saveCoolData {
    [[NSUserDefaults standardUserDefaults] setObject:@(self.isSleepOn) forKey:[NSString stringWithFormat:@"acpartner_isSleepOn_%@%@",self.acpartner.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.repeatType) forKey:[NSString stringWithFormat:@"acpartner_sleepRepeatType_%@%@",self.acpartner.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] setObject:@[ @(self.onHour),  @(self.offHour), @(self.onMinute), @(self.offMinute) ] forKey:[NSString stringWithFormat:@"acpartner_SleepTime_%@%@",self.acpartner.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] setObject:@[ @(self.beginTemp),  @(self.afterTemp), @(self.endBeforeTemp), @(self.endTemp) ] forKey:[NSString stringWithFormat:@"acpartner_sleepTemp_%@%@",self.acpartner.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.endoffTime) forKey:[NSString stringWithFormat:@"acpartner_endoffTime_%@%@",self.acpartner.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.endType) forKey:[NSString stringWithFormat:@"acpartner_endType_%@%@",self.acpartner.did,[MHPassportManager sharedSingleton].currentAccount.userId]];


    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)restoreCoolData {
    self.isSleepOn =  [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"acpartner_isSleepOn_%@%@",self.acpartner.did,[MHPassportManager sharedSingleton].currentAccount.userId]] boolValue];
    self.repeatType = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"acpartner_sleepRepeatType_%@%@",self.acpartner.did,[MHPassportManager sharedSingleton].currentAccount.userId]] integerValue];
    self.endoffTime = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"acpartner_endoffTime_%@%@",self.acpartner.did,[MHPassportManager sharedSingleton].currentAccount.userId]] integerValue];
    self.endType = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"acpartner_endType_%@%@",self.acpartner.did,[MHPassportManager sharedSingleton].currentAccount.userId]] integerValue];
    
    NSArray *timeArray = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"acpartner_SleepTime_%@%@",self.acpartner.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    NSArray *tempArray = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"acpartner_sleepTemp_%@%@",self.acpartner.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    
    if (timeArray.count >= 4) {
        self.onHour = [timeArray[0] integerValue];
        self.offHour = [timeArray[1] integerValue];
        self.onMinute = [timeArray[2] integerValue];
        self.offMinute = [timeArray[3] integerValue];
        [self updateTimeSpan];
    }
    else {
        self.onHour = 23;
        self.offHour = 7;
        self.onMinute = 0;
        self.offMinute = 0;
        self.repeatType = MHDeviceTimerRepeat_Everyday;
        [self updateTimeSpan];
    }
    if (tempArray.count >= 4) {
        self.beginTemp = [tempArray[0] integerValue] ?: 26;
        self.afterTemp = [tempArray[1] integerValue] ?: 28;
        self.endBeforeTemp = [tempArray[2] integerValue] ?: 28;
        self.endTemp = [tempArray[3] integerValue] ?: 26;
    }
    else {
        self.beginTemp = 26;
        self.afterTemp = 28;
        self.endBeforeTemp = 28;
        self.endTemp = 26;
    }
    
    //    self.isCool = self.isCool ?: 10;
    //    NSLog(@"%@", self.bindDid);
    
}


@end
