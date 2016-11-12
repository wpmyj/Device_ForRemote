//
//  MHACPartnerTimerDetailViewController.m
//  MiHome
//
//  Created by ayanami on 16/5/20.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerTimerDetailViewController.h"
#import "MHLuTimerRepeatTypeVC.h"
#import "MHGatewayTimerPicker.h"
#import "MHStrongBox.h"
#import "MHGatewayAlarmClockTimerTools.h"
#import "MHLumiAccessSettingCell.h"
#import "MHLumiDefaultSettingCell.h"
#import "MHACPartnerPreferencesViewController.h"
#import "MHACPartnerTimerPicker.h"

#define TimerSettingCellId                  @"MHLumiAccessSettingCell"
#define TimerPreferencesSettingCellId       @"MHLumiDefaultSettingCell"

#define TimerModifyAbortAVTag       21000
#define TimerModifyDeleteAVTag      21001
#define TimerAddAbortAVTag          21002

typedef enum : NSInteger {
    TimerSetting_RepeatType,
    TimerSetting_OpenTime,
    TimerSetting_CloseTime,
    TimerSetting_Preferences,
}   TimerSetting;

@interface MHACPartnerTimerDetailViewController ()

@property (nonatomic, strong) MHACPartnerTimerPicker *openTimePicker;
@property (nonatomic, strong) MHACPartnerTimerPicker *closeTimePicker;

@property (nonatomic, strong) MHDataDeviceTimer *timer;
@property (nonatomic, strong) MHDataDeviceTimer *oldTimer;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic,strong) MHDeviceAcpartner *acpartner;
@property (nonatomic, assign) BOOL isAddNewTimer;

@end

@implementation MHACPartnerTimerDetailViewController{
    
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
            if (timer.isOnOpen && timer.isOffOpen) {
                [acpartner analyzeHexInfo:nil decimalInfo:[[timer.onParam firstObject] intValue] type:PROP_TIMER];
            }
            else if (timer.isOnOpen && !timer.isOffOpen) {
                [acpartner analyzeHexInfo:nil decimalInfo:[[timer.onParam firstObject] intValue] type:PROP_TIMER];
                
            }
            else if (!timer.isOnOpen && timer.isOffOpen) {
                [acpartner analyzeHexInfo:nil decimalInfo:[[timer.offParam firstObject] intValue] type:PROP_TIMER];
                
            }
        }
        _oldTimer = [_timer copy];
        NSArray *timespan = [NSArray arrayWithObjects:
                     @(TimerSetting_RepeatType),
                     @(TimerSetting_OpenTime),
                     @(TimerSetting_CloseTime),nil];
        
        if (acpartner.ACType == 2 || acpartner.ACType == 3) {
            NSArray *preferences = @[ @(TimerSetting_Preferences) ];
            _settings = [NSArray arrayWithObjects:timespan, preferences, nil];
        }
        else {
            _settings = [NSArray arrayWithObjects:timespan, nil];
        }
    }
    return self;
}


