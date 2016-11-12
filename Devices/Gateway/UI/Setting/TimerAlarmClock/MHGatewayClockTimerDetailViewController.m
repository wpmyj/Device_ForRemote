//
//  MHGatewayClockTimerDetailViewController.m
//  MiHome
//
//  Created by guhao on 4/8/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayClockTimerDetailViewController.h"
#import "MHLuTimerRepeatTypeVC.h"
#import "MHGatewayBellChooseViewController.h"
#import "MHGatewayBellChooseNewViewController.h"
#import "MHDeviceSettingDefaultCell.h"
#import "MHDeviceSettingVolumeCell.h"
#import "MHTimerPicker.h"
#import "MHStrongBox.h"
#import "MHGatewayAlarmClockTimerTools.h"
#import "MHGatewayVolumeSettingCell.h"
#import "MHGatewayLegSettingCell.h"
#import "MHGatewayClockBellChooseViewController.h"


#define TimerModifyAbortAVTag       21000
#define TimerAddAbortAVTag          21002

#define TimerSettingCellId @"TimerSettingCellId"

//实现UIPickerView循环用
#define TimerPickerMultiply         200
#define TimerPickerInitPosition     100

@interface MHGatewayClockTimerDetailViewController ()
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic, strong) MHDataDeviceTimer *timer;
@property (nonatomic, strong) MHDataDeviceTimer *oldTimer;      //timer copy，用来退出时做比较，判断是否修改过
@property (nonatomic, strong) UILabel *pickerTitle;

@property (nonatomic, strong) NSString *timerOnOff;
@property (nonatomic, strong) NSString *timerMusicIndex;
@property (nonatomic, assign) int timerVolume;
@property (nonatomic,strong) MHDeviceGateway *device;
@end

@implementation MHGatewayClockTimerDetailViewController {
    BOOL                    _isAddNewTimer; //是否为创建Timer
    
    
    NSMutableArray*         _settingItems;
    
    UIView*                 _pickerViewCanvas;
    MHTimerPicker*          _openTimePicker;
    
    int                     _clockDuration;
    NSMutableDictionary *   _callbackdic;
}

- (id)initWithTimer:(MHDataDeviceTimer* )timer andGatewayDevice:(MHDeviceGateway *)device {
    if (self = [super init]) {
        _device = device;
        [_device restoreGatewayDownloadList];
        if (!timer) {
            _isAddNewTimer = YES;
            [self initTimerWithCurrentTime];
        } else {
            _timer = timer;
            if ([timer.onMethod isEqualToString:@"play_specify_fm"]) {
                if (timer.onParam.count > 2) {
                    _timerMusicIndex = timer.onParam[0] ? [NSString stringWithFormat:@"%@", timer.onParam[1]] : @"20";
                    _timerVolume = [timer.onParam[1] intValue];
                    if (timer.onParam[2]) {
                       _timerOnOff = @"on";
                    }
                    else {
                        _timerOnOff = @"off";
                    }
                }
                if (timer.onParam.count == 2) {
                    _timerMusicIndex = timer.onParam[0] ? timer.onParam[1] : @"20";
                    _timerVolume = [timer.onParam[1] intValue];
                    _timerOnOff = @"off";
                }
            }
            else {
                if (timer.onParam.count > 2) {
                    _timerOnOff = timer.onParam[0];
                    _timerMusicIndex = timer.onParam[1] ? timer.onParam[1] : @"20";
                    _timerVolume = [timer.onParam[2] intValue];
                }
            }
            NSLog(@"音乐序号%@", _timerMusicIndex);
        }
        _oldTimer = [_timer copy];
    }
    return self;
}

