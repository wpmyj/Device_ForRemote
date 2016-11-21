//
//  MHIFTTTACPartnerCustomizeViewController.m
//  MiHome
//
//  Created by ayanami on 16/5/26.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHIFTTTACPartnerCustomizeViewController.h"
#import "MHIFTTTManager.h"
#import "MHDeviceAcpartner.h"
#import "MHACPartnerPreferencesViewController.h"
#import "MHIFTTTLmCustomizeManager.h"
#import "MHIFTTTFMChooseViewController.h"

#define kACPARTNER_ON_ACTIONID      @"283"
#define kACPARTNER_OFF_ACTIONID     @"284"
#define kACPARTNER_TOGGLE_ACTIONID  @"285"
#define kACPARTNER_GROUP_ACTIONID   @"286"
#define kACPARTNER_MORE_ACTIONID    @"385"
#define kACPARTNER_FM_ACTIONID      @"299"


@interface MHIFTTTACPartnerCustomizeViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) MHDeviceAcpartner *acpartner;
@property (nonatomic,strong) MHIFTTTFMChooseViewController *fmListView;
@property (nonatomic,assign) NSInteger selectedMid;
@property (nonatomic,assign) NSInteger selectedVolume;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSString *itemName;

@end

@implementation MHIFTTTACPartnerCustomizeViewController
+ (void)load {
    [MHIFTTTManager registerActionCustomViewController:self actionId:kACPARTNER_ON_ACTIONID];
    [MHIFTTTManager registerActionCustomViewController:self actionId:kACPARTNER_OFF_ACTIONID];
    [MHIFTTTManager registerActionCustomViewController:self actionId:kACPARTNER_TOGGLE_ACTIONID];
    [MHIFTTTManager registerActionCustomViewController:self actionId:kACPARTNER_GROUP_ACTIONID];
//    [MHIFTTTManager registerActionCustomViewController:self actionId:kACPARTNER_MORE_ACTIONID];
    [MHIFTTTManager registerActionCustomViewController:self actionId:kACPARTNER_FM_ACTIONID];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isTabBarHidden = YES;
    
//    NSLog(@"%@", NSStringFromClass([self.device class]));
//    NSLog(@"%@", self.device);
//    [MHDevFactory deviceFromModelId:newDevice.model dataDevice:newDevice];
//    NSLog(@"%@", self.acpartner.did);
    
        NSLog(@"自动化中的空调type<<%d>>", self.acpartner.ACType);
    
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.control",@"plugin_gateway","空调控制");
        if ([self.action.actionId isEqualToString:kACPARTNER_FM_ACTIONID]) {
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.scene.edit.music.fm.title", @"plugin_gateway", nil);
    }
}

