//
//  MHGatewayHumitureCell.m
//  MiHome
//
//  Created by guhao on 15/12/31.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//

#import "MHGatewayHumitureCell.h"

#define kDryAndCold NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.temp_lower_than_23_and_humidity_lower30",@"plugin_gateway","室内干冷")
#define kType1 NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.humidity_type_1",@"plugin_gateway","注意保暖,补充水分")

#define kHumidAndCold NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.temp_lower_than_23_and_humidity_than_70",@"plugin_gateway","室内湿冷")
#define kType2 NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.humidity_type_2",@"plugin_gateway","注意保暖,建议除湿")

#define kDryAndHot NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.humidity_temp_than_27_and_humidity_lower_30",@"plugin_gateway","室内干热")
#define kType3 NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.humidity_type_3",@"plugin_gateway","注意防暑降温,补充水分")

#define kHumidAndHot NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.humidity_temp_than_27_and_humidity_than_70",@"plugin_gateway","室内湿热")
#define kType4 NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.humidity_type_4",@"plugin_gateway","注意防暑降温,建议除湿")

#define kDry NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.temp_between_23_and_27_and_humindity_lower_30",@"plugin_gateway","室内干燥")
#define kType5 NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.humidity_type_5",@"plugin_gateway","注意补充水分,建议加湿")

#define kHumid NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.temp_between_23_and_27_and_humidity_than_70",@"plugin_gateway","室内潮湿")
#define kType6 NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.humidity_type_6",@"plugin_gateway","影响身体健康,建议除湿")

#define kCold NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.temp_lower_than_23_and_humidity_between_30_and_70",@"plugin_gateway","室内偏冷")
#define kType7 NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.humidity_type_7",@"plugin_gateway","注意保暖")

#define kHot NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.humidity_temp_than_27_and_humidity_between_30_and_70",@"plugin_gateway","室内偏热")
#define kType8 NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.humidity_type_8",@"plugin_gateway","注意防暑降温")

#define kComfortable NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.temp_between_23_and_27_and_humidity_between_30_and_70",@"plugin_gateway","舒适")


#define DryCold  NSLocalizedStringFromTable(@"mydevice.gateway.log.ht.drycold",@"plugin_gateway","dry cold")
#define HumidCold  NSLocalizedStringFromTable(@"mydevice.gateway.log.ht.humidcold",@"plugin_gateway","humid cold")
#define Cold  NSLocalizedStringFromTable(@"mydevice.gateway.log.ht.cold",@"plugin_gateway","cold")
#define Dry  NSLocalizedStringFromTable(@"mydevice.gateway.log.ht.dry",@"plugin_gateway","dry")
#define Comfortable  NSLocalizedStringFromTable(@"mydevice.gateway.log.ht.comfortable",@"plugin_gateway","comfortable")
#define Humid  NSLocalizedStringFromTable(@"mydevice.gateway.log.ht.humid",@"plugin_gateway","humid")
#define DryHot  NSLocalizedStringFromTable(@"mydevice.gateway.log.ht.dryhot",@"plugin_gateway","dry hot")
#define HumidHot  NSLocalizedStringFromTable(@"mydevice.gateway.log.ht.humidhot",@"plugin_gateway","humid hot")
#define Hot  NSLocalizedStringFromTable(@"mydevice.gateway.log.ht.hot",@"plugin_gateway","hot")

static NSDictionary *htTypes = nil;


@interface MHGatewayHumitureCell ()

@property (nonatomic, strong) UIImageView *topImageView;
@property (nonatomic, strong) UIImageView *htImageView;

@property (nonatomic, strong) UILabel *innerHtText;
@property (nonatomic, strong) UILabel *outterHtText;

@property (nonatomic, strong) UIButton *warmText;
@property (nonatomic, strong) UILabel *adviceText;
@property (nonatomic, strong) UILabel *temperatureLabel;
@property (nonatomic, strong) UILabel *humidityLabel;

@property (nonatomic, strong) UIImageView *arrowImageView;



@end

@implementation MHGatewayHumitureCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
       htTypes = @{ DryCold     :@[ kDryAndCold,   kType1, @"lumi_ht_cold_bg", @"" ],
           HumidCold   :@[ kHumidAndCold, kType2, @"lumi_ht_cold_bg", @"lumi_ht_rain_bg" ],
           DryHot      :@[ kDryAndHot,    kType3, @"lumi_ht_hot_bg",  @"" ],
           HumidHot    :@[ kHumidAndHot,  kType4, @"lumi_ht_hot_bg",  @"lumi_ht_rain_bg" ],
           Dry         :@[ kDry,          kType5, @"lumi_ht_hot_bg",  @"" ],
           Humid       :@[ kHumid,        kType6, @"lumi_ht_warm_bg", @"lumi_ht_rain_bg" ],
           Cold        :@[ kCold,         kType7, @"lumi_ht_cold_bg", @"" ],
           Hot         :@[ kHot,          kType8, @"lumi_ht_hot_bg",  @"" ],
           Comfortable :@[ kComfortable,  @"",    @"lumi_ht_warm_bg", @"" ]
           };
        [self buildSubviews];
    }
    return self;
}


