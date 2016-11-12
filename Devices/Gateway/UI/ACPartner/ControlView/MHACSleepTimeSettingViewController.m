//
//  MHACSleepTimeSettingViewController.m
//  MiHome
//
//  Created by ayanami on 16/7/25.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACSleepTimeSettingViewController.h"
#import "MHLuTimerRepeatTypeVC.h"
#import "MHGatewayTimerPicker.h"
#import "MHStrongBox.h"
#import "MHGatewayAlarmClockTimerTools.h"
#import "MHLumiAccessSettingCell.h"
#import "MHLumiDefaultSettingCell.h"
#import "MHACPartnerPreferencesViewController.h"
#import "MHACPartnerTimerPicker.h"
#import "MHACCrontabRepeatType.h"

#define TimerSettingCellId                  @"MHLumiAccessSettingCell"
#define TimerPreferencesSettingCellId       @"MHLumiDefaultSettingCell"

#define TimerModifyAbortAVTag       21000
#define TimerModifyDeleteAVTag      21001
#define TimerAddAbortAVTag          21002

typedef enum : NSInteger {
    TimerSetting_RepeatType,
    TimerSetting_OpenTime,
    TimerSetting_CloseTime,
}   TimerSetting;

@interface MHACSleepTimeSettingViewController ()

@property (nonatomic, strong) MHTimerPicker *openTimePicker;
@property (nonatomic, strong) MHTimerPicker *closeTimePicker;

@property (nonatomic, strong) MHDataDeviceTimer *timer;
@property (nonatomic, strong) MHDataDeviceTimer *oldTimer;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic,strong) MHDeviceAcpartner *acpartner;
@property (nonatomic, assign) BOOL isAddNewTimer;

@end

@implementation MHACSleepTimeSettingViewController
{
    
    NSArray*                _settings;
}

- (id)initWithTimer:(MHDataDeviceTimer* )timer andAcpartner:(MHDeviceAcpartner *)acpartner {
    if (self = [super init]) {
        _acpartner = acpartner;
        if (!timer) {
            _isAddNewTimer = YES;
            [self initTimerWithCurrentTime];
        } else {
            _timer = timer;
        }
        _oldTimer = [_timer copy];
        NSArray *timespan = [NSArray arrayWithObjects:
                             @(TimerSetting_RepeatType),
                             @(TimerSetting_OpenTime),
                             @(TimerSetting_CloseTime),nil];
        _settings = [NSArray arrayWithObjects:timespan, nil];
    }
    return self;
}


