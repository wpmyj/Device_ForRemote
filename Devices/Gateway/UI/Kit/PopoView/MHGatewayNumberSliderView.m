//
//  MHGatewayNumberSliderView.m
//  MiHome
//
//  Created by guhao on 2/24/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayNumberSliderView.h"

#define kMiniPlayerBtnSize 30.f

@interface MHGatewayNumberSliderView ()

@property (nonatomic, strong) MHLumiPopoverSlider *slider;
@property (nonatomic, strong) UILabel  *titleLabel;
@property (nonatomic, strong) UIButton *minusBtn;
@property (nonatomic, strong) UIButton *plusBtn;
@property (nonatomic, strong) MHGatewayPopupView *popupView;
//@property (nonatomic, strong) MHGatewayPopupView *windowPopupView;

@end
@implementation MHGatewayNumberSliderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self buildSubviews];
    }
    return self;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)dealloc {
//    [self.windowPopupView removeFromSuperview];
//    self.windowPopupView = nil;
}

- (void)updateConstraints {
    
    [self buildConstraints];
    [super updateConstraints];
}

- (void)buildSubviews {
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"你看不见我";
    _titleLabel.hidden = YES;
    _titleLabel.textColor = [MHColorUtils colorWithRGB:0x333333];
    _titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [self addSubview:_titleLabel];
    
    //configure slider
    _slider = [[MHLumiPopoverSlider alloc] init];
    _slider.minimumValue = 0;   //最小值
    _slider.maximumValue = 100;  //最大值
    _slider.continuous = NO;
    [_slider setThumbImage:[UIImage imageNamed:@"gateway_slider_thumb"] forState:UIControlStateNormal];
    [_slider setMaximumTrackTintColor:[MHColorUtils colorWithRGB:0xdfdfdf]];
    [_slider setMinimumTrackTintColor:[MHColorUtils colorWithRGB:0x37b57d]];
    [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_slider];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTapped:)];
    [_slider addGestureRecognizer:tapGestureRecognizer];

    _minusBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_minusBtn setImage:[UIImage imageNamed:@"lumi_fm_plauer_volminus"] forState:UIControlStateNormal];
    _minusBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20.f];
    [_minusBtn setTintColor:[UIColor grayColor]];
    [_minusBtn addTarget:self action:@selector(minusBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_minusBtn];
    
    _plusBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_plusBtn setImage:[UIImage imageNamed:@"lumi_fm_plauer_voladd"] forState:UIControlStateNormal];
    _plusBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20.f];
    [_plusBtn setTintColor:[UIColor grayColor]];
    [_plusBtn addTarget:self action:@selector(plusBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_plusBtn];
    
    _popupView = [[MHGatewayPopupView alloc] initWithFrame:CGRectMake(0, 0, kPopupWidth, kPopupHeight)];
    _popupView.backgroundColor = [UIColor clearColor];
    _popupView.hidden = YES;
    [self addSubview:self.popupView];
}

- (void)buildConstraints {
    XM_WS(weakself);
    CGFloat verticalSpacing = 10;
    CGFloat herizonSpacing = 0;
    CGFloat sliderHeight = 50 * ScaleHeight;
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself).with.offset(herizonSpacing);
        make.top.equalTo(weakself).with.offset(verticalSpacing);
    }];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself);
        make.centerY.mas_equalTo(weakself.mas_centerY).with.offset(10);
        make.height.mas_equalTo(sliderHeight);
        make.left.equalTo(self.minusBtn.mas_right);
        make.right.equalTo(self.plusBtn.mas_left);
    }];
    
    [self.plusBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakself.slider);
        make.right.equalTo(weakself).with.offset(-herizonSpacing);
        make.size.mas_equalTo(CGSizeMake(kMiniPlayerBtnSize, kMiniPlayerBtnSize));
    }];
    
    [self.minusBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakself.slider);
        make.left.equalTo(weakself).with.offset(herizonSpacing);
        make.size.mas_equalTo(CGSizeMake(kMiniPlayerBtnSize, kMiniPlayerBtnSize));
    }];
}

