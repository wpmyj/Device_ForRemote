//
//  MHACSleepViewController.m
//  MiHome
//
//  Created by ayanami on 16/7/21.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACSleepViewController.h"
#import "MHACSleepTemperatureView.h"
#import "MHLumiPopoverSlider.h"
#import "MHLuTimerDetailViewController.h"
#import "MHLMVerticalSlider.h"
#import "MHACSleepTimeSettingViewController.h"
#import "MHLMCrontabTime.h"
#import <MiHomeKit/MHTimeUtils.h>

@interface MHACSleepViewController ()
@property (nonatomic, strong) MHDeviceAcpartner *acpartner;
@property (nonatomic, copy) MHDataDeviceTimer *timer;
@property (nonatomic, copy) MHDataDeviceTimer *oldTimer;



@property (nonatomic, strong) UISwitch *sleepSwitch;
@property (nonatomic, strong) UILabel *sleepCaption;
@property (nonatomic, strong) UILabel *sleepComment;

@property (nonatomic, strong) UILabel *setting;

@property (nonatomic, strong) UIControl *timeSpanView;
@property (nonatomic, strong) UILabel *timespanTitle;
@property (nonatomic, strong) UILabel *timespan;
@property (nonatomic, strong) UIImageView *indictorView;
@property (nonatomic, strong) UIControl *timeSpanBtn;

@property (nonatomic, strong) UIView *lineOne;
@property (nonatomic, strong) UIView *lineTwo;
@property (nonatomic, strong) UIView *lineThree;

@property (nonatomic, strong) MHACSleepTemperatureView *tempView;
@property (nonatomic, strong) UILabel *tipsLabel;

@property (nonatomic, strong) UILabel *tempLabel;


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

@property (nonatomic, copy) NSString *beginCrontab;
@property (nonatomic, copy) NSString *afterCrontab;
@property (nonatomic, copy) NSString *endBeforeCrontab;
@property (nonatomic, copy) NSString *endCrontab;

@property (nonatomic, strong) NSNumber *beginTimeInterval;
@property (nonatomic, strong) NSNumber *afterTimeInterval;
@property (nonatomic, strong) NSNumber *endBeforeTimeInterval;
@property (nonatomic, strong) NSNumber *endTimeInterval;

@property (nonatomic, copy) void(^saveCmdBlock)(NSInteger);
@property (nonatomic, strong) NSMutableArray *cmdArray;


@end


@implementation MHACSleepViewController
- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner
{
    self = [super init];
    if (self) {
        self.isTabBarHidden = YES;
        self.acpartner = acpartner;
        
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    
    
}

- (void)buildSubviews {
    [super buildSubviews];
   

    
       
    XM_WS(weakself);
    self.sleepCaption = [[UILabel alloc] init];
    self.sleepCaption.textAlignment = NSTextAlignmentCenter;
    self.sleepCaption.textColor = [MHColorUtils colorWithRGB:0x333333];
    self.sleepCaption.font = [UIFont systemFontOfSize:15.0f];
    self.sleepCaption.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.sleepmode.caption",@"plugin_gateway","睡眠模式");

    [self.view addSubview:self.sleepCaption];
    
    
    self.sleepComment = [[UILabel alloc] init];
    self.sleepComment.textAlignment = NSTextAlignmentLeft;
    self.sleepComment.textColor = [MHColorUtils colorWithRGB:0x888888];
    self.sleepComment.font = [UIFont systemFontOfSize:13.0f];
    self.sleepComment.numberOfLines = 0;
    self.sleepComment.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.sleepmode.comment",@"plugin_gateway","按照睡眠曲线, 以最低风速调整空调温度");
    [self.view addSubview:self.sleepComment];
    
    
    self.sleepSwitch = [[UISwitch alloc] init];
    [self.sleepSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sleepSwitch];
    
    
    //    [_bottomLine setFrame:CGRectMake(20.0f, self.bounds.size.height - 1.0f, self.bounds.size.width - 20.0f * 2, 1.0f)];
    _lineOne = [[UIView alloc] init];
    _lineOne.backgroundColor = [MHColorUtils colorWithRGB:0xf1f1f1];
    [self.view addSubview:_lineOne];
    
    
  
    self.timeSpanView = [[UIControl alloc] initWithFrame:CGRectMake(0, 140, WIN_WIDTH, 60)];
    self.timeSpanView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.timeSpanView];

    _lineTwo = [[UIView alloc] init];
    _lineTwo.backgroundColor = [MHColorUtils colorWithRGB:0xf1f1f1];
    [self.timeSpanView addSubview:_lineTwo];
    
    self.timespanTitle = [[UILabel alloc] init];
    self.timespanTitle.textAlignment = NSTextAlignmentCenter;
    self.timespanTitle.textColor = [MHColorUtils colorWithRGB:0x333333];
    self.timespanTitle.font = [UIFont systemFontOfSize:15.0f];
    self.timespanTitle.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.sleepmode.timespan",@"plugin_gateway","睡眠时段");
    [self.timeSpanView addSubview:self.timespanTitle];
    
    
    self.timespan = [[UILabel alloc] init];
    self.timespan.textAlignment = NSTextAlignmentRight;
    self.timespan.textColor = [MHColorUtils colorWithRGB:0x888888];
    self.timespan.font = [UIFont systemFontOfSize:13.0f];
    [self.timeSpanView addSubview:self.timespan];
    
    self.indictorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lumi_scene_log_rightarrow"]];
    self.indictorView.userInteractionEnabled = YES;
    [self.timeSpanView addSubview:self.indictorView];
    
    _timeSpanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_timeSpanBtn addTarget:self action:@selector(onTimespanSet:) forControlEvents:UIControlEventTouchUpInside];
    _timeSpanBtn.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_timeSpanBtn];

    
    //14 26 scenelog
    
