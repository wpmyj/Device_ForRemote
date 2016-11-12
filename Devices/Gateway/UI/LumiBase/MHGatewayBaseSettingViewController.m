//
//  MHGatewayBaseSettingViewController.m
//  MiHome
//
//  Created by Lynn on 7/30/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayBaseSettingViewController.h"
#import "MHDeviceSettingDefaultCell.h"
#import "MHDeviceSettingSwitchCell.h"
#import "MHDeviceSettingSegmentControlCell.h"
#import "MHDeviceSettingDatePickerCell.h"
#import "MHDeviceSettingVolumeCell.h"
#import "MHDeviceSettingCheckCell.h"
#import "MHDeviceSettingColorVolumeCell.h"
#import "MHGatewaySettingCell.h"
#import "MHGatewayAlarmClockCell.h"
#import "MHGatewayHelpDetailCell.h"
#import "MHGatewaySettingDefaultCell.h"
#import "MHGatewayLegSettingCell.h"
#import "MHGatewayVolumeSettingCell.h"

@implementation MHGatewaySettingGroup
@end

@interface MHGatewayBaseSettingViewController ()

@end

@implementation MHGatewayBaseSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buildSubviews
{
    if ([self.settingGroups count] > 1) {
        self.settingTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        
    } else {
        self.settingTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    }
    
    if (self.isGroupStyle) self.settingTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    
    [self.view addSubview:self.settingTableView];
    self.settingTableView.delegate = self;
    self.settingTableView.dataSource = self;
    self.settingTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    
    [self.settingTableView beginUpdates];
    
    [items insertObject:item atIndex:idx];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:section];
    
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    
    [self.settingTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    
    [self.settingTableView endUpdates];
    
    //    [_settingTableView reloadData];
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
    
    [self.settingTableView beginUpdates];
    
    [items removeObjectAtIndex:idx];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:section];
    
    if ([self.settingTableView cellForRowAtIndexPath:indexPath] == nil) { //保护，防止cell不存在
        return;
    }
    
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    
    [self.settingTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    
    [self.settingTableView endUpdates];
    
    //    [_settingTableView reloadData];
}

//- (Class)cellClassWithItem:(MHDeviceSettingItem *)item
//{
//    if ([item isKindOfClass:[MHGatewaySettingCellItem class]]){
//        switch (item.type) {
//            case MHGatewatSettingItemTypeDetailSwitch:
//                return [MHGatewayAlarmClockCell class];
//                break;
//            case MHGatewatSettingItemTypeDetailLines:
//                return [MHGatewayHelpDetailCell class];
//                break;
//            case MHGatewaySettingItemTypeBrightness:
//                return [MHGatewayVolumeSettingCell class];
//                break;
//            case MHGatewaySettingItemTypeVolume:
//                return [MHGatewayVolumeSettingCell class];
//                break;
//            case MHGatewaySettingItemTypeLeg:
//                return [MHGatewayLegSettingCell class];
//                break;
//            default:
//                return [MHGatewaySettingDefaultCell class];
//                break;
//        }
//    }
//    else{
//        switch (item.type) {
//            case MHDeviceSettingItemTypeDefault:
//                return [MHDeviceSettingDefaultCell class];
//                break;
//            case MHDeviceSettingItemTypeSwitch:
//                return [MHDeviceSettingSwitchCell class];
//                break;
//            case MHDeviceSettingItemTypeSegmentControl:
//                return [MHDeviceSettingSegmentControlCell class];
//                break;
//            case MHDeviceSettingItemTypeDatePicker:
//                return [MHDeviceSettingDatePickerCell class];
//                break;
//            case MHDeviceSettingItemTypeVolume:
//                return [MHDeviceSettingVolumeCell class];
//                break;
//            case MHDeviceSettingItemTypeColorVolum:
//                return [MHDeviceSettingColorVolumeCell class];
//                break;
//            case MHDeviceSettingItemTypeCheckmark:
//                return [MHDeviceSettingCheckCell class];
//                break;
//            default:
//                return [MHDeviceSettingDefaultCell class];
//                break;
//        }
//    
//    }
//    return [MHDeviceSettingDefaultCell class];
//}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if ([self.settingGroups count] > section) {
        if ([self.settingGroups[section] isKindOfClass:[MHGatewaySettingGroup class]])
            return ((MHGatewaySettingGroup* )self.settingGroups[section]).tail;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if([cell isKindOfClass:[MHGatewaySettingDefaultCell class]]){
        MHGatewaySettingDefaultCell *defaultCell = (MHGatewaySettingDefaultCell *)cell;
        if(defaultCell.gatewayItem.selected){
            cell.backgroundColor = [(MHGatewaySettingCell *)cell gatewayItem].backGroundRGB;
        }
        else {
            cell.backgroundColor = self.settingTableView.backgroundColor;
        }
    }
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//    
//    NSMutableArray* settingItems = ((MHLuDeviceSettingGroup* )self.settingGroups[indexPath.section]).items;
//    MHDeviceSettingCell *cell = (MHDeviceSettingCell *)[tableView cellForRowAtIndexPath:indexPath];
//    if ([settingItems[indexPath.row] callBackOnSelect])
//    {
//        void((^block)(id));
//        block = [settingItems[indexPath.row] callbackBlock];
//        if (block)
//        {
//            block(cell);
//        }
//    }
//}

@end
