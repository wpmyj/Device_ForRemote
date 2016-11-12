//
//  MHACCustomRemoteNameViewController.m
//  MiHome
//
//  Created by ayanami on 16/7/26.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACCustomRemoteNameViewController.h"
#import "MHACAddRemoteSucceedViewController.h"
#import "MHLuTextField.h"
#import "MHLumiSensorFooterView.h"

@interface MHACCustomRemoteNameViewController ()<UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) MHDeviceAcpartner *acpartner;
@property (nonatomic, strong) UIButton *determineBtn;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) MHLuTextField *nameField;
@property (nonatomic, strong) UILabel *tipText;
@property (nonatomic, strong) UILabel *tipTitle;


@property (nonatomic, copy) NSString *selectName;
@property (nonatomic, copy) NSString *identify;


@end

@implementation MHACCustomRemoteNameViewController
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
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.addremote.rename.title",@"plugin_gateway","设置按键名");
    UITapGestureRecognizer *tapHide = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nameFieldHide:)];
    tapHide.delegate = self;
    [self.view addGestureRecognizer:tapHide];

  
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    
}

- (void)buildSubviews {
    [super buildSubviews];
    
    _determineBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *nextStr = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.nextStep",@"plugin_gateway","下一步");
    //    NSMutableAttributedString *nextTitleAttribute = [[NSMutableAttributedString alloc] initWithString:nextStr];
    //    [nextTitleAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x858585] range:NSMakeRange(0, nextStr.length)];
    //    [nextTitleAttribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0f] range:NSMakeRange(0, nextStr.length)];
    //    [_determineBtn setAttributedTitle:nextTitleAttribute forState:UIControlStateNormal];
    [_determineBtn setTitle:nextStr forState:UIControlStateNormal];
    [_determineBtn addTarget:self action:@selector(onDetermine:) forControlEvents:UIControlEventTouchUpInside];
    _determineBtn.layer.cornerRadius = 20.0f;
    _determineBtn.layer.borderWidth = 0.5f;
    _determineBtn.layer.borderColor = [[MHColorUtils colorWithRGB:0xBCBCBC] CGColor];
    _determineBtn.backgroundColor = [MHColorUtils colorWithRGB:0x00ba7c];
    [_determineBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:_determineBtn];
    

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [MHColorUtils colorWithRGB:0x000000];
    self.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.addremote.rename.caption",@"plugin_gateway","添加遥控器按键");
    [self.view addSubview:self.titleLabel];

       
    _nameField = [[MHLuTextField alloc] init];
    _nameField.delegate = self;
    _nameField.textColor = [MHColorUtils colorWithRGB:0x000000];
    _nameField.font = [UIFont systemFontOfSize:16];
    _nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _nameField.backgroundColor = [MHColorUtils colorWithRGB:0xffffff];
    _nameField.borderStyle = UITextBorderStyleRoundedRect;
    _nameField.layer.borderColor = [[MHColorUtils colorWithRGB:0xBCBCBC] CGColor];
    _nameField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_nameField];
    
    self.tipTitle = [[UILabel alloc] init];
    self.tipTitle.textAlignment = NSTextAlignmentLeft;
    self.tipTitle.font = [UIFont systemFontOfSize:14.0f];
    NSString *red = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.addremote.rename.tips.title",@"plugin_gateway", "注 :");

    NSMutableAttributedString *todayCountTailAttribute = [[NSMutableAttributedString alloc] initWithString:red];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragraphStyle setLineSpacing:5];//调整行间距
    
    [todayCountTailAttribute addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [red length])];
    [todayCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[red rangeOfString:red]];
    self.tipTitle.attributedText = todayCountTailAttribute;
    [self.view addSubview:self.tipTitle];
    

    self.tipText = [[UILabel alloc] init];
    self.tipText.textAlignment = NSTextAlignmentLeft;
    self.tipText.font = [UIFont systemFontOfSize:16.0f];
    self.tipText.numberOfLines = 0;
    self.tipText.text = [NSString stringWithFormat:@"   %@", NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.addremote.rename.tips.text",@"plugin_gateway", "部分空调指示灯开关是不同的红外码,需要添加两次")];
    [self.view addSubview:self.tipText];
    


  
    
}

