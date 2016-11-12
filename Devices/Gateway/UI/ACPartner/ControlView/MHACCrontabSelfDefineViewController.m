//
//  MHACCrontabSelfDefineViewController.m
//  MiHome
//
//  Created by ayanami on 16/8/4.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACCrontabSelfDefineViewController.h"

@interface MHACCrontabSelfDefineViewController ()<UITableViewDelegate, UITableViewDataSource>

@end


@implementation MHACCrontabSelfDefineViewController
{
    MHCrontabTime*  _crontab;
    UITableView*        _tableView;
    NSArray*            _repeatTypes;
}
- (id)initWithCrontab:(MHCrontabTime *)crontab {
    if (self = [super init]) {
        _crontab = crontab;
        _repeatTypes = [NSArray arrayWithObjects:
                        NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.sun",@"plugin_gateway","星期日"),
                        NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.mon",@"plugin_gateway","星期一"),
                        NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.tues",@"plugin_gateway","星期二"),
                        NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.wed",@"plugin_gateway","星期三"),
                        NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.thur",@"plugin_gateway","星期四"),
                        NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.fri",@"plugin_gateway","星期五"),
                        NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.sat",@"plugin_gateway","星期六"),nil];
    }
    return self;
}



- (void)dealloc {
    NSLog(@"ddd");
}

- (void)buildSubviews {
    [super buildSubviews];
    
    self.isTabBarHidden = YES;
    self.title = NSLocalizedStringFromTable(@"mydevice.timersetting.repeat.selfdefine",@"plugin_gateway","自定义");
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

- (void)buildConstraints {
    [super buildConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)updateCell:(UITableViewCell* )cell indexPath:(NSIndexPath* )indexPath {
    cell.textLabel.text = _repeatTypes[indexPath.row];
    if (indexPath.row == 0 && _crontab.daysOfWeek & MHCrontabSunday) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (indexPath.row == 1 && _crontab.daysOfWeek & MHCrontabMonday) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (indexPath.row == 2 && _crontab.daysOfWeek & MHCrontabTuesday) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (indexPath.row == 3 && _crontab.daysOfWeek & MHCrontabWednesday) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (indexPath.row == 4 && _crontab.daysOfWeek & MHCrontabThursday) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (indexPath.row == 5 && _crontab.daysOfWeek & MHCrontabFriday) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (indexPath.row == 6 && _crontab.daysOfWeek & MHCrontabSaturday) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
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
        _crontab.daysOfWeek ^= MHCrontabSunday;
    } else if (indexPath.row == 1) {
        _crontab.daysOfWeek ^= MHCrontabMonday;
    } else if (indexPath.row == 2) {
        _crontab.daysOfWeek ^= MHCrontabTuesday;
    } else if (indexPath.row == 3) {
        _crontab.daysOfWeek ^= MHCrontabWednesday;
    } else if (indexPath.row == 4) {
        _crontab.daysOfWeek ^= MHCrontabThursday;
    } else if (indexPath.row == 5) {
        _crontab.daysOfWeek ^= MHCrontabFriday;
    } else if (indexPath.row == 6) {
        _crontab.daysOfWeek ^= MHCrontabSaturday;
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
    }
    [self updateCell:cell indexPath:indexPath];
    return cell;
}

@end
