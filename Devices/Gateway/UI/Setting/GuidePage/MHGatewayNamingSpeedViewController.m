//
//  MHGatewayNamingSpeedViewController.m
//  MiHome
//
//  Created by guhao on 4/16/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayNamingSpeedViewController.h"
#import "MHLuTextField.h"
#import "MHLumiNamingSpeedCell.h"
#import "MHGatewayAddSubDeviceViewController.h"
#import "MHGatewayMainViewController.h"
#import "MHLumiChooseLogoListManager.h"
#import "MHLumiJavascriptObjectBridge.h"
#import "MHGatewayAddSubDeviceSucceedViewController.h"
#import "MHLumiChangeIconManager.h"
#import "MHGatewayAddSuccessCell.h"


@interface MHGatewayNamingSpeedViewController ()<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) MHLuTextField *nameField;
@property (nonatomic, strong) UIButton *nextPageBtn;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) MHDeviceGatewayBase *subDevice;
@property (nonatomic, strong) MHDeviceGateway *gateway;
@property (nonatomic, strong) NSMutableArray *locaitonNames;
@property (nonatomic, strong) NSMutableArray *selectedArray;
@property (nonatomic, assign) NSInteger selectedItem;
@property (nonatomic, assign) BOOL isShare;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *iconID;


@property (nonatomic, assign) BOOL isLocation;
@property (nonatomic, assign) BOOL isLogo;
@property (nonatomic, assign) BOOL showChangeLogo;
@property (nonatomic, assign) NSInteger serviceIndex;

@property (nonatomic, strong) MHLumiChooseLogoListManager *logoManager;

@property (nonatomic, strong) UITableView *tableView;




@end

@implementation MHGatewayNamingSpeedViewController

- (id)initWithSubDevice:(MHDeviceGatewayBase *)subDevice gatewayDevice:(MHDeviceGateway *)gateway shareIdentifier:(BOOL)isShare serviceIndex:(NSInteger)index
{
    self = [super init];
    if (self) {
        _isShare = isShare;
        _subDevice = subDevice;
        self.gateway = gateway;
        self.subDevice.parent = self.gateway;
        self.serviceIndex = index;
  
        self.isTabBarHidden = YES;
        UITapGestureRecognizer *tapHide = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nameFieldHide:)];
        tapHide.delegate = self;
        [self.view addGestureRecognizer:tapHide];
        
        self.iconID = [[MHLumiChangeIconManager sharedInstance] restorePdataByService:subDevice.services[index]
                                                                     withCompletionHandler:^(id result, NSError *error){ }];
        
        
        _showChangeLogo = [[MHLumiChooseLogoListManager sharedInstance] isShowLogoListWithandDeviceModel:self.subDevice.model finish:nil];
        if (self.iconID || !_showChangeLogo) {
            _isLogo = YES;
        }
        
        XM_WS(weakself);
