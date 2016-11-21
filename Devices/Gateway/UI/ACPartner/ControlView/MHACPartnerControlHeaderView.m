//
//  MHACPartnerControlHeaderView.m
//  MiHome
//
//  Created by ayanami on 16/5/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerControlHeaderView.h"
#import "MHGatewayAlarmControlView.h"
#import "MHGatewayNightLightControlView.h"
#import "MHLumiFmPlayerViewController.h"
#import "MHGatewayTempAndHumidityViewController.h"
#import "MHGatewayMainpageAnimation.h"
#import "MHGatewayDragCircularSlider.h"
#import "MHACPartnerAddAcListViewController.h"
#import "MHACPartnerDetailViewController.h"
#import "MHLumiHtmlHandleTools.h"
#import "MHACPartnerUploadViewController.h"
#import "MHACPartnerAddTipsViewController.h"
#import "MHACPartnerAddControlView.h"

#define kHeight self.frame.size.height

@interface MHACPartnerControlHeaderView ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) MHDeviceAcpartner *acpartner;
@property (nonatomic, strong) MHACPartnerAddControlView *acAddView;

@property (nonatomic, strong) MHGatewayMainpageAnimation *changeColorAnimation;

@property (nonatomic, strong) UIView *leftBgView;
@property (nonatomic, strong) UIView *rightBgView;
@property (nonatomic, strong) UIView *midBgView;


@end

@implementation MHACPartnerControlHeaderView
{
    NSMutableArray *                        _scrollViewContentArray;
    NSInteger                               _totalPageCount;
    MHGatewayFMControlView *                _fmView;
    MHGatewayAlarmControlView*              _alarmView;
}

- (id)initWithFrame:(CGRect)frame sensor:(MHDeviceAcpartner *)acpartner {
    if (self = [super initWithFrame:frame]) {
        self.acpartner = acpartner;
        [self buildSubViews];
//        [self buildConstraints];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"dead");
}

- (void)buildSubViews {
//    self.headerBufferView.backgroundColor = [MHColorUtils colorWithRGB:0x22333f];
    
    //只有空调,需求频繁变更先保留
//    CGRect acAddViewViewRect = CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT * 0.4);
//    self.acAddView = [[MHACPartnerAddControlView alloc] initWithFrame:acAddViewViewRect sensor:_acpartner];
//    XM_WS(weakself);
//    [self.acAddView  setAddACClicked:^{
//        if (weakself.clickCallBack) {
//            weakself.clickCallBack(Acpartner_MainPage_AddAC);
//        }
//    }];
//    [self.acAddView  setAcDetailClicked:^{
//        if (weakself.clickCallBack) {
//            weakself.clickCallBack(Acpartner_MainPage_ACDetail);
//        }
//    }];
//    [self.acAddView  addTarget:self action:@selector(goToACDetail:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:self.acAddView];
    
    //scrollview
    _mainPageScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _mainPageScrollView.contentSize = CGSizeMake(WIN_WIDTH * 3, kHeight);
    _mainPageScrollView.pagingEnabled = YES;
    _mainPageScrollView.delegate = self;
    _mainPageScrollView.bounces = NO;
    _mainPageScrollView.showsHorizontalScrollIndicator = NO;
    [_mainPageScrollView setContentOffset:CGPointMake(WIN_WIDTH, 0) animated:NO];
    [self addSubview:self.mainPageScrollView];
    
    self.changeColorAnimation = [[MHGatewayMainpageAnimation alloc] init];
    self.changeColorAnimation.colorsArray = @[  @(0x17b56c), @(0x0ca8ba) ];//@(0x22333f),
    self.changeColorAnimation.headerView = self;

    //支持设置默认的当前页
    _totalPageCount = 2;
    _currentPageIndex = 0;
    [self setPageControl:_currentPageIndex];
    
    [self setDefaultCanvasView];
    [self buildContentView];
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
    [_mainPageScrollView setContentOffset:CGPointMake(WIN_WIDTH, 0) animated:NO];
    [self setPageControl:_currentPageIndex];
}

- (void)setHeaderBufferView:(UIView *)headerBufferView {
    _headerBufferView = headerBufferView;
    self.changeColorAnimation.headerBufferView = headerBufferView;
    _headerBufferView.backgroundColor = self.backgroundColor;
}

//默认画布
- (void)setDefaultCanvasView {
    _leftBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, kHeight)];
    _leftBgView.backgroundColor = [UIColor clearColor];
    
    [_mainPageScrollView addSubview:_leftBgView];
    
    _midBgView = [[UIView alloc] initWithFrame:CGRectMake(WIN_WIDTH, 0, WIN_WIDTH, kHeight)];
    _midBgView.backgroundColor = [UIColor clearColor];
    [_mainPageScrollView addSubview:_midBgView];
    _rightBgView = [[UIView alloc] initWithFrame:CGRectMake(WIN_WIDTH * 2, 0, WIN_WIDTH, kHeight)];
    _rightBgView.backgroundColor = [UIColor clearColor];
    [_mainPageScrollView addSubview:_rightBgView];
}

