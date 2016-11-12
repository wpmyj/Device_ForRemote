//
//  MHGatewayDurationController.m
//  MiHome
//
//  Created by Lynn on 8/12/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayDurationController.h"

@interface MHGatewayDurationController ()

@end

@implementation MHGatewayDurationController {
    UITableView*        _tableView;
    NSArray*            _durationTypes;
}

- (id)init {
    if (self = [super init]) {
        _durationTypes = [NSArray arrayWithObjects:
                        NSLocalizedStringFromTable(@"mydevice.gateway.setting.timersetting.duration.5min",@"plugin_gateway","5"),
                        NSLocalizedStringFromTable(@"mydevice.gateway.setting.timersetting.duration.10min",@"plugin_gateway","10"),
                        NSLocalizedStringFromTable(@"mydevice.gateway.setting.timersetting.duration.15min",@"plugin_gateway","15"),
                        NSLocalizedStringFromTable(@"mydevice.gateway.setting.timersetting.duration.30min",@"plugin_gateway","30"),
                        NSLocalizedStringFromTable(@"mydevice.gateway.setting.timersetting.duration.forever",@"plugin_gateway","永久"), nil];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"ddd");
}

- (void)buildSubviews {
    [super buildSubviews];
    self.isTabBarHidden = YES;
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.timersetting.duration",@"plugin_gateway","持续时间");
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = [MHColorUtils colorWithRGB:0xE1E1E1];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
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

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
   
    UITableViewCell *cell = (UITableViewCell *)[tableView.visibleCells objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [MHColorUtils colorWithRGB:0x3fb57d];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [_tableView reloadData];
    _selectionType = (DurationType)indexPath.row;
    self.callback((DurationType)indexPath.row);

//    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_durationTypes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellId = @"cellId";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textColor = [MHColorUtils colorWithRGB:0x5f5f5f];
    cell.textLabel.text = _durationTypes[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if ((DurationType)indexPath.row == _selectionType) {
        cell.textLabel.textColor = [MHColorUtils colorWithRGB:0x3fb57d];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}


@end