//    _lineThree = [[UIView alloc] init];
//    _lineThree.backgroundColor = [MHColorUtils colorWithRGB:0xf1f1f1];
//    [self.timeSpanView addSubview:_lineThree];
    
    
    
    

    

    self.tipsLabel = [[UILabel alloc] init];
    self.tipsLabel.textAlignment = NSTextAlignmentLeft;
    self.tipsLabel.textColor = [MHColorUtils colorWithRGB:0x888888];
    self.tipsLabel.font = [UIFont systemFontOfSize:14.0f];
    self.tipsLabel.numberOfLines = 0;
    self.tipsLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.sleepmode.tips",@"plugin_gateway","注: 只有空调打开时, 该功能才起作用");

    [self.view addSubview:self.tipsLabel];
    
    
    
      
//    self.slider.transform = CGAffineTransformMakeRotation(-M_PI/2);
    self.tempView = [[MHACSleepTemperatureView alloc] initWithFrame:CGRectMake(0, 260 * ScaleHeight, WIN_WIDTH, WIN_HEIGHT - 240 * ScaleHeight) acpartner:self.acpartner];
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
   
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 44, 26);
    [btn setBackgroundColor:[MHColorUtils colorWithRGB:0x1dc58a]];
    [btn setTitle:NSLocalizedStringFromTable(@"Ok",@"plugin_gateway", "确定") forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13.f];
    btn.layer.cornerRadius = 3.0f;
    [btn addTarget:self action:@selector(onDone:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
 

}




- (void)buildConstraints {
    [super buildConstraints];
    XM_WS(weakself);
    
    CGFloat leftSpacing = 15;
    CGFloat labelSpacing = 15;
    CGFloat lineSpacing = 5;
    CGFloat leadSpacing = 80;

    
    [self.sleepCaption mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.view.mas_left).with.offset(leftSpacing);
        make.top.mas_equalTo(weakself.view.mas_top).with.offset(leadSpacing);
    }];
    
    [self.sleepComment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.view.mas_left).with.offset(leftSpacing);
        make.top.mas_equalTo(weakself.sleepCaption.mas_bottom);
        make.width.mas_equalTo(WIN_WIDTH - 70);
    }];
    
    [self.sleepSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakself.view.mas_right).with.offset(-20);
        make.top.mas_equalTo(weakself.view.mas_top).with.offset(leadSpacing);
        make.size.mas_equalTo(CGSizeMake(40 * ScaleWidth, 20 * ScaleWidth));
    }];
    
    [self.lineOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.sleepComment.mas_bottom).with.offset(labelSpacing);
        make.width.mas_equalTo(WIN_WIDTH - leftSpacing * 2);
        make.height.mas_equalTo(1);
        make.centerX.equalTo(weakself.view);
    }];
    

    
    [self.timeSpanView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakself.view);
        make.top.mas_equalTo(weakself.lineOne.mas_bottom).with.offset(2);
        make.size.mas_equalTo(CGSizeMake(WIN_WIDTH, 60));
    }];
    
    [self.timespanTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.timeSpanView.mas_left).with.offset(leftSpacing);
        make.top.mas_equalTo(weakself.timeSpanView.mas_top).with.offset(leftSpacing);
    }];
    
    
    [self.indictorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakself.view.mas_right).with.offset(-leftSpacing);
        make.top.mas_equalTo(weakself.timeSpanView.mas_top).with.offset(leftSpacing);
        make.size.mas_equalTo(CGSizeMake(7, 13));
    }];
    
    [self.timespan mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakself.indictorView.mas_left).with.offset(-lineSpacing);
        make.top.mas_equalTo(weakself.timeSpanView.mas_top).with.offset(leftSpacing);
    }];
    
    [self.timeSpanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakself.timeSpanView);
    }];


    [self.lineTwo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.timespan.mas_bottom).with.offset(leftSpacing);
        make.width.mas_equalTo(WIN_WIDTH - leftSpacing * 2);
        make.height.mas_equalTo(1 * ScaleHeight);
        make.centerX.equalTo(weakself.view);
    }];
    

    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.view.mas_left).with.offset(leftSpacing);
        make.right.mas_equalTo(weakself.view.mas_right).with.offset(-leftSpacing);
        make.top.mas_equalTo(weakself.lineTwo.mas_bottom).with.offset(labelSpacing);
    }];
    
