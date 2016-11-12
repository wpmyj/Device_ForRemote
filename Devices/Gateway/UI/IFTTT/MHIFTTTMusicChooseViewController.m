//
//  MHIFTTTMusicChooseViewController.m
//  MiHome
//
//  Created by Lynn on 1/28/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHIFTTTMusicChooseViewController.h"
#import "MHTableViewControllerInternal.h"
#import "MHDeviceSettingDefaultCell.h"
#import "MHGwMusicInvoker.h"
#import "MHGatewayVolumeSettingCell.h"

#define FooterHeight 65.f
#define CellIdentifier @"MHGatewayVolumeSettingCell"

@interface MHIFTTTMusicChooseViewController () <MHTableViewControllerInternalDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) MHTableViewControllerInternal *tvcInternal;
@property (nonatomic,strong) MHDeviceGateway *gateway;
@property (nonatomic,strong) NSArray *gatewayList;
@property (nonatomic,assign) NSInteger musicGroup;
@property (nonatomic,strong) UITableView *footerTableView;
@property (nonatomic,assign) NSInteger currentVolume;
@property (nonatomic,assign) NSInteger selectedMid;

@end

@implementation MHIFTTTMusicChooseViewController
{
    NSInteger                               _selectedRow;
    UIView *                                _footerView;
}

- (id)initWithGateway:(MHDeviceGateway*)gateway musicGroup:(NSInteger)group {
    if (self = [super init]) {
        self.gateway = gateway;
        _musicGroup = group;
        _selectedMid = -1;
        _selectedRow = -1;
        self.currentVolume = -1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XM_WS(weakself);
    if(_musicGroup == 1){
        [_gateway getProperty:DOORBELL_VOLUME_INDEX success:^(id obj) {
            weakself.gateway.doorbell_volume = [[obj firstObject] integerValue];
        } failure:nil];
    }
    
    if(_musicGroup == 9){
        [_gateway getProperty:GATEWAY_VOLUME_INDEX success:^(id obj) {
            weakself.gateway.gateway_volume = [[obj firstObject] integerValue];
            weakself.currentVolume = weakself.gateway.gateway_volume;
            [weakself.footerTableView reloadData];
        } failure:^(NSError *error) {
            NSLog(@"%@",error);
        }];
    }
    
//    if(_musicGroup == 9 || _musicGroup == 1){
//        [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"getting",@"plugin_gateway","获取中，请稍候...") modal:NO];
//        [_gateway getMusicInfoWithGroup:1 Success:^(id v) {
//            [weakself onGetMusicListSucceeed];
//            if (weakself.musicGroup == 9) [weakself setGatewayDownloadList];
//            [[MHTipsView shareInstance] hide];
//        } failure:^(NSError *error) {
//            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
//        }];
//    }
    if([weakself.gateway.model isEqualToString:@"lumi.gateway.v2"]){
        [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"getting",@"plugin_gateway","获取中，请稍候...") modal:NO];

        [self.gateway getMusicListOfGroup:BellGroup_Door success:^(id v) {
            [weakself onGetMusicListSucceeed];
            if (weakself.musicGroup == 9) [weakself setGatewayDownloadList];
                        [[MHTipsView shareInstance] hide];

        } failure:^(NSError *v) {
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];

        }];
    }
    else {
        [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"getting",@"plugin_gateway","获取中，请稍候...") modal:NO];
        [self.gateway getMusicInfoWithGroup:BellGroup_Door Success:^(id v) {
            [weakself onGetMusicListSucceeed];
            if (weakself.musicGroup == 9) [weakself setGatewayDownloadList];
            [[MHTipsView shareInstance] hide];
        } failure:^(NSError *v) {
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
        }];
    }

    
    
    [self getGatewayDownloadList];
}

