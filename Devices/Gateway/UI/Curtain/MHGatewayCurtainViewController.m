//
//  MHGatewayCurtainViewController.m
//  MiHome
//
//  Created by guhao on 16/1/11.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayCurtainViewController.h"
#import "MHDeviceGatewaySensorCurtain.h"
#import "MHGatewayTimerSettingNewViewController.h"
#import "MHGatewayCurtainLevelSettingViewController.h"
#import "MHGatewaySensorViewController.h"
#import "MHGatewayCurtainLevelAnimaiton.h"
#import "MHGatewayCurtainSettingViewController.h"

#define ASTag_More 1001
#define BtnTag_Open 1002
#define BtnTag_Stop 1003
#define BtnTag_Close 1004
#define BtnTag_Timer 1005

#define LabelWhiteTextColor [UIColor whiteColor]
#define OpenBgColor [MHColorUtils colorWithRGB:0x00a161]
#define CloseBgColor [MHColorUtils colorWithRGB:0x464646]

@interface MHGatewayCurtainViewController ()

@property (nonatomic, strong) MHDeviceGatewaySensorCurtain *deviceCurtain;
@property (nonatomic, strong) MHGatewayTimerSettingNewViewController *timerVC;
@property (nonatomic, strong) MHGatewayCurtainLevelSettingViewController *levelVC;

@property (nonatomic, assign) BOOL *isOpen;

@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIButton *btnOnOff;
@property (nonatomic, strong) UIButton *btnStop;
@property (nonatomic, strong) UIButton *btnTimer;
@property (nonatomic, strong) UILabel *labOnOff;
@property (nonatomic, strong) UILabel *labStop;
@property (nonatomic, strong) UILabel *labTimer;

@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UIImageView *curtainPlunger;
@property (nonatomic, strong) UILabel *levelLabel;
@property (nonatomic, strong) UISlider *levelSlider;
@property (nonatomic, strong) MHGatewayCurtainLevelAnimaiton *levelAnimation;
@property (nonatomic, strong) UILabel *offTip;
@property (nonatomic, strong) UILabel *onTip;

@property (nonatomic, strong) UIActionSheet *actionSheet;

@end

@implementation MHGatewayCurtainViewController 

- (instancetype)initWithDevice:(MHDevice *)device
{
    self = [super initWithDevice:device];
    if (self) {
        self.deviceCurtain = (MHDeviceGatewaySensorCurtain *)device;
        self.isHasShare = NO;
    }
    return self;
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isNavBarTranslucent = YES;
//    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.deviceCurtain getCurtainPropertyStatusWithSuccess:^(id obj) {
        NSLog(@"窗帘的属性%@", obj);
    } failure:^(NSError *error) {
        NSLog(@"获取窗帘属性失败%@", error);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.deviceCurtain getPrivatePropertySuccess:^(id obj) {
        
    } failure:^(NSError *v) {
        
    }];
}

