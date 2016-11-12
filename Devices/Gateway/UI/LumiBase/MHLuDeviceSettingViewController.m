//
//  MHLuDeviceSettingViewController.m
//  MiHome
//
//  Created by Lynn on 10/16/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLuDeviceSettingViewController.h"
#import "MHDeviceSettingDefaultCell.h"
#import "MHDeviceSettingSwitchCell.h"
#import "MHDeviceSettingSegmentControlCell.h"
#import "MHDeviceSettingDatePickerCell.h"
#import "MHDeviceSettingVolumeCell.h"
#import "MHDeviceSettingCheckCell.h"
#import "MHDeviceSettingColorVolumeCell.h"
#import "MHGatewayVolumeSettingCell.h"
#import "MHGatewaySettingDefaultCell.h"
#import "MHGatewayAlarmClockCell.h"
#import "MHGatewayLogCell.h"
#import "MHGatewayLegSettingCell.h"
#import "MHLumiAccessSettingCell.h"
#import "MHGatewayWebViewController.h"
#import "MHLumiSwitchSettingCell.h"
#import "MHLumiDefaultSettingCell.h"
#import "MHLumiVolumeSettingCell.h"

@implementation MHLuDeviceSettingGroup
@end

@interface MHLuDeviceSettingViewController ()

@property (nonatomic, strong) UILabel *tipsText;
@property (nonatomic, strong) UIButton *btnSee;

@end

@implementation MHLuDeviceSettingViewController
{
    void (^_onBackCallback)();
}

- (id)init
{
    if (self = [super init]) {
        self.title = NSLocalizedStringFromTable(@"mydevice.actionsheet.setting",@"plugin_gateway", @"设置");
        self.isTabBarHidden = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - 没有相关设备弹窗,先留着以备腿哥
- (void)notFoundDevice {
    XM_WS(weakself);
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.nodevice.tips",@"plugin_gateway","没找到人体传感器") message:NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.switch.tips",@"plugin_gateway","看看") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *see = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.switch.see",@"plugin_gateway","看看") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakself goToBuy];
        }];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.switch.cancle",@"plugin_gateway","取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:see];
        [alert addAction:cancle];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.nodevice.tips",@"plugin_gateway","没找到人体传感器") message:NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.switch.tips",@"plugin_gateway","看看") delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.switch.cancle",@"plugin_gateway","取消") otherButtonTitles:NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.switch.see",@"plugin_gateway","看看"), nil];
        [alert show];
    }

}

#pragma mark -为找到相关子设备
- (void)addNotFoundSubDevicesView {
    /*
     "mydevice.gateway.defaultname.magnet" = "门窗传感器";
     "mydevice.gateway.defaultname.motion" = "人体传感器";
     */
    
    _tipsText = [[UILabel alloc] init];
    _tipsText.font = [UIFont systemFontOfSize:15.0f];
    _tipsText.textColor = [MHColorUtils colorWithRGB:0x606060];
    _tipsText.text = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.nodevice.tips",@"plugin_gateway","没找到人体传感器");
    _tipsText.numberOfLines = 0;
    _tipsText.lineBreakMode = NSLineBreakByWordWrapping;
    NSString *tips =  NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.nodevice.tips",@"plugin_gateway","没找到人体传感器");
    NSString *magnet = NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.motion",@"plugin_gateway","人体传感器");
    NSString *motion = NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.magnet",@"plugin_gateway","门窗传感器");
    NSString *nameSwitch = NSLocalizedStringFromTable(@"mydevice.gateway.defaultname.switch",@"plugin_gateway","无线开关");
    NSMutableAttributedString *tipsAttribute = [[NSMutableAttributedString alloc] initWithString:tips];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragraphStyle setLineSpacing:5];//调整行间距
    
    [tipsAttribute addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [tips length])];
    [tipsAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x00ba7c] range:[tips rangeOfString:magnet]];
    [tipsAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x00ba7c] range:[tips rangeOfString:motion]];
    [tipsAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x00ba7c] range:[tips rangeOfString:nameSwitch]];
    _tipsText.attributedText = tipsAttribute;
    _tipsText.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_tipsText];
    
    
    _btnSee = [UIButton buttonWithType:UIButtonTypeSystem];
    [_btnSee setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.switch.see",@"plugin_gateway","看看") forState:UIControlStateNormal];
    [_btnSee addTarget:self action:@selector(goToSee:) forControlEvents:UIControlEventTouchUpInside];
    [_btnSee setTitleColor:[MHColorUtils colorWithRGB:0x606060] forState:UIControlStateNormal];
    _btnSee.layer.cornerRadius = 20.0f;
    _btnSee.layer.borderWidth = 1.0f;
    [self.view addSubview:_btnSee];
    
}

