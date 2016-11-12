//
//  MHACPartnerAddAcListViewController.m
//  MiHome
//
//  Created by ayanami on 16/5/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerAddAcListViewController.h"
#import "MHACPartnerAddListCell.h"
#import "MHACTypeModel.h"
#import "MHACPartnerAddSucceedViewController.h"
#import "MHACPartnerTypeSearchViewController.h"
#import "MHACPartnerManualMatchViewController.h"
#import "MHACPartnerRemoteMatchViewController.h"
#import "MHLMACTipsView.h"

#define kADDLISTCELLID @"MHACPartnerAddListCell"

@interface MHACPartnerAddAcListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *acListTableView;
@property (nonatomic, retain) NSMutableArray *listArray;
@property (nonatomic, strong) MHDeviceAcpartner *acpartner;

@property (nonatomic, strong) UIButton *determineBtn;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, assign) NSInteger hasSelected;
@property (nonatomic, assign) ACPARTNER_MATCH_MANNER manner;


@property (nonatomic, assign) int number;
@property (nonatomic, assign) NSInteger brandid;
@property (nonatomic, copy) NSString *ACRemoteId;//remoteid
@property (nonatomic, copy) NSString *ACBrand;//品牌


@property (nonatomic, copy) NSString *oldRemoteid;
@property (nonatomic, assign) NSInteger oldBrandid;
@property (nonatomic, assign) int oldType;
@end

@implementation MHACPartnerAddAcListViewController



- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner mactchManner:(ACPARTNER_MATCH_MANNER)manner
{
    self = [super init];
    if (self) {
        self.isTabBarHidden = YES;
        self.acpartner = acpartner;
        self.manner = manner;
        self.oldRemoteid = acpartner.ACRemoteId;
        self.oldBrandid = self.acpartner.brand_id;
        self.oldType = self.acpartner.ACType;
        self.listArray = [NSMutableArray arrayWithArray:self.acpartner.acTypeList];
        
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    "mydevice.gateway.sensor.acpartner.add.wait" = "匹配空调中%@，请稍后...";
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.seleted",@"plugin_gateway","选择空调品牌");
    
    XM_WS(weakself);
    [self.acpartner getACTypeListSuccess:^(id obj) {
        weakself.listArray = obj;
        [weakself.acListTableView reloadData];
    } Failure:^(NSError *v) {
        
    }];
    
    [self.acpartner getCommandMapSuccess:nil failure:nil];
}

- (void)buildSubviews {
    [super buildSubviews];
    self.acListTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.acListTableView.dataSource = self;
    self.acListTableView.delegate = self;
    self.acListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.acListTableView.tableFooterView = [UIView new];
    [self.view addSubview:self.acListTableView];
    
    UIImage* imageMore = [[UIImage imageNamed:@"lumi_fm_radio_search"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *rightItemMore = [[UIBarButtonItem alloc] initWithImage:imageMore style:UIBarButtonItemStylePlain target:self action:@selector(onSearch:)];
    self.navigationItem.rightBarButtonItem = rightItemMore;
    
    _determineBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    NSString *nextStr =  [NSString stringWithFormat:@"%@(2/3)",NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.nextStep",@"plugin_gateway","下一步")];
    
    self.footerView = [[UIView alloc] init];
    self.footerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.footerView];
    
    NSString *nextStr = NSLocalizedStringFromTable(@"mydevice.setting.datepicker.ok",@"plugin_gateway","确认");
//    NSMutableAttributedString *nextTitleAttribute = [[NSMutableAttributedString alloc] initWithString:nextStr];
//    [nextTitleAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x858585] range:NSMakeRange(0, nextStr.length)];
//    [nextTitleAttribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0f] range:NSMakeRange(0, nextStr.length)];
//    [_determineBtn setAttributedTitle:nextTitleAttribute forState:UIControlStateNormal];
    [_determineBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_determineBtn setTitle:nextStr forState:UIControlStateNormal];
    [_determineBtn addTarget:self action:@selector(onDetermine:) forControlEvents:UIControlEventTouchUpInside];
    _determineBtn.layer.cornerRadius = 20.0f;
    _determineBtn.layer.borderWidth = 0.5f;
    _determineBtn.layer.borderColor = [[MHColorUtils colorWithRGB:0xBCBCBC] CGColor];
    _determineBtn.backgroundColor = [MHColorUtils colorWithRGB:0x606060 alpha:0.2];
    _determineBtn.enabled = NO;
    [self.view addSubview:_determineBtn];

}

- (void)buildConstraints {
    XM_WS(weakself);
    [self.acListTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakself.view);
    }];
    
    [self.footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(weakself.view);
        make.height.mas_equalTo(70);
    }];
    
    [self.determineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakself.view.mas_bottom).with.offset(-12);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(WIN_WIDTH - 60, 46));
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.listArray.count;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MHACPartnerAddListCell *cell = [tableView dequeueReusableCellWithIdentifier:kADDLISTCELLID];
    if (cell == nil) {
        cell = [[MHACPartnerAddListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kADDLISTCELLID];
    }
    MHACTypeModel *typeModel = self.listArray[indexPath.section][indexPath.row];
    [cell configureWithDataObject:typeModel];
    if (typeModel.brand_id == self.brandid) {
        cell.nameLabel.textColor = [MHColorUtils colorWithRGB:0x00ba7c];
        cell.arrowImage.hidden = NO;
        self.acpartner.number = typeModel.number;
    }
    else {
        cell.nameLabel.textColor = [MHColorUtils colorWithRGB:0x333333];
        cell.arrowImage.hidden = YES;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 57;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0f;
}

- (NSArray *)memberOfAcListTableView:(NSArray *)object {
    return @[ @"#", @"A", @"B", @"C"];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, 40.0f)];
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, WIN_WIDTH - 70, 30)];
    detailLabel.textAlignment = NSTextAlignmentLeft;
    detailLabel.font = [UIFont systemFontOfSize:14.f];
    detailLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    if (section == 0) {
        detailLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.commonbrand", @"plugin_gateway", "常见品牌");
    }
    else {
        detailLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.allbrand", @"plugin_gateway", "所有品牌");
    }
    [header addSubview:detailLabel];
    return header;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.brandid = [self.listArray[indexPath.section][indexPath.row] brand_id];
    self.number = [self.listArray[indexPath.section][indexPath.row] number];
    self.ACBrand = [self.listArray[indexPath.section][indexPath.row] name];
    _determineBtn.enabled = YES;
    _determineBtn.backgroundColor = [MHColorUtils colorWithRGB:0x00ba7c];
    [_determineBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [tableView reloadData];
    
}


