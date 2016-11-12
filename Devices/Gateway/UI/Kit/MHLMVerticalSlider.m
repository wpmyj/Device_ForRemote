//
//  MHLMVerticalSlider.m
//  MiHome
//
//  Created by ayanami on 16/7/21.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLMVerticalSlider.h"

@interface MHLMVerticalSlider ()

@property (nonatomic, assign) BOOL isIndicatorTouched;
@property (nonatomic, assign) CGFloat indicatorOffset;

@property (nonatomic, strong) UIImageView *thumbImageView;
@property (nonatomic, strong) UIImageView *popImageView;
@property (nonatomic, strong) UIButton *popBtn;

@property (nonatomic, strong) UIImage *thumbImage;
@property (nonatomic, strong) UIImage *popImage;
@property (nonatomic, strong) UILabel *popLabel;

@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *maxlineView;
@property (nonatomic, strong) UIView *minlineView;

@property (nonatomic, copy) sliderCallback valueCallBack;

@property (nonatomic, assign) CGFloat trendValue;
@property (nonatomic, assign) CGFloat canSliderLength;


@end

@implementation MHLMVerticalSlider
- (id)initWithFrame:(CGRect)frame thumbImage:(UIImage *)thumb popImage:(UIImage *)image handle:(sliderCallback)handle
{
    self = [super initWithFrame:frame];
    if (self) {
        self.valueCallBack = handle;
        self.thumbImage = thumb;
        self.popImage = image;
        self.minimumValue = 0;
        self.maximumValue = 100;
        
        [self buildSubviews];
        [self buildConstraints];

    }
    return self;
}


- (void)buildSubviews {
//    XM_WS(weakself);

//    self.bounds = CGRectMake(0, 0, 37, 200);
//    self.canSliderLength = 200 - 37;

    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = [MHColorUtils colorWithRGB:0x888888 alpha:0.3];
    [self addSubview:self.lineView];
   
    
    self.maxlineView = [[UIView alloc] init];
    self.maxlineView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.maxlineView];
    
    
    self.minlineView = [[UIView alloc] init];
    self.minlineView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.minlineView];
    
    
    _popBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_popBtn setImage:self.popImage forState:UIControlStateNormal];
    [_popBtn setTitleColor:[MHColorUtils colorWithRGB:0x888888] forState:UIControlStateNormal];
    [self.popBtn setTitle:@"22" forState:UIControlStateNormal];
    [self addSubview:_popBtn];
    _popBtn.alpha = 0.0;

    self.popLabel = [[UILabel alloc] init];
    self.popLabel.textAlignment = NSTextAlignmentCenter;
    self.popLabel.textColor = [MHColorUtils colorWithRGB:0x888888];
    self.popLabel.font = [UIFont systemFontOfSize:18.0f];
    self.popLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.popLabel];
    self.popLabel.alpha = 0;

    
    
    self.thumbImageView = [[UIImageView alloc] initWithImage:self.thumbImage];
    self.thumbImageView.userInteractionEnabled = YES;
    [self addSubview:self.thumbImageView];
    
//    self.popImageView = [[UIImageView alloc] initWithImage:self.popImage];
//    self.popImageView.userInteractionEnabled = YES;
//    [self addSubview:self.popImageView];
   
    
}

- (void)buildConstraints {
    XM_WS(weakself);
    
    self.thumbImageView.frame = CGRectMake((self.bounds.size.width - self.thumbImage.size.width) / 2, 0, self.thumbImage.size.width, self.thumbImage.size.height);
    NSLog(@"%@", self);
    
    self.popBtn.frame = CGRectMake((self.bounds.size.width - self.popImage.size.width) / 2, 0, self.popImage.size.width, self.popImage.size.height);
    
    self.popLabel.frame = CGRectMake(0, 0, 40, 40);
    self.popLabel.center = self.popBtn.center;
    
    self.canSliderLength = self.bounds.size.height - self.thumbImage.size.height;
    
    //97 157
    NSLog(@"%@", self.popImage);
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.mas_top).offset(5);
        make.centerX.equalTo(weakself);
        make.size.mas_equalTo(CGSizeMake(2, weakself.bounds.size.height - 10));
    }];
    
    
    
}


#pragma mark -setter
- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor {
    _maxlineView.backgroundColor = maximumTrackTintColor;
}


- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor {
    _minlineView.backgroundColor = minimumTrackTintColor;

}

