//
//  MHGatewayAlarmClockTimerView.m
//  MiHome
//
//  Created by guhao on 4/8/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayAlarmClockTimerView.h"
#import "MHGatewayAlarmClockCell.h"
#import "MHTimerDetailViewController.h"
#import "MHGatewayAlarmClockTimerTools.h"

#define TimerCellId @"MHGatewayAlarmClockCell"
#define TableViewCellHeight (56)

@interface MHGatewayAlarmClockTimerView ()<UIActionSheetDelegate>

@property (nonatomic, strong) UITableView *tableview;

@property (nonatomic, strong) UIButton *btnSetting;
@property (nonatomic, strong) UIButton *btnAdd;

@property (nonatomic, strong) UILabel *labelSetting;
@property (nonatomic, strong) UILabel *labelAdd;

@property (nonatomic, strong) MHDevice *device;

@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) NSString *timespace;

@end

@implementation MHGatewayAlarmClockTimerView
{
    __weak UIViewController*    _parentVC;
    
    UITableView*                _tableview;
    EGORefreshTableHeaderView*  _headerView;
    BOOL                        _reloading;
    
    NSInteger                   _longPressedIndex;
    NSArray *       _timerList;
}


- (id)initWithDevice:(MHDevice*)device timerList:(NSArray* )timerList parentVC:(UIViewController* )parentVC {
    if (self = [super initWithDevice:device timerList:timerList parentVC:parentVC]) {
        _device = device;
        _timerList = timerList;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"ddd");
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIActionSheet *actionsheet = [[UIActionSheet alloc]
                                  initWithTitle:NSLocalizedStringFromTable(@"mydevice.timersetting.del", @"plugin_gateway", "删除此项定时设置？")
                                  delegate:self
                                  cancelButtonTitle:nil
                                  destructiveButtonTitle:NSLocalizedStringFromTable(@"Ok",@"plugin_gateway", "确定")
                                  otherButtonTitles:NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway", "取消"), nil];
    actionsheet.tag = indexPath.row;
    [actionsheet showInView:self];
}

- (void)setCustomName:(NSString *)customName {
    _customName = customName;
    if(customName){
        _labelAdd.text = [NSString stringWithFormat:@"%@%@", NSLocalizedStringFromTable(@"timer.button.part1", @"plugin_gateway", "添加"),self.customName];
    }
}

#pragma mark - UIActionSheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            if (self.onNewDelTimer) {
                self.onNewDelTimer(actionSheet.tag);
            }
            break;
        default:
            break;
    }
}

- (void)buildHeaderView {
    if (_headerView && [_headerView superview]) {
        [_headerView removeFromSuperview];
    }
    
    _headerView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0.0f-_tableview.bounds.size.height, _tableview.bounds.size.width, _tableview.bounds.size.height)];
    _headerView.delegate = self;
    _headerView.refreshTriggerValue = 35;
    _headerView.backgroundColor = [MHColorUtils colorWithRGB:0xF1F1F1];
    _headerView.statusLabel.textColor = [MHColorUtils colorWithRGB:0x999999];
    _headerView.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [_tableview addSubview:_headerView];
    [_headerView refreshLastUpdatedDate];
}

- (void)buildSubviews {
    self.backgroundColor = [UIColor whiteColor];
    
    _tableview = [[UITableView alloc] init];
    _tableview.dataSource = self;
    _tableview.delegate = self;
    _tableview.tableFooterView = [[UIView alloc] init];
//    [_tableview registerClass:[MHGatewayAlarmClockCell class] forCellReuseIdentifier:TimerCellId];
    [self addSubview:_tableview];
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onTableViewCellLongPressed:)];
    longPress.minimumPressDuration = 1.0;
    _tableview.separatorColor = [MHColorUtils colorWithRGB:0xf1f1f1];
    [_tableview addGestureRecognizer:longPress];
    
    
    _btnAdd = [[UIButton alloc] init];
    [_btnAdd setBackgroundImage:[UIImage imageNamed:@"device_addtimer"] forState:(UIControlStateNormal)];
    [_btnAdd addTarget:self action:@selector(onAdd:) forControlEvents:(UIControlEventTouchUpInside)];
    [self addSubview:_btnAdd];
    
    _labelAdd = [[UILabel alloc] init];
    _labelAdd.font = [UIFont boldSystemFontOfSize:11];
    _labelAdd.textColor = [MHColorUtils colorWithRGB:0x0 alpha:0.4];
    _labelAdd.textAlignment = NSTextAlignmentCenter;
    _labelAdd.text = NSLocalizedStringFromTable(@"mydevice.timersetting.add", @"plugin_gateway", "添加定时");
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAdd:)];
    [_labelAdd addGestureRecognizer:tap];
    _labelAdd.userInteractionEnabled = YES;
    [self addSubview:_labelAdd];
    
    
    _btnSetting = [[UIButton alloc] init];
    [_btnSetting setBackgroundImage:[UIImage imageNamed:@"gateway_alock_setTimer"] forState:(UIControlStateNormal)];
    [_btnSetting addTarget:self action:@selector(onSetting:) forControlEvents:(UIControlEventTouchUpInside)];
    [self addSubview:_btnSetting];
    
    _labelSetting = [[UILabel alloc] init];
    _labelSetting.font = [UIFont boldSystemFontOfSize:11];
    _labelSetting.textColor = [MHColorUtils colorWithRGB:0x0 alpha:0.4];
    _labelSetting.textAlignment = NSTextAlignmentCenter;
    _labelSetting.text = NSLocalizedStringFromTable(@"mydevice.timersetting.set", @"plugin_gateway", "设置");
    
    UITapGestureRecognizer *SetTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSetting:)];
    [_labelSetting addGestureRecognizer:SetTap];
    _labelSetting.userInteractionEnabled = YES;
    [self addSubview:_labelSetting];

    
}

