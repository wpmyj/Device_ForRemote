//
//  MHACAddRemoteSucceedViewController.m
//  MiHome
//
//  Created by ayanami on 16/8/9.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACAddRemoteSucceedViewController.h"


@interface MHACAddRemoteSucceedViewController ()


@property (nonatomic, strong) UIImageView *resultView;
@property (nonatomic, strong) UILabel *tipsLabel;

@property (nonatomic, strong) UIButton *btnDone;

@end



@implementation MHACAddRemoteSucceedViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.addremote.title",@"plugin_gateway","添加遥控器按键");
    self.isTabBarHidden = YES;
    
}

- (void)buildSubviews {
    [super buildSubviews];
    
    _resultView = [[UIImageView alloc] init];
    [_resultView setImage:[UIImage imageNamed:@"gateway_addsub_succeed"]];
    [self.view addSubview:_resultView];
    
    
    self.tipsLabel = [[UILabel alloc] init];
    self.tipsLabel.textAlignment = NSTextAlignmentCenter;
    self.tipsLabel.textColor = [UIColor blackColor];
    self.tipsLabel.font = [UIFont systemFontOfSize:16.0f];
    self.tipsLabel.numberOfLines = 0;
    self.tipsLabel.text = [NSString stringWithFormat:@"%@ [%@] %@", NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.addremote.succeed.header",@"plugin_gateway","添加"),self.selectName,NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.addremote.succeed.tail",@"plugin_gateway","成功")];
    [self.view addSubview:self.tipsLabel];
    
    
    _btnDone = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btnDone setTitle:NSLocalizedStringFromTable(@"done",@"plugin_gateway","完成") forState:(UIControlStateNormal)];
    _btnDone.titleLabel.font = [UIFont systemFontOfSize:14];
    [_btnDone setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:(UIControlStateNormal)];
    [_btnDone.layer setCornerRadius:46 / 2.f];
    _btnDone.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _btnDone.layer.borderWidth = 0.5;
    [_btnDone addTarget:self action:@selector(onDone:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:_btnDone];
    
    
    
    
    
    
}


- (void)buildConstraints {
    [super buildConstraints];
    XM_WS(weakself);
    CGFloat leadSpacing = 120 * ScaleHeight;
    CGFloat guideSpacing = 40 * ScaleHeight;
    
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
    
    
    [self.btnDone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.view).with.offset(herizonSpacing);
        make.bottom.equalTo(weakself.view).with.offset(-veritalSapcing);
        make.right.equalTo(weakself.view).with.offset(-herizonSpacing);
        make.height.mas_equalTo(46);
    }];

    
}

- (void)onDone:(id)sender {
    
    [self goBackToDetailPage];
}

- (void)onBack:(id)sender {
    [self goBackToDetailPage];
}

- (void)goBackToDetailPage {
    XM_WS(weakself);
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([NSStringFromClass([obj class]) isEqualToString:@"MHACPartnerMainViewController"]) {
            //                if ([obj isKindOfClass:[MHACPartnerDetailViewController class]]) {
            [weakself.navigationController popToViewController:obj animated:YES];
            *stop = YES;
        }
    }];

}

@end
