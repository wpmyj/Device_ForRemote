//
//  MHGatewayNeutralChangeNameViewController.m
//  MiHome
//
//  Created by guhao on 3/11/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayNeutralChangeNameViewController.h"
#import "MHDeviceGatewaySensorDoubleNeutral.h"
#import "MHDeviceSettingDefaultCell.h"
#import "MHStrongBox.h"
#import "MHLuDeviceChangeNameView.h"
#import "MHGatewayNeutralViewController.h"

typedef enum : NSInteger {
    NameSetting_NeutralLeft,
    NameSetting_NeutralRight,
}   NamesSetting;

@interface MHGatewayNeutralChangeNameViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) MHDevice *deviceDoubleNeutral;
@property (nonatomic, strong) NSString *leftName;
@property (nonatomic, strong) NSString *rightName;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *switchNames;

@end

@implementation MHGatewayNeutralChangeNameViewController

- (id)initWithDevice:(MHDevice *)device {
    if (self = [super init]) {
        self.deviceDoubleNeutral = device;
        self.switchNames = [[NSMutableArray alloc] initWithObjects:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.singleNeutral.title.left",@"plugin_gateway", @"修改左键名称"), NSLocalizedStringFromTable(@"mydevice.gateway.sensor.singleNeutral.title.right",@"plugin_gateway", @"修改右键名称"), nil];
        NSArray *names = [self.deviceDoubleNeutral.name componentsSeparatedByString:@"/"];
        if(names.count != 2) names = @[self.deviceDoubleNeutral.name,self.deviceDoubleNeutral.name];
        self.leftName = names[NameSetting_NeutralLeft];
        self.rightName = names[NameSetting_NeutralRight];
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)buildSubviews {
    self.title = NSLocalizedStringFromTable(@"mydevice.actionsheet.changename",@"plugin_gateway","修改设备名称");
    [super buildSubviews];
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
        case NameSetting_NeutralLeft: {
            [self deviceChangePluralNames:NameSetting_NeutralLeft];
        }
            break;
        case NameSetting_NeutralRight: {
            [self deviceChangePluralNames:NameSetting_NeutralRight];
        }
            break;
        default:
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.switchNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MHDeviceSettingDefaultCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MHDeviceSettingDefaultCell"];
    if (!cell) {
        cell = [[MHDeviceSettingDefaultCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MHDeviceSettingDefaultCell"];
    }
    [self configCell:cell withSettingIndex:(NamesSetting)indexPath.row];
    return cell;
}

- (void)configCell:(MHDeviceSettingCell* )cell withSettingIndex:(NamesSetting)index {
    MHDeviceSettingItem* item = [[MHDeviceSettingItem alloc] init];
    item.type = MHDeviceSettingItemTypeDefault;
    item.hasAcIndicator = YES;
    item.customUI = YES;
    item.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(100), SettingAccessoryKey_CaptionFontSize : @(14), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(10), SettingAccessoryKey_CommentFontColor : [MHColorUtils colorWithRGB:0x5f5f5f]}];
    item.caption = self.switchNames[index];
    [cell fillWithItem:item];
}

- (void)deviceChangePluralNames:(NamesSetting)name {
    XM_WS(weakself);
    CGFloat ratio = [UIScreen mainScreen].bounds.size.width / 414.0f;
    MHLuDeviceChangeNameView *changeNameView = [[MHLuDeviceChangeNameView alloc] initWithFrame:[UIScreen mainScreen].bounds panelFrame:CGRectMake(20 * ratio, 100, ([UIScreen mainScreen].bounds.size.width-40 * ratio), 195 * ratio) withCancel:^(id object){
    } withOk:^(NSString* newName){
        switch (name) {
            case NameSetting_NeutralLeft: {
                weakself.leftName = newName;
                newName = [NSString stringWithFormat:@"%@/%@", weakself.leftName, weakself.rightName];
            }
                break;
            case NameSetting_NeutralRight: {
                weakself.rightName = newName;
                newName = [NSString stringWithFormat:@"%@/%@", weakself.leftName, weakself.rightName];
            }
                break;
            default:
                break;
        }
            [weakself.deviceDoubleNeutral changeName:newName success:^(id v) {
                [[MHTipsView shareInstance] showFinishTips:NSLocalizedStringFromTable(@"mydevice.changename.tips.succeed", @"plugin_gateway","修改设备名称成功") duration:1.0 modal:NO];
            } failure:^(NSError *v) {
                [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.changename.tips.failed", @"plugin_gateway","修改设备名称失败") duration:1.0 modal:NO];
            }];
    }];
    [changeNameView setName:name ? self.rightName : self.leftName];
    changeNameView.labelTitleText = name? _switchNames[NameSetting_NeutralRight] : _switchNames[NameSetting_NeutralLeft];
    [self.view.window addSubview:changeNameView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
