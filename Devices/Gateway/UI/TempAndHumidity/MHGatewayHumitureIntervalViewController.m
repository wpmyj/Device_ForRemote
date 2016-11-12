//
//  MHGatewayHumitureIntervalViewController.m
//  MiHome
//
//  Created by guhao on 3/4/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayHumitureIntervalViewController.h"

#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 ) //角度转化成PI

@interface MHGatewayHumitureIntervalViewController ()

@property (nonatomic, strong) UIImageView *temperatureImageView;
@property (nonatomic, strong) UIImageView *temperaturePointerView;
@property (nonatomic, strong) UILabel *tempeatureText;

@property (nonatomic, strong) UIImageView *humidtyImageView;
@property (nonatomic, strong) UIImageView *humidtyPointerView;
@property (nonatomic, strong) UILabel *humidtyText;

@property (nonatomic, strong) MHDeviceGatewaySensorHumiture *deviceHt;

@end

@implementation MHGatewayHumitureIntervalViewController

-(id)initWithDevice:(MHDevice *)device {
    if(self = [super init]) {
        self.deviceHt = (MHDeviceGatewaySensorHumiture*)device;
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [MHColorUtils colorWithRGB:0x202f3b];
    self.isTabBarHidden=YES;
    self.isNavBarTranslucent = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateStatus];
}

- (void)buildSubviews {
    [super buildSubviews];
    //温度
    _temperatureImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lumi_humiture_tempeture"]];
    [self.view addSubview:_temperatureImageView];
    
    _temperaturePointerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lumi_humiture_pointer"]];
    [self.view addSubview:_temperaturePointerView];
    
    _tempeatureText = [[UILabel alloc] init];
    _tempeatureText.font = [UIFont systemFontOfSize:16.0f];
    _tempeatureText.textColor = [MHColorUtils colorWithRGB:0xffffff alpha:0.7];
    [self.view addSubview:_tempeatureText];
    
    //湿度
    _humidtyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lumi_humiture_humidty"]];
    [self.view addSubview:_humidtyImageView];
    
    _humidtyPointerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lumi_humiture_pointer"]];
    [self.view addSubview:_humidtyPointerView];
    
    _humidtyText = [[UILabel alloc] init];
    _humidtyText.font = [UIFont systemFontOfSize:16.0f];
    _humidtyText.textColor = [MHColorUtils colorWithRGB:0xffffff alpha:0.7];
    [self.view addSubview:_humidtyText];
    
  

}

- (void)buildConstraints {
    [super buildConstraints];
    XM_WS(weakself);
    CGFloat imageViewSize = 243 * ScaleHeight;
    CGFloat pointerHeight = 162 * ScaleHeight;
    CGFloat pointerWidth = 19 * ScaleWidth;
    CGFloat spacing = 50 * ScaleHeight;
    
    [self.humidtyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakself.view.mas_bottom).with.offset(-spacing);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(imageViewSize, imageViewSize));
    }];
    
    [self.humidtyText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.view);
        make.bottom.mas_equalTo(weakself.humidtyImageView.mas_bottom);
    }];
    
    [self.humidtyPointerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(pointerWidth, pointerHeight));
        make.centerY.equalTo(weakself.humidtyImageView);
    }];
    
    [self.temperatureImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakself.humidtyImageView.mas_top).with.offset(-spacing);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(imageViewSize, imageViewSize));
    }];
    
    
    [self.tempeatureText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.view);
        make.bottom.mas_equalTo(weakself.temperatureImageView.mas_bottom);
    }];
    [self.temperaturePointerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(pointerWidth, pointerHeight));
        make.centerY.equalTo(weakself.temperatureImageView);
    }];
    

}

- (void)updateStatus {
    float temperatureAngle = 0;
    float humidtyAngle = 0;
    //温度的表盘不均匀
    if (self.deviceHt.temperature >= 0 && self.deviceHt.temperature <= 40) {
        temperatureAngle = (self.deviceHt.temperature - 20) * 90  / 20.0f;
    }
    else {
        if (self.deviceHt.temperature <= -20) {
            self.deviceHt.temperature = -20;
        }
        if (self.deviceHt.temperature >= 60) {
            self.deviceHt.temperature = 60;
        }
        if (self.deviceHt.temperature < 0) {
            temperatureAngle = -90 + self.deviceHt.temperature * 45 / 20.0f;
        }
        if (self.deviceHt.temperature > 40) {
            temperatureAngle = 90 + (self.deviceHt.temperature - 40) * 45 / 20.0f;
        }
    }
    if (self.deviceHt.humidity <= 0 ) {
        self.deviceHt.humidity = 0;
    }
    humidtyAngle = (self.deviceHt.humidity - 50) * 2.7f;

    
    self.temperaturePointerView.transform = CGAffineTransformMakeRotation(ToRad(temperatureAngle));
    self.humidtyPointerView.transform = CGAffineTransformMakeRotation(ToRad(humidtyAngle));
    
    self.tempeatureText.text = [NSString stringWithFormat:@"%.0f℃", self.deviceHt.temperature];
    self.humidtyText.text = [NSString stringWithFormat:@"%.0f%%", self.deviceHt.humidity];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
