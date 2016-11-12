//
//  MHLuTimerDetailViewController.m
//  MiHome
//
//  Created by Lynn on 10/16/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLuTimerDetailViewController.h"
#import "MHLuTimerRepeatTypeVC.h"

#import "MHGatewayTimerOnOffTimeSettingCell.h"
#import "MHDeviceSettingDefaultCell.h"
#import "MHStrongBox.h"
#import "MHGatewayAlarmClockTimerTools.h"
#import "MHGatewayTimerPicker.h"
#import "MHGatewayLegSettingCell.h"

#define TimerModifyAbortAVTag       21000
#define TimerModifyDeleteAVTag      21001
#define TimerAddAbortAVTag          21002

#define TimerSettingCellId @"MHGatewayTimerOnOffTimeSettingCell"
#define RepeatTypeCellId   @"MHGatewayLegSettingCell"
//实现UIPickerView循环用
#define TimerPickerMultiply         200
#define TimerPickerInitPosition     100


typedef enum : NSInteger {
    TimerSetting_RepeatType,
    TimerSetting_OpenTime,
    TimerSetting_CloseTime,
}   TimerSetting;

@interface MHLuTimerDetailViewController ()

@property (nonatomic, strong) MHDataDeviceTimer *timer;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *pickerTitle;

@property (nonatomic, strong) MHGatewayTimerPicker *openTimePicker;
@property (nonatomic, strong) MHGatewayTimerPicker *closeTimePicker;

@end

@implementation MHLuTimerDetailViewController {
    MHDataDeviceTimer*      _oldTimer;      //timer copy，用来退出时做比较，判断是否修改过
    BOOL                    _isAddNewTimer; //是否为创建Timer
    
    
    NSArray*                _settings;

}

- (id)initWithTimer:(MHDataDeviceTimer* )timer {
    if (self = [super init]) {
        if (!timer) {
            _isAddNewTimer = YES;
            [self initTimerWithCurrentTime];
        } else {
            _timer = timer;
        }
        _oldTimer = [_timer copy];
        
        _settings = [NSArray arrayWithObjects:
                     @(TimerSetting_RepeatType),
                     @(TimerSetting_OpenTime),
                     @(TimerSetting_CloseTime),nil];
    }
    return self;
}

- (id)initWithTimer:(MHDataDeviceTimer *)timer andIdentifier:(NSString *)identifier {
    if (self = [super init]) {
        if (!timer) {
            _isAddNewTimer = YES;
            [self initTimerWithCurrentTime];
        } else {
            _timer = timer;
        }
        _oldTimer = [_timer copy];
        
        _settings = [NSArray arrayWithObjects:
                     @(TimerSetting_RepeatType),
                     @(TimerSetting_OpenTime),
                     @(TimerSetting_CloseTime),nil];
    }
    return self;

}

- (void)dealloc {
    NSLog(@"ddd");
}

