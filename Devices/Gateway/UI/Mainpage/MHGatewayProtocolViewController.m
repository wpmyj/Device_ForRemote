//
//  MHGatewayProtocolViewController.m
//  MiHome
//
//  Created by LM21Mac002 on 16/9/12.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayProtocolViewController.h"
#import "MHPromptKit.h"
@interface MHGatewayProtocolViewController ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UISwitch *enableSwitch;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *prefixLabel;
@property (nonatomic, strong) UILabel *passsWordLabel;
@property (nonatomic, strong) UIButton *refreshButton;
@property (nonatomic, strong) UITextView *contentTextView;
@property (nonatomic, strong) UIView *buttonBgView;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIView *lineView2;
@property (nonatomic, strong) UIColor *enableColor;
@property (nonatomic, strong) UIColor *unableColor;
@property (nonatomic, copy) NSString *prefixStr;
@end

@implementation MHGatewayProtocolViewController
static CGFloat leftPadding = 20;
static CGFloat rightPadding = 20;
static CGFloat topPadding = 100;
static CGFloat lineTopPadding = 20;
static CGFloat passWordTopPadding = 20;
static CGFloat passsWordRightPadding = 10;
static CGFloat contentTextViewTopPadding = 20;
static CGFloat buttonBgViewHeight = 50;
static CGFloat buttonBgViewBottomPadding = 20;
static CGFloat contentTextViewBottomPadding = 10;
- (void)viewDidLoad {
    [super viewDidLoad];
    //TODO: 多语言
    self.isTabBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.enableColor = [UIColor blackColor];
    self.unableColor = [UIColor colorWithWhite:0.8 alpha:0.5];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.enableSwitch];
    [self.view addSubview:self.lineView];
    [self.view addSubview:self.prefixLabel];
    [self.view addSubview:self.passsWordLabel];
    [self.view addSubview:self.refreshButton];
    [self.view addSubview:self.contentTextView];
    [self.view addSubview:self.buttonBgView];
    [self.buttonBgView addSubview:self.cancelButton];
    [self.buttonBgView addSubview:self.confirmButton];
    [self.buttonBgView addSubview:self.lineView2];
    [self configureLayout];
    [self loadPassWordFormGateWay];
}

#pragma mark - event response
- (void)refreshButtonAction:(UIButton *)sender{
    //17位？
    NSString *todoStr = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *uniqueString = [todoStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *uniqueString1 = [uniqueString substringToIndex:16];
    self.passsWordLabel.text = uniqueString1;
}

- (void)enableSwitchAction:(UISwitch *)sender{
    if (sender.isOn){
        self.passsWordLabel.textColor = self.enableColor;
    }else{
        self.passsWordLabel.textColor = self.unableColor;
    }
}

- (void)confirmButtonAction:(UIButton *)sender{
    NSString *passWord = nil;
    if (self.enableSwitch.isOn){
        passWord = self.passsWordLabel.text;
    }
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"setting",@"plugin_gateway","设置中，请稍候...") modal:NO];
    __weak typeof(self) weakSelf = self;
    [self.dataGetter setLumiDpfAesKeyWithPassWord:passWord
                                          success:^(NSDictionary *result) {
                                              [[MHTipsView shareInstance] showFinishTips:NSLocalizedStringFromTable(@"request.succeed", @"plugin_gateway", @"请求成功") duration:1 modal:YES];
                                              [weakSelf dissmissSelf];
                                          } failure:^(NSError *error) {
                                              [[MHTipsView shareInstance] showFinishTips:NSLocalizedStringFromTable(@"setting.failed",@"plugin_gateway","设置失败") duration:1 modal:YES];
                                          }];
}

- (void)cancelButtonAction:(UIButton *)sender{
    [self dissmissSelf];
}