//创建控件
- (void)buildContentView {
    _scrollViewContentArray = [NSMutableArray new];
    
//    MHACPartnerAddControlView *acAddView = [self buildAcAddView];
//    [_scrollViewContentArray addObject:acAddView];
    
    MHGatewayAlarmControlView *alarmView = [self buildAlarm];
    [_scrollViewContentArray addObject:alarmView];
    
    MHGatewayFMControlView *fmBgView = [self buildFM];
    [_scrollViewContentArray addObject:fmBgView];
  
}

//警戒
- (MHGatewayAlarmControlView *)buildAlarm {
    if (_alarmView) {
        return _alarmView;
    }
    float alarmRadius = 188 * ScaleHeight;
    CGFloat topSpacing = 5 * ScaleHeight;
    CGRect alarmViewRect = CGRectMake((WIN_WIDTH - alarmRadius) / 2, topSpacing, alarmRadius, alarmRadius);
    MHGatewayAlarmControlView *alarmView = [[MHGatewayAlarmControlView alloc] initWithFrame:alarmViewRect sensor:_acpartner];
    alarmView.padding = 6 * ScaleWidth;
    _alarmView = alarmView;
    return alarmView;
}

//FM
- (MHGatewayFMControlView *)buildFM {
    
    if (_fmView) {
        return _fmView;
    }
    CGRect fmViewRect = CGRectMake(0, 0, WIN_WIDTH, kHeight);
    MHGatewayFMControlView *fmBgView = [[MHGatewayFMControlView alloc] initWithFrame:fmViewRect sensor:_acpartner];
    fmBgView.backgroundColor = [UIColor clearColor];
    [fmBgView addTarget:self action:@selector(goToFmPlayer:) forControlEvents:UIControlEventTouchUpInside];
    _fmView = fmBgView;
    return fmBgView;
}

//添加空调
- (MHACPartnerAddControlView *)buildAcAddView {
    CGRect acAddViewViewRect = CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT * 0.4);
    MHACPartnerAddControlView *acAddView = [[MHACPartnerAddControlView alloc] initWithFrame:acAddViewViewRect sensor:_acpartner];
    XM_WS(weakself);
    [acAddView setAddACClicked:^{
        if (weakself.clickCallBack) {
            weakself.clickCallBack(Acpartner_MainPage_AddAC);
        }
    }];
    [acAddView setAcDetailClicked:^{
        if (weakself.clickCallBack) {
            weakself.clickCallBack(Acpartner_MainPage_ACDetail);
        }
    }];
    [acAddView addTarget:self action:@selector(goToACDetail:) forControlEvents:UIControlEventTouchUpInside];
    return acAddView;
}

//默认布局
- (void)setDefaultContentView {
    
    NSInteger leftIndex = (_currentPageIndex + _totalPageCount - 1) % _totalPageCount;
    NSInteger rightIndex = (_currentPageIndex + 1) % _totalPageCount;
    
    id copyedView;
    if(leftIndex == rightIndex){
        if([_scrollViewContentArray[leftIndex] isKindOfClass:[MHGatewayFMControlView class]]){
            copyedView = [self buildFM];
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
}

#pragma mark - 详情页
- (void)goToFmPlayer:(id)sender {
    if (self.clickCallBack) {
        self.clickCallBack(Acpartner_MainPage_FM);
    }
}

- (void)goToACDetail:(UIControl *)sender {
    
    BOOL hasScan = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@", self.acpartner.did, kHASSCANED]] boolValue];
    if (hasScan) {
        if (self.clickCallBack) {
            self.clickCallBack(Acpartner_MainPage_ACDetail);
        }
    }
    else {
        if (self.clickCallBack) {
            self.clickCallBack(Acpartner_MainPage_AddAC);
        }
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
    
    NSInteger leftIndex = (_currentPageIndex + _totalPageCount - 1) % _totalPageCount;
    NSInteger rightIndex = (_currentPageIndex + 1) % _totalPageCount;
    
    id copyedView;
    if(leftIndex == rightIndex){
        if([_scrollViewContentArray[leftIndex] isKindOfClass:[MHGatewayFMControlView class]]){
            copyedView = [self buildFM];
        }
        else if([_scrollViewContentArray[leftIndex] isKindOfClass:[MHGatewayAlarmControlView class]]){
            copyedView = [self buildAlarm];
        }
    }
    else {
        copyedView = _scrollViewContentArray[rightIndex];
    }
    
    [self resetScrollviewContent:_scrollViewContentArray[leftIndex] inCanvasView:_leftBgView];
    [self resetScrollviewContent:copyedView inCanvasView:_rightBgView];
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
    
}

#pragma mark - 更新控件状态
- (void)updateMainPageStatus {
    //警戒
    if (_mainPageControll.currentPage == 0) {
        if ([_scrollViewContentArray[_mainPageControll.currentPage] isKindOfClass:[MHGatewayAlarmControlView class]]) {
            MHGatewayAlarmControlView *armingView = _scrollViewContentArray[_mainPageControll.currentPage];
            [armingView setupGateway];
        }
    }
    else if (_mainPageControll.currentPage == 1) {
        //fm
        if ([[_scrollViewContentArray lastObject] isKindOfClass:[MHGatewayFMControlView class]]) {
            MHGatewayFMControlView *fm = [_scrollViewContentArray lastObject];
            [fm updateStastus];
        }
    }
//    MHACPartnerAddControlView *addACView = [_scrollViewContentArray firstObject];
//    [addACView updateMainPageStatus];
    
//    [self.acAddView updateMainPageStatus];
    
}



@end
