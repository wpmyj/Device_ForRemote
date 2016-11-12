//
//  MHLuTimerSelfDefineViewController.m
//  MiHome
//
//  Created by Lynn on 10/16/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLuTimerSelfDefineViewController.h"

@implementation MHLuTimerSelfDefineViewController{
    MHDataDeviceTimer*  _timer;
    UITableView*        _tableView;
    NSArray*            _repeatTypes;
}

- (id)initWithTimer:(MHDataDeviceTimer* )timer {
    if (self = [super init]) {
        _timer = timer;
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
    if (indexPath.row == 0 && _timer.onRepeatType & MHDeviceTimerRepeat_Sun) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (indexPath.row == 1 && _timer.onRepeatType & MHDeviceTimerRepeat_Mon) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (indexPath.row == 2 && _timer.onRepeatType & MHDeviceTimerRepeat_Tues) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (indexPath.row == 3 && _timer.onRepeatType & MHDeviceTimerRepeat_Wed) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (indexPath.row == 4 && _timer.onRepeatType & MHDeviceTimerRepeat_Thur) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (indexPath.row == 5 && _timer.onRepeatType & MHDeviceTimerRepeat_Fri) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (indexPath.row == 6 && _timer.onRepeatType & MHDeviceTimerRepeat_Sat) {
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
        _timer.onRepeatType ^= MHDeviceTimerRepeat_Sun;
        _timer.offRepeatType = _timer.onRepeatType;
    } else if (indexPath.row == 1) {
        _timer.onRepeatType ^= MHDeviceTimerRepeat_Mon;
        _timer.offRepeatType = _timer.onRepeatType;
    } else if (indexPath.row == 2) {
        _timer.onRepeatType ^= MHDeviceTimerRepeat_Tues;
        _timer.offRepeatType = _timer.onRepeatType;
    } else if (indexPath.row == 3) {
        _timer.onRepeatType ^= MHDeviceTimerRepeat_Wed;
        _timer.offRepeatType = _timer.onRepeatType;
    } else if (indexPath.row == 4) {
        _timer.onRepeatType ^= MHDeviceTimerRepeat_Thur;
        _timer.offRepeatType = _timer.onRepeatType;
    } else if (indexPath.row == 5) {
        _timer.onRepeatType ^= MHDeviceTimerRepeat_Fri;
        _timer.offRepeatType = _timer.onRepeatType;
    } else if (indexPath.row == 6) {
        _timer.onRepeatType ^= MHDeviceTimerRepeat_Sat;
        _timer.offRepeatType = _timer.onRepeatType;
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
