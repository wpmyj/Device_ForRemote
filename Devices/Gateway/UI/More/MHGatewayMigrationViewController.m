//
//  MHGatewayMigrationViewController.m
//  MiHome
//
//  Created by Lynn on 5/17/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayMigrationViewController.h"
#import "MHTableViewControllerInternalV2.h"
#import "MHCacheManager.h"
#import "MHDeviceSettingDefaultCell.h"
#import "MHFirmwareUpgradeViewController.h"
#import "MHGatewayMigrationLoadingController.h"
#import "MHGatewayMigrationManager.h"

#define AVBtnClick              10000
#define miniGatewayV2Version    @(1301200138)
#define miniGatewayV3Version    @(1261320138)

@interface MHGatewayMigrationViewController () <MHTableViewControllerInternalDelegateV2,UIAlertViewDelegate>

@property (nonatomic,strong) MHTableViewControllerInternalV2 *tvcInternal;
@property (nonatomic,strong) MHDeviceGateway *selectedNewGateway;
@property (nonatomic,strong) UIButton *migrateBtn;

@end

@implementation MHGatewayMigrationViewController
{
    NSMutableArray *        _gatewayList;
    NSInteger               _selectedRow;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.about.migration",@"plugin_gateway","迁移");
    
    CGRect tableRect = CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT - 70);
    self.tvcInternal = [[MHTableViewControllerInternalV2 alloc] initWithStyle:UITableViewStyleGrouped];
    self.tvcInternal.delegate = self;
    [self.tvcInternal.view setFrame:tableRect];
    [self addChildViewController:self.tvcInternal];
    [self.view addSubview:self.tvcInternal.view];
    
    self.migrateBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.migrateBtn.frame = CGRectMake(30, WIN_HEIGHT - 70, WIN_WIDTH - 60, 45);
    [self.migrateBtn setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.about.migration",@"plugin_gateway","迁移") forState:UIControlStateNormal];
    [self.migrateBtn addTarget:self action:@selector(onMigrationStart:) forControlEvents:UIControlEventTouchUpInside];
    self.migrateBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.migrateBtn setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:(UIControlStateNormal)];
    [self.migrateBtn.layer setCornerRadius:45 / 2.f];
    self.migrateBtn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.migrateBtn.layer.borderWidth = 0.5;
    [self.view addSubview:self.migrateBtn];
    self.view.backgroundColor = self.tvcInternal.view.backgroundColor;
    
    XM_WS(weakself);
    //版本检测，检测只有特定的版本以上才支持迁移。这里先检测当前的gateway，选择
    [self checkV2Version];
    
    //列出相应的待迁出网关，分组，第二组展示当前选择网关的子设备
    [[MHCacheManager shareInstance] asynLoadDeviceListWithCompletionBlock:^(NSArray* deviceList) {
        [weakself buildTableView:deviceList];
    }];
}

- (void)buildTableView:(NSArray *)deviceList {
    _gatewayList = [NSMutableArray new];
    XM_WS(weakself);
    for(MHDevice *device in deviceList){
        if([device.model isEqualToString:@"lumi.gateway.v3"] || [self.gateway.model isEqualToString:DeviceModelAcpartner]){
            [_gatewayList addObject:device];
        }
    }
    
    _selectedRow = 0;
    if(_gatewayList.count > 0){
        _selectedNewGateway = (MHDeviceGateway *)_gatewayList[0];
//        [[MHGatewayMigrationManager sharedInstance] gatewayDeleteDeviceData:_selectedNewGateway];
        
        [(MHDeviceGateway *)_gatewayList[0] getVersionWithSuccess:^(id obj) {
            [weakself checkV3Version:weakself.selectedNewGateway];
        } failure:nil];
        self.migrateBtn.hidden = NO;
    }
    else {
        self.migrateBtn.hidden = YES;
    }
    self.tvcInternal.cellClass = [MHDeviceSettingDefaultCell class];
    self.tvcInternal.dataSource = @[_gatewayList];
    [self.tvcInternal stopRefreshAndReload];
//    [[MHGatewayMigrationManager sharedInstance] gatewayDeleteDeviceData:self.gateway];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onMigrationStart:(id)sender {
    NSString *message = [NSString stringWithFormat:
                         NSLocalizedStringFromTable(@"mydevice.gateway.about.migration.tips", @"plugin_gateway",""), _selectedNewGateway.name];

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway","")
                                              otherButtonTitles:NSLocalizedStringFromTable(@"Ok",@"plugin_gateway",""), nil];
    alertView.tag = AVBtnClick;
    [alertView show];
}

#pragma mark - check version
- (void)checkV2Version {
    XM_WS(weakself);
    if(self.gateway.version != nil){
        [self checkV2];
    }
    else {
        [self.gateway getVersionWithSuccess:^(id obj) {
            [weakself checkV2];
        } failure:nil];
    }
}