- (void)buildSubviews {
    [super buildSubviews];

    CGRect tableFrame = CGRectMake(0, 64, WIN_WIDTH, self.view.bounds.size.height - 64);
    if(_musicGroup == 9) {
        tableFrame = CGRectMake(0, 64, WIN_WIDTH, self.view.bounds.size.height - 64 - FooterHeight);
    }
    self.tvcInternal = [[MHTableViewControllerInternal alloc] initWithStyle:UITableViewStylePlain];
    self.tvcInternal.delegate = self;
    self.tvcInternal.cellClass = [MHDeviceSettingDefaultCell class];
    self.tvcInternal.dataSource = [_gateway.music_list valueForKey:[NSString stringWithFormat:@"%ld",(long)_musicGroup]];
    [self.tvcInternal.view setFrame:tableFrame];
    [self addChildViewController:self.tvcInternal];
    [self.view addSubview:self.tvcInternal.view];
    
    if(_musicGroup == 9){
        CGRect footerRect = CGRectMake(0, CGRectGetHeight(self.view.bounds) - FooterHeight, CGRectGetWidth(self.view.bounds), FooterHeight);
        _footerView = [[UIView alloc] initWithFrame:footerRect];
        _footerView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_footerView];
        
        CGRect footTableViewRect = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), FooterHeight);
        _footerTableView = [[UITableView alloc] initWithFrame:footTableViewRect style:UITableViewStylePlain];
        [_footerTableView registerClass:[MHGatewayVolumeSettingCell class] forCellReuseIdentifier:CellIdentifier];
        _footerTableView.delegate = self;
        _footerTableView.dataSource = self;
        _footerTableView.scrollEnabled = NO;
        _footerTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_footerView addSubview:_footerTableView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 获取音乐列表
- (void)onGetMusicListSucceeed {
    self.gatewayList = [_gateway.music_list valueForKey:[NSString stringWithFormat:@"%ld",(long)_musicGroup]];
    self.tvcInternal.dataSource = self.gatewayList;
    [self.tvcInternal stopRefreshAndReload];
}

- (void)getGatewayDownloadList {
    XM_WS(weakself);
    MHGwMusicInvoker *invoker =[[MHGwMusicInvoker alloc] initWithDevice:_gateway];
    [invoker readGatwayDownloadListWithSuccess:^(id obj){
        weakself.tvcInternal.dataSource = weakself.gateway.downloadMusicList;
        [weakself.tvcInternal stopRefreshAndReload];
    } andFailure:nil];
}

- (BOOL)setGatewayDownloadList {
    MHGwMusicInvoker *invoker = [[MHGwMusicInvoker alloc] initWithDevice:_gateway];
    
    //重新匹配列表，并设置
    NSMutableArray *extraDownlistData = [NSMutableArray arrayWithCapacity:1];
    for(NSDictionary *obj in _gateway.downloadMusicList){
        [extraDownlistData addObject:[NSString stringWithFormat:@"%@",[obj objectForKey:@"mid"]]];
    }

    NSMutableArray *currentList = [NSMutableArray arrayWithCapacity:1];
    for(NSDictionary *obj in [_gateway.music_list valueForKey:@"9"]){
        [currentList addObject:[NSString stringWithFormat:@"%@",[obj objectForKey:@"mid"]]];
    }
    
    [extraDownlistData removeObjectsInArray:[currentList mutableCopy]];
    
    if(extraDownlistData.count > 0){
        NSMutableArray *downlist = [_gateway.downloadMusicList mutableCopy];
        
        for(id mid in extraDownlistData){
            for(NSDictionary *obj in _gateway.downloadMusicList){
                if([[obj objectForKey:@"mid"] integerValue] == [mid integerValue])
                    [downlist removeObject:obj];
            }
        }
        
        //设置
        [invoker setGatwayDownloadListWithValue:[downlist mutableCopy] Success:nil andFailure:nil];
    }
    
    return NO;
}