//        self.logoManager = [MHLumiChooseLogoListManager sharedInstance];
        [[MHLumiChooseLogoListManager sharedInstance] setCurrentService:subDevice.services[index]];
        [[MHLumiChooseLogoListManager sharedInstance] setIsAddSubDevice:YES];
        [[MHLumiChooseLogoListManager sharedInstance] setSetIconName:^(NSString *name, NSString *icon) {
            weakself.isLogo = YES;
            weakself.imageName = name;
            weakself.iconID = icon;
            [weakself.tableView reloadData];
            weakself.nameField.text = [NSString stringWithFormat:@"%@-%@", weakself.location, name];
        }];        
    }
    return self;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.serviceIndex == 0 && [NSStringFromClass([self.subDevice class]) isEqualToString:DeviceModelCtrlNeutral2ClassName]) {
        self.title = [NSString stringWithFormat:@"%@%@",NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.namingSpeed",@"plugin_gateway","快速命名"), NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.namingSpeed.left",@"plugin_gateway","左键") ];
        self.imageName = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.namingSpeed.left",@"plugin_gateway","左键");
    }
    else if (self.serviceIndex == 1 && [NSStringFromClass([self.subDevice class]) isEqualToString:DeviceModelCtrlNeutral2ClassName]) {
        self.title = [NSString stringWithFormat:@"%@%@",NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.namingSpeed",@"plugin_gateway","快速命名"), NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.namingSpeed.right",@"plugin_gateway","右键") ];
        self.imageName = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.namingSpeed.right",@"plugin_gateway","右键");
    }
    else {
        self.title = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.namingSpeed",@"plugin_gateway","快速命名");
  
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)buildSubviews {
    [super buildSubviews];
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [MHColorUtils colorWithRGB:0x000000];
    self.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.deviceName",@"plugin_gateway","设备名称");
    [self.view addSubview:self.titleLabel];
    
    _nameField = [[MHLuTextField alloc] init];
    _nameField.delegate = self;
    if (self.serviceIndex == 0 && [NSStringFromClass([self.subDevice class]) isEqualToString:DeviceModelCtrlNeutral2ClassName]) {
        _nameField.text = [NSString stringWithFormat:@"%@",NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.namingSpeed.left",@"plugin_gateway","左键")];
    }
    else if (self.serviceIndex == 1 && [NSStringFromClass([self.subDevice class]) isEqualToString:DeviceModelCtrlNeutral2ClassName]) {
        _nameField.text = [NSString stringWithFormat:@"%@",NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.namingSpeed.right",@"plugin_gateway","右键")];
    }
    else {
        _nameField.text = [NSString stringWithFormat:@"%@",self.subDevice.name];
    }
    _nameField.textColor = [MHColorUtils colorWithRGB:0x000000];
    _nameField.font = [UIFont systemFontOfSize:16];
    _nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _nameField.backgroundColor = [MHColorUtils colorWithRGB:0xffffff];
    _nameField.borderStyle = UITextBorderStyleRoundedRect;
    _nameField.layer.borderColor = [[MHColorUtils colorWithRGB:0xBCBCBC] CGColor];
    _nameField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_nameField];
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, WIN_HEIGHT) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView setShowsVerticalScrollIndicator:NO];
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    [self.tableView registerClass:[MHGatewayAddSuccessCell class] forCellReuseIdentifier:@"MHGatewayAddSuccessCell"];
    
    _nextPageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *str = [NSString stringWithFormat:@"%@",NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.nextStep",@"plugin_gateway","下一步")];
    NSMutableAttributedString *titleAttribute = [[NSMutableAttributedString alloc] initWithString:str];
    [titleAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x858585] range:NSMakeRange(0, str.length)];
    [titleAttribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0f] range:NSMakeRange(0, str.length)];
    [_nextPageBtn setAttributedTitle:titleAttribute forState:UIControlStateNormal];
    [_nextPageBtn addTarget:self action:@selector(onNextPage:) forControlEvents:UIControlEventTouchUpInside];
//    [_nextPageBtn setTitleColor:[MHColorUtils colorWithRGB:0x606060] forState:UIControlStateNormal];
    _nextPageBtn.layer.cornerRadius = 20.0f;
    _nextPageBtn.layer.borderWidth = 0.5f;
    _nextPageBtn.layer.borderColor = [[MHColorUtils colorWithRGB:0xBCBCBC] CGColor];
    [self.view addSubview:_nextPageBtn];
    
}


- (void)buildConstraints {
    [super buildConstraints];
    XM_WS(weakself);
    CGFloat labelSpacingV = 80 * ScaleHeight;
    CGFloat labelSpacingH = 20 * ScaleWidth;
    
    CGFloat fieldSpacingV = 10 * ScaleHeight;
    CGFloat fieldSpacingH = 20 * ScaleWidth;
    
    CGFloat btnSpacingV = 20 * ScaleHeight;

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.view).with.offset(labelSpacingV);
        make.left.equalTo(weakself.view).with.offset(labelSpacingH);
    }];
    
    [self.nameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.titleLabel.mas_bottom).with.offset(fieldSpacingV);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(WIN_WIDTH - fieldSpacingH * 2, 40));
    }];
    
    [self.nextPageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakself.view).with.offset(-btnSpacingV);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(WIN_WIDTH - 60, 46));
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameField.mas_bottom).offset(8);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.nextPageBtn.mas_top).offset(8);
    }];

}

