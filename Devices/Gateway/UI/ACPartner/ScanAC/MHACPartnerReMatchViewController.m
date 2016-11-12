//
//  MHACPartnerReMatchViewController.m
//  MiHome
//
//  Created by ayanami on 16/7/19.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerReMatchViewController.h"
#import "MHACPartnerAddAcListViewController.h"
#import "MHACPartnerRemoteMatchViewController.h"
#import "MHACPartnerManualMatchViewController.h"
#import "MHACHistoryMatchViewController.h"

@interface MHACPartnerReMatchViewController ()

@property (nonatomic, assign) ACPARTNER_REMATCH_TYPE type;
@property (nonatomic, strong) MHDeviceAcpartner *acpartner;
@property (nonatomic, strong) UILabel *historyLabel;
@property (nonatomic, strong) UIButton *remoteBtn;
@property (nonatomic, strong) UIButton *manualBtn;
@property (nonatomic, strong) UIButton *autoBtn;

@end

@implementation MHACPartnerReMatchViewController
- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner type:(ACPARTNER_REMATCH_TYPE)type
{
    self = [super init];
    if (self) {
        self.acpartner = acpartner;
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isTabBarHidden = YES;
}

- (void)buildSubviews {
    [super buildSubviews];
    
    _autoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_autoBtn setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.type.auto",@"plugin_gateway", "自动匹配空调") forState:UIControlStateNormal];
    [_autoBtn addTarget:self action:@selector(onAutoMatch:) forControlEvents:UIControlEventTouchUpInside];
//    [_autoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_autoBtn setBackgroundImage:[UIImage imageNamed:@"acpartner_match_bg"] forState:UIControlStateNormal];
    [_autoBtn setTitle: NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.type.auto",@"plugin_gateway", "自动匹配空调") forState:UIControlStateNormal];
    _autoBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [_autoBtn setTitleColor:[MHColorUtils colorWithRGB:0xffffff] forState:UIControlStateNormal];
    [self.view addSubview:_autoBtn];
    
    _remoteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_remoteBtn setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.switch.see",@"plugin_gateway","遥控器匹配") forState:UIControlStateNormal];
    [_remoteBtn setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.remotematch",@"plugin_gateway","遥控器匹配") forState:UIControlStateNormal];
    [_remoteBtn setBackgroundImage:[UIImage imageNamed:@"acpartner_match_bg"] forState:UIControlStateNormal];
    [_remoteBtn addTarget:self action:@selector(onRemoteMatch:) forControlEvents:UIControlEventTouchUpInside];
    [_remoteBtn setTitleColor:[MHColorUtils colorWithRGB:0xffffff] forState:UIControlStateNormal];
    _remoteBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:_remoteBtn];

    
    _manualBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_manualBtn setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.type.manual",@"plugin_gateway", "手动匹配空调") forState:UIControlStateNormal];
    [_manualBtn addTarget:self action:@selector(onManuallMatch:) forControlEvents:UIControlEventTouchUpInside];
    _manualBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:_manualBtn];
    
    
    self.historyLabel = [[UILabel alloc] init];
    self.historyLabel.textAlignment = NSTextAlignmentCenter;
    self.historyLabel.textColor = [MHColorUtils colorWithRGB:0x606060];
    self.historyLabel.font = [UIFont systemFontOfSize:16.0f];
//    self.historyLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.status.off.tips",@"plugin_gateway","历史匹配");
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(historyMatch:)];
    [self.historyLabel addGestureRecognizer:tap];
    self.historyLabel.userInteractionEnabled = YES;
    self.historyLabel.text = @"历史匹配 >";
    self.historyLabel.hidden = YES;

    [self.view addSubview:self.historyLabel];
    switch (self.type) {
        case REMACTCH_INDEX: {
            self.autoBtn.hidden = NO;
            self.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.more.newir",@"plugin_gateway","重新匹配空调");
            [_manualBtn setBackgroundImage:[UIImage imageNamed:@"acpartner_match_bg"] forState:UIControlStateNormal];
            [_manualBtn setTitleColor:[MHColorUtils colorWithRGB:0xffffff] forState:UIControlStateNormal];
            break;
        }
        case MATCH_FAILURE_INDEX: {
            self.autoBtn.hidden = YES;
            self.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.remotematch.failure",@"plugin_gateway","尝试其他方法");
            [_manualBtn setBackgroundImage:[UIImage imageNamed:@"acpartner_match_hollow_bg"] forState:UIControlStateNormal];
            [_manualBtn setTitleColor:[MHColorUtils colorWithRGB:0x00ba7c] forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
    
}


- (void)buildConstraints {
    [super buildConstraints];
    XM_WS(weakself);
    CGFloat topSpacing = 100 * ScaleHeight;
    CGFloat btnSpacing = 40 * ScaleHeight;
    CGFloat btnSize = 110 * ScaleWidth;
    
    [self.autoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.view.mas_top).with.offset(topSpacing);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(btnSize, btnSize));
    }];
    
    [self.remoteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.autoBtn.mas_bottom).with.offset(btnSpacing);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(btnSize, btnSize));
    }];
    
    [self.manualBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.remoteBtn.mas_bottom).with.offset(btnSpacing);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(btnSize, btnSize));
    }];
    
    [self.historyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakself.view.mas_bottom).with.offset(-btnSpacing);
        make.centerX.equalTo(weakself.view);
    }];
    
}

