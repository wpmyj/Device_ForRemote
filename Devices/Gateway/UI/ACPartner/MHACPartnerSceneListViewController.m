//
//  MHACPartnerSceneListViewController.m
//  MiHome
//
//  Created by ayanami on 16/5/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerSceneListViewController.h"
#import "MHIFTTTManager.h"
#import "MHTableViewControllerInternalV2.h"
#import "MHACPartnerSceneCell.h"
#import "MHGatewaySceneLogViewController.h"
#import "MHIFTTTEditViewController.h"
#import "MHGatewayAlarmSettingViewController.h"
#import "MHGatewayDoorBellSettingViewController.h"

@interface MHACPartnerSceneListViewController ()<MHTableViewControllerInternalDelegateV2>

@property (nonatomic, strong) MHDeviceAcpartner *acpartner;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIButton *btnSetting;
@property (nonatomic, strong) UIButton *btnAddDevice;

@property (nonatomic, strong) UILabel *labelSetting;
@property (nonatomic, strong) UILabel *labelAddDevice;

@property (nonatomic, strong) MHIFTTTManager *sceneManager;
@property (nonatomic, strong) MHTableViewControllerInternalV2 *iftTableView;
@property (nonatomic, retain) NSArray *sysIFTGroup;
@property (nonatomic, retain) NSArray *acSysIFTGroup;
@property (nonatomic, retain) NSMutableArray *customIFTGroup;
@property (nonatomic, retain) NSMutableArray *recomIFTGroup;

@end

@implementation MHACPartnerSceneListViewController
{
    NSInteger                           _selectedRecordIndex;
}

- (id)initWithFrame:(CGRect)frame sensor:(MHDeviceAcpartner *)acpartner {
    if (self = [super init]) {
        self.acpartner = acpartner;
        self.view.frame = frame;
        self.isTabBarHidden = YES;
        self.view.backgroundColor = [UIColor whiteColor];

    }
    return self;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self dataConstruct];
    
    [self loadStatus];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadStatus];
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
    
//    
    CGRect tableRect = CGRectMake(0, 64, WIN_WIDTH, WIN_HEIGHT - 64 - CGRectGetHeight(_footerView.frame));
    _iftTableView = [[MHTableViewControllerInternalV2 alloc] initWithStyle:UITableViewStyleGrouped];
    _iftTableView.delegate = self;
    if(!_sysIFTGroup) _sysIFTGroup = [NSArray new];
    _iftTableView.dataSource = @[_sysIFTGroup];
    _iftTableView.cellClass = [MHACPartnerSceneCell class];
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

- (void)loadStatus {
    self.sceneManager = [MHIFTTTManager sharedInstance];
    [self.sceneManager getAllRecomRecordsCompletion:nil];
    [self.sceneManager getTemplateCompletion:nil];

    [self loadIFTTTRecords];
}

- (void)dataConstruct {
    _sysIFTGroup = @[
                     @{
                         @"name" : NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm", @"plugin_gateway", nil),
                         @"detail" : NSLocalizedStringFromTable(@"mydevice.gateway.scene.sys.detail.alarm", @"plugin_gateway", nil),
                         @"icon" : @"gateway_home_page_alarm_off",
                         @"QA" : @"cell1",
                         },
//                     @{
//                         @"name" : NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight", @"plugin_gateway", nil),
//                         @"detail" : NSLocalizedStringFromTable(@"mydevice.gateway.scene.sys.detail.nightlight", @"plugin_gateway", nil),
//                         @"icon" : @"gateway_home_page_light_off",
//                         @"QA" : @"cell2",
//                         },
//                     @{
//                         @"name" : NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.timer.cap", @"plugin_gateway", nil),
//                         @"detail" : NSLocalizedStringFromTable(@"mydevice.gateway.scene.sys.detail.timerlight", @"plugin_gateway", nil),
//                         @"icon" : @"gateway_home_page_timing_light",
//                         },
//                     @{
//                         @"name" : NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmclock", @"plugin_gateway", nil),
//                         @"detail" : NSLocalizedStringFromTable(@"mydevice.gateway.scene.sys.detail.alarmclock", @"plugin_gateway", nil),
//                         @"icon" : @"gateway_home_page_clock",
//                         },
                     @{
                         @"name" : NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell", @"plugin_gateway", nil),
                         @"detail" : NSLocalizedStringFromTable(@"mydevice.gateway.scene.sys.detail.doorbell", @"plugin_gateway", nil),
                         @"icon" : @"gateway_home_page_doorbell",
                         },
                     ];
    [self reloadTableView];
}