- (void)initTimerWithCurrentTime {
    if (!_timer) {
        _timer = [[MHDataDeviceTimer alloc] init];
        _timer.onRepeatType = MHDeviceTimerRepeat_Everyday;
        _timer.onHour = 23;
        _timer.offHour = 8;
        _timer.onMinute = _timer.offMinute = 0;
        _timer.offRepeatType = MHDeviceTimerRepeat_Everyday;

        self.acpartner.timerACType = self.acpartner.ACType;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [_tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //    [_tableView reloadData];
}
- (void)buildSubviews {
    [super buildSubviews];
    
        self.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.sleepmode.timespan.title",@"plugin_gateway","睡眠时段设置");
    self.isTabBarHidden = YES;
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 44, 26);
    [btn setBackgroundColor:[MHColorUtils colorWithRGB:0x1dc58a]];
    [btn setTitle:NSLocalizedStringFromTable(@"Ok",@"plugin_gateway", "确定") forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13.f];
    btn.layer.cornerRadius = 3.0f;
    [btn addTarget:self action:@selector(onDone:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    //    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_tableView];
    
    XM_WS(weakself);
    _openTimePicker = [[MHTimerPicker alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.timersetting.on",@"plugin_gateway","开启时间") timePicked:^(NSUInteger hour, NSUInteger minute) {
        weakself.timer.onHour = hour % 24;
        weakself.timer.onMinute = minute % 60;
        weakself.timer.isOnOpen = YES;
//        weakself.openTimePicker.pickerTitle.text = [[MHGatewayAlarmClockTimerTools sharedInstance] fetchTimeSpace:weakself.timer andIdentifier:NextIdentifierOn];
        [weakself.timer updateTimerMonthAndDayForRepeatOnceType];
        [weakself.tableView reloadData];
    }];
//    [_openTimePicker setOnOk:^{
//        weakself.timer.isOnOpen = YES;
//        [weakself.tableView reloadData];
//        
//    }];
//    [_openTimePicker setOnClear:^{
//        weakself.timer.isOnOpen = NO;
//        [weakself.tableView reloadData];
//    }];
//    _openTimePicker.pickerTitle.text = [[MHGatewayAlarmClockTimerTools sharedInstance] fetchTimeSpace:weakself.timer andIdentifier:NextIdentifierOn];
    
    _closeTimePicker = [[MHTimerPicker alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.timersetting.off",@"plugin_gateway","关闭时间") timePicked:^(NSUInteger hour, NSUInteger minute) {
        weakself.timer.offHour = hour % 24;
        weakself.timer.offMinute = minute % 60;
        weakself.timer.isOffOpen = YES;
//        weakself.closeTimePicker.pickerTitle.text = [[MHGatewayAlarmClockTimerTools sharedInstance] fetchTimeSpace:weakself.timer andIdentifier:NextIdentifierOff];
        [weakself.timer updateTimerMonthAndDayForRepeatOnceType];
        [weakself.tableView reloadData];
    }];
//    [_closeTimePicker setOnOk:^{
//        weakself.timer.isOffOpen = YES;
//        [weakself.tableView reloadData];
//    }];
//    [_closeTimePicker setOnClear:^{
//        weakself.timer.isOffOpen = NO;
//        [weakself.tableView reloadData];
//    }];
//    _closeTimePicker.pickerTitle.text = [[MHGatewayAlarmClockTimerTools sharedInstance] fetchTimeSpace:weakself.timer andIdentifier:NextIdentifierOff];
    
    
}

#pragma mark - 按钮消息
- (void)onBack:(id)sender {
    if (![_timer isEqualWithTimer:_oldTimer]) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.timersetting.cancel.tips",@"plugin_gateway","要舍弃对该定时的修改吗？") message:nil delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"plugin_gateway","取消") otherButtonTitles:NSLocalizedStringFromTable(@"Ok", @"plugin_gateway","确定"), nil];
        alertView.tag = TimerModifyAbortAVTag;
        [alertView show];
        return;
    }
    [super onBack:sender];
}

- (void)onDone:(id)sender {
    if (![self timeSpacnLength]) {
        [[MHTipsView shareInstance] showTipsInfo:@"睡眠时段至少需要设置4个小时" duration:1.5 modal:YES];
        return;
    }
    
    
    if (_timer.isOnOpen && _timer.isOffOpen && _timer.onHour == _timer.offHour && _timer.onMinute == _timer.offMinute) {
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.timersetting.invalid",@"plugin_gateway","您设置的开关时间相同，请重新设置") duration:1.0 modal:NO];
        return;
    }
    
    
    [_timer updateTimerMonthAndDayForRepeatOnceType];
    if (_onDone) {
        _onDone(_timer);
    }
    [self.navigationController popViewControllerAnimated:YES];
}


- (BOOL)timeSpacnLength {
    BOOL isLength = NO;
    NSInteger hourSpan = 0;
//    NSInteger minuteSpan = 0;
//    
//    if (onHour + 1 == 24) {
//        if (onHour != offHour) {
//            hourSpan = 1 + offHour;
//        }
//        else {
//            return NO;
//        }
//    }
//    else if (onHour > offHour && offHour <= 23) {
//        hourSpan = onHour - offHour;
//    }
//    else if (offHour > onHour) {
//        hourSpan = offHour - onHour;
//    }
//    else {
//        hourSpan = 24 - onHour + offHour;
//    }
//    minuteSpan = onMinute - offMinute;
//    if (hourSpan >= 4) {
//        isLength = YES;
//    }
//    else {
//        isLength = NO;
//    }
    
    NSDate *onDate = [NSDate date];
    NSDate *offDate = [NSDate date];
    
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // 需要对比的时间数据
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth
    | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    NSDateComponents *onComp = [calendar components:unit fromDate:onDate];
    NSDateComponents *offComp = [calendar components:unit fromDate:offDate];
    
    onComp.hour = _timer.onHour;
    
    offComp.hour = _timer.offHour;
    
    onDate = [calendar dateFromComponents:onComp];
    offDate = [calendar dateFromComponents:offComp];

    // 对比时间差
        NSDateComponents *Compare = [calendar components:unit fromDate:onDate toDate:offDate options:0];
    hourSpan = Compare.hour;
    
    if (hourSpan < 0) {
        hourSpan = 24 + hourSpan;
    }
    NSLog(@"时间差%ld", hourSpan);
    if (hourSpan >= 4) {
        isLength = YES;
    }
    else {
        isLength = NO;
    }
    return isLength;
}

//- (void)onSwitchOpenClose:(BOOL)on cellIndex:(NSInteger)index {
//    if (index == 1) {
//        _timer.isOnOpen = on;
//    } else if (index == 2) {
//        _timer.isOffOpen = on;
//    }
//}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == TimerModifyAbortAVTag) {
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
                //舍弃对该定时的修改
                [_timer resetWithTimer:_oldTimer];
                [super onBack:nil];
                break;
            default:
                break;
        }
    } else if (alertView.tag == TimerModifyDeleteAVTag) {
        switch (buttonIndex) {
            case 0:
                break;
            case 1: {
                //删除定时
                if (_onDone) {
                    _onDone(_timer);
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
                break;
            default:
                break;
        }
        
    } else if (alertView.tag == TimerAddAbortAVTag) {
        switch (buttonIndex) {
            case 0:
                break;
            case 1: {
                //取消添加
                //                [_timer resetWithTimer:_oldTimer];
                [super onBack:nil];
            }
                break;
            default:
                break;
        }
    }
}


#pragma mark - UITableViewDelegate&DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0) {
        switch ((TimerSetting)indexPath.row) {
            case TimerSetting_OpenTime: {
                NSInteger hourRow = TimerPickerInitPosition * 24 + _timer.onHour;
                NSInteger minRow = TimerPickerInitPosition * 24 + _timer.onMinute;
                [_openTimePicker.picker selectRow:hourRow inComponent:0 animated:NO];
                [_openTimePicker.picker selectRow:minRow inComponent:1 animated:NO];
                [_openTimePicker showInView:self.view.window];
            }
                break;
            case TimerSetting_CloseTime: {
                NSInteger hourRow = TimerPickerInitPosition * 24+ _timer.offHour;
                NSInteger minRow = TimerPickerInitPosition * 24 +  _timer.offMinute;
                [_closeTimePicker.picker selectRow:hourRow inComponent:0 animated:NO];
                [_closeTimePicker.picker selectRow:minRow inComponent:1 animated:NO];
                [_closeTimePicker showInView:self.view.window];
                
            }
                break;
            case TimerSetting_RepeatType: {
//                MHACCrontabRepeatType* repeatTypeVC = [[MHACCrontabRepeatType alloc] initWithCrontab:nil];
                MHLuTimerRepeatTypeVC* repeatTypeVC = [[MHLuTimerRepeatTypeVC alloc] initWithTimer:_timer];
                [self.navigationController pushViewController:repeatTypeVC animated:YES];
            }
                break;
            default:
                break;
        }
    }
    else {
        MHACPartnerPreferencesViewController *preferencesVC = [[MHACPartnerPreferencesViewController alloc] initWithTimer:self.isAddNewTimer ? nil : self.timer andAcpartner:self.acpartner];
        [self.navigationController pushViewController:preferencesVC animated:YES];
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0f;
}


