//
//  MHGatewayLightTimerDetailViewController.m
//  MiHome
//
//  Created by guhao on 16/1/15.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayLightTimerDetailViewController.h"
#import "MHLuTimerRepeatTypeVC.h"

#import "MHDeviceSettingDefaultCell.h"
#import "MHGatewayLightColorSettingCell.h"
#import "MHGatewayTimerPicker.h"
#import "MHStrongBox.h"
#import "MHGatewayAlarmClockTimerTools.h"
#import "MHGatewayTimerOnOffTimeSettingCell.h"
#import "MHGatewayLegSettingCell.h"
#import "MHGatewayVolumeSettingCell.h"

#define TimerModifyAbortAVTag       21000
#define TimerModifyDeleteAVTag      21001
#define TimerAddAbortAVTag          21002

#define TimerSettingCellId                  @"MHGatewayTimerOnOffTimeSettingCell"
#define TimerRepeatTypeSettingCellId        @"MHGatewayLegSettingCell"
#define TimerColorTypeSettingCellId         @"MHGatewayLightColorSettingCell"
#define TimerBrightnessTypeSettingCellId    @"MHGatewayVolumeSettingCell"

//实现UIPickerView循环用
#define TimerPickerMultiply         200
#define TimerPickerInitPosition     100

#define kRomantic NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.scenes.romantic",@"plugin_gateway", "romantic")
#define kPink     NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.scenes.pink", @"plugin_gateway","pink")
#define kGolden   NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.scenes.golden", @"plugin_gateway","golden")
#define kWhite    NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.scenes.white", @"plugin_gateway","white")
#define kForest   NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.scenes.forest",@"plugin_gateway", "forest")
#define kBlue     NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.scenes.charmblue", @"plugin_gateway","blue")

static NSDictionary *colorViewsSences = nil;
static NSDictionary *colorNumber = nil;
//736847991, 738187008, 721485695, 731119827, 722010362, 729666288
static NSDictionary *colorString = nil;

#define NightTimerDefaultOnHour   20
#define NightTimerDefaultOffHour  23

typedef enum : NSInteger {
    TimerSetting_RepeatType,
    TimerSetting_OpenTime,
    TimerSetting_CloseTime,
    TimerSetting_ColorType,
    TimerSetting_BrightnessType,
}   TimerSetting;

@interface MHGatewayLightTimerDetailViewController () <MHGatewayLightColorSettingCellDelegate> 

@property (nonatomic, assign) BOOL isAddNewTimer;

@property (nonatomic, strong) MHGatewayTimerPicker *openTimePicker;
@property (nonatomic, strong) MHGatewayTimerPicker *closeTimePicker;

@property (nonatomic, strong) MHDataDeviceTimer *timer;
@property (nonatomic, strong) MHDataDeviceTimer *oldTimer;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) MHDeviceGateway *gateway;
@property (nonatomic, strong) NSNumber *nightColor;

@property (nonatomic, assign) NSInteger originalRGB; //记录网关彩灯的初始状态

@end

@implementation MHGatewayLightTimerDetailViewController {
    NSArray*                _settings;
}

- (id)initWithTimer:(MHDataDeviceTimer* )timer andGatewayDevice:(MHDeviceGateway *)device {
    if (self = [super init]) {
        colorViewsSences = @{ kRomantic:@(0x2b9400d3), kPink:@(0x2beb6877), kGolden:@(0x2bffd700), kBlue:@(0x2b0900fa), kForest:@(0x2b00ff7f), kWhite:@(0x2b7dd2f0) };
        colorNumber =  @{ @(0x2beb6877):kPink, @(0x2bffd700):kGolden, @(0x2b00ff7f):kForest,@(0x2b9400d3):kRomantic, @(0x2b7dd2f0):kWhite, @(0x2b0900fa):kBlue };
        colorString =  @{ @"736847991":kPink, @"738187008":kGolden, @"721485695":kForest, @"731119827":kRomantic, @"722010362":kBlue, @"729666288":kWhite };
        
        _gateway = device;
        _originalRGB = _gateway.rgb;
        if (!timer) {
            _isAddNewTimer = YES;
            [self initTimerWithCurrentTime];
        } else {
            _timer = timer;
            if ([_timer.onParam[0] isKindOfClass:[NSString class]]) {
                if ([_timer.onParam[0] isEqualToString:@"on"]) {
                    self.nightColor = colorViewsSences[kRomantic];
                }
                else {
                    self.nightColor = colorViewsSences[colorString[_timer.onParam[0]]];
                }
            }
            else {
                self.nightColor = _timer.onParam[0];
            }
        }
        _oldTimer = [_timer copy];
        _settings = [NSArray arrayWithObjects:
                     @(TimerSetting_RepeatType),
                     @(TimerSetting_OpenTime),
                     @(TimerSetting_CloseTime),
                     @(TimerSetting_ColorType),nil];
    }
    return self;
}

