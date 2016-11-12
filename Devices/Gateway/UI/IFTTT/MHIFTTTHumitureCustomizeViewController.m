//
//  MHIFTTTHumitureCustomizeViewController.m
//  MiHome
//
//  Created by Lynn on 1/28/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHIFTTTHumitureCustomizeViewController.h"
#import "MHIFTTTManager.h"
#import "MHIFTTTLmCustomizeManager.h"

#define PanelHeight     100.f


#define kTemp_High_TriggerID        @"62"
#define kTemp_Low_TriggerID         @"63"
#define kHumi_High_TriggerID        @"64"
#define kHumi_Low_TriggerID         @"65"

@interface MHIFTTTHumitureCustomizeViewController () <UITableViewDelegate,UITableViewDataSource>

@end

@implementation MHIFTTTHumitureCustomizeViewController
{
    UITableView*            _tableView;
    BOOL                    _isTmp;
    NSInteger               _selectedRow;
}


+ (void)load {
    //        [MHIFTTTManager registerTriggerCustomViewController:self triggerId:<#(NSString *)#>
//        [MHIFTTTManager registerCustomViewControllerClass:self forModel:@"lumi.sensor_ht.v1" plugId:Humiture_PlugInID];
        [MHIFTTTManager registerTriggerCustomViewController:self triggerId:kTemp_High_TriggerID];
        [MHIFTTTManager registerTriggerCustomViewController:self triggerId:kTemp_Low_TriggerID];
        [MHIFTTTManager registerTriggerCustomViewController:self triggerId:kHumi_High_TriggerID];
        [MHIFTTTManager registerTriggerCustomViewController:self triggerId:kHumi_Low_TriggerID];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.isTabBarHidden = YES;
    self.isNavBarHidden = NO;

    
    self.title = self.trigger.name;
    
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmBtn.frame = CGRectMake(0, 0, 46, 26);
    [confirmBtn setBackgroundColor:[MHColorUtils colorWithRGB:0x1dc58a]];
    [confirmBtn setTitle:NSLocalizedStringFromTable(@"Ok", @"plugin_gateway","确定") forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:13.f];
    confirmBtn.layer.cornerRadius = 3.0f;
    [confirmBtn addTarget:self action:@selector(onDone:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:confirmBtn];
}

- (void)buildSubviews {
    [super buildSubviews];
//    NSLog(@"trigger%@", self.trigger.value);
//    NSLog(@"%@", self.trigger.value[@"min"]);
    _selectedRow = -1;
    if(self.trigger){
        NSString *key = [[MHIFTTTLmCustomizeManager sharedInstance] fetchSpecificLaunchKey:self.trigger];
        if([key isEqualToString:Humiture_IFTTT_Temperature]) _isTmp = YES;
        else _isTmp = NO;
    }
    //编辑
    if ([self.trigger.value isKindOfClass:[NSDictionary class]] && [self.trigger.value count] > 1) {
        if ([self.trigger.triggerId isEqualToString:kTemp_High_TriggerID]) {
            _selectedRow = [self.trigger.value[@"min"] integerValue] / 100 + 19;
        }
        if ([self.trigger.triggerId isEqualToString:kTemp_Low_TriggerID]) {
            _selectedRow = [self.trigger.value[@"max"] integerValue] / 100 + 19;
        }
        if ([self.trigger.triggerId isEqualToString:kHumi_High_TriggerID]) {
            _selectedRow = [self.trigger.value[@"min"] integerValue] / 100 - 1;
            
        }
        if ([self.trigger.triggerId isEqualToString:kHumi_Low_TriggerID]) {
            _selectedRow = [self.trigger.value[@"max"] integerValue] / 100 - 1;
        }
    }

    
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    NSIndexPath *indexPath = nil;
    if(_isTmp){
        if([[[self.trigger.value allKeys] firstObject] isEqualToString:@"max"]) {
            indexPath = [NSIndexPath indexPathForRow:_selectedRow == -1 ? 20 : _selectedRow inSection:0];
        }
        else if ([[[self.trigger.value allKeys] firstObject] isEqualToString:@"min"]) {
            indexPath = [NSIndexPath indexPathForRow:_selectedRow == -1 ? 50 : _selectedRow inSection:0];
        }
    }
    else {
        if([[[self.trigger.value allKeys] firstObject] isEqualToString:@"max"])
            indexPath = [NSIndexPath indexPathForRow:_selectedRow == -1 ? 40 : _selectedRow inSection:0];
        else if ([[[self.trigger.value allKeys] firstObject] isEqualToString:@"min"])
            indexPath = [NSIndexPath indexPathForRow:_selectedRow == -1 ? 70 : _selectedRow inSection:0];
    }
//    NSLog(@"%ld", indexPath.row);
    [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - button
- (void)onDone:(id)sender {
    NSMutableDictionary *valueDic = [self.trigger.value mutableCopy];    
        if ([self.trigger.triggerId isEqualToString:kTemp_High_TriggerID]) {
            [valueDic setValue:@(6000) forKey:@"max"];
            [valueDic setValue:@((_selectedRow - 19) * 100) forKey:@"min"];
            self.trigger.name = [NSString stringWithFormat:@"%@%@ ℃", NSLocalizedStringFromTable(@"ifttt.scene.local.scene.ht.temphigh", @"plugin_gateway", @"温度高于"), @(_selectedRow - 19)];
        }
        if ([self.trigger.triggerId isEqualToString:kTemp_Low_TriggerID]) {
            [valueDic setValue:@((_selectedRow - 19) * 100) forKey:@"max"];
            [valueDic setValue:@(-2000) forKey:@"min"];
             self.trigger.name = [NSString stringWithFormat:@"%@%@ ℃", NSLocalizedStringFromTable(@"ifttt.scene.local.scene.ht.templow", @"plugin_gateway", @"温度低于"), @(_selectedRow - 19)];
        }
     

        if ([self.trigger.triggerId isEqualToString:kHumi_High_TriggerID]) {
            [valueDic setValue:@(10000) forKey:@"max"];
            [valueDic setValue:@((_selectedRow + 1) * 100) forKey:@"min"];
            self.trigger.name = [NSString stringWithFormat:@"%@%@ ％", NSLocalizedStringFromTable(@"ifttt.scene.local.scene.ht.humihigh", @"plugin_gateway", @"湿度高于"), @((_selectedRow + 1))];

        }
        if ([self.trigger.triggerId isEqualToString:kHumi_Low_TriggerID]) {
            [valueDic setValue:@((_selectedRow + 1) * 100) forKey:@"max"];
            [valueDic setValue:@(0) forKey:@"min"];
            self.trigger.name = [NSString stringWithFormat:@"%@%@ ％", NSLocalizedStringFromTable(@"ifttt.scene.local.scene.ht.humilow", @"plugin_gateway", @"湿度低于"), @((_selectedRow + 1))];
        }
    if(self.completionHandler)self.completionHandler(valueDic);
}

#pragma mark - table datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(_isTmp) return 79;
    else return 99;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = nil;
    if (_isTmp) {
        title = [NSString stringWithFormat:@"%ld ℃", indexPath.row - 19];
    }
    else {
        title = [NSString stringWithFormat:@"%ld ％", indexPath.row + 1];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = title;
    if(indexPath.row == _selectedRow) cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - table delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedRow = indexPath.row;
    [_tableView reloadData];
}

@end