- (void)addConstrants {
    XM_WS(weakself);
    [_tipsText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakself.view);
        make.width.mas_equalTo(WIN_WIDTH - 60);
    }];
    
    [_btnSee mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.view);
        make.top.mas_equalTo(weakself.tipsText.mas_bottom).with.offset(20);
        make.width.mas_equalTo(WIN_WIDTH - 60);
        make.height.mas_equalTo(40);
    }];
}

- (void)removewNotFoundSubDevicesView {
    [_tipsText removeFromSuperview];
    [_btnSee removeFromSuperview];
}

- (void)goToSee:(id)sender {
    [self goToBuy];
}
- (void)goToBuy {
    NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:kMagnetBuyingLinksKey];
    MHGatewayWebViewController* web = [[MHGatewayWebViewController alloc] initWithURL:[NSURL URLWithString:url ? url :kNOTFOUNDDEVICE]];
    web.isTabBarHidden = YES;
    web.hasShare = NO;
    web.controllerIdentifier = @"buyingLinks";
    web.strOriginalURL = url;
    [self.navigationController pushViewController:web animated:YES];
}

- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];

    MHLuDeviceSettingGroup *groupNone = [self.settingGroups firstObject];
    if (groupNone.items.count <= 0) {
        [self addNotFoundSubDevicesView];
        [self addConstrants];
    }
    else {
        [self removewNotFoundSubDevicesView];
    }

}


- (void)onBack:(id)sender
{
    [super onBack:sender];
    
    if (_onBackCallback) {
        _onBackCallback();
    }
}

- (void)setOnBackCallback:(void (^)())onBackCallback
{
    _onBackCallback = onBackCallback;
}

