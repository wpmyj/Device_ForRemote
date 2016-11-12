//
//  MHACCoolSpeedViewController.m
//  MiHome
//
//  Created by ayanami on 16/7/26.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACCoolSpeedViewController.h"
#import "MHACCoolSpeedHtBindViewController.h"
#import "MHGatewayAlarmDurationPicker.h"
#import "MHDevListManager.h"

@interface MHACCoolSpeedViewController ()

@property (nonatomic, strong) MHDeviceAcpartner *acpartner;
@property (nonatomic, assign) BOOL isCool;
@property (nonatomic, assign) NSInteger coolSpan;
@property (nonatomic, copy) NSString *bindDid;

@property (nonatomic, strong) UISwitch *coolSwitch;
@property (nonatomic, strong) UILabel *coolCaption;
@property (nonatomic, strong) UILabel *coolComment;

@property (nonatomic, strong) UILabel *setting;

@property (nonatomic, strong) UIControl *coolTimeView;
@property (nonatomic, strong) UILabel *coolTimeTitle;
@property (nonatomic, strong) UILabel *coolTime;
@property (nonatomic, strong) UIImageView *coolIndictorView;
@property (nonatomic, strong) UIControl *coolTimeBtn;

@property (nonatomic, strong) UIControl *htView;
@property (nonatomic, strong) UILabel *htCaption;
@property (nonatomic, strong) UILabel *htComment;
@property (nonatomic, strong) UILabel *htAccess;
@property (nonatomic, strong) UIImageView *htIndictorView;
@property (nonatomic, strong) UIControl *htBtn;

@property (nonatomic, strong) UIView *lineOne;
@property (nonatomic, strong) UIView *lineTwo;
@property (nonatomic, strong) UIView *lineThree;

@property (nonatomic, strong) UIImageView *trendView;
@property (nonatomic, strong) UILabel *trendTitle;
@property (nonatomic, strong) UILabel *startTemp;
@property (nonatomic, strong) UILabel *endTemp;
@property (nonatomic, strong) UILabel *trendBegin;
@property (nonatomic, strong) UILabel *trendTime;


@property (nonatomic, strong) MHGatewayAlarmDurationPicker *durationPickerView;


@end

