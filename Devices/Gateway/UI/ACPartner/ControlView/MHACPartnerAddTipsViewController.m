//
//  MHACPartnerAddTipsViewController.m
//  MiHome
//
//  Created by ayanami on 16/6/20.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerAddTipsViewController.h"
#import "MHACPartnerAddAcListViewController.h"
#import "MHCheckBox.h"

@interface MHACPartnerAddTipsViewController ()<MHCheckBoxDelegate>

@property (nonatomic, strong) MHDeviceAcpartner *acpartner;
@property (nonatomic, strong) MHCheckBox *acceptStatus;

@property (nonatomic, strong) UIButton *determineBtn;
@property (nonatomic, strong) UIButton *manualBtn;

@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *noteLabel;
@property (nonatomic, strong) UILabel *acceptLabel;

@property (nonatomic, strong) UIImageView *addImage;

@property (nonatomic, assign) BOOL isAccept;

@end

@implementation MHACPartnerAddTipsViewController
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
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add",@"plugin_gateway", "添加空调");
    self.isAccept = NO;
    XM_WS(weakself);
    [self.acpartner getACDeviceProp:AC_POWER_ID success:^(id obj) {
        weakself.acpartner.ac_power = [obj[0] floatValue];
    } failure:nil];

    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   
    
}

- (void)buildSubviews {
    [super buildSubviews];
    
    self.noteLabel = [[UILabel alloc] init];
    self.noteLabel.textColor = [UIColor redColor];
    self.noteLabel.font = [UIFont systemFontOfSize:18.0f];
    self.noteLabel.backgroundColor = [UIColor clearColor];
    self.noteLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.about.migration.about.warningtips",@"plugin_gateway","注意事项 ：");
    [self.view addSubview:self.noteLabel];

    
    self.detailLabel = [[UILabel alloc] init];
    self.detailLabel.font = [UIFont systemFontOfSize:16.0f];
    self.detailLabel.numberOfLines = 0;
    
    NSString *blue1 = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.warningtips.green.one",@"plugin_gateway", "空调");
    NSString *blue2 = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.warningtips.green.two",@"plugin_gateway", "空调伴侣插座");
    NSString *blue3 = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.warningtips.green.three",@"plugin_gateway", "不要使用");
    NSString *blue4 = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.warningtips.green.four",@"plugin_gateway", "遥控器");
    
    NSString *strDetail = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.warningtips.detail",@"plugin_gateway", "1.添加前,请务必将 空调 接在 空调伴侣插座 上。 \n 2.添加过程中,请 不要使用 空调 遥控器 操作,以免影响添加结果。");

    NSMutableAttributedString *todayCountTailAttribute = [[NSMutableAttributedString alloc] initWithString:strDetail];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragraphStyle setLineSpacing:10];//调整行间距
    
    [todayCountTailAttribute addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [strDetail length])];
    [todayCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x00ba7c] range:[strDetail rangeOfString:blue1]];
    [todayCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x00ba7c] range:[strDetail rangeOfString:blue2]];
    
    [todayCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x00ba7c] range:[strDetail rangeOfString:blue3]];
    [todayCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x00ba7c] range:[strDetail rangeOfString:blue4]];

    self.detailLabel.attributedText = todayCountTailAttribute;
    [self.view addSubview:self.detailLabel];
    
    
    _addImage = [[UIImageView alloc] init];
    [_addImage setImage:[UIImage imageNamed:@"acpartner_add"]];
    [self.view addSubview:_addImage];
    
    
    _acceptStatus = [[MHCheckBox alloc] initWithDelegate:self];
    _acceptStatus.unselImage = [UIImage imageNamed:@"device_cnnt_checkbox_unchecked"];
    _acceptStatus.selImage = [UIImage imageNamed:@"device_cnnt_checkbox_checked"];
    [self.view addSubview:_acceptStatus];
    
    self.acceptLabel = [[UILabel alloc] init];
    self.acceptLabel.textAlignment = NSTextAlignmentCenter;
    self.acceptLabel.textColor = [UIColor blackColor];
    self.acceptLabel.font = [UIFont systemFontOfSize:14.0f];
    self.acceptLabel.backgroundColor = [UIColor clearColor];
//    self.acceptLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.setting.alarm.status.off.tips",@"plugin_gateway","点击开启");
    self.acceptLabel.text = NSLocalizedStringFromTable(@"ifttt.scene.local.scene.log.scenedelete.confirm",@"plugin_gateway", "我知道了");

    [self.view addSubview:self.acceptLabel];
    

    
    
    _determineBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString *nextStr =  NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.nextStep",@"plugin_gateway","下一步");
      //"profile.alert.logout.confirm" = "确定";
//    NSString *nextStr = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.type.auto",@"plugin_gateway", "自动匹配空调");
    NSMutableAttributedString *nextTitleAttribute = [[NSMutableAttributedString alloc] initWithString:nextStr];
    [nextTitleAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x858585] range:NSMakeRange(0, nextStr.length)];
    [nextTitleAttribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0f] range:NSMakeRange(0, nextStr.length)];
    [_determineBtn setAttributedTitle:nextTitleAttribute forState:UIControlStateNormal];
    [_determineBtn addTarget:self action:@selector(onAutoMatch:) forControlEvents:UIControlEventTouchUpInside];
    _determineBtn.layer.cornerRadius = 20.0f;
    _determineBtn.layer.borderWidth = 0.5f;
    _determineBtn.layer.borderColor = [[MHColorUtils colorWithRGB:0xBCBCBC] CGColor];
    _determineBtn.backgroundColor = [MHColorUtils colorWithRGB:0x606060 alpha:0.2];
    _determineBtn.enabled = NO;
    [self.view addSubview:_determineBtn];