- (void)buildConstraints {
    [super buildConstraints];
    
    XM_WS(weakself);
    CGFloat labelSpacingV = 100 * ScaleHeight;
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
    
    [self.tipTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.view);
        make.left.mas_equalTo(weakself.view.mas_left).with.offset(fieldSpacingH);
        make.top.mas_equalTo(weakself.nameField.mas_bottom).with.offset(labelSpacingV);
        make.width.mas_equalTo(WIN_WIDTH - fieldSpacingH * 2);
    }];
    
    
    [self.tipText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.view);
        make.left.mas_equalTo(weakself.view.mas_left).with.offset(fieldSpacingH);
        make.top.mas_equalTo(weakself.tipTitle.mas_bottom).with.offset(5);
        make.width.mas_equalTo(WIN_WIDTH - fieldSpacingH * 2);
    }];
    
    [self.determineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakself.view).with.offset(-btnSpacingV);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(WIN_WIDTH - 60, 46));
    }];
}


#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
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

#pragma mark - 收起键盘
- (void)nameFieldHide:(id)sender {
    [_nameField resignFirstResponder];
}

- (void)onDetermine:(id)sender {
    if (!self.nameField.text) {
        [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.addremote.rename.nono",@"plugin_gateway","按键名不能为空") duration:1.5f modal:YES];
        return;
    }
    
    if ([self checkRepeat:self.nameField.text]) {
        [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.addremote.rename.caption.conflict",@"plugin_gateway","按键名与已有按键重名,请重新输入") duration:1.5f modal:YES];
        return;
    }
    self.selectName = self.nameField.text;

    [self handleNewRemoteData];
    [self gw_clickMethodCountWithStatType:@"remaneRemoteButton:"];

    MHACAddRemoteSucceedViewController *remoteVC = [[MHACAddRemoteSucceedViewController alloc] init];
    remoteVC.selectName = self.selectName;
    [self.navigationController pushViewController:remoteVC animated:YES];
}


- (void)handleNewRemoteData {
    
    NSMutableDictionary *newFunction = [NSMutableDictionary new];
    [newFunction setObject:self.selectName forKey:@"name"];
    NSString *strCmd = [self.acpartner getACCommand:CUSTOM_FUNCTION_INDEX commandIndex:POWER_COMMAND isTimer:NO];
    NSLog(@"%@", strCmd);
    [newFunction setObject:strCmd forKey:@"shortCmd"];
    [newFunction setObject:self.cmd forKey:@"cmd"];
    
    XM_WS(weakself);
    //先同步服务器的
    [self.acpartner getLearnedRemoteListSuccess:^(id obj) {
        
        //编辑
        [weakself.acpartner.customFunctionList addObject:newFunction];
        
        [weakself.acpartner editLearnedRemoteList:weakself.acpartner.customFunctionList success:^(id obj) {
            NSDictionary *sourceDic =  [weakself updateNewFooterResource:weakself.acpartner.customFunctionList];
//            if (weakself.addCustomFucntion) {
//                weakself.addCustomFucntion(sourceDic);
//            }
            [[NSNotificationCenter defaultCenter] postNotificationName:AddRemoteNotiName object:nil userInfo:sourceDic];

            [[MHTipsView shareInstance] hide];
                     
            
        } failure:^(NSError *v) {
            [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"operation.failed",@"plugin_gateway","操作失败, 请检查网络") duration:1.5f modal:NO];
        }];
    } failure:^(NSError *v) {
        [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"operation.failed",@"plugin_gateway","操作失败, 请检查网络") duration:1.5f modal:NO];
        
        //        [[MHTipsView shareInstance] showTipsInfo:@"添加失败请重试" duration:1.5f modal:NO];
        
    }];
    [[MHTipsView shareInstance] showTips:@"" modal:YES];
}