@implementation MHACCoolSpeedViewController
- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner
{
    self = [super init];
    if (self) {
        self.isTabBarHidden = YES;
        self.acpartner = acpartner;
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.footer.coolmode",@"plugin_gateway","速冷设置");
    
    if (self.acpartner.ACType == 2) {
        self.acpartner.timerPowerState = 1;
        self.acpartner.timerModeState = 0;
        self.acpartner.timerWindPower = 3;
        self.acpartner.timerWindState = 0;
        self.acpartner.timerTemperature = 20;
        [self.acpartner.kkAcManager changePowerStateWithPowerstate:AC_POWER_ON];
        [self.acpartner.kkAcManager getPowerState];
        [self.acpartner.kkAcManager getAirConditionInfrared];
        [self.acpartner judgeModeCanControl:PROP_TIMER];
        [self.acpartner judgeWindsCanControl:PROP_TIMER];
        [self.acpartner judgeSwipCanControl:PROP_TIMER];
        [self.acpartner judgeTempratureCanControl:PROP_TIMER];
    }
    
    NSString *strCmd = [self.acpartner getACCommand:SPEED_COOL_INDEX commandIndex:TIMER_COMMAND isTimer:NO];
    XM_WS(weakself);
    [self.acpartner saveCommandMap:strCmd success:^(id obj) {
        [weakself.acpartner resetAcStatus];
    } failure:^(NSError *v) {
        
    }];
    [self restoreCoolData];
    [self updateUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getCoolSpeedData];
}

- (void)buildSubviews {
    [super buildSubviews];
    

    XM_WS(weakself);
    self.coolCaption = [[UILabel alloc] init];
    self.coolCaption.textAlignment = NSTextAlignmentCenter;
    self.coolCaption.textColor = [MHColorUtils colorWithRGB:0x333333];
    self.coolCaption.font = [UIFont systemFontOfSize:15.0f];
        self.coolCaption.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.coolspeed.caption",@"plugin_gateway","开机速冷");
    
    [self.view addSubview:self.coolCaption];
    
   

    self.coolComment = [[UILabel alloc] init];
    self.coolComment.textAlignment = NSTextAlignmentLeft;
    self.coolComment.textColor = [MHColorUtils colorWithRGB:0x888888];
    self.coolComment.font = [UIFont systemFontOfSize:13.0f];
    self.coolComment.numberOfLines = 0;
    self.coolComment.text = [NSString stringWithFormat:@"%@%ld%@ %@", NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.coolspeed.comment.header",@"plugin_gateway","开机以最大风速降至20度,"),self.coolSpan,
    NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.coolspeed.caption",@"plugin_gateway","开机速冷"),
    NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.coolspeed.comment.tail",@"plugin_gateway","后恢复上次温度")];
    [self.view addSubview:self.coolComment];
    
    
    self.coolSwitch = [[UISwitch alloc] init];
    [self.coolSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.coolSwitch];
//    self.coolSwitch.on = self.isCool;

    
    //    [_bottomLine setFrame:CGRectMake(20.0f, self.bounds.size.height - 1.0f, self.bounds.size.width - 20.0f * 2, 1.0f)];
    _lineOne = [[UIView alloc] init];
    _lineOne.backgroundColor = [MHColorUtils colorWithRGB:0xf1f1f1];
    [self.view addSubview:_lineOne];
    
   

    
    
    self.coolTimeView = [[UIControl alloc] initWithFrame:CGRectMake(0, 140, WIN_WIDTH, 60)];
    self.coolTimeView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.coolTimeView];
//    self.coolTimeView.hidden = !self.isCool;

    _lineTwo = [[UIView alloc] init];
    _lineTwo.backgroundColor = [MHColorUtils colorWithRGB:0xf1f1f1];
    [self.coolTimeView addSubview:_lineTwo];
    
    self.coolTimeTitle = [[UILabel alloc] init];
    self.coolTimeTitle.textAlignment = NSTextAlignmentCenter;
    self.coolTimeTitle.textColor = [MHColorUtils colorWithRGB:0x333333];
    self.coolTimeTitle.font = [UIFont systemFontOfSize:15.0f];
    self.coolTimeTitle.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.coolspeed.time.caption",@"plugin_gateway","速冷时间");
    self.coolTimeTitle.userInteractionEnabled = YES;
    [self.coolTimeView addSubview:self.coolTimeTitle];
    
    
  
    
    
    self.coolTime = [[UILabel alloc] init];
    self.coolTime.textAlignment = NSTextAlignmentRight;
    self.coolTime.textColor = [MHColorUtils colorWithRGB:0x888888];
    self.coolTime.font = [UIFont systemFontOfSize:13.0f];
    self.coolTime.text = [NSString stringWithFormat:@"%ld%@", self.coolSpan, NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.countdown.minute",@"plugin_gateway","分钟")];
    self.coolTime.userInteractionEnabled = YES;
    [self.coolTimeView addSubview:self.coolTime];
    
    self.coolIndictorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lumi_scene_log_rightarrow"]];
    self.coolIndictorView.userInteractionEnabled = YES;
    [self.coolTimeView addSubview:self.coolIndictorView];
    
    self.durationPickerView = [[MHGatewayAlarmDurationPicker alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.gateway.scene.custom",@"plugin_gateway","自定义") durationPicked:^(NSUInteger duration) {
       
        [weakself setCoolSpeedData:duration Success:^(id obj) {
            weakself.coolSpan = duration;
            [weakself updateUI];
        } failure:^(NSError *v) {
            
        }];
    } pickerType:MHLMPickerType_Minute];
    
    
    _coolTimeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_coolTimeBtn addTarget:self action:@selector(oncoolTimeSet:) forControlEvents:UIControlEventTouchUpInside];
    _coolTimeBtn.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_coolTimeBtn];
    
    
    //温湿度
    self.htView = [[UIControl alloc] initWithFrame:CGRectMake(0, 140, WIN_WIDTH, 60)];
    self.htView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.htView];