- (void)buildSubviews {
    [super buildSubviews];
    

    
    self.menuView = [[UIView alloc] init];
    [self.menuView setBackgroundColor:[MHColorUtils colorWithRGB:0x133a69]];
    [self.view addSubview:self.menuView];
    
    self.footerView = [[UIView alloc] init];
    [self.footerView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.footerView];
    
    self.curtainPlunger = [[UIImageView alloc] init];
    self.curtainPlunger.image = [UIImage imageNamed:@"gateway_curtain_plunger"];
    [self.view addSubview:self.curtainPlunger];

    
    self.levelSlider = [[UISlider alloc] init];
    self.levelSlider.minimumValue = 0;
    self.levelSlider.maximumValue = 100;
    self.levelSlider.continuous = NO;
    [self.levelSlider setThumbImage:[UIImage imageNamed:@"gateway_slider_thumb"] forState:UIControlStateNormal];
//    [self.levelSlider setMaximumTrackTintColor:[MHColorUtils colorWithRGB:0xdfdfdf]];
//    [self.levelSlider setMinimumTrackTintColor:[MHColorUtils colorWithRGB:0x37b57d]];
    [self.levelSlider setMaximumTrackTintColor:[MHColorUtils colorWithRGB:0xffffff alpha:0.5]];
    [self.levelSlider setMinimumTrackTintColor:[MHColorUtils colorWithRGB:0xffffff alpha:0.5]];
    [self.levelSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.levelSlider];
    
    self.levelAnimation = [[MHGatewayCurtainLevelAnimaiton alloc] init];
    [self.view addSubview:self.levelAnimation];

    _offTip = [[UILabel alloc] init];
    _offTip.font = [UIFont systemFontOfSize:20];
    [_offTip setTextColor:CloseBgColor];
    _offTip.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.action.close",@"plugin_gateway","关");
    _offTip.hidden = YES;
    [self.view addSubview:_offTip];
    
    _onTip = [[UILabel alloc] init];
    _onTip.font = [UIFont systemFontOfSize:20];
    [_onTip setTextColor:CloseBgColor];
    _onTip.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.action.open",@"plugin_gateway","开");
    [_onTip setTextAlignment:NSTextAlignmentRight];
    _onTip.hidden = YES;
    [self.view addSubview:_onTip];
    
    _levelLabel = [[UILabel alloc] init];
    _levelLabel.font = [UIFont systemFontOfSize:24];
    _levelLabel.textAlignment = NSTextAlignmentCenter;
    [_levelLabel setTextColor:CloseBgColor];
    _levelLabel.hidden = YES;
    [self.view addSubview:_levelLabel];
    
    _btnOnOff = [[UIButton alloc] init];
    _btnOnOff.clipsToBounds = NO;
    _btnOnOff.tag = BtnTag_Open;
    [_btnOnOff setBackgroundImage:[UIImage imageNamed:@"lumi_curtain_on"] forState:UIControlStateNormal];
    [_btnOnOff addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.footerView addSubview:_btnOnOff];
    
    _labOnOff = [[UILabel alloc] init];
    _labOnOff.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.action.open",@"plugin_gateway","开");
    _labOnOff.font = [UIFont systemFontOfSize:14];
    [_labOnOff setTextColor:CloseBgColor];
    [_labOnOff setTextAlignment:NSTextAlignmentCenter];
    [self.footerView addSubview:_labOnOff];
    
    self.btnStop = [[UIButton alloc] init];
    [self.btnStop setBackgroundImage:[UIImage imageNamed:@"lumi_curtain_stop"] forState:UIControlStateNormal];
    [self.btnStop addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.btnStop.tag = BtnTag_Stop;
    [self.footerView addSubview:self.btnStop];
    
    self.labStop = [[UILabel alloc] init];
    self.labStop.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.action.stop",@"plugin_gateway","停");
    self.labStop.font = [UIFont systemFontOfSize:14];
    [self.labStop setTextColor:CloseBgColor];
    [self.labStop setTextAlignment:NSTextAlignmentCenter];
    [self.footerView addSubview:self.labStop];

    
    _btnTimer = [[UIButton alloc] init];
    _btnTimer.clipsToBounds = NO;
    _btnTimer.tag = BtnTag_Close;
    [_btnTimer setBackgroundImage:[UIImage imageNamed:@"lumi_curtain_off"] forState:UIControlStateNormal];
    [_btnTimer addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.footerView addSubview:_btnTimer];
    
    self.labTimer = [[UILabel alloc] init];
    self.labTimer.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.action.close",@"plugin_gateway","关");
    self.labTimer.font = [UIFont systemFontOfSize:14];
    [self.labTimer setTextAlignment:NSTextAlignmentCenter];
    [self.labTimer setTextColor:CloseBgColor];
    [self.footerView addSubview:self.labTimer];
    
    
}

- (void)buildConstraints {
    [super buildConstraints];
    XM_WS(weakself);
    CGFloat bgCurtainHeight = 514 * ScaleHeight;
    CGFloat sliderSpacing = 20 * ScaleHeight;
    CGFloat btnTopSpacing = 38 * ScaleHeight;
    CGFloat btnSize = 48 ;
    CGFloat sliderWidth = 60;
    CGFloat labWidth = 40 ;
    CGFloat labHeight = 16 ;
    CGFloat spacing = 13 * ScaleHeight;
    CGFloat horizontal = 57 * ScaleWidth;
    
    CGFloat plungerHeight = 15 * ScaleHeight;
    CGFloat plungerWidth = 272 * ScaleHeight;
    
    //menuview
    [self.menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(weakself.view);
//        make.left.equalTo(weakself.view);
//        make.right.equalTo(weakself.view);
        make.height.mas_equalTo(bgCurtainHeight);
    }];
    
    [self.curtainPlunger mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.view).with.offset(120);
        make.size.mas_equalTo(CGSizeMake(plungerWidth, plungerHeight));
        make.centerX.equalTo(weakself.view);
    }];
    
    [self.levelAnimation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.curtainPlunger.mas_bottom).with.offset(5);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(plungerWidth - 50 * ScaleHeight, 273 * ScaleHeight));
    }];
    
    //slider
    [self.levelSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakself.menuView.mas_bottom).with.offset(-sliderSpacing);
        make.left.equalTo(weakself.view).with.offset(sliderWidth);
        make.size.mas_equalTo(CGSizeMake(WIN_WIDTH - 120, 60));
    }];
 
    [self.levelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.view);
        make.bottom.mas_equalTo(weakself.levelSlider.mas_top);
    }];
    [self.offTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakself.levelSlider);
        make.right.mas_equalTo(weakself.levelSlider.mas_left).with.offset(-spacing);
    }];
    [self.onTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakself.levelSlider);
        make.left.mas_equalTo(weakself.levelSlider.mas_right).with.offset(spacing);
    }];

    //footerview
    
    [self.footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.menuView.mas_bottom);
        make.left.right.bottom.equalTo(weakself.view);