#pragma mark - private method
- (void)loadPassWordFormGateWay{
    __weak typeof(self) weakSelf = self;
    void(^compliteHander)(void) = ^{
        [weakSelf refreshButtonAction:weakSelf.refreshButton];
        [weakSelf.enableSwitch setOn:NO animated:NO];
        weakSelf.confirmButton.enabled = YES;
        weakSelf.passsWordLabel.textColor = weakSelf.unableColor;
    };
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"getting",@"plugin_gateway","获取中，请稍候...") modal:YES];
    [self.dataGetter fetchLumiDpfAesKeyWithSuccess:^(NSString *passWord, NSDictionary *result) {
        [[MHTipsView shareInstance] showFinishTips:NSLocalizedStringFromTable(@"get.succeed", @"plugin_gateway", @"获取成功") duration:1 modal:YES];
        if (passWord != nil && ![passWord isEqualToString:@""]){
            weakSelf.passsWordLabel.text = passWord;
            [weakSelf.enableSwitch setOn:YES animated:NO];
            weakSelf.confirmButton.enabled = YES;
            weakSelf.passsWordLabel.textColor = weakSelf.enableColor;
        }else{
            compliteHander();
        }
    } failure:^(NSError *error) {
        //信息获取失败
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"get.failed",@"plugin_gateway","获取失败") duration:0.3 modal:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *title = NSLocalizedStringFromTable(@"get.failed",@"plugin_gateway","获取失败");
            NSString *ok = NSLocalizedStringFromTable(@"Ok",@"plugin_gateway","确定");
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:ok style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf dissmissSelf];
            }];
            [vc addAction:action];
            [weakSelf presentViewController:vc animated:YES completion:nil];
        });
    }];
}

- (void)dissmissSelf{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma makr - configureLayout
- (void)configureLayout{
    
    [self.enableSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(topPadding * ScaleHeight);
        make.right.equalTo(self.view).offset(-rightPadding * ScaleWidth);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(leftPadding * ScaleWidth);
        make.centerY.equalTo(self.enableSwitch);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.enableSwitch.mas_bottom).offset(lineTopPadding * ScaleHeight);
        make.left.equalTo(self.view).offset(leftPadding * ScaleWidth);
        make.right.equalTo(self.view).offset(-rightPadding * ScaleWidth);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.refreshButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lineView.mas_bottom).offset(passWordTopPadding * ScaleHeight);
        make.right.equalTo(self.view).offset(-rightPadding * ScaleWidth);
        make.size.mas_equalTo(CGSizeMake(50, 30));
    }];
    
    [self.prefixLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(leftPadding * ScaleWidth);
        make.centerY.equalTo(self.refreshButton);
        make.size.mas_equalTo(self.prefixLabel.bounds.size);
    }];
    
    [self.passsWordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.prefixLabel.mas_right).offset(2 * ScaleWidth);
        make.right.equalTo(self.refreshButton.mas_left).offset(-passsWordRightPadding * ScaleWidth);
        make.centerY.equalTo(self.refreshButton);
    }];
    
    [self.contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passsWordLabel.mas_bottom).offset(contentTextViewTopPadding * ScaleHeight);
        make.left.equalTo(self.view).offset(leftPadding * ScaleWidth);
        make.right.equalTo(self.view).offset(-rightPadding * ScaleWidth);
        make.bottom.equalTo(self.buttonBgView.mas_top).offset(-(contentTextViewBottomPadding * ScaleHeight));
    }];
    
    [self.buttonBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-buttonBgViewBottomPadding * ScaleHeight);
        make.right.equalTo(self.view).offset(-rightPadding * ScaleWidth);
        make.left.equalTo(self.view).offset(leftPadding * ScaleWidth);
        make.height.mas_equalTo(buttonBgViewHeight);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.buttonBgView);
        make.right.equalTo(self.buttonBgView.mas_centerX);
        make.left.equalTo(self.buttonBgView).offset((buttonBgViewHeight * ScaleHeight)/2);
    }];
    
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.buttonBgView);
        make.left.equalTo(self.buttonBgView.mas_centerX);
        make.right.equalTo(self.buttonBgView).offset(-(buttonBgViewHeight * ScaleHeight)/2);
    }];
    
    [self.lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.centerX.equalTo(self.buttonBgView);
        make.width.mas_equalTo(0.5);
    }];
}


