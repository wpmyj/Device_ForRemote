//
//  MHGatewaySceneListViewController.m
//  MiHome
//
//  Created by Lynn on 2/16/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewaySceneListViewController.h"
#import "MHIFTTTViewController.h"
#import "MHGatewaySysCell.h"
#import "MHTableViewControllerInternalV2.h"
#import "MHIFTTTEditViewController.h"


@interface MHGatewaySceneListViewController () <MHTableViewControllerInternalDelegateV2,UIActionSheetDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) MHDeviceGateway *gateway;
@property (nonatomic,strong) MHIFTTTManager *sceneManager;
@property (nonatomic,strong) MHTableViewControllerInternalV2 *iftTableView;
@property (nonatomic,strong) NSArray *sysIFTGroup;
@property (nonatomic,strong) NSMutableArray *customIFTGroup;

@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIButton *btnSetting;
@property (nonatomic, strong) UIButton *btnAddDevice;

@property (nonatomic, strong) UILabel *labelSetting;
@property (nonatomic, strong) UILabel *labelAddDevice;

@end

@implementation MHGatewaySceneListViewController
{
    NSInteger                           _selectedRecordIndex;
}

- (id)initWithFrame:(CGRect)frame sensor:(MHDeviceGateway* )gateway {
    if (self = [super init]) {
        _gateway = gateway;
        self.view.frame = frame;
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self dataConstruct];
    
    [self loadStatus];
}

- (void)loadStatus {
    self.sceneManager = [MHIFTTTManager sharedInstance];
    [self.sceneManager getAllRecomRecordsCompletion:nil];
    [self.sceneManager getTemplateCompletion:nil];

    [self.gateway getAlarmClockData:nil failure:nil];
    
    [self loadIFTTTRecords];
}

- (void)loadIFTTTRecords {
    XM_WS(weakself);
    
    NSMutableArray *dids = [NSMutableArray new];
    [dids addObject:_gateway.did];
    for (MHDeviceGatewayBase *sensor in _gateway.subDevices){
        if(sensor.isOnline) [dids addObject:sensor.did];
    }
//    NSLog(@"%@",dids);
    [self.sceneManager getRecordsOfDevices:dids completion:^(NSArray *array) {
        weakself.customIFTGroup = [array mutableCopy];
        [weakself reloadTableView];
    }];
}

- (void)dataConstruct {
    _sysIFTGroup = @[
                     @{
                         @"name" : NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm", @"plugin_gateway", nil),
                         @"detail" : NSLocalizedStringFromTable(@"mydevice.gateway.scene.sys.detail.alarm", @"plugin_gateway", nil),
                         @"icon" : @"gateway_home_page_alarm_off",
                         @"QA" : @"cell1",
                         },
                     @{
                         @"name" : NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight", @"plugin_gateway", nil),
                         @"detail" : NSLocalizedStringFromTable(@"mydevice.gateway.scene.sys.detail.nightlight", @"plugin_gateway", nil),
                         @"icon" : @"gateway_home_page_light_off",
                         @"QA" : @"cell2",
                         },
                     @{
                         @"name" : NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.timer.cap", @"plugin_gateway", nil),
                         @"detail" : NSLocalizedStringFromTable(@"mydevice.gateway.scene.sys.detail.timerlight", @"plugin_gateway", nil),
                         @"icon" : @"gateway_home_page_timing_light",
                         },
                     @{
                         @"name" : NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmclock", @"plugin_gateway", nil),
                         @"detail" : NSLocalizedStringFromTable(@"mydevice.gateway.scene.sys.detail.alarmclock", @"plugin_gateway", nil),
                         @"icon" : @"gateway_home_page_clock",
                         },
                     @{
                         @"name" : NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell", @"plugin_gateway", nil),
                         @"detail" : NSLocalizedStringFromTable(@"mydevice.gateway.scene.sys.detail.doorbell", @"plugin_gateway", nil),
                         @"icon" : @"gateway_home_page_doorbell",
                         },
                     ];
    [self reloadTableView];
}

- (void)reloadTableView {
    if(!_sysIFTGroup) _sysIFTGroup = [NSArray new];
    if(!_customIFTGroup) _customIFTGroup = [NSMutableArray new];
    if(_customIFTGroup.count){
        _iftTableView.dataSource = @[_sysIFTGroup,_customIFTGroup];
        _footerView.backgroundColor = [UIColor whiteColor];
    }
    else {
        _iftTableView.dataSource = @[_sysIFTGroup];
        _footerView.backgroundColor = [UIColor colorWithRed:239.f/255.f green:239.f/255.f blue:244.f/255.f alpha:1.f];
    }
    
    [_iftTableView stopRefreshAndReload];
}

