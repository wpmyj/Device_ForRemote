//
//  MHGatewayNatgasSelfTestViewController.m
//  MiHome
//
//  Created by ayanami on 16/7/6.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayNatgasSelfTestViewController.h"
#import "CountTimerProgressView.h"

#define CancelButtonHeight 46

@interface MHGatewayNatgasSelfTestViewController ()
@property (nonatomic, strong) MHDeviceGatewaySensorNatgas *deviceNatgas;
@property (nonatomic, strong) UILabel *waitingLabel;
@property (nonatomic, strong) UIImageView *resultView;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) CountTimerProgressView *progressView;

@property (nonatomic, strong) UIButton *btnCancel;
@property (nonatomic, strong) UIButton *btnDone;
@property (nonatomic, strong) UIButton *btnRetry;
@property (nonatomic, assign) BOOL isTimerOut;


@end

@implementation MHGatewayNatgasSelfTestViewController {
    NSTimer*                _progressTimer;
    NSTimer*                _monitorTimer;

}

- (id)initWithDeviceNatgas:(MHDeviceGatewaySensorNatgas *)deviceNatgas
{
    self = [super init];
    if (self) {
        self.deviceNatgas = deviceNatgas;
        _isTimerOut = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isTabBarHidden = YES;
    self.title = @"设备自检";
    [self beginSelfTest];
}

- (void)buildSubviews {
    [super buildSubviews];
    _progressView = [CountTimerProgressView progressView];
    _progressView.progress = 0;
    _progressView.totalCount = 18.0f;
    [self.view addSubview:_progressView];
    
    _resultView = [[UIImageView alloc] init];
    [_resultView setImage:[UIImage imageNamed:@"gateway_addsub_succeed"]];
    [self.view addSubview:_resultView];
    _resultView.hidden = YES;
    
    
    self.tipsLabel = [[UILabel alloc] init];
    self.tipsLabel.textAlignment = NSTextAlignmentCenter;
    self.tipsLabel.textColor = [UIColor blackColor];
    self.tipsLabel.font = [UIFont systemFontOfSize:16.0f];
    self.tipsLabel.text = @"设备自检中, 请稍等";
    self.tipsLabel.numberOfLines = 0;
    [self.view addSubview:self.tipsLabel];
    
    
    
    
    _progressView = [CountTimerProgressView progressView];
    _progressView.progress = 0;
    _progressView.totalCount = 30.f;
    [self.view addSubview:_progressView];
    
    
    _btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btnCancel setTitle:NSLocalizedStringFromTable(@"Cancel",@"plugin_gateway","取消") forState:(UIControlStateNormal)];
    _btnCancel.titleLabel.font = [UIFont systemFontOfSize:14];
    [_btnCancel setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:(UIControlStateNormal)];
    [_btnCancel.layer setCornerRadius:CancelButtonHeight / 2.f];
    _btnCancel.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _btnCancel.layer.borderWidth = 0.5;
    [_btnCancel addTarget:self action:@selector(onCancle:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:_btnCancel];
    
    _btnDone = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btnDone setTitle:NSLocalizedStringFromTable(@"done",@"plugin_gateway","完成") forState:(UIControlStateNormal)];
    _btnDone.titleLabel.font = [UIFont systemFontOfSize:14];
    [_btnDone setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:(UIControlStateNormal)];
    [_btnDone.layer setCornerRadius:CancelButtonHeight / 2.f];
    _btnDone.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _btnDone.layer.borderWidth = 0.5;
    [_btnDone addTarget:self action:@selector(onDone:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:_btnDone];
    _btnDone.hidden = YES;
    
    
    
    _btnRetry = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btnRetry setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.addsubdeviceslist.failedretry",@"plugin_gateway","重试") forState:(UIControlStateNormal)];
    _btnRetry.titleLabel.font = [UIFont systemFontOfSize:14];
    [_btnRetry setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:(UIControlStateNormal)];
    [_btnRetry.layer setCornerRadius:CancelButtonHeight / 2.f];
    _btnRetry.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _btnRetry.layer.borderWidth = 0.5;
    [_btnRetry addTarget:self action:@selector(onRetry:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:_btnRetry];
    _btnRetry.hidden = YES;

}

- (void)buildConstraints {
    [super buildConstraints];
    XM_WS(weakself);
    
    
    CGFloat leadSpacing = 120 * ScaleHeight;
    CGFloat guideSpacing = 40 * ScaleHeight;
    CGFloat progressSize = 110 * ScaleWidth;
    
    CGFloat veritalSapcing = 30 * ScaleHeight;
    CGFloat herizonSpacing = 30 * ScaleWidth;
  
    
    //添加成功
    [self.resultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.view).with.offset(leadSpacing);
        make.centerX.equalTo(weakself.view);
    }];
    
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.resultView.mas_bottom).with.offset(guideSpacing);
        make.centerX.equalTo(weakself.view);
        make.width.mas_equalTo(WIN_WIDTH - 80);
    }];
    

    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakself.view.mas_bottom).with.offset(-leadSpacing);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(progressSize, progressSize));
    }];
    
    
    [self.waitingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakself.progressView.mas_top).with.offset(veritalSapcing);
        make.centerX.equalTo(weakself.view);
        make.width.mas_equalTo(WIN_WIDTH - 80);
    }];
    
    [self.btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.view).with.offset(herizonSpacing);
        make.bottom.equalTo(weakself.view).with.offset(-veritalSapcing);
        make.right.equalTo(weakself.view).with.offset(-herizonSpacing);
        make.height.mas_equalTo(CancelButtonHeight);
    }];
    
    [self.btnRetry mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.view).with.offset(herizonSpacing);
        make.bottom.equalTo(weakself.view).with.offset(-veritalSapcing);
        make.right.equalTo(weakself.view).with.offset(-herizonSpacing);
        make.height.mas_equalTo(CancelButtonHeight);
    }];
    
    
    [self.btnDone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.view).with.offset(herizonSpacing);
        make.bottom.equalTo(weakself.view).with.offset(-veritalSapcing);
        make.right.equalTo(weakself.view).with.offset(-herizonSpacing);
        make.height.mas_equalTo(CancelButtonHeight);
    }];
    

}