//    _manualBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    NSString *manaul = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.type.manual",@"plugin_gateway", "手动匹配空调");
//    NSMutableAttributedString *manaulTitleAttribute = [[NSMutableAttributedString alloc] initWithString:manaul];
//    [manaulTitleAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x858585] range:NSMakeRange(0, manaul.length)];
//    [manaulTitleAttribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0f] range:NSMakeRange(0, manaul.length)];
//    [_manualBtn setAttributedTitle:manaulTitleAttribute forState:UIControlStateNormal];
//    [_manualBtn addTarget:self action:@selector(onManaul:) forControlEvents:UIControlEventTouchUpInside];
//    _manualBtn.layer.cornerRadius = 20.0f;
//    _manualBtn.layer.borderWidth = 0.5f;
//    _manualBtn.layer.borderColor = [[MHColorUtils colorWithRGB:0xBCBCBC] CGColor];
//    _manualBtn.backgroundColor = [MHColorUtils colorWithRGB:0x606060 alpha:0.2];
//    _manualBtn.enabled = NO;
//    [self.view addSubview:_manualBtn];
    

    
    
}

- (void)buildConstraints {
    [super buildConstraints];
    
    XM_WS(weakself);
    
    [self.addImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.view.mas_top).with.offset(100);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(235.5, 89.5));
    }];

    
    [self.noteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.view.mas_left).with.offset(30);
        make.top.equalTo(weakself.addImage.mas_bottom).with.offset(40);
        make.centerX.equalTo(weakself.view);
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.view.mas_left).with.offset(30);
        make.top.equalTo(weakself.noteLabel.mas_bottom).with.offset(20);
        make.centerX.equalTo(weakself.view);
        make.width.mas_equalTo(WIN_WIDTH - 20);
    }];
    
    
    CGFloat btnHeight = 46;
    
//    [self.determineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(weakself.view).with.offset(-90);
//        make.centerX.equalTo(weakself.view);
//        make.size.mas_equalTo(CGSizeMake(WIN_WIDTH - 60, btnHeight));
//    }];
    
//    [self.manualBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(weakself.view).with.offset(-20);
//        make.centerX.equalTo(weakself.view);
//        make.size.mas_equalTo(CGSizeMake(WIN_WIDTH - 60, btnHeight));
//    }];
    
    [self.determineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakself.view).with.offset(-20);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(WIN_WIDTH - 60, btnHeight));
    }];
    
    [self.acceptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.right.equalTo(weakself.acceptStatus.mas_right).with.offset(-20);
        //        make.centerY.equalTo(weakself.acceptStatus);
        make.bottom.equalTo(weakself.determineBtn.mas_top).with.offset(-40);
        make.centerX.equalTo(weakself.view);
    }];
    
    [self.acceptStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakself.acceptLabel.mas_left).with.offset(-10);
        //        make.top.equalTo(weakself.detailLabel.mas_bottom).with.offset(20);
        make.centerY.equalTo(weakself.acceptLabel);
        make.size.mas_equalTo(CGSizeMake(25, 25));
    }];



    
}

#pragma mark - MHCheckBoxDelegate
- (void)didSelectedCheckBox:(MHCheckBox *)checkbox checked:(BOOL)checked {
    if (self.acpartner.isOnline == NO) {
        checkbox.selected = !checkbox.selected;
        [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.offline",@"plugin_gateway", "设备离线了,请接上电源后重试") duration:1.5f modal:YES];
        return;
    }
    self.determineBtn.enabled = checked;
    self.manualBtn.enabled = checked;
    _determineBtn.backgroundColor =  checked ? [MHColorUtils colorWithRGB:0x00ba7c] :[MHColorUtils colorWithRGB:0x606060 alpha:0.2];
    NSString *nextStr = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.nextStep",@"plugin_gateway","下一步");
    NSMutableAttributedString *nextTitleAttribute = [[NSMutableAttributedString alloc] initWithString:nextStr];
    [nextTitleAttribute addAttribute:NSForegroundColorAttributeName value:checked ? [UIColor whiteColor] : [MHColorUtils colorWithRGB:0x858585] range:NSMakeRange(0, nextStr.length)];
    [nextTitleAttribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0f] range:NSMakeRange(0, nextStr.length)];
    [_determineBtn setAttributedTitle:nextTitleAttribute forState:UIControlStateNormal];

    _manualBtn.backgroundColor =  checked ? [UIColor whiteColor] :[MHColorUtils colorWithRGB:0x606060 alpha:0.2];
}



- (void)onAutoMatch:(id)sender {
    MHACPartnerAddAcListViewController *acAddListVC = [[MHACPartnerAddAcListViewController alloc] initWithAcpartner:self.acpartner mactchManner:AUTO_MATCH];
    [self.navigationController pushViewController:acAddListVC animated:YES];
    
}
- (void)onManaulMatch:(id)sender {
    MHACPartnerAddAcListViewController *acAddListVC = [[MHACPartnerAddAcListViewController alloc] initWithAcpartner:self.acpartner mactchManner:MANUAL_MACTCH];
    [self.navigationController pushViewController:acAddListVC animated:YES];
}

- (void)onRemoteMatch:(id)sender {
    MHACPartnerAddAcListViewController *acAddListVC = [[MHACPartnerAddAcListViewController alloc] initWithAcpartner:self.acpartner mactchManner:REMOTE_MACTCH];
    [self.navigationController pushViewController:acAddListVC animated:YES];
}
@end
