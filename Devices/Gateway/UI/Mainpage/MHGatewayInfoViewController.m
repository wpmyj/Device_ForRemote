//
//  MHGatewayInfoViewController.m
//  MiHome
//
//  Created by LM21Mac002 on 16/9/13.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayInfoViewController.h"
#import "MHGatewayProtocolViewController.h"

@interface MHGatewayInfoViewController ()
@property (nonatomic, strong) UITextView *contentTextView;
@property (nonatomic, strong) UIView *buttonBgView;
@property (nonatomic, strong) UIButton *copyButton;
@property (nonatomic, strong) UIButton *encryptionButton;
@property (nonatomic, strong) UIView *lineView2;
@property (atomic, copy) NSString *zigbeeChannel;
@property (atomic, copy) NSString *gatewayInfo;
@end

@implementation MHGatewayInfoViewController
static CGFloat leftPadding = 20;
static CGFloat rightPadding = 20;
static CGFloat topPadding = 84;
static CGFloat buttonBgViewBottomPadding = 20;
static CGFloat contentTextViewBottomPadding = 10;
static CGFloat buttonBgViewHeight = 50;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.isTabBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    //TODO: 多语言
    self.title = @"绿米网关";
    [self.view addSubview:self.buttonBgView];
    [self.view addSubview:self.contentTextView];
    [self.buttonBgView addSubview:self.encryptionButton];
    [self.buttonBgView addSubview:self.copyButton];
    [self.buttonBgView addSubview:self.lineView2];
    [self configureLayout];
    [self loadData];
}

#pragma mark - event response
- (void)copyButtonAction:(UIButton *)sender{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.contentTextView.text;
    [[MHTipsView shareInstance] showFinishTips:NSLocalizedStringFromTable(@"done", @"plugin_gateway", @"完成") duration:1 modal:YES];
}

- (void)encryptionButtonAction:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(gatewayInfoViewController:didTapEncryptionButton:)]){
        [self.delegate gatewayInfoViewController:self didTapEncryptionButton:sender];
    }
}

#pragma mark - private method
- (void)loadData{
    //转菊
    __weak typeof(self) weakSelf = self;
    void(^completeHander)(void) = ^{
        if (self.zigbeeChannel && self.gatewayInfo){
            //停止转菊且显示
            weakSelf.contentTextView.text = [weakSelf fetchContentText];
            weakSelf.encryptionButton.enabled = YES;
            weakSelf.copyButton.enabled = YES;
        }
    };
    NSLog(@"%@",self.gatewayInfoGetter);
    [self.gatewayInfoGetter fetchZigbeeChannelWithSuccess:^(NSString *channel, NSDictionary *result) {
        weakSelf.zigbeeChannel = channel;
        completeHander();
    } failure:^(NSError *error) {
        weakSelf.zigbeeChannel = @" ";
        completeHander();
    }];
    
    [self.gatewayInfoGetter fetchGatewayInfoWithSuccess:^(NSString *gatewayInfo, NSDictionary *result) {
        weakSelf.gatewayInfo = gatewayInfo;
        completeHander();
    } failure:^(NSError *error) {
        weakSelf.gatewayInfo = @" ";
        completeHander();
    }];
}

- (NSString *)fetchContentText{
    NSMutableString *contentStr = [NSMutableString string];
    [contentStr appendString:[NSString stringWithFormat:@"网关ID: %@\n",[self.gatewayInfoGetter gatewayId]]];
    [contentStr appendString:[NSString stringWithFormat:@"Zigbee通道: %@\n",self.zigbeeChannel]];
    [contentStr appendString:[NSString stringWithFormat:@"网关信息: \n%@\n",self.gatewayInfo]];
    [contentStr appendString:[NSString stringWithFormat:@"子设备信息: \n%@\n",[self.gatewayInfoGetter subDevicesInfo]]];
    return contentStr;
}

#pragma makr - configureLayout
- (void)configureLayout{
    
    [self.contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(leftPadding * ScaleWidth);
        make.right.equalTo(self.view).offset(-rightPadding * ScaleWidth);
        make.top.equalTo(self.view).offset(topPadding * ScaleHeight);
        make.bottom.equalTo(self.buttonBgView.mas_top).offset(-(contentTextViewBottomPadding * ScaleHeight));
    }];
    
    [self.buttonBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-buttonBgViewBottomPadding * ScaleHeight);
        make.right.equalTo(self.view).offset(-rightPadding * ScaleWidth);
        make.left.equalTo(self.view).offset(leftPadding * ScaleWidth);
        make.height.mas_equalTo(buttonBgViewHeight);
    }];
    
    [self.encryptionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.buttonBgView);
        make.right.equalTo(self.buttonBgView.mas_centerX);
        make.left.equalTo(self.buttonBgView).offset((buttonBgViewHeight * ScaleHeight)/2);
    }];
    
    [self.copyButton mas_makeConstraints:^(MASConstraintMaker *make) {
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
- (UITextView *)contentTextView{
    if (!_contentTextView){
        _contentTextView = [[UITextView alloc] init];
        [_contentTextView setEditable:NO];
        _contentTextView.font = [UIFont systemFontOfSize:15];
        _contentTextView.textAlignment = NSTextAlignmentCenter;
        _contentTextView.text = NSLocalizedStringFromTable(@"loading", @"plugin_gateway", @"加载中");
    }
    return _contentTextView;
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

- (UIButton *)copyButton{
    if (!_copyButton){
        _copyButton = [[UIButton alloc] init];
        //TODO: 多语言
        [_copyButton setTitle:@"复制" forState:UIControlStateNormal];
        [_copyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_copyButton addTarget:self action:@selector(copyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _copyButton.enabled = NO;
        
    }
    return _copyButton;
}

- (UIButton *)encryptionButton{
    if (!_encryptionButton){
        _encryptionButton = [[UIButton alloc] init];
        //TODO: 多语言
        [_encryptionButton setTitle:@"加密" forState:UIControlStateNormal];
        [_encryptionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_encryptionButton addTarget:self action:@selector(encryptionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _encryptionButton;
}

- (UIView *)lineView2{
    if (!_lineView2){
        _lineView2 = [[UIView alloc] init];
        _lineView2.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
    }
    return _lineView2;
}


@end