- (void)buildSubviews {
    [super buildSubviews];
    
    //Footer view
    _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 70, CGRectGetWidth(self.view.bounds), 70)];
    _footerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_footerView];
    
    _btnAddDevice = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(_footerView.frame) - 28) / 2.f, 5, 28, 28)];
    [_btnAddDevice setBackgroundImage:[UIImage imageNamed:@"device_addtimer"] forState:UIControlStateNormal];
    [_btnAddDevice addTarget:self action:@selector(onAddDevice:) forControlEvents:UIControlEventTouchUpInside];
    [_footerView addSubview:_btnAddDevice];
    
    _labelAddDevice = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_btnAddDevice.frame) + 6,
                                                                CGRectGetWidth(_footerView.frame), 11)];
    _labelAddDevice.font = [UIFont systemFontOfSize:11];
    _labelAddDevice.textColor = [MHColorUtils colorWithRGB:0x0 alpha:0.4];
    _labelAddDevice.text = NSLocalizedStringFromTable(@"mydevice.gateway.scene.add",@"plugin_gateway", @"添加自动化");
    _labelAddDevice.textAlignment = NSTextAlignmentCenter;
    [_footerView addSubview:_labelAddDevice];
    
    
    _btnSetting = [[UIButton alloc] init];
    [_btnSetting setBackgroundImage:[UIImage imageNamed:@"lumi_scene_log"] forState:(UIControlStateNormal)];
    [_btnSetting addTarget:self action:@selector(onSceneLog:) forControlEvents:(UIControlEventTouchUpInside)];
    [_footerView addSubview:_btnSetting];
    
    _labelSetting = [[UILabel alloc] init];
    _labelSetting.font = [UIFont boldSystemFontOfSize:11];
    _labelSetting.textColor = [MHColorUtils colorWithRGB:0x0 alpha:0.4];
    _labelSetting.textAlignment = NSTextAlignmentCenter;
    _labelSetting.text = NSLocalizedStringFromTable(@"ifttt.scene.log", @"plugin_gateway", "自动化日志");
    
    UITapGestureRecognizer *SetTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSceneLog:)];
    [_labelSetting addGestureRecognizer:SetTap];
    _labelSetting.userInteractionEnabled = YES;
    [_footerView addSubview:_labelSetting];

    
    CGRect tableRect = CGRectMake(0, 64, WIN_WIDTH, WIN_HEIGHT - 64 - CGRectGetHeight(_footerView.frame));
    _iftTableView = [[MHTableViewControllerInternalV2 alloc] initWithStyle:UITableViewStyleGrouped];
    _iftTableView.delegate = self;
    if(!_sysIFTGroup) _sysIFTGroup = [NSArray new];
    _iftTableView.dataSource = @[_sysIFTGroup];
    _iftTableView.cellClass = [MHGatewaySysCell class];
    [_iftTableView.view setFrame:tableRect];
    
    for (id gesture in _iftTableView.view.gestureRecognizers){
        if([gesture isKindOfClass:[UILongPressGestureRecognizer class]]){
            [_iftTableView.view removeGestureRecognizer:gesture];
        }
    }
    [self addChildViewController:_iftTableView];
    [self.view addSubview:_iftTableView.view];
}

- (void)buildConstraints {
    XM_WS(weakself);
    CGFloat labelSpacingV = 12;
    CGFloat btnSpacingV = 6;
    CGFloat btnSpacingH = 15 * ScaleWidth;
    CGFloat btnSize = 35;
    
    [_labelAddDevice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakself.footerView).with.offset(-labelSpacingV);
        make.right.mas_equalTo(weakself.footerView.mas_centerX).with.offset(-btnSpacingH);
    }];
    [_btnAddDevice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.labelAddDevice);
        make.bottom.mas_equalTo(weakself.labelAddDevice.mas_top).with.offset(-btnSpacingV);
        make.size.mas_equalTo(CGSizeMake(btnSize, btnSize));
    }];
    
    [_labelSetting mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakself.footerView).with.offset(-labelSpacingV);
        make.left.mas_equalTo(weakself.footerView.mas_centerX).with.offset(btnSpacingH);
    }];
    [_btnSetting mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.labelSetting);
        make.bottom.mas_equalTo(weakself.labelSetting.mas_top).with.offset(-btnSpacingV);
        make.size.mas_equalTo(CGSizeMake(btnSize, btnSize));
    }];
    

    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - button 
