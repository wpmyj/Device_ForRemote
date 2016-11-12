//
//  MHLuDeviceSettingViewController.h
//  MiHome
//
//  Created by Lynn on 10/16/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceSettingCell.h"
#import "MHGatewaySettingCell.h"

@interface MHLuDeviceSettingGroup : NSObject
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSMutableArray* items;
@end

@interface MHLuDeviceSettingViewController : MHLuViewController<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray* settingGroups;
@property (nonatomic, strong) UITableView *settingTableView;

- (void)lumiInsertNewItem:(MHGatewaySettingCellItem *)item atIndex:(NSUInteger)idx;


- (void)insertNewItem:(MHDeviceSettingItem *)item atIndex:(NSUInteger)idx;
- (void)removeItemAtIndex:(NSUInteger)idx;
- (void)reloadItemAtIndex:(NSUInteger)idx;
- (void)reloadItemAtIndex:(NSUInteger)idx atSection:(NSUInteger)section;
- (void)reloadAllItems;
- (void)removewNotFoundSubDevicesView;

- (NSUInteger)indexOfItemWithIdentifier:(NSString *)identifier;
- (MHDeviceSettingItem *)itemWithIdentifier:(NSString *)identifier;

- (void)setOnBackCallback:(void (^)())onBackCallback;

@end
