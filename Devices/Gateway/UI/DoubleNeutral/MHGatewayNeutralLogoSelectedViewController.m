//
//  MHGatewayNeutralLogoSelectedViewController.m
//  MiHome
//
//  Created by guhao on 3/17/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayNeutralLogoSelectedViewController.h"
#import "MHDeviceSettingDefaultCell.h"
#import "MHStrongBox.h"
#import "MHLumiChooseLogoListManager.h"
#import "MHLumiChangeIconManager.h"
#import "MHDeviceGatewaySensorWithNeutralDual.h"
#import "MHDeviceGatewaySensorDoubleNeutral.h"

typedef enum : NSInteger {
    TimerSetting_NeutralLeft,
    TimerSetting_NeutralRight,
}TimerSetting;

@interface MHGatewayNeutralLogoSelectedViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) MHDevice *deviceNeutral;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *switchTimer;

@end

@implementation MHGatewayNeutralLogoSelectedViewController

- (instancetype)initWithDevice:(MHDevice *)device
{
    self = [super init];
    if (self) {
        self.deviceNeutral = device;
        self.switchTimer = @[NSLocalizedStringFromTable(@"mydevice.gateway.sensor.singleNeutral.title.left",@"plugin_gateway", @"左键定时设置"), NSLocalizedStringFromTable(@"mydevice.gateway.sensor.singleNeutral.title.right",@"plugin_gateway", @"右键定时设置") ];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)buildSubviews {
    [super buildSubviews];
    self.title = NSLocalizedStringFromTable(@"mydevice.actionsheet.changelogo",@"plugin_gateway","更换图标");
    self.isTabBarHidden = YES;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
//    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = [[UIView alloc] init];

    [self.view addSubview:_tableView];
}

#pragma mark - UITableViewDelegate&DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.row) {
        case TimerSetting_NeutralLeft: {
            [self logoChoose:_service0];
        }
            break;
        case TimerSetting_NeutralRight: {
            [self logoChoose:_service1];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - logo choose 
- (void)logoChoose:(MHDeviceGatewayBaseService *)service {

    NSString *title = service.serviceId ? @"mydevice.gateway.sensor.neutral.changeLogo.right.title" : @"mydevice.gateway.sensor.neutral.changeLogo.left.title";
    
    
    NSString *iconID = [[MHLumiChangeIconManager sharedInstance] restorePdataByService:service
                                                                 withCompletionHandler:^(id result, NSError *error){}];
    
    [[MHLumiChooseLogoListManager sharedInstance] chooseLogoWithSevice:service iconID:iconID ? iconID : @"" titleIdentifier:title segeViewController:self];
}
@end