- (void)buildSubviews {
    
    self.htImageView = [[UIImageView alloc] init];
    self.htImageView.clipsToBounds = YES;
    [self.contentView addSubview:self.htImageView];
    
    self.topImageView = [[UIImageView alloc] init];
    self.topImageView.clipsToBounds = YES;
    self.topImageView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.topImageView];
    

    self.warmText = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.warmText addTarget:self action:@selector(cozyTrend:) forControlEvents:UIControlEventTouchUpInside];
    [self.warmText setTintColor:[UIColor whiteColor]];
    [self.warmText setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:self.warmText];

    self.arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lumi_navigation_arrow"]];
    self.arrowImageView.contentMode = UIViewContentModeCenter;
    UITapGestureRecognizer *cozyTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cozyTrend:)];
    [self.arrowImageView addGestureRecognizer:cozyTap];
    self.arrowImageView.userInteractionEnabled = YES;
    [self.contentView addSubview:self.arrowImageView];

    self.adviceText = [[UILabel alloc] init];
    self.adviceText.font = [UIFont systemFontOfSize:20.0f];
    self.adviceText.textColor = [MHColorUtils colorWithRGB:0xfffefe];
    self.adviceText.textAlignment = NSTextAlignmentCenter;
    self.adviceText.numberOfLines = 0;
    self.adviceText.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:self.adviceText];
    
    self.temperatureLabel = [[UILabel alloc] init];
    self.temperatureLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.temperature",@"plugin_gateway","温度");
    self.temperatureLabel.textColor = [MHColorUtils colorWithRGB:0xffffff];
    self.temperatureLabel.alpha = 0.5;
    self.temperatureLabel.font = [UIFont systemFontOfSize:18.0f];
    [self.contentView addSubview:self.temperatureLabel];
    
    self.innerHtText = [[UILabel alloc] init];
    self.innerHtText.textColor = [MHColorUtils colorWithRGB:0xffffff];
    UITapGestureRecognizer *innerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loglistTap:)];
    [self.innerHtText addGestureRecognizer:innerTap];
    self.innerHtText.userInteractionEnabled = YES;
    [self.contentView addSubview:self.innerHtText];
    
    self.humidityLabel = [[UILabel alloc] init];
    self.humidityLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.humidity",@"plugin_gateway","湿度");
    self.humidityLabel.textColor = [MHColorUtils colorWithRGB:0xffffff];
    self.humidityLabel.alpha = 0.5;
    self.humidityLabel.font = [UIFont systemFontOfSize:18.0f];
    [self.contentView addSubview:self.humidityLabel];
    
    
    self.outterHtText = [[UILabel alloc] init];
    self.outterHtText.textColor = [MHColorUtils colorWithRGB:0xffffff];
    UITapGestureRecognizer *outTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loglistTap:)];
    [self.outterHtText addGestureRecognizer:outTap];
    self.outterHtText.userInteractionEnabled = YES;
    [self.contentView addSubview:self.outterHtText];
    
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    [self buildConstraints];
    
    [super updateConstraints];
}

- (void)buildConstraints {
    
    CGFloat leadingSpacing = 180 * ScaleHeight;
    CGFloat maxSpacing = 8 * ScaleHeight;
    
    CGFloat outterLabelSpacing = 90 * ScaleHeight;
    CGFloat topImageViewHeight = 467 * ScaleHeight;
    
    CGFloat midSpacing = 140 * ScaleHeight;
    CGFloat herizonSpacing = 40 * ScaleWidth;
    
    XM_WS(weakself);
    
    [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.contentView);
        make.left.equalTo(weakself.contentView);
        make.right.equalTo(weakself.contentView);
        make.height.mas_equalTo(topImageViewHeight);
    }];
    [self.htImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(weakself.contentView);
    }];
    
    [self.warmText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.contentView);
        make.top.equalTo(weakself.contentView).with.offset(leadingSpacing);
    }];
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakself.warmText);
        make.left.mas_equalTo(weakself.warmText.mas_right).with.offset(-5);
        make.size.mas_equalTo(CGSizeMake(35 * ScaleWidth, 54 * ScaleWidth));
    }];
    
    [self.adviceText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.contentView);
        make.top.mas_equalTo(weakself.warmText.mas_bottom).with.offset(maxSpacing);
        make.left.equalTo(weakself.contentView.mas_left).with.offset(herizonSpacing / 2);
        make.width.mas_equalTo(WIN_WIDTH - herizonSpacing);
    }];
    
    
    [self.temperatureLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.contentView).with.offset(herizonSpacing);
        make.bottom.equalTo(weakself.contentView).with.offset(-midSpacing);
    }];
    
 
    [self.innerHtText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakself.temperatureLabel.mas_centerY);
        make.right.mas_equalTo(weakself.contentView.mas_right).with.offset(-herizonSpacing);
    }];

    
    [self.humidityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.contentView).with.offset(herizonSpacing);
        make.top.mas_equalTo(weakself.temperatureLabel.mas_bottom).with.offset(outterLabelSpacing);
    }];
    
    [self.outterHtText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakself.humidityLabel.mas_centerY);
        make.left.mas_equalTo(weakself.innerHtText.mas_left);
    }];


}


