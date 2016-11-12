//
//  MHACPartnerQuantView.m
//  MiHome
//
//  Created by ayanami on 16/5/21.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerQuantView.h"

#define LabelWhiteTextColor [UIColor whiteColor]


@interface MHACPartnerQuantView ()
//用电与功率
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIButton *todayBtn;
@property (nonatomic, strong) UIButton *monthBtn;
@property (nonatomic, strong) UIButton *quantBtn;
@property (nonatomic, strong) UILabel *todayCountTail;
@property (nonatomic, strong) UILabel *monthCountTail;
@property (nonatomic, strong) UILabel *currentWatTail;
@property (nonatomic, strong) UILabel *todayCountTitle;
@property (nonatomic, strong) UILabel *monthCountTitle;
@property (nonatomic, strong) UILabel *currentWatTitle;
@property (nonatomic, strong) UILabel *todayCountNum;
@property (nonatomic, strong) UILabel *monthCountNum;
@property (nonatomic, strong) UILabel *currentWatNum;
@end

@implementation MHACPartnerQuantView

//- (id)initWithACPartner:(MHDeviceAcpartner *)acpartner
//{
//    self = [super init];
//    if (self) {
//        [self buildSubviews];
//        [self buildConstraints];
//    }
//    return self;
//}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self buildSubviews];
        [self buildConstraints];
    }
    return self;
}