- (void)buildConstraints {
    XM_WS(weakself);
    CGFloat labelSpacingV = 15;
    CGFloat btnSpacingV = 6;
    CGFloat tableViewSpacingV = 5;
    CGFloat btnSpacingH = 15 * ScaleWidth;
    CGFloat btnSize = 35;
    
    [_labelAdd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakself).with.offset(-labelSpacingV);
        make.right.mas_equalTo(weakself.mas_centerX).with.offset(-btnSpacingH);
    }];
    [_btnAdd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.labelAdd);
        make.bottom.mas_equalTo(weakself.labelAdd.mas_top).with.offset(-btnSpacingV);
        make.size.mas_equalTo(CGSizeMake(btnSize, btnSize));
    }];
    
    [_labelSetting mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakself).with.offset(-labelSpacingV);
        make.left.mas_equalTo(weakself.mas_centerX).with.offset(btnSpacingH);
    }];
    [_btnSetting mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.labelSetting);
        make.bottom.mas_equalTo(weakself.labelSetting.mas_top).with.offset(-btnSpacingV);
        make.size.mas_equalTo(CGSizeMake(btnSize, btnSize));
    }];
    

    [_tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself);
        make.left.equalTo(weakself);
        make.width.mas_equalTo(WIN_WIDTH);
        make.bottom.mas_equalTo(weakself.btnAdd.mas_top).with.offset(-tableViewSpacingV);
    }];
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self buildHeaderView];
}

#pragma mark - 添加
- (void)onAdd:(id)sender {
    
    if (_device.shareFlag == MHDeviceShared) {
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.timersetting.noright", @"plugin_gateway", "被分享设备无此权限") duration:1.0 modal:NO];
        return;
    }
    
    if (self.onAddTimer) {
        self.onAddTimer();
    }
}
#pragma mark - 设置
- (void)onSetting:(id)sender {
    if (_device.shareFlag == MHDeviceShared) {
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.timersetting.noright", @"plugin_gateway", "被分享设备无此权限") duration:1.0 modal:NO];
        return;
    }
    
    if (self.onSettingTimer) {
        self.onSettingTimer();
    }

}

- (void)reloadAllTimer {
    [_tableview reloadData];
}

#pragma mark - 定时
- (void)showDeleteTimerAV {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.timersetting.del", @"plugin_gateway", "删除此项定时设置？") message:nil delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"plugin_gateway", "取消") otherButtonTitles:NSLocalizedStringFromTable(@"Ok", @"plugin_gateway", "确定"), nil];
    [alertView show];
}

- (void)onRefreshTimerListDone:(BOOL)succeed timerList:(NSArray* )timerList {
    _reloading = NO;
    [_headerView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableview];
    
    if (succeed) {
        _timerList = timerList;
        [self reloadAllTimer];
    }
}