#pragma mark - 搜索
- (void)onSearch:(id)sender {
    XM_WS(weakself);
    MHACPartnerTypeSearchViewController *searchVC = [[MHACPartnerTypeSearchViewController alloc] initWithACList:self.listArray[1]];
    [self.navigationController pushViewController:searchVC animated:YES];
//    [self.acpartner stopScanSuccess:nil failure:nil];
//    [[MHTipsView shareInstance] hide];
    [searchVC setSelectBrand:^(NSInteger brand) {
        weakself.brandid = brand;
        weakself.determineBtn.enabled = YES;
        weakself.determineBtn.backgroundColor = [MHColorUtils colorWithRGB:0x00ba7c];
        [weakself.determineBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [weakself.acListTableView reloadData];
        
        
        __block NSInteger selectRow = 0;
        NSArray *allArray = weakself.listArray[1];
        [allArray enumerateObjectsUsingBlock:^(MHACTypeModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj brand_id] == brand) {
                selectRow = idx;
                *stop = YES;
            }
        }];
        
        NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:selectRow inSection:1];
        
        [weakself.acListTableView scrollToRowAtIndexPath:selectIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }];

}

#pragma mark - 确认
- (void)onDetermine:(id)sender {
    
    self.acpartner.brand_id = self.brandid;
    self.acpartner.number = self.number;
    self.acpartner.ACBrand = self.ACBrand;
    self.acpartner.original_power = self.acpartner.ac_power;
    
    switch (self.manner) {
        case AUTO_MATCH:
            [self onAuto];
            break;
        case MANUAL_MACTCH:
            [self onManual];
            break;
        case REMOTE_MACTCH:
            [self onRemote];
            break;

        default:
            break;
    }
}