#pragma mark - getter and setter
- (UILabel *)titleLabel{
    if (!_titleLabel){
        _titleLabel = [[UILabel alloc] init];
        //TODO: 多语言
        _titleLabel.text = @"局域网通信协议";
    }
    return _titleLabel;
}

- (UISwitch *)enableSwitch{
    if (!_enableSwitch){
        _enableSwitch = [[UISwitch alloc] init];
        [_enableSwitch addTarget:self action:@selector(enableSwitchAction:) forControlEvents:UIControlEventValueChanged];
        [_enableSwitch setOn:NO animated:NO];
    }
    return _enableSwitch;
}

- (UIView *)lineView{
    if (!_lineView){
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
    }
    return _lineView;
}

- (UITextView *)contentTextView{
    if (!_contentTextView){
        _contentTextView = [[UITextView alloc] init];
        [_contentTextView setEditable:NO];
        _contentTextView.text = @"绿米多功能网关局域网通讯协议\n\n1. 开放本协议的目的是为了让不同厂家的设备能够互联互通，共同组建物联网。\n2. 用户可以把绿米的设备集成到homekit或其它现有系统中。\n3. 本协议只在局域网中通讯，使用的协议或机制主要有：udp协议，组播，AES加解密。\n4. 用户可以通过本协议获取到绿米传感器的数据，例如门窗的状态，家里有没有人，温湿度值等。\n5. 用户可以通过本协议控制绿米的插座、墙壁开关等设备（控制必须使用密钥）";
        _contentTextView.font = [UIFont systemFontOfSize:15];
    }
    return _contentTextView;
}

- (UILabel *)prefixLabel{
    if (!_prefixLabel){
        _prefixLabel = [[UILabel alloc] init];
        _prefixLabel.text = self.prefixStr;
        [_prefixLabel sizeToFit];
    }
    return _prefixLabel;
}

- (UILabel *)passsWordLabel{
    if (!_passsWordLabel){
        _passsWordLabel = [[UILabel alloc] init];
        _passsWordLabel.text = NSLocalizedStringFromTable(@"loading", @"plugin_gateway", @"加载中");
        _passsWordLabel.textColor = self.unableColor;
    }
    return _passsWordLabel;
}

- (NSString *)prefixStr{
    static NSString *str = @"密码：";
    return str;
}

- (UIButton *)refreshButton{
    if (!_refreshButton){
        _refreshButton = [[UIButton alloc] init];
        [_refreshButton setImage:[UIImage imageNamed:@"gateway_protocol_refresh"] forState:UIControlStateNormal];
        [_refreshButton addTarget:self action:@selector(refreshButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refreshButton;
}

- (UIView *)buttonBgView{
    if (!_buttonBgView){
        _buttonBgView = [[UIView alloc] init];
        _buttonBgView.backgroundColor = [UIColor whiteColor];
        _buttonBgView.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:0.5].CGColor;
        _buttonBgView.layer.borderWidth = 1.0;
        _buttonBgView.layer.cornerRadius = (buttonBgViewHeight * ScaleHeight)/2;
    }
    return _buttonBgView;
}

- (UIButton *)confirmButton{
    if (!_confirmButton){
        _confirmButton = [[UIButton alloc] init];
        [_confirmButton setTitle:NSLocalizedStringFromTable(@"Ok", @"plugin_gateway", @"确定") forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirmButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _confirmButton.enabled = NO;
        
    }
    return _confirmButton;
}

- (UIButton *)cancelButton{
    if (!_cancelButton){
        _cancelButton = [[UIButton alloc] init];
        [_cancelButton setTitle:NSLocalizedStringFromTable(@"Cancel", @"plugin_gateway", @"取消") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIView *)lineView2{
    if (!_lineView2){
        _lineView2 = [[UIView alloc] init];
        _lineView2.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
    }
    return _lineView2;
}


@end