- (void)initTimerWithCurrentTime {
    if (!_timer) {
        _timer = [[MHDataDeviceTimer alloc] init];
        _timer.isOnOpen = NO;
        _timer.isOffOpen = NO;
        NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
        NSDateComponents* comps = [calendar components:unitFlags fromDate:[NSDate date]];
        _timer.onHour = _timer.offHour = [comps hour];
        _timer.onMinute = _timer.offMinute = [comps minute];
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
//    [_openTimePicker addObserver:self forKeyPath:@"alpha" options:NSKeyValueObservingOptionNew context:nil];
//    [_closeTimePicker addObserver:self forKeyPath:@"alpha" options:NSKeyValueObservingOptionNew context:nil];

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
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
//    [_tableView registerClass:[MHDeviceSettingDefaultCell class] forCellReuseIdentifier:RepeatTypeCellId];
//    [_tableView registerClass:[MHGatewayTimerOnOffTimeSettingCell class] forCellReuseIdentifier:TimerSettingCellId];

    
//    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_tableView];
    

    XM_WS(weakself);
    _openTimePicker = [[MHGatewayTimerPicker alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.timersetting.on",@"plugin_gateway","开启时间") timePicked:^(NSUInteger hour, NSUInteger minute) {
        weakself.timer.onHour = hour % 24;
        weakself.timer.onMinute = minute % 60;
        weakself.timer.isOnOpen = YES;
        weakself.openTimePicker.pickerTitle.text = [[MHGatewayAlarmClockTimerTools sharedInstance] fetchTimeSpace:weakself.timer andIdentifier:NextIdentifierOn];
        [weakself.tableView reloadData];
    }];
    _openTimePicker.pickerTitle.text = [[MHGatewayAlarmClockTimerTools sharedInstance] fetchTimeSpace:weakself.timer andIdentifier:NextIdentifierOn];

    
    _closeTimePicker = [[MHGatewayTimerPicker alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.timersetting.off",@"plugin_gateway","关闭时间") timePicked:^(NSUInteger hour, NSUInteger minute) {
        weakself.timer.offHour = hour % 24;
        weakself.timer.offMinute = minute % 60;
        weakself.timer.isOffOpen = YES;
        weakself.closeTimePicker.pickerTitle.text = [[MHGatewayAlarmClockTimerTools sharedInstance] fetchTimeSpace:weakself.timer andIdentifier:NextIdentifierOff];
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
    
    switch ((TimerSetting)indexPath.row) {
        case TimerSetting_OpenTime: {
            NSInteger hourRow = TimerPickerInitPosition*24+_timer.onHour;
            NSInteger minRow = TimerPickerInitPosition*24+_timer.onMinute;
            [_openTimePicker.picker selectRow:hourRow inComponent:0 animated:NO];
            [_openTimePicker.picker selectRow:minRow inComponent:1 animated:NO];
            [_openTimePicker showInView:self.view.window];

        }
            break;
        case TimerSetting_CloseTime: {
            NSInteger hourRow = TimerPickerInitPosition*24+_timer.offHour;
            NSInteger minRow = TimerPickerInitPosition*24+_timer.offMinute;
            [_closeTimePicker.picker selectRow:hourRow inComponent:0 animated:NO];
            [_closeTimePicker.picker selectRow:minRow inComponent:1 animated:NO];
            [_closeTimePicker showInView:self.view.window];

        }
            break;
        case TimerSetting_RepeatType: {
            MHLuTimerRepeatTypeVC* repeatTypeVC = [[MHLuTimerRepeatTypeVC alloc] initWithTimer:_timer];
            [self.navigationController pushViewController:repeatTypeVC animated:YES];
        }
            break;
        default:
            break;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_settings count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        MHGatewayLegSettingCell* cell = [tableView dequeueReusableCellWithIdentifier:RepeatTypeCellId];
        if (cell == nil) {
            cell = [[MHGatewayLegSettingCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:RepeatTypeCellId];
        }
        [self configRepeatTypeCell:cell];
        return cell;
    }
    else {
        XM_WS(weakself);
        MHGatewayTimerOnOffTimeSettingCell* cell = [tableView dequeueReusableCellWithIdentifier:TimerSettingCellId];
        if (cell == nil) {
            cell = [[MHGatewayTimerOnOffTimeSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimerSettingCellId];
        }
        switch (indexPath.row) {
            case TimerSetting_OpenTime:
                [cell configIdentifier:ItemIdentifierOn withTimer:_timer];
                break;
            case TimerSetting_CloseTime:
                [cell configIdentifier:ItemIdentifierOff withTimer:_timer];
                break;
            default:
                break;
        }
        cell.cleanCallBack = ^(NSString *itemIdentifier){
            if ([ItemIdentifierOn isEqualToString:itemIdentifier]) {
                weakself.timer.isOnOpen = NO;
                [weakself.tableView reloadData];
            }
            else {
                weakself.timer.isOffOpen = NO;
                [weakself.tableView reloadData];
            }
        };
        return cell;
    }
}



- (void)configRepeatTypeCell:(MHGatewayLegSettingCell *)cell {
    MHGatewaySettingCellItem* item = [[MHGatewaySettingCellItem alloc] init];
    item.type = MHGatewaySettingItemTypeLeg;
    item.hasAcIndicator = YES;
    item.customUI = YES;
    item.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(100), SettingAccessoryKey_CaptionFontSize : @(14), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13), SettingAccessoryKey_CommentFontColor : [MHColorUtils colorWithRGB:0x5f5f5f]}];
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
    cell.gatewayItem = item;
}


@end