- (void)buildSubviews {
    // to be implemented in subclass
    
    //功率
    _headerView = [[UIView alloc] init];
    _headerView.backgroundColor = [UIColor clearColor];
    [self addSubview:_headerView];
  
    _todayCountTitle = [[UILabel alloc] init];
    _todayCountTitle.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.quant.today", @"plugin_gateway", @"今日");
    _todayCountTitle.font = [UIFont systemFontOfSize:14.f];
    [_todayCountTitle setTextColor:LabelWhiteTextColor];
    [_todayCountTitle setTextAlignment:NSTextAlignmentCenter];
//    [_headerView addSubview:_todayCountTitle];
        [self addSubview:_todayCountTitle];

    _todayCountNum = [[UILabel alloc] init];
    _todayCountNum.font = [UIFont systemFontOfSize:22.f * ScaleWidth];
    [_todayCountNum setTextColor:LabelWhiteTextColor];
    [_todayCountNum setTextAlignment:NSTextAlignmentLeft];
    [_todayCountNum sizeToFit];
    //    _todayCountNum.text = [NSString stringWithFormat:@"%0.1f",self.devicePlug.pw_day];
    _todayCountNum.text = [NSString stringWithFormat:@"%0.1f", 20.0f];
    [self addSubview:_todayCountNum];
    
    _todayCountTail = [[UILabel alloc] init];
    _todayCountTail.text = [NSString stringWithFormat:@"%@ >", NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.quant.degree", @"plugin_gateway", @"度")];
    [_todayCountTail setTextColor:LabelWhiteTextColor];
    [_todayCountTail setTextAlignment:NSTextAlignmentLeft];
    
    NSInteger todayCountTailLargeNumber = _todayCountTail.text.length;
    NSMutableAttributedString *todayCountTailAttribute = [[NSMutableAttributedString alloc] initWithString:_todayCountTail.text];
    [todayCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0xffffff alpha:1.0] range:NSMakeRange(todayCountTailLargeNumber - 1, 1)];
    [todayCountTailAttribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15.0f] range:NSMakeRange(todayCountTailLargeNumber - 1, 1)];

    [todayCountTailAttribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0f] range:NSMakeRange(0, todayCountTailLargeNumber - 1)];
    self.todayCountTail.attributedText = todayCountTailAttribute;
    
    [self addSubview:_todayCountTail];
    
    _monthCountTitle = [[UILabel alloc] init];
    _monthCountTitle.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.quant.month", @"plugin_gateway", @"当月");
    _monthCountTitle.font = [UIFont systemFontOfSize:14];
    [_monthCountTitle setTextColor:LabelWhiteTextColor];
    [_monthCountTitle setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_monthCountTitle];
    
    _monthCountNum = [[UILabel alloc] init];
    [_monthCountNum setTextColor:LabelWhiteTextColor];
    [_monthCountNum setTextAlignment:NSTextAlignmentLeft];
    _monthCountNum.font = [UIFont systemFontOfSize:22.f * ScaleWidth];
    //    _monthCountNum.text = [NSString stringWithFormat:@"%0.1f",self.devicePlug.pw_month];
    _monthCountNum.text = [NSString stringWithFormat:@"%0.1f",33.0f];
    [_monthCountNum sizeToFit];
    [self addSubview:_monthCountNum];
    
    _monthCountTail = [[UILabel alloc] init];
    _monthCountTail.text = [NSString stringWithFormat:@"%@ >", NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.quant.degree", @"plugin_gateway", @"度")];
    [_monthCountTail setTextColor:LabelWhiteTextColor];
    [_monthCountTail setTextAlignment:NSTextAlignmentLeft];
    
    NSInteger monthCountTailLargeNumber = _monthCountTail.text.length;
    NSMutableAttributedString *monthCountTailAttribute = [[NSMutableAttributedString alloc] initWithString:_monthCountTail.text];
    [monthCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0xffffff alpha:1.0] range:NSMakeRange(monthCountTailLargeNumber - 1, 1)];
    [monthCountTailAttribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0f] range:NSMakeRange(0, monthCountTailLargeNumber)];
    self.monthCountTail.attributedText = monthCountTailAttribute;
    
    [self addSubview:_monthCountTail];
    
    _currentWatTitle = [[UILabel alloc] init];
    _currentWatTitle.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.quant.wat", @"plugin_gateway", @"功率");
    _currentWatTitle.font  = [UIFont systemFontOfSize:14];
    _currentWatTitle.textColor = LabelWhiteTextColor;
    [_currentWatTitle setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_currentWatTitle];
    
    _currentWatNum = [[UILabel alloc] init];
    _currentWatNum.font = [UIFont systemFontOfSize:22.f * ScaleWidth];
    [_currentWatNum setTextColor:LabelWhiteTextColor];
    [_currentWatNum setTextAlignment:NSTextAlignmentLeft];
    [_currentWatNum sizeToFit];
    //    _currentWatNum.text = [NSString stringWithFormat:@"%0.1f",self.devicePlug.sload_power];
    _currentWatNum.text = [NSString stringWithFormat:@"%0.1f", 10.0f];
    [self addSubview:_currentWatNum];
    
    _currentWatTail = [[UILabel alloc] init];
    _currentWatTail.text = [NSString stringWithFormat:@"%@ >", NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.quant.w", @"plugin_gateway", @"w")];
    [_currentWatTail setTextColor:LabelWhiteTextColor];
    [_currentWatTail setTextAlignment:NSTextAlignmentLeft];

    
    NSInteger temperatureLargeNumber = _currentWatTail.text.length;
    NSMutableAttributedString *currentWatTailAttribute = [[NSMutableAttributedString alloc] initWithString:_currentWatTail.text];
    [currentWatTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0xffffff alpha:1.0] range:NSMakeRange(temperatureLargeNumber - 1, 1)];
    [currentWatTailAttribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0f] range:NSMakeRange(0, temperatureLargeNumber)];
    self.currentWatTail.attributedText = currentWatTailAttribute;
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTest:)];
//    [self.currentWatTail addGestureRecognizer:tap];
    self.currentWatTail.userInteractionEnabled = YES;
    
    [self addSubview:_currentWatTail];
   
    _todayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    _todayBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH / 3, 80)];;
    _todayBtn.tag = 10000;
    [_todayBtn addTarget:self action:@selector(onTodayClicked:) forControlEvents:UIControlEventTouchUpInside];
    _todayBtn.backgroundColor = [UIColor clearColor];
    [self addSubview:_todayBtn];
    
    self.monthBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    _monthBtn = [[UIButton alloc] initWithFrame:CGRectMake(WIN_WIDTH / 3, 0, WIN_WIDTH / 3, 80)];;
    self.monthBtn.tag = 10001;
    [self.monthBtn addTarget:self action:@selector(onMonthClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.monthBtn.backgroundColor = [UIColor clearColor];
    [self addSubview:self.monthBtn];
    

    
    self.quantBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    _quantBtn = [[UIButton alloc] initWithFrame:CGRectMake(WIN_WIDTH * 2 / 3, 0, WIN_WIDTH / 3, 80)];;
    self.quantBtn.tag = 100002;
    [self.quantBtn addTarget:self action:@selector(onQuantTrend:) forControlEvents:UIControlEventTouchUpInside];
    self.quantBtn.backgroundColor = [UIColor clearColor];
    [self addSubview:self.quantBtn];
    
    
}

- (void)buildConstraints {
    // to be implemented in subclass
    XM_WS(weakself);
    
    CGFloat titleSpacing = 5 * ScaleHeight;
    CGFloat labelSpacing = 7 * ScaleHeight;
    CGFloat btnWidth = WIN_WIDTH / 3.0f - 1;
//    CGFloat btnHeight = self.bounds.size.height;
    CGFloat btnHeight = 80;


//    [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(weakself);
//    }];
    
//    本月用电
    [_monthCountTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself);
        make.bottom.mas_equalTo(weakself.mas_bottom).with.offset(-titleSpacing);
    }];
    
    [_monthCountNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself);
        make.bottom.mas_equalTo(weakself.monthCountTitle.mas_top).with.offset(-labelSpacing);
    }];
    
    [_monthCountTail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.monthCountNum.mas_right);
        make.centerY.mas_equalTo(weakself.monthCountNum);
    }];
    
    [_monthBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakself);
        make.size.mas_equalTo(CGSizeMake(btnWidth, btnHeight));
    }];
    
    //今日用电
    [_todayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakself);
        make.right.equalTo(weakself.monthBtn.mas_left);
        make.size.mas_equalTo(CGSizeMake(btnWidth, btnHeight));
    }];

    [_todayCountTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.todayBtn);
        make.bottom.mas_equalTo(weakself.mas_bottom).with.offset(-titleSpacing);
    }];
    
    [_todayCountNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.todayCountTitle);
        make.bottom.mas_equalTo(weakself.todayCountTitle.mas_top).with.offset(-labelSpacing);
    }];
    
    [_todayCountTail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.todayCountNum.mas_right);
