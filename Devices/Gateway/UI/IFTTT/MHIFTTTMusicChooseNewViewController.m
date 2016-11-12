//
//  MHIFTTTMusicChooseNewViewController.m
//  MiHome
//
//  Created by guhao on 16/5/9.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHIFTTTMusicChooseNewViewController.h"
#import "MHTableViewControllerInternal.h"
#import "MHTableViewControllerInternalV2.h"
#import "MHDeviceSettingDefaultCell.h"
#import "MHGwMusicInvoker.h"
#import "MHGatewayVolumeSettingCell.h"
#import "MHGatewayNumberSliderView.h"

#define FooterHeight 65.f
#define CellIdentifier @"MHGatewayVolumeSettingCell"

#define kALARMMUZIC NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmbell.name",@"plugin_gateway","警戒音")
#define kDOORBELLMUZIC NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.click.tone1",@"plugin_gateway","门铃")
#define kALOCKMUZIC NSLocalizedStringFromTable(@"mydevice.gateway.setting.doorbell.click.tone4",@"plugin_gateway","闹钟")
#define kUSERMUZIC NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.record.uploadedfiles",@"plugin_gateway","自定义")


@interface MHIFTTTMusicChooseNewViewController () < MHTableViewControllerInternalDelegateV2,MHTableViewControllerInternalDelegate,UITableViewDelegate,UITableViewDataSource>

//@property (nonatomic,strong) MHTableViewControllerInternal *tvcInternal;
@property (nonatomic,strong) MHTableViewControllerInternalV2 *tvcInternal;
@property (nonatomic,strong) MHDeviceGateway *gateway;
@property (nonatomic,strong) NSMutableArray *gatewayList;
@property (nonatomic,assign) NSInteger musicGroup;
@property (nonatomic,strong) UITableView *footerTableView;
@property (nonatomic,assign) NSInteger currentVolume;
@property (nonatomic,assign) NSInteger selectedMid;

//铃音列表 0：报警 1：门铃 2：欢迎 9：自定义
@property (nonatomic , strong) NSMutableArray *alarmMusicArray;
@property (nonatomic , strong) NSMutableArray *doorbellMusicArray;
@property (nonatomic , strong) NSMutableArray *welcomeMusicArray;
@property (nonatomic , strong) NSMutableArray *userMusicArray;
@property (nonatomic , strong) NSMutableArray *titleArray;

@end

@implementation MHIFTTTMusicChooseNewViewController {
    NSInteger                               _selectedSeciton;
    NSInteger                               _selectedRow;
    UIView *                                _footerView;
}

