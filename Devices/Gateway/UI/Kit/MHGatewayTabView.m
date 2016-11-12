//
//  MHGatewayTabView.m
//  MiHome
//
//  Created by Lynn on 10/20/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayTabView.h"

#define Spline_Gap_V 9

#define Color_Highlighted 0x02a99f
#define Color_Normal 0x666666

#define Line_MoveIn @"in"
#define Line_MoveOut @"out"

@implementation MHGatewayTabView{
    //当前各个title列表
    NSArray*                _titleArray;
    void(^_callback)(NSInteger);
    NSInteger               _itemCount;
    
    //各个item 按钮
    NSMutableArray*         _buttonsArray;
    NSMutableArray*         _bottomLinesArray;
    
    NSInteger               _curHighlightedIndex;

    LumiTabStyle            _tabStyle;
}

- (id)initWithFrame:(CGRect)frame
         titleArray:(NSArray*)titleArray
           callback:(void(^)(NSInteger))callback {
    if (self = [super initWithFrame:frame]) {
        _titleArray = titleArray;
        self.titleArray = titleArray;
        _callback = callback;
        _itemCount = [_titleArray count];
        _buttonsArray = [[NSMutableArray alloc] init];
        _bottomLinesArray = [[NSMutableArray alloc] init];
        _curHighlightedIndex = 0;
        self.currentIndex = -1;
        _tabStyle = LumiTabStyleDefault;
        [self buildSubviews];
        [self selectItem:0];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
         titleArray:(NSArray*)titleArray
          stypeType:(LumiTabStyle)style
           callback:(void(^)(NSInteger))callback {
    
    if (self = [super initWithFrame:frame]) {
        _titleArray = titleArray;
        self.titleArray = titleArray;
        _callback = callback;
        _itemCount = [_titleArray count];
        _buttonsArray = [[NSMutableArray alloc] init];
        _bottomLinesArray = [[NSMutableArray alloc] init];
        _curHighlightedIndex = 0;
        self.currentIndex = -1;
        _tabStyle = style;
        
        [self buildSubviews];
        [self selectItem:0];
    }
    return self;
}

- (void)buildSubviews {
    if(_tabStyle == LumiTabStyleDefault) {
        [self buildDefaultStyleSubviews];
    }
    else if(_tabStyle == LumiTabStyleWithFrame) {
        [self buildTabStyleWithFrame];
    }
    else if (_tabStyle == LumiTabStyleInTitle) {
        [self buildTabStyleInTitle];
    }
}

- (void)selectItem:(NSInteger)idx {
    if(self.currentIndex != idx){
        self.currentIndex = idx;
        
        if (_tabStyle == LumiTabStyleDefault) {
            [self defaultStyleAnimation:idx];
        }
        else if(_tabStyle == LumiTabStyleWithFrame){
            [self frameStyleAnimation:idx];
        }
        else if(_tabStyle == LumiTabStyleInTitle){
            [self titleStyleAnimation:idx];
        }
        
        //重绘
        [self setNeedsDisplay];
        
        _curHighlightedIndex = idx;
        
        if (_callback) {
            _callback(idx);
        }
    }
}

- (void)btnAction:(UITapGestureRecognizer *)sender {
    NSInteger index = sender.view.tag;
    [self selectItem:index];
}

#pragma mark - 分style创建tabbar
- (void)buildTabStyleInTitle {
    self.backgroundColor = [UIColor clearColor];
    CGFloat itemWidth = CGRectGetWidth(self.frame)  / _itemCount;
    NSInteger idx = 0;
    for (id titleDic in _titleArray) {
        CGRect itemRect = CGRectMake(itemWidth * idx, 0, itemWidth, CGRectGetHeight(self.bounds));
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:itemRect];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [MHColorUtils colorWithRGB:Color_Normal];
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.text = [titleDic valueForKey:@"name"];
        titleLabel.tag = idx;
        titleLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnAction:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [titleLabel addGestureRecognizer:tap];
        [self addSubview:titleLabel];
     
        [_buttonsArray addObject:titleLabel];
        idx++;
    }
}

- (void)buildTabStyleWithFrame {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.borderColor = [MHColorUtils colorWithRGB:0xf1f1f1].CGColor;
    self.layer.borderWidth = 1.f;
    self.layer.cornerRadius = 3.f;
    CGFloat itemWidth = CGRectGetWidth(self.frame)  / _itemCount;
    
    //画竖直线
    for (int i = 1; i < _itemCount; i++) {
        UIView* spline = [[UIView alloc]init];
        spline.frame = CGRectMake(itemWidth*i, 0, 0.5, self.bounds.size.height);
        spline.backgroundColor = [MHColorUtils colorWithRGB:0xf1f1f1];
        [self addSubview:spline];
    }
    
    NSInteger idx = 0;
    for (NSString* title in _titleArray) {
        
        CGRect itemRect = CGRectMake(itemWidth * idx, 0, itemWidth, CGRectGetHeight(self.bounds));
        
        UIView* bg = [[UIView alloc]init];
        bg.frame = CGRectMake(itemWidth*idx-0.5, 0.5, itemWidth, CGRectGetHeight(self.bounds)-1);
        bg.backgroundColor = [UIColor colorWithRed:235.f/255.f green:235.f/255.f blue:235.f/255.f alpha:1.f];
        bg.tag = idx;
        bg.hidden = YES;
        [self addSubview:bg];
        [_bottomLinesArray addObject:bg];
        
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:itemRect];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [MHColorUtils colorWithRGB:Color_Normal];
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.text = title;
        titleLabel.tag = idx;
        titleLabel.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnAction:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [titleLabel addGestureRecognizer:tap];
        [self addSubview:titleLabel];
        [_buttonsArray addObject:titleLabel];
        
        idx++;
    }
}