- (void)initTimerWithCurrentTime {
    if (!_timer) {
        _timer = [[MHDataDeviceTimer alloc] init];
//        NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//        NSInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
//        NSDateComponents* comps = [calendar components:unitFlags fromDate:[NSDate date]];
        _timer.onHour = _timer.offHour = 8;
//        _timer.onHour = _timer.offHour = [comps hour];
        _timer.onMinute = _timer.offMinute = 0;
//        _timer.onMinute = _timer.offMinute = [comps minute];
        _timerVolume = (int)(self.device.clock_volume);
        _timerMusicIndex = @"20";
        _timerOnOff = @"on";
        _timer.onParam = @[ @"on", @"20", @(_timerVolume) ];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    XM_WS(weakself);
    //items
    _settingItems = [NSMutableArray arrayWithCapacity:1];
    {
        MHGatewaySettingCellItem* item = [[MHGatewaySettingCellItem alloc] init];
        item.customUI = YES;
        item.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(100), SettingAccessoryKey_CaptionFontSize : @(14), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13), SettingAccessoryKey_CommentFontColor : [MHColorUtils colorWithRGB:0x5f5f5f]}];
        item.type = MHGatewaySettingItemTypeLeg;
        item.hasAcIndicator = YES;
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
        [_settingItems addObject:item];
    }
    
    {
        __block MHGatewaySettingCellItem* item = [[MHGatewaySettingCellItem alloc] init];
        item.customUI = YES;
        item.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(100), SettingAccessoryKey_CaptionFontSize : @(14), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13), SettingAccessoryKey_CommentFontColor : [MHColorUtils colorWithRGB:0x5f5f5f]}];
        item.type = MHGatewaySettingItemTypeLeg;
        item.hasAcIndicator = YES;
        item.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmclock.tone",@"plugin_gateway","请选择闹钟铃声");
        
        int index = [_timerMusicIndex intValue];
        NSString *musicname = @"";
        //        if (index > 1000) musicname = [self.device fetchGwDownloadMidName:[NSString stringWithFormat:@"%d",index]];
        if (index > 1000) musicname = [self.device fetchGwDownloadMidName:_timerMusicIndex];
        else musicname = [MHDeviceGateway getBellNameOfGroup:(BellGroup)BellGroup_Welcome index:index % 10];
        item.comment = musicname;
        [_settingItems addObject:item];
    }
    
    {
        MHGatewaySettingCellItem *item = [[MHGatewaySettingCellItem alloc] init];
        //        item.identifier = @"mydevice.gateway.setting.volume.alarmclock";
        item.identifier = @"doorbell";
        item.type = MHGatewaySettingItemTypeVolume;
        item.caption = NSLocalizedStringFromTable(@"mydevice.gateway.setting.volume.alarmclock",@"plugin_gateway","闹钟音量");
        item.customUI = YES;
        item.accessories = [[MHStrongBox alloc] initWithDictionary:@{MinValue:@(0), MaxValue:@(100),CurValue:@(self.timerVolume), SettingAccessoryKey_CellHeight : @(70), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
        item.callbackBlock = ^(MHGatewaySettingCell *cell) {
            
            id volume = [cell.item.accessories valueForKey:CurValue class:[NSNumber class]];
            [weakself.device setProperty:CLOCK_VOLUME_INDEX value:volume success:^(id v){
                weakself.timerVolume = [volume intValue];
                weakself.timer.onParam = @ [ weakself.timerOnOff, weakself.timerMusicIndex, @(weakself.timerVolume) ];
                
                [cell finish];
                
            } failure:^(NSError *v) {
                [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
                [cell.item.accessories setValue:@(weakself.timerVolume) forKey:CurValue];
                [cell fillWithItem:cell.item];
                [cell finish];
            }];
        };
        
        [_settingItems addObject:item];
    }
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)buildSubviews {
    [super buildSubviews];
    
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmclock",@"plugin_gateway","懒人闹钟");
    self.isTabBarHidden = YES;
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 44, 26);
    [btn setBackgroundColor:[MHColorUtils colorWithRGB:0x1dc58a]];
    [btn setTitle:NSLocalizedStringFromTable(@"Ok",@"plugin_gateway", "确定") forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13.f];
    btn.layer.cornerRadius = 3.0f;
    [btn addTarget:self action:@selector(onDone:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    {
        CGRect rect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 260.f);
        _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = YES;
        self.automaticallyAdjustsScrollViewInsets = YES;
        [self.view addSubview:_tableView];
    }
    
    
    XM_WS(weakself);
    _openTimePicker = [[MHTimerPicker alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.timersetting.on",@"plugin_gateway","开启时间") timePicked:^(NSUInteger hour, NSUInteger minute) {
        weakself.timer.onHour = hour % 24;
        weakself.timer.onMinute = minute % 60;
        weakself.pickerTitle.text = [[MHGatewayAlarmClockTimerTools sharedInstance] fetchTimeSpace:weakself.timer andIdentifier:NextIdentifierOn];
        [weakself.tableView reloadData];
    }];
    
    {
        CGRect rect = CGRectMake(0, self.view.bounds.size.height - 260.f, self.view.bounds.size.width, 260.f);
        _pickerViewCanvas = [[UIView alloc] initWithFrame:rect];
        _pickerViewCanvas.backgroundColor = _tableView.backgroundColor;
        [self.view addSubview:_pickerViewCanvas];
        
        NSInteger hourRow = TimerPickerInitPosition * 24 + _timer.onHour;
        NSInteger minRow = TimerPickerInitPosition * 24 + _timer.onMinute;
        [_openTimePicker.picker selectRow:hourRow inComponent:0 animated:NO];
        [_openTimePicker.picker selectRow:minRow inComponent:1 animated:NO];
        [_pickerViewCanvas addSubview:_openTimePicker.picker];
    }
    
    CGRect labelRect = CGRectMake(0, self.view.bounds.size.height - 240.f, self.view.bounds.size.width, 50.f);
    _pickerTitle = [[UILabel alloc] initWithFrame:labelRect];
    _pickerTitle.text = [[MHGatewayAlarmClockTimerTools sharedInstance] fetchTimeSpace:_timer andIdentifier:NextIdentifierOn];
    _pickerTitle.textAlignment = NSTextAlignmentCenter;
    _pickerTitle.textColor = [MHColorUtils colorWithRGB:0x3fb57d];
    _pickerTitle.font = [UIFont boldSystemFontOfSize:10];
    _pickerTitle.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_pickerTitle];
}

#pragma mark - 按钮消息
- (void)onBack:(id)sender {
    NSLog(@"新%@旧%@", _timer, _oldTimer);
        if (![_timer isEqualWithTimer:_oldTimer]) {
//    if (![self timer:_timer isEqualWithTimer:_oldTimer]) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.timersetting.cancel.tips",@"plugin_gateway","要舍弃对该定时的修改吗？") message:nil delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway", "取消") otherButtonTitles:NSLocalizedStringFromTable(@"Ok", @"plugin_gateway","确定"), nil];
        alertView.tag = TimerModifyAbortAVTag;
        [alertView show];
        return;
    }
    
    [super onBack:sender];
}

- (void)onDone:(id)sender {
    
    [_timer updateTimerMonthAndDayForRepeatOnceType];
    _timer.isEnabled = YES;
        if (_onDone) {
            _onDone(_timer);
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
                [_timer resetWithTimer:_oldTimer];
                [super onBack:nil];
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
                [_timer resetWithTimer:_oldTimer];
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
    if (indexPath.row == (_settingItems.count - 1)) {
        return 70;
    }
    return 56.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    switch (indexPath.row) {
        case 0: {
            MHLuTimerRepeatTypeVC* repeatTypeVC = [[MHLuTimerRepeatTypeVC alloc] initWithTimer:_timer];
            [self.navigationController pushViewController:repeatTypeVC animated:YES];
        }
            break;
        case 1: {
            [self openBellChoosePage:(MHDeviceSettingCell *)[tableView cellForRowAtIndexPath:indexPath]];
        }
            break;
         default:
            break;
    }
}

- (void)openBellChoosePage:(MHDeviceSettingCell *)cell {
    XM_WS(weakself);
    MHGatewayBellChooseNewViewController* bellChooseVC = [[MHGatewayBellChooseNewViewController alloc] initWithGateway:self.device mid:[_timerMusicIndex integerValue]];
    bellChooseVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmclock.tone",@"plugin_gateway","选择闹钟铃音");
    bellChooseVC.controllerIdentifier = @"mydevice.gateway.setting.alarmclock.tone";
    bellChooseVC.onSelectMusic = ^(NSString *musicName){
        cell.item.comment = musicName;
    };
    bellChooseVC.onSelectIndex = ^(NSInteger index){
        weakself.timerMusicIndex = [NSString stringWithFormat:@"%d", (int)index];
        weakself.timer.onParam = @[weakself.timerOnOff, weakself.timerMusicIndex, @(weakself.timerVolume) ];
        weakself.timer.onMethod = @"play_alarm_clock";
        weakself.timer.offMethod = @"play_alarm_clock";
        weakself.timer.offParam = @[ @"off" ];
    };
    [self.navigationController pushViewController:bellChooseVC animated:YES];
    
    
//    MHGatewayClockBellChooseViewController* bellChooseVC = [[MHGatewayClockBellChooseViewController alloc] initWithGateway:self.device mid:[_timerMusicIndex integerValue]];
//    bellChooseVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmclock.tone",@"plugin_gateway","选择闹钟铃音");
//    bellChooseVC.controllerIdentifier = @"mydevice.gateway.setting.alarmclock.tone";
//    bellChooseVC.onSelectMusic = ^(NSString *musicName){
//        cell.item.comment = musicName;
//    };
//    bellChooseVC.onSelectIndex = ^(NSInteger index){
//        weakself.timerMusicIndex = [NSString stringWithFormat:@"%d", (int)index];
//        weakself.timer.onParam = @[weakself.timerOnOff, weakself.timerMusicIndex, @(weakself.timerVolume) ];
//    };
//    [self.navigationController pushViewController:bellChooseVC animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_settingItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Class cellClass = [self cellClassWithItem:_settingItems[indexPath.row]];
    MHDeviceSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(cellClass)];
    if (!cell)
    {
        cell = [[cellClass alloc] initWithReuseIdentifier:NSStringFromClass(cellClass)];
    }
    [cell fillWithItem:_settingItems[indexPath.row]];
    
    return cell;
}

- (Class)cellClassWithItem:(id)item
{
    if ([item isKindOfClass:[MHDeviceSettingItem class]]) {
        MHDeviceSettingItem *currentItem = (MHDeviceSettingItem *)item;
        switch (currentItem.type) {
            case MHDeviceSettingItemTypeDefault:
                return [MHDeviceSettingDefaultCell class];
                break;
            case MHDeviceSettingItemTypeVolume:
                return [MHDeviceSettingVolumeCell class];
                break;
            default:
                return [MHDeviceSettingDefaultCell class];
                break;
        }
    }
    else {
        MHGatewaySettingCellItem *currentItem = (MHGatewaySettingCellItem *)item;
        switch (currentItem.type) {
            case MHGatewaySettingItemTypeLeg:
                return [MHGatewayLegSettingCell class];
                break;
            case MHGatewaySettingItemTypeVolume:
                return [MHGatewayVolumeSettingCell class];
                break;
            default:
                return [MHGatewaySettingCell class];
                break;
        }
    }
}


#pragma mark - 新旧闹钟对比
- (BOOL)timer:(MHDataDeviceTimer *)timer isEqualWithTimer:(MHDataDeviceTimer *)oldTimer {
    BOOL isEqual = NO;
    if (_timer.onMinute != _oldTimer.onMinute ||
        _timer.onHour != _oldTimer.onHour ||
        _timer.onRepeatType != _oldTimer.onRepeatType ||
        ![_timer.onParam isEqual:_oldTimer.onParam]) {
        isEqual = NO;
    }
    else {
        isEqual = YES;
    }
    return isEqual;
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
