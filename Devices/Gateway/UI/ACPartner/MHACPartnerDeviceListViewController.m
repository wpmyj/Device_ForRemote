//
//  MHACPartnerDeviceListViewController.m
//  MiHome
//
//  Created by ayanami on 16/5/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerDeviceListViewController.h"
#import "MHTableViewControllerInternalV2.h"
#import "MHGatewayDeviceCell.h"
#import "MHACPartnerSettingViewController.h"
#import "MHGatewayAddSubDeviceViewController.h"
#import "MHGatewayAddSubDeviceListController.h"
#import "MHGatewayWebViewController.h"
#import "MHLuDeviceViewControllerBase.h"

#define AVTag_Offline       13001
#define WALLTAG_Offline     220
#define CubeTag_Offline      250

@interface MHACPartnerDeviceListViewController ()<MHTableViewControllerInternalDelegateV2>

@property (nonatomic, strong) MHDeviceAcpartner *acpartner;
@property (nonatomic,strong) UIView  *footerView;
@property (nonatomic,strong) MHTableViewControllerInternalV2* tvcInternal;
@property (nonatomic,strong) NSMutableArray *dataSource;

@end

@implementation MHACPartnerDeviceListViewController
{
    MHTableViewControllerInternalV2 *       _deviceList;
    UIButton *                              _btnAddDevice;
    UILabel *                               _labelAddDevice;
    
    MHDeviceGatewayBase *                   _pressedDevice;
    NSMutableArray *                        _newAddDevices;
}

- (id)initWithFrame:(CGRect)frame sensor:(MHDeviceAcpartner *)acpartner{
    if (self = [super init]) {
        self.acpartner = acpartner;
        self.view.frame = frame;
        self.isTabBarHidden = YES;
        self.view.backgroundColor = [UIColor colorWithRed:239.f/255.f green:239.f/255.f blue:244.f/255.f alpha:1.f];
        [self dataSourceRebuild];
        XM_WS(weakself);
        [[NSNotificationCenter defaultCenter] addObserverForName:[[MHDevListManager sharedManager] notificationNameForUIUpdate] object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [weakself onGetDeviceListSucceed:note];
        }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self dataSourceRebuild];
    [self.acpartner getCanAddSubDevice];
    [self.acpartner getPublicCanAddSubDevice];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startRefresh];
}

- (void)buildSubviews {
    [super buildSubviews];
    
    //Footer view
    _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 65, CGRectGetWidth(self.view.bounds), 65)];
    _footerView.backgroundColor = [UIColor whiteColor];
    if (self.acpartner.shareFlag == MHDeviceShared) {
        _footerView.hidden = YES;
    }
    [self.view addSubview:_footerView];
    
    _btnAddDevice = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(_footerView.frame) - 28) / 2.f, 5, 28, 28)];
    [_btnAddDevice setBackgroundImage:[UIImage imageNamed:@"device_addtimer"] forState:UIControlStateNormal];
    [_btnAddDevice addTarget:self action:@selector(onAddDevice:) forControlEvents:UIControlEventTouchUpInside];
    if (self.acpartner.shareFlag == MHDeviceShared) {
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
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray new];
    }
    self.tvcInternal.dataSource = @[_dataSource];
    if (self.acpartner.shareFlag == MHDeviceShared) {
        CGRect tableRect = CGRectMake(0, 64, CGRectGetWidth(self.view.frame),
                                      _footerView.frame.origin.y);
        [self.tvcInternal.view setFrame:tableRect];
        
    }
    else {
        CGRect tableRect = CGRectMake(0, 64, CGRectGetWidth(self.view.frame),
                                      _footerView.frame.origin.y - 64);
        [self.tvcInternal.view setFrame:tableRect];
    }
    [self addChildViewController:self.tvcInternal];
    [self.view addSubview:self.tvcInternal.view];
}

#pragma mark - button
- (void)onAddDevice:(id)sender{
    [self addSubdeviceAgain];
//    if(self.clickAddDeviceBtn)self.clickAddDeviceBtn();
    [self gw_clickMethodCountWithStatType:@"openAddDeviceListPage:"];
}

- (void)dataSourceRebuild {
    


    self.dataSource = [NSMutableArray arrayWithObject:self.acpartner];
    
    NSMutableArray *tmpSubDevices = [NSMutableArray arrayWithArray:self.acpartner.subDevices];
    
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"isOnline" ascending:NO];
    NSArray *tmp = [tmpSubDevices sortedArrayUsingDescriptors:@[sort1]];
    
    tmpSubDevices = [NSMutableArray arrayWithArray:tmp];
    
    [self.dataSource addObjectsFromArray:tmpSubDevices];
    self.tvcInternal.dataSource = @[_dataSource];
    [self.tvcInternal stopRefreshAndReload];
}

#pragma mark - 设备列表更新
- (void)onGetDeviceListSucceed:(NSNotification* )note {
    [self startRefresh];
}

