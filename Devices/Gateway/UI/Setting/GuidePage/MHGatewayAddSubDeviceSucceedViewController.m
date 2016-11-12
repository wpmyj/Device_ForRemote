//
//  MHGatewayAddSubDeviceSucceedViewController.m
//  MiHome
//
//  Created by guhao on 4/19/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayAddSubDeviceSucceedViewController.h"
#import "MHGatewayTempAndHumidityViewController.h"
#import "MHGatewayAddSubDeviceViewController.h"
#import "MHGatewayAddSubDeviceCell.h"

@interface MHGatewayAddSubDeviceSucceedViewController ()<UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIButton *compeleteBtn;
@property (nonatomic, assign) BOOL isShare;
@property (nonatomic, copy) NSString *deviceType;

@end

@implementation MHGatewayAddSubDeviceSucceedViewController

- (id)initWithShareIdentifier:(BOOL)isShare deviceType:(NSString *)deviceType
{
    self = [super init];
    if (self) {
        _isShare = isShare;
        _deviceType = deviceType;
        self.isTabBarHidden = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.setup",@"plugin_gateway","添加完成");
    self.automaticallyAdjustsScrollViewInsets = NO;
}



- (void)buildSubviews {
    [super buildSubviews];
   

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, WIN_WIDTH, WIN_HEIGHT) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView setShowsVerticalScrollIndicator:NO];
    _tableView.scrollEnabled = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    [self.tableView registerClass:[MHGatewayAddSubDeviceCell class] forCellReuseIdentifier:@"MHGatewayAddSubDeviceCell"];

    _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 65, CGRectGetWidth(self.view.bounds), 65)];
    _footerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_footerView];
    
    //完成
    _compeleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *str = [NSString stringWithFormat:@"%@",NSLocalizedStringFromTable(@"done",@"plugin_gateway","完成")];
    NSMutableAttributedString *titleAttribute = [[NSMutableAttributedString alloc] initWithString:str];
    [titleAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x858585] range:NSMakeRange(0, str.length)];
    [titleAttribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0f] range:NSMakeRange(0, str.length)];
    [_compeleteBtn setAttributedTitle:titleAttribute forState:UIControlStateNormal];
    [_compeleteBtn addTarget:self action:@selector(onCompelete:) forControlEvents:UIControlEventTouchUpInside];
    [_compeleteBtn setTitleColor:[MHColorUtils colorWithRGB:0x606060] forState:UIControlStateNormal];
    _compeleteBtn.layer.cornerRadius = 20.0f;
    _compeleteBtn.layer.borderWidth = 0.5f;
    _compeleteBtn.layer.borderColor = [[MHColorUtils colorWithRGB:0xBCBCBC] CGColor];
    [self.view addSubview:_compeleteBtn];
    
}

#pragma mark - UITableViewDelegate&DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return WIN_HEIGHT + 120;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MHGatewayAddSubDeviceCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MHGatewayAddSubDeviceCell"];
    [cell configureWithShare:self.isShare deviceType:self.deviceType];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)buildConstraints {
    [super buildConstraints];
    XM_WS(weakself);
    CGFloat btnSpacingV = 20 * ScaleHeight;
    [self.compeleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakself.view).with.offset(-btnSpacingV);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(WIN_WIDTH - 60, 40));
    }];
}


#pragma mark - 完成
- (void)onCompelete:(id)sender {
    [self goBack];
}

- (void)onBack {
    [super onBack];
    [self goBack];
}


- (void)goBack {
    XM_WS(weakself);
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([NSStringFromClass([obj class]) isEqualToString:@"MHACPartnerMainViewController"] ||
            [NSStringFromClass([obj class]) isEqualToString:@"MHGatewayMainViewController"]) {
            [weakself.navigationController popToViewController:obj animated:YES];
            
        }
        
    }];

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.deviceType isEqualToString:DeviceModelMagnetClassName]) {
        self.tableView.scrollEnabled = YES;
    }
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