//    self.htView.hidden = !self.isCool;

    _lineThree = [[UIView alloc] init];
    _lineThree.backgroundColor = [MHColorUtils colorWithRGB:0xf1f1f1];
    [self.htView addSubview:_lineThree];
    
    self.htCaption = [[UILabel alloc] init];
    self.htCaption.textColor = [MHColorUtils colorWithRGB:0x333333];
    self.htCaption.font = [UIFont systemFontOfSize:15.0f];
    self.htCaption.numberOfLines = 0;
    self.htCaption.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.coolspeed.ht.caption",@"plugin_gateway","室温低于30度的时候不执行速冷");
    [self.htView addSubview:self.htCaption];
    
  
    self.htComment = [[UILabel alloc] init];
    self.htComment.textAlignment = NSTextAlignmentRight;
    self.htComment.textColor = [MHColorUtils colorWithRGB:0x888888];
    self.htComment.font = [UIFont systemFontOfSize:13.0f];
    self.htComment.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.coolspeed.ht.comment",@"plugin_gateway","需要关联温湿度");
    [self.htView addSubview:self.htComment];
    
    self.htAccess = [[UILabel alloc] init];
    self.htAccess.textAlignment = NSTextAlignmentRight;
    self.htAccess.textColor = [MHColorUtils colorWithRGB:0x888888];
    self.htAccess.font = [UIFont systemFontOfSize:13.0f];
    self.htAccess.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.coolspeed.ht.notconnect",@"plugin_gateway","未关联");
    [self.htView addSubview:self.htAccess];
   

        self.htIndictorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lumi_scene_log_rightarrow"]];
    [self.htView addSubview:self.htIndictorView];
    
    _htBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_htBtn addTarget:self action:@selector(onHtSetting:) forControlEvents:UIControlEventTouchUpInside];
    _htBtn.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_htBtn];
    
    
    self.trendView = [[UIImageView alloc] init];
    [self.view addSubview:self.trendView];
//    self.trendView.hidden = !self.isCool;
    

    self.startTemp = [[UILabel alloc] init];
    self.startTemp.textAlignment = NSTextAlignmentCenter;
    self.startTemp.textColor = [MHColorUtils colorWithRGB:0x606060 alpha:0.6];
    self.startTemp.font = [UIFont systemFontOfSize:13.0f];
    self.startTemp.backgroundColor = [UIColor clearColor];
    self.startTemp.text = @"20℃";
    [self.view addSubview:self.startTemp];
//    self.startTemp.hidden = !self.isCool;

    
    self.endTemp = [[UILabel alloc] init];
    self.endTemp.textAlignment = NSTextAlignmentCenter;
    self.endTemp.textColor = [MHColorUtils colorWithRGB:0x606060 alpha:0.6];
    self.endTemp.font = [UIFont systemFontOfSize:13.0f];
    self.endTemp.text = @"20℃";
    [self.view addSubview:self.endTemp];
    self.endTemp.hidden = !self.isCool;

    
    self.trendBegin = [[UILabel alloc] init];
    self.trendBegin.textAlignment = NSTextAlignmentCenter;
    self.trendBegin.textColor = [MHColorUtils colorWithRGB:0x606060 alpha:0.6];
    self.trendBegin.font = [UIFont systemFontOfSize:13.0f];
    self.trendBegin.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.coolspeed.ht.start",@"plugin_gateway","开机");
    [self.view addSubview:self.trendBegin];
//    self.trendBegin.hidden = !self.isCool;

    self.trendTime = [[UILabel alloc] init];
    self.trendTime.textAlignment = NSTextAlignmentCenter;
    self.trendTime.textColor = [MHColorUtils colorWithRGB:0x606060 alpha:0.6];
    self.trendTime.font = [UIFont systemFontOfSize:13.0f];
    [self.view addSubview:self.trendTime];
