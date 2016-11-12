//
//  MHGatewayExpandableTableViewController.m
//  MiHome
//
//  Created by guhao on 16/5/17.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayExpandableTableViewController.h"
#import "MHTableViewCell.h"

@interface MHGatewayExpandableTableViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation MHGatewayExpandableTableViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)buildSubviews {
    [super buildSubviews];
    self.expandableTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.expandableTable.dataSource = self;
    self.expandableTable.delegate = self;
    self.expandableTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.expandableTable.tableFooterView = [UIView new];
    [self.view addSubview:self.expandableTable];
}

- (void)buildConstraints {
    [super buildConstraints];
    XM_WS(ws);
    [_expandableTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(ws.view);
    }];
}

- (void)didSelectContent:(MHExpandableContent *)content
{
    
}

- (void)didSelectCategory:(MHExpandableCategory *)category
{
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.categories count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section < [self.categories count]) {
        MHExpandableCategory* category = [self.categories objectAtIndex:section];
        if (category.expanded) { //category展开
            return [category.contents count] + 1;
        } else { //category收起
            return 1;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MHTableViewCell* cell = nil;
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:kExpandableCategoryCellID forIndexPath:indexPath];
        if (indexPath.section < [self.categories count]) {
            [cell configureWithDataObject:[self.categories objectAtIndex:indexPath.section]];
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:kExpandableContentCellID forIndexPath:indexPath];
        if (indexPath.section < [self.categories count]) {
            MHExpandableCategory* category = [self.categories objectAtIndex:indexPath.section];
            NSUInteger contentIndex = indexPath.row - 1;
            if (contentIndex < [category.contents count]) {
                [cell configureWithDataObject:[category.contents objectAtIndex:contentIndex]];
            }
        }
    }
    
    if (cell == nil) {
        cell = [[MHTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"defaultCell"];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if ([self.delegate respondsToSelector:@selector(didSelectRowAtIndexPath:)]) {
        [self.delegate didSelectRowAtIndexPath:indexPath];
    } else {
        if (indexPath.row == 0) { // select category
            if (indexPath.section < [self.categories count]) {
                [self.categories enumerateObjectsUsingBlock:^(MHExpandableCategory* category, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (idx == indexPath.section) { // 选中的category
//                        if (category.expandable) {
//                            category.expanded = !category.expanded; // 可展开的改变展开状态
//                        } else {
                            category.selected = YES; // 不可展开的选中
                            [self didSelectCategory:category];
//                        }
                    } else { // 其他category
                        if (category.expandable) {
                            // 其他category保持expanded状态
                        } else {
                            category.selected = NO; // 不可展开的取消选中
                        }
                    }
                }];
            }
        }
//        else { // select content
//            if (indexPath.section < [self.categories count]) {
//                MHExpandableCategory* category = [self.categories objectAtIndex:indexPath.section];
//                NSUInteger contentIndex = indexPath.row - 1;
//                if (contentIndex < [category.contents count]) {
//                    [category.contents enumerateObjectsUsingBlock:^(MHExpandableContent* content, NSUInteger idx, BOOL * _Nonnull stop) {
//                        if (idx == contentIndex) { //选中的content
//                            content.selected = YES;
//                            category.selectedContent = content;
//                            [self didSelectContent:content];
//                        } else { //其他content
//                            content.selected = NO;
//                        }
//                    }];
//                }
//            }
//        }
    }
    [tableView reloadData];
}



@end
