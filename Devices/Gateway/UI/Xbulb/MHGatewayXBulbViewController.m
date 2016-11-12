//
//  MHGatewayXBulbViewController.m
//  MiHome
//
//  Created by Lynn on 8/3/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayXBulbViewController.h"
#import "MHWaveAnimation.h"
#import "XBCircularSlider.h"
#import "MHDeviceGatewaySensorLoopData.h"

#define ASTag_More 1001

@interface MHGatewayXBulbViewController ()
@property (nonatomic,assign) int brightness;
@end

@implementation MHGatewayXBulbViewController
{
    MHWaveAnimation *                   _waveAnimation; //波纹动画
    
    UIView *                            _controlView;

    XBCircularSlider *                  _slider;
    
    UILabel *                           _percentLabel;

    UIButton *                          _minusBtn;
    UIButton *                          _plusBtn;
    UIButton *                          _btnPowerSetting;
    
    UIImageView *                       _xbulbImage;
    
    BOOL                                _isLightOn;
    UILabel *                           _brightLabel;
    
    MHDeviceGatewaySensorLoopData *     _looper;
    UIActionSheet *                     _actionSheet;
}

-(void)setBrightness:(int)brightness
{
    _brightness = brightness;
    
    [_brightLabel setText:[NSString stringWithFormat:@"%d",brightness]];
    _slider.initialValue = brightness;
    if(brightness) {
        [_btnPowerSetting setSelected:YES];
        _isLightOn = YES;
        _xbulbImage.alpha = brightness / 100.0;
        if(brightness < 10.0) _xbulbImage.alpha = 10.0 / 100.0;
    }
    else{
        [_btnPowerSetting setSelected:NO];
        _isLightOn = NO;
        _xbulbImage.alpha = 5.0 / 100.0;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isNavBarTranslucent = YES;
    
    UIImage *backgroundImage = [UIImage imageNamed:@"gateway_xbulb_bg"];
    UIImageView *myImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [myImageView setImage:[backgroundImage stretchableImageWithLeftCapWidth:3 topCapHeight:3]];
    [self.view addSubview:myImageView];
    [self.view sendSubviewToBack:myImageView];
    
    self.brightness = (int)self.device.bright ? (int)self.device.bright : 0 ;
    
    __weak typeof(self) weakSelf = self;
    _slider = [[XBCircularSlider alloc] initWithFrame:CGRectMake(0, 0, XB_SLIDER_SIZE, XB_SLIDER_SIZE)];
    [_slider addTarget:self action:@selector(updateSlideValue:) forControlEvents:UIControlEventValueChanged];
    _slider.initialValue = (int)self.device.bright;
    _slider.callbackBlock = ^(int backValue){
        //此处设置灯泡亮度，RPC
        [weakSelf setXBulbBrightness:backValue];
    };
    [_controlView addSubview:_slider];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.device addObserver:self forKeyPath:@"bright" options:NSKeyValueObservingOptionNew context:nil];
    
    //循环检查灯亮度 -- 别处更改此灯亮度
    _looper = [[MHDeviceGatewaySensorLoopData alloc] init];
    _looper.device = self.device;
    [_looper startWatchingNewData:@"bright" WithParams:@"power"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.device removeObserver:self forKeyPath:@"bright"];
    _looper = nil;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"bright"] && object == self.device) {
        self.brightness = (int)self.device.bright;
    }
}