//    self.trendTime.hidden = !self.isCool;

    
    
    self.trendTitle = [[UILabel alloc] init];
    self.trendTitle.textAlignment = NSTextAlignmentCenter;
    self.trendTitle.textColor = [MHColorUtils colorWithRGB:0x333333];
    self.trendTitle.font = [UIFont systemFontOfSize:14.0f];
    self.trendTitle.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.coolspeed.trend.title",@"plugin_gateway","速冷曲线");
    [self.view addSubview:self.trendTitle];
//    self.trendTitle.hidden = !self.isCool;

    
}


- (void)buildConstraints {
    [super buildConstraints];
    
    XM_WS(weakself);
    
    CGFloat leftSpacing = 15;
    CGFloat labelSpacing = 15;
    CGFloat lineSpacing = 5;
    CGFloat leadSpacing = 80;
    
    
    [self.coolCaption mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.view.mas_left).with.offset(leftSpacing);
        make.top.mas_equalTo(weakself.view.mas_top).with.offset(leadSpacing);
    }];
    
    [self.coolSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakself.view.mas_right).with.offset(-20);
        make.top.mas_equalTo(weakself.view.mas_top).with.offset(leadSpacing);
        make.size.mas_equalTo(CGSizeMake(40 , 20));
    }];
    
    [self.coolComment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.view.mas_left).with.offset(leftSpacing);
        make.width.mas_equalTo(WIN_WIDTH - (leftSpacing * 2 + 40 + 5));
        make.top.mas_equalTo(weakself.coolCaption.mas_bottom);
    }];
    
    [self.lineOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.coolComment.mas_bottom).with.offset(labelSpacing);
        make.width.mas_equalTo(WIN_WIDTH - leftSpacing * 2);
        make.height.mas_equalTo(1);
        make.centerX.equalTo(weakself.view);
    }];
    
    
    //速冷时间
    [self.coolTimeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakself.view);
        make.top.mas_equalTo(weakself.lineOne.mas_bottom).with.offset(2);
        make.size.mas_equalTo(CGSizeMake(WIN_WIDTH, 60));
    }];
    
    [self.coolTimeTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.coolTimeView.mas_left).with.offset(leftSpacing);
        make.top.mas_equalTo(weakself.coolTimeView.mas_top).with.offset(leftSpacing);
    }];
    
    
    [self.coolIndictorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakself.view.mas_right).with.offset(-leftSpacing);
        make.top.mas_equalTo(weakself.coolTimeView.mas_top).with.offset(leftSpacing);
        make.size.mas_equalTo(CGSizeMake(7, 13));
    }];
    
    [self.coolTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakself.coolIndictorView.mas_left).with.offset(-lineSpacing);
        make.top.mas_equalTo(weakself.coolTimeView.mas_top).with.offset(leftSpacing);
    }];
    
    
    [self.lineTwo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.coolTime.mas_bottom).with.offset(leftSpacing);
        make.width.mas_equalTo(WIN_WIDTH - leftSpacing * 2);
        make.height.mas_equalTo(1 * ScaleHeight);
        make.centerX.equalTo(weakself.view);
    }];
    
    [self.coolTimeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakself.coolTimeView);
    }];
    
    //温湿度
    [self.htView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakself.view);
        make.top.mas_equalTo(weakself.lineTwo.mas_bottom).with.offset(2);
        make.size.mas_equalTo(CGSizeMake(WIN_WIDTH, 70));
    }];
    
    [self.htCaption mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.view.mas_left).with.offset(leftSpacing);
        make.top.mas_equalTo(weakself.htView.mas_top).with.offset(labelSpacing);
        make.width.mas_equalTo(WIN_WIDTH - 120);
    }];
    
    [self.htComment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.view.mas_left).with.offset(leftSpacing);
        make.top.mas_equalTo(weakself.htCaption.mas_bottom);
    }];
    
    [self.htIndictorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakself.view.mas_right).with.offset(-leftSpacing);
        make.centerY.equalTo(weakself.htView);
        make.size.mas_equalTo(CGSizeMake(7, 13));
    }];
    
    [self.htAccess mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakself.htIndictorView.mas_left).with.offset(-lineSpacing);
        make.centerY.equalTo(weakself.htView);
        make.width.mas_equalTo(80 * ScaleWidth);
    }];
    
    
    [self.lineThree mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakself.htView.mas_bottom).with.offset(2);
        make.width.mas_equalTo(WIN_WIDTH - leftSpacing * 2);
        make.height.mas_equalTo(1 * ScaleHeight);
        make.centerX.equalTo(weakself.view);
    }];

    [self.htBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakself.htView);
    }];
    //速冷曲线
    [self.trendTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.view);
        make.bottom.mas_equalTo(weakself.view.mas_bottom).with.offset(-40);
    }];
    
    UIImage *trendImage = [UIImage imageNamed:@"acpartner_coolspeed_trend"];
    self.trendView.image = trendImage;
    [self.trendView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(trendImage.size);
        make.centerX.equalTo(weakself.view);
        make.bottom.mas_equalTo(weakself.trendTitle.mas_top).with.offset(-40);
    }];
    
    [self.startTemp mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.trendView.mas_left).with.offset(20 * ScaleWidth);
        make.bottom.mas_equalTo(weakself.trendView.mas_bottom).with.offset(-30 * ScaleHeight);
    }];
    
    [self.endTemp mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakself.startTemp);
        make.right.mas_equalTo(weakself.trendView.mas_right).with.offset(-20 * ScaleWidth);
    }];
    
    
    [self.trendBegin mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.trendView.mas_left).with.offset(20 * ScaleWidth);
        make.bottom.mas_equalTo(weakself.trendView.mas_bottom);
    }];
    
    [self.trendTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakself.trendBegin);
        make.right.mas_equalTo(weakself.trendView.mas_right).with.offset(-20 * ScaleWidth);
    }];
