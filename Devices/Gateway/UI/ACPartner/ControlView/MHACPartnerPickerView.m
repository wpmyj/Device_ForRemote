//
//  MHACPartnerPickerView.m
//  MiHome
//
//  Created by ayanami on 16/5/19.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerPickerView.h"
#import "MHACPartnerDetailViewController.h"

#define kLineHeight (106.0f)

@implementation MHACPartnerPickerView
{
    UIView *_contentView;
    MHACPartnerDetailViewController *_controlView;
    UIPanGestureRecognizer *_pan;
    UIScrollView *_scrollView;
    NSMutableArray *_labels;
    BOOL _isReleasing;
    int _pages;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _isReleasing = NO;
        _isTracking = NO;
        [self buildSubViews];
    }
    return self;
}

- (void)dealloc
{
    [_pan removeObserver:self forKeyPath:@"state"];
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return [self pointInside:point withEvent:event] ? _scrollView : nil;
}

- (void)setTempMin:(float)minTemp max:(float)maxTemp step:(float)step {
    self.minTemp = minTemp;
    self.maxTemp = maxTemp;
    self.stepTemp = step;
    [self fillPicker];
    [self hideProcess];
}

- (void)fillWithDevice:(MHDeviceAcpartner *)device
{
    self.device = device;
    if (_isBlinking)
    {
        return;
    }
    
    [self setDisable:YES];
    
//    [_controlView fillWithDevice:device];
}

- (void)setPickerTemp:(float)temp
{
    if (temp < self.minTemp)
    {
        temp = self.minTemp;
    }
    else if (temp > self.maxTemp)
    {
        temp = self.maxTemp;
    }
    
    temp -= self.minTemp;
    
    CGFloat height  = kLineHeight;
    NSInteger offsetY = height * temp / self.stepTemp;
    [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x, offsetY) animated:NO];
}

- (void)setControlTemp:(NSInteger)temp
{
    
}

- (void)buildSubViews
{
    self.clipsToBounds = YES;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, kLineHeight)];
    _scrollView.delegate = self;
    [_scrollView setCenter:CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 2.0f)];
    [self addSubview:_scrollView];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    [_scrollView setClipsToBounds:NO];
    _pan = [[UIPanGestureRecognizer alloc] init];
    _pan.delegate = self;
    [self addGestureRecognizer:
     _pan];
    [_pan addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
    [self fillPicker];
    [self hideProcess];
    [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
//    _controlView = [[MHAirConMainControlView alloc] initWithFrame:CGRectMake(0, 0, 230, 251)];
//    _controlView.picker = self;
//    [_controlView setUserInteractionEnabled:NO];
//    [_controlView setCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 - 2.5f)];
//    [self addSubview:_controlView];
}

- (void)fillPicker
{
    [_contentView removeFromSuperview];
    NSLog(@"%f, %f, %f", self.maxTemp, self.minTemp, self.stepTemp);
    //    _labels = [NSMutableArray arrayWithCapacity:((self.maxTemp - self.minTemp) / self.stepTemp + 1)];
    _labels = [NSMutableArray new];
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [_scrollView addSubview:_contentView];
    
    float maxY = 0;
    
    UIFont *font = [UIFont fontWithName:@"DINOffc-CondMedi" size:95.0f];
    for (float i = 0; i< (self.maxTemp - self.minTemp) + self.stepTemp; i+=self.stepTemp)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, (i/self.stepTemp) *  kLineHeight, self.frame.size.width, kLineHeight)];
        [label setFont:font];
        [label setTextColor:[UIColor whiteColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [_contentView addSubview:label];
        [label setText:[NSString stringWithFormat:@"%.0f", self.minTemp + i]];
        maxY = CGRectGetMaxY(label.frame);
        [_labels addObject:label];
    }
    
    [_contentView setFrame:CGRectMake(0, 0, self.frame.size.width, maxY)];
    [_scrollView setContentSize:CGSizeMake(self.frame.size.width, _contentView.frame.size.height)];
    [self adjustLabels];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_contentView setCenter:CGPointMake(self.frame.size.width / 2, _contentView.center.y)];
}

- (void)show
{
    _contentView.alpha = 1.0f;
}

- (void)hideProcess
{
    _contentView.alpha = 0.0f;
}

- (void)onPress
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _isReleasing = NO;
    
    if (_isTracking)
    {
        return;
    }
    
    _isTracking = YES;
    
    if (self.actionCallback)
    {
        self.actionCallback(MHACPartnerPickerActionPress);
    }
//    [self setPickerTemp:[_controlView currentTemp]];
//    [_controlView hide];
    [self show];
}