- (void)reloadTableView {
//    if(!_customIFTGroup) _customIFTGroup = [NSMutableArray new];
//    if (_sysIFTGroup.count) {
//        _iftTableView.dataSource = @[_customIFTGroup, _sysIFTGroup];
//    }
//    else {
//        _iftTableView.dataSource = @[_customIFTGroup];
//    }
//        _footerView.backgroundColor = [UIColor whiteColor];
//    [_iftTableView stopRefreshAndReload];
    
    if(!_sysIFTGroup) _sysIFTGroup = [NSArray new];
    if(!_customIFTGroup) _customIFTGroup = [NSMutableArray new];
    if (_customIFTGroup.count && _recomIFTGroup.count) {
        _iftTableView.dataSource = @[_sysIFTGroup,_customIFTGroup, _recomIFTGroup];
    }
    else if (_customIFTGroup.count && !_recomIFTGroup.count) {
//        _footerView.backgroundColor = [UIColor whiteColor];
        _iftTableView.dataSource = @[_sysIFTGroup,_customIFTGroup];
        }
    else if (!_customIFTGroup.count && _recomIFTGroup.count) {
        //        _footerView.backgroundColor = [UIColor whiteColor];
        _iftTableView.dataSource = @[_sysIFTGroup,_recomIFTGroup];
    }
    else {
        _iftTableView.dataSource = @[_sysIFTGroup];
//        _footerView.backgroundColor = [UIColor colorWithRed:239.f/255.f green:239.f/255.f blue:244.f/255.f alpha:1.f];
    }
    
    [_iftTableView stopRefreshAndReload];
}

#pragma mark - button
- (void)onAddDevice:(id)sender {
    XM_WS(weakself);
    if (self.acpartner.shareFlag == MHDeviceShared) {
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.timersetting.noright", @"plugin_gateway", "被分享设备无此权限") duration:1.0 modal:NO];
        return;
    }
    MHDataIFTTTRecord *selectedRecord = nil;
    
    
    MHIFTTTEditViewController* editVC = [MHIFTTTEditViewController new];
    editVC.record = selectedRecord;
    editVC.editCompletion = ^(MHDataIFTTTRecord *record) {
        [[MHIFTTTManager sharedInstance].recordList addObject:record];
        [weakself.navigationController popToViewController:weakself.parentViewController animated:YES];
    };
    editVC.recordDeleted = ^(MHDataIFTTTRecord* record) {
        [weakself.navigationController popToViewController:weakself.parentViewController animated:YES];
    };
    [self.navigationController pushViewController:editVC animated:YES];
//    if(self.iftttCellClicked)self.iftttCellClicked(nil);
    [self gw_clickMethodCountWithStatType:@"editAutomation:"];
}

#pragma mark - 自动化日志
- (void)onSceneLog:(id)sender {
    //    if (_device.shareFlag == MHDeviceShared) {
    //        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.timersetting.noright", @"plugin_gateway", "被分享设备无此权限") duration:1.0 modal:NO];
    //        return;
    //    }
    
    MHGatewaySceneLogViewController* logVC = [[MHGatewaySceneLogViewController alloc] initWithGateway:self.acpartner];
    [self.navigationController pushViewController:logVC animated:YES];
//    if(self.sceneLogClicked) {
//        self.sceneLogClicked();
//    }
    [self gw_clickMethodCountWithStatType:@"openAutomationLog:"];

}

