//
//  MHGatewayNullNeutralTimerSelectedViewController.m
//  MiHome
//
//  Created by LM21Mac002 on 16/9/13.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayNullNeutralTimerSelectedViewController.h"
#import "MHGatewayTimerSettingNewViewController.h"
#import "MHDeviceSettingDefaultCell.h"
#import "MHDeviceGatewaySensorWithNeutralDual.h"
#import "MHStrongBox.h"
typedef enum : NSInteger {
    TimerSetting_NeutralLeft,
    TimerSetting_NeutralRight,
} TimerSetting;
@interface MHGatewayNullNeutralTimerSelectedViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSString *timerIdentify;
@property (nonatomic, strong) MHDeviceGatewaySensorWithNeutralDual *deviceDoubleNeutral;
@property (nonatomic, strong) MHGatewayTimerSettingNewViewController *timerVC;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *switchTimer;
@end

@implementation MHGatewayNullNeutralTimerSelectedViewController
- (instancetype)initWithDevice:(MHDevice *)device
{
    self = [super init];
    if (self) {
        self.deviceDoubleNeutral = (MHDeviceGatewaySensorWithNeutralDual *)device;
        self.switchTimer = [[NSMutableArray alloc] initWithObjects:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.singleNeutral.title.left",@"plugin_gateway", @"左键定时设置"), NSLocalizedStringFromTable(@"mydevice.gateway.sensor.singleNeutral.title.right",@"plugin_gateway", @"右键定时设置"), nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadStatus];
}

- (void)buildSubviews {
    [super buildSubviews];
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.doubleNeutral.timer.title",@"plugin_gateway","定时开关选择");
    self.isTabBarHidden = YES;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    //    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_tableView];
    
}

- (void)loadStatus {
    //获取单火定时数据
    [self.deviceDoubleNeutral getTimerListWithID:TimerIdentifyCtrlLn2Neutral0 Success:^(id obj) {
        
    } andFailure:^(NSError *error) {
        
    }];
    [self.deviceDoubleNeutral getTimerListWithID:TimerIdentifyCtrlLn2Neutral1 Success:^(id obj) {
        
    } andFailure:^(NSError *error) {
        
    }];
    
}

#pragma mark - UITableViewDelegate&DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.row) {
        case TimerSetting_NeutralLeft: {
            XM_WS(weakself);
            self.timerVC = [[MHGatewayTimerSettingNewViewController alloc] initWithDevice:self.deviceDoubleNeutral andIdentifier:TimerIdentifyCtrlLn2Neutral0];
            
            self.timerVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.doubleNeutral.timer.left.title",@"plugin_gateway", @"左键定时");
            self.timerVC.controllerIdentifier = @"doubleNeutral";
            self.timerVC.onAddNewTimer = ^(MHDataDeviceTimer *newTimer){
                [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.timersetting.adding",@"plugin_gateway","添加定时中，请稍候...") modal:YES];
                
                newTimer.identify = TimerIdentifyCtrlLn2Neutral0;
                newTimer.onMethod = @"toggle_ctrl_neutral";
                newTimer.onParam = @[ @"channel_0" , @"on" ];
                newTimer.offMethod = @"toggle_ctrl_neutral";
                newTimer.offParam = @[ @"channel_0" , @"off" ];
                
                [weakself.timerVC addTimer:newTimer];
            };
            [self.navigationController pushViewController:self.timerVC animated:YES];
        }
            break;
        case TimerSetting_NeutralRight: {
            XM_WS(weakself);
            self.timerVC = [[MHGatewayTimerSettingNewViewController alloc] initWithDevice:self.deviceDoubleNeutral andIdentifier:TimerIdentifyCtrlLn2Neutral1];
            
            self.timerVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.doubleNeutral.timer.right.title",@"plugin_gateway", @"右键定时");
            self.timerVC.controllerIdentifier = @"doubleNeutral";
            self.timerVC.onAddNewTimer = ^(MHDataDeviceTimer *newTimer){
                [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.timersetting.adding",@"plugin_gateway","添加定时中，请稍候...") modal:YES];
                
                newTimer.identify = TimerIdentifyCtrlLn2Neutral1;
                newTimer.onMethod = @"toggle_ctrl_neutral";
                newTimer.onParam = @[ @"channel_1" , @"on" ];
                newTimer.offMethod = @"toggle_ctrl_neutral";
                newTimer.offParam = @[ @"channel_1" , @"off" ];
                [weakself.timerVC addTimer:newTimer];
            };
            [self.navigationController pushViewController:self.timerVC animated:YES];
        }
            break;
        default:
            break;
    }
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.switchTimer count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MHDeviceSettingDefaultCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MHDeviceSettingDefaultCell"];
    if (!cell) {
        cell = [[MHDeviceSettingDefaultCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MHDeviceSettingDefaultCell"];
    }
    [self configCell:cell withSettingIndex:(TimerSetting)indexPath.row];
    return cell;
}

- (void)configCell:(MHDeviceSettingCell* )cell withSettingIndex:(TimerSetting)index {
    MHDeviceSettingItem* item = [[MHDeviceSettingItem alloc] init];
    item.type = MHDeviceSettingItemTypeDefault;
    item.hasAcIndicator = YES;
    item.customUI = YES;
    item.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(100), SettingAccessoryKey_CaptionFontSize : @(14), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(10), SettingAccessoryKey_CommentFontColor : [MHColorUtils colorWithRGB:0x5f5f5f]}];
    switch (index) {
        case TimerSetting_NeutralLeft: {
            item.caption = self.switchTimer[index];
        }
            break;
        case TimerSetting_NeutralRight: {
            item.caption = self.switchTimer[index];
        }
            break;
        default:
            break;
    }
    [cell fillWithItem:item];
}

@end