//
//  MHACPartnerPreferencesViewController.m
//  MiHome
//
//  Created by ayanami on 16/5/19.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerPreferencesViewController.h"
#import "MHLumiAccessSettingCell.h"
#import "MHACPartnerModeSettingViewController.h"
#import "MHACPartnerWindsSettingViewController.h"
#import "MHACPartnerTemperaturePickerView.h"

@interface MHACPartnerPreferencesViewController ()

@property (nonatomic, strong) MHDeviceAcpartner *acpartner;
@property (nonatomic, copy) MHDataDeviceTimer *timer;
@property (nonatomic, strong) MHACPartnerTemperaturePickerView *temperaturePickerView;
@property (nonatomic, assign) NSUInteger temperature;

@property (nonatomic, strong) MHLumiSettingCellItem *itemTemperature;

@end

@implementation MHACPartnerPreferencesViewController

- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner
{
    self = [super init];
    if (self) {
        self.isTabBarHidden = YES;
        self.acpartner = acpartner;
        self.acpartner.timerModeState = 0;
        self.acpartner.timerTemperature = 26;
        self.acpartner.timerWindPower = 3;
        self.acpartner.timerWindDirection = 0;
        self.acpartner.timerWindState = 1;
        [self dataConstruct];
    }
    return self;
}

- (id)initWithTimer:(MHDataDeviceTimer *)timer andAcpartner:(MHDeviceAcpartner *)acpartner {
    self = [super init];
    if (self) {
        self.isTabBarHidden = YES;
        self.acpartner = acpartner;
        if (timer) {
            self.timer = [timer copy];
            self.temperature = self.acpartner.timerTemperature;
        }
        else {
            self.acpartner.timerModeState = 0;
            self.acpartner.timerTemperature = 26;
            self.acpartner.timerWindPower = 3;
            self.acpartner.timerWindDirection = 0;
            self.acpartner.timerWindState = 1;
            self.temperature = 26;
        }
        [self dataConstruct];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedStringFromTable(@"mydevice.actionsheet.more",@"plugin_gateway","更多");

    
}

-(void)dataConstruct{
    //    [_gateway getTimerListWithSuccess:nil failure:nil];
    XM_WS(weakself);
    
    NSString* strMode = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.mode",@"plugin_gateway","模式");
    NSString* strWinds = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.fanspeed",@"plugin_gateway","风速");
    NSString* strSwept = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.airswing",@"plugin_gateway","扫风");
    NSString *strTemperature = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.timer.temperature",@"plugin_gateway","温度");
  
    MHLuDeviceSettingGroup* group1 = [[MHLuDeviceSettingGroup alloc] init];
    group1.title = nil;

//    if (_timer) {
//        group1.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.settings",@"plugin_gateway","空调偏好设置");
//    }
//    else {
//        group1.title = nil;
//    }
    
    NSMutableArray *acSettings = [NSMutableArray new];
    
    //模式
    MHLumiSettingCellItem *itemMode = [[MHLumiSettingCellItem alloc] init];
    itemMode.identifier = @"mydevice.gateway.sensor.mode";
    itemMode.lumiType = MHLumiSettingItemTypeAccess;
    itemMode.hasAcIndicator = YES;
    itemMode.caption = strMode;
    itemMode.comment = modeArray[self.acpartner.timerModeState];
    itemMode.customUI = YES;
    itemMode.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
    itemMode.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
        [weakself openModePage:^(NSString *mode) {
            cell.lumiItem.comment = mode;
            [cell fillWithItem:cell.lumiItem];
            [cell finish];
            if (weakself.chooseMode) {
                weakself.chooseMode(mode);
            }
        }];
    };
    [acSettings addObject:itemMode];
    
    
    //温度
    _itemTemperature = [[MHLumiSettingCellItem alloc] init];
    _itemTemperature.identifier = @"mydevice.gateway.sensor.temp";
    _itemTemperature.lumiType = MHLumiSettingItemTypeAccess;
    _itemTemperature.hasAcIndicator = YES;
    _itemTemperature.caption = strTemperature;
    _itemTemperature.comment = [NSString stringWithFormat:@"%d℃", self.acpartner.timerTemperature];
    _itemTemperature.customUI = YES;
    _itemTemperature.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
    _itemTemperature.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
        [weakself openTemperaturePage];
    };
    [acSettings addObject:_itemTemperature];
    
    
    //风速
    MHLumiSettingCellItem *itemWinds = [[MHLumiSettingCellItem alloc] init];
    itemWinds.identifier = @"mydevice.gateway.sensor.windspeed";
    itemWinds.lumiType = MHLumiSettingItemTypeAccess;
    itemWinds.hasAcIndicator = YES;
    itemWinds.caption = strWinds;
    itemWinds.comment = windPowerArray[self.acpartner.timerWindPower];
    itemWinds.customUI = YES;
    itemWinds.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
    itemWinds.lumiCallbackBlock = ^(MHLumiSettingCell *cell) {
        [weakself openWindsPage:^(NSString *winds) {
            cell.lumiItem.comment = winds;
            [cell fillWithItem:cell.lumiItem];
            [cell finish];
            if (weakself.chooseWinds) {
                weakself.chooseWinds(winds);
            }
        }];
    };
    [acSettings addObject:itemWinds];
    

    
    
    //扫风
    MHDeviceSettingItem *itemSwept = [[MHDeviceSettingItem alloc] init];
    itemSwept.identifier = @"mydevice.gateway.sensor.curtain.directionchoice";
    itemSwept.type = MHDeviceSettingItemTypeSwitch;
    itemSwept.caption = strSwept;
    itemSwept.customUI = YES;
    itemSwept.isOn = !self.acpartner.timerWindState;
    itemSwept.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(13)}];
    itemSwept.callbackBlock = ^(MHDeviceSettingCell *cell) {
        cell.item.isOn = !cell.item.isOn;
        weakself.acpartner.timerWindState = (int)cell.item.isOn;
        [cell finish];
    };
    [acSettings addObject:itemSwept];

    
    group1.items = acSettings;
    self.settingGroups = [NSMutableArray arrayWithObjects:group1,nil];
}