- (void)minusBtnClicked:(UIButton *)sender {
    NSInteger newValue = _slider.value - 10;
    if (newValue <= _slider.minimumValue) newValue = _slider.minimumValue;
    [self fadePopupViewInAndOut:newValue locationX:sender.frame.origin.x locationY:sender.frame.origin.y];
    [_slider setValue:newValue];
    [_slider sendActionsForControlEvents:UIControlEventValueChanged];
    if (_numberControlCallBack) {
        self.numberControlCallBack(newValue, self.type);
    }
}

- (void)plusBtnClicked:(UIButton *)sender {
    NSInteger newValue = _slider.value + 10;
    if (newValue >= 100) newValue = 100;
    [self fadePopupViewInAndOut:newValue locationX:sender.frame.origin.x locationY:sender.frame.origin.y];
    [_slider setValue:newValue];
    [_slider sendActionsForControlEvents:UIControlEventValueChanged];
    if (_numberControlCallBack) {
        self.numberControlCallBack(newValue, self.type);
    }
}

- (void)sliderValueChanged:(id)sender {
    _sliderValue = _slider.value;
    if (self.numberControlCallBack) {
        self.numberControlCallBack(_slider.value, self.type);
    }
}

- (void)sliderTapped:(UIGestureRecognizer *)gestureRecognizer {
    //setValue
    CGPoint location = [gestureRecognizer locationInView:_slider];
    [_slider setValue:location.x / _slider.frame.size.width * 100];
//    [self fadePopupViewInAndOut:_slider.value locationX:location.x + 60];//tap手势的位置有问题,暂时先不加
    [_slider sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)configureConstruct:(NSInteger)value {
    [self setSliderValue:value];
    [_slider setValue:value];
}
#pragma mark - 点击动画
-(void)fadePopupViewInAndOut:(float)newValue locationX:(CGFloat)x locationY:(CGFloat)y {
    __weak MHGatewayPopupView *tempPopup = nil;
    CGRect tempRect = CGRectMake(x - (kPopupWidth - kMiniPlayerBtnSize) / 2, y - kPopupHeight, kPopupWidth, kPopupHeight);
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    //坐标转换
    CGRect windowRect = [_popupView convertRect:tempRect toView:delegate.window];
    for (UIView *obj in delegate.window.subviews) {
        if ([obj isKindOfClass:[MHGatewayPopupView class]]) {
            tempPopup = (MHGatewayPopupView *)obj;
             tempPopup.frame = windowRect;
        }
    }
    tempPopup.value = newValue;

    [UIView animateWithDuration:0.35 animations:^{
        tempPopup.alpha = 1.0f;
    } completion:^(BOOL finished) {
        tempPopup.alpha = 0.0;
    }];
}




#pragma mark - setter
- (void)setType:(NSString *)type {
    _type = type;
    self.titleLabel.text = _type;
    self.titleLabel.hidden = NO;
}

- (void)setMaximumValue:(float)maximumValue {
    _maximumValue = maximumValue;
    _slider.maximumValue = _maximumValue;
}

- (void)setMinimumValue:(float)MinimumValue {
    _MinimumValue = MinimumValue;
    _slider.minimumValue = MinimumValue;
}
- (void)setPlusImageName:(NSString *)plusImageName {
    _plusImageName = plusImageName;
    [_plusBtn setImage:[UIImage imageNamed:plusImageName] forState:UIControlStateNormal];

}

- (void)setMinusImageName:(NSString *)minusImageName {
    _minusImageName = minusImageName;
    [_minusBtn setImage:[UIImage imageNamed:minusImageName] forState:UIControlStateNormal];

}

- (void)setSliderValue:(float)sliderValue {
    _sliderValue = sliderValue;
    [_slider setValue:sliderValue];
}

- (void)setTitleColor:(UIColor *)titleColor {
    [_titleLabel setTextColor:titleColor];
}

- (void)setTitleFont:(UIFont *)titleFont {
    [_titleLabel setFont:titleFont];
}
@end