- (id)initWithGateway:(MHDeviceGateway*)gateway musicGroup:(NSInteger)group {
    if (self = [super init]) {
        self.gateway = gateway;
        [self.gateway restoreStatus];
        self.gatewayList = [NSMutableArray new];
        NSLog(@"提示音量%ld", self.gateway.gateway_volume);
        _musicGroup = group;
        _selectedMid = -1;
        _selectedRow = -1;
        self.currentVolume = -1;
        self.alarmMusicArray = [NSMutableArray new];
        self.doorbellMusicArray = [NSMutableArray new];
        self.welcomeMusicArray = [NSMutableArray new];
        self.userMusicArray = [NSMutableArray new];
/*
 "mydevice.gateway.setting.alarmbell.name" = "警戒音";
 "mydevice.gateway.setting.doorbell.click.tone1" = "门铃音";
 "mydevice.gateway.setting.doorbell.click.tone4" = "闹钟音";
 "mydevice.gateway.setting.cloudmusic.record.uploadedfiles" = "自定义音乐";


NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarmbell.name",@"plugin_gateway","警戒音")
 */
        self.titleArray = [NSMutableArray arrayWithObjects:kUSERMUZIC, kALOCKMUZIC, kALARMMUZIC, kDOORBELLMUZIC, nil];
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
//    if([self.gateway.model isEqualToString:@"lumi.gateway.v2"]){
//        [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"getting",@"plugin_gateway","获取中，请稍候...") modal:NO];
//        
//        [self.gateway getMusicListOfGroup:BellGroup_Door success:^(id v) {
//            [weakself onGetMusicListSucceeed];
//            if (weakself.musicGroup == 9) [weakself setGatewayDownloadList];
//            [[MHTipsView shareInstance] hide];
//            
//        } failure:^(NSError *v) {
//            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"request.failed",@"plugin_gateway", @"请求失败，请检查网络") duration:1.0f modal:NO];
//            
//        }];
//    }
//    else {
    [self getMusicData];
          [self getGatewayDownloadList];
}

- (void)buildSubviews {
    [super buildSubviews];
    
    CGRect tableFrame = CGRectMake(0, 64, WIN_WIDTH, self.view.bounds.size.height - 64);
    if(_musicGroup == 9) {
        tableFrame = CGRectMake(0, 64, WIN_WIDTH, self.view.bounds.size.height - 64 - FooterHeight);
    }
    self.tvcInternal = [[MHTableViewControllerInternalV2 alloc] initWithStyle:UITableViewStyleGrouped];
    self.tvcInternal.delegate = self;
    self.tvcInternal.cellClass = [MHDeviceSettingDefaultCell class];
    self.tvcInternal.dataSource = self.gatewayList;
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

#pragma mark - 获取数据
- (void)getMusicData {
    XM_WS(weakself);
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"getting",@"plugin_gateway","获取中，请稍候...") modal:NO];
    //警戒音
    if (!self.alarmMusicArray.count) {
        [weakself.gateway getMusicInfoWithGroup:BellGroup_Alarm Success:^(id respObj) {
            [[[MHSafeDictionary alloc] init] setObjectsInDictionary:respObj];
            
            MHSafeDictionary* result = [(MHSafeDictionary* )respObj objectForKey:@"result" class:[MHSafeDictionary class]];
            NSLog(@"%@", result);
            NSArray *listArray = [result objectForKey:@"list" class:[NSArray class]];
            NSMutableArray *list = [NSMutableArray arrayWithArray:listArray];
            NSLog(@"%@", list);
            if (list) {
                for(id obj in [list mutableCopy]){
                    if([[obj valueForKey:@"mid"] intValue] > 1000) {
                        
                    }
                    else {
                        [weakself.alarmMusicArray addObject:obj];
                    }
                }
            }
//            [[MHTipsView shareInstance] hide];
            [weakself onGetMusicListSucceeed];
            if (![weakself.titleArray containsObject:kALARMMUZIC]) {
                [weakself.titleArray addObject:kALARMMUZIC];
            }
                        if (weakself.musicGroup == 9) [weakself setGatewayDownloadList];
        } failure:^(NSError *v) {
            [weakself.titleArray removeObject:kALARMMUZIC];
//            [[MHTipsView shareInstance] hide];
        }];
 
    }
    
    //门铃音
    if (!self.doorbellMusicArray.count) {
        [weakself.gateway getMusicInfoWithGroup:BellGroup_Door Success:^(id respObj) {
            [[[MHSafeDictionary alloc] init] setObjectsInDictionary:respObj];
            
            MHSafeDictionary* result = [(MHSafeDictionary* )respObj objectForKey:@"result" class:[MHSafeDictionary class]];
            NSLog(@"%@", result);
            NSArray *listArray = [result objectForKey:@"list" class:[NSArray class]];
            NSMutableArray *list = [NSMutableArray arrayWithArray:listArray];
            NSLog(@"%@", list);
            if (list) {
                for(id obj in [list mutableCopy]){
                    if([[obj valueForKey:@"mid"] intValue] > 1000) {
                        
                    }
                    else {
                        [weakself.doorbellMusicArray addObject:obj];
                    }
                }
            }
            if (![weakself.titleArray containsObject:kDOORBELLMUZIC]) {
                [weakself.titleArray addObject:kDOORBELLMUZIC];
            }
//            [[MHTipsView shareInstance] hide];
            [weakself onGetMusicListSucceeed];
        } failure:^(NSError *v) {
            [weakself.titleArray removeObject:kDOORBELLMUZIC];
//            [[MHTipsView shareInstance] hide];
        }];
    }
    if (!self.welcomeMusicArray.count) {
        [weakself.gateway getMusicInfoWithGroup:BellGroup_Welcome Success:^(id respObj) {
            
            [[[MHSafeDictionary alloc] init] setObjectsInDictionary:respObj];
            
            MHSafeDictionary* result = [(MHSafeDictionary* )respObj objectForKey:@"result" class:[MHSafeDictionary class]];
            NSLog(@"%@", result);
            NSArray *listArray = [result objectForKey:@"list" class:[NSArray class]];
            NSMutableArray *list = [NSMutableArray arrayWithArray:listArray];
            NSLog(@"%@", list);
            if (list) {
                for(id obj in [list mutableCopy]){
                    if([[obj valueForKey:@"mid"] intValue] > 1000) {
                        [weakself.userMusicArray addObject:obj];
                    }
                    else {
                        [weakself.welcomeMusicArray addObject:obj];

                    }
                }
                
            }
            if (weakself.userMusicArray.count > weakself.gateway.downloadMusicList.count) {
                [weakself.userMusicArray removeObjectsInArray:weakself.gateway.downloadMusicList];
            }
            [[MHTipsView shareInstance] hide];
            [weakself onGetMusicListSucceeed];
            if (![weakself.titleArray containsObject:kALOCKMUZIC]) {
                [weakself.titleArray addObject:kALOCKMUZIC];
            }
            if (![weakself.titleArray containsObject:kUSERMUZIC]) {
                [weakself.titleArray insertObject:kUSERMUZIC atIndex:0];
            }
        } failure:^(NSError *v) {
            [[MHTipsView shareInstance] hide];
            [weakself.titleArray removeObject:kALOCKMUZIC];
            if (!weakself.userMusicArray.count) {
                [weakself.titleArray removeObject:kUSERMUZIC];
            }
        }];
    }
}