- (void)buildSubviews
{
    XM_WS(weakself);

    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 44, 26);
    [btn setBackgroundColor:[MHColorUtils colorWithRGB:0x1dc58a]];
    [btn setTitle:NSLocalizedStringFromTable(@"Ok",@"plugin_gateway", "确定") forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13.f];
    btn.layer.cornerRadius = 3.0f;
    [btn addTarget:self action:@selector(onDone:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.settingTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:self.settingTableView];
    self.settingTableView.delegate = self;
    self.settingTableView.dataSource = self;
    self.settingTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.temperaturePickerView = [[MHACPartnerTemperaturePickerView alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.setting.type.temperature",@"plugin_gateway","指定温度") temperaturePicked:^(NSUInteger temperature) {
        weakself.acpartner.timerTemperature = (int)temperature;
        weakself.itemTemperature.comment = [NSString stringWithFormat:@"%d℃", weakself.acpartner.timerTemperature];
        [weakself reloadItemAtIndex:1 atSection:0];
    }];
}

- (void)onDone:(id)sender {
    if (self.acpartner.timerModeState == -1) {
        [[MHTipsView shareInstance] showTipsInfo:@"请先选择模式" duration:1.5f modal:NO];
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    if (self.onDone) {
        self.onDone([NSMutableArray new]);
    }
}

#pragma mark - 按钮消息
- (void)onBack:(id)sender {
    //    NSLog(@"%@, %@", _timer.onParam[0], _oldTimer.onParam[0]);
    //    NSLog(@"%@", self.nightColor);
    //    NSLog(@"%@", colorString[[_oldTimer.onParam[0] stringValue]]);
    //    NSLog(@"%@", colorViewsSences[colorString[[_oldTimer.onParam[0] stringValue]]]);
//    if (![_timer isEqualWithTimer:_oldTimer]) {
//        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.timersetting.cancel.tips",@"plugin_gateway","要舍弃对该定时的修改吗？") message:nil delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"plugin_gateway","取消") otherButtonTitles:NSLocalizedStringFromTable(@"Ok", @"plugin_gateway","确定"), nil];
//        alertView.tag = TimerModifyAbortAVTag;
//        [alertView show];
//        return;
//    }
    [super onBack:sender];
}

- (void)onBack {
    //    NSLog(@"%@, %@", _timer.onParam[0], _oldTimer.onParam[0]);
    //    NSLog(@"%@", self.nightColor);
    //    NSLog(@"%@", colorString[[_oldTimer.onParam[0] stringValue]]);
    //    NSLog(@"%@", colorViewsSences[colorString[[_oldTimer.onParam[0] stringValue]]]);
    //    if (![_timer isEqualWithTimer:_oldTimer]) {
    //        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.timersetting.cancel.tips",@"plugin_gateway","要舍弃对该定时的修改吗？") message:nil delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"plugin_gateway","取消") otherButtonTitles:NSLocalizedStringFromTable(@"Ok", @"plugin_gateway","确定"), nil];
    //        alertView.tag = TimerModifyAbortAVTag;
    //        [alertView show];
    //        return;
    //    }
        [super onBack];
}



#pragma mark - 扫风
- (void)openSweptPage:(void (^)(NSString *swept))selectedCallBack {
    
    XM_WS(weakself);
    MHLuDeviceSettingGroup* groupSelMotion = [[MHLuDeviceSettingGroup alloc] init];
    NSMutableArray *directionItems = [NSMutableArray arrayWithCapacity:1];
    groupSelMotion.items = directionItems;
    groupSelMotion.title = nil;
    
//    NSString *strForward = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.directionchoice.forward",@"plugin_gateway","正向");
//    NSString *strReverse = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.directionchoice.reverse",@"plugin_gateway","反向");
    
    MHDeviceSettingItem *itemForward = [[MHDeviceSettingItem alloc] init];
    itemForward.identifier = @"mydevice.gateway.sensor.curtain.directionchoice.forward";
    itemForward.type = MHDeviceSettingItemTypeCheckmark;
    itemForward.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.airswing.upanddown",@"plugin_gateway","上下扫风");
    itemForward.hasAcIndicator = YES;
    itemForward.customUI = YES;
    itemForward.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    itemForward.callbackBlock = ^(MHDeviceSettingCell *cell) {
        if (selectedCallBack) {
            selectedCallBack(cell.item.caption);
        }
        [weakself.navigationController popViewControllerAnimated:YES];
        
    };
    
    [directionItems addObject:itemForward];
    
    //NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.control",@"plugin_gateway","空调控制")
    MHDeviceSettingItem *itemReverse = [[MHDeviceSettingItem alloc] init];
    itemReverse.identifier = @"mydevice.gateway.sensor.curtain.directionchoice.reverse";
   
   
    itemReverse.type = MHDeviceSettingItemTypeCheckmark;
    itemReverse.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.airswing.leftandright",@"plugin_gateway","左右扫风");
    itemReverse.hasAcIndicator = NO;
    itemReverse.customUI = YES;
    itemReverse.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    itemReverse.callbackBlock = ^(MHDeviceSettingCell *cell) {
        if (selectedCallBack) {
            selectedCallBack(cell.item.caption);
        }
        [weakself.navigationController popViewControllerAnimated:YES];
       
    };
    
    [directionItems addObject:itemReverse];
    
    MHDeviceSettingItem *itemAuto = [[MHDeviceSettingItem alloc] init];
    itemAuto.identifier = @"mydevice.gateway.sensor.curtain.directionchoice.reverse";
    
    
    itemAuto.type = MHDeviceSettingItemTypeCheckmark;
    itemAuto.caption = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.airswing.auto",@"plugin_gateway","自动送风");
    itemAuto.hasAcIndicator = NO;
    itemAuto.customUI = YES;
    itemAuto.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    itemAuto.callbackBlock = ^(MHDeviceSettingCell *cell) {
        if (selectedCallBack) {
            selectedCallBack(cell.item.caption);
        }
        [weakself.navigationController popViewControllerAnimated:YES];
        
    };
    
    [directionItems addObject:itemAuto];
    
    
    MHLuDeviceSettingViewController* sweptVC = [[MHLuDeviceSettingViewController alloc] init];
    sweptVC.settingGroups = @[groupSelMotion];
    sweptVC.controllerIdentifier = @"mydevice.gateway.sensor.curtain.directionchoice";
    sweptVC.title = @"扫风";
    [self.navigationController pushViewController:sweptVC animated:YES];
}
#pragma mark - 温度
- (void)openTemperaturePage {
    [_temperaturePickerView setTemperature:self.acpartner.timerTemperature];
    [self.temperaturePickerView showInView:self.view.window];
}
#pragma mark - 模式
- (void)openModePage:(void (^)(NSString *mode))selectedCallBack{
    MHACPartnerModeSettingViewController *modeVC = [[MHACPartnerModeSettingViewController alloc] initWithAcpartner:self.acpartner currentMode:self.acpartner.timerModeState];
    XM_WS(weakself);
    modeVC.chooseMode = ^(int mode){
        weakself.acpartner.timerModeState = mode;
        if (selectedCallBack) {
            selectedCallBack(modeArray[mode]);
        }
    };
    [self.navigationController pushViewController:modeVC animated:YES];
}
#pragma mark - 风速
- (void)openWindsPage:(void (^)(NSString *winds))selectedCallBack {
    XM_WS(weakself);
    MHACPartnerWindsSettingViewController *modeVC = [[MHACPartnerWindsSettingViewController alloc] initWithAcpartner:self.acpartner currentWinds:self.acpartner.timerWindPower];
    modeVC.chooseWinds = ^(int winds){
        weakself.acpartner.timerWindPower = winds;
        if (selectedCallBack) {
            selectedCallBack(windPowerArray[winds]);
        }
    };
    [self.navigationController pushViewController:modeVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
