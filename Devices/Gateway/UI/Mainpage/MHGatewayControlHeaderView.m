//
//  MHGatewayControlHeaderView.m
//  MiHome
//
//  Created by Lynn on 2/16/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayControlHeaderView.h"
#import "MHGatewayAlarmControlView.h"
#import "MHGatewayNightLightControlView.h"
#import "MHLumiFmPlayerViewController.h"
#import "MHGatewayTempAndHumidityViewController.h"
#import "MHGatewayMainpageAnimation.h"
#import "MHGatewayDragCircularSlider.h"


#define kHeight self.frame.size.height

@interface MHGatewayControlHeaderView ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) MHDeviceGateway *gateway;
@property (nonatomic, strong) UIView *leftBgView;
@property (nonatomic, strong) UIView *rightBgView;
@property (nonatomic, strong) UIView *midBgView;

@property (nonatomic, assign) BOOL isShowFM;
@property (nonatomic, assign) BOOL isShowNightLight;

@property (nonatomic, strong) MHGatewayMainpageAnimation *changeColorAnimation;

@end

@implementation MHGatewayControlHeaderView
{
    NSMutableArray *                        _scrollViewContentArray;
    NSInteger                               _totalPageCount;
}

- (id)initWithFrame:(CGRect)frame sensor:(MHDeviceGateway* )gateway {
    if (self = [super initWithFrame:frame]) {
        _gateway = gateway;
        _isShowFM = [_gateway.model isEqualToString:@"lumi.gateway.v3"]; // 什么时候要FM
        _isShowNightLight = ![_gateway.model isEqualToString:DeviceModelCamera]; // 什么时候要夜灯
        [self buildSubviews];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"dead");
}

- (void)buildSubviews {
    [self buildContentView];
    NSInteger count = _scrollViewContentArray.count;
    _currentPageIndex = 0;
    //scrollview
    _mainPageScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _mainPageScrollView.contentSize = CGSizeMake(count > 1 ? WIN_WIDTH * 3 : WIN_WIDTH, kHeight);
    _mainPageScrollView.pagingEnabled = YES;
    _mainPageScrollView.delegate = self;
    _mainPageScrollView.bounces = NO;
    _mainPageScrollView.showsHorizontalScrollIndicator = NO;
    [_mainPageScrollView setContentOffset:CGPointMake(count > 1 ? WIN_WIDTH*1 : 0, 0) animated:NO];
    [self addSubview:self.mainPageScrollView];
    
    self.changeColorAnimation = [[MHGatewayMainpageAnimation alloc] init];
    NSMutableArray *colorsArray = [NSMutableArray array];
    [colorsArray addObject:@(0x17b56c)];
    if (_isShowFM){
        [colorsArray addObject:@(0x0ca8ba)];
    }
    if (_isShowNightLight){
        [colorsArray addObject:@(0x22333f)];
    }
    self.changeColorAnimation.colorsArray = colorsArray;
    self.changeColorAnimation.headerView = self;

    //支持设置默认的当前页
    _totalPageCount = count;
    [self setPageControl:_currentPageIndex];

    [self setDefaultCanvasView];
    [self setDefaultContentView];
    
    //pageControll
    CGRect pageControlFrame = CGRectMake(0, kHeight - 35, WIN_WIDTH, 35);
    _mainPageControll = [[MHLumiPageControl alloc] initWithFrame:pageControlFrame];
    _mainPageControll.numberOfPages = _scrollViewContentArray.count;
    _mainPageControll.currentPage = _currentPageIndex;
    [self addSubview:self.mainPageControll];
}

//支持设置默认的当前页
- (void)setCurrentPageIndex:(NSInteger)currentPageIndex {
    _currentPageIndex = currentPageIndex;
    [self rebuildScrollView];
    if (_scrollViewContentArray.count > 1){
        [_mainPageScrollView setContentOffset:CGPointMake(WIN_WIDTH, 0) animated:NO];
    }else if(_scrollViewContentArray.count == 1){
        [_mainPageScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
    [self setPageControl:_currentPageIndex];
}

- (void)setHeaderBufferView:(UIView *)headerBufferView {
    _headerBufferView = headerBufferView;
    self.changeColorAnimation.headerBufferView = headerBufferView;
    _headerBufferView.backgroundColor = self.backgroundColor;
}

//默认画布
- (void)setDefaultCanvasView {
    if (_scrollViewContentArray.count > 1){
        _leftBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, kHeight)];
        _leftBgView.backgroundColor = [UIColor clearColor];
        
        [_mainPageScrollView addSubview:_leftBgView];
        
        _midBgView = [[UIView alloc] initWithFrame:CGRectMake(WIN_WIDTH, 0, WIN_WIDTH, kHeight)];
        _midBgView.backgroundColor = [UIColor clearColor];
        [_mainPageScrollView addSubview:_midBgView];
        _rightBgView = [[UIView alloc] initWithFrame:CGRectMake(WIN_WIDTH * 2, 0, WIN_WIDTH, kHeight)];
        _rightBgView.backgroundColor = [UIColor clearColor];
        [_mainPageScrollView addSubview:_rightBgView];
    }else if (_scrollViewContentArray.count == 1){
        _midBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, kHeight)];
        _midBgView.backgroundColor = [UIColor clearColor];
        [_mainPageScrollView addSubview:_midBgView];
    }

}