- (void)buildSubviews
{
    //    CGRect tableRect = self.view.bounds;
    //    tableRect.size.height -= tableRect.origin.y;
    //
    if ([_settingGroups count] > 1) {
        _settingTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        
    } else {
        _settingTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    }
    
    [self.view addSubview:_settingTableView];
    _settingTableView.delegate = self;
    _settingTableView.dataSource = self;
    _settingTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (Class)cellClassWithItem:(MHDeviceSettingItem *)item
{
    if ([item isKindOfClass:[MHLumiSettingCellItem class]]) {
        MHLumiSettingCellItem *lumiItem = (MHLumiSettingCellItem *)item;
        switch (lumiItem.lumiType) {
            case MHLumiSettingItemTypeDefault:
                return [MHLumiDefaultSettingCell class];
                break;
            case MHLumiSettingItemTypeSwitch:
                return [MHLumiSwitchSettingCell class];
                break;
            case MHLumiSettingItemTypeDetailSwitch:
                return [MHLumiSettingCell class];
                break;
            case MHLumiSettingItemTypeDetailLines:
                return [MHLumiSettingCell class];
                break;
            case MHLumiSettingItemTypeVolume:
                return [MHLumiVolumeSettingCell class];
                break;
            case MHLumiSettingItemTypeBrightness:
                return [MHLumiVolumeSettingCell class];
                break;
            case MHLumiSettingItemTypeAccess:
                return [MHLumiAccessSettingCell class];
                break;
            default:
                return [MHLumiSettingCell class];
                break;
        }
    }
    switch (item.type) {
        case MHDeviceSettingItemTypeDefault:
            return [MHDeviceSettingDefaultCell class];
            break;
        case MHDeviceSettingItemTypeSwitch:
            return [MHDeviceSettingSwitchCell class];
            break;
        case MHDeviceSettingItemTypeSegmentControl:
            return [MHDeviceSettingSegmentControlCell class];
            break;
        case MHDeviceSettingItemTypeDatePicker:
            return [MHDeviceSettingDatePickerCell class];
            break;
        case MHDeviceSettingItemTypeVolume:
            return [MHDeviceSettingVolumeCell class];
            break;
        case MHDeviceSettingItemTypeColorVolum:
            return [MHDeviceSettingColorVolumeCell class];
            break;
        case MHDeviceSettingItemTypeCheckmark:
            return [MHDeviceSettingCheckCell class];
            break;
        default:
            return [MHDeviceSettingDefaultCell class];
            break;
    }
}

#pragma mark - lumiItem
- (Class)cellClassWithLumiItem:(MHGatewaySettingCellItem *)item
{
    switch (item.type) {
        case MHGatewaySettingItemTypeDefault:
            return [MHGatewaySettingDefaultCell class];
            break;
        case MHGatewatSettingItemTypeDetailSwitch:
            return [MHGatewayAlarmClockCell class];
            break;
        case MHGatewatSettingItemTypeDetailLines:
            return [MHGatewayLogCell class];
            break;
        case MHGatewaySettingItemTypeVolume:
            return [MHGatewayVolumeSettingCell class];
            break;
        case MHGatewaySettingItemTypeBrightness:
            return [MHGatewayVolumeSettingCell class];
            break;
        case MHGatewaySettingItemTypeLeg:
            return [MHGatewayLegSettingCell class];
            break;
        default:
            return [MHGatewaySettingDefaultCell class];
            break;
    }
    return [MHGatewaySettingDefaultCell class];
}



- (void)insertNewItem:(MHDeviceSettingItem *)item atIndex:(NSUInteger)idx
{
    [self insertNewItem:item atIndex:idx atSection:0];
}

- (void)insertNewItem:(MHDeviceSettingItem *)item atIndex:(NSUInteger)idx atSection:(NSUInteger)section
{
    if (section > [self.settingGroups count]) {//越界保护
        return;
    }
    NSMutableArray* items = ((MHLuDeviceSettingGroup* )self.settingGroups[section]).items;
    if (idx > [items count]) { //越界保护
        return;
    }
    
    [_settingTableView beginUpdates];
    
    [items insertObject:item atIndex:idx];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:section];
    
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    
    [_settingTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    
    [_settingTableView endUpdates];
    
    //    [_settingTableView reloadData];
}

#pragma mark - 绿米增加cell,itemType不一致
- (void)lumiInsertNewItem:(MHGatewaySettingCellItem *)item atIndex:(NSUInteger)idx {
    [self lumiInsertNewItem:item atIndex:idx atSection:0];
}

- (void)lumiInsertNewItem:(MHGatewaySettingCellItem *)item atIndex:(NSUInteger)idx atSection:(NSUInteger)section
{
    if (section > [self.settingGroups count]) {//越界保护
        return;
    }
    NSMutableArray* items = ((MHLuDeviceSettingGroup* )self.settingGroups[section]).items;
    if (idx > [items count]) { //越界保护
        return;
    }
    
    [_settingTableView beginUpdates];
    
    [items insertObject:item atIndex:idx];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:section];
    
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    
    [_settingTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    
    [_settingTableView endUpdates];
    
    //    [_settingTableView reloadData];
}

- (void)removeItemAtIndex:(NSUInteger)idx
{
    [self removeItemAtIndex:idx atSection:0];
}
- (void)removeItemAtIndex:(NSUInteger)idx  atSection:(NSUInteger)section
{
    if (section > [self.settingGroups count]) {//越界保护
        return;
    }
    NSMutableArray* items = ((MHLuDeviceSettingGroup* )self.settingGroups[section]).items;
    if (idx > [items count]) { //越界保护
        return;
    }
    
    [_settingTableView beginUpdates];
    
    [items removeObjectAtIndex:idx];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:section];
    
    if ([_settingTableView cellForRowAtIndexPath:indexPath] == nil) { //保护，防止cell不存在
        return;
    }
    
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    
    [_settingTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    
    [_settingTableView endUpdates];
    
    //    [_settingTableView reloadData];
}

- (void)reloadItemAtIndex:(NSUInteger)idx
{
    [self reloadItemAtIndex:idx atSection:0];
}

- (void)reloadItemAtIndex:(NSUInteger)idx atSection:(NSUInteger)section
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:section];
    
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    
    [_settingTableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

- (NSUInteger)indexOfItemWithIdentifier:(NSString *)identifier
{
    NSUInteger __block result = NSNotFound;
    [self.settingGroups enumerateObjectsUsingBlock:^(MHLuDeviceSettingGroup* group, NSUInteger idx, BOOL *stop) {
        [group.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *innerStop) {
            if ([[(MHDeviceSettingItem *)obj identifier] isEqualToString:identifier])
            {
                result = idx;
                *innerStop = YES;
                *stop = YES;
            }
        }];
    }];
    
    return result;
}

