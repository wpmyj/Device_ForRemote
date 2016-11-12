//
//  MHGatewayHumitureRefreshView.m
//  MiHome
//
//  Created by guhao on 16/1/5.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayHumitureRefreshView.h"

#define TEXT_COLOR	 [UIColor whiteColor]
#define FLIP_ANIMATION_DURATION 0.18f

#define DEFAULT_REFRESH_TRIGGER_VALUE  30.0f


@interface MHGatewayHumitureRefreshView (Private)
- (void)setState:(EGOPullRefreshState)aState;
@end
@implementation MHGatewayHumitureRefreshView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.refreshTriggerValue = DEFAULT_REFRESH_TRIGGER_VALUE;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
        label.font = [UIFont systemFontOfSize:12.0f];
        label.textColor = TEXT_COLOR;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        _lastUpdatedLabel=label;
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height + 12, self.frame.size.width, 20.0f)];
        label.font = [UIFont boldSystemFontOfSize:13.0f];
        label.textColor = TEXT_COLOR;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        _statusLabel=label;
        
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(25.0f, frame.size.height - 65.0f, 30.0f, 55.0f);
        layer.contentsGravity = kCAGravityResizeAspect;
        layer.contents = nil;//(id)[UIImage imageNamed:@"blueArrow.png"].CGImage;
        
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            layer.contentsScale = [[UIScreen mainScreen] scale];
        }
        
        [[self layer] addSublayer:layer];
        _arrowImage=layer;
        
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        view.frame = CGRectMake(self.frame.size.width / 2 - 50.0f, frame.size.height + 12, 20.0f, 20.0f);
        [self addSubview:view];
        _activityView = view;
        
        [self setState:EGOOPullRefreshNormal];
        
    }
    
    return self;
    
}

- (instancetype)initByUseAutoLayout
{
    self = [super init];
    if (self) {
        self.refreshTriggerValue = DEFAULT_REFRESH_TRIGGER_VALUE;
        [self buildSubviews];
        [self buildConstraints];
        [self setState:EGOOPullRefreshNormal];
    }
    return self;
}

- (void)buildSubviews
{
    self.backgroundColor = [UIColor clearColor];
    
    UILabel* label = [[UILabel alloc] init];//WithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.font = [UIFont boldSystemFontOfSize:13.0f];
    label.textColor = TEXT_COLOR;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    _statusLabel=label;
    
    UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:view];
    _activityView = view;
}

- (void)buildConstraints
{
    NSLayoutConstraint* labelCenter = [NSLayoutConstraint constraintWithItem:_statusLabel
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1.f constant:0.f];
    NSLayoutConstraint* labelTop = [NSLayoutConstraint constraintWithItem:_statusLabel
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1.f constant:12.0f];
    [self addConstraint:labelCenter];
    [self addConstraint:labelTop];
    
    NSLayoutConstraint* activityRight = [NSLayoutConstraint constraintWithItem:_activityView
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_statusLabel
                                                                     attribute:NSLayoutAttributeLeading
                                                                    multiplier:1.f constant:-10.f];
    NSLayoutConstraint* activityCenterY = [NSLayoutConstraint constraintWithItem:_activityView
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:_statusLabel
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1.f constant:0.f];
    [self addConstraint:activityRight];
    [self addConstraint:activityCenterY];
}

#pragma mark -
#pragma mark Setters

- (void)refreshLastUpdatedDate {
    
    if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceLastUpdated:)]) {
        
        NSDate *date = [_delegate egoRefreshTableHeaderDataSourceLastUpdated:self];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setAMSymbol:@"AM"];
        [formatter setPMSymbol:@"PM"];
        [formatter setDateFormat:@"MM/dd/yyyy hh:mm:a"];
        _lastUpdatedLabel.text = [NSString stringWithFormat:@"Last Updated: %@", [formatter stringFromDate:date]];
        [[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    } else {
        
        _lastUpdatedLabel.text = nil;
        
    }
    
}

- (void)setState:(EGOPullRefreshState)aState{
    
    switch (aState) {
        case EGOOPullRefreshPulling:
            _statusLabel.hidden = NO;
            _statusLabel.text = @"松开刷新";
            [CATransaction begin];
            [CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
            _arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
            [CATransaction commit];
            
            break;
        case EGOOPullRefreshNormal:
            
            if (_state == EGOOPullRefreshPulling) {
                [CATransaction begin];
                [CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
                _arrowImage.transform = CATransform3DIdentity;
                [CATransaction commit];
            }
            _statusLabel.text = @"下拉刷新";
            [_activityView stopAnimating];
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            _arrowImage.hidden = NO;
            _arrowImage.transform = CATransform3DIdentity;
            [CATransaction commit];
            
            [self refreshLastUpdatedDate];
            _statusLabel.hidden = YES;
            break;
        case EGOOPullRefreshLoading:
            _statusLabel.hidden = NO;
            _statusLabel.text = @"载入中...";
            [_activityView startAnimating];
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            _arrowImage.hidden = YES;
            [CATransaction commit];
            
            break;
        default:
            break;
    }
    
    _state = aState;
}


#pragma mark ScrollView Methods

- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (_state == EGOOPullRefreshLoading) {
        //        [UIView beginAnimations:nil context:NULL];
        //        [UIView setAnimationDuration:0.2];
        //        scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
        //        [UIView commitAnimations];
        
        //		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
        //		offset = MIN(offset, 60);
        //		scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
        
    } else if (scrollView.isDragging) {
        
        BOOL _loading = NO;
        if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
            _loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
        }
        
        if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -self.refreshTriggerValue && scrollView.contentOffset.y < 0.0f && !_loading) {
            [self setState:EGOOPullRefreshNormal];
        } else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -self.refreshTriggerValue && !_loading) {
            [self setState:EGOOPullRefreshPulling];
        }
        
        if (scrollView.contentInset.top != 0) {
            scrollView.contentInset = UIEdgeInsetsZero;
        }
        
    }
    
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
    
    BOOL _loading = NO;
    if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
        _loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
    }
    if (scrollView.contentOffset.y <= - self.refreshTriggerValue && !_loading) {
        
        if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
            [_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
        }
        
        [self setState:EGOOPullRefreshLoading];
        
        [scrollView setContentInset:UIEdgeInsetsMake(-scrollView.contentOffset.y, 0.0f, 0.0f, 0.0f)];
        
        [UIView animateWithDuration:0.2f animations:^{
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3f animations:^{
                [scrollView setContentInset:UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f)];
            } completion:^(BOOL finished) {
                CGSize size = scrollView.contentSize;
                size.height -= 60.0f;
                scrollView.contentSize = size;
            }];
        }];
    }
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {	
    
    CGSize size = scrollView.contentSize;
    size.height += 60.0f;
    [scrollView setContentSize:size];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    [scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [UIView commitAnimations];
    
    [self setState:EGOOPullRefreshNormal];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
