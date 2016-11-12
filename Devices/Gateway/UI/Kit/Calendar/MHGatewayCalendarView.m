//
//  MHGatewayCalendarView.m
//  MiHome
//
//  Created by guhao on 16/5/17.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayCalendarView.h"
#import "MHGatewayCalendarItemView.h"


#define kSun NSLocalizedStringFromTable(@"ifttt.scene.local.scene.log.title.calendar.sun", @"plugin_gateway", "日")
#define kMon NSLocalizedStringFromTable(@"ifttt.scene.local.scene.log.title.calendar.mon", @"plugin_gateway", "一")
#define kTue NSLocalizedStringFromTable(@"ifttt.scene.local.scene.log.title.calendar.tue", @"plugin_gateway", "二")
#define kWed NSLocalizedStringFromTable(@"ifttt.scene.local.scene.log.title.calendar.wed", @"plugin_gateway", "三")
#define kThu NSLocalizedStringFromTable(@"ifttt.scene.local.scene.log.title.calendar.thu", @"plugin_gateway", "四")
#define kFri NSLocalizedStringFromTable(@"ifttt.scene.local.scene.log.title.calendar.fri", @"plugin_gateway", "五")
#define kSat NSLocalizedStringFromTable(@"ifttt.scene.local.scene.log.title.calendar.sat", @"plugin_gateway", "六")
static NSArray *WeekdaysArray = nil;

static NSDateFormatter *dateFormattor;
static CGFloat headerBarHeight = 75;


@interface MHGatewayCalendarView () <UIScrollViewDelegate, MHGatewayCalendarItemViewDelegate>

@property (strong, nonatomic) NSDate *date;

@property (strong, nonatomic) UIButton *titleButton;
@property (strong, nonatomic) UIView *maskView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) MHGatewayCalendarItemView *leftCalendarItem;
@property (strong, nonatomic) MHGatewayCalendarItemView *centerCalendarItem;
@property (strong, nonatomic) MHGatewayCalendarItemView *rightCalendarItem;
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIView *datePickerView;
@property (strong, nonatomic) UIDatePicker *datePicker;


@end

@implementation MHGatewayCalendarView


- (instancetype)initWithCurrentDate:(NSDate *)date {
    if (self = [super init]) {
        WeekdaysArray = @[ kSun, kMon, kTue, kWed, kThu, kFri, kSat ];
        self.date = date;        
        [self setupCalendarItems];
        [self setupScrollView];
        [self setupWeekHeader];
        [self setupTitleBar];
//        [self setFrame:CGRectMake(0, 0, WIN_WIDTH, CGRectGetMaxY(self.scrollView.frame))];
        [self setFrame:CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT)];
        
        self.backgroundColor = [MHColorUtils colorWithRGB:0x000000 alpha:0.3];
        [self setCurrentDate:self.date];
    }
    return self;
}

#pragma mark - Custom Accessors

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame: self.bounds];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 0;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDatePickerView)];
        [_backgroundView addGestureRecognizer:tapGesture];
    }
    
    [self addSubview:_backgroundView];
    
    return _backgroundView;
}

- (UIView *)datePickerView {
    if (!_datePickerView) {
        _datePickerView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.frame.size.width, 0)];
        _datePickerView.backgroundColor = [UIColor whiteColor];
        _datePickerView.clipsToBounds = YES;
        
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 10, 32, 20)];
        cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelSelectCurrentDate) forControlEvents:UIControlEventTouchUpInside];
        [_datePickerView addSubview:cancelButton];
        
        UIButton *okButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 52, 10, 32, 20)];
        okButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [okButton setTitle:@"确定" forState:UIControlStateNormal];
        [okButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [okButton addTarget:self action:@selector(selectCurrentDate) forControlEvents:UIControlEventTouchUpInside];
        [_datePickerView addSubview:okButton];
        
        [_datePickerView addSubview:self.datePicker];
    }
    
    [self addSubview:_datePickerView];
    
    return _datePickerView;
}

- (UIDatePicker *)datePicker {
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        _datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"Chinese"];
        CGRect frame = _datePicker.frame;
        frame.origin = CGPointMake(0, 32);
        _datePicker.frame = frame;
    }
    
    return _datePicker;
}

#pragma mark - Private
- (NSString *)stringFromDate:(NSDate *)date {
    if (!dateFormattor) {
        dateFormattor = [[NSDateFormatter alloc] init];
        [dateFormattor setDateFormat:@"MM-yyyy"];
    }
    return [dateFormattor stringFromDate:date];
}

