//
//  MHGatewayAlarmTriggerViewController.m
//  MiHome
//
//  Created by Woody on 15/4/9.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import "MHGatewayAlarmTriggerViewController.h"

@interface MHGatewayAlarmTriggerViewController()
@property (nonatomic, retain) UIButton* btnSensor;
@end

@implementation MHGatewayAlarmTriggerViewController {
    MHDevice*                  _fromDevice;
    MHDeviceGateway*           _toDevice;
    NSString*                  _event;
    NSString*                  _time;

    UILabel*        _labelTriggerTime;
    UILabel*        _labelTriggerSensorName;
    
    UIButton*       _btnDone;
    UILabel*        _labelDone;
}

- (id)initWithAlarmFromSensorId:(NSString* )sid toDevice:(MHDeviceGateway*)device event:(NSString* )event time:(NSDate *)time {
    if (self = [super init]) {
        _toDevice = device;
        _event = event;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM/dd HH:mm:ss"];
        _time = [dateFormat stringFromDate:time];
        _fromDevice = [_toDevice getSubDevice:sid];
    }
    return self;
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isNavBarTranslucent = YES;
    
    [self performSelector:@selector(startAnimation) withObject:self afterDelay:1.0f];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
}

- (void)buildSubviews {
    [super buildSubviews];
    self.isTabBarHidden = YES;
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.alarm.trigger.title",@"plugin_gateway","触发警报");
    self.view.backgroundColor = [MHColorUtils colorWithRGB:0x260d0c];
    
    
    _btnSensor = [[UIButton alloc] init];
    NSString* sensorImageName = nil;
    if (_fromDevice.deviceType == MHDeviceType_GatewaySensorMotion) {
        sensorImageName = @"gateway_sensor_trigger.motion";
    } else if (_fromDevice.deviceType == MHDeviceType_GatewaySensorMagnet) {
        sensorImageName = @"gateway_sensor_trigger.magnet";
    } else if (_fromDevice.deviceType == MHDeviceType_GatewaySensorSwitch) {
        sensorImageName = @"gateway_sensor_trigger.switch";
    } else if (_fromDevice.deviceType == MHDeviceType_GatewaySensorCube) {
        sensorImageName = @"gateway_sensor_trigger.cube";
    } else {
        sensorImageName = @"gateway_sensor_trigger.motion";
    }
    [_btnSensor setBackgroundImage:[UIImage imageNamed:sensorImageName] forState:UIControlStateNormal];
    _btnSensor.translatesAutoresizingMaskIntoConstraints = NO;
    [_btnSensor addTarget:self action:@selector(onSensorClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnSensor];
    
    _labelTriggerTime = [[UILabel alloc] init];
    _labelTriggerTime.font = [UIFont systemFontOfSize:11];
    _labelTriggerTime.textColor = [MHColorUtils colorWithRGB:0xffffff alpha:0.4];
    _labelTriggerTime.text = _time;
    _labelTriggerTime.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_labelTriggerTime];
    
    _labelTriggerSensorName = [[UILabel alloc] init];
    _labelTriggerSensorName.font = [UIFont systemFontOfSize:11];
    _labelTriggerSensorName.textColor = [MHColorUtils colorWithRGB:0xffffff alpha:0.4];
    _labelTriggerSensorName.text = [NSString stringWithFormat:@"%@%@", _fromDevice.name, NSLocalizedStringFromTable(@"mydevice.gateway.alarm.trigger.triggered",@"plugin_gateway","被触发")];
    _labelTriggerSensorName.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_labelTriggerSensorName];
    
    _btnDone = [[UIButton alloc] init];
    [_btnDone setBackgroundImage:[UIImage imageNamed:@"gateway_alarm_iknow"] forState:UIControlStateNormal];
    _btnDone.translatesAutoresizingMaskIntoConstraints = NO;
    [_btnDone addTarget:self action:@selector(onDone:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnDone];
    
    _labelDone = [[UILabel alloc] init];
    _labelDone.font = [UIFont systemFontOfSize:11];
    _labelDone.textColor = [MHColorUtils colorWithRGB:0xffffff alpha:0.4];
    _labelDone.text = NSLocalizedStringFromTable(@"iknow",@"plugin_gateway","知道了");
    _labelDone.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_labelDone];
}