//    
//    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(weakself.view.mas_left).with.offset(leftSpacing);
//        make.top.mas_equalTo(weakself.lineTwo.mas_bottom).with.offset(labelSpacing);
//    }];

}

- (void)oncoolTimeSet:(id)sender {
    [self.durationPickerView setDuration:self.coolSpan];
    [self.durationPickerView showInView:self.view.window];
    [self gw_clickMethodCountWithStatType:@"setACPartnerCoolSpeedTimeSpan:"];
}

- (void)onHtSetting:(id)sender {
    XM_WS(weakself);
    MHACCoolSpeedHtBindViewController *htVC = [[MHACCoolSpeedHtBindViewController alloc] initWithAcpartner:self.acpartner htDid:[self.bindDid isEqualToString:@""] ? kCoolNotBindHt : self.bindDid timeSpan:self.coolSpan];
    [htVC setHtSelect:^(NSString *htDid) {
        if ([htDid isEqualToString:kCoolNotBindHt]) {
            weakself.bindDid = @"";
        }
        else {
            weakself.bindDid = htDid;

        }
        [weakself updateUI];
    }];
    [self.navigationController pushViewController:htVC animated:YES];
    
    [self gw_clickMethodCountWithStatType:@"setACPartnerCoolSpeedH&TBind:"];

}

- (void)switchValueChanged:(UISwitch *)sender {
    XM_WS(weakself);
    self.isCool = !self.isCool;
    [self setCoolSpeedData:self.coolSpan Success:^(id obj) {
        weakself.coolSwitch.on = weakself.isCool;

    } failure:^(NSError *v) {
        weakself.isCool = !weakself.isCool;
        weakself.coolSwitch.on = weakself.isCool;

    }];
    [[MHTipsView shareInstance] showTips:@"" modal:YES];
    [self gw_clickMethodCountWithStatType:@"setACPartnerCoolSpeedSwitch:"];
    
}