- (void)onRelease
{
    CGFloat offsetY = _scrollView.contentOffset.y;
    CGFloat height  = kLineHeight;
    NSInteger page = offsetY / height;
    if (offsetY - (height * page) > (height / 2.0)) {
        page += 1;
    }
    self.temperature = self.minTemp + page * self.stepTemp;
    if (!_isReleasing)
    {
        _isReleasing = YES;
        [self performSelector:@selector(startHideProcess) withObject:nil afterDelay:0.5f];
    }
}

- (void)startHideProcess
{
    //    [self.device setTemperature:self.temperature success:^(id obj) {
    //        if (self.actionCallback)
    //        {
    //            self.actionCallback(MHAirConPickerActionRelease);
    //        }
    //    } failure:^(NSError *v) {
    //        if (self.actionCallback)
    //        {
    //            self.actionCallback(MHAirConPickerActionRelease);
    //        }
    //    }];
    
    if (self.actionCallback)
    {
        self.actionCallback(MHACPartnerPickerActionRelease);
    }
    
}

- (void)hide
{
//    [_controlView show];
    [self hideProcess];
    __typeof(self) __weak weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __typeof(self) __strong strongSelf = weakSelf;
        if (strongSelf)
        {
            strongSelf -> _isTracking = NO;
        }
    });
}

- (void)startBlinking
{
    [self setDisable:YES];
//    [_controlView startBlinking:YES];
    _isBlinking = YES;
}

- (void)stopBlinking
{
    [self setDisable:NO];
//    [_controlView stopBlinking];
    _isBlinking = NO;
}

- (void)setDisable:(BOOL)disable
{
    [self setUserInteractionEnabled:!disable];
    [_scrollView setUserInteractionEnabled:!disable];
    [_scrollView setScrollEnabled:!disable];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (!self.userInteractionEnabled)
    {
        return NO;
    }
    if (gestureRecognizer == _pan)
    {
        [self onPress];
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"state"])
    {
        UIGestureRecognizerState state = (UIGestureRecognizerState)[change[@"new"] integerValue];
        if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateFailed || state == UIGestureRecognizerStateCancelled)
        {
            if (!_scrollView.isDecelerating)
            {
                [self onRelease];
            }
        }
    }
    
    if ([object isKindOfClass:[UIScrollView class]] && [keyPath isEqualToString:@"contentOffset"])
    {
        [self adjustLabels];
    }
}

- (void)adjustLabels
{
    NSInteger page = [self currentPage];
    if (page >= [_labels count] || page < 0)
    {
        return;
    }
    [_labels[page] setAlpha:1.0f];
    [(UILabel *)_labels[page] setTransform:CGAffineTransformIdentity];
    NSInteger i = page;
    float distance = [(UILabel *)_labels[page] center].y - _scrollView.contentOffset.y - (_scrollView.frame.size.height / 2);
    [(UILabel *)_labels[page] setTransform:CGAffineTransformMakeScale( 1 - (fabs(distance) / 218.0f) * 0.3, 1 - (fabs(distance) / 218.0f) * 0.3)];
    
    while (i - 1 >= 0)
    {
        i--;
        float distanceI = [(UILabel *)_labels[i] center].y - _scrollView.contentOffset.y - (_scrollView.frame.size.height / 2);
        [_labels[i] setAlpha:(1- (page - i) * ([UIScreen mainScreen].bounds.size.height > 600 ? 0.4 : 0.5f))];
        [(UILabel *)_labels[i] setTransform:CGAffineTransformMakeScale( 1 - (fabs(distanceI) / 218.0f) * 0.5, 1 - (fabs(distanceI) / 218.0f) * 0.5)];
    }
    i = page;
    while (i + 1 < ([_labels count]))
    {
        i++;
        float distanceI = [(UILabel *)_labels[i] center].y - _scrollView.contentOffset.y - (_scrollView.frame.size.height / 2);
        [_labels[i] setAlpha:(1 - (i-page) * 0.4f)];
        [(UILabel *)_labels[i] setTransform:CGAffineTransformMakeScale( 1 - (fabs(distanceI) / 218.0f) * 0.5, 1 - (fabs(distanceI) / 218.0f) * 0.5)];
    }
    
}

- (NSInteger)currentPage
{
    CGFloat offsetY = _scrollView.contentOffset.y;
    CGFloat height  = kLineHeight;
    NSInteger page = offsetY / height;
    if (offsetY - (height * page) > (height / 2.0)) {
        page += 1;
    }
    return page;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat height  = kLineHeight;
    NSInteger page = offsetY / height;
    if (offsetY - (height * page) > (height / 2.0)) {
        page += 1;
    }
    offsetY = page * height;
    [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, offsetY) animated:YES];
    [self onRelease];
}

@end