- (void)initTimerWithCurrentTime {
    if (!_timer) {
        _timer = [[MHDataDeviceTimer alloc] init];
        NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
        NSDateComponents* comps = [calendar components:unitFlags fromDate:[NSDate date]];
                _timer.onHour = _timer.offHour = [comps hour];
                _timer.onMinute = _timer.offMinute = [comps minute];
//        _timer.onHour = NightTimerDefaultOnHour;
//        _timer.offHour = NightTimerDefaultOffHour;
//        _timer.onMinute = _timer.offMinute = 0;
        _timer.isOnOpen = NO;
        _timer.isOffOpen = NO;
        if ([_timer.onParam[0] isKindOfClass:[NSString class]]) {
            if ([_timer.onParam[0] isEqualToString:@"on"]) {
                self.nightColor = colorViewsSences[kRomantic];
                _timer.onParam = @[ @(0x2b9400d3) ];
            }
        }
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
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
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
//    NSLog(@"%@, %@", _timer.onParam[0], _oldTimer.onParam[0]);
//    NSLog(@"%@", self.nightColor);
//    NSLog(@"%@", colorString[[_oldTimer.onParam[0] stringValue]]);
//    NSLog(@"%@", colorViewsSences[colorString[[_oldTimer.onParam[0] stringValue]]]);
    if (![_timer isEqualWithTimer:_oldTimer] || ![self.nightColor isEqualToNumber:colorViewsSences[colorString[[_oldTimer.onParam[0] stringValue]]]]) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.timersetting.cancel.tips",@"plugin_gateway","要舍弃对该定时的修改吗？") message:nil delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"plugin_gateway","取消") otherButtonTitles:NSLocalizedStringFromTable(@"Ok", @"plugin_gateway","确定"), nil];
        alertView.tag = TimerModifyAbortAVTag;
        [alertView show];
        return;
    }
    //退出设置界面时,恢复网关彩灯的状态
    [self.gateway setProperty:RGB_INDEX value:@(self.originalRGB) success:^(id v) {
        
    } failure:^(NSError *v) {
        
    }];

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
    //退出设置界面时,恢复网关彩灯的状态
    [self.gateway setProperty:RGB_INDEX value:@(self.originalRGB) success:^(id v) {
        
    } failure:^(NSError *v) {
//        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"send.failed",@"plugin_gateway", nil) duration:1.5f modal:YES];
    }];
    
    [_timer updateTimerMonthAndDayForRepeatOnceType];
       if (_onDone) {
        _onDone(_timer, self.nightColor);
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
                //退出设置界面时,恢复网关彩灯的状态
                [self.gateway setProperty:RGB_INDEX value:@(self.originalRGB) success:^(id v) {
                    
                } failure:^(NSError *v) {

                }];
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
                    _onDone(_timer, self.nightColor);
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
    if (indexPath.row == TimerSetting_ColorType) {
        return 120;
    }
    else if (indexPath.row == TimerSetting_BrightnessType) {
        return 70;
    }
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == TimerSetting_ColorType) {
        
    }
    else {
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
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_settings count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == TimerSetting_RepeatType) {
        MHGatewayLegSettingCell* cell = [tableView dequeueReusableCellWithIdentifier:TimerRepeatTypeSettingCellId];
        if (!cell) {
            cell = [[MHGatewayLegSettingCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TimerRepeatTypeSettingCellId];
        }
        [self configCell:cell withSettingIndex:(TimerSetting)indexPath.row];
        return cell;
    }
    else if (indexPath.row == TimerSetting_ColorType) {
        MHGatewayLightColorSettingCell * cell = [tableView dequeueReusableCellWithIdentifier:TimerColorTypeSettingCellId];
        if (!cell) {
            cell = [[MHGatewayLightColorSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimerColorTypeSettingCellId];
        }
        cell.delegate = self;
        [cell configureWithDataObject:_timer.onParam];
        return cell;
    }
    else {
        XM_WS(weakself);
        MHGatewayTimerOnOffTimeSettingCell* cell = [tableView dequeueReusableCellWithIdentifier:TimerSettingCellId];
        if (cell == nil) {
            cell = [[MHGatewayTimerOnOffTimeSettingCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:TimerSettingCellId];
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


- (void)configCell:(MHGatewayLegSettingCell* )cell withSettingIndex:(TimerSetting)index {
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



#pragma mark - MHGatewayLightColorSettingCellDelegate
- (void)didSelectedColorName:(NSString *)colorname {
    self.nightColor = colorViewsSences[colorname];
    [self.gateway setProperty:RGB_INDEX value:self.nightColor success:^(id v) {
    } failure:^(NSError *v) {
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"send.failed",@"plugin_gateway", nil) duration:1.5f modal:YES];
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
