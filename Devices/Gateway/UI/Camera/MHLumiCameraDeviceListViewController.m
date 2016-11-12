//
//  MHLumiCameraDeviceListViewController.m
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/1.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiCameraDeviceListViewController.h"
#import "MHTableViewControllerInternalV2.h"
#import "MHGatewayDeviceCell.h"
#import "MHGatewayThirdDataRequest.h"
#import "MHGatewayThirdDataResponse.h"
#import "MHNetworkStatusCell.h"
#import "MHGatewayAddSubDeviceViewController.h"
#import "MHGatewayAddSubDeviceListController.h"
#import "MHGatewaySettingViewController.h"
#import "MHDeviceCamera.h"
#import "MHLumiCameraGatewaySettingViewController.h"

#define AVTag_Offline       13001
#define WALLTAG_Offline     220
#define CubeTag_Offline      250
/**
 *  主要代码都是从MHGatewayDeviceListViewController复制过来，有时间再重构
 */
@interface MHLumiCameraDeviceListViewController () <MHTableViewControllerInternalDelegateV2,UIAlertViewDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) MHDeviceGateway *gateway;
@property (nonatomic, strong) MHDeviceGatewayBase *pressedDevice;
@property (nonatomic, strong) MHTableViewControllerInternalV2* tvcInternal;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UIView  *footerView;
@property (nonatomic, strong) UIButton *btnAddDevice;
@property (nonatomic, strong) UILabel *labelAddDevice;
@property (nonatomic, strong) MHTableViewControllerInternalV2 *deviceList;
@property (nonatomic, strong) NSMutableArray *AddedNewDevices;
@end

@implementation MHLumiCameraDeviceListViewController

- (id)initWithDevice:(MHDeviceGateway* )device {
    if (self = [super initWithDevice:device]) {
        _gateway = device;
        self.isNavBarTranslucent = NO;
        self.isTabBarHidden = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:239.f/255.f green:239.f/255.f blue:244.f/255.f alpha:1.f];
    [self.gateway getCanAddSubDevice];
    [self.gateway getPublicCanAddSubDevice];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

- (void)buildSubviews {
    [super buildSubviews];
    [self dataSourceRebuild];
    //Footer view
    _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 65, CGRectGetWidth(self.view.bounds), 65)];
    _footerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _footerView.backgroundColor = [UIColor whiteColor];
    if (self.gateway.shareFlag == MHDeviceShared) {
        _footerView.hidden = YES;
    }
    [self.view addSubview:_footerView];
    
    _btnAddDevice = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(_footerView.frame) - 28) / 2.f, 5, 28, 28)];
    [_btnAddDevice setBackgroundImage:[UIImage imageNamed:@"device_addtimer"] forState:UIControlStateNormal];
    [_btnAddDevice addTarget:self action:@selector(onAddDevice:) forControlEvents:UIControlEventTouchUpInside];
    if (self.gateway.shareFlag == MHDeviceShared) {
        _btnAddDevice.hidden = YES;
    }
    
    [_footerView addSubview:_btnAddDevice];
    
    _labelAddDevice = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_btnAddDevice.frame) + 6,
                                                                CGRectGetWidth(_footerView.frame), 11)];
    _labelAddDevice.font = [UIFont systemFontOfSize:11];
    _labelAddDevice.textColor = [MHColorUtils colorWithRGB:0x0 alpha:0.4];
    _labelAddDevice.text = NSLocalizedStringFromTable(@"mydevice.gateway.setting.addsubdeviceslist",@"plugin_gateway", @"添加子设备");
    _labelAddDevice.textAlignment = NSTextAlignmentCenter;
    [_footerView addSubview:_labelAddDevice];
    
    self.tvcInternal = [[MHTableViewControllerInternalV2 alloc] initWithStyle:UITableViewStylePlain];
    self.tvcInternal.cellClass = [MHGatewayDeviceCell class];
    self.tvcInternal.delegate = self;
    self.tvcInternal.dataSource = @[_dataSource];
    if (self.gateway.shareFlag == MHDeviceShared) {
        CGRect tableRect = CGRectMake(0, 64, CGRectGetWidth(self.view.frame),
                                      CGRectGetHeight(self.view.frame)-64);
        [self.tvcInternal.view setFrame:tableRect];
    }
    else {
        CGRect tableRect = CGRectMake(0, 64, CGRectGetWidth(self.view.frame),
                                      CGRectGetHeight(self.view.frame)-64-65);
        [self.tvcInternal.view setFrame:tableRect];
    }
    self.tvcInternal.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self addChildViewController:self.tvcInternal];
    [self.view addSubview:self.tvcInternal.view];
}