//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, 40.0f)];
//    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, WIN_WIDTH - 70, 30)];
//    detailLabel.textAlignment = NSTextAlignmentLeft;
//    detailLabel.font = [UIFont systemFontOfSize:14.f];
//    detailLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
//    [header addSubview:detailLabel];
//    return header;
//}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_settings count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_settings[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        MHLumiAccessSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:TimerSettingCellId];
        if (!cell) {
            cell = [[MHLumiAccessSettingCell alloc] initWithReuseIdentifier:TimerSettingCellId];
        }
        [self configCell:cell withSettingIndex:(TimerSetting)indexPath.row];
        return cell;
    }
    else {
        MHLumiAccessSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:TimerPreferencesSettingCellId];
        if (!cell) {
            cell = [[MHLumiAccessSettingCell alloc] initWithReuseIdentifier:TimerPreferencesSettingCellId];
        }
        NSArray *temp = _settings[indexPath.section];
        [self configCell:cell withSettingIndex:(TimerSetting)[temp[indexPath.row] integerValue]];
        return cell;
    }
    
    
}


- (void)configCell:(MHLumiSettingCell *)cell withSettingIndex:(TimerSetting)index {
    MHLumiSettingCellItem *item = [[MHLumiSettingCellItem alloc] init];
    item.lumiType = MHLumiSettingItemTypeAccess;
    item.hasAcIndicator = YES;
    item.customUI = YES;
    item.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(100), SettingAccessoryKey_CaptionFontSize : @(14), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13), SettingAccessoryKey_CommentFontColor : [MHColorUtils colorWithRGB:0x5f5f5f]}];
    
    switch (index) {
        case TimerSetting_RepeatType: {
            NSString* strRepeat = nil;
            if (_timer.onRepeatType == MHDeviceTimerRepeat_Once) {
                strRepeat = NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.once",@"plugin_gateway","执行一次");
            }
            else if (_timer.onRepeatType == MHDeviceTimerRepeat_Workday){
                strRepeat = NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.workday",@"plugin_gateway","周一到周五");
            }
            else {
                strRepeat = [_timer getOnRepeatTypeString];
            }
            item.caption = NSLocalizedStringFromTable(@"mydevice.timersetting.repeat",@"plugin_gateway","重复");
            item.comment = strRepeat;
        }
            break;
        case TimerSetting_OpenTime: {
            item.caption = NSLocalizedStringFromTable(@"mydevice.timersetting.on",@"plugin_gateway","开启时间");
            item.comment = [_timer getOnTimeString];
        }
            break;
            
        case TimerSetting_CloseTime: {
            item.caption = NSLocalizedStringFromTable(@"mydevice.timersetting.off",@"plugin_gateway","关闭时间");
            item.comment = [_timer getOffTimeString];
        }
            break;
        default:
            break;
    }
    NSLog(@"%@", item.comment);
    [cell fillWithItem:item];
}

@end