#pragma mark - 获取音乐列表
- (void)onGetMusicListSucceeed {
    NSMutableArray *temp = [NSMutableArray arrayWithArray:@[ self.userMusicArray, self.welcomeMusicArray, self.alarmMusicArray, self.doorbellMusicArray ]];
    self.gatewayList = temp;
    if (!self.userMusicArray.count) {
        [self.gatewayList removeObject:self.userMusicArray];
    }
    if (!self.welcomeMusicArray.count) {
        [self.gatewayList removeObject:self.welcomeMusicArray];
    }
    if (!self.alarmMusicArray.count) {
        [self.gatewayList removeObject:self.alarmMusicArray];
    }
    if (!self.doorbellMusicArray.count) {
        [self.gatewayList removeObject:self.doorbellMusicArray];
    }
    self.tvcInternal.dataSource = self.gatewayList;
    [self.tvcInternal stopRefreshAndReload];
}

- (void)getGatewayDownloadList {
    XM_WS(weakself);
    MHGwMusicInvoker *invoker =[[MHGwMusicInvoker alloc] initWithDevice:_gateway];
    [invoker readGatwayDownloadListWithSuccess:^(id obj){
//        [weakself.userMusicArray addObjectsFromArray:weakself.gateway.downloadMusicList];
        weakself.userMusicArray = [NSMutableArray arrayWithArray:weakself.gateway.downloadMusicList];
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
    if (_musicGroup == 9){
        return 50;
    }
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
//    if(_musicGroup != 9){
//        text = [MHDeviceGateway getBellNameOfGroup:(BellGroup)_musicGroup index:indexPath.row];
//    }
//    else {
//        if(self.gatewayList.count){
//            //            text = [self.gateway.downloadMusicList[indexPath.row] valueForKey:@"alias_name"];
//            int index = [self.gatewayList[indexPath.row][@"mid"] intValue];
//            text = [self.gateway fetchGwDownloadMidName:[NSString stringWithFormat:@"%d",index]];
//        }
//        else {
//            text = NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.record.uploadedfiles", @"plugin_gateway", @"自定义音乐");
//        }
//    }
//    switch (indexPath.section) {
//        case 0: {
//            int index = [self.gatewayList[indexPath.section][indexPath.row][@"mid"] intValue];
//            text = [self.gateway fetchGwDownloadMidName:[NSString stringWithFormat:@"%d",index]];
//            if(!text) text = NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.record.uploadedfiles",@"plugin_gateway", nil);
//        }
//            break;
//        case 1: {
//            int index = [self.gatewayList[indexPath.section][indexPath.row][@"mid"] intValue];
//            text = [MHDeviceGateway getBellNameOfGroup:(BellGroup)BellGroup_Welcome index:index % 10];
//        }
//            break;
//            
//        case 2: {
//            int index = [self.gatewayList[indexPath.section][indexPath.row][@"mid"] intValue];
//            text = [MHDeviceGateway getBellNameOfGroup:(BellGroup)BellGroup_Alarm index:index];
//        }
//            break;
//        case 3: {
//            int index = [self.gatewayList[indexPath.section][indexPath.row][@"mid"] intValue];
//            text = [MHDeviceGateway getBellNameOfGroup:(BellGroup)BellGroup_Door index:index % 10];
//        }
//            break;
//            
//        default:
//            break;
//    }
    
    NSMutableArray *todoArray = self.gatewayList[indexPath.section];
    if (todoArray == self.userMusicArray){
        int index = [todoArray[indexPath.row][@"mid"] intValue];
        text = [self.gateway fetchGwDownloadMidName:[NSString stringWithFormat:@"%d",index]];
        if(!text) text = NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.record.uploadedfiles",@"plugin_gateway", nil);
    }
    
    if (todoArray == self.doorbellMusicArray){
        int index = [todoArray[indexPath.row][@"mid"] intValue];
        text = [MHDeviceGateway getBellNameOfGroup:(BellGroup)BellGroup_Door index:index % 10];
    }
    
    if (todoArray == self.welcomeMusicArray){
        int index = [todoArray[indexPath.row][@"mid"] intValue];
        text = [MHDeviceGateway getBellNameOfGroup:(BellGroup)BellGroup_Welcome index:index % 10];
    }
    
    if (todoArray == self.alarmMusicArray){
        int index = [todoArray[indexPath.row][@"mid"] intValue];
        text = [MHDeviceGateway getBellNameOfGroup:(BellGroup)BellGroup_Alarm index:index];
    }
    
    
    MHDeviceSettingItem* item = [[MHDeviceSettingItem alloc] init];
    item.caption = text;
    item.type = MHDeviceSettingItemTypeDefault;
    item.customUI = YES;
    item.accessories = [[MHStrongBox alloc] initWithDictionary:@{SettingAccessoryKey_CellHeight : @(56), SettingAccessoryKey_CaptionFontSize : @(15), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333]}];
    [cell fillWithItem:item];
    
    if(_selectedRow == indexPath.row && _selectedSeciton == indexPath.section) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section {
    return 40.0f;
}
- (UIView *)viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, 40.0f)];
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, WIN_WIDTH - 70, 30)];
    detailLabel.textAlignment = NSTextAlignmentLeft;
    detailLabel.font = [UIFont systemFontOfSize:14.f];
    detailLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    NSMutableArray *todoArray = self.gatewayList[section];
    if (todoArray == self.userMusicArray){
        detailLabel.text = kUSERMUZIC;
    }
    
    if (todoArray == self.doorbellMusicArray){
        detailLabel.text = kDOORBELLMUZIC;
    }
    
    if (todoArray == self.welcomeMusicArray){
        detailLabel.text = kALOCKMUZIC;
    }
    
    if (todoArray == self.alarmMusicArray){
        detailLabel.text = kALARMMUZIC;
    }
    [header addSubview:detailLabel];
    return header;
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedRow = indexPath.row;
    _selectedSeciton = indexPath.section;
//
//    if (_musicGroup == 9){
//        _selectedMid = [[self.gatewayList[indexPath.row] valueForKey:@"mid"] integerValue];
//        if(self.currentVolume == -1){
//            self.currentVolume = self.gateway.gateway_volume;
//        }
//    }
//    else {
//        _selectedMid = [[self.gatewayList[indexPath.row] valueForKey:@"mid"] integerValue];
//    }
    _selectedMid = [[self.gatewayList[indexPath.section][indexPath.row] valueForKey:@"mid"] integerValue];
    if(self.currentVolume == -1){
        self.currentVolume = self.gateway.gateway_volume;
    }
    [self.tvcInternal stopRefreshAndReload];

    [self tryPlaySpecifyMusic];
}

- (UITableViewCellEditingStyle)editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
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
