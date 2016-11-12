//
//  MHACAddRemoteViewController.m
//  MiHome
//
//  Created by ayanami on 16/7/20.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACAddRemoteViewController.h"
#import "SDProgressView.h"
#import "MHACPartnerAddSucceedViewController.h"
#import "MHGatewaySetZipPDataRequest.h"
#import "MHGatewaySetZipPDataResponse.h"
#import "MHACPartnerDetailViewController.h"
#import "MHLMDecimalBinaryTools.h"
#import "MHACCustomRemoteNameViewController.h"

#define CancelButtonHeight 46

@interface MHACAddRemoteViewController ()
@property (nonatomic, strong) MHDeviceAcpartner *acpartner;

@property (nonatomic, strong) UIImageView *resultView;
@property (nonatomic, strong) UIImageView *matchImage;
@property (nonatomic, strong) UILabel *tipsLabel;


@property (nonatomic, strong) UIButton *btnCancel;
@property (nonatomic, strong) UIButton *btnDone;
@property (nonatomic, strong) UIButton *btnRetry;
@property (nonatomic, strong) CountTimerProgressView *progressView;

@property (nonatomic, assign) BOOL isChooseName;
@property (nonatomic, copy) NSString *cmd;

@end


@implementation MHACAddRemoteViewController {
    NSTimer*                _progressTimer;
    NSTimer*                _monitorTimer;

}
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
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.addremote.title",@"plugin_gateway","添加遥控器按键");
    
    [self starRemoteMactch];
    
   
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
    
    _resultView = [[UIImageView alloc] init];
    [_resultView setImage:[UIImage imageNamed:@"gateway_addsub_succeed"]];
    [self.view addSubview:_resultView];
    _resultView.hidden = YES;

    
    self.tipsLabel = [[UILabel alloc] init];
    self.tipsLabel.textAlignment = NSTextAlignmentCenter;
    self.tipsLabel.textColor = [UIColor blackColor];
    self.tipsLabel.font = [UIFont systemFontOfSize:16.0f];
    self.tipsLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.addremote.tips",@"plugin_gateway","用 空调遥控器 对准空调, 按下需要学习的按键(如 灯光)");
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
    [self.acpartner startLearnRemoteValue:@(self.acpartner.brand_id) success:^(id obj) {
        [weakself startProgressTimer];
        [weakself startMonitorMatchResult];
    } failure:^(NSError *v) {
        
    }];
}

- (void)endRemoteMatch {
    [self stopMonitorMatchResult];
    [self stopProgressTimer];
    [self.acpartner endLearnRemoteSuccess:nil failure:nil];
    
    
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
            [self stopProgressTimer];
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
    [self.acpartner getLearnRemoteResultSuccess:^(id obj) {
        NSLog(@"添加按钮结果`%@", obj);
        if ([obj[@"result"] isKindOfClass:[NSArray class]] && [obj[@"result"] count] > 0 && ![[obj[@"result"] firstObject] isEqualToString:@"(null)"]) {
            NSLog(@"添加按钮成功`%@", obj);
            [weakself endRemoteMatch];
            weakself.cmd = [obj[@"result"] firstObject];
            [weakself matchSucceed];
        }
    } failure:^(NSError *v) {
        
    }];
    
}


- (void)onDone:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)onRetry:(id)sender {
    self.btnCancel.hidden = NO;
    self.btnDone.hidden = YES;
    self.btnRetry.hidden = YES;
    self.matchImage.hidden = NO;
    self.resultView.hidden = YES;
    self.tipsLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.addremote.tips",@"plugin_gateway","用 空调遥控器 对准空调, 按下需要学习的按键(如 灯光)");
    [self starRemoteMactch];
    [self gw_clickMethodCountWithStatType:@"retryAddRemoteButton:"];
}

- (void)onCancle:(id)sender {
    
    [self endRemoteMatch];
    [self.navigationController popViewControllerAnimated:YES];
    [self gw_clickMethodCountWithStatType:@"cancleAddRemoteButton:"];

}