- (void)setCoolSpeedData:(NSInteger )timeSpan Success:(SucceedBlock)success failure:(FailedBlock)failure {
    XM_WS(weakself);
    NSMutableArray *payload = [[NSMutableArray alloc] init];
    [payload addObject:@((int)self.isCool)];
    [payload addObject:@(timeSpan)];
    [payload addObject:self.bindDid ?: @""];
    [[MHTipsView shareInstance] showTips:@"" modal:YES];
    
    [self.acpartner setCoolSpeed:payload success:^(id obj) {
        [[MHTipsView shareInstance] hide];
        [weakself updateUI];
        [weakself saveCoolData];
        if (success) success(obj);

//        [[MHTipsView shareInstance] showTipsInfo:@"保存修改成功" duration:1.5 modal:YES];
        
    } failure:^(NSError *error) {
        NSLog(@"错误%@", error);
        if (failure) failure(error);
        [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"operation.failed",@"plugin_gateway","操作失败, 请检查网络") duration:1.5f modal:NO];

//        [[MHTipsView shareInstance] showTipsInfo:@"跪了" duration:1.5 modal:YES];
    }];

}

- (void)updateUI {
    self.coolTime.text = [NSString stringWithFormat:@"%ld%@", self.coolSpan, NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.countdown.minute",@"plugin_gateway","分钟")];
    self.trendTime.text = [NSString stringWithFormat:@"%ld(%@)", self.coolSpan, NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.countdown.minute",@"plugin_gateway","分钟")];
    if ([self.bindDid isEqualToString:@""]) {
        self.htAccess.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.coolspeed.ht.notconnect",@"plugin_gateway","未关联");
    }
    else {
        self.htAccess.text = [[[MHDevListManager sharedManager] deviceForDid:self.bindDid] name];
    }
    self.coolComment.text = [NSString stringWithFormat:@"%@%ld%@%@", NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.coolspeed.comment.header",@"plugin_gateway","开机以最大风速降至20度,"),self.coolSpan,NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.countdown.minute",@"plugin_gateway","分钟"),NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.coolspeed.comment.tail",@"plugin_gateway","后恢复上次温度")];
    self.coolSwitch.on = self.isCool;
    self.htView.hidden = !self.isCool;
    self.trendView.hidden = !self.isCool;
    self.coolTimeView.hidden = !self.isCool;
    self.trendTitle.hidden = !self.isCool;
    self.trendBegin.hidden = !self.isCool;
    self.trendTime.hidden = !self.isCool;
    self.startTemp.hidden = !self.isCool;
    self.endTemp.hidden = !self.isCool;

    
}

- (void)getCoolSpeedData {
    XM_WS(weakself);
    [self.acpartner getCoolSpeedResultSuccess:^(id obj) {
        NSLog(@"速冷结果%@", obj);
        if ([obj[@"result"] isKindOfClass:[NSArray class]] && [obj[@"result"] count] > 2) {
            NSArray *result = obj[@"result"];
            weakself.isCool = [result[0] boolValue];
            weakself.coolSpan = [result[1] integerValue];
            weakself.bindDid = result[2];
            [weakself updateUI];
            [weakself saveCoolData];
        }
    } failure:^(NSError *v) {
        
    }];
}


- (void)saveCoolData {
    
    [[NSUserDefaults standardUserDefaults] setObject:@((int)self.isCool) forKey:[NSString stringWithFormat:@"acpartner_isCool_%@%@",self.acpartner.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.coolSpan) forKey:[NSString stringWithFormat:@"acpartner_coolSpan_%@%@",self.acpartner.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] setObject:self.bindDid forKey:[NSString stringWithFormat:@"acpartner_htBindDid_%@%@",self.acpartner.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)restoreCoolData {
   self.isCool =  [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"acpartner_isCool_%@%@",self.acpartner.did,[MHPassportManager sharedSingleton].currentAccount.userId]] boolValue];
    self.coolSpan = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"acpartner_coolSpan_%@%@",self.acpartner.did,[MHPassportManager sharedSingleton].currentAccount.userId]] integerValue];
    self.bindDid = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"acpartner_htBindDid_%@%@",self.acpartner.did,[MHPassportManager sharedSingleton].currentAccount.userId]];
    self.coolSpan = self.coolSpan ?: 10;
    NSLog(@"%@", self.bindDid);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
