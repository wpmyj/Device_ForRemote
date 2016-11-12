//
//  MHACPartnerChooseIrViewController.m
//  MiHome
//
//  Created by ayanami on 16/6/7.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerChooseIrViewController.h"
#import "MHACPartnerAddAcListViewController.h"
#import "MHACPartnerManualMatchViewController.h"

@interface MHACPartnerChooseIrViewController ()
@property (nonatomic, strong) MHDeviceAcpartner *acpartner;

@property (nonatomic, strong) UILabel *acChangeLabel;
@property (nonatomic, strong) UIButton *acChangeBtn;
@property (nonatomic, strong) UIButton *irChangeBtn;

@end

@implementation MHACPartnerChooseIrViewController

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
    // Do any additional setup after loading the view.
    self.title = @"重新选择码库";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    BOOL hasScan = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@", self.acpartner.did, kHASSCANED]] boolValue];
    self.irChangeBtn.enabled = hasScan;
}

- (void)buildSubviews {
    [super buildSubviews];
    
    self.acChangeLabel = [[UILabel alloc] init];
    self.acChangeLabel.textAlignment = NSTextAlignmentCenter;
    self.acChangeLabel.textColor = [UIColor blackColor];
    self.acChangeLabel.font = [UIFont systemFontOfSize:16.0f];
    self.acChangeLabel.backgroundColor = [UIColor clearColor];
//    self.acChangeLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.status.off.tips",@"plugin_gateway","点击开启");
    self.acChangeLabel.text = @"是否更换空调伴侣连接的空调?";
    [self.view addSubview:self.acChangeLabel];
    

    
    _acChangeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_acChangeBtn setTitle:@"已更换" forState:UIControlStateNormal];
    [_acChangeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_acChangeBtn addTarget:self action:@selector(onAcChange:) forControlEvents:UIControlEventTouchUpInside];
    [_acChangeBtn setBackgroundImage:[[UIImage imageNamed:@"gateway_migration_cancel"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 23, 0, 1)] forState:(UIControlStateNormal)];
    [self.view addSubview:_acChangeBtn];
    
    _irChangeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_irChangeBtn setTitle:@"未更换" forState:UIControlStateNormal];
    [_irChangeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_irChangeBtn addTarget:self action:@selector(onIrChange:) forControlEvents:UIControlEventTouchUpInside];
    [_irChangeBtn setBackgroundImage:[[UIImage imageNamed:@"gateway_migration_retry"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 23)] forState:(UIControlStateNormal)];
    [self.view addSubview:_irChangeBtn];

    
}

- (void)buildConstraints {
    [super buildConstraints];
    XM_WS(weakself);

    CGFloat btnHeight = 46;
    
    [self.acChangeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakself.view);
    }];
    
    [self.acChangeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.view.mas_left).with.offset(30);
        make.bottom.mas_equalTo(weakself.view.mas_bottom).with.offset(-20);
        make.size.mas_equalTo(CGSizeMake((WIN_WIDTH - 60) / 2, btnHeight));
    }];
    
    [self.irChangeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakself.view.mas_right).with.offset(-30);
        make.centerY.equalTo(weakself.acChangeBtn);
        make.size.mas_equalTo(CGSizeMake((WIN_WIDTH - 60) / 2, btnHeight));
    }];
    
}

- (void)onAcChange:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:[NSString stringWithFormat:@"%@%@", self.acpartner.did, kHASSCANED]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (self.acpartner.usableCodeList.count) {
        [self.acpartner.usableCodeList removeAllObjects];
    }
    self.acpartner.brand_id = 0;
    self.acpartner.ACRemoteId = nil;
    MHACPartnerAddAcListViewController *addVC = [[MHACPartnerAddAcListViewController alloc] initWithAcpartner:self.acpartner mactchManner:AUTO_MATCH];
    [self.navigationController pushViewController:addVC animated:YES];
}

- (void)onIrChange:(id)sender {
    MHACPartnerManualMatchViewController *irTestVC = [[MHACPartnerManualMatchViewController alloc] initWithAcpartner:self.acpartner];
    [self.navigationController pushViewController:irTestVC animated:YES];
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