- (void)buildConstraints {
    [super buildConstraints];
    
    CGFloat scaleHeight = [UIScreen mainScreen].bounds.size.height / 568.f;
//    CGFloat scaleWidth = [UIScreen mainScreen].bounds.size.height / 320.f;
    CGFloat vLeadSpacing = 187 * scaleHeight;
    CGFloat vSpacing1 = 10 * scaleHeight;
    CGFloat vSpacing2 = 3 * scaleHeight;
    CGFloat vSpacing3 = 222 * scaleHeight;
    CGFloat vSpacing4 = 6 * scaleHeight;
    NSDictionary* metrics = @{@"vLeadSpacing" : @(vLeadSpacing),
                              @"vSpacing1" : @(vSpacing1),
                              @"vSpacing2" : @(vSpacing2),
                              @"vSpacing3" : @(vSpacing3),
                              @"vSpacing4" : @(vSpacing4)};
    NSDictionary* views = @{@"sensor" : _btnSensor,
                            @"time" : _labelTriggerTime,
                            @"name" : _labelTriggerSensorName,
                            @"btnDone" : _btnDone,
                            @"labelDone" : _labelDone};
    NSLayoutConstraint* sensorCenterX = [NSLayoutConstraint constraintWithItem:_btnSensor attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    NSLayoutConstraint* timeCenterX = [NSLayoutConstraint constraintWithItem:_labelTriggerTime attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    NSLayoutConstraint* nameCenterX = [NSLayoutConstraint constraintWithItem:_labelTriggerSensorName attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    NSLayoutConstraint* doneCenterX = [NSLayoutConstraint constraintWithItem:_btnDone attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    NSLayoutConstraint* labelDoneCenterX = [NSLayoutConstraint constraintWithItem:_labelDone attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    
    NSLayoutConstraint* sensorTop = [NSLayoutConstraint constraintWithItem:_btnSensor attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:vLeadSpacing];
    NSLayoutConstraint* timeTop = [NSLayoutConstraint constraintWithItem:_labelTriggerTime attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_btnSensor attribute:NSLayoutAttributeBottom multiplier:1.0 constant:vSpacing1];
    NSLayoutConstraint* nameTop = [NSLayoutConstraint constraintWithItem:_labelTriggerSensorName attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_labelTriggerTime attribute:NSLayoutAttributeBottom multiplier:1.0 constant:vSpacing2];
    NSLayoutConstraint* doneTop = [NSLayoutConstraint constraintWithItem:_btnDone attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_labelTriggerSensorName attribute:NSLayoutAttributeBottom multiplier:1.0 constant:vSpacing3];
        NSLayoutConstraint* labelDoneTop = [NSLayoutConstraint constraintWithItem:_labelDone attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_btnDone attribute:NSLayoutAttributeBottom multiplier:1.0 constant:vSpacing4];
    
    [self.view addConstraint:sensorCenterX];
    [self.view addConstraint:timeCenterX];
    [self.view addConstraint:nameCenterX];
    [self.view addConstraint:doneCenterX];
    [self.view addConstraint:labelDoneCenterX];
    [self.view addConstraint:sensorTop];
    [self.view addConstraint:timeTop];
    [self.view addConstraint:nameTop];
    [self.view addConstraint:doneTop];
    [self.view addConstraint:labelDoneTop];
}

- (void)startAnimation {
    
    static NSInteger index = 0;
    
    index++;
    
    NSInteger delay = 0.025f;
    if (index % 4 == 0) {
        delay = 1.5f;
    }
    
    CGRect frame = _btnSensor.frame;
    CGRect offsetFrame = CGRectOffset(frame, 10, -10);
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.05f animations:^{
        [weakSelf.btnSensor setFrame:offsetFrame];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.05f animations:^{
            [weakSelf.btnSensor setFrame:frame];
        } completion:^(BOOL finished) {
            [self performSelector:@selector(startAnimation) withObject:self afterDelay:delay];
        }];
    }];
}

- (void)onSensorClick:(id)sender {
    
}

- (void)onDone:(id)sender {
    [_toDevice disAlarmWithSuccess:nil failure:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