#pragma mark - MHTableViewControllerInternalDelegateV2
- (void)startRefresh {
    XM_WS(weakself);
    [_acpartner getSubDeviceListWithSuccess:^(id obj) {
        if([obj isKindOfClass:[NSArray class]]){
            [weakself deviceMap:[obj mutableCopy]];
        }
        if(weakself.dataSource){
            weakself.tvcInternal.dataSource = @[weakself.dataSource];
            [weakself.tvcInternal stopRefreshAndReload];
        }
        //子设备数量改变
        if (weakself.deviceCountChange) {
            weakself.deviceCountChange();
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
    
    MHGatewayDeviceCell* cell = (MHGatewayDeviceCell *)[self.tvcInternal.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell configureWithDataObject:device];
    
    return cell;
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MHDeviceGatewayBase *device = _dataSource[indexPath.row];
    device.isNewAdded = NO;
    if(device.isOnline){
        if([device isKindOfClass:[MHDeviceAcpartner class]]){
            MHACPartnerSettingViewController* settingVC = [[MHACPartnerSettingViewController alloc] initWithAcpartner:self.acpartner];
            [self.navigationController pushViewController:settingVC animated:YES];
            [self gw_clickMethodCountWithStatType:@"openACpartnerSettingPage"];

        }
        else{
            Class deviceClassName = NSClassFromString([[device class] getViewControllerClassName]);
            id deviceVC = [[deviceClassName alloc] initWithDevice:device];
            [self.navigationController pushViewController:deviceVC animated:YES];
        }
        [self gw_clickMethodCountWithStatType:[NSString stringWithFormat:@"openDeviceDetatilPage_%@", NSStringFromClass([device class])]];

//        if(self.clickDeviceCell) self.clickDeviceCell(device);
    }
    else{
        [self showOfflineAV:device];
    }
}

- (UITableViewCellEditingStyle)editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.acpartner.shareFlag == MHDeviceUnShared) {
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
        [self gw_clickMethodCountWithStatType:@"ACPartnerDeleteDevice:"];
    }
}

- (void)didLongPressRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != 0) {
        XM_WS(weakself);
        [self gw_clickMethodCountWithStatType:@"ACPartnerDeleteDevice:"];

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

#pragma mark - 比对添加和删除设备
- (void)deviceMap:(NSMutableArray *)newSubDevices {
    XM_WS(weakself);
    __block NSMutableArray *newDeviceArray = [NSMutableArray new];
    
    [newSubDevices enumerateObjectsUsingBlock:^(MHDevice *newDevice, NSUInteger idx, BOOL * _Nonnull stop) {
        //        NSLog(@"子设备的did <<<%@>>>, 模型<<%@>>", newDevice.did, newDevice.model);
        MHDeviceGatewayBase *sensor = (MHDeviceGatewayBase *)[MHDevFactory deviceFromModelId:newDevice.model dataDevice:newDevice];
        sensor.parent = weakself.acpartner;
        [newDeviceArray addObject:sensor];
    }];
//    if (_acpartner.subDevices.count != newSubDevices.count) {
        _acpartner.subDevices = newDeviceArray;
//    }
    
    [self dataSourceRebuild];
}


#pragma mark - alert view
- (void)showOfflineAV:(MHDeviceGatewayBase* )device{
    if ([NSStringFromClass([device class]) isEqualToString:DeviceModelPlugClassName] ||
        [NSStringFromClass([device class]) isEqualToString:DeviceModelCtrlNeutral1ClassName] ||
        [NSStringFromClass([device class]) isEqualToString:DeviceModelCtrlNeutral2ClassName]) {
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
                //更换电池
                [self ChangeBattery];
               //                if(self.clickChangeBattery)self.clickChangeBattery(_pressedDevice);
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
    [self.acpartner removeSubDevice:device.did success:^(id v) {
        [[MHTipsView shareInstance] hide];
        [weakself startRefresh];
    } failure:^(NSError *v) {
        [weakself startRefresh];
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
    }];
}

#pragma mark -重新添加子设备
- (void)addSubdeviceAgain {
    if (_acpartner.shareFlag == MHDeviceShared) {
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.timersetting.noright", @"plugin_gateway", "被分享设备无此权限") duration:1.0 modal:NO];
        return;
    }
    MHGatewayAddSubDeviceListController *addlist = [[MHGatewayAddSubDeviceListController alloc] init];
    addlist.device = self.acpartner;
    MHLuDeviceSettingGroup* group1 = [[MHLuDeviceSettingGroup alloc] init];
    group1.title = NSLocalizedStringFromTable(@"deviceselect.title",@"plugin_gateway", "选择要连接的设备");
    MHLuDeviceSettingGroup* group2 = [[MHLuDeviceSettingGroup alloc] init];
    addlist.settingGroups = [NSMutableArray arrayWithObjects:group1,group2, nil];
    [self.navigationController pushViewController:addlist animated:YES];
//    if(self.clickAddDeviceBtn)self.clickAddDeviceBtn();
}

- (void)ChangeBattery {
    NSURL* faqURL = [NSURL URLWithString:[[_pressedDevice class] getBatteryChangeGuideUrl]];
    MHGatewayWebViewController* faqVC = [[MHGatewayWebViewController alloc] initWithURL:faqURL];
    faqVC.controllerIdentifier = @"mydevice.gateway.sensor.changebattery";
    faqVC.hasShare = NO;
    faqVC.strOriginalURL = [[_pressedDevice class] getBatteryChangeGuideUrl];
    [self.navigationController pushViewController:faqVC animated:YES];
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