- (void)setMinimumValue:(float)minimumValue {
    _minimumValue = minimumValue;
    _trendValue = _maximumValue - _minimumValue;
}

- (void)setMaximumValue:(float)maximumValue {
    _maximumValue = maximumValue;
    _trendValue = _maximumValue - _minimumValue;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchCoord = [touch locationInView:self];
    
    if (CGRectContainsPoint(self.thumbImageView.frame, touchCoord)) {
        self.isIndicatorTouched = YES;
//        CGPoint touchCoordInIndicator = [touch locationInView:self.thumbImageView];
//                  self.indicatorOffset = touchCoordInIndicator.y;
        [self fadePopupViewInAndOut:YES];
        
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.isIndicatorTouched = NO;
    [self fadePopupViewInAndOut:NO];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGFloat imageY = self.thumbImageView.frame.origin.y;
    if (self.isIndicatorTouched && imageY >= 0 && imageY <= self.canSliderLength) {
        UITouch *touch = [touches anyObject];
        CGPoint touchCoord = [touch locationInView:self];
        
        CGFloat currentY = touchCoord.y;
        touchCoord.y = MIN(touchCoord.y, self.canSliderLength);
        touchCoord.y = MAX(touchCoord.y, 0);
        NSLog(@"当前的y值%0.f", currentY);
        CGFloat currentValue = (self.canSliderLength - touchCoord.y) * (self.trendValue) / self.canSliderLength + self.minimumValue;
        NSLog(@"当前的value值%0.f", currentValue);

        [self setSliderValue:currentValue animated:NO];

        [self fadePopupViewInAndOut:YES];
    }
    
    UIImage *test = [UIImage imageNamed:@"acpartner_custom_sliderthumb"];
    NSLog(@"%lf, %lf", test.size.height,test.size.width);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    if (self.isIndicatorTouched) {
//        UITouch *touch = [touches anyObject];
//        CGPoint touchCoord = [touch locationInView:self];
//        
//                  CGFloat trueHeight = self.frame.size.height - self.thumbImageView.frame.size.height;
//            touchCoord.y = MIN(touchCoord.y, trueHeight);
//                    CGFloat sliderY = touchCoord.y;
//        touchCoord.y = MIN(sliderY, self.canSliderLength);
//        touchCoord.y = MAX(sliderY, 0);
//        CGFloat lastValue = (self.canSliderLength - sliderY)  * self.trendValue / self.canSliderLength + self.minimumValue;
//        [self setSliderValue:lastValue animated:YES];
//    }
    [self fadePopupViewInAndOut:NO];
    self.isIndicatorTouched = NO;
}

- (void)setSliderValue:(CGFloat)value animated:(BOOL)animated {
    XM_WS(weakself);
    _value = value;
   
    
    CGRect newFrame = self.thumbImageView.frame;
    NSLog(@"温度%.0f", value);
    CGFloat tempValue = 0;
    if (value >= self.trendValue) {
        tempValue = value - self.minimumValue;
    }
   CGFloat newY  = (self.trendValue - tempValue) * self.canSliderLength / self.trendValue;
    newY = MIN(newY, self.canSliderLength);
    newY = MAX(newY, 0);
    newFrame.origin.y = newY;
    
    CGRect newPopFrame = self.popBtn.frame;
    newPopFrame.origin.y = newY + self.thumbImage.size.height - self.popImage.size.height - self.popImage.size.height / 3;
    self.popBtn.frame = newPopFrame;
    NSString *strTitle = [NSString stringWithFormat:@"%.0f", value];
    CGPoint newPopCenter = self.popBtn.center;
    newPopCenter.y = newPopCenter.y - 15;
    self.popLabel.center = newPopCenter;
    self.popLabel.text = strTitle;
    
    if (animated) {
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.thumbImageView.frame = newFrame;
                         } completion:^(BOOL finished) {
                             if (weakself.valueCallBack) {
                                 weakself.valueCallBack(value, weakself.thumbImageView.center);
                             }

                         }];
    } else {
        self.thumbImageView.frame = newFrame;
        if (self.valueCallBack) {
            self.valueCallBack(value, weakself.thumbImageView.center);
        }
    }
    

}

-(void)fadePopupViewInAndOut:(BOOL)animated {
    XM_WS(weakself);
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            weakself.popBtn.alpha = 1.0;
            weakself.popLabel.alpha = 1.0;
        }];
    } else {
        weakself.popBtn.alpha = 0.0;
        weakself.popLabel.alpha = 0.0;
    }
}

@end