- (NSDictionary *)updateNewFooterResource:(NSArray *)tempArray {
    NSDictionary *source = nil;
    NSMutableArray *imageArray = [NSMutableArray arrayWithArray:@[ @"gateway_plug_kaion", @"acpartner_device_delay", @"acpartner_device_coolspeed", @"acpartner_device_sleep", @"acpartner_device_swing", @"acpartner_device_winds", @"acpartner_device_mode"]];
    NSMutableArray *nameArray = [NSMutableArray arrayWithArray:@[ NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.switch",@"plugin_gateway","开关"), NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.footer.delayoff",@"plugin_gateway","延时关"), NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.footer.coolmode",@"plugin_gateway","速冷设置"), NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.footer.sleepmode",@"plugin_gateway","睡眠设置"),NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.airswing",@"plugin_gateway","扫风"),NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.fanspeed",@"plugin_gateway","风速"), NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.mode",@"plugin_gateway","模式")]];
    
    if ([self.acpartner isExtraRemoteId]) {
        [imageArray addObject:@"acpartner_device_led"];
        [nameArray addObject:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.footer.led",@"plugin_gateway","灯光")];
    }
    
    NSUInteger limitCount = [self.acpartner isExtraRemoteId] ? 5 : 6;
    //无速冷
    //    NSMutableArray *imageArray = [NSMutableArray arrayWithArray:@[ @"gateway_plug_kaion", @"acpartner_device_delay", @"acpartner_device_sleep", @"acpartner_device_winds", @"acpartner_device_mode"]];
    //    NSMutableArray *nameArray = [NSMutableArray arrayWithArray:@[ NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.switch",@"plugin_gateway","开关"), @"延时关", @"睡眠模式",NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.fanspeed",@"plugin_gateway","风速"), NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.mode",@"plugin_gateway","模式")]];
    
    [tempArray enumerateObjectsUsingBlock:^(NSDictionary *function, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![function isKindOfClass:[NSDictionary class]]) {
            return;
        }
        [imageArray addObject:@"acpartner_device_common"];
        [nameArray addObject:function[kACNameKey]];
        if (idx == limitCount) {
            *stop = YES;
        }
    }];
    [imageArray addObjectsFromArray:@[@"acpartner_device_add", @"acpartner_device_delete"]];
    [nameArray addObjectsFromArray:@[NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.footer.addremote",@"plugin_gateway","添加按键"), NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.footer.deleteremote",@"plugin_gateway","删除按键")]];
    source = @{ kIMAGENAMEKEY : imageArray, kTEXTKEY : nameArray };
    return source;
}

- (BOOL)checkRepeat:(NSString *)newName {
    __block BOOL isRepeat = NO;
    NSMutableArray *nameArray = [NSMutableArray arrayWithArray:@[ NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.switch",@"plugin_gateway","开关"), NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.footer.delayoff",@"plugin_gateway","延时关"), NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.footer.coolmode",@"plugin_gateway","速冷设置"), NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.footer.sleepmode",@"plugin_gateway","睡眠设置"),NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.airswing",@"plugin_gateway","扫风"),NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.fanspeed",@"plugin_gateway","风速"), NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.mode",@"plugin_gateway","模式"),NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.footer.addremote",@"plugin_gateway","添加按键"), NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.footer.deleteremote",@"plugin_gateway","删除按键")]];
    
    if ([self.acpartner isExtraRemoteId]) {
        [nameArray addObject:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.footer.led",@"plugin_gateway","灯光")];
    }
    
    //无速冷
//    NSMutableArray *nameArray = [NSMutableArray arrayWithArray:@[ NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.switch",@"plugin_gateway","开关"), @"延时关", @"睡眠模式",NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.fanspeed",@"plugin_gateway","风速"), NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.mode",@"plugin_gateway","模式")]];
    
    [self.acpartner.customFunctionList enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {
        [nameArray addObject:dic[kACNameKey]];
    }];
    
    [nameArray enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([name isEqualToString:newName]) {
            isRepeat = YES;
            *stop = YES;
        }
    }];
    
    
    return isRepeat;
}
@end