//        make.right.equalTo(weakself.view);
//        make.bottom.equalTo(weakself.view);
    }];
    
    [self.btnStop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.footerView);
        make.size.mas_equalTo(CGSizeMake(btnSize, btnSize));
        make.top.equalTo(weakself.footerView).with.offset(btnTopSpacing);
    }];
    [self.labStop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.footerView);
        make.top.equalTo(weakself.btnStop.mas_bottom).with.offset(spacing);
        make.size.mas_equalTo(CGSizeMake(labWidth, labHeight));
    }];
    
    [self.btnOnOff mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.footerView).with.offset(btnTopSpacing);
        make.size.mas_equalTo(CGSizeMake(btnSize, btnSize));
        make.right.equalTo(weakself.btnStop.mas_left).with.offset(-horizontal);
    }];
    [self.labOnOff mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.btnOnOff);
        make.top.equalTo(weakself.btnOnOff.mas_bottom).with.offset(spacing);
        make.size.mas_equalTo(CGSizeMake(labWidth, labHeight));
    }];
    
    [self.btnTimer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.footerView).with.offset(btnTopSpacing);
        make.size.mas_equalTo(CGSizeMake(btnSize, btnSize));
        make.left.equalTo(weakself.btnStop.mas_right).with.offset(horizontal);
    }];
    [self.labTimer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.btnTimer);
        make.top.equalTo(weakself.btnTimer.mas_bottom).with.offset(spacing);
        make.size.mas_equalTo(CGSizeMake(labWidth, labHeight));
    }];
}

#pragma mark - 设备控制相关
- (void)onMore:(id)sender {
    MHGatewayCurtainSettingViewController *curtainSettingVC = [[MHGatewayCurtainSettingViewController alloc] initWithCurtainDevice:self.deviceCurtain curtainController:self];
    [self.navigationController pushViewController:curtainSettingVC animated:YES];
}


#pragma mark - 控制
- (void)buttonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case BtnTag_Open: {
            [self curtainOpen];
            break;
        }
        case BtnTag_Stop: {
            [self curtainStop];
            break;
        }
        case BtnTag_Close: {
            [self curtainClose];
            break;
        }
        default:
            break;
    }
}

- (void)curtainOpen {
    [self.deviceCurtain openCurtainSuccess:^(id obj) {
        NSLog(@"%@", obj);
    } andFailure:^(NSError *v) {
         [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"send.failed",@"plugin_gateway", nil) duration:1.5f modal:YES];
    }];
}

- (void)curtainStop {
    [self.deviceCurtain stopCurtainSuccess:^(id obj) {
        NSLog(@"%@", obj);

    } andFailure:^(NSError *v) {
         [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"send.failed",@"plugin_gateway", nil) duration:1.5f modal:YES];
    }];
}

- (void)curtainClose {
    [self.deviceCurtain closeCurtainSuccess:^(id obj) {
        NSLog(@"%@", obj); 
    } andFailure:^(NSError *v) {
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"send.failed",@"plugin_gateway", nil) duration:1.5f modal:YES];
    }];
}


- (void)openTimerSetting {
    XM_WS(weakself);
    self.timerVC = [[MHGatewayTimerSettingNewViewController alloc] initWithDevice:self.deviceCurtain andIdentifier:LumiCurtainTimerIdentify];
    self.timerVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.timer.title",@"plugin_gateway", @"窗帘定时");
    self.timerVC.controllerIdentifier = @"mydevice.gateway.sensor.curtain.timer.title";
    self.timerVC.onAddNewTimer = ^(MHDataDeviceTimer *newTimer){
        [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"mydevice.timersetting.adding",@"plugin_gateway","添加定时中，请稍候...") modal:YES];
        
        newTimer.identify = LumiCurtainTimerIdentify;
        newTimer.onMethod = @"toggle_device";
        newTimer.onParam = @[ @"open" ];
        newTimer.offMethod = @"toggle_device";
        newTimer.offParam = @[ @"close" ];
        
        [weakself.timerVC addTimer:newTimer];
    };
    [self.navigationController pushViewController:self.timerVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"openTimerSetting"];
}

- (void)openLevelSetting {
    self.levelVC = [[MHGatewayCurtainLevelSettingViewController alloc] initWithDevice:self.deviceCurtain];
    self.levelVC.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.openlevel",@"plugin_gateway", @"开启位置");
    self.levelVC.controllerIdentifier = @"mydevice.gateway.sensor.curtain.openlevel";
    self.levelVC.isTabBarHidden = YES;
    [self.navigationController pushViewController:self.levelVC animated:YES];
    
    [self gw_clickMethodCountWithStatType:@"openLevelSetting"];

}

-(void)onAddScene {
    MHGatewaySensorViewController *sceneVC = [[MHGatewaySensorViewController alloc] initWithDevice:self.deviceCurtain];
    sceneVC.isHasMore = NO;
    sceneVC.isHasShare = NO;
    [self.navigationController pushViewController:sceneVC animated:YES];
}

- (void)sliderValueChanged:(UISlider *)sender {
//    [self.levelAnimation configureWithLevel:sender.value];
//    self.levelLabel.text = [NSString stringWithFormat:@"%0.lf%%", sender.value];
    [self.deviceCurtain setCurtainProperty:sender.value andSuccess:^(id obj) {
        NSLog(@"设置成功%@", obj);
        
    } failure:^(NSError *error) {
        NSLog(@"设置开关比错误%@", error);
    }];

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