- (void)dataSourceRebuild {
    self.dataSource = [NSMutableArray arrayWithObject:self.gateway];
    
    NSMutableArray *tmpSubDevices = [NSMutableArray arrayWithArray:self.gateway.subDevices];
    
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"isOnline" ascending:NO];
    NSArray *tmp = [tmpSubDevices sortedArrayUsingDescriptors:@[sort1]];
    
    tmpSubDevices = [NSMutableArray arrayWithArray:tmp];
    
    [self.dataSource addObjectsFromArray:tmpSubDevices];
    //    NSLog(@"%@", self.dataSource);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 比对添加和删除设备
- (void)deviceMap:(NSMutableArray *)newSubDevices {
    XM_WS(weakself);
    __block NSMutableArray *newDeviceArray = [NSMutableArray new];
    
    [newSubDevices enumerateObjectsUsingBlock:^(MHDevice *newDevice, NSUInteger idx, BOOL * _Nonnull stop) {
        //        NSLog(@"子设备的name <<<%@>>>, 模型<<%@>>, 在不在线%d", newDevice.name, newDevice.model, newDevice.isOnline);
        MHDeviceGatewayBase *sensor = (MHDeviceGatewayBase *)[MHDevFactory deviceFromModelId:newDevice.model dataDevice:newDevice];
        sensor.parent = weakself.gateway;
        [newDeviceArray addObject:sensor];
    }];
    //    if (_gateway.subDevices.count != newSubDevices.count) {
    _gateway.subDevices = [NSMutableArray arrayWithArray:newDeviceArray];
    //    }
    
    
    //    NSMutableArray *oldSubDevices = [_gateway.subDevices mutableCopy];
    //    _newAddDevices = [NSMutableArray new];
    
    //新增
    //    for (MHDevice* newDevice in newSubDevices) {
    //        BOOL foundFlag = NO;
    //        for (MHDevice*  oldDevice in oldSubDevices) {
    //            if ([newDevice.did isEqualToString:oldDevice.did]) {
    //                foundFlag = YES;
    //                break;
    //            }
    //        }
    
    //        如果找到新的网关子设备
    //        if(!foundFlag){;
    //            MHDeviceGatewayBase *sensor = (MHDeviceGatewayBase *)[MHDevFactory deviceFromModelId:newDevice.model dataDevice:newDevice];
    //            sensor.isNewAdded = YES;
    //            sensor.parent = _gateway;
    //            [self.gateway.subDevices addObject:sensor];
    //            [_newAddDevices addObject:sensor.did];
    //            sensor.isNewAdded = YES;
    //        }
    //    }
    //
    //    //删除
    //    for (MHDevice *oldDevice in oldSubDevices){
    //        BOOL foundFlag = NO;
    //        for (MHDevice*  newDevice in newSubDevices) {
    //            if ([newDevice.did isEqualToString:oldDevice.did]) {
    //                foundFlag = YES;
    //                break;
    //            }
    //        }
    //
    //        if(!foundFlag){
    //            [self.gateway.subDevices removeObject:oldDevice];
    //        }
    //    }
    
    [self dataSourceRebuild];
}

#pragma mark - button
- (void)onAddDevice:(id)sender{
    if(self.clickAddDeviceBtn)self.clickAddDeviceBtn();
    [self gw_clickMethodCountWithStatType:@"openAddDeviceListPage:"];
    MHGatewayAddSubDeviceListController *addlist = [[MHGatewayAddSubDeviceListController alloc] init];
    addlist.device = self.gateway;
    MHLuDeviceSettingGroup* group1 = [[MHLuDeviceSettingGroup alloc] init];
    group1.title = NSLocalizedStringFromTable(@"deviceselect.title",@"plugin_gateway", "选择要连接的设备");
    MHLuDeviceSettingGroup* group2 = [[MHLuDeviceSettingGroup alloc] init];
    addlist.settingGroups = [NSMutableArray arrayWithObjects:group1,group2, nil];
    [self.navigationController pushViewController:addlist animated:YES];
}

