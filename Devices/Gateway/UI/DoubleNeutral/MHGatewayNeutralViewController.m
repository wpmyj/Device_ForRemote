//
//  MHGatewayNeutralViewController.m
//  MiHome
//
//  Created by guhao on 15/12/9.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//

#import "MHGatewayNeutralViewController.h"
#import "MHDeviceGatewaySensorDoubleNeutral.h"
#import "MHGatewayNeutralTimerSelectedViewController.h"
#import "MHGatewaySensorViewController.h"
#import "MHDeviceGatewaySensorLoopData.h"
#import "MHWaveAnimation.h"
#import "MHGatewayNeutralChangeNameViewController.h"
#import "MHGatewayNeutralLogoSelectedViewController.h"
#import "MHLumiChangeIconManager.h"

#define OpenBtn  @"lumi_neutral_on"
#define CloseBtn @"lumi_neutral_off"
#define OpenLight  @"lumi_neutral_light_title_on"
#define CloseLight @"lumi_neutral_light_title_off"

#define BtnTag_Neutral0 1000
#define BtnTag_neutral1 1001
#define btnTag_Timer    1002
#define ASTag_More      1003

@interface MHGatewayNeutralViewController ()

@property (nonatomic, strong) MHDeviceGatewaySensorDoubleNeutral *deviceNeutral;
@property (nonatomic, strong) MHGatewayNeutralTimerSelectedViewController *swtichSelectedVC;

@property (nonatomic, assign) BOOL isLeftOn;
@property (nonatomic, assign) BOOL isRightOn;

@property (nonatomic, strong) NSArray *callbackBlockArr;

@property (nonatomic, strong) UIButton *leftBtn;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, strong) UILabel *leftName;
@property (nonatomic, strong) UILabel *rightName;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *leftLightView;
@property (nonatomic, strong) UIImageView *rightLightView;
@property (nonatomic, strong) UIImageView *leftHaloView;
@property (nonatomic, strong) UIImageView *rightHaloView;
@property (nonatomic, strong) UIImageView *lineView;

@property (nonatomic, strong) MHDeviceGatewaySensorLoopData *loopData;

@end

@implementation MHGatewayNeutralViewController {

    UIActionSheet* _actionSheet;
    MHWaveAnimation *_waveAnimation;
}

