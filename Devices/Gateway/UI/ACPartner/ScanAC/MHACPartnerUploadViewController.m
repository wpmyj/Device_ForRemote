//
//  MHACPartnerUploadViewController.m
//  MiHome
//
//  Created by ayanami on 16/6/1.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerUploadViewController.h"
#import "MHLuTextField.h"
#import "MHACPartnerAddSucceedViewController.h"
#import "MHACTypeModel.h"

@interface MHACPartnerUploadViewController ()<UITextFieldDelegate>
@property (nonatomic, strong) MHDeviceAcpartner *acpartner;

@property (nonatomic, strong) UILabel *brandLabel;
@property (nonatomic, strong) UILabel *modelLabel;

@property (nonatomic, strong) MHLuTextField *brandField;
@property (nonatomic, strong) MHLuTextField *modelField;

@property (nonatomic, strong) UIButton *determineBtn;
@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, copy) NSString *brand;
@property (nonatomic, copy) NSString *model;

@end

@implementation MHACPartnerUploadViewController
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
    self.title = [NSString stringWithFormat:@"%@%@%@", NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.upload",@"plugin_gateway","上传"),NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.warningtips.green.one",@"plugin_gateway","空调"),NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.upload.brand",@"plugin_gateway","品牌")];
    self.isTabBarHidden = YES;
    
    UITapGestureRecognizer *tapHide = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nameFieldHide:)];
    [self.view addGestureRecognizer:tapHide];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[MHTipsView shareInstance] hide];
}

- (void)buildSubviews {
    [super buildSubviews];
 
    
    _brandLabel = [[UILabel alloc] init];
    _brandLabel.textAlignment = NSTextAlignmentCenter;
    _brandLabel.font = [UIFont systemFontOfSize:14.0f];
    _brandLabel.textColor = [MHColorUtils colorWithRGB:0x030303 alpha:0.7];
    _brandLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.upload.brand",@"plugin_gateway","品牌");
    [self.view addSubview:_brandLabel];
    
    _brandField = [[MHLuTextField alloc] init];
    _brandField.delegate = self;
//        _brandField.text = sel;
    XM_WS(weakself);
    if (self.acpartner.acTypeList.count) {
        [[self.acpartner.acTypeList lastObject] enumerateObjectsUsingBlock:^(MHACTypeModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            if (model.brand_id == weakself.acpartner.brand_id) {
                weakself.acpartner.ACBrand = [[MHLumiHtmlHandleTools sharedInstance] currentLanguageIsChinese] ? model.name : model.eng_name;
                weakself.brandField.text = weakself.acpartner.ACBrand;
                *stop = YES;
            }
        }];
    }
    _brandField.textColor = [MHColorUtils colorWithRGB:0x030303];
    _brandField.font = [UIFont systemFontOfSize:16];
    _brandField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _brandField.backgroundColor = [MHColorUtils colorWithRGB:0xffffff];
    _brandField.borderStyle = UITextBorderStyleRoundedRect;
    _brandField.layer.borderColor = [[MHColorUtils colorWithRGB:0xBCBCBC] CGColor];
    _brandField.returnKeyType = UIReturnKeyDone;

    [self.view addSubview:_brandField];
    
    
    _modelLabel = [[UILabel alloc] init];
    _modelLabel.textAlignment = NSTextAlignmentCenter;
    _modelLabel.font = [UIFont systemFontOfSize:14.0f];
    _modelLabel.textColor = [MHColorUtils colorWithRGB:0x030303 alpha:0.7];
    _modelLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.upload.model",@"plugin_gateway","模型");
    [self.view addSubview:_modelLabel];
    
  

    
    _modelField = [[MHLuTextField alloc] init];
    _modelField.delegate = self;
//    _modelField.text = [NSString stringWithFormat:@"%@-%@", @""];
    _modelField.textColor = [MHColorUtils colorWithRGB:0x030303];
    _modelField.font = [UIFont systemFontOfSize:16];
    _modelField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _modelField.backgroundColor = [MHColorUtils colorWithRGB:0xffffff];
    _modelField.borderStyle = UITextBorderStyleRoundedRect;
    _modelField.layer.borderColor = [[MHColorUtils colorWithRGB:0xBCBCBC] CGColor];
    _modelField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_modelField];

    
    //    NSString *nextStr =  [NSString stringWithFormat:@"%@(2/3)",NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.nextStep",@"plugin_gateway","下一步")];
    
    self.footerView = [[UIView alloc] init];
    self.footerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.footerView];
    
    _determineBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *nextStr = NSLocalizedStringFromTable(@"mydevice.setting.datepicker.ok",@"plugin_gateway","确认");
    NSMutableAttributedString *nextTitleAttribute = [[NSMutableAttributedString alloc] initWithString:nextStr];
    [nextTitleAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x858585] range:NSMakeRange(0, nextStr.length)];
    [nextTitleAttribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0f] range:NSMakeRange(0, nextStr.length)];
    [_determineBtn setAttributedTitle:nextTitleAttribute forState:UIControlStateNormal];
    [_determineBtn addTarget:self action:@selector(onDetermine:) forControlEvents:UIControlEventTouchUpInside];
    _determineBtn.layer.cornerRadius = 20.0f;
    _determineBtn.layer.borderWidth = 0.5f;
    _determineBtn.layer.borderColor = [[MHColorUtils colorWithRGB:0xBCBCBC] CGColor];