//创建控件
- (void)buildContentView {
    _scrollViewContentArray = [NSMutableArray new];
    
    MHGatewayAlarmControlView *alarmView = [self buildAlarm];
    [_scrollViewContentArray addObject:alarmView];
    
    if(_isShowFM) {
        MHGatewayFMControlView *fmBgView = [self buildFM];
        [_scrollViewContentArray addObject:fmBgView];
    }
    
    if (_isShowNightLight){
        MHGatewayNightLightControlView *nightLightView = [self buildNightLight];
        [_scrollViewContentArray addObject:nightLightView];
    }

}

//警戒
- (MHGatewayAlarmControlView *)buildAlarm {
    float alarmRadius = 188 * ScaleHeight;
    CGFloat topSpacing = 5 * ScaleHeight;
    CGRect alarmViewRect = CGRectMake((WIN_WIDTH - alarmRadius) / 2, topSpacing, alarmRadius, alarmRadius);
    MHGatewayAlarmControlView *alarmView = [[MHGatewayAlarmControlView alloc] initWithFrame:alarmViewRect sensor:_gateway];
    alarmView.padding = 6 * ScaleWidth;
    return alarmView;
}

//FM
- (MHGatewayFMControlView *)buildFM {
    CGRect fmViewRect = CGRectMake(0, 0, WIN_WIDTH, kHeight);
    MHGatewayFMControlView *fmBgView = [[MHGatewayFMControlView alloc] initWithFrame:fmViewRect sensor:_gateway];
    fmBgView.backgroundColor = [UIColor clearColor];
    [fmBgView addTarget:self action:@selector(goToFmPlayer:) forControlEvents:UIControlEventTouchUpInside];
    return fmBgView;
}

//彩灯
- (MHGatewayNightLightControlView *)buildNightLight {
    float nightRadius = kHeight - 35;
    CGRect nightLightViewRect = CGRectMake(0, 0, WIN_WIDTH, nightRadius);
    MHGatewayNightLightControlView *nightLightView = [[MHGatewayNightLightControlView alloc] initWithFrame:nightLightViewRect sensor:_gateway];
    return nightLightView;
}

//默认布局
- (void)setDefaultContentView {
    if (_totalPageCount > 1){
        NSInteger leftIndex = (_currentPageIndex + _totalPageCount - 1) % _totalPageCount;
        NSInteger rightIndex = (_currentPageIndex + 1) % _totalPageCount;
        
        id copyedView;
        if(leftIndex == rightIndex){
            if([_scrollViewContentArray[leftIndex] isKindOfClass:[MHGatewayNightLightControlView class]]){
                copyedView = [self buildNightLight];
                [copyedView updateNightLightStatus];
            }
            else if([_scrollViewContentArray[leftIndex] isKindOfClass:[MHGatewayAlarmControlView class]]){
                copyedView = [self buildAlarm];
            }
        }
        else {
            copyedView = _scrollViewContentArray[rightIndex];
        }
        [self resetScrollviewContent:_scrollViewContentArray[leftIndex] inCanvasView:_leftBgView];
        [self resetScrollviewContent:_scrollViewContentArray[_currentPageIndex] inCanvasView:_midBgView];
        [self resetScrollviewContent:copyedView inCanvasView:_rightBgView];
    }else if(_totalPageCount == 1){
        [self resetScrollviewContent:_scrollViewContentArray[_currentPageIndex] inCanvasView:_midBgView];
    }
}

#pragma mark - FM
- (void)goToFmPlayer:(id)sender {
    if (self.clickCallBack) {
        self.clickCallBack();
    }
}

