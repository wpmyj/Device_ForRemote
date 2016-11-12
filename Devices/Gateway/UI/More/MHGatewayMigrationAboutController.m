//
//  MHGatewayMigrationAboutController.m
//  MiHome
//
//  Created by Lynn on 5/25/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayMigrationAboutController.h"
#import "MHGatewayMigrationViewController.h"

@interface MHGatewayMigrationAboutController ()

@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *noteLabel;
@property (nonatomic, strong) UILabel *noteDetail;


@end

@implementation MHGatewayMigrationAboutController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.about.migration",@"plugin_gateway","迁移");

    UILabel *about = [[UILabel alloc] initWithFrame:CGRectMake(30, 90, 150, 35)];
    about.text = NSLocalizedStringFromTable(@"mydevice.gateway.about.migration.about.title",@"plugin_gateway","Introduction");
    about.font = [UIFont systemFontOfSize:18.f];
    [self.view addSubview:about];
    
    self.detailLabel = [[UILabel alloc] init];
    self.detailLabel.font = [UIFont systemFontOfSize:16.0f];
    self.detailLabel.numberOfLines = 0;
    
    NSString *blue1 = NSLocalizedStringFromTable(@"mydevice.gateway.about.migration.about.title.detail.blue1",@"plugin_gateway", "断开Internet也能正常执行自动化");
    NSString *blue2 = NSLocalizedStringFromTable(@"mydevice.gateway.about.migration.about.title.detail.blue2",@"plugin_gateway", "感受不到自动化延迟");
    NSString *blue3 = NSLocalizedStringFromTable(@"mydevice.gateway.about.migration.about.title.detail.blue3",@"plugin_gateway", "实现两个网关一起联动报警");

    NSString *strDetail = NSLocalizedStringFromTable(@"mydevice.gateway.about.migration.about.title.detail",@"plugin_gateway","1.一键将一代网关下子设备,迁...");
    NSMutableAttributedString *todayCountTailAttribute = [[NSMutableAttributedString alloc] initWithString:strDetail];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragraphStyle setLineSpacing:5];//调整行间距
    
    [todayCountTailAttribute addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [strDetail length])];
    [todayCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x1084c1] range:[strDetail rangeOfString:blue1]];
    [todayCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x1084c1] range:[strDetail rangeOfString:blue2]];

    [todayCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x1084c1] range:[strDetail rangeOfString:blue3]];
    self.detailLabel.attributedText = todayCountTailAttribute;
    [self.view addSubview:self.detailLabel];
    
    
    self.noteLabel = [[UILabel alloc] init];
    self.noteLabel.textColor = [UIColor redColor];
    self.noteLabel.font = [UIFont systemFontOfSize:18.0f];
    self.noteLabel.backgroundColor = [UIColor clearColor];
    self.noteLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.about.migration.about.warningtips",@"plugin_gateway","注意事项 ：");
    [self.view addSubview:self.noteLabel];
    
    
    self.noteDetail = [[UILabel alloc] init];
    self.noteDetail.textColor = [UIColor blackColor];
    self.noteDetail.font = [UIFont systemFontOfSize:16.0f];
    self.noteDetail.backgroundColor = [UIColor clearColor];
    self.noteDetail.numberOfLines = 0;
    self.noteDetail.text = NSLocalizedStringFromTable(@"mydevice.gateway.about.migration.about.warningtips.detail",@"plugin_gateway","注意事项 ：  迁移后，新一代网关下子设备将被全部删除，请了解哦");
    [self.view addSubview:self.noteDetail];

    
    UIButton *migrateBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    migrateBtn.frame = CGRectMake(30, WIN_HEIGHT - 70, WIN_WIDTH - 60, 45);
    [migrateBtn setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.switch.see",@"plugin_gateway","迁移")
                forState:UIControlStateNormal];
    [migrateBtn addTarget:self action:@selector(onMigration:) forControlEvents:UIControlEventTouchUpInside];
    migrateBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [migrateBtn setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:(UIControlStateNormal)];
    [migrateBtn.layer setCornerRadius:45 / 2.f];
    migrateBtn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    migrateBtn.layer.borderWidth = 0.5;
    [self.view addSubview:migrateBtn];
    
   
    

}

- (void)buildConstraints {
    [super buildConstraints];
    XM_WS(weakself);
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.view.mas_left).with.offset(30);
        make.top.equalTo(weakself.view.mas_top).with.offset(130);
        make.centerX.equalTo(weakself.view);
        make.width.mas_equalTo(WIN_WIDTH - 20);
    }];
    
    [self.noteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.view.mas_left).with.offset(30);
        make.top.equalTo(weakself.detailLabel.mas_bottom).with.offset(20);
        make.centerX.equalTo(weakself.view);
    }];
    
    
    [self.noteDetail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.view.mas_left).with.offset(30);
        make.top.equalTo(weakself.noteLabel.mas_bottom).with.offset(5);
        make.centerX.equalTo(weakself.view);
        make.width.mas_equalTo(WIN_WIDTH - 20);
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onMigration:(id)sender {
    MHGatewayMigrationViewController *migrate = [[MHGatewayMigrationViewController alloc] init];
    migrate.gateway = self.gateway;
    migrate.isTabBarHidden = YES;
    [self.navigationController pushViewController:migrate animated:YES];
}

@end