- (id)initWithDevice:(MHDevice *)device {
    if (self = [super initWithDevice:device]) {
        self.deviceNeutral = (MHDeviceGatewaySensorDoubleNeutral *)device;
        [self.deviceNeutral buildServices];
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isNavBarTranslucent = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [self updateCurrentStatus];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSArray *names = [self.deviceNeutral.name componentsSeparatedByString:@"/"];
    if (names.count > 1) {
        self.title = [NSString stringWithFormat:@"%@ / %@", names[0], names[1]];
    }
    else {
        self.title = self.deviceNeutral.name; 
    }
    
    [self loadStatus];

    XM_WS(weakself);
    _loopData = [[MHDeviceGatewaySensorLoopData alloc] init];
    _loopData.device = self.deviceNeutral;
    [_loopData startWatchingNewData:@"prop_ctrl_neutral" WithParams:@[ @"neutral_0", @"neutral_1" ]];
    _loopData.fetchNewDataCallBack = ^(id respObj){
        if([respObj isKindOfClass:[NSArray class]] &&
           [respObj count] > 1 &&
           [respObj[0] isKindOfClass:[NSString class]] &&
            [respObj[1] isKindOfClass:[NSString class]]
           ){
            
            weakself.deviceNeutral.neutral_0 = respObj[0];
            weakself.deviceNeutral.neutral_1 = respObj[1];
            [weakself.deviceNeutral updateServices];
            //左键
            if ([weakself.deviceNeutral.neutral_0 isEqualToString:@"disable"]) {
                weakself.leftBtn.enabled = NO;
            }
            else {
                weakself.leftBtn.enabled = YES;
                [weakself updateCurrentStatus];
            }
            //右键
            if ([weakself.deviceNeutral.neutral_1 isEqualToString:@"disable"]) {
                weakself.rightBtn.enabled = NO;
            }
            else {
                weakself.rightBtn.enabled = YES;
                [weakself updateCurrentStatus];
            }

        }
    };
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)buildSubviews {
    [super buildSubviews];
    //背景
    _bgView = [[UIView alloc] init];
    _bgView.backgroundColor = [MHColorUtils colorWithRGB:0x006fc5];
    [self.view addSubview:_bgView];
    
    //左键
    self.leftBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.leftBtn.tag = BtnTag_Neutral0;
    [self.leftBtn addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.leftBtn];
    
    self.leftLabel = [[UILabel alloc] init];
    self.leftLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.switcher",@"plugin_gateway","开关");
    self.leftLabel.font = [UIFont systemFontOfSize:14 * ScaleWidth];
    [self.leftLabel setTextColor:[MHColorUtils colorWithRGB:0x464646]];
    [self.leftLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.leftLabel];

    
    //右键
    self.rightBtn = [[UIButton alloc] init];
    self.rightBtn.tag = BtnTag_neutral1;
    [self.rightBtn addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.rightBtn];
    
    self.rightLabel = [[UILabel alloc] init];
    self.rightLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.switcher",@"plugin_gateway","开关");
    self.rightLabel.font = [UIFont systemFontOfSize:14 * ScaleWidth];
    [self.rightLabel setTextColor:[MHColorUtils colorWithRGB:0x464646]];
    [self.rightLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.rightLabel];

    //左边开启光晕
    self.leftHaloView = [[UIImageView alloc] init];
    self.leftHaloView.image = [UIImage imageNamed:@"lumi_neutral_on_bg"];
    [self.bgView addSubview:self.leftHaloView];
    //右边开启光晕
    self.rightHaloView = [[UIImageView alloc] init];
    self.rightHaloView.image = [UIImage imageNamed:@"lumi_neutral_on_bg"];
    [self.bgView addSubview:_rightHaloView];
    
    //左边灯具图片
    self.leftLightView = [[UIImageView alloc] init];
    self.leftLightView.image = self.isLeftOn ? [UIImage imageNamed:OpenLight] : [UIImage imageNamed:CloseLight];
    [self.bgView addSubview:self.leftLightView];
    
    self.leftName = [[UILabel alloc] init];
    self.leftName.font = [UIFont systemFontOfSize:14 * ScaleWidth];
    [self.leftName setTextColor:[UIColor whiteColor]];
    [self.leftName setTextAlignment:NSTextAlignmentCenter];
    [self.bgView addSubview:self.leftName];

    //右边灯具图片
    self.rightLightView = [[UIImageView alloc] init];
    self.rightLightView.image = self.isRightOn ? [UIImage imageNamed:OpenLight] : [UIImage imageNamed:CloseLight];
    [self.bgView addSubview:self.rightLightView];
    
    self.rightName = [[UILabel alloc] init];
    self.rightName.font = [UIFont systemFontOfSize:14 * ScaleWidth];
    [self.rightName setTextColor:[UIColor whiteColor]];
    [self.rightName setTextAlignment:NSTextAlignmentCenter];
    [self.bgView addSubview:self.rightName];

    //分割线
    self.lineView = [[UIImageView alloc] init];
    self.lineView.backgroundColor = [MHColorUtils colorWithRGB:0xffffff alpha:0.2];
    [self.bgView addSubview:self.lineView];
    
    _waveAnimation = [[MHWaveAnimation alloc] initWithFrame:CGRectZero];
    _waveAnimation.waveInterval = 0.5f;
    _waveAnimation.singleWaveScale = 1.5f;
    [self.view addSubview:_waveAnimation];

}

- (void)buildConstraints {
    [super buildConstraints];
        XM_WS(weakself);

    CGFloat bgViewHeight = 467 * ScaleHeight;
    
    CGFloat haloWidth = 184 * ScaleWidth;
    CGFloat haloHeight = 298 * ScaleHeight;
    
    CGFloat logoHeight = 104 * ScaleHeight;
    CGFloat logoWidth = 56 * ScaleWidth;
    
    CGFloat btnSize = 57 * ScaleWidth;
    CGFloat bottomSpacing = 70 * ScaleHeight;
    
    CGFloat lineHeight = 467 * ScaleHeight - 70;
    
    
    CGFloat labTitleSpacing = 15 * ScaleHeight;
    CGFloat logoNameSpacing = 90 * ScaleHeight;
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.view);
        make.height.mas_equalTo(bgViewHeight);
        make.width.mas_equalTo(WIN_WIDTH);
        make.centerX.equalTo(weakself.view);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.bgView);
        make.top.equalTo(weakself.bgView).with.offset(64);
        make.size.mas_equalTo(CGSizeMake(1, lineHeight));
    }];
    
    [self.leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakself.view).with.offset(-bottomSpacing);
        make.left.equalTo(weakself.view).with.offset(WIN_WIDTH / 4 - btnSize / 2);
        make.size.mas_equalTo(CGSizeMake(btnSize, btnSize));
    }];
    
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.leftBtn.mas_bottom).with.offset(labTitleSpacing);
        make.centerX.equalTo(weakself.leftBtn);
    }];

    
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakself.view).with.offset(-bottomSpacing);
        make.right.equalTo(weakself.view).with.offset(-WIN_WIDTH / 4 + btnSize / 2);
        make.size.mas_equalTo(CGSizeMake(btnSize, btnSize));
    }];
    
    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.rightBtn.mas_bottom).with.offset(labTitleSpacing);
        make.centerX.equalTo(weakself.rightBtn);
    }];

    
    
    [self.leftLightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakself.bgView);
        make.left.equalTo(weakself.bgView).with.offset(WIN_WIDTH / 4 - logoWidth / 2);
        make.size.mas_equalTo(CGSizeMake(logoWidth, logoHeight));
    }];
    
    [self.leftName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakself.bgView).with.offset(-logoNameSpacing);
        make.centerX.equalTo(weakself.leftLightView);
    }];

    [self.rightLightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakself.bgView);
        make.right.equalTo(weakself.view).with.offset(-WIN_WIDTH / 4 + logoWidth / 2);
        make.size.mas_equalTo(CGSizeMake(logoWidth, logoHeight));
    }];
    
    [self.rightName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakself.bgView).with.offset(-logoNameSpacing);
        make.centerX.equalTo(weakself.rightLightView);
    }];

    
    [self.leftHaloView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakself.bgView);
        make.left.equalTo(weakself.bgView).with.offset(WIN_WIDTH / 4 - haloWidth / 2);
        make.size.mas_equalTo(CGSizeMake(haloWidth, haloHeight));
    }];
    [self.rightHaloView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakself.view).with.offset(-WIN_WIDTH / 4 + haloWidth / 2);
        make.centerY.equalTo(weakself.bgView);
        make.size.mas_equalTo(CGSizeMake(haloWidth, haloHeight));
    }];
}