- (void)historyMatch:(id)sender {
    MHACHistoryMatchViewController *historyVC = [[MHACHistoryMatchViewController alloc] initWithAcpartner:self.acpartner];
    [self.navigationController pushViewController:historyVC animated:YES];
}


- (void)onAutoMatch:(id)sender {
    MHACPartnerAddAcListViewController *acAddListVC = [[MHACPartnerAddAcListViewController alloc] initWithAcpartner:self.acpartner mactchManner:AUTO_MATCH];
    [self.navigationController pushViewController:acAddListVC animated:YES];
    [self gw_clickMethodCountWithStatType:@"openACPartnerAutoMatch:"];
    
}
- (void)onManuallMatch:(id)sender {
    switch (self.type) {
        case REMACTCH_INDEX: {
            MHACPartnerAddAcListViewController *acAddListVC = [[MHACPartnerAddAcListViewController alloc] initWithAcpartner:self.acpartner mactchManner:MANUAL_MACTCH];
            [self.navigationController pushViewController:acAddListVC animated:YES];
            break;
        }
        case MATCH_FAILURE_INDEX: {
            MHACPartnerManualMatchViewController *manualVC = [[MHACPartnerManualMatchViewController alloc] initWithAcpartner:self.acpartner];
            manualVC.oldBrandid = self.acpartner.brand_id;
            manualVC.oldRemoteid = self.acpartner.ACRemoteId;
            [self.navigationController pushViewController:manualVC animated:YES];

            break;
        }
        default:
            break;
    }
    [self gw_clickMethodCountWithStatType:@"openACPartnerManualMatch:"];

}

- (void)onRemoteMatch:(id)sender {
    switch (self.type) {
        case REMACTCH_INDEX: {
            
            MHACPartnerAddAcListViewController *acAddListVC = [[MHACPartnerAddAcListViewController alloc] initWithAcpartner:self.acpartner mactchManner:REMOTE_MACTCH];
            [self.navigationController pushViewController:acAddListVC animated:YES];
            break;
        }
        case MATCH_FAILURE_INDEX: {
            
            MHACPartnerRemoteMatchViewController *remoteVC = [[MHACPartnerRemoteMatchViewController alloc] initWithAcpartner:self.acpartner];
            [self.navigationController pushViewController:remoteVC animated:YES];
            
            break;
        }
        default:
            break;
    }
    [self gw_clickMethodCountWithStatType:@"openACPartnerRemoteMatch:"];

}

@end