// 设置上层的titleBar
- (void)setupTitleBar {
    UIView *weekdayBar = [[UIView alloc] initWithFrame:CGRectMake(0, WIN_HEIGHT - kITEMHEIGHT - headerBarHeight, WIN_WIDTH, 44)];
    weekdayBar.backgroundColor = [UIColor whiteColor];
    
    
    self.titleButton = [[UIButton alloc] initWithFrame:CGRectMake((WIN_WIDTH - 100) / 2, 0, 100, 44)];
    [self.titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

//    self.titleButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.titleButton addTarget:self action:@selector(showDatePicker) forControlEvents:UIControlEventTouchUpInside];
    [weekdayBar addSubview:self.titleButton];
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(self.titleButton.frame.origin.x - 30, 15, 20, 10)];
    [leftButton setImage:[UIImage imageNamed:@"lumi_scene_log_leftarrow"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(setPreviousMonthDate) forControlEvents:UIControlEventTouchUpInside];
    [weekdayBar addSubview:leftButton];
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(self.titleButton.frame.origin.x + 110, 15, 20, 10)];
    [rightButton setImage:[UIImage imageNamed:@"lumi_scene_log_rightarrow"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(setNextMonthDate) forControlEvents:UIControlEventTouchUpInside];
    [weekdayBar addSubview:rightButton];
    
    [self addSubview:weekdayBar];

}

// 设置星期文字的显示
- (void)setupWeekHeader {
    NSInteger count = [WeekdaysArray count];
    CGFloat offsetX = 5;
    for (int i = 0; i < count; i++) {
        UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, WIN_HEIGHT - kITEMHEIGHT - 24, (WIN_WIDTH - 10) / count, 20)];
        weekdayLabel.textAlignment = NSTextAlignmentCenter;
        weekdayLabel.text = WeekdaysArray[i];
        
        if (i == 0 || i == count - 1) {
            weekdayLabel.textColor = [UIColor redColor];
        } else {
            weekdayLabel.textColor = [UIColor grayColor];
        }
        
        [self addSubview:weekdayLabel];
        offsetX += weekdayLabel.frame.size.width;
    }
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(15, WIN_HEIGHT - kITEMHEIGHT - 2, WIN_WIDTH - 30, 1)];
    lineView.backgroundColor = [MHColorUtils colorWithRGB:0xffffff alpha:0.3];
    [self addSubview:lineView];
}

// 设置包含日历的item的scrollView
- (void)setupScrollView {
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
//    [self.scrollView setFrame:CGRectMake(0, 75, WIN_WIDTH, self.centerCalendarItem.frame.size.height)];
    [self.scrollView setFrame:CGRectMake(0, WIN_HEIGHT - kITEMHEIGHT - headerBarHeight, WIN_WIDTH, kITEMHEIGHT + headerBarHeight)];
    self.scrollView.contentSize = CGSizeMake(3 * WIN_WIDTH, kITEMHEIGHT);
    self.scrollView.contentOffset = CGPointMake(WIN_WIDTH, 0);
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.scrollView];
    
    
    self.maskView = [[UIView alloc] init];
    self.maskView.backgroundColor = [MHColorUtils colorWithRGB:0x000000 alpha:0.3];
//    self.maskView.frame = CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT - self.scrollView.frame.size.height);
        self.maskView.frame = CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT - kITEMHEIGHT - 75);

    UIGestureRecognizer *tapBgViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeView:)];
    [self.maskView addGestureRecognizer:tapBgViewGesture];
    [self addSubview:self.maskView];
}

// 设置3个日历的item
- (void)setupCalendarItems {
    self.scrollView = [[UIScrollView alloc] init];
    
    self.leftCalendarItem = [[MHGatewayCalendarItemView alloc] init];
    [self.scrollView addSubview:self.leftCalendarItem];
    
    CGRect itemFrame = self.leftCalendarItem.frame;
    itemFrame.origin.x = WIN_WIDTH;
    self.centerCalendarItem = [[MHGatewayCalendarItemView alloc] init];
    self.centerCalendarItem.frame = itemFrame;
    self.centerCalendarItem.delegate = self;
    [self.scrollView addSubview:self.centerCalendarItem];
    
    itemFrame.origin.x = WIN_WIDTH * 2;
    self.rightCalendarItem = [[MHGatewayCalendarItemView alloc] init];
    self.rightCalendarItem.frame = itemFrame;
    [self.scrollView addSubview:self.rightCalendarItem];
}

// 设置当前日期，初始化
- (void)setCurrentDate:(NSDate *)date {
    self.centerCalendarItem.date = date;
    self.leftCalendarItem.date = [self.centerCalendarItem previousMonthDate];
    self.rightCalendarItem.date = [self.centerCalendarItem nextMonthDate];
    
    [self.titleButton setTitle:[self stringFromDate:self.centerCalendarItem.date] forState:UIControlStateNormal];
}

// 重新加载日历items的数据
- (void)reloadCalendarItems {
    CGPoint offset = self.scrollView.contentOffset;
    
    if (offset.x > self.scrollView.frame.size.width) {
        [self setNextMonthDate];
    } else {
        [self setPreviousMonthDate];
    }
}

- (void)showDatePickerView {
//    [UIView animateWithDuration:0.25 animations:^{
//        self.backgroundView.alpha = 0.4;
//        self.datePickerView.frame = CGRectMake(0, 44, self.frame.size.width, 250);
//    }];
}

- (void)hideDatePickerView {
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundView.alpha = 0;
        self.datePickerView.frame = CGRectMake(0, 44, self.frame.size.width, 0);
    } completion:^(BOOL finished) {
        [self.backgroundView removeFromSuperview];
        [self.datePickerView removeFromSuperview];
    }];
}

#pragma mark - SEL

// 跳到上一个月
- (void)setPreviousMonthDate {
    [self setCurrentDate:[self.centerCalendarItem previousMonthDate]];
}

// 跳到下一个月
- (void)setNextMonthDate {
    [self setCurrentDate:[self.centerCalendarItem nextMonthDate]];
}

- (void)showDatePicker {
    [self showDatePickerView];
}

// 选择当前日期
- (void)selectCurrentDate {
    [self setCurrentDate:self.datePicker.date];
    [self hideDatePickerView];
}

- (void)cancelSelectCurrentDate {
    [self hideDatePickerView];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self reloadCalendarItems];
    self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
}

#pragma mark - MHGatewayCalendarItemViewDelegate
- (void)calendarItem:(MHGatewayCalendarItemView *)item didSelectedDate:(NSDate *)date {
    self.date = date;
    [self setCurrentDate:self.date];
    [self hideView];
    if (self.selectDateCallBack) {
        self.selectDateCallBack(date);
    }
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