- (void)onAddDevice:(id)sender {
    if (_gateway.shareFlag == MHDeviceShared) {
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.timersetting.noright", @"plugin_gateway", "被分享设备无此权限") duration:1.0 modal:NO];
        return;
    }
    if(self.customIftCellClicked)self.customIftCellClicked(nil);
    [self gw_clickMethodCountWithStatType:@"editAutomation:"];

}

#pragma mark - 设置
- (void)onSceneLog:(id)sender {
//    if (_device.shareFlag == MHDeviceShared) {
//        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.timersetting.noright", @"plugin_gateway", "被分享设备无此权限") duration:1.0 modal:NO];
//        return;
//    }

    if(self.sceneLogClicked) {
     self.sceneLogClicked();   
    }
    [self gw_clickMethodCountWithStatType:@"openAutomationLog:"];

    
}


#pragma mark - table view delegate
- (void)startRefresh {
    [self loadIFTTTRecords];
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section {
    return 40.f;
}

- (CGFloat)heightForFooterInSection:(NSInteger)section {
    return 5.f;
}

- (UIView *)viewForFooterInSection:(NSInteger)section {
    UIView *back = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, 40)];
    back.backgroundColor = [UIColor clearColor];
    return back;
}

- (UIView *)viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, 40)];
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, WIN_WIDTH - 70, 30)];
    detailLabel.textAlignment = NSTextAlignmentLeft;
    detailLabel.font = [UIFont systemFontOfSize:14.f];
    detailLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    detailLabel.text = section ? NSLocalizedStringFromTable(@"mydevice.gateway.scene.custom", @"plugin_gateway", nil) : NSLocalizedStringFromTable(@"mydevice.gateway.scene.sys", @"plugin_gateway", nil);
    [headerView addSubview:detailLabel];
    
    UIView *bottomeLine = [[UIView alloc] initWithFrame:CGRectMake(20.0f, 39.f, WIN_WIDTH - 40.f, 0.5)];
    bottomeLine.backgroundColor = [MHColorUtils colorWithRGB:0xD1D1D1];
    [headerView addSubview:bottomeLine];

    return headerView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) return NSLocalizedStringFromTable(@"mydevice.gateway.scene.sys", @"plugin_gateway", nil);
    return NSLocalizedStringFromTable(@"mydevice.gateway.scene.custom", @"plugin_gateway", nil);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(_customIFTGroup.count) return 2;
    return 1;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TableViewCellHeight;
}

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *sysCellIdentifier = @"sysCell";
    static NSString *customCellIdentifier = @"customCell";
    
    if(indexPath.section == 0){
        id obj = _sysIFTGroup[indexPath.row];
        MHGatewaySysCell* cell = (MHGatewaySysCell *)[self.iftTableView.tableView dequeueReusableCellWithIdentifier:sysCellIdentifier];
        [cell configureWithDataObject:obj];
        return cell;
    }
    else {
         MHDataIFTTTRecord *record = _customIFTGroup[indexPath.row];
        MHGatewaySysCell *cell = (MHGatewaySysCell *)[self.iftTableView.tableView dequeueReusableCellWithIdentifier:customCellIdentifier];
        [cell configureWithDataObject:record];
        return cell;
    }
}

- (void)extraConfigureCell:(UITableViewCell *)cell withDataObject:(id)object {
    if ([object isKindOfClass:[MHDataIFTTTRecord class]]) {
        MHGatewaySysCell *scene = (MHGatewaySysCell *)cell;
        MHDataIFTTTRecord *record = (MHDataIFTTTRecord *)object;
        XM_WS(weakself);
        scene.relocateRecordBlock = ^{
//            NSLog(@"%@", record);
            [weakself retryLocal:record];
        };
        [scene setOfflineRecord:^(MHDataIFTTTRecord *offlineRecord) {
            if (weakself.offlineRecord) {
                weakself.offlineRecord(offlineRecord);
            }
        }];
    }
}


- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        if(self.sysIftCellClicked)self.sysIftCellClicked((SysIftType)indexPath.row);
    }
    else {
        MHDataIFTTTRecord *record = _customIFTGroup[indexPath.row];
        if(self.customIftCellClicked)self.customIftCellClicked(record);
        [self gw_clickMethodCountWithStatType:@"editAutomation:"];
    }
}

- (UITableViewCellEditingStyle)editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1) return UITableViewCellEditingStyleDelete;
    else return UITableViewCellEditingStyleNone;
}

- (void)commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    XM_WS(weakself);
    if (editingStyle == UITableViewCellEditingStyleDelete){
        MHDataIFTTTRecord *record = _customIFTGroup[indexPath.row];
        [self.sceneManager deleteRecord:record success:^{
            [weakself.customIFTGroup removeObject:record];
            [weakself.iftTableView stopRefreshAndReload];
            
        } failure:^(NSError *error){
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"delete.failed", @"plugin_gateway", nil) duration:1.f modal:YES];
        }];
        [self gw_clickMethodCountWithStatType:@"DeleteAutomation:"];
    }
}