- (void)initTimerWithCurrentTime {
    if (!_timer) {
        _timer = [[MHDataDeviceTimer alloc] init];
        _timer.onRepeatType = MHDeviceTimerRepeat_Everyday;
        _timer.onHour = 19;
        _timer.offHour = 8;
        _timer.onMinute = _timer.offMinute = 0;
        _timer.offRepeatType = MHDeviceTimerRepeat_Everyday;

        self.acpartner.timerACType = self.acpartner.ACType;
        self.acpartner.timerModeState = 0;
        self.acpartner.timerTemperature = 26;
        self.acpartner.timerWindPower = 3;
        self.acpartner.timerWindDirection = 0;
        self.acpartner.timerWindState = 1;
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
    
    self.title = NSLocalizedStringFromTable(@"mydevice.timersetting.title",@"plugin_gateway","设置定时");
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
    _openTimePicker = [[MHACPartnerTimerPicker alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.timersetting.on",@"plugin_gateway","开启时间") timePicked:^(NSUInteger hour, NSUInteger minute) {
        weakself.timer.onHour = hour % 24;
        weakself.timer.onMinute = minute % 60;
        weakself.timer.isOnOpen = YES;
        weakself.openTimePicker.pickerTitle.text = [[MHGatewayAlarmClockTimerTools sharedInstance] fetchTimeSpace:weakself.timer andIdentifier:NextIdentifierOn];
        [weakself.tableView reloadData];
    }];
    [_openTimePicker setOnOk:^{
        weakself.timer.isOnOpen = YES;
        [weakself.tableView reloadData];
        
    }];
    [_openTimePicker setOnClear:^{
        weakself.timer.isOnOpen = NO;
        [weakself.tableView reloadData];
    }];
    _openTimePicker.pickerTitle.text = [[MHGatewayAlarmClockTimerTools sharedInstance] fetchTimeSpace:weakself.timer andIdentifier:NextIdentifierOn];
    
    _closeTimePicker = [[MHACPartnerTimerPicker alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.timersetting.off",@"plugin_gateway","关闭时间") timePicked:^(NSUInteger hour, NSUInteger minute) {
        weakself.timer.offHour = hour % 24;
        weakself.timer.offMinute = minute % 60;
        weakself.timer.isOffOpen = YES;
        weakself.closeTimePicker.pickerTitle.text = [[MHGatewayAlarmClockTimerTools sharedInstance] fetchTimeSpace:weakself.timer andIdentifier:NextIdentifierOff];
        [weakself.tableView reloadData];
    }];
    [_closeTimePicker setOnOk:^{
        weakself.timer.isOffOpen = YES;
        [weakself.tableView reloadData];
    }];
    [_closeTimePicker setOnClear:^{
        weakself.timer.isOffOpen = NO;
        [weakself.tableView reloadData];
    }];
    _closeTimePicker.pickerTitle.text = [[MHGatewayAlarmClockTimerTools sharedInstance] fetchTimeSpace:weakself.timer andIdentifier:NextIdentifierOff];
    
    
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
    if (self.acpartner.brand_id == 0 || self.acpartner.ACType == 0) {
            [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.first",@"plugin_gateway", "请先添加空调") duration:1.5f modal:NO];
            return;
    }
    
    if (!_timer.isOnOpen && !_timer.isOffOpen) {
        if (_isAddNewTimer) {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.timersetting.abort.title",@"plugin_gateway","您还未设置时间") message:NSLocalizedStringFromTable(@"mydevice.timersetting.abort.message",@"plugin_gateway","确认放弃本次操作？") delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"plugin_gateway","取消") otherButtonTitles:NSLocalizedStringFromTable(@"Ok",@"plugin_gateway", "确定"), nil];
            alertView.tag = TimerAddAbortAVTag;
            [alertView show];

            return;
        } else {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.timersetting.del.title",@"plugin_gateway","您已关闭全部定时设置项") message:NSLocalizedStringFromTable(@"mydevice.timersetting.del.message",@"plugin_gateway","本条定时将被删除？") delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway", "取消") otherButtonTitles:NSLocalizedStringFromTable(@"Ok",@"plugin_gateway", "确定"), nil];
            alertView.tag = TimerModifyDeleteAVTag;
            [alertView show];
            return;
        }
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


- (void)onSwitchOpenClose:(BOOL)on cellIndex:(NSInteger)index {
    if (index == 1) {
        _timer.isOnOpen = on;
    } else if (index == 2) {
        _timer.isOffOpen = on;
    }
}


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
                [self gw_clickMethodCountWithStatType:@"editOpenTime:"];
            }
                break;
            case TimerSetting_CloseTime: {
                NSInteger hourRow = TimerPickerInitPosition * 24+ _timer.offHour;
                NSInteger minRow = TimerPickerInitPosition * 24 +  _timer.offMinute;
                [_closeTimePicker.picker selectRow:hourRow inComponent:0 animated:NO];
                [_closeTimePicker.picker selectRow:minRow inComponent:1 animated:NO];
                [_closeTimePicker showInView:self.view.window];
                [self gw_clickMethodCountWithStatType:@"editCloseTime:"];
                
            }
                break;
            case TimerSetting_RepeatType: {
                MHLuTimerRepeatTypeVC* repeatTypeVC = [[MHLuTimerRepeatTypeVC alloc] initWithTimer:_timer];
                [self.navigationController pushViewController:repeatTypeVC animated:YES];
                [self gw_clickMethodCountWithStatType:@"openTimerRepeatPage:"];
            }
                break;
            default:
                break;
        }
    }
    else {
        MHACPartnerPreferencesViewController *preferencesVC = [[MHACPartnerPreferencesViewController alloc] initWithTimer:self.timer andAcpartner:self.acpartner];
        [self.navigationController pushViewController:preferencesVC animated:YES];
        [self gw_clickMethodCountWithStatType:@"openTimerWorkTypePage:"];
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0f;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, 40.0f)];
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, WIN_WIDTH - 70, 30)];
    detailLabel.textAlignment = NSTextAlignmentLeft;
    detailLabel.font = [UIFont systemFontOfSize:14.f];
    detailLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    if (section == 0) {
        detailLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.timer.timespan",@"plugin_gateway","开启时段");
        
    }
    else {
//        detailLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.settings",@"plugin_gateway","空调偏好设置");
        detailLabel.text = nil;
    }
    [header addSubview:detailLabel];
    return header;
}


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
        case TimerSetting_Preferences: {
            item.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.setting.type",@"plugin_gateway","工作方式");
        }
            break;
            
        default:
            break;
    }
    NSLog(@"%@", item.comment);
    [cell fillWithItem:item];

}



#pragma mark - MHGatewayLightColorSettingCellDelegate

@end