- (void)checkV2 {
    NSString *v2String = [self.gateway.version stringByReplacingOccurrencesOfString:@"." withString:@""];
    v2String = [v2String stringByReplacingOccurrencesOfString:@"_" withString:@""];
    NSInteger v2Code = v2String.integerValue;
    
    NSInteger minV2Version = miniGatewayV2Version.integerValue;
    if(v2Code < minV2Version){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:NSLocalizedStringFromTable(@"mydevice.gateway.about.migration.versionV2tip",@"plugin_gateway","")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedStringFromTable(@"Ok",@"plugin_gateway","")
                                                  otherButtonTitles:nil];
        
        [alertView show];
    }
}

- (void)checkV3Version:(MHDeviceGateway *)newGateway {
    NSString *vString = [newGateway.version stringByReplacingOccurrencesOfString:@"." withString:@""];
    vString = [vString stringByReplacingOccurrencesOfString:@"_" withString:@""];
    NSInteger vCode = vString.integerValue;
    
    NSInteger minVersion = miniGatewayV3Version.integerValue;
    if(vCode < minVersion){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                            message:NSLocalizedStringFromTable(@"mydevice.gateway.about.migration.versionV3tip",@"plugin_gateway","")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedStringFromTable(@"Ok",@"plugin_gateway","")
                                                  otherButtonTitles:nil];
        
        [alertView show];
    }
}

- (void)openUpgrateView {
    MHFirmwareUpgradeViewController *upgate = [[MHFirmwareUpgradeViewController alloc] init];
    upgate.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:upgate animated:YES];
}

#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex != 0){
        MHGatewayMigrationLoadingController *migrationLoading = [[MHGatewayMigrationLoadingController alloc] init];
        migrationLoading.outGateway = self.gateway;
        migrationLoading.inGateway = _selectedNewGateway;
        migrationLoading.isTabBarHidden = YES;
        [self.navigationController pushViewController:migrationLoading animated:YES];
    }
    else {
        //打开升级页面
        if(alertView.tag != AVBtnClick){
            [self openUpgrateView];
        }
    }
}

#pragma mark - MHTableViewControllerInternalDelegateV2
- (void)startRefresh {
    [self.tvcInternal stopRefreshAndReload];
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section {
    return 40.f;
}

- (UIView *)viewForHeaderInSection:(NSInteger)section {
    UIView * titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, 40)];
    titleView.backgroundColor = [UIColor clearColor];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 200, 30)];
    title.font = [UIFont systemFontOfSize:14.f];
    title.textColor = [UIColor grayColor];
    title.text = section ? NSLocalizedStringFromTable(@"mydevice.gateway.about.migration.title2",@"plugin_gateway","迁移") :
                           NSLocalizedStringFromTable(@"mydevice.gateway.about.migration.title1",@"plugin_gateway","迁移");
    [titleView addSubview:title];
    return titleView;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56.f;
}

- (UIView *)emptyView {
    UIView *messageView = [[UIView alloc] initWithFrame:self.view.bounds];
    [messageView setBackgroundColor:[MHColorUtils colorWithRGB:0xefefef alpha:0.4f]];
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableview_blank_logo"]];
    [messageView addSubview:icon];
    CGRect imageFrame = icon.frame;
    imageFrame.origin.x = messageView.bounds.size.width / 2.0f - icon.frame.size.width / 2.0f;
    imageFrame.origin.y = CGRectGetHeight(self.view.bounds) / 3.f;
    [icon setFrame:imageFrame];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(messageView.frame.origin.x, CGRectGetMaxY(icon.frame), messageView.frame.size.width, 19.0f)];
    label.text = NSLocalizedStringFromTable(@"mydevice.gateway.about.migration.nosourcedevice", @"plugin_gateway", @"列表空");
    label.textAlignment = NSTextAlignmentCenter;
    [label setTextColor:[UIColor lightGrayColor]];
    [label setFont:[UIFont systemFontOfSize:15.0f]];
    [messageView addSubview:label];
    
    return messageView;
}

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* cellIdentifier = @"Cell";
    MHDeviceSettingDefaultCell* cell = (MHDeviceSettingDefaultCell* )[self.tvcInternal.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MHDeviceSettingDefaultCell alloc] initWithReuseIdentifier:cellIdentifier];
    }

    NSString *text = @"";
    if(indexPath.section == 0) {
        text = [_gatewayList[indexPath.row] valueForKey:@"name"];
    }
    else {
        text = [self.gateway.subDevices[indexPath.row] valueForKey:@"name"];
    }
    
    MHDeviceSettingItem* item = [[MHDeviceSettingItem alloc] init];
    item.caption = text;
    item.type = MHDeviceSettingItemTypeDefault;
    item.customUI = YES;
    item.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    [cell fillWithItem:item];
    
    if(indexPath.section == 0){
        if(_selectedRow == indexPath.row) cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0 ){
        _selectedRow = indexPath.row;
        _selectedNewGateway = _gatewayList[_selectedRow];
        [self checkV3Version:_selectedNewGateway];
        [self.tvcInternal.tableView reloadData];
    }
}

@end
