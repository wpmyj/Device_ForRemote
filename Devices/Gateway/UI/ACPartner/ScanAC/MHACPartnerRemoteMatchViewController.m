//
//  MHACPartnerRemoteMatchViewController.m
//  MiHome
//
//  Created by ayanami on 16/7/19.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerRemoteMatchViewController.h"
#import "SDProgressView.h"
#import "MHACPartnerAddSucceedViewController.h"
#import "MHLMDecimalBinaryTools.h"
#define CancelButtonHeight 46

typedef enum : NSUInteger {
    EMOTEMATCHSTATE_SUCCESS,
    EMOTEMATCHSTATE_FAILURE,
    EMOTEMATCHSTATE_RETRY,
} MHACREMOTEMATCHSTATE;

@interface MHACPartnerRemoteMatchViewController ()
@property (nonatomic, strong) MHDeviceAcpartner *acpartner;
@property (nonatomic, strong) UIImageView *resultView;

@property (nonatomic, strong) UIButton *btnCancel;
@property (nonatomic, strong) UIButton *btnDone;
@property (nonatomic, strong) UIButton *btnRetry;

@property (nonatomic, strong) UIImageView *matchImage;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) CountTimerProgressView *progressView;
@property (nonatomic, assign) BOOL isSuccess;
@property (nonatomic, assign) MHACREMOTEMATCHSTATE matchState;


@end

@implementation MHACPartnerRemoteMatchViewController {
    NSTimer*                _progressTimer;
    NSTimer*                _monitorTimer;

}
- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner
{
    self = [super init];
    if (self) {
        self.isTabBarHidden = YES;
        self.acpartner = acpartner;
        self.isSuccess = NO;
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.remotematch.title",@"plugin_gateway","遥控器匹配空调");
    
    [self starRemoteMactch];
    
//    XM_WS(weakself);
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [weakself matchFailed];
//    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self endRemoteMatch];
    
    
}

- (void)buildSubviews {
    [super buildSubviews];
    _matchImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"acpartner_remote_match"]];
    [self.view addSubview:_matchImage];
    
    self.tipsLabel = [[UILabel alloc] init];
    self.tipsLabel.textAlignment = NSTextAlignmentCenter;
    self.tipsLabel.textColor = [UIColor blackColor];
    self.tipsLabel.font = [UIFont systemFontOfSize:14.0f];
    self.tipsLabel.backgroundColor = [UIColor clearColor];
    self.tipsLabel.numberOfLines = 0;
    self.tipsLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.remotematch.tips",@"plugin_gateway","请使用空调遥控器 , 对着空调按一下 开关 键");
    [self.view addSubview:self.tipsLabel];
    
    _resultView = [[UIImageView alloc] init];
    [_resultView setImage:[UIImage imageNamed:@"gateway_addsub_succeed"]];
    [self.view addSubview:_resultView];
    _resultView.hidden = YES;
    
    
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
    CGFloat progressSpacing = 90 * ScaleHeight;
    CGFloat progressSize = 110 * ScaleWidth;
    CGFloat veritalSapcing = 30 * ScaleHeight;
    CGFloat herizonSpacing = 30 * ScaleWidth;
    
    //添加成功
    [self.resultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.view).with.offset(leadSpacing);
        make.centerX.equalTo(weakself.view);
    }];
    
    [self.matchImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.view.mas_top).with.offset(leadSpacing);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake( 471 / 2, 339 / 2));
    }];

    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.matchImage.mas_bottom).with.offset(guideSpacing);
        make.centerX.equalTo(weakself.view);
        make.width.mas_equalTo(WIN_WIDTH - 80);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakself.view.mas_bottom).with.offset(-progressSpacing);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(progressSize, progressSize));
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

- (void)starRemoteMactch {
       XM_WS(weakself);

    [self.acpartner startRemoteMatchParams:@[ [NSString stringWithFormat:@"%04ld", self.acpartner.brand_id], @(30) ] success:^(id obj) {
        [weakself startProgressTimer];
        [weakself startMonitorMatchResult];
    } failure:^(NSError *error) {
    }];
}

- (void)endRemoteMatch {
    [self stopMonitorMatchResult];
    [self stopProgressTimer];
    [self.acpartner endRemoteMatchSuccess:nil failure:nil];
    

}



#pragma mark - 倒计时进度
- (void)startProgressTimer {
    _progressView.hidden = NO;
    _progressView.progress = 0;
    _progressView.totalCount = 30.f;
    _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(startProgressCnt) userInfo:nil repeats:YES];
}

