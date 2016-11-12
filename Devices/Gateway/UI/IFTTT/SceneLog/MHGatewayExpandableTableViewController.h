//
//  MHGatewayExpandableTableViewController.h
//  MiHome
//
//  Created by guhao on 16/5/17.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHExpandableCategory.h"
#import "MHExpandableContent.h"

#define kExpandableCategoryCellID   @"ExpandableCategoryCellID"
#define kExpandableContentCellID    @"ExpandableContentCellID"

@protocol MHExpandableTableViewControllerDelegate <NSObject>

@optional
//选中indexPath
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface MHGatewayExpandableTableViewController : MHLuViewController

@property (nonatomic, strong) UITableView *expandableTable;
@property (nonatomic, strong) NSArray* categories;

- (void)didSelectContent:(MHExpandableContent *)content;
- (void)didSelectCategory:(MHExpandableCategory *)category;

@property (nonatomic, weak) id<MHExpandableTableViewControllerDelegate> delegate;
@end