//    _determineBtn.backgroundColor = [MHColorUtils colorWithRGB:0x00ba7c];
    [self.view addSubview:_determineBtn];
    

    

    
}

- (void)buildConstraints {
    [super buildConstraints];
    XM_WS(weakself);
   
    CGFloat topSpacing = 80 * ScaleHeight;
    CGFloat labelFieldSpacing = 30 * ScaleHeight;
    CGFloat labelSpacing = 15 * ScaleHeight;
    
    [self.brandLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.view.mas_left).with.offset(20);
        make.top.equalTo(weakself.view).with.offset(topSpacing);
    }];
    
    [self.brandField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.brandLabel.mas_bottom).with.offset(labelSpacing);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake((WIN_WIDTH - 40), 40));
    }];
    
    [self.modelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.view.mas_left).with.offset(20);
        make.top.mas_equalTo(weakself.brandField.mas_bottom).with.offset(labelFieldSpacing);
    }];
    
    [self.modelField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.modelLabel.mas_bottom).with.offset(labelSpacing);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake((WIN_WIDTH - 40), 40));
    }];
    
    [self.footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(weakself.view);
        make.height.mas_equalTo(70);
    }];
    
    [self.determineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakself.view).with.offset(-15);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(WIN_WIDTH - 60, 40));
    }];
}

- (void)onDetermine:(id)sender {
    XM_WS(weakself);
    if (self.brand && self.model) {
//        [[MHTipsView shareInstance] showTips:@"" modal:NO];
//        [self.acpartner uploadBrandName:self.brand andBrandType:self.model Success:^(id obj) {
//            [[MHTipsView shareInstance] hide];
//            MHACPartnerAddSucceedViewController *succeedVC = [[MHACPartnerAddSucceedViewController alloc] initWithAcpartner:self.acpartner successType:UPLOAD_INDEX];
//            [weakself.navigationController pushViewController:succeedVC animated:YES];
//
//        } failure:^(NSError *error) {
//            NSLog(@"上傳失敗%@", error);
//            [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.upload.failure",@"plugin_gateway","上传失败") duration:1.5f modal:NO];
//        }];
//        [[MHTipsView shareInstance] hide];
        MHACPartnerAddSucceedViewController *succeedVC = [[MHACPartnerAddSucceedViewController alloc] initWithAcpartner:self.acpartner successType:UPLOAD_INDEX];
        [self.navigationController pushViewController:succeedVC animated:YES];

           }
    else {
        [[MHTipsView shareInstance] showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.upload.none",@"plugin_gateway","品牌和模型不能为空") duration:1.5f modal:YES];
    }
    
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    if ([NSStringFromClass([self.subDevice class]) isEqualToString:DeviceModelCtrlNeutral2ClassName]) {
//        if ([string isEqualToString:@"/"] || [string containsString:@"/"]) {
//            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"mydevice.changename.tips.invaildsymbol", @"plugin_gateway","设备名称包含非法字符&") duration:1.5 modal:NO];
//            return NO;
//        }
//    }
    //    BOOL enable = ([textField.text length] + [string length] - range.length) > 0;
    //    [self enableOk:enable];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.brandField) {
        self.brand = textField.text;
    }
    else {
        self.model = textField.text;
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    //    [self enableOk:NO];
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}



- (void)nameFieldHide:(id)sender {
    [_brandField resignFirstResponder];
    [_modelField resignFirstResponder];

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