- (void)refreshUI {
    NSString *currentStatus = [self getHTStautsWithTemperature:self.temperature humidity:self.humidity];
    if (![currentStatus isEqualToString:@""]) {
        NSString *strWarmText = [NSString stringWithFormat:@"%@", htTypes[currentStatus][0]];//
        NSMutableAttributedString *warmTextArritbute = [[NSMutableAttributedString alloc] initWithString:strWarmText];
        [warmTextArritbute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:36.0f * ScaleWidth] range:NSMakeRange(0, strWarmText.length)];
        [warmTextArritbute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0xfffefe] range:NSMakeRange(0, strWarmText.length)];
        [self.warmText setAttributedTitle:warmTextArritbute forState:UIControlStateNormal];
        self.warmText.hidden = NO;
        self.arrowImageView.hidden = NO;
    }
    else {
        self.warmText.hidden = YES;
        self.arrowImageView.hidden = YES;
    }
    self.adviceText.text = htTypes[currentStatus][1];
    if ([htTypes[currentStatus][3] isEqualToString:@""]) {
        self.topImageView.image = nil;
    }
    else {
        self.topImageView.image = [UIImage imageNamed:htTypes[currentStatus][3]];
    }
    self.htImageView.image = [UIImage imageNamed:htTypes[currentStatus][2]];
    // 绿色 网络异常，请按下设备开关键并重新刷新
    NSString *strHumiture = nil;
    NSInteger humitureLargeNumber = 0;
    NSString *strTemperature = nil;
    NSInteger temperatureLargeNumber = 0;
    
    if (self.humidity) {
        strHumiture = [NSString stringWithFormat:@"%.1lf%%  >", self.humidity];
         humitureLargeNumber = [NSString stringWithFormat:@"%.1lf", self.humidity].length;
         strTemperature = [NSString stringWithFormat:@"%.1lf℃  >", self.temperature];
        temperatureLargeNumber = [NSString stringWithFormat:@"%.1lf", self.temperature].length;
    }
    else {
        strHumiture = @"N/A  >";
        humitureLargeNumber = [NSString stringWithFormat:@"%@", @"N/A"].length;
        strTemperature = @"N/A  >";
        temperatureLargeNumber = [NSString stringWithFormat:@"%@", @"N/A"].length;
    }
    NSMutableAttributedString *temperatureAttribute = [[NSMutableAttributedString alloc] initWithString:strTemperature];
    [temperatureAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0xffffff alpha:0.9] range:NSMakeRange(strTemperature.length - 1, 1)];
    [temperatureAttribute addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"DINCond-Regular" size:36.0f * ScaleWidth] range:NSMakeRange(0, temperatureLargeNumber)];
    [temperatureAttribute addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"DINCond-Regular" size:20.0f] range:NSMakeRange(temperatureLargeNumber, strTemperature.length - temperatureLargeNumber)];
    self.innerHtText.attributedText = temperatureAttribute;
//
  
    
    NSMutableAttributedString *humitureAttriute = [[NSMutableAttributedString alloc] initWithString:strHumiture];
    [humitureAttriute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0xffffff alpha:0.9] range:NSMakeRange(strHumiture.length - 1, 1)];
    [humitureAttriute addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"DINCond-Regular" size:36.0f * ScaleWidth] range:NSMakeRange(0, humitureLargeNumber)];
    [humitureAttriute addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"DINCond-Regular" size:20.0f] range:NSMakeRange(humitureLargeNumber, strHumiture.length - humitureLargeNumber)];
    self.outterHtText.attributedText = humitureAttriute;
    

}

- (NSString *)getHTStautsWithTemperature:(float)temperature humidity:(float)humidity {
    if (temperature < 18 && ( humidity > 0 && humidity < 30)) {
        return DryCold;
    }
    else if (temperature < 18 && (humidity >= 30 && humidity <= 80)) {
        return Cold;
    }
    else if (temperature < 18 && (humidity > 80 && humidity <= 100)) {
        return HumidCold;
    }
    else if ((temperature >= 18 && temperature <= 27) && (humidity > 0 && humidity < 30)) {
        return Dry;
    }
    else if ((temperature >= 18 && temperature <= 27) && (humidity >= 30 && humidity <= 80)) {
        return Comfortable;
    }
    else if ((temperature >= 18 && temperature <= 27) && (humidity > 80 && humidity <= 100)) {
        return Humid;
    }
    else if ((temperature > 27) && (humidity > 80 && humidity <= 100)) {
        return HumidHot;
    }
    else if (temperature > 27 && ( humidity > 0 && humidity < 30)) {
        return DryHot;
    }
    else if (temperature > 27 && ( humidity >= 30 && humidity <= 80)) {
        return Hot;
    }
    else {
        return @"";
    }
}

- (void)cozyTrend:(id)sender {
    if (self.cozyClickCallBack) {
        self.cozyClickCallBack();
    }
}

- (void)loglistTap:(id)sender {
    if (self.loglistClickCallBack) {
        self.loglistClickCallBack();
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