- (void)loadStatus {
    XM_WS(weakself);
    [self.deviceNeutral getPropertyWithSuccess:^(id obj) {
        [weakself.deviceNeutral updateServices];
        NSLog(@"%@", obj);
        if ([weakself.deviceNeutral.neutral_0 isEqualToString:@"disable"]) {
            weakself.leftBtn.enabled = NO;
        }
        else {
            weakself.leftBtn.enabled = YES;
            [weakself updateCurrentStatus];
        }
        if ([weakself.deviceNeutral.neutral_1 isEqualToString:@"disable"]) {
            weakself.rightBtn.enabled = NO;
        }
        else {
            weakself.rightBtn.enabled = YES;
            [weakself updateCurrentStatus];
        }

    } andFailure:^(NSError *error) {
        weakself.rightBtn.enabled = NO;
        weakself.leftBtn.enabled = NO;
    }];
}


#pragma mark - 获取图标
- (void)fetchIcon {
    XM_WS(weakself);
    if(!self.deviceNeutral.services.count){
        [self.deviceNeutral buildServices];
    }
    if(self.deviceNeutral.services.count){
        for (MHDeviceGatewayBaseService *service in self.deviceNeutral.services) {
            NSLog(@"服务的编号%d", service.serviceId);
            NSString *iconID = [[MHLumiChangeIconManager sharedInstance] restorePdataByService:service
                                                                         withCompletionHandler:^(id result, NSError *error) {
                if(result)[weakself fetchIconWithId:result service:service];
            }];
            
            [self fetchIconWithId:iconID service:service];
        }
    }
}