//长按indexPath
- (void)didLongPressRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedRecordIndex = indexPath.row;
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:nil
                                          destructiveButtonTitle:NSLocalizedStringFromTable(@"mydevice.gateway.scene.list.rename", @"plugin_gateway", nil)
                                               otherButtonTitles:NSLocalizedStringFromTable(@"Cancel", @"plugin_gateway", nil), nil];
    [action showInView:self.view];
}

#pragma mark - action sheet delegate 
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(!buttonIndex){
        MHDataIFTTTRecord *record = _customIFTGroup[_selectedRecordIndex];

        //弹出修改名称的输入框
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.gateway.scene.edit.rename",@"plugin_gateway", "") message:@"" delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway","") otherButtonTitles:NSLocalizedStringFromTable(@"Ok",@"plugin_gateway", "确定"), nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert textFieldAtIndex:0].text = record.name;
        [alert show];
    }
}

#pragma mark - alert delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    UITextField *tf=[alertView textFieldAtIndex:0];
    MHDataIFTTTRecord *record = _customIFTGroup[_selectedRecordIndex];
    record.name = tf.text;
    if(buttonIndex){
        [tf resignFirstResponder];
        [self saveScene];
    }
}

#pragma mark - 编辑自动化保存
- (void)saveScene {
    
    XM_WS(weakself);
    MHDataIFTTTRecord *record = _customIFTGroup[_selectedRecordIndex];
    [self.sceneManager editRecord:record success:^{
        [weakself.iftTableView stopRefreshAndReload];
    } failure:^(NSInteger v) {
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"modify.failed", @"plugin_gateway", nil) duration:1.f modal:YES];
    }];
}



#pragma mark - 重新本地化
- (void)retryLocal:(MHDataIFTTTRecord *)record {
    NSString *strDelete = NSLocalizedStringFromTable(@"delete", @"plugin_gateway", "删除");
    NSString *strRetry = NSLocalizedStringFromTable(@"retry", @"plugin_gateway", "重试");
    NSString *strCancle = NSLocalizedStringFromTable(@"Cancel", @"plugin_gateway", "取消");
    NSString *strTitle = nil;
    NSArray *buttonArray = nil;
    
    if (record.status == -1) {
        strTitle = NSLocalizedStringFromTable(@"ifttt.scene.local.delete.alert.title", @"plugin_gateway", "请确保网关在线后再删除");
        buttonArray = @[ strCancle, strDelete ];
    }
    else {
        strTitle = NSLocalizedStringFromTable(@"ifttt.scene.local.alert.title", @"plugin_gateway", "自动化同步失败");
        buttonArray = @[ strDelete, strRetry ];

    }
    
    
    XM_WS(weakself);
    [[MHPromptKit shareInstance] showAlertWithHandler:^(NSInteger buttonIndex, NSArray *inputs) {
        switch (buttonIndex) {
            case 0: {
                if (record.status == -1) {
                    //取消
                }
                else {
                    //删除
                    [weakself.sceneManager deleteRecord:record success:^{
                        [weakself.customIFTGroup removeObject:record];
                        [weakself.iftTableView stopRefreshAndReload];
                    } failure:^(NSError *v) {
                        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"ifttt.scene.delete.failed", @"plugin_gateway", "删除自动化失败") duration:1.0f modal:NO];
                    }];
                }
            }
                break;
            case 1: {
                if (record.status == -1) {
                    //删除
                    [weakself.sceneManager deleteRecord:record success:^{
                        [weakself.customIFTGroup removeObject:record];
                        [weakself.iftTableView stopRefreshAndReload];
                    } failure:^(NSError *v) {
                        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"ifttt.scene.delete.failed", @"plugin_gateway", "删除自动化失败") duration:1.0f modal:NO];
                    }];
                    
                }
                else {
                    //编辑
                    [weakself.sceneManager editRecord:record success:^{
                        [weakself.iftTableView pullDownToRefresh];
                    } failure:^(NSInteger v) {
                        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"ifttt.scene.local.alert.edit.tips", @"plugin_gateway", "自动化本地化失败") duration:1.0f modal:NO];
                    }];
                }
            }
                break;
                
            default:
                break;
        }
    } withTitle:@"" message:strTitle style:UIAlertViewStyleDefault defaultText:nil cancelButtonTitle:nil otherButtonTitlesArray:buttonArray];
    
    
}

@end
