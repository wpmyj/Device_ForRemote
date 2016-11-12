//
//  MHGatewayLightTimeSettingViewController.m
//  MiHome
//
//  Created by guhao on 4/13/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayLightTimeSettingViewController.h"
#import "MHLuTimerRepeatTypeVC.h"

#import "MHGatewayTimerOnOffTimeSettingCell.h"
#import "MHDeviceSettingDefaultCell.h"
#import "MHStrongBox.h"
#import "MHGatewayAlarmClockTimerTools.h"
#import "MHGatewayTimerPicker.h"

#define TimerModifyAbortAVTag       21000
#define TimerModifyDeleteAVTag      21001
#define TimerAddAbortAVTag          21002

#define TimerSettingCellId @"MHGatewayTimerOnOffTimeSettingCell"
//实现UIPickerView循环用
#define TimerPickerMultiply         200
#define TimerPickerInitPosition     100


#define kNOTSET 1022419

typedef enum : NSInteger {
    TimerSetting_OpenTime,
    TimerSetting_CloseTime,
}   TimerSetting;

@interface MHGatewayLightTimeSettingViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *pickerTitle;

@property (nonatomic, strong) MHGatewayTimerPicker *openTimePicker;
@property (nonatomic, strong) MHGatewayTimerPicker *closeTimePicker;
@property (nonatomic, assign) NSInteger onHour;     //开启时间：时
@property (nonatomic, assign) NSInteger onMinute;   //开启时间：分

@property (nonatomic, assign) NSInteger offHour;    //关闭时间：时
@property (nonatomic, assign) NSInteger offMinute;  //关闭时间：分

@property (nonatomic, copy) NSArray *timer;

@end

@implementation MHGatewayLightTimeSettingViewController {
    
    NSArray *_settings;
    NSArray *_oldTimer;
    
}

- (id)initWithTimer:(NSArray *)timer andIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        if (timer.count >= 4) {
            self.onHour = [timer[0] integerValue];
            self.onMinute = [timer[1] integerValue];
            self.offHour = [timer[2] integerValue];
            self.offMinute = [timer[3] integerValue];
        }
        _timer = timer;
        _oldTimer = [_timer copy];
        _settings = @[ @(TimerSetting_OpenTime), @(TimerSetting_CloseTime) ];
    }
    return self;
}



- (void)dealloc {
    NSLog(@"ddd");
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [_tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


- (void)buildSubviews {
    [super buildSubviews];
    
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.motion.workTime",@"plugin_gateway","感应时段");
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
        weakself.onHour = hour % 24;
        weakself.onMinute = minute % 60;
        weakself.timer = @[ @(weakself.onHour), @(weakself.onMinute), @(weakself.offHour), @(weakself.offMinute) ];
        [weakself.tableView reloadData];
    }];
    _openTimePicker.pickerTitle.text = NSLocalizedStringFromTable(@"mydevice.timersetting.on",@"plugin_gateway","开启时间");
    
    
    _closeTimePicker = [[MHGatewayTimerPicker alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.timersetting.off",@"plugin_gateway","关闭时间") timePicked:^(NSUInteger hour, NSUInteger minute) {
        weakself.offHour = hour % 24;
        weakself.offMinute = minute % 60;
        weakself.timer = @[ @(weakself.onHour), @(weakself.onMinute), @(weakself.offHour), @(weakself.offMinute) ];
        [weakself.tableView reloadData];
    }];
    _closeTimePicker.pickerTitle.text = NSLocalizedStringFromTable(@"mydevice.timersetting.off",@"plugin_gateway","关闭时间");
    
}

#pragma mark - 按钮消息
- (void)onBack:(id)sender {
    if (![self.timer isEqual:_oldTimer]) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.timersetting.cancel.tips",@"plugin_gateway","要舍弃对该定时的修改吗？") message:nil delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"plugin_gateway","取消") otherButtonTitles:NSLocalizedStringFromTable(@"Ok", @"plugin_gateway","确定"), nil];
        alertView.tag = TimerModifyAbortAVTag;
        [alertView show];
        return;
    }

    [super onBack:sender];
}

- (void)onDone:(id)sender {
    if (self.onHour == kNOTSET || self.offHour == kNOTSET) {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.timersetting.abort.title",@"plugin_gateway","您还未设置时间") message:NSLocalizedStringFromTable(@"mydevice.timersetting.abort.message",@"plugin_gateway","确认放弃本次操作？") delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"plugin_gateway","取消") otherButtonTitles:NSLocalizedStringFromTable(@"Ok",@"plugin_gateway", "确定"), nil];
            alertView.tag = TimerAddAbortAVTag;
            [alertView show];
            return;
        }
    if (self.onHour == self.offHour && self.onMinute == self.offMinute && self.onHour != 0) {
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.timersetting.invalid",@"plugin_gateway","您设置的开关时间相同，请重新设置") duration:1.0 modal:NO];
        return;
    }
    if (_onDone) {
        _onDone(self.timer);
    }
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == TimerModifyAbortAVTag) {
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
                //舍弃对该定时的修改
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
            NSInteger hourRow = TimerPickerInitPosition*24+ self.onHour;
            NSInteger minRow = TimerPickerInitPosition*24+ self.onMinute;
            [_openTimePicker.picker selectRow:hourRow inComponent:0 animated:NO];
            [_openTimePicker.picker selectRow:minRow inComponent:1 animated:NO];
            [_openTimePicker showInView:self.view.window];
            
        }
            break;
        case TimerSetting_CloseTime: {
            NSInteger hourRow = TimerPickerInitPosition * 24 + self.offHour;
            NSInteger minRow = TimerPickerInitPosition * 24 + self.offMinute;
            [_closeTimePicker.picker selectRow:hourRow inComponent:0 animated:NO];
            [_closeTimePicker.picker selectRow:minRow inComponent:1 animated:NO];
            [_closeTimePicker showInView:self.view.window];
            
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
        XM_WS(weakself);
        MHGatewayTimerOnOffTimeSettingCell* cell = [tableView dequeueReusableCellWithIdentifier:TimerSettingCellId];
        if (cell == nil) {
            cell = [[MHGatewayTimerOnOffTimeSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimerSettingCellId];
        }
    __weak MHGatewayTimerOnOffTimeSettingCell* weakCell = cell;
        cell.cleanCallBack = ^(NSString *itemIdentifier){
            if ([ItemIdentifierOn isEqualToString:itemIdentifier]) {
                [weakCell configIdentifier:ItemIdentifierOn withTime:@[  ]];
                weakself.onHour = kNOTSET;
                weakself.onMinute = kNOTSET;
                weakself.timer = @[ @(weakself.onHour), @(weakself.onMinute), @(weakself.offHour), @(weakself.offMinute) ];
            }
            else {
                [weakCell configIdentifier:ItemIdentifierOff withTime:@[  ]];
                weakself.offHour = kNOTSET;
                weakself.offMinute = kNOTSET;
                weakself.timer = @[ @(weakself.onHour), @(weakself.onMinute), @(weakself.offHour), @(weakself.offMinute) ];
            }
        };
    if (indexPath.row == 0) {
        [cell configIdentifier:ItemIdentifierOn withTime:@[ @(weakself.onHour), @(weakself.onMinute) ]];
    }
    else {
        [cell configIdentifier:ItemIdentifierOff withTime:@[ @(weakself.offHour), @(weakself.offMinute) ]];
    }
        return cell;
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