- (MHDeviceSettingItem *)itemWithIdentifier:(NSString *)identifier
{
    __block MHDeviceSettingItem* item = nil;
    
    [self.settingGroups enumerateObjectsUsingBlock:^(MHLuDeviceSettingGroup* group, NSUInteger idx, BOOL *stop) {
        [group.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *innerStop) {
            if ([[(MHDeviceSettingItem *)obj identifier] isEqualToString:identifier])
            {
                item = obj;
                *innerStop = YES;
                *stop = YES;
            }
        }];
    }];
    
    return item;
}

- (void)reloadAllItems {
    
    UIEdgeInsets insets = _settingTableView.contentInset;
    if (_settingTableView) {
        [_settingTableView removeFromSuperview];
    }
    
    if ([self.settingGroups count] > 1) {
        _settingTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        
    } else {
        _settingTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    }
    [_settingTableView setContentInset:insets];
    
    [self.view addSubview:_settingTableView];
    _settingTableView.delegate = self;
    _settingTableView.dataSource = self;
    _settingTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    [self.settingTableView reloadData];
}

#pragma mark - UITableViewDelegate/DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray* settingItems = ((MHLuDeviceSettingGroup* )self.settingGroups[indexPath.section]).items;
    Class cellClass = nil;
    if ([settingItems[indexPath.row] isKindOfClass:[MHGatewaySettingCellItem class]]) {
        cellClass = [self cellClassWithLumiItem:settingItems[indexPath.row]];
    }
    else {
        cellClass = [self cellClassWithItem:settingItems[indexPath.row]];
    }

    return [cellClass heightWithItem:settingItems[indexPath.row] width:_settingTableView.bounds.size.width];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray* settingItems = ((MHLuDeviceSettingGroup* )self.settingGroups[section]).items;
    return [settingItems count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.settingGroups count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray* settingItems = ((MHLuDeviceSettingGroup* )self.settingGroups[indexPath.section]).items;
    Class cellClass = nil;
    if ([settingItems[indexPath.row] isKindOfClass:[MHGatewaySettingCellItem class]]) {
        cellClass = [self cellClassWithLumiItem:settingItems[indexPath.row]];
    }
    else {
        cellClass = [self cellClassWithItem:settingItems[indexPath.row]];
    }
    MHDeviceSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(cellClass)];
    if (!cell)
    {
        cell = [[cellClass alloc] initWithReuseIdentifier:NSStringFromClass(cellClass)];
    }
    
    [cell fillWithItem:settingItems[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSMutableArray* settingItems = ((MHLuDeviceSettingGroup* )self.settingGroups[indexPath.section]).items;
    MHDeviceSettingCell *cell = (MHDeviceSettingCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ([settingItems[indexPath.row] callBackOnSelect])
    {
        void((^block)(id));
        if ([cell isKindOfClass:[MHLumiSettingCell class]]) {
            block = [settingItems[indexPath.row] lumiCallbackBlock];
        }
        else {
            block = [settingItems[indexPath.row] callbackBlock];
        }
        if (block)
        {
            block(cell);
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.settingGroups count] > section) {
        return ((MHLuDeviceSettingGroup* )self.settingGroups[section]).title;
    }
    return nil;
}

@end