#pragma mark - MHTableViewControllerInternalDelegateV2
- (void)startRefresh {
    XM_WS(weakself);
    [_gateway getSubDeviceListWithSuccess:^(id obj) {
        if([obj isKindOfClass:[NSArray class]]){
            [weakself deviceMap:[obj mutableCopy]];
        }
        
        //        weakself.gateway.subDevices = obj;
        //        [weakself dataSourceRebuild];
        if(weakself.dataSource){
            weakself.tvcInternal.dataSource = @[weakself.dataSource];
            [weakself.tvcInternal stopRefreshAndReload];
        }
        //子设备数量改变
        if (weakself.deviceCountChange) {
            weakself.deviceCountChange();
        }
        if ([self.delegate respondsToSelector:@selector(cameraDeviceListViewControllerCallWhenDeviceCountChange:)]){
            [self.delegate cameraDeviceListViewControllerCallWhenDeviceCountChange:self];
        }
    } failuer:^(NSError *v) {
        [weakself.tvcInternal stopRefreshAndReload];
    }];
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.f;
}

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* cellIdentifier = @"Cell";
    
    MHDeviceGatewayBase *device = _dataSource[indexPath.row];
    //    BOOL isNewFlag;
    //    if(_newAddDevices) {
    //        if ([_newAddDevices indexOfObject:device.did] == NSNotFound) isNewFlag = NO;
    //        else isNewFlag = YES;
    //    }
    //    else isNewFlag = NO;
    //    device.isNewAdded = isNewFlag;
    
    MHGatewayDeviceCell* cell = (MHGatewayDeviceCell *)[self.tvcInternal.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell configureWithDataObject:device];
    
    return cell;
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MHDeviceGatewayBase *device = _dataSource[indexPath.row];
    if(device.isOnline){
        device.isNewAdded = NO;
        if(self.clickDeviceCell) self.clickDeviceCell(device);
        [self openDeviceViewControllerWithDevice:device];
    }
    else{
        [self showOfflineAV:device];
    }
}

- (UITableViewCellEditingStyle)editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.gateway.shareFlag == MHDeviceUnShared) {
        if(indexPath.row == 0) return UITableViewCellEditingStyleNone;
        else return UITableViewCellEditingStyleDelete;
    }
    else {
        return UITableViewCellEditingStyleNone;
    }
}

- (void)commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete){
        
        MHDeviceGatewayBase *device = _dataSource[indexPath.row];
        
        NSMutableArray *ds = [NSMutableArray arrayWithArray:_dataSource];
        [ds removeObjectAtIndex:indexPath.row];
        _dataSource = [ds mutableCopy];
        self.tvcInternal.dataSource = @[_dataSource];
        [self.tvcInternal stopRefreshAndReload];
        
        [self deleteConfirm:device];
    }
}

- (void)didLongPressRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != 0) {
        XM_WS(weakself);
        NSString *title = NSLocalizedStringFromTable(@"mydevice.actionsheet.more",@"plugin_gateway","更多");
        
        NSMutableArray *objects = [NSMutableArray new];
        
        [objects addObject:[MHPromptKitObject objWithTitle:NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway",@"取消") isCancelBtn:YES isDestructiveBtn:NO handler:^(NSInteger buttonIndex) {
            
        }]];
        
        [objects addObject:[MHPromptKitObject objWithTitle:NSLocalizedStringFromTable(@"delete",@"plugin_gateway",@"删除") isCancelBtn:NO isDestructiveBtn:YES handler:^(NSInteger buttonIndex) {
            MHDeviceGatewayBase *device = weakself.dataSource[indexPath.row];
            
            NSMutableArray *ds = [NSMutableArray arrayWithArray:weakself.dataSource];
            [ds removeObjectAtIndex:indexPath.row];
            weakself.dataSource = [ds mutableCopy];
            weakself.tvcInternal.dataSource = @[weakself.dataSource];
            [weakself.tvcInternal stopRefreshAndReload];
            [weakself deleteConfirm:device];
        }]];
        
        [[MHPromptKit shareInstance] showPromptInView:self.view withTitle:title withObjects:objects];
        
    }
}


