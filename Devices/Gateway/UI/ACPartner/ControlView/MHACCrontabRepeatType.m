//
//  MHACCrontabRepeatType.m
//  MiHome
//
//  Created by ayanami on 16/8/4.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACCrontabRepeatType.h"
#import "MHACCrontabSelfDefineViewController.h"

@interface MHACCrontabRepeatType ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation MHACCrontabRepeatType
{
    MHCrontabTime*  _crontab;
    UITableView*        _tableView;
    NSArray*            _repeatTypes;
}


- (id)initWithCrontab:(MHCrontabTime *)crontab {
    if (self = [super init]) {
        _crontab = crontab;
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
    
    if (indexPath.row == 0 && _crontab.daysOfWeek == MHCrontabDayOfWeekNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (indexPath.row == 1 && _crontab.daysOfWeek == MHCrontabEveryday) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (indexPath.row == 2 && _crontab.daysOfWeek == MHCrontabWeekday) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (indexPath.row == 3 && _crontab.daysOfWeek == MHCrontabWeekend) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (indexPath.row == 4 &&
               _crontab.daysOfWeek != MHCrontabDayOfWeekNone &&
               _crontab.daysOfWeek != MHCrontabEveryday &&
               _crontab.daysOfWeek != MHCrontabWeekday &&
               _crontab.daysOfWeek != MHCrontabWeekend) {
        //自定义
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        cell.detailTextLabel.text = [_crontab repeatDescription];
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
    if (indexPath.row == 0 && _crontab.daysOfWeek == MHCrontabDayOfWeekNone) {
        _crontab.daysOfWeek = MHCrontabDayOfWeekNone;
    } else if (indexPath.row == 1 && _crontab.daysOfWeek == MHCrontabEveryday) {
        _crontab.daysOfWeek = MHCrontabEveryday;
    } else if (indexPath.row == 2 && _crontab.daysOfWeek == MHCrontabWeekday) {
        _crontab.daysOfWeek = MHCrontabWeekday;
    } else if (indexPath.row == 3 && _crontab.daysOfWeek == MHCrontabWeekend) {
        _crontab.daysOfWeek = MHCrontabWeekend;
    } else if (indexPath.row == 4) {
        MHACCrontabSelfDefineViewController* repeatTypeSelfDefineVC = [[MHACCrontabSelfDefineViewController alloc] initWithCrontab:_crontab];
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
