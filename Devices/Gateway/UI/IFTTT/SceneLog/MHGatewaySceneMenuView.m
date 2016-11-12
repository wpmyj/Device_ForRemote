//
//  MHGatewaySceneMenuView.m
//  MiHome
//
//  Created by guhao on 16/5/17.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewaySceneMenuView.h"
#import "MHTableViewCell.h"

#define kCELLID @"MHTableViewCell"

@interface MHGatewaySceneMenuView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *menuTableView;
@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, retain) NSMutableArray *dataSource;


@end

@implementation MHGatewaySceneMenuView



- (id)initWithDataSource:(NSArray *)dataSource
{
    self = [super init];
    if (self) {
        self.dataSource = [NSMutableArray arrayWithArray:dataSource];
        [self buildSubViews];
    }
    return self;
}


- (void)buildSubViews {
    
    self.backgroundColor = [MHColorUtils colorWithRGB:0x000000 alpha:0.3];
    self.frame = CGRectMake(0, 64, WIN_WIDTH, WIN_HEIGHT);
    
    self.menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT - 64)];
    self.menuTableView.backgroundColor = [MHColorUtils colorWithRGB:0x000000 alpha:0.3];
    self.menuTableView.delegate = self;
    self.menuTableView.dataSource = self;
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT)];
    footer.backgroundColor = [UIColor clearColor];
//    self.menuTableView.tableFooterView = [[UIView alloc] init];
        self.menuTableView.tableFooterView = footer;
    [self addSubview:self.menuTableView];
    
    UIGestureRecognizer *tapBgViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeView:)];
    [self.menuTableView.tableFooterView addGestureRecognizer:tapBgViewGesture];
}

#pragma - mark UITableViewDelegate UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MHTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCELLID];
    if (cell == nil) {
        cell = [[MHTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCELLID];
    }
    cell.textLabel.text = self.dataSource[indexPath.row][@"name"];
    if ([self.seletedDid isEqual:self.dataSource[indexPath.row][@"did"]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self hideView];
    if (self.delegate && [self.delegate respondsToSelector:@selector(menuViewDidSelectedRow:did:name:)]) {
        NSDictionary *selectDic = self.dataSource[indexPath.row];
        [self.delegate menuViewDidSelectedRow:indexPath.row did:selectDic[@"did"]  name:selectDic[@"name"]];
    }
    [tableView reloadData];

}


#pragma mark - show
- (void)showViewInView:(UIView*)view {
    
    [view addSubview:self];
//    [self setAnchorPoint:CGPointMake(0.9, 0) forView:self];
//    self.transform = CGAffineTransformMakeScale(0.05, 0.05);
//    
//    [UIView animateWithDuration:0.3 animations:^{
//        self.transform = CGAffineTransformMakeScale(0.99, 0.99);
//    } completion:^(BOOL finished) {
//        [self setAnchorPoint:CGPointMake(0.5, 0.5) forView:self];
//        self.transform = CGAffineTransformMakeScale(1, 1);
//    }];
}

- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint oldOrigin = view.frame.origin;
    view.layer.anchorPoint = anchorPoint;
    CGPoint newOrigin = view.frame.origin;
    
    CGPoint transition;
    transition.x = newOrigin.x - oldOrigin.x;
    transition.y = newOrigin.y - oldOrigin.y;
    
    view.center = CGPointMake (view.center.x - transition.x, view.center.y - transition.y);
}

#pragma mark - 隐藏
- (void)closeView:(id)sender {
    if (self.footerHide) self.footerHide();

    [self hideView];
}

- (void)hideView {
            [self removeFromSuperview];
//    [self setAnchorPoint:CGPointMake(0.9, 0) forView:self];
//    [UIView animateWithDuration:0.3 animations:^{
//        self.transform = CGAffineTransformMakeScale(0.05, 0.05);
//    } completion:^(BOOL finished) {
//        [self setAnchorPoint:CGPointMake(0.5, 0.5) forView:self];
//        [self removeFromSuperview];
//    }];
}


@end