- (void)matchFailed {
    self.btnCancel.hidden = YES;
    self.btnDone.hidden = YES;
    self.btnRetry.hidden = NO;
    self.progressView.hidden = YES;
    self.resultView.hidden = NO;
    self.matchImage.hidden = YES;

    self.resultView.image = [UIImage imageNamed:@"gateway_addsub_failed"];
    self.tipsLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.addremote.failure",@"plugin_gateway","添加遥控器按键失败");
    
    
   
}

- (void)matchSucceed {
    [self endRemoteMatch];
    
    self.btnCancel.hidden = YES;
    self.btnRetry.hidden = YES;
    self.btnDone.hidden = NO;
    self.resultView.hidden = NO;
    self.progressView.hidden = YES;
    self.matchImage.hidden = YES;
    
    self.cmd = [self updateCmd:self.cmd];

    MHACCustomRemoteNameViewController *renameVC = [[MHACCustomRemoteNameViewController alloc] initWithAcpartner:self.acpartner];
    renameVC.cmd = self.cmd;
    [self.navigationController pushViewController:renameVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"succeedAddRemoteButton:"];
    
}

- (NSString *)updateCmd:(NSString *)cmd {
    /**
     *  FE
     0000 brandid
     00000000  remoteid
     9470   固定
     00000000  明文
     05       来什么给什么
     0072       来什么给什么
     22 ->27   改成27
     97  checksum
     002C00340074013D13883212021000101200000202000200001212000202000002000
     */
    
    if (self.cmd.length < 36) {
        return @"error";
    }
    NSString *strCmd = nil;
    NSMutableString *newCmd = [NSMutableString new];
    NSString *strBegin = @"FE";
    NSString *strBrand = [NSString stringWithFormat:@"%04ld", self.acpartner.brand_id];
    NSString *strRemote = [NSString stringWithFormat:@"%08ld", [self.acpartner.ACRemoteId integerValue]];
    NSString *strF = @"9470";
    NSString *strInfo = [self.acpartner getACCommand:CUSTOM_FUNCTION_INDEX commandIndex:POWER_COMMAND isTimer:NO];
//    NSString *strInfo = @"1fff79ff";
    NSString *strType = [self.cmd substringWithRange:NSMakeRange(26, 2)];
    NSString *strLength = [self.cmd substringWithRange:NSMakeRange(28, 4)];
    NSString *strVersion = @"27";
    NSString *strHeadCheck = nil;
//strtoul([strHex UTF8String], 0, 16)
    NSLog(@"类型%@", strType);
    NSLog(@"长度%@", strLength);

   
   
    [newCmd appendString:strBegin];
    [newCmd appendString:strBrand];
    [newCmd appendString:strRemote];
    [newCmd appendString:strF];
    [newCmd appendString:strInfo];
    [newCmd appendString:strType];
    [newCmd appendString:strLength];
    [newCmd appendString:strVersion];
    
    long checkSum = 0;
    //头校验chechsum
    for (int i = 0; i < newCmd.length; i += 2) {
        NSString *tempTwo = [newCmd substringWithRange:NSMakeRange(i, 2)];
        NSLog(@"%d两位分割的字符%@", i ,tempTwo);
        checkSum += strtoul([tempTwo UTF8String], 0, 16);
    }
    NSLog(@"取模之前%ld", checkSum % 256);
//    NSInteger before = checkSum % 256;
//    before = before ^ 0xff;
//    NSLog(@"%ld", before);
    
    strHeadCheck = [MHLMDecimalBinaryTools decimalToHex:checkSum % 256];
    [newCmd appendString:strHeadCheck];
    NSLog(@"%@", strHeadCheck);
    NSLog(@"类型%@", strType);
    NSLog(@"转之前的命令%@", self.cmd);

    self.cmd = [self.cmd stringByReplacingCharactersInRange:NSMakeRange(0, 36) withString:newCmd];
    
    NSLog(@"转换完以后的命令%@", self.cmd);
    strCmd = self.cmd;
    return strCmd;
}


@end