//        make.bottom.mas_equalTo(weakself.todayCountTitle.mas_bottom).with.offset(-labelSpacing);
        make.centerY.mas_equalTo(weakself.todayCountNum);
    }];
    
   
    
    //功率
    [_quantBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakself);
        make.left.mas_equalTo(weakself.monthBtn.mas_right);
        make.size.mas_equalTo(CGSizeMake(btnWidth, btnHeight));
    }];
    
    [_currentWatTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.quantBtn);
        make.bottom.mas_equalTo(weakself.mas_bottom).with.offset(-titleSpacing);
    }];
    
    [_currentWatNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.currentWatTitle);
        make.bottom.mas_equalTo(weakself.currentWatTitle.mas_top).with.offset(-labelSpacing);
    }];
    
    [_currentWatTail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.currentWatNum.mas_right);
        make.centerY.mas_equalTo(weakself.currentWatNum);
    }];

    NSLog(@"%@", _quantBtn);
}

- (void)onTodayClicked:(UIButton *)sender {
    if (self.todayCallback) {
        self.todayCallback();
    }
    
}


- (void)onMonthClicked:(UIButton *)sender {
    if (self.monthCallback) {
        self.monthCallback();
    }
    
}
- (void)onQuantTrend:(id)sender {
    if (self.quantCallback) {
        self.quantCallback();
    }
}

/**
 *  不一定每次三个数据都要同时更新，传入非零才会更新。
 *
 */
- (void)updateQuant:(float)day month:(float)month power:(float)power {
    if (day>=0){
        _todayCountNum.text = [NSString stringWithFormat:@"%.1f", day];
    }
    if (month>=0){
        _monthCountNum.text = [NSString stringWithFormat:@"%.1f", month];
    }
    if (power>=0){
        _currentWatNum.text = [NSString stringWithFormat:@"%.1f", power];
    }
}

@end