- (void)updateTimerMonthAndDayForRepeatOnceType:(MHDataDeviceTimer* )timer {
    if (timer.isEnabled == YES && timer.onRepeatType == MHDeviceTimerRepeat_Once) {
        [timer updateTimerMonthAndDayForRepeatOnceType];
    }
}
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TableViewCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_device.shareFlag == MHDeviceUnShared) {
        if (self.onModifyTimer) {
            MHDataDeviceTimer* selectedTimer = [_timerList objectAtIndex:indexPath.row];
            self.onModifyTimer(selectedTimer, YES);
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([_timerList count]) {
        tableView.backgroundView = nil;
        return [_timerList count];
    }
    else if (self.needBlankCup) {
        
        UIView *messageView = [[UIView alloc] initWithFrame:tableView.bounds];
        [messageView setBackgroundColor:[UIColor whiteColor]];
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableview_blank_logo"]];
        [messageView addSubview:icon];
        CGRect frame = icon.frame;
        frame.origin.x = messageView.bounds.size.width / 2.0f - icon.frame.size.width / 2.0f;
        frame.origin.y = CGRectGetHeight(tableView.bounds) / 4.f;
        [icon setFrame:frame];
        UIView *sep = [[UIView alloc] initWithFrame:CGRectMake((messageView.frame.size.width - 117) / 2, CGRectGetMaxY(icon.frame) + 5.f , 117, 1.0f)];
        [sep setBackgroundColor:[MHColorUtils colorWithRGB:0xe6e6e6]];
        [messageView addSubview:sep];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(sep.frame.origin.x, CGRectGetMaxY(sep.frame) + 8.0f, sep.frame.size.width, 19.0f)];
        if(self.customName){
            label.text = [NSString stringWithFormat:@"%@%@%@",NSLocalizedStringFromTable(@"timer.blank.part1", @"plugin_gateway", nil),self.customName,NSLocalizedStringFromTable(@"timer.blank.part2", @"plugin_gateway", nil)];
        }
        else {
            label.text = NSLocalizedStringFromTable(@"timer.blank", @"plugin_gateway", @"还没有定时");
        }
        
        label.textAlignment = NSTextAlignmentCenter;
        [label setTextColor:[MHColorUtils colorWithRGB:0xcfcfcf]];
        [label setFont:[UIFont systemFontOfSize:13.0f]];
        [messageView addSubview:label];
        UIView *sep2 = [[UIView alloc] initWithFrame:CGRectMake(sep.frame.origin.x, CGRectGetMaxY(label.frame) + 8.0f, sep.frame.size.width, sep.frame.size.height)];
        [messageView addSubview:sep2];
        [sep2 setBackgroundColor:[MHColorUtils colorWithRGB:0xe6e6e6]];
        
        tableView.backgroundView = messageView;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        return 0;
        
    }
    
    return [_timerList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    __block MHDataDeviceTimer* timer = _timerList[indexPath.row];
    MHGatewayAlarmClockCell* cell = [tableView dequeueReusableCellWithIdentifier:TimerCellId];
    if (cell == nil) {
        cell = [[MHGatewayAlarmClockCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimerCellId];
    }
    XM_WS(weakself);
    cell.onSwitch = ^(){
        timer.isEnabled = !timer.isEnabled;
        if (weakself.onModifyTimer) {
            weakself.onModifyTimer(timer, NO);
        }
    };
    [self configureWithTimer:timer cell:cell];
    return cell;
}

//长按事件的手势监听实现方法
- (void) onTableViewCellLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint ponit = [gestureRecognizer locationInView:_tableview];
        NSIndexPath* indexPath = [_tableview indexPathForRowAtPoint:ponit];
        _longPressedIndex = indexPath.row;
        if (indexPath && _longPressedIndex < [_timerList count]) {
            [self showDeleteTimerAV];
        }
    }
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 1: {
            if (_device.shareFlag == MHDeviceShared) {
                [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.timersetting.noright", @"plugin_gateway", "被分享设备无此权限") duration:1.0 modal:NO];
                return;
            }
            if (self.onDelTimer) {
                self.onDelTimer(_timerList[_longPressedIndex]);
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_headerView egoRefreshScrollViewDidScroll:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_headerView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - EGORefreshTableHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
    if (self.refreshTimerList) {
        _reloading = YES;
        self.refreshTimerList();
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
    return _reloading;
}

#pragma mark - cell
- (void)configureWithTimer:(MHDataDeviceTimer *)timer  cell:(MHGatewaySettingCell *)cell{
    [self updateTimerView:timer];
    MHGatewaySettingCellItem *item = [[MHGatewaySettingCellItem alloc] init];
    item.customUI = YES;
    item.type = MHGatewatSettingItemTypeDetailSwitch;
    item.caption = _title;
    item.comment = _detail;
    item.identifier = _timespace;
    item.isOn = timer.isEnabled;
    item.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    cell.gatewayItem = item;
    

}

- (void)updateTimerView:(MHDataDeviceTimer *)timer {
    self.isOpen = timer.isEnabled;
    //小时
    if(timer.onHour >9)
        _title = [NSString stringWithFormat:@"%ld:", timer.onHour];
    else
        _title = [NSString stringWithFormat:@"0%ld:",
                  timer.onHour];
    //分钟
    if (timer.onMinute < 10)
        _title = [_title stringByAppendingFormat:@"0%ld",timer.onMinute];
    else
        _title = [_title stringByAppendingFormat:@"%ld",timer.onMinute];
    _detail = [timer getOnRepeatTypeString];
    
    if (!self.isOpen){
        _timespace = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmclock.timerclose", @"plugin_gateway",@"未启用闹钟");
//        _item1.identifier = _timespace;
    }
    else {
        _timespace = [[MHGatewayAlarmClockTimerTools sharedInstance] fetchTimeSpace:timer andIdentifier:NextIdentifierOn];
//        _item1.identifier = _timespace;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