-(void)setXBulbBrightness:(int)backValue
{
    [self.device setDeviceBrightness:^(id obj){
    } failure:^(NSError *error){
         NSLog(@"%s error = %@" ,__func__,error);
    } propvalue:backValue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)buildSubviews
{
    [super buildSubviews];
    
    _waveAnimation = [[MHWaveAnimation alloc] initWithFrame:CGRectZero];
    _waveAnimation.waveInterval = 0.5f;
    _waveAnimation.singleWaveScale = 1.5f;
    [self.view addSubview:_waveAnimation];
    
    //滑块控件背景布
    _controlView = [[UIView alloc] init];
//    _controlView.backgroundColor = [UIColor lightTextColor];
    _controlView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_controlView];

    //bulb 图片
    _xbulbImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gateway_xbulb_light"]];
    _xbulbImage.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_xbulbImage];
    
    //加减按钮
    _minusBtn = [[UIButton alloc] init];
    [_minusBtn setImage:[UIImage imageNamed:@"gateway_xbulb_jian"] forState:UIControlStateNormal];
    [_minusBtn addTarget:self action:@selector(minusBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _minusBtn.translatesAutoresizingMaskIntoConstraints =NO;
    [self.view addSubview:_minusBtn];
    
    _plusBtn = [[UIButton alloc] init];
    [_plusBtn setImage:[UIImage imageNamed:@"gateway_xbulb_jia"] forState:UIControlStateNormal];
    [_plusBtn addTarget:self action:@selector(plusBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _plusBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_plusBtn];
    
    //百分数字
    CGFloat size_font = 105./375.*XB_SLIDER_SIZE;
    _brightLabel = [[UILabel alloc] init];
    [_brightLabel setText:@"100"];
    [_brightLabel setFont:[UIFont fontWithName:@"DINCond-Regular" size:size_font]];
    [_brightLabel setTextColor:[UIColor whiteColor]];
    [_brightLabel sizeToFit];
    [_brightLabel setTextAlignment:NSTextAlignmentRight];
    _brightLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_brightLabel];
    
    _percentLabel = [[UILabel alloc] init];
    [_percentLabel setText:@"%"];
    [_percentLabel setFont:[UIFont fontWithName:@"DINCond-Regular" size:size_font/2]];
    [_percentLabel setTextColor:[UIColor whiteColor]];
    [_percentLabel sizeToFit];
    [_percentLabel setTextAlignment:NSTextAlignmentLeft];
    _percentLabel.translatesAutoresizingMaskIntoConstraints =NO;
    [self.view addSubview:_percentLabel];
    
    // 电源按钮
    _btnPowerSetting = [[UIButton alloc] init];
    [_btnPowerSetting setBackgroundImage:[UIImage imageNamed:@"gateway_xbulb_kg_off"] forState:UIControlStateNormal];
    [_btnPowerSetting setBackgroundImage:[UIImage imageNamed:@"gateway_xbulb_kg"] forState:UIControlStateSelected];
    [_btnPowerSetting addTarget:self action:@selector(onPowerSettingClicked:) forControlEvents:UIControlEventTouchUpInside];
    _btnPowerSetting.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_btnPowerSetting];
}