#pragma mark - table delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XM_WS(weakself);
    NSString *title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.volume.specialvolume", @"plugin_gateway", "音量");
    MHGatewayVolumeSettingCell *cell = [[MHGatewayVolumeSettingCell alloc] init];
    [cell configureConstruct:self.currentVolume andType:title];
    cell.volumeControlCallBack = ^(NSInteger value, NSString *type, MHGatewayVolumeSettingCell *cell){
        weakself.currentVolume = value;
        if(weakself.gateway.downloadMusicList.count){
            [self tryPlaySpecifyMusic];
        }
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - interval table view delegate
- (void)startRefresh {
    [self.tvcInternal stopRefreshAndReload];
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76.f;
}

- (UIView *)emptyView {
    UIView *messageView = [[UIView alloc] initWithFrame:self.view.bounds];
    [messageView setBackgroundColor:[MHColorUtils colorWithRGB:0xefefef alpha:0.4f]];
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableview_blank_logo"]];
    [messageView addSubview:icon];
    CGRect imageFrame = icon.frame;
    imageFrame.origin.x = messageView.bounds.size.width / 2.0f - icon.frame.size.width / 2.0f;
    imageFrame.origin.y = CGRectGetHeight(self.view.bounds) / 3.f;
    [icon setFrame:imageFrame];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(messageView.frame.origin.x, CGRectGetMaxY(icon.frame) + 10.0f, messageView.frame.size.width, 19.0f)];
    label.text = NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.record.none", @"plugin_gateway", @"列表空");
    label.textAlignment = NSTextAlignmentCenter;
    [label setTextColor:[UIColor lightGrayColor]];
    [label setFont:[UIFont systemFontOfSize:15.0f]];
    [messageView addSubview:label];
    
    return messageView;
}

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString* cellIdentifier = @"Cell";
    MHDeviceSettingDefaultCell* cell = (MHDeviceSettingDefaultCell* )[self.tvcInternal.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MHDeviceSettingDefaultCell alloc] initWithReuseIdentifier:cellIdentifier];
    }
    
    NSString *text = @"";
    if(_musicGroup != 9){
        text = [MHDeviceGateway getBellNameOfGroup:(BellGroup)_musicGroup index:indexPath.row];
    }
    else {
        if(self.gatewayList.count){
//            text = [self.gateway.downloadMusicList[indexPath.row] valueForKey:@"alias_name"];
            int index = [self.gatewayList[indexPath.row][@"mid"] intValue];
            text = [self.gateway fetchGwDownloadMidName:[NSString stringWithFormat:@"%d",index]];
        }
        else {
            text = NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.record.uploadedfiles", @"plugin_gateway", @"自定义音乐");
        }
    }
    
    MHDeviceSettingItem* item = [[MHDeviceSettingItem alloc] init];
    item.caption = text;
    item.type = MHDeviceSettingItemTypeDefault;
    item.customUI = YES;
    item.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    [cell fillWithItem:item];

    if(_selectedRow == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedRow = indexPath.row;
    [self.tvcInternal stopRefreshAndReload];
    
    if (_musicGroup == 9){
        _selectedMid = [[self.gatewayList[indexPath.row] valueForKey:@"mid"] integerValue];
        if(self.currentVolume == -1){
            self.currentVolume = self.gateway.gateway_volume;
        }
    }
    else {
        _selectedMid = [[self.gatewayList[indexPath.row] valueForKey:@"mid"] integerValue];
    }
    [self tryPlaySpecifyMusic];
}

#pragma mark - 播放指定铃音
- (void)tryPlaySpecifyMusic {
    if(_selectedMid == -1){
        _selectedRow = 0;
        [self.tvcInternal stopRefreshAndReload];
        _selectedMid = [[self.gateway.downloadMusicList[0] valueForKey:@"mid"] integerValue];
    }
    if(self.onSelectMusicMid) self.onSelectMusicMid(_selectedMid);
    if(self.onSelectMusicVolume) self.onSelectMusicVolume(self.currentVolume);
    
    NSString *stringMid = [NSString stringWithFormat:@"%d",(int)_selectedMid];
    [self.gateway playMusicWithMid:stringMid volume:self.currentVolume Success:nil failure:nil];
}

@end