- (void)fetchIconWithId:(NSString *)iconId service:(MHDeviceGatewayBaseService *)service {
    XM_WS(weakself);
    if(!iconId) {
        [self defaultIcon:service.isOpen withServiceId:service.serviceId];
    }
    else {
        NSString *iconUrl = nil;
        service.serviceIconId = iconId;
        iconUrl = [service fetchIconNameWithHeader:@"lumi"];
        if([[NSFileManager defaultManager] fileExistsAtPath:iconUrl]) {
            if(service.serviceId) [_rightLightView setImage:[UIImage imageWithContentsOfFile:iconUrl]];
            else [_leftLightView setImage:[UIImage imageWithContentsOfFile:iconUrl]];
        }
        else{
            [self defaultIcon:service.isOpen withServiceId:service.serviceId];
            [[MHLumiChangeIconManager sharedInstance] fetchIconUrlsByIconId:iconId
                                                                withService:service
                                                          completionHandler:^(id result,NSError *error){
                                                              if(!error)[weakself fetchIcon];
                                                          }];
        }
    }
}

- (void)defaultIcon:(BOOL)isOpen withServiceId:(int)serviceId {
    if(isOpen){
        if(serviceId) [_rightLightView setImage:[UIImage imageNamed:OpenLight]];
        else [_leftLightView setImage:[UIImage imageNamed:OpenLight]];
    }
    else{
        if(serviceId) [_rightLightView setImage:[UIImage imageNamed:CloseLight]];
        else [_leftLightView setImage:[UIImage imageNamed:CloseLight]];
    }
}

#pragma mark - 波纹动画
- (void)setWaveAnim:(BOOL)anim forBtn:(UIButton*)btn {
    BOOL isOpen = [btn isEqual:self.leftBtn] ? self.isLeftOn : self.isRightOn;
    if (isOpen) {
        _waveAnimation.waveColor = [MHColorUtils colorWithRGB:0x888888];
    }
    else {
        _waveAnimation.waveColor = [MHColorUtils colorWithRGB:0x006fc5];
    }
    [_waveAnimation setFrame:[btn frame]];
    if (anim){
        [_waveAnimation startAnimation];
    }
    else{
        [_waveAnimation stopAnimation];
    }
}

#pragma mark - 控制
- (void)onButtonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case BtnTag_Neutral0: {
            self.isLeftOn = !self.isLeftOn;
            [self setWaveAnim:YES forBtn:sender];
            [self onNeutral:@"neutral_0" andSender:sender];
            break;
        }
        case BtnTag_neutral1: {
            self.isRightOn = !self.isRightOn;
            [self setWaveAnim:YES forBtn:sender];
            [self onNeutral:@"neutral_1" andSender:sender];
            break;
        }
        default:
            break;
    }
    [self gw_clickMethodCountWithStatType:@"onButtonClicked:"];
}

- (void)onNeutral:(NSString *)neutral andSender:(UIButton *)sender {
    XM_WS(weakself);
    NSUInteger index = [neutral isEqualToString:@"neutral_1"];
    sender.enabled = NO;
    [(MHDeviceGatewayBaseService *)weakself.deviceNeutral.services[index] serviceMethod];
    [(MHDeviceGatewayBaseService *)weakself.deviceNeutral.services[index] setServiceMethodSuccess:^(id obj) {
        NSLog(@"%@", obj);
        if ([index ? weakself.deviceNeutral.neutral_1 : weakself.deviceNeutral.neutral_0 isEqualToString:@"disable"]) {
//            index ? weakself.isRightOn = !weakself.isRightOn : weakself.isLeftOn = !weakself.isLeftOn;
            if (index) {
                weakself.isRightOn = !weakself.isRightOn;
            }
            else {
                weakself.isLeftOn = !weakself.isLeftOn;
            }
        }
        else {
            [weakself updateCurrentStatusWithNeutral:neutral];
        }
        [weakself setWaveAnim:NO forBtn:sender];
        
    }];
    [(MHDeviceGatewayBaseService *)weakself.deviceNeutral.services[index] setServiceMethodFailure:^(NSError *error) {
        sender.enabled = YES;
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"send.failed",@"plugin_gateway", nil) duration:1.5f modal:YES];
        [weakself setWaveAnim:NO forBtn:sender];
    }];

}

