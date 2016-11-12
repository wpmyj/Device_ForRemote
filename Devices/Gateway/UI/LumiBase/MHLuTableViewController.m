//
//  MHLuTableViewController.m
//  MiHome
//
//  Created by Lynn on 1/4/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLuTableViewController.h"

@interface MHLuTableViewController ()

@end

@implementation MHLuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.canDelete) return YES;
    return NO;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete){
        
        NSMutableArray *ds = [NSMutableArray arrayWithArray:self.dataSource];
        [ds removeObjectAtIndex:indexPath.row];
        self.dataSource = [ds mutableCopy];
        
        if (self.dataSource.count){
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [tableView endUpdates];
        }
        else {
            [tableView reloadData];
        }
        
        [self showDeleteAV:indexPath];
    }
}

- (void)showDeleteAV:(NSIndexPath *)indexPath {
    if (self.luDelegate) [self.luDelegate deleteTableViewCell:indexPath];
}

@end