#pragma mark - alert view
- (void)showOfflineAV:(MHDeviceGatewayBase* )device{
    if ([NSStringFromClass([device class]) isEqualToString:DeviceModelPlugClassName] ||
        [NSStringFromClass([device class]) isEqualToString:DeviceModelCtrlNeutral1ClassName] ||
        [NSStringFromClass([device class]) isEqualToString:DeviceModelCtrlNeutral2ClassName] ||
        [NSStringFromClass([device class]) isEqualToString:DeviceModelCameraClassName]) {
        UIAlertView* atV = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.offlineview.title",@"plugin_gateway","设备已离线")
                                                      message:[[device class] offlineTips]
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"plugin_gateway","取消")
                                            otherButtonTitles:
                            NSLocalizedStringFromTable(@"mydevice.offlineview.button.refresh",@"plugin_gateway","刷新列表"),NSLocalizedStringFromTable(@"mydevice.gateway.sensor.addSubdeviceagain",@"plugin_gateway","重新添加子设备"),nil];
        atV.tag = WALLTAG_Offline;
        [atV show];
    }
    else {
        if ([NSStringFromClass([device class]) isEqualToString:DeviceModelCubeClassName]){
            UIAlertView* atV = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.offlineview.title",@"plugin_gateway","设备已离线")
                                                          message:[[device class] offlineTips]
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"plugin_gateway","取消")
                                                otherButtonTitles:
                                NSLocalizedStringFromTable(@"mydevice.offlineview.button.refresh",@"plugin_gateway","刷新列表"),
                                NSLocalizedStringFromTable(@"mydevice.gateway.sensor.addSubdeviceagain",@"plugin_gateway","重新添加子设备"),nil];
            atV.tag = CubeTag_Offline;
            [atV show];
        }
        else {
            UIAlertView* atV = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.offlineview.title",@"plugin_gateway","设备已离线")
                                                          message:[[device class] offlineTips]
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"plugin_gateway","取消")
                                                otherButtonTitles:
                                NSLocalizedStringFromTable(@"mydevice.gateway.sensor.changebattery",@"plugin_gateway","更换电池") ,
                                NSLocalizedStringFromTable(@"mydevice.offlineview.button.refresh",@"plugin_gateway","刷新列表"),
                                NSLocalizedStringFromTable(@"mydevice.gateway.sensor.addSubdeviceagain",@"plugin_gateway","重新添加子设备"),nil];
            atV.tag = AVTag_Offline;
            [atV show];
        }
        
    }
    _pressedDevice = device;
    [self gw_clickMethodCountWithStatType:[NSString stringWithFormat:@"showOfflineAV:%@",NSStringFromClass(device.class)]];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (AVTag_Offline == alertView.tag) {
        switch (buttonIndex) {
            case 1: {
                if(self.clickChangeBattery)self.clickChangeBattery(_pressedDevice);
                [self changBatteryWithDevice:_pressedDevice];
                break;
            }
            case 2: {
                //刷新列表
                [self startRefresh];
                break;
            }
            case 3: {
                //重新添加子设备
                [self addSubdeviceAgain];
                break;
            }
            default:
                break;
        }
    }
    if (WALLTAG_Offline == alertView.tag || CubeTag_Offline == alertView.tag) {
        switch (buttonIndex) {
            case 1:
                //刷新列表
                [self startRefresh];
                break;
            case 2: {
                //重新添加子设备
                [self addSubdeviceAgain];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - 删除设备
- (void)deleteConfirm:(MHDeviceGatewayBase *)device {
    XM_WS(weakself);
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"processing",@"plugin_gateway","正在处理中...") modal:NO];
    [self.gateway removeSubDevice:device.did success:^(id v) {
        [[MHTipsView shareInstance] hide];
        [weakself startRefresh];
        
    } failure:^(NSError *v) {
        [weakself startRefresh];
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
    }];
}

#pragma mark -重新添加子设备
- (void)addSubdeviceAgain {
    if (_gateway.shareFlag == MHDeviceShared) {
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.timersetting.noright", @"plugin_gateway", "被分享设备无此权限") duration:1.0 modal:NO];
        return;
    }
    if(self.clickAddDeviceBtn)self.clickAddDeviceBtn();
    [self gw_clickMethodCountWithStatType:@"openAddDeviceListPage:"];
}

#pragma mark - 更换电池
- (void)changBatteryWithDevice:(MHDeviceGatewayBase *)device{
    //更换电池
    NSURL* faqURL = [NSURL URLWithString:[[device class] getBatteryChangeGuideUrl]];
    MHGatewayWebViewController* faqVC = [[MHGatewayWebViewController alloc] initWithURL:faqURL];
    faqVC.controllerIdentifier = @"mydevice.gateway.sensor.changebattery";
    faqVC.hasShare = NO;
    faqVC.strOriginalURL = [[device class] getBatteryChangeGuideUrl];
    [self.navigationController pushViewController:faqVC animated:YES];
}

#pragma mark - 打开设备页
- (void)openDeviceViewControllerWithDevice:(MHDeviceGatewayBase *)device{
    if ([device isKindOfClass:[MHDeviceCamera class]]){
        MHLumiCameraGatewaySettingViewController *settingVC = [[MHLumiCameraGatewaySettingViewController alloc] initWithDevice:self.gateway];
        settingVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.title",@"plugin_gateway","多功能网关");
        [self.navigationController pushViewController:settingVC animated:YES];
        [self gw_clickMethodCountWithStatType:@"openGatewaySettingPage"];
    }else if([device isKindOfClass:[MHDeviceGateway class]]){
        MHGatewaySettingViewController* settingVC = [[MHGatewaySettingViewController alloc] initWithDevice:self.gateway];
        settingVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.title",@"plugin_gateway","多功能网关");
        [self.navigationController pushViewController:settingVC animated:YES];
        [self gw_clickMethodCountWithStatType:@"openGatewaySettingPage"];
    }else{
        [self gw_clickMethodCountWithStatType:[NSString stringWithFormat:@"openDeviceDetatilPage_%@", NSStringFromClass([device class])]];
        
        Class deviceClassName = NSClassFromString([[device class] getViewControllerClassName]);
        id deviceVC = [[deviceClassName alloc] initWithDevice:device];
        [self.navigationController pushViewController:deviceVC animated:YES];
    }
}

@end