#pragma mark - 更新UI
- (void)updateCurrentStatusWithNeutral:(NSString *)neutral {
    if ([neutral isEqualToString:@"neutral_0"]) {
        self.isLeftOn = [self.deviceNeutral.neutral_0 isEqualToString:@"on"];
        self.leftHaloView.hidden = !self.isLeftOn;
        self.leftBtn.enabled = YES;
        [self.leftBtn setBackgroundImage:[UIImage imageNamed:self.isLeftOn ? OpenBtn : CloseBtn] forState:UIControlStateNormal];
        MHDeviceGatewayBaseService *service = self.deviceNeutral.services[0];
        service.isOpen = self.isLeftOn;
        self.leftName.text = self.isLeftOn ? NSLocalizedStringFromTable(@"mydevice.gateway.sensor.singleNeutral.isOn",@"plugin_gateway", "已开启") : NSLocalizedStringFromTable(@"mydevice.gateway.sensor.singleNeutral.isOff",@"plugin_gateway", "已关闭");
    }
    else {
        self.isRightOn = [self.deviceNeutral.neutral_1 isEqualToString:@"on"];
        self.rightHaloView.hidden = !self.isRightOn;
        self.rightBtn.enabled = YES;
        [self.rightBtn setBackgroundImage:[UIImage imageNamed:self.isRightOn ? OpenBtn : CloseBtn] forState:UIControlStateNormal];
        MHDeviceGatewayBaseService *service = self.deviceNeutral.services[1];
        service.isOpen = self.isRightOn;
        self.rightName.text = self.isRightOn ? NSLocalizedStringFromTable(@"mydevice.gateway.sensor.singleNeutral.isOn",@"plugin_gateway", "已开启") : NSLocalizedStringFromTable(@"mydevice.gateway.sensor.singleNeutral.isOff",@"plugin_gateway", "已关闭");
    }
    [self fetchIcon];
}

//第一次进入更新开关状态
- (void)updateCurrentStatus {
    self.isLeftOn = [self.deviceNeutral.neutral_0 isEqualToString:@"on"];
    self.isRightOn = [self.deviceNeutral.neutral_1 isEqualToString:@"on"];
    self.leftHaloView.hidden = !self.isLeftOn;
    NSLog(@"左%@", self.deviceNeutral.neutral_0);
    NSLog(@"右边%@", self.deviceNeutral.neutral_1);

    [self.leftBtn setBackgroundImage:[UIImage imageNamed:self.isLeftOn ? OpenBtn : CloseBtn] forState:UIControlStateNormal];
    
    self.rightHaloView.hidden = !self.isRightOn;
    [self.rightBtn setBackgroundImage:[UIImage imageNamed:self.isRightOn ? OpenBtn : CloseBtn] forState:UIControlStateNormal];
    self.leftName.text = self.isLeftOn ? NSLocalizedStringFromTable(@"mydevice.gateway.sensor.singleNeutral.isOn",@"plugin_gateway", "已开启") : NSLocalizedStringFromTable(@"mydevice.gateway.sensor.singleNeutral.isOff",@"plugin_gateway", "已关闭");
    self.rightName.text = self.isRightOn ? NSLocalizedStringFromTable(@"mydevice.gateway.sensor.singleNeutral.isOn",@"plugin_gateway", "已开启") : NSLocalizedStringFromTable(@"mydevice.gateway.sensor.singleNeutral.isOff",@"plugin_gateway", "已关闭");
    [self fetchIcon];
}

#pragma mark - 定时
- (void)openTimerView {
    self.swtichSelectedVC = [[MHGatewayNeutralTimerSelectedViewController alloc] initWithDevice:self.deviceNeutral];
    [self.navigationController pushViewController:self.swtichSelectedVC animated:YES];
}

