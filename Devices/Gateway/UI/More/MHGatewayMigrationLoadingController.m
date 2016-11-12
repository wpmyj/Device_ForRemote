//
//  MHGatewayMigrationLoadingController.m
//  MiHome
//
//  Created by Lynn on 5/25/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayMigrationLoadingController.h"
#import "MHGatewayMigrationManager.h"
#import "SDProgressView.h"
#import "MHGatewayMainViewController.h"

#define FailedTipsImage        [UIImage imageNamed:@"gateway_addsub_failed"]
#define FailedTipsLabel        NSLocalizedStringFromTable(@"mydevice.gateway.about.migration.failedtips",@"plugin_gateway","")
#define SuccessedTipsImage     [UIImage imageNamed:@"gateway_addsub_succeed"]
#define SuccessedTipsLabel     NSLocalizedStringFromTable(@"mydevice.gateway.about.migration.successtips",@"plugin_gateway","")

#define WaitingTipsLabel       NSLocalizedStringFromTable(@"mydevice.gateway.about.migration.waitingtips",@"plugin_gateway","")

@interface MHGatewayMigrationLoadingController ()

@end

@implementation MHGatewayMigrationLoadingController
{
    CountTimerProgressView *         _progressView;
    UILabel *                        _progressLabel;
    UIActivityIndicatorView *        _indicator;
    
    UIImageView *                    _tipsImageView;
    UILabel *                        _tipsLabel;
    UILabel *                        _warningTipsLabel;
    
    UIButton *                       _cancelButton;
    UIButton *                       _finishButton;
    UIButton *                       _retryButton;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
        
    if(_finishButton.hidden){
        self.navigationItem.hidesBackButton = YES;
    }else {
        self.navigationItem.hidesBackButton = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.about.migration",@"plugin_gateway","迁移");
    
    _tipsImageView = [[UIImageView alloc] initWithFrame:CGRectMake( WIN_WIDTH / 2 - 60 * ScaleWidth, 110, 120 * ScaleWidth, 120 * ScaleWidth)];
    _tipsImageView.image = SuccessedTipsImage;
    [self.view addSubview:_tipsImageView];
    _tipsImageView.hidden = YES;
    
    _progressView = [CountTimerProgressView progressView];
    _progressView.circleColor = [UIColor colorWithRed:20.f/255.f green:155.f/255.f blue:255.f/255.f alpha:1.0f];
    _progressView.backColor = [UIColor whiteColor];
    _progressView.circleUnCoverColor = [UIColor colorWithRed:0.f/255.f green:150.f/255.f blue:255.f/255.f alpha:0.2f];
    _progressView.frame = CGRectMake(0, 0, 120 * ScaleWidth, 120 * ScaleWidth);
    _progressView.center = _tipsImageView.center;
    _progressView.progress = 0.001;
    [self.view addSubview:_progressView];

    _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    _progressLabel.textAlignment = NSTextAlignmentCenter;
    _progressLabel.font = [UIFont systemFontOfSize:15.f];
    _progressLabel.textColor = [UIColor colorWithRed:20.f/255.f green:155.f/255.f blue:255.f/255.f alpha:1.0f];
    _progressLabel.text = @"0.1%";
    _progressLabel.center = _progressView.center;
    [self.view addSubview:_progressLabel];
    
    _indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    _indicator.center = CGPointMake(_progressLabel.center.x, CGRectGetMaxY(_progressLabel.frame) + 10);
    [_indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [_indicator startAnimating];
    [self.view addSubview:_indicator];
    
    _tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_tipsImageView.frame) + 10, WIN_WIDTH, 40)];
    _tipsLabel.textAlignment = NSTextAlignmentCenter;
    _tipsLabel.font = [UIFont systemFontOfSize:15.f];
    _tipsLabel.textColor = [UIColor darkGrayColor];
    _tipsLabel.text = WaitingTipsLabel;
    [self.view addSubview:_tipsLabel];
    
    _warningTipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, WIN_HEIGHT - 90, WIN_WIDTH, 40)];
    _warningTipsLabel.textAlignment = NSTextAlignmentCenter;
    _warningTipsLabel.font = [UIFont systemFontOfSize:13.f];
    _warningTipsLabel.textColor = [UIColor colorWithRed:250.f/255.f green:128.f/255.f blue:10.f/255.f alpha:1.0f];
    _warningTipsLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.about.migration.warningtips",@"plugin_gateway","");
    [self.view addSubview:_warningTipsLabel];
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _cancelButton.frame = CGRectMake(30, WIN_HEIGHT - 70, (WIN_WIDTH - 60) / 2, 46);
    [_cancelButton setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.about.migration.cancel",@"plugin_gateway","")
                   forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_cancelButton setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:(UIControlStateNormal)];
    [_cancelButton setBackgroundImage:[[UIImage imageNamed:@"gateway_migration_cancel"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 23, 0, 1)] forState:(UIControlStateNormal)];
    [self.view addSubview:_cancelButton];
    _cancelButton.hidden = YES;
    
    _retryButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _retryButton.frame = CGRectMake(30 + (WIN_WIDTH - 60) / 2, WIN_HEIGHT - 70, (WIN_WIDTH - 60) / 2, 46);
    [_retryButton setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.about.migration.retry",@"plugin_gateway","")
                  forState:UIControlStateNormal];
    [_retryButton addTarget:self action:@selector(onRetry:) forControlEvents:UIControlEventTouchUpInside];
    _retryButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_retryButton setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:(UIControlStateNormal)];
    [_retryButton setBackgroundImage:[[UIImage imageNamed:@"gateway_migration_retry"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 23)] forState:(UIControlStateNormal)];
    [self.view addSubview:_retryButton];
    _retryButton.hidden = YES;
    
    _finishButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _finishButton.frame = CGRectMake(30, WIN_HEIGHT - 70, WIN_WIDTH - 60, 46);
    [_finishButton setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.about.migration.finish",@"plugin_gateway","")
                   forState:UIControlStateNormal];
    [_finishButton addTarget:self action:@selector(onFinish:) forControlEvents:UIControlEventTouchUpInside];
    _finishButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_finishButton setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:(UIControlStateNormal)];
    [_finishButton.layer setCornerRadius:45 / 2.f];
    _finishButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _finishButton.layer.borderWidth = 0.5;
    [self.view addSubview:_finishButton];
    _finishButton.hidden = YES;
    
    [self startMigration];
}

