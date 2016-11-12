//
//  MHIFTTTFMChooseViewController.m
//  MiHome
//
//  Created by Lynn on 1/29/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHIFTTTFMChooseViewController.h"
#import "MHTableViewControllerInternal.h"
#import "MHDeviceSettingDefaultCell.h"
#import "MHLumiFMCollectionInvoker.h"
#import "MHGatewayVolumeSettingCell.h"

#define FooterHeight 65.f
#define CellIdentifier @"MHGatewayVolumeSettingCell"

@interface MHIFTTTFMChooseViewController () <MHTableViewControllerInternalDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) MHTableViewControllerInternal *tvcInternal;
@property (nonatomic,strong) MHDeviceGateway *gateway;
@property (nonatomic,strong) NSArray *fmCollectionList;
@property (nonatomic,strong) UITableView *footerTableView;
@property (nonatomic,assign) NSInteger currentVolume;
@property (nonatomic,assign) NSInteger selectedRadioId;

@end

@implementation MHIFTTTFMChooseViewController
{
    NSInteger               _selectedRow;
    UIView *                _footerView;
}

- (id)initWithGateway:(MHDeviceGateway*)gateway {
    if (self = [super init]) {
        _gateway = gateway;
        _selectedRow = -1;
        _selectedRadioId = -1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    XM_WS(weakself);
    MHLumiFMCollectionInvoker *invoker = [[MHLumiFMCollectionInvoker alloc] init];
    invoker.radioDevice = _gateway;
    [invoker fetchCollectionListWithSuccess:^(NSMutableArray *datalist) {
        weakself.fmCollectionList = datalist;
        weakself.tvcInternal.dataSource = weakself.fmCollectionList;
        [weakself.tvcInternal stopRefreshAndReload];
        [weakself.gateway setGatewayFMCollection:datalist withSuccess:nil andFailure:nil];
        
    } andFailure:^(NSError *error) {
        
    }];
}

- (void)buildSubviews {
    [super buildSubviews];
    
    CGRect tableFrame = CGRectMake(0, 64, WIN_WIDTH, self.view.bounds.size.height - 64 - FooterHeight);
    self.tvcInternal = [[MHTableViewControllerInternal alloc] initWithStyle:UITableViewStylePlain];
    self.tvcInternal.delegate = self;
    self.tvcInternal.cellClass = [MHDeviceSettingDefaultCell class];
    self.tvcInternal.dataSource = self.fmCollectionList;
    [self.tvcInternal.view setFrame:tableFrame];
    [self addChildViewController:self.tvcInternal];
    [self.view addSubview:self.tvcInternal.view];
    
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
    
    XM_WS(weakself);
    [_gateway fetchRadioDeviceStatusWithSuccess:^(id obj) {
        [weakself.footerTableView reloadData];
        weakself.currentVolume = weakself.gateway.fm_volume;
    } andFailure:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    NSString *title = NSLocalizedStringFromTable(@"mydevice.gateway.setting.volume.fm", @"plugin_gateway", "fm音量");
    MHGatewayVolumeSettingCell *cell = [[MHGatewayVolumeSettingCell alloc] init];
    [cell configureConstruct:self.gateway.fm_volume andType:title];
    cell.volumeControlCallBack = ^(NSInteger value, NSString *type, MHGatewayVolumeSettingCell *cell){
        weakself.currentVolume = value;
        if(weakself.fmCollectionList.count){
            [self tryPlaySpecifyRadio];
        }
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - interval table view delegate
- (void)startRefresh {
    [self.tvcInternal stopRefreshAndReload];
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(messageView.frame.origin.x, CGRectGetMaxY(icon.frame), messageView.frame.size.width, 19.0f)];
    label.text = NSLocalizedStringFromTable(@"list.blank", @"plugin_gateway", @"列表空");
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
    
    NSString *text = [self.fmCollectionList[indexPath.row] valueForKey:@"radioName"];
    
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

    MHLumiXMRadio *currentRadio = self.fmCollectionList[indexPath.row];
    _selectedRadioId = [[currentRadio valueForKey:@"radioId"] integerValue];

    if (_selectedRadioId && [currentRadio valueForKey:@"radioRateUrl"]) {
        [self tryPlaySpecifyRadio];
    }
}

#pragma mark - try play 
- (void)tryPlaySpecifyRadio {
    if(_selectedRadioId == -1){
        _selectedRow = 0;
        [self.tvcInternal stopRefreshAndReload];
        MHLumiXMRadio *currentRadio = self.fmCollectionList[0];
        _selectedRadioId = [[currentRadio valueForKey:@"radioId"] integerValue];
    }
    if(self.onSelectMusicMid) self.onSelectMusicMid(_selectedRadioId);
    if(self.onSelectMusicVolume) self.onSelectMusicVolume(_currentVolume);

    [self.gateway playSpecifyRadioForTryVolume:_selectedRadioId
                                        volume:_currentVolume
                                   withSuccess:nil
                                       failure:nil];
}

@end