- (void)loadIFTTTRecords {
    XM_WS(weakself);
    
//    
    __block NSMutableArray *dids = [NSMutableArray new];
    [dids addObject:_acpartner.did];
//    for (MHDeviceGatewayBase *sensor in _gateway.subDevices){
//        if(sensor.isOnline) [dids addObject:sensor.did];
//    }
    
    [self.acpartner.subDevices enumerateObjectsUsingBlock:^(MHDeviceGatewayBase *sensor, NSUInteger idx, BOOL * _Nonnull stop) {
        if(sensor.isOnline) [dids addObject:sensor.did];
    }];
    

    
    [[MHIFTTTManager sharedInstance] getRecordsOfDevices:dids completion:^(NSArray *array) {
        weakself.customIFTGroup = [array mutableCopy];
        [weakself reloadTableView];
    }];

    
    [[MHIFTTTManager sharedInstance] getRecomRecordOfDevice:self.acpartner.did completion:^(NSArray *array) {
        weakself.recomIFTGroup = [array mutableCopy];
        [weakself reloadTableView];
    }];
    
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
    if (section == 0) {
        detailLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.scene.sys", @"plugin_gateway", nil);
    }
    else if (section == 1 && _customIFTGroup.count) {
        detailLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.scene.custom", @"plugin_gateway", nil);
    }
    else if (section == 1 && !_customIFTGroup.count && _recomIFTGroup.count) {
        detailLabel.text = NSLocalizedStringFromTable(@"ifttt.scene.recom", @"plugin_gateway", nil);
    }
    else if (section == 2) {
        detailLabel.text = NSLocalizedStringFromTable(@"ifttt.scene.recom", @"plugin_gateway", nil);
    }
    [headerView addSubview:detailLabel];
    
    UIView *bottomeLine = [[UIView alloc] initWithFrame:CGRectMake(20.0f, 39.f, WIN_WIDTH - 40.f, 0.5)];
    bottomeLine.backgroundColor = [MHColorUtils colorWithRGB:0xD1D1D1];
    [headerView addSubview:bottomeLine];
    
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sectionCount = 1;
    if (_customIFTGroup.count > 0) {
        sectionCount += 1;
    }
    if (_recomIFTGroup.count > 0) {
        sectionCount += 1;
    }
    return sectionCount;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TableViewCellHeight;
}

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *sysCellIdentifier = @"sysCell";
    static NSString *customCellIdentifier = @"customCell";
    static NSString *recomCellIdentifier = @"recomCell";

    if(indexPath.section == 0){
        id obj = _sysIFTGroup[indexPath.row];
        MHGatewaySysCell* cell = (MHGatewaySysCell *)[self.iftTableView.tableView dequeueReusableCellWithIdentifier:sysCellIdentifier];
        [cell configureWithDataObject:obj];
        return cell;
    }
    else if(indexPath.section == 1 && _customIFTGroup.count > 0) {
        MHDataIFTTTRecord *record = _customIFTGroup[indexPath.row];
        MHGatewaySysCell *cell = (MHGatewaySysCell *)[self.iftTableView.tableView dequeueReusableCellWithIdentifier:customCellIdentifier];
        [cell configureWithDataObject:record];
        [self gw_clickMethodCountWithStatType:@"editAutomation:"];
        return cell;
    }
    else {
        MHDataIFTTTRecomRecord *record = _recomIFTGroup[indexPath.row];
        MHGatewaySysCell *cell = (MHGatewaySysCell *)[self.iftTableView.tableView dequeueReusableCellWithIdentifier:recomCellIdentifier];
        [cell configureWithDataObject:record];
        [self gw_clickMethodCountWithStatType:@"editAutomation:"];
        return cell;
    }

}

- (void)extraConfigureCell:(UITableViewCell *)cell withDataObject:(id)object {
    if ([object isKindOfClass:[MHDataIFTTTRecord class]]) {
        MHGatewaySysCell *scene = (MHGatewaySysCell *)cell;
        MHDataIFTTTRecord *record = (MHDataIFTTTRecord *)object;
        XM_WS(weakself);
        scene.relocateRecordBlock = ^{
            NSLog(@"%@", record);
            [weakself retryLocal:record];
        };
        [scene setOfflineRecord:^(MHDataIFTTTRecord *offlineRecord) {
//            [weakself openRecordEdit:offlineRecord];
            [weakself offlineClicked:offlineRecord];
//            if (weakself.offlineRecord) {
//                weakself.offlineRecord(offlineRecord);
//            }
        }];
    }
}



- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        [self sysIftCellSelected:(ACSysIftType)indexPath.row];
//        if(self.sysIftCellClicked)self.sysIftCellClicked((ACSysIftType)indexPath.row);
    }
    else {
        id record = nil;
        if(indexPath.section == 1 && _customIFTGroup.count > 0){
            record = _customIFTGroup[indexPath.row];
        }
        else {
            record = _recomIFTGroup[indexPath.row];
        }
        [self openRecordEdit:record];
//        if(self.iftttCellClicked)self.iftttCellClicked(record);

    }
    
}

- (UITableViewCellEditingStyle)editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1 && _customIFTGroup.count > 0) return UITableViewCellEditingStyleDelete;
    else return UITableViewCellEditingStyleNone;

}

- (void)commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.acpartner.shareFlag == MHDeviceShared) {
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.timersetting.noright", @"plugin_gateway", "被分享设备无此权限") duration:1.0 modal:NO];
        return;
    }
    XM_WS(weakself);
    if (editingStyle == UITableViewCellEditingStyleDelete){
        MHDataIFTTTRecord *record = _customIFTGroup[indexPath.row];
        [self.sceneManager deleteRecord:record success:^{
            [weakself.customIFTGroup removeObject:record];
            [weakself reloadTableView];
//            [weakself.iftTableView stopRefreshAndReload];
            
        } failure:^(NSError *error){
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"delete.failed", @"plugin_gateway", nil) duration:1.f modal:YES];
        }];
        [self gw_clickMethodCountWithStatType:@"DeleteAutomation:"];
    }
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
    } withTitle:strTitle message:nil style:UIAlertViewStyleDefault defaultText:nil cancelButtonTitle:nil otherButtonTitlesArray:buttonArray];
    
    
}


- (UIView*)emptyView {
    UIView *messageView = [[UIView alloc] initWithFrame:self.view.bounds];
    [messageView setBackgroundColor:[MHColorUtils colorWithRGB:0xefefef alpha:0.4f]];
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableview_blank_logo"]];
    [messageView addSubview:icon];
    CGRect frame = icon.frame;
    frame.origin.x = messageView.bounds.size.width / 2.0f - icon.frame.size.width / 2.0f;
    frame.origin.y = CGRectGetHeight(self.view.bounds) * 2.f / 5.f;
    [icon setFrame:frame];
    UIView *sep = [[UIView alloc] initWithFrame:CGRectMake((messageView.frame.size.width - 180) / 2, CGRectGetMaxY(icon.frame) + 5.f , 180, 1.0f)];
    [sep setBackgroundColor:[MHColorUtils colorWithRGB:0xe6e6e6]];
    [messageView addSubview:sep];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(sep.frame.origin.x, CGRectGetMaxY(sep.frame) + 8.0f, sep.frame.size.width, 19.0f)];
    label.text = NSLocalizedStringFromTable(@"mydevice.gateway.scene.list.none", @"plugin_gateway", @"列表内容为空");
    label.textAlignment = NSTextAlignmentCenter;
    [label setTextColor:[MHColorUtils colorWithRGB:0xcfcfcf]];
    [label setFont:[UIFont systemFontOfSize:13.0f]];
    [messageView addSubview:label];
    UIView *sep2 = [[UIView alloc] initWithFrame:CGRectMake(sep.frame.origin.x, CGRectGetMaxY(label.frame) + 8.0f, sep.frame.size.width, sep.frame.size.height)];
    [messageView addSubview:sep2];
    [sep2 setBackgroundColor:[MHColorUtils colorWithRGB:0xe6e6e6]];
    
    return messageView;
}