- (void)buildDefaultStyleSubviews {
    self.backgroundColor = [UIColor clearColor];
    CGFloat itemWidth = CGRectGetWidth(self.bounds)  / _itemCount;
    
    //画竖直线
    for (int i = 1; i < _itemCount; i++) {
        UIView* spline = [[UIView alloc]init];
        spline.frame = CGRectMake(itemWidth*i, Spline_Gap_V, 0.5, self.bounds.size.height - Spline_Gap_V*2);
        spline.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:spline];
    }
    
    //画水平线
    //    UIView* hSpline = [[UIView alloc]init];
    //    hSpline.frame = CGRectMake(0, CGRectGetHeight(self.bounds)-1, CGRectGetWidth(self.bounds)-0.5, 0.5);
    //    hSpline.backgroundColor = [UIColor lightGrayColor];
    //    [self addSubview:hSpline];
    
    NSInteger idx = 0;
    for (NSString* title in _titleArray) {
        CGRect itemRect = CGRectMake(itemWidth * idx, 0, itemWidth, CGRectGetHeight(self.bounds));
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:itemRect];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [MHColorUtils colorWithRGB:Color_Normal];
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.text = title;
        titleLabel.tag = idx;
        titleLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnAction:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [titleLabel addGestureRecognizer:tap];
        [self addSubview:titleLabel];
        [_buttonsArray addObject:titleLabel];
        
        UIView* bottomSpline = [[UIView alloc]init];
        bottomSpline.frame = CGRectMake(itemWidth*idx, CGRectGetHeight(self.bounds)-0.5, itemWidth, 0.5);
        bottomSpline.backgroundColor = [MHColorUtils colorWithRGB:Color_Highlighted alpha:0.4];
        bottomSpline.tag = idx;
        bottomSpline.hidden = YES;
        [self addSubview:bottomSpline];
        [_bottomLinesArray addObject:bottomSpline];
        
        idx++;
    }
}

#pragma mark - animation
- (void)titleStyleAnimation:(NSInteger)idx {
    __block UIColor *cancelColor ;
    //取消之前的选中状态
    if(idx == 0) {
        cancelColor = [UIColor colorWithWhite:1.f alpha:0.5];
    }
    else if (idx == 1 && _titleArray.count > 3) {
        cancelColor = [UIColor colorWithWhite:1.f alpha:0.5];
    }
    else {
        cancelColor = [MHColorUtils colorWithRGB:Color_Normal];
    }
    [_buttonsArray enumerateObjectsUsingBlock:^(UILabel *obj, NSUInteger idx, BOOL *stop) {
        obj.textColor = cancelColor;
    }];

    //设定当前点击的选中状态
    UILabel *enableBtn = (UILabel*)[_buttonsArray objectAtIndex:idx];
    enableBtn.textColor = [_titleArray[idx] valueForKey:@"color"];
}

- (void)frameStyleAnimation:(NSInteger)idx {
    UIView *cancelLine = [_bottomLinesArray objectAtIndex:_curHighlightedIndex];
    UIView *enableLine = [_bottomLinesArray objectAtIndex:idx];
    
    
    CATransition *animation = [[CATransition alloc] init];
    animation.duration = 0.4;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;

    if (idx > _curHighlightedIndex) {
        animation.subtype = kCATransitionFromLeft;
    }
    else if  (idx < _curHighlightedIndex ) {
        animation.subtype = kCATransitionFromRight;
    }

    
    [cancelLine setHidden:YES];
    [enableLine setHidden:NO];
    if (idx != _curHighlightedIndex) {
        [enableLine.layer addAnimation:animation forKey:nil];
    }
}

- (void)defaultStyleAnimation:(NSInteger)idx {
    UILabel *cancelBtn = (UILabel*)[_buttonsArray objectAtIndex:_curHighlightedIndex];
    UILabel *enableBtn = (UILabel*)[_buttonsArray objectAtIndex:idx];
    UIView *cancelLine = [_bottomLinesArray objectAtIndex:_curHighlightedIndex];
    UIView *enableLine = [_bottomLinesArray objectAtIndex:idx];
    [cancelLine.layer addAnimation:[self lineMoveAnim:Line_MoveOut] forKey:nil];
    [enableLine.layer addAnimation:[self lineMoveAnim:Line_MoveIn] forKey:nil];
    
    //取消之前的选中状态
    cancelBtn.textColor = [MHColorUtils colorWithRGB:Color_Normal];
    [cancelLine setHidden:YES];
    
    //设定当前点击的选中状态
    enableBtn.textColor = [MHColorUtils colorWithRGB:Color_Highlighted];
    [enableLine setHidden:NO];
}

-(CATransition *)lineMoveAnim:(NSString *)inOut{
    CATransition *animation = [[CATransition alloc] init];
    animation.duration = 0.4;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    if ([inOut isEqualToString:Line_MoveIn])
        animation.subtype = kCATransitionFromRight;
    else if ([inOut isEqualToString:Line_MoveOut])
        animation.subtype = kCATransitionFromLeft;
    return animation;
}

@end
