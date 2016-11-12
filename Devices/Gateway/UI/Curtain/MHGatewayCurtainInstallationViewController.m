//
//  MHGatewayCurtainInstallationViewController.m
//  MiHome
//
//  Created by guhao on 16/5/16.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayCurtainInstallationViewController.h"

@interface MHGatewayCurtainInstallationViewController ()

@property (nonatomic, strong) UILabel *installationLabel;

@end

@implementation MHGatewayCurtainInstallationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isTabBarHidden = YES;
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.installationtutorial",@"plugin_gateway","安装教程");

}

- (void)buildSubviews {
    [super buildSubviews];
    
    self.installationLabel = [[UILabel alloc] init];
    self.installationLabel.textAlignment = NSTextAlignmentCenter;
    self.installationLabel.textColor = [UIColor blackColor];
    self.installationLabel.font = [UIFont systemFontOfSize:14.0f];
    self.installationLabel.numberOfLines = 0;
    self.installationLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.curtain.installationtutorial.title",@"plugin_gateway","安装教程详细");
    [self.view addSubview:self.installationLabel];
    

}


- (void)buildConstraints {
    [super buildConstraints];
    XM_WS(weakself);
    [self.installationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.view.mas_top).with.offset(70);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(WIN_WIDTH - 40, 250));
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
