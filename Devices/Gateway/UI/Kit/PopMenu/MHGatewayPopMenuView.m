//
//  MHGatewayPopMenuView.m
//  MiHome
//
//  Created by guhao on 4/14/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayPopMenuView.h"
#import "MHGatewayPopMenuCell.h"

#define POPCELLID @"MHGatewayPopMenuCell"
#define MenuBackgroundColor [MHColorUtils colorWithRGB:0x000000 alpha:0.7]

@interface MHGatewayPopMenuView ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic,strong) UIView *touchView;
@property(nonatomic,strong) UIView *showContainerView;
@property(nonatomic,strong) UITableView *mainTableView;
@property(nonatomic,strong) NSArray *dataArray;

@property(nonatomic) CGRect showContainerViewFrame;

@end

@implementation MHGatewayPopMenuView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT)];
    if (self) {
        self.showContainerViewFrame = frame;
        [self buildSubViews];
    }
    return self;
}

- (void)buildSubViews {
    
//    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
  
    
    self.touchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT)];
    self.touchView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.touchView];
    
    self.showContainerView = [[UIView alloc] initWithFrame:self.showContainerViewFrame];
    self.showContainerView.layer.masksToBounds = YES;
    [self addSubview:self.showContainerView];
    
    
    
//    CAShapeLayer *layer = [CAShapeLayer new];
//    UIBezierPath *path = [UIBezierPath new];
//    [path moveToPoint:CGPointMake(0, 10)];
//    [path addLineToPoint:CGPointMake(6, 0)];
//    [path addLineToPoint:CGPointMake(12, 10)];
//    [path closePath];
//    layer.path = path.CGPath;
//    layer.lineWidth = 1.0;
//    layer.fillColor = MenuBackgroundColor.CGColor;
//    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
//    layer.bounds = CGPathGetBoundingBox(bound);
//    CGPathRelease(bound);
//    layer.position = CGPointMake(self.showContainerView.frame.size.width - 12, 7);
//    [self.showContainerView.layer addSublayer:layer];
//    
    self.mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 8, self.showContainerView.frame.size.width, self.showContainerView.frame.size.height - 8)];
    self.mainTableView.backgroundColor = MenuBackgroundColor;
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.mainTableView.layer.cornerRadius = 10.0f;
    self.mainTableView.layer.masksToBounds = YES;
    [self.showContainerView addSubview:self.mainTableView];

    UIGestureRecognizer *tapBgViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeView:)];
    [self.touchView addGestureRecognizer:tapBgViewGesture];
    
}

#pragma - mark UITableViewDelegate UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.delegate && [self.delegate respondsToSelector:@selector(popMenuDataSource)]) {
        NSLog(@"%ld", [[self.delegate popMenuDataSource] count]);
        return [[self.delegate popMenuDataSource] count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40 * ScaleHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MHGatewayPopMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:POPCELLID];
    if (!cell) {
        cell = [[MHGatewayPopMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:POPCELLID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(popMenuDataSource)]) {
        NSDictionary *itemDic = [[self.delegate popMenuDataSource] objectAtIndex:indexPath.row];
//        cell.titleLbl.text = [NSString stringWithFormat:@"%@", [itemDic objectForKey:@"title"]];
        cell.titleLbl.text = [itemDic objectForKey:@"title"];
        cell.titleLbl.textColor = [[itemDic objectForKey:@"seleted"] boolValue] ? [MHColorUtils colorWithRGB:0x0CABBA] : [UIColor whiteColor];
        cell.identifier = [itemDic objectForKey:@"identifier"];
        if (indexPath.row == [[self.delegate popMenuDataSource] count] - 1) {
            cell.lineView.hidden = YES;
        } else {
            cell.lineView.hidden = NO;
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(popMenuView:didSelectedRow:identifier:)]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(popMenuDataSource)]) {
            NSDictionary *itemDic = [[self.delegate popMenuDataSource] objectAtIndex:indexPath.row];
            [self.delegate popMenuView:self didSelectedRow:indexPath.row identifier:[itemDic objectForKey:@"identifier"]];
        }
    }
}

#pragma mark - action
- (void)showViewInView:(UIView*)view {
    
    [view addSubview:self];
    [self setAnchorPoint:CGPointMake(0.9, 0) forView:self.showContainerView];
    self.showContainerView.transform = CGAffineTransformMakeScale(0.05, 0.05);
    
    [UIView animateWithDuration:0.3 animations:^{
        self.showContainerView.transform = CGAffineTransformMakeScale(0.99, 0.99);
    } completion:^(BOOL finished) {
        [self setAnchorPoint:CGPointMake(0.5, 0.5) forView:self.showContainerView];
        self.showContainerView.transform = CGAffineTransformMakeScale(1, 1);
    }];
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

- (void)closeView:(id)sender {
    [self hideView];
}

- (void)hideView {
    
    [self setAnchorPoint:CGPointMake(0.9, 0) forView:self.showContainerView];
    [UIView animateWithDuration:0.3 animations:^{
        self.showContainerView.transform = CGAffineTransformMakeScale(0.05, 0.05);
    } completion:^(BOOL finished) {
        [self setAnchorPoint:CGPointMake(0.5, 0.5) forView:self.showContainerView];
        [self removeFromSuperview];
    }];
}

- (void)updateData {
    [self.mainTableView reloadData];
}

@end