- (void)buildSubviews {
    [super buildSubviews];
    self.acpartner = (MHDeviceAcpartner *)self.device;
    [self.acpartner registerAppAndInit];
    [self.acpartner restoreACStatus];
    
    

    XM_WS(weakself);
    NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithDictionary:self.action.payload];

    if ([self.action.actionId isEqualToString:kACPARTNER_ON_ACTIONID]){
        //        [payload setObject:self.device.did forKey:@"did"];
        
        NSLog(@"当前的空调类型%d", self.acpartner.ACType);
        if (self.acpartner.brand_id == 0 || self.acpartner.ACType == 0) {
            [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.first",@"plugin_gateway", "请先添加空调") duration:1.5f modal:NO];
            return;
        }
        NSString *strCommand = [self.acpartner getACCommand:SCENE_ON_INDEX commandIndex:POWER_COMMAND isTimer:NO];
        NSString *strHex = [strCommand substringWithRange:NSMakeRange(10, 8)];
        uint32_t value = (uint32_t)strtoul([strHex UTF8String], 0, 16);
                NSString *strValue = [NSString stringWithFormat:@"%d", value];
        NSLog(@"%@", @(0x12001101));
                    [payload setObject:strValue forKey:@"value"];
//        [payload setObject:@(value) forKey:@"value"];
        
    }
    if ([self.action.actionId isEqualToString:kACPARTNER_OFF_ACTIONID]){
        if (self.acpartner.brand_id == 0 || self.acpartner.ACType == 0) {
            [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.first",@"plugin_gateway", "请先添加空调") duration:1.5f modal:NO];
            return;
        }
        NSString *strCommand = [self.acpartner getACCommand:SCENE_OFF_INDEX commandIndex:POWER_COMMAND isTimer:NO];
        NSLog(@"%@", strCommand);
        NSString *strHex = [strCommand substringWithRange:NSMakeRange(10, 8)];
        uint32_t value = (uint32_t)strtoul([strHex UTF8String], 0, 16);
                NSString *strValue = [NSString stringWithFormat:@"%d", value];
                [payload setObject:strValue forKey:@"value"];
//        [payload setObject:@(value) forKey:@"value"];
        
    }
    if ([self.action.actionId isEqualToString:kACPARTNER_TOGGLE_ACTIONID]){
        if (self.acpartner.brand_id == 0 || self.acpartner.ACType == 0) {
            [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.first",@"plugin_gateway", "请先添加空调") duration:1.5f modal:NO];
            return;
        }
        NSString *strTogggle = [self.acpartner getACCommand:SCENE_TOGGLE_INDEX commandIndex:POWER_COMMAND isTimer:NO];
        NSLog(@"%@", strTogggle);
        NSString *strHex = [strTogggle substringWithRange:NSMakeRange(10, 8)];
        uint32_t value = (uint32_t)strtoul([strHex UTF8String], 0, 16);
                NSString *strValue = [NSString stringWithFormat:@"%d", value];
                [payload setObject:strValue forKey:@"value"];
//        [payload setObject:@(value) forKey:@"value"];
        
    }
    //开到指定状态
    if ([self.action.actionId isEqualToString:kACPARTNER_GROUP_ACTIONID]){
        if (self.acpartner.brand_id == 0 || self.acpartner.ACType == 0) {
            [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.first",@"plugin_gateway", "请先添加空调") duration:1.5f modal:NO];
            return;
        }
        if (self.acpartner.ACType == 1) {
            [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.unavailable",@"plugin_gateway", "此空调不支持此选项") duration:1.5f modal:NO];
            return;
        }
        MHACPartnerPreferencesViewController *preferences = nil;
        if (self.action.payload[@"value"]) {
            NSLog(@"%@", self.action.payload);
            [self.acpartner analyzeHexInfo:nil decimalInfo:[self.action.payload[@"value"] intValue] type:PROP_TIMER];
            preferences = [[MHACPartnerPreferencesViewController alloc] initWithTimer:[[MHDataDeviceTimer alloc] init] andAcpartner:self.acpartner];
        }
        else {
            preferences = [[MHACPartnerPreferencesViewController alloc] initWithAcpartner:self.acpartner];
        }
        
        [self.view addSubview:preferences.view];
        [self addChildViewController:preferences];
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 44, 26);
        [btn setBackgroundColor:[MHColorUtils colorWithRGB:0x1dc58a]];
        [btn setTitle:NSLocalizedStringFromTable(@"Ok",@"plugin_gateway", "确定") forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13.f];
        btn.layer.cornerRadius = 3.0f;
        [btn addTarget:self action:@selector(onDone:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        
    }
     else if ([self.action.actionId isEqualToString:kACPARTNER_MORE_ACTIONID]){
         if (self.acpartner.brand_id == 0 || self.acpartner.ACType == 0) {
             [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.first",@"plugin_gateway", "请先添加空调") duration:1.5f modal:NO];
             return;
         }

         self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT) style:UITableViewStylePlain];
         self.tableView.delegate = self;
         self.tableView.dataSource = self;
         self.tableView.tableFooterView = [UIView new];
         [self.view addSubview:self.tableView];
         
         [self.acpartner getLearnedRemoteListSuccess:^(id obj) {
             NSLog(@"%@", weakself.acpartner.customFunctionList);
             [weakself.tableView reloadData];
         } failure:^(NSError *v) {
             
         }];
//         if (self.action.payload[@"value"]) {
//             NSLog(@"%@", self.action.payload);
//             [self.acpartner.customFunctionList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                 
//             }];
//             [self.acpartner analyzeHexInfo:nil decimalInfo:[self.action.payload[@"value"] intValue] type:PROP_TIMER];
//             
//         }
        
 
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 44, 26);
        [btn setBackgroundColor:[MHColorUtils colorWithRGB:0x1dc58a]];
        [btn setTitle:NSLocalizedStringFromTable(@"Ok",@"plugin_gateway", "确定") forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13.f];
        btn.layer.cornerRadius = 3.0f;
        [btn addTarget:self action:@selector(onDone:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        
    }
    else if ([self.action.actionId isEqualToString:kACPARTNER_FM_ACTIONID]) {
        _fmListView = [[MHIFTTTFMChooseViewController alloc] initWithGateway:(MHDeviceGateway *)self.device];
        _fmListView.onSelectMusicMid = ^(NSInteger mid){
            weakself.selectedMid = mid;
        };
        _fmListView.onSelectMusicVolume = ^(NSInteger volume){
            weakself.selectedVolume = volume;
        };
        [self.view addSubview:_fmListView.view];
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 44, 26);
        [btn setBackgroundColor:[MHColorUtils colorWithRGB:0x1dc58a]];
        [btn setTitle:NSLocalizedStringFromTable(@"Ok",@"plugin_gateway", "确定") forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13.f];
        btn.layer.cornerRadius = 3.0f;
        [btn addTarget:self action:@selector(onDone:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
    else {
        if(self.completionHandler)self.completionHandler(payload);
    }

    
}

- (void)onDone:(id)sender {
    NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithDictionary:self.action.payload];
    if ([self.action.actionId isEqualToString:kACPARTNER_FM_ACTIONID]){
        if (_selectedMid != -1){
            NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithDictionary:self.action.payload];
            NSArray *fmValueStr = [NSArray arrayWithObjects:@((long)_selectedMid),@((long)_selectedVolume), nil];
            [payload setObject:fmValueStr forKey:@"value"];
            if(self.completionHandler)self.completionHandler(payload);
            [self onBack:nil];
        }
        else {
            NSString *tips = NSLocalizedStringFromTable(@"mydevice.gateway.scene.edit.music.fm.choosetips", @"plugin_gateway", nil);
            [[MHTipsView shareInstance] showFailedTips:tips duration:1.5 modal:NO];
        }
    }
    if ([self.action.actionId isEqualToString:kACPARTNER_GROUP_ACTIONID]){
        if (self.acpartner.ACType == 2) {
            self.acpartner.timerPowerState = 1;
            [self.acpartner.kkAcManager changePowerStateWithPowerstate:AC_POWER_ON];
            [self.acpartner.kkAcManager getPowerState];
            [self.acpartner.kkAcManager getAirConditionInfrared];
            
            [self.acpartner judgeModeCanControl:PROP_TIMER];
            [self.acpartner judgeWindsCanControl:PROP_TIMER];
            [self.acpartner judgeSwipCanControl:PROP_TIMER];
            [self.acpartner judgeTempratureCanControl:PROP_TIMER];
        }

        NSString *strOpen = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.scene.opentitle", @"plugin_gateway", "开空调并调至");
//        NSString *strMode = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.mode",@"plugin_gateway","模式");
//        NSString *strWindSpeed = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.fanspeed",@"plugin_gateway","风速");
//        NSString *strTemp = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.timer.temperature",@"plugin_gateway","温度");
//
        NSString *strOn = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.type.manual.button.on",@"plugin_gateway","开");
        NSString *strOff = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.type.manual.button.off",@"plugin_gateway","关");
        NSLog(@"改之前%@", self.action.name);
        
        NSString *strWindSwing = [NSString stringWithFormat:@"%@%@", NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.airswing",@"plugin_gateway","扫风"), self.acpartner.timerWindState ? strOff : strOn];
        self.action.name = [NSString stringWithFormat:@"%@ %d℃ %@ %@ %@", strOpen,self.acpartner.timerTemperature,modeArray[self.acpartner.timerModeState], windPowerArray[self.acpartner.timerWindPower], strWindSwing];
        
        NSLog(@"改之后%@", self.action.name);

        
        NSString *strCommand = [self.acpartner getACCommand:SCENE_AC_INDEX commandIndex:TIMER_COMMAND isTimer:NO];
       
        NSString *strHex = [strCommand substringWithRange:NSMakeRange(10, 8)];
        uint32_t value = (uint32_t)strtoul([strHex UTF8String], 0, 16);
                NSString *strValue = [NSString stringWithFormat:@"%d", value];
//        [payload setObject:@(value) forKey:@"value"];
            [payload setObject:strValue forKey:@"value"];
        if (self.acpartner.ACType == 2) {
            [self.acpartner resetAcStatus];
        }
        XM_WS(weakself);
        [[MHTipsView shareInstance] showTips:@"" modal:YES];
        NSLog(@"类型%d", self.acpartner.ACType);
        NSLog(@"保存的命令%@", strCommand);
        [self.acpartner saveCommandMap:strCommand success:^(id obj) {
            [[MHTipsView shareInstance] hide];
            if(weakself.completionHandler)weakself.completionHandler(payload);
        } failure:^(NSError *v) {
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"operation.failed", @"plugin_gateway",@"操作失败，请检查网络") duration:1.5f modal:YES];
        }];
    }
    if ([self.action.actionId isEqualToString:kACPARTNER_MORE_ACTIONID]){
        
        XM_WS(weakself);
        __block NSString *strCmd = nil;
        [self.acpartner.customFunctionList enumerateObjectsUsingBlock:^(NSDictionary *dataDic, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([dataDic[kACNameKey] isEqualToString:weakself.itemName]) {
                uint32_t value = (uint32_t)strtoul([dataDic[kACShortCmdKey] UTF8String], 0, 16);
                NSString *strValue = [NSString stringWithFormat:@"%d", value];
                //        [payload setObject:@(value) forKey:@"value"];
                [payload setObject:strValue forKey:@"value"];
                strCmd = dataDic[kACCmdKey];
                *stop = YES;
            }
        }];
        [[MHTipsView shareInstance] showTips:@"" modal:YES];

        [self.acpartner saveCommandMap:strCmd success:^(id obj) {
            [[MHTipsView shareInstance] hide];
            if(weakself.completionHandler)weakself.completionHandler(payload);
        } failure:^(NSError *v) {
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"operation.failed", @"plugin_gateway",@"操作失败，请检查网络") duration:1.5f modal:YES];
        }];
    }
    
}
- (void)onBack:(id)sender {
    if ([self.action.actionId isEqualToString:kACPARTNER_FM_ACTIONID]){
        [self.acpartner setSoundPlaying:@"off" success:nil failure:nil];
    }
    [super onBack:sender];
}


#pragma mark - 更多功能
#pragma mark - UITableViewDelegate&DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *dataDic = self.acpartner.customFunctionList[indexPath.row];
    self.itemName = dataDic[kACNameKey];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.acpartner.customFunctionList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static  NSString *reuseID = @"customFunc";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
    }
    NSDictionary *dataDic = self.acpartner.customFunctionList[indexPath.row];
    if ([dataDic[kACNameKey] isEqualToString:self.itemName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = dataDic[kACNameKey];
    return cell;
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