-(void)buildConstraints
{
    [super buildConstraints];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_controlView,_minusBtn,_plusBtn,_brightLabel,_percentLabel,_xbulbImage);
    NSDictionary *metrics = @{@"hPadding":@(XB_RADIUSOFFSIZE),@"vPadding":@(175./667.*XB_SCREEN_HEIGHT)};
    
    CGFloat sizeWidth = XB_SLIDER_SIZE - 2 * XB_RADIUSOFFSIZE;
    NSString *vfl_view_h = [NSString stringWithFormat:@"H:|-hPadding-[_controlView(==%f)]|",sizeWidth];
    NSArray *constraint_view_h = [NSLayoutConstraint constraintsWithVisualFormat:vfl_view_h options:NSLayoutFormatAlignAllCenterX metrics:metrics views:views];
    NSString *vfl_view_v = [NSString stringWithFormat:@"V:|-vPadding-[_controlView(==%f)]|",sizeWidth];
    NSArray *constraint_view_v = [NSLayoutConstraint constraintsWithVisualFormat:vfl_view_v options:0 metrics:metrics views:views];
    NSLayoutConstraint *constraint_ctl_X = [NSLayoutConstraint constraintWithItem:_controlView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    
    NSLayoutConstraint *lbContraint_v = [NSLayoutConstraint constraintWithItem:_brightLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_controlView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:10];
    NSLayoutConstraint *lbContraint_h = [NSLayoutConstraint constraintWithItem:_brightLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:-20];
    
    NSLayoutConstraint *lbContraint_pct_v = [NSLayoutConstraint constraintWithItem:_percentLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_brightLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10];
    NSLayoutConstraint *lbContraint_pct_h = [NSLayoutConstraint constraintWithItem:_percentLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_brightLabel attribute:NSLayoutAttributeRight multiplier:1.0 constant:1];
    
    NSLayoutConstraint *constraint_img_v = [NSLayoutConstraint constraintWithItem:_xbulbImage attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_controlView attribute:NSLayoutAttributeTop multiplier:1.0 constant:43./667.*XB_SCREEN_HEIGHT];
    NSLayoutConstraint *constraint_img_h = [NSLayoutConstraint constraintWithItem:_xbulbImage attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_controlView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];

    NSLayoutConstraint *btnMinConstraint_h = [NSLayoutConstraint constraintWithItem:_minusBtn attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_controlView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:50.0];
    NSLayoutConstraint *btnMinConstraint_v = [NSLayoutConstraint constraintWithItem:_minusBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_controlView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-40.0];

    NSLayoutConstraint *btnPluConstraint_h = [NSLayoutConstraint constraintWithItem:_plusBtn attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_controlView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-50];
    NSLayoutConstraint *btnPluConstraint_v = [NSLayoutConstraint constraintWithItem:_plusBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_controlView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-40.0];
    
    NSLayoutConstraint *constrain_pwBtn = [NSLayoutConstraint constraintWithItem:_btnPowerSetting attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    NSLayoutConstraint *constrain_pwBtn_v = [NSLayoutConstraint constraintWithItem:_btnPowerSetting attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-50];
    
    [self.view addConstraint:constrain_pwBtn];
    [self.view addConstraint:constrain_pwBtn_v];
    
    [self.view addConstraints:constraint_view_h];
    [self.view addConstraints:constraint_view_v];
    [self.view addConstraint:constraint_ctl_X];
    
    [self.view addConstraint:constraint_img_h];
    [self.view addConstraint:constraint_img_v];
    
    [self.view addConstraint:lbContraint_v];
    [self.view addConstraint:lbContraint_pct_v];
    [self.view addConstraint:lbContraint_h];
    [self.view addConstraint:lbContraint_pct_h];
    
    [self.view addConstraint:btnMinConstraint_h];
    [self.view addConstraint:btnMinConstraint_v];
    
    [self.view addConstraint:btnPluConstraint_h];
    [self.view addConstraint:btnPluConstraint_v];
}

#pragma mark -- 滑块控制
-(void)updateSlideValue:(XBCircularSlider *)sender
{
    self.brightness = sender.callBackResult;
}

#pragma mark -- 开关灯控制
-(void)onPowerSettingClicked:(id)sender
{
    [self setWaveAnim:YES forBtn:_btnPowerSetting];
    [self setPowerStatus:!_isLightOn sender:sender];
}

-(void)minusBtnClicked:(id)sender
{
    if(self.brightness != 0){
        if(self.brightness - 10 > 0)
            self.brightness = self.brightness - 10;
        else self.brightness = 1;
        [self setXBulbBrightness:self.brightness];
    }
}

-(void)plusBtnClicked:(id)sender
{
    if(self.brightness + 10 < 100)
        self.brightness = self.brightness + 10;
    else self.brightness = 100;
    [self setXBulbBrightness:self.brightness];
}

-(void)setPowerStatus:(BOOL)isOn sender:(id)sender
{
    __weak typeof(self) weakSelf = self;
    
    [self.device setToggleLight:^(id obj){
        [weakSelf setWaveAnim:NO forBtn:sender];
        
    } failure:^(NSError *error){
        NSLog(@"%s error = %@" ,__func__,error);
    }];
}

#pragma mark -- 设置的动画
- (void)setWaveAnim:(BOOL)anim forBtn:(UIButton*)btn
{
    if ([btn isSelected]) {
        _waveAnimation.waveColor = [MHColorUtils colorWithRGB:0x3FB57D];
    }
    else {
        _waveAnimation.waveColor = [MHColorUtils colorWithRGB:0x888888];
    }
    [_waveAnimation setFrame:[btn frame]];
    
    if (anim){
        [_waveAnimation startAnimation];
    }
    else{
        [_waveAnimation stopAnimation];
    }
}

#pragma mark - 设备控制相关
- (void)onMore:(id)sender {
    NSString* strChangeTitle = [NSString stringWithFormat:@"%@", NSLocalizedStringFromTable(@"mydevice.actionsheet.changename",@"plugin_gateway","修改设备名称")];
    NSString* strFeedback = NSLocalizedStringFromTable(@"mydevice.actionsheet.feedback",@"plugin_gateway","反馈");
    
    _actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"mydevice.actionsheet.more",@"plugin_gateway","更多")
                                               delegate:self
                                      cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway",@"取消")
                                 destructiveButtonTitle:nil
                                      otherButtonTitles:nil];
    [_actionSheet addButtonWithTitle:strChangeTitle];
    [_actionSheet addButtonWithTitle:strFeedback];
    _actionSheet.tag = ASTag_More;
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    if ([window.subviews containsObject:self.view]) {
        [_actionSheet showInView:self.view];
    } else {
        [_actionSheet showInView:window];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            //取消
            break;
        }
        case 1: {
            //修改设备名称
            [self deviceChangeName];
            break;
        }
        case 2: {
            //反馈
            [self onFeedback];
            break;
        }
        default:
            break;
    }
}

@end