//    [self.tempView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.bottom.right.equalTo(weakself.view);
//        make.top.mas_equalTo(weakself.tipsLabel.mas_bottom).with.offset(labelSpacing);
//    }];
    
    
    
}

- (void)onBack:(id)sender {
    [super onBack:sender];
//    if (![_timer isEqualWithTimer:_oldTimer]) {
//        [[MHTipsView shareInstance] showTipsInfo:@"是否要放弃更改" duration:1.5f modal:YES];
//    }
    
}

- (void)onDone:(id)sender {
    XM_WS(weakself);
    [[MHTipsView shareInstance] showTips:@"" modal:YES];

    NSArray *payload = [self handleSleepCmd];
     //序列化发送4个温度对应的命令
    NSLog(@"准备下发的睡眠数据%@", payload);

    __block NSInteger count = 0;
    [self setSaveCmdBlock:^(NSInteger index) {
        if (count < 4) {
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
        weakself.acpartner.timerModeState = 0;
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

- (void)onTimespanSet:(id)sender {
    
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

- (void)switchValueChanged:(UISwitch *)sender {
    self.isSleepOn = !self.isSleepOn;
    [self gw_clickMethodCountWithStatType:@"setACPartnerSleepSwitch:"];
}

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

- (void)getSleepModeData {
    
    XM_WS(weakself);
    [self.acpartner getSleepModeResultSuccess:^(id obj) {
        NSLog(@"获取的睡眠数据%@", obj);
        if ([obj[@"result"] isKindOfClass:[NSArray class]] && [obj[@"result"] count] >= 5) {
            weakself.isSleepOn = [obj[@"result"][0] boolValue];
            
            weakself.beginCrontab = obj[@"result"][1][0];
            NSString *strBeginTemp = obj[@"result"][1][1];
            //00000000
            
            if ([weakself.beginCrontab isEqualToString:@""] || [weakself.beginCrontab isEqualToString:@"* * * * *"] || [strBeginTemp isEqualToString:@"00000000"]) {
                return;
            }
            if ([obj[@"result"][1][0] containsString:@"*"]) {
                weakself.afterCrontab = obj[@"result"][2][0];
                weakself.endBeforeCrontab = obj[@"result"][3][0];
                weakself.endCrontab = obj[@"result"][4][0];
                [weakself crontabStringToData];
            }
            else {
                [weakself timeIntervalToDataWithBeginTime:[obj[@"result"][1][0] doubleValue] endTime:[obj[@"result"][4][0] doubleValue]];
            }

            weakself.beginTemp = [weakself getTempWithCommand:obj[@"result"][1][1]];
            
            weakself.afterTemp = [weakself getTempWithCommand:obj[@"result"][2][1]];

            weakself.endBeforeTemp = [weakself getTempWithCommand:obj[@"result"][3][1]];

            weakself.endTemp = [weakself getTempWithCommand:obj[@"result"][4][1]];

        }
        [weakself updateUI];
        [weakself saveCoolData];
    } failure:^(NSError *error) {
        
    }];
}

- (NSUInteger)getTempWithCommand:(NSString *)cmd {
    NSLog(@"分解命令%@", cmd);

   NSUInteger temp  = (NSUInteger)strtoul([[cmd substringWithRange:NSMakeRange(4, 2)] UTF8String], 0, 16);
    NSLog(@"温度的值%ld", temp);
    return temp;
    
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

- (void)timeIntervalToDataWithBeginTime:(double)beginTnterval endTime:(double)endInterval {
//   NSDate *beginDate =  [NSDate dateWithTimeIntervalSinceNow:beginTnterval];
//    NSDate *endDate =  [NSDate dateWithTimeIntervalSinceNow:endInterval];
   NSDate *beginDate = [NSDate dateWithTimeIntervalSince1970:beginTnterval];
    NSDate *endDate =  [NSDate dateWithTimeIntervalSince1970:endInterval];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *beginComp = [calendar components:unitFlags fromDate:beginDate];
    
    //    NSLog(@"%ld, %ld, %ld,  %ld, %ld", [comp1 year],[comp1 month], [comp1 day] ,[comp1 hour], [comp1 minute]);
    self.onHour = beginComp.hour;
    self.onMinute = beginComp.minute;
    self.repeatType = MHDeviceTimerRepeat_Once;
    
    NSDateComponents *endComp = [calendar components:unitFlags fromDate:endDate];
    self.offHour = endComp.hour;
    self.offMinute = endComp.minute;
    
    NSLog(@"%ld", self.onHour);
}

- (void)updateUI {
    
//    self.tempView.hidden = !self.isSleepOn;
//    self.timeSpanView.hidden = !self.isSleepOn;
//    self.tipsLabel.hidden = !self.isSleepOn;
    [self initTimerWithCurrentTime];
    

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
    self.timespan.text = [NSString stringWithFormat:@"%@ %@ - %@", strRepeat, strTime, strOffTime];

    self.sleepSwitch.on = self.isSleepOn;
    
    [self.tempView reloadView:@[ @(self.beginTemp),  @(self.afterTemp), @(self.endBeforeTemp), @(self.endTemp) ] timeArray:@[ @(self.onHour),  @(self.offHour), @(self.onMinute), @(self.offMinute) ]];

}

- (void)saveCoolData {
    [[NSUserDefaults standardUserDefaults] setObject:@(self.isSleepOn) forKey:[NSString stringWithFormat:@"acpartner_isSleepOn_%@%@",self.acpartner.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
      [[NSUserDefaults standardUserDefaults] setObject:@(self.repeatType) forKey:[NSString stringWithFormat:@"acpartner_sleepRepeatType_%@%@",self.acpartner.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] setObject:@[ @(self.onHour),  @(self.offHour), @(self.onMinute), @(self.offMinute) ] forKey:[NSString stringWithFormat:@"acpartner_SleepTime_%@%@",self.acpartner.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] setObject:@[ @(self.beginTemp),  @(self.afterTemp), @(self.endBeforeTemp), @(self.endTemp) ] forKey:[NSString stringWithFormat:@"acpartner_sleepTemp_%@%@",self.acpartner.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)restoreCoolData {
    self.isSleepOn =  [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"acpartner_isSleepOn_%@%@",self.acpartner.did,[MHPassportManager sharedSingleton].currentAccount.userId]] boolValue];
    self.repeatType = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"acpartner_sleepRepeatType_%@%@",self.acpartner.did,[MHPassportManager sharedSingleton].currentAccount.userId]] integerValue];
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