#pragma mark - 系统自动化
- (void)sysIftCellSelected:(ACSysIftType)type {
    switch (type) {
        case Acpartner_System_Scene_Alarm:
            [self openAlarmSettingPage];
            break;
        case Acpartner_System_Scene_DoorBell :
            [self openDoorBell];
            break;
        default:
            break;
    }
}


- (void)openAlarmSettingPage {
    MHGatewayAlarmSettingViewController* alarmSettingVC = [[MHGatewayAlarmSettingViewController alloc] initWithGateway:self.acpartner];
    alarmSettingVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm", @"plugin_gateway","警戒模式");
    alarmSettingVC.isTabBarHidden = YES;
    [self.navigationController pushViewController:alarmSettingVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"openAlarmSettingPage"];
}

- (void)openDoorBell {
    MHGatewayDoorBellSettingViewController* doorBellSettingVC = [[MHGatewayDoorBellSettingViewController alloc] initWithGateway:self.acpartner];
    doorBellSettingVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.settingcell", @"plugin_gateway","门铃设置");
    doorBellSettingVC.isTabBarHidden = YES;
    [self.navigationController pushViewController:doorBellSettingVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"openDoorBellSettingPage"];
}

- (void)openRecordEdit:(id)sender {
    XM_WS(weakself);
    MHDataIFTTTRecord *selectedRecord = nil;
    
    //自定义自动化
    if([sender isKindOfClass:NSClassFromString(@"MHDataIFTTTRecord")]){
        selectedRecord = sender;
    }
    //推荐自动化
    else if([sender isKindOfClass:NSClassFromString(@"MHDataIFTTTRecomRecord")]){
        selectedRecord = [sender bestFitRecord];
    }
    
    MHIFTTTEditViewController* editVC = [MHIFTTTEditViewController new];
    editVC.record = selectedRecord;
    editVC.editCompletion = ^(MHDataIFTTTRecord *record) {
        [[MHIFTTTManager sharedInstance].recordList addObject:record];
        [weakself.navigationController popToViewController:weakself.parentViewController animated:YES];
    };
    editVC.recordDeleted = ^(MHDataIFTTTRecord* record) {
        [weakself.navigationController popToViewController:weakself.parentViewController animated:YES];
    };
    [self.navigationController pushViewController:editVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"editAutomation:"];
}

- (void)offlineClicked:(MHDataIFTTTRecord *)selectedRecord {
    NSString *strDelete = NSLocalizedStringFromTable(@"ifttt.scene.local.scene.log.scenedelete.confirm", @"plugin_gateway", "我知道了");
    NSString *strRetry = NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.switch.see", @"plugin_gateway", "去看看");
    NSString *strTitle = nil;
    NSArray *buttonArray = nil;
    
    strTitle = NSLocalizedStringFromTable(@"ifttt.scene.local.delete.alert.offline.title", @"plugin_gateway", "自动化中有设备离线了,快去看看吧");
    buttonArray = @[ strDelete, strRetry ];
    
    
    XM_WS(weakself);
    [[MHPromptKit shareInstance] showAlertWithHandler:^(NSInteger buttonIndex, NSArray *inputs) {
        switch (buttonIndex) {
            case 0: {
                //我知道了
            }
                break;
            case 1: {
                //去看看
                MHIFTTTEditViewController* editVC = [MHIFTTTEditViewController new];
                editVC.record = selectedRecord;
                editVC.editCompletion = ^(MHDataIFTTTRecord *record) {
                    [[MHIFTTTManager sharedInstance].recordList addObject:record];
                    [weakself.navigationController popToViewController:weakself.parentViewController animated:YES];
                };
                editVC.recordDeleted = ^(MHDataIFTTTRecord* record) {
                    [weakself.navigationController popToViewController:weakself.parentViewController animated:YES];
                };
                [weakself.navigationController pushViewController:editVC animated:YES];
            }
                break;
                
            default:
                break;
        }
    } withTitle:@"" message:strTitle style:UIAlertViewStyleDefault defaultText:nil cancelButtonTitle:nil otherButtonTitlesArray:buttonArray];
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