#pragma mark - 更新控件状态
- (void)updateMainPageStatus {
    //FM
    if (_mainPageControll.currentPage == 1 && _isShowFM) {
        if ([_scrollViewContentArray[_mainPageControll.currentPage] isKindOfClass:[MHGatewayFMControlView class]]) {
            MHGatewayFMControlView *fm = _scrollViewContentArray[_mainPageControll.currentPage];
            [fm updateStastus];
        }
    }
    //彩灯
    if ([[_scrollViewContentArray lastObject] isKindOfClass:[MHGatewayNightLightControlView class]]) {
        MHGatewayNightLightControlView *nightLightView = [_scrollViewContentArray lastObject];
        [nightLightView updateNightLightStatus];
    }
    //警戒
    if ([[_scrollViewContentArray firstObject] isKindOfClass:[MHGatewayAlarmControlView class]]) {
        MHGatewayAlarmControlView *armingView = [_scrollViewContentArray firstObject];
        [armingView setupGateway];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsizeX = scrollView.contentOffset.x;
    if(offsizeX > WIN_WIDTH){
        //向后滑
        CGFloat progress = (offsizeX - WIN_WIDTH) / WIN_WIDTH;
        [self.changeColorAnimation headerViewBackgroundColorAnimation:Direction_Left progress:progress];
        [_mainPageControll animationActiveImage:progress direction:Page_Left];
    }
    else if (offsizeX < WIN_WIDTH){
        //向前滑
        CGFloat progress = (WIN_WIDTH - offsizeX) / WIN_WIDTH;
        [self.changeColorAnimation headerViewBackgroundColorAnimation:Direction_Right progress:progress];
        [_mainPageControll animationActiveImage:progress direction:Page_Right];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self rebuildScrollView];
    [_mainPageScrollView setContentOffset:CGPointMake(WIN_WIDTH, 0) animated:NO];
    [self setPageControl:_currentPageIndex];
}

- (void)rebuildScrollView{
    CGPoint offset=[_mainPageScrollView contentOffset];
    if (offset.x > WIN_WIDTH) { //向右滑动
        _currentPageIndex = (_currentPageIndex + 1 ) % _totalPageCount;
    }
    else if(offset.x < WIN_WIDTH){ //向左滑动
        _currentPageIndex = (_currentPageIndex + _totalPageCount - 1) % _totalPageCount;
    }
    [self resetScrollviewContent:_scrollViewContentArray[_currentPageIndex] inCanvasView:_midBgView];
    
    [self setDefaultContentView];

//    NSInteger leftIndex = (_currentPageIndex + _totalPageCount - 1) % _totalPageCount;
//    NSInteger rightIndex = (_currentPageIndex + 1) % _totalPageCount;
    
//    id copyedView;
//    if(leftIndex == rightIndex){
//        if([_scrollViewContentArray[leftIndex] isKindOfClass:[MHGatewayNightLightControlView class]]){
//            copyedView = [self buildNightLight];
//            [copyedView updateNightLightStatus];
//        }
//        else if([_scrollViewContentArray[leftIndex] isKindOfClass:[MHGatewayAlarmControlView class]]){
//            copyedView = [self buildAlarm];
//        }
//    }
//    else {
//        copyedView = _scrollViewContentArray[rightIndex];
//    }
//    
//    [self resetScrollviewContent:_scrollViewContentArray[leftIndex] inCanvasView:_leftBgView];
//    [self resetScrollviewContent:copyedView inCanvasView:_rightBgView];
}

- (void)resetScrollviewContent:(UIView *)contentView inCanvasView:(UIView *)canvasView {
    [canvasView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [canvasView addSubview:contentView];
}

#pragma mark - set pagecontrol
- (void)setPageControl:(NSInteger)currentPage {
    self.changeColorAnimation.currentPage = currentPage;
    self.mainPageControll.currentPage = currentPage;
    NSUInteger colorValue = [self.changeColorAnimation.colorsArray[currentPage] unsignedIntegerValue];
    self.backgroundColor = [MHColorUtils colorWithRGB:colorValue];
    _headerBufferView.backgroundColor = self.backgroundColor;
    //彩灯
    if ([[_scrollViewContentArray lastObject] isKindOfClass:[MHGatewayNightLightControlView class]]) {
        MHGatewayNightLightControlView *nightLightView = [_scrollViewContentArray lastObject];
        [nightLightView updateNightLightStatus];
    }
    
    for (UIView *todoView in _scrollViewContentArray) {
        if ([todoView isKindOfClass:[MHGatewayNightLightControlView class]]){
            MHGatewayNightLightControlView *nightLightView = (MHGatewayNightLightControlView *)todoView;
            [nightLightView updateNightLightStatus];
        }
    }
   
}







@end