- (void)onAuto {
//       [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.wait", @"plugin_gateway", "匹配空调中，请稍后...") modal:YES]; 
    XM_WS(weakself);
    
    
    [self.acpartner getIrCodeListWithBrandId:self.brandid Success:^(id obj) {
        weakself.acpartner.original_power = weakself.acpartner.ac_power;
        weakself.acpartner.number = (int)[weakself.acpartner.codeList count];
        
        [weakself startScanAC];
        
        
    } Failure:^(NSError *error) {
        [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"request.failed", @"plugin_gateway", "请求失败") duration:1.5f modal:NO];
    }];

}

- (void)onManual {
    MHACPartnerManualMatchViewController *irTestVC = [[MHACPartnerManualMatchViewController alloc] initWithAcpartner:self.acpartner];
    irTestVC.oldBrandid = self.oldBrandid;
    irTestVC.oldRemoteid = self.oldRemoteid;
    [self.navigationController pushViewController:irTestVC animated:YES];
}
- (void)onRemote {
    MHACPartnerRemoteMatchViewController *remoteVC = [[MHACPartnerRemoteMatchViewController alloc] initWithAcpartner:self.acpartner];
    [self.navigationController pushViewController:remoteVC animated:YES];
}

- (void)startScanAC {
    
    [[MHLMACTipsView shareInstance] showTips:@"" modal:NO];
    XM_WS(weakself);
    [self.acpartner scanACType:self.acpartner.number success:^(id obj) {
        [[MHLMACTipsView shareInstance] hide];
        [weakself autoMatchSucceed];
    } failure:^(NSError *error) {
        NSLog(@"失败的unknow值%@", weakself.acpartner.unknowState);
        NSLog(@"失败的状态%d", weakself.acpartner.powerState);
        
        if ([error.domain isEqualToString:CancleAutoMatch]) {
            [[MHLMACTipsView shareInstance] hide];
            return;
        }
        
        //不确定开关状态,先当开扫一遍如果失败再当关扫一遍
        if ([weakself.acpartner.unknowState isEqualToString:kUNKNOWSTATE] && weakself.acpartner.powerState == 1) {
            [weakself autoMatchUnknowState];
        }
        else {
            [weakself autoMatchFailed];
        }
        
    }];
}

- (void)autoMatchFailed {
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:[NSString stringWithFormat:@"isfirst%@%@", self.acpartner.ACRemoteId,[MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:[NSString stringWithFormat:@"%@%@", self.acpartner.did, kHASSCANED]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.acpartner setACByModel:kNONACMODEL success:^(id obj) {
        
        
    } failure:^(NSError *v) {
        
    }];

    
    self.acpartner.ACType = 0;
    self.acpartner.ACRemoteId = nil;
    self.acpartner.brand_id = 0;
    [self.acpartner saveACStatus];
    [[MHLMACTipsView shareInstance] hide];
    
   
    [self.acpartner stopScanSuccess:nil failure:nil];
    MHACPartnerAddSucceedViewController *succeedVC = [[MHACPartnerAddSucceedViewController alloc] initWithAcpartner:self.acpartner successType:ADD_AUTO_FAILURE_INDEX];
    [self.navigationController pushViewController:succeedVC animated:YES];
}

- (void)autoMatchSucceed {
    XM_WS(weakself);
    if (self.acpartner.ACType == 2) {
        [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:[NSString stringWithFormat:@"isfirst%@%@", self.acpartner.ACRemoteId,[MHPassportManager sharedSingleton].currentAccount.userId]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:[NSString stringWithFormat:@"%@%@", self.acpartner.did, kHASSCANED]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.acpartner stopScanSuccess:nil failure:nil];
    [self.acpartner saveACStatus];
    [[MHTipsView shareInstance] hide];
    [self.acpartner updateCommandMapSuccess:^(id obj) {
        [weakself.acpartner restoreACStatus];
    } failure:^(NSError *v) {
        
    }];
    
    MHACPartnerAddSucceedViewController *succeedVC = [[MHACPartnerAddSucceedViewController alloc] initWithAcpartner:self.acpartner successType:ADD_SUCCESS_INDEX];
    [self.navigationController pushViewController:succeedVC animated:YES];
}

- (void)autoMatchUnknowState {
    self.acpartner.powerState = 0;
    self.acpartner.unknowState = kCERTAINSTATE;
    [self startScanAC];
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
