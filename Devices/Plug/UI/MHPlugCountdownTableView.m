//
//  MHPlugCountdownTableView.m
//  MiHome
//
//  Created by hanyunhui on 15/9/29.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//

#import "MHPlugCountdownTableView.h"

#define PLUG_COUNTDOWN_CELL     @"CountdownCell"
#define TableViewCellHeight     54*[UIScreen mainScreen].bounds.size.height/667.0

@interface MHPlugCountdownTableView ()

@end

@implementation MHPlugCountdownTableView {
    NSArray*        _countdownArray;
    UITableView*    _tableview;
}

- (id)initWithTableView:(NSArray* )countdownArray rectFrame:(CGRect)rect {
    if (self = [super initWithFrame:rect]) {
        _countdownArray = countdownArray;
        _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
        [self buildSubviews];
    }
    
    return self;
}

- (void)buildSubviews {
    self.backgroundColor = [UIColor whiteColor];
    
    _tableview.delegate = self;
    _tableview.dataSource = self;
    [self addSubview:_tableview];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _countdownArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PLUG_COUNTDOWN_CELL];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PLUG_COUNTDOWN_CELL];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = _countdownArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.selectedCountdownTable) {
        self.selectedCountdownTable((int)(indexPath.row));
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TableViewCellHeight;
}

@end
