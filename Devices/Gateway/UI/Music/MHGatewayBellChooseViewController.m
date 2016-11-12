//
//  MHGatewayBellChooseViewController.m
//  MiHome
//
//  Created by Woody on 15/4/8.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import "MHGatewayBellChooseViewController.h"
#import "MHDeviceSettingDefaultCell.h"
#import <AVFoundation/AVFoundation.h>
#import "MHGatewayCloudMusicViewController.h"


@interface MHGatewayBellChooseViewController() <UITableViewDelegate, UITableViewDataSource, AVAudioRecorderDelegate>

@end

@implementation MHGatewayBellChooseViewController {
    UITableView*                            _tableView;
    MHDeviceGateway*                        _gateway;
    NSInteger                               _musicGroup;
    NSDictionary*                           _bellLocalNames;
    NSInteger                               _selectedRow;
}

- (id)initWithGateway:(MHDeviceGateway*)gateway musicGroup:(NSInteger)group{
    if (self = [super init]) {
        _gateway = gateway;
        _musicGroup = group;

        _selectedRow = -1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    typeof(self) __weak weakSelf = self;
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"getting",@"plugin_gateway","获取中，请稍候...") modal:NO];
    [_gateway getMusicListOfGroup:_musicGroup success:^(id v) {
        [weakSelf onGetMusicListSucceeed];
        [[MHTipsView shareInstance] hide];
    } failure:^(NSError *v) {
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
    }];
}

- (void)onBack:(id)sender {
    [super onBack:sender];
    [_gateway setSoundPlaying:@"off" success:nil failure:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[MHTipsView shareInstance] hide];
}

- (void)buildSubviews {
    self.isTabBarHidden = YES;
    
    CGRect rect = self.view.bounds;
    _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    self.view.backgroundColor = _tableView.backgroundColor;
}

#pragma mark - 获取音乐列表
- (void)onGetMusicListSucceeed {
    _selectedRow = [_gateway.default_music_index[_musicGroup] integerValue] - _musicGroup*10;
    
    [_tableView reloadData];
    [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[_gateway.default_music_index[_musicGroup] integerValue] - _musicGroup*10 inSection:0]].accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)onSetMusicOfGroupSucceed:(NSInteger)groupIndex {
    [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedRow inSection:0]].accessoryType = UITableViewCellAccessoryNone;
    [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:groupIndex inSection:0]].accessoryType = UITableViewCellAccessoryCheckmark;
    _selectedRow = groupIndex;
    [_gateway playMusicOfIndex:_selectedRow+_musicGroup*10];
    if (self.onSelectMusic) {
        self.onSelectMusic([MHDeviceGateway getBellNameOfGroup:(BellGroup)_musicGroup index:_selectedRow]);
        if (self.onSelectIndex)self.onSelectIndex(_selectedRow);
    }
}

#pragma mark - UITableViewDelegate/DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_gateway.music_list objectForKey:@(_musicGroup)] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString* cellIdentifier = @"cell";
    MHDeviceSettingDefaultCell* cell = (MHDeviceSettingDefaultCell* )[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MHDeviceSettingDefaultCell alloc] initWithReuseIdentifier:cellIdentifier];
    }
    
    NSString* text = nil;
    NSString* detailText = nil;
    NSArray* musicListOfCurGroup = [_gateway.music_list objectForKey:@(_musicGroup)];
    if (indexPath.row < [musicListOfCurGroup count]) {
        MHSafeDictionary* music = musicListOfCurGroup[indexPath.row];

        text = [MHDeviceGateway getBellNameOfGroup:(BellGroup)_musicGroup index:indexPath.row];
        
        NSUInteger min = 0;
        NSUInteger sec = 0;
        NSUInteger seconds = [[music objectForKey:@"time" class:[NSNumber class]] unsignedIntegerValue];
        if (seconds >= 60 && seconds < 3600) {
            min = seconds / 60;
            sec = seconds % 60;
        } else if (seconds < 60) {
            sec = seconds;
        } else {
            min = 59;
            sec = 59;
            assert(0);  //超过1小时暂时不支持显示
        }
        detailText = [NSString stringWithFormat:@"%02ld:%02ld", min, sec];
    }
    
    MHDeviceSettingItem* item = [[MHDeviceSettingItem alloc] init];
    item.caption = text;
    item.comment = detailText;
    item.type = MHDeviceSettingItemTypeDefault;
    item.customUI = YES;
    item.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    [cell fillWithItem:item];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    typeof(self) __weak weakSelf = self;
    [_gateway setDefaultMusicOfGroup:_musicGroup*10 + indexPath.row success:^(id v) {
        [weakSelf onSetMusicOfGroupSucceed:indexPath.row];
        [[MHTipsView shareInstance] hide];
    } failure:^(NSError *v) {
        [[MHTipsView shareInstance] hide];
    }];
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"updating",@"plugin_gateway","正在更新中...") modal:NO];
}


@end