- (void)startMigration {
    XM_WS(weakself);
    [[MHGatewayMigrationManager sharedInstance] gatewayMigrationInvoker:self.outGateway
                                                             newGateway:self.inGateway
                                                            withSuccess:^(id obj) {
                                                                [weakself migrationSuccess];
                                                                
                                                            } failure:^(NSError *v) {
                                                                [weakself migrationFailed];
                                                                
                                                            } progress:^(CGFloat progress) {
                                                                [weakself setProgressCnt:progress];
                                                            }];
}

- (void)migrationFailed {
    _progressView.progress = 0.001;
    _progressView.hidden = YES;
    _progressLabel.text = @"0.1%";
    _progressLabel.hidden = YES;
    _indicator.hidden = YES;
    
    _tipsImageView.hidden = NO;
    _tipsImageView.image = FailedTipsImage;
    
    _tipsLabel.text = FailedTipsLabel;
    _tipsLabel.hidden = NO;
    
    _warningTipsLabel.hidden = YES;
    _cancelButton.hidden = NO;
    _retryButton.hidden = NO;
}

- (void)migrationSuccess {
    _progressView.hidden = YES;
    _progressLabel.hidden = YES;
    _indicator.hidden = YES;
    
    _tipsImageView.hidden = NO;
    _tipsImageView.image = SuccessedTipsImage;
    
    _tipsLabel.text = SuccessedTipsLabel;
    _tipsLabel.hidden = NO;
    
    _warningTipsLabel.hidden = YES;
    _finishButton.hidden = NO;
    
    self.navigationItem.hidesBackButton = NO;
}

- (void)setProgressCnt:(CGFloat)progress
{
    if(progress >= 1.0) {
        _progressView.progress = 0.999;
        self.navigationItem.hidesBackButton = NO;
    }
    else{
        _progressView.progress = progress;
        _progressLabel.text = [NSString stringWithFormat:@"%0.0f%@",progress * 100,@"%"];
    }
}

- (void)onFinish:(id)sender {
    [self onBack:nil];
}

- (void)onBack:(id)sender {
    //只有当成功时才出现这个返回键
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)onCancel:(id)sender {
    NSArray *currentViewControllers = self.navigationController.viewControllers;
    NSInteger idx = currentViewControllers.count - 3;
    [self.navigationController popToViewController:currentViewControllers[idx] animated:YES];
}

- (void)onRetry:(id)sender {
    _progressView.hidden = NO;
    _progressLabel.hidden = NO;
    _indicator.hidden = NO;
    
    _tipsImageView.hidden = YES;
    
    _tipsLabel.text = WaitingTipsLabel;
    _tipsLabel.hidden = NO;
    
    _warningTipsLabel.hidden = NO;
    _cancelButton.hidden = YES;
    _retryButton.hidden = YES;
    
    [self startMigration];
    self.navigationItem.hidesBackButton = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