#pragma mark - 设备控制相关
- (void)onMore:(id)sender {
    NSString *strScene = NSLocalizedStringFromTable(@"profile.entry.triggerAction",@"plugin_gateway","自动化");
    NSString *logoChange = NSLocalizedStringFromTable(@"mydevice.actionsheet.changelogo",@"plugin_gateway","更换图标");
    NSString *strTimer = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.timer",@"plugin_gateway","定时");
    NSString* strChangeTitle = NSLocalizedStringFromTable(@"mydevice.actionsheet.changename",@"plugin_gateway","修改设备名称");
    
     NSString* strShowMode = _deviceNeutral.showMode ? NSLocalizedStringFromTable(@"mydevice.gateway.delsub.rmvlist",@"plugin_gateway","撤销显示") : NSLocalizedStringFromTable(@"mydevice.gateway.delsub.addlist",@"plugin_gateway","添加显示");
    NSString *strFAQ = NSLocalizedStringFromTable(@"mydevice.gateway.about.freFAQ",@"plugin_gateway","常见问题");
    NSString* strFeedback = NSLocalizedStringFromTable(@"mydevice.actionsheet.feedback",@"plugin_gateway","反馈");
    
    NSArray *titlesArray = @[ strScene, logoChange, strTimer, strChangeTitle, strShowMode, strFeedback ];
    
    XM_WS(weakself);
    [[MHPromptKit shareInstance] showPromptInView:self.view withHandler:^(NSInteger buttonIndex) {
        switch (buttonIndex) {
            case 0: {
                //取消
                break;
            }
            case 1: {
                //自动化
                [weakself onAddScene];
                [weakself gw_clickMethodCountWithStatType:@"actionSheetAddScene"];
                break;
            }
            case 2: {
                //单火图标
                [weakself chooseLogo];
                [weakself gw_clickMethodCountWithStatType:@"actionSheetChangeLogo"];

                break;
            }
            case 3: {
                //定时
                [weakself openTimerView];
                [weakself gw_clickMethodCountWithStatType:@"actionSheetOpenTimerView"];

                break;
            }
            case 4: {
                //修改设备名称
                [weakself onchangeName];
                [weakself gw_clickMethodCountWithStatType:@"actionSheetChangeName"];

                break;
            }
            case 5: {
                // 设置列表显示
                [weakself.deviceNeutral setShowMode:(int)!weakself.deviceNeutral.showMode success:^(id obj) {
                    
                } failure:^(NSError *v) {
                    [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"setting.failed", @"plugin_gateway","") duration:1.f modal:YES];
                }];
                [weakself gw_clickMethodCountWithStatType:@"actionSheetShowMode"];
                break;
            }
                
            case 6: {
                //反馈
                [weakself onFeedback];
                [weakself gw_clickMethodCountWithStatType:@"actionSheetFeedback"];

                break;
            }
                
            default:
                break;
        }
        //            case 6: {
        //                //常见问题
        //                [weakself openFAQ:[[weakself.deviceHt class] getFAQUrl]];
        //                break;
        //            }
        
    } withTitle:NSLocalizedStringFromTable(@"mydevice.actionsheet.more",@"plugin_gateway","更多") cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway",@"取消") destructiveButtonTitle:nil otherButtonTitlesArray:titlesArray];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 自动化
- (void)onAddScene {
    MHGatewaySensorViewController *sceneVC = [[MHGatewaySensorViewController alloc] initWithDevice:self.deviceNeutral];
    sceneVC.isHasMore = NO;
    sceneVC.isHasShare = NO;
    [self.navigationController pushViewController:sceneVC animated:YES];
}

#pragma mark - 重命名
- (void)onchangeName {
    MHGatewayNeutralChangeNameViewController *changeNameVC = [[MHGatewayNeutralChangeNameViewController alloc] initWithDevice:self.deviceNeutral];
    [self.navigationController pushViewController:changeNameVC animated:YES];
}

#pragma mark - 选择图标
-(void)chooseLogo{
    XM_WS(weakself);
    MHGatewayNeutralLogoSelectedViewController *logoChoose = [[MHGatewayNeutralLogoSelectedViewController alloc] initWithDevice:_deviceNeutral];
    if(self.deviceNeutral.services.count){
        logoChoose.service0 = weakself.deviceNeutral.services[0];
        logoChoose.service1 = weakself.deviceNeutral.services[1];
    }
    [self.navigationController pushViewController:logoChoose animated:YES];
}

@end
