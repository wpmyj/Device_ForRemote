//
//  MHLuTimerRepeatTypeVC.m
//  MiHome
//
//  Created by Lynn on 10/16/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLuTimerRepeatTypeVC.h"
#import "MHLuTimerSelfDefineViewController.h"

@implementation MHLuTimerRepeatTypeVC{
    MHDataDeviceTimer*  _timer;
    UITableView*        _tableView;
    NSArray*            _repeatTypes;
}

- (id)initWithTimer:(MHDataDeviceTimer* )timer {
    if (self = [super init]) {
        _timer = timer;
        _repeatTypes = [NSArray arrayWithObjects:
                        NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.once",@"plugin_gateway","执行一次"),
                        NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.everyday",@"plugin_gateway","每天"),
                        NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.workday",@"plugin_gateway","工作日"),
                        NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.weekend",@"plugin_gateway","周末"),
                        NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.selfdefine",@"plugin_gateway","自定义"), nil];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"ddd");
}

- (void)buildSubviews {
    [super buildSubviews];
    
    self.isTabBarHidden = YES;
    self.title = NSLocalizedStringFromTable(@"mydevice.timersetting.repeat",@"plugin_gateway","重复");
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = [MHColorUtils colorWithRGB:0xE1E1E1];
    [self.view addSubview:_tableView];
}

- (void)buildConstraints {
    [super buildConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_tableView reloadData];
}

- (void)updateCell:(UITableViewCell* )cell indexPath:(NSIndexPath* )indexPath {
    cell.textLabel.text = _repeatTypes[indexPath.row];
    
    if (indexPath.row == 0 && _timer.onRepeatType == MHDeviceTimerRepeat_Once) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (indexPath.row == 1 && _timer.onRepeatType == MHDeviceTimerRepeat_Everyday) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (indexPath.row == 2 && _timer.onRepeatType == MHDeviceTimerRepeat_Workday) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (indexPath.row == 3 && _timer.onRepeatType == MHDeviceTimerRepeat_Weekend) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (indexPath.row == 4 &&
               _timer.onRepeatType != MHDeviceTimerRepeat_Once &&
               _timer.onRepeatType != MHDeviceTimerRepeat_Everyday &&
               _timer.onRepeatType != MHDeviceTimerRepeat_Workday &&
               _timer.onRepeatType != MHDeviceTimerRepeat_Weekend) {
        //自定义
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.detailTextLabel.text = [_timer getOnRepeatTypeString];
    } else {
        cell.detailTextLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        _timer.onRepeatType = _timer.offRepeatType = MHDeviceTimerRepeat_Once;
    } else if (indexPath.row == 1) {
        _timer.onRepeatType = _timer.offRepeatType = MHDeviceTimerRepeat_Everyday;
    } else if (indexPath.row == 2) {
        _timer.onRepeatType = _timer.offRepeatType = MHDeviceTimerRepeat_Workday;
    } else if (indexPath.row == 3) {
        _timer.onRepeatType = _timer.offRepeatType = MHDeviceTimerRepeat_Weekend;
    } else if (indexPath.row == 4) {
        MHLuTimerSelfDefineViewController* repeatTypeSelfDefineVC = [[MHLuTimerSelfDefineViewController alloc] initWithTimer:_timer];
        [self.navigationController pushViewController:repeatTypeSelfDefineVC animated:YES];
    }
    
    [_tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_repeatTypes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellId = @"cellId";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = [MHColorUtils colorWithRGB:0x5f5f5f];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
        cell.detailTextLabel.textColor = [MHColorUtils colorWithRGB:0x999999];
    }
    [self updateCell:cell indexPath:indexPath];
    return cell;
}

@end