#pragma mark - 倒计时进度
- (void)startProgressTimer {
    _progressView.hidden = NO;
    _progressView.progress = 0;
    _progressView.totalCount = 25.0f;
    _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(startProgressCnt) userInfo:nil repeats:YES];
}

- (void)startProgressCnt {
    CGFloat progress = _progressView.progress;
    if (progress <= 1.0) {
        progress += 0.01;
        
        //循环
        if (progress > 1.0) {
            [self stopProgressTimer];
            [self selfTestFailed];
            _isTimerOut = YES;
        }
        _progressView.progress = progress;
    }
}

- (void)stopProgressTimer {
    if(_progressTimer){
        [_progressTimer invalidate];
        _progressTimer = nil;
    }
}

- (void)startSelfTest {
    XM_WS(weakself);
    [self.deviceNatgas setPrivateProperty:SELFTEST_INDEX value:nil success:^(id obj) {
        NSLog(@"自检结果%@", obj);
        NSString *result = [[obj[@"result"] firstObject] stringValue];
        if ([result isEqualToString:@"ok"]) {
            [weakself endSelfTest];
            NSString *strTitle = @"有蜂鸣声和指示灯闪烁吗?";
            NSArray *buttonArray = @[ @"没有", @"有" ];
            
            [[MHPromptKit shareInstance] showAlertWithHandler:^(NSInteger buttonIndex, NSArray *inputs) {
                switch (buttonIndex) {
                    case 0: {
                        [weakself selfTestFailed];
                    }
                        break;
                    case 1: {
                        [weakself selfTestSucceed];
                    }
                        break;
                        
                    default:
                        break;
                }
            } withTitle:@"" message:strTitle style:UIAlertViewStyleDefault defaultText:nil cancelButtonTitle:nil otherButtonTitlesArray:buttonArray];
        }else if ([result isEqualToString:@"waiting"]){
            if (weakself.isTimerOut){
                [weakself selfTestFailed];
            }else{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakself startSelfTest];
                });
            }
        }else{
            [weakself selfTestFailed];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error.userInfo);
            [weakself selfTestFailed];
    }];
    
}

- (void)selfTestFailed {
    [self endSelfTest];
    self.progressView.hidden = YES;
    self.btnCancel.hidden = YES;
    self.btnDone.hidden = YES;
    self.btnRetry.hidden = NO;
    self.resultView.hidden = YES;
    self.resultView.image = [UIImage imageNamed:@"gateway_addsub_failed"];
//    self.tipsLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.addremote.tips",@"plugin_gateway","自检失败, 请重试");
        self.tipsLabel.text = @"自检失败, 请重试";

}

- (void)selfTestSucceed {
    [self endSelfTest];
    self.progressView.hidden = YES;
    self.btnCancel.hidden = YES;
    self.btnDone.hidden = NO;
    self.btnRetry.hidden = YES;
    self.resultView.hidden = NO;
    self.resultView.image = [UIImage imageNamed:@"gateway_addsub_succeed"];
//    self.tipsLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.addremote.tips",@"plugin_gateway","恭喜你, 设备工作正常!");
        self.tipsLabel.text = @"恭喜你, 设备工作正常!";


}

- (void)onDone:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onRetry:(id)sender {
    
    [self beginSelfTest];
}

- (void)onCancle:(id)sender {
    
    [self endSelfTest];
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (void)beginSelfTest {
    self.progressView.hidden = NO;
    _isTimerOut = NO;
    [self startSelfTest];
    [self startProgressTimer];
    self.tipsLabel.text = @"设备自检中, 请稍等";
    self.progressView.hidden = NO;
    self.btnCancel.hidden = YES;
    self.btnDone.hidden = YES;
    self.btnRetry.hidden = YES;
}

- (void)endSelfTest {
    [self stopSelftTestMonitor];
    [self stopProgressTimer];
    
}

#pragma mark - 子设备列表监控
- (void)startSelftTestMonitor {
    [_monitorTimer invalidate];
    _monitorTimer = nil;
    _monitorTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(startSelfTest) userInfo:nil repeats:YES];
}

- (void)stopSelftTestMonitor {
    [_monitorTimer invalidate];
    _monitorTimer = nil;
}


@end