- (void)startProgressCnt {
    CGFloat progress = _progressView.progress;
    if (progress <= 1.0) {
        progress += 0.01;
        
        //循环
        if (progress > 1.0) {
            [self matchFailed];
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

#pragma mark - 子设备列表监控
- (void)startMonitorMatchResult {
    [_monitorTimer invalidate];
    _monitorTimer = nil;
    _monitorTimer = [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(onMonitorTimer:) userInfo:nil repeats:YES];
}

- (void)stopMonitorMatchResult {
    [_monitorTimer invalidate];
    _monitorTimer = nil;
}

- (void)onMonitorTimer:(NSTimer* )timer {
    XM_WS(weakself);
    [self.acpartner getRemoteMatchResultSuccess:^(id obj) {
        if ([obj[@"result"] isKindOfClass:[NSArray class]] && [obj[@"result"] count] > 1 && [[obj[@"result"] firstObject] integerValue]) {
            NSLog(@"遥控器匹配成功`%@", obj);
            //
            [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"setting",@"plugin_gateway","设置中") modal:YES];
            if (!weakself.isSuccess) {
                weakself.isSuccess = YES;
                [weakself endRemoteMatch];
                NSArray *resultArray = obj[@"result"];
                weakself.acpartner.brand_id = [resultArray[0] intValue];
                weakself.acpartner.ACRemoteId = [NSString stringWithFormat:@"%ld", [resultArray[1] integerValue]];
                [weakself.acpartner setRemoteMatchResultSuccess:^(id obj) {
                    [[MHTipsView shareInstance] hide];
                    [weakself matchSucceed];
                } failure:^(NSError *v) {
                    [[MHTipsView shareInstance] hide];
                    [weakself matchFailed];
                    
                }];
            }
        }
    } failure:^(NSError *error) {
        
    }];
  
}



- (void)matchFailed {
    [self endRemoteMatch];
    self.isSuccess = NO;
    self.btnCancel.hidden = YES;
    self.btnDone.hidden = YES;
    self.btnRetry.hidden = NO;
    self.progressView.hidden = YES;
    self.resultView.hidden = NO;
    self.matchImage.hidden = YES;
    
    self.resultView.image = [UIImage imageNamed:@"gateway_addsub_failed"];
    

    [[MHTipsView shareInstance] hide];
    MHACPartnerAddSucceedViewController *succeedVC = [[MHACPartnerAddSucceedViewController alloc] initWithAcpartner:self.acpartner successType:ADD_OTHER_FAILURE_INDEX];
    [self.navigationController pushViewController:succeedVC animated:YES];

    

}

- (void)matchSucceed {
    
    [self endRemoteMatch];
    self.isSuccess = NO;
    self.btnCancel.hidden = YES;
    self.btnRetry.hidden = YES;
    self.btnDone.hidden = YES;
    self.resultView.hidden = YES;
    self.progressView.hidden = YES;
    self.matchImage.hidden = YES;
    
//    self.resultView.image = [UIImage imageNamed:@"gateway_addsub_succeed"];
    
    XM_WS(weakself);   
    [self.acpartner saveACStatus];
    [[MHTipsView shareInstance] hide];
    //更新定时和场景的红外码
    [self.acpartner updateCommandMapSuccess:^(id obj) {
        [weakself.acpartner restoreACStatus];
    } failure:^(NSError *v) {
        
    }];
    MHACPartnerAddSucceedViewController *succeedVC = [[MHACPartnerAddSucceedViewController alloc] initWithAcpartner:self.acpartner successType:ADD_SUCCESS_INDEX];
    [self.navigationController pushViewController:succeedVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"remoteMatchSucceed:"];

   
}

- (void)onDone:(id)sender {
}

- (void)onRetry:(id)sender {
    self.progressView.hidden = NO;
    self.btnCancel.hidden = NO;
    self.btnDone.hidden = YES;
    self.btnRetry.hidden = YES;
    self.matchImage.hidden = NO;
    self.resultView.hidden = YES;
    [self starRemoteMactch];
}

- (void)onCancle:(id)sender {
    [self gw_clickMethodCountWithStatType:@"remoteMatchCancled:"];

    [self endRemoteMatch];
    XM_WS(weakself);
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([NSStringFromClass([obj class]) isEqualToString:@"MHACPartnerReMatchViewController"]) {
            [weakself.navigationController popToViewController:obj animated:YES];
        }
    }];
    
}

@end