#pragma mark - UITableViewDelegate&DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 600;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MHGatewayAddSuccessCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MHGatewayAddSuccessCell"];
    cell.subDevice = self.subDevice;
    cell.nameField = self.nameField;
    cell.showChangeLogo = self.showChangeLogo;
    cell.imageName = self.imageName;
    [cell refreshUI];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.selectLocation = ^(BOOL isLocation, NSString *location){
        self.isLocation = isLocation;
        self.location = location;
    };
    return cell;
}

#pragma mark - 收起键盘
- (void)nameFieldHide:(id)sender {
    [_nameField resignFirstResponder];
}

#pragma mark - nextPage
- (void)onNextPage:(id)sender {
    if (!self.isLocation) {
        [[MHTipsView shareInstance] showTipsInfo:@"请先选择位置" duration:1.5f modal:NO];
        return;
    }
    else if (!self.isLogo) {
        [[MHTipsView shareInstance] showTipsInfo:@"请先选择图标" duration:1.5f modal:NO];
        return;
    }
    NSString *newname = _nameField.text;
    NSLog(@"%@", self.subDevice.name);
    NSLog(@"%@", self.subDevice);

    if (self.serviceIndex == 1) {
        newname = [NSString stringWithFormat:@"%@/%@", self.leftName, newname];
    }
    
    if ([newname length] > 30 || [newname length] == 0) {
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.changename.tips.toolong", @"plugin_gateway","设备名称必须在30个字符之内") duration:1.0 modal:NO];
    }
    else {
        
        if (self.serviceIndex == 0 && self.subDevice.services.count > 1) {
            [[MHLumiChooseLogoListManager sharedInstance] setIsAddSubDevice:NO];
            
            MHGatewayNamingSpeedViewController *namingVC = [[MHGatewayNamingSpeedViewController alloc] initWithSubDevice:self.subDevice gatewayDevice:_gateway shareIdentifier:self.isShare serviceIndex:1];
            namingVC.leftName = newname;
            [self.navigationController pushViewController:namingVC animated:YES];

        }
        else {
            [[MHTipsView shareInstance] showTips:@"" modal:YES];
            XM_WS(weakself);
            [self.subDevice changeName:newname success:^(id v) {
                NSLog(@"%@", newname);
                NSLog(@"%@", weakself.subDevice.name);
                [[MHTipsView shareInstance] hide];
                [weakself pushToSuccess];
                
            } failure:^(NSError *v) {
                [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.changename.tips.failed", @"plugin_gateway","修改设备名称失败") duration:1.0 modal:NO];
            }];
 
        }
    }
}

- (void)pushToSuccess {
    [[MHLumiChooseLogoListManager sharedInstance] setIsAddSubDevice:NO];
//    if (self.serviceIndex == 0 && self.subDevice.services.count > 1) {
//        MHGatewayNamingSpeedViewController *namingVC = [[MHGatewayNamingSpeedViewController alloc] initWithSubDevice:self.subDevice gatewayDevice:_gateway shareIdentifier:self.isShare serviceIndex:1];
//        [self.navigationController pushViewController:namingVC animated:YES];
//    }
//    else {
        MHGatewayAddSubDeviceSucceedViewController *successVC = [[MHGatewayAddSubDeviceSucceedViewController alloc] initWithShareIdentifier:self.isShare deviceType:NSStringFromClass([self.subDevice class])];
        [self.navigationController pushViewController:successVC animated:YES];
//    }

}



#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([NSStringFromClass([self.subDevice class]) isEqualToString:DeviceModelCtrlNeutral2ClassName]) {
        if ([string isEqualToString:@"/"] || [string containsString:@"/"]) {
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.changename.tips.invaildsymbol", @"plugin_gateway","设备名称包含非法字符&") duration:1.5 modal:NO];
            return NO;
        }
    }
   //    BOOL enable = ([textField.text length] + [string length] - range.length) > 0;
//    [self enableOk:enable];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
//    [self enableOk:NO];
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - tap手势与colletionview的cell事件的冲突
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.view];
    if (CGRectContainsPoint(self.tableView.frame, point)) {
        return NO;
    }
    return YES;
}


#pragma mark - 完成
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




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
