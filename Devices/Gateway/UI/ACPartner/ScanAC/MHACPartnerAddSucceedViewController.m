//
//  MHACPartnerAddSucceedViewController.m
//  MiHome
//
//  Created by ayanami on 16/5/22.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerAddSucceedViewController.h"
#import "MHACPartnerUploadViewController.h"
#import "MHACPartnerReMatchViewController.h"

@interface MHACPartnerAddSucceedViewController ()
@property (nonatomic, strong) MHDeviceAcpartner *acpartner;

@property (nonatomic, strong) UIButton *determineBtn;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIImageView *succeedView;
@property (nonatomic, strong) UIImageView *failedView;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UILabel *rematchLabel;

@property (nonatomic, strong) UIButton *retryButton;
@property (nonatomic, strong) UIButton *uploadButton;


@property (nonatomic, assign) ACPARTNER_SUCCEED_TYPE type;

@end

@implementation MHACPartnerAddSucceedViewController

- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner successType:(ACPARTNER_SUCCEED_TYPE)type
{
    self = [super init];
    if (self) {
        self.type = type;
        self.acpartner = acpartner;
        self.controllerIdentifier = [NSString stringWithFormat:@"matchResult_%ld", self.type];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
       self.isTabBarHidden = YES;
    
}
- (void)buildSubviews {
    [super buildSubviews];
    
      //    "mydevice.gateway.sensor.acpartner.add.upload" = "上传";
    //    "mydevice.gateway.sensor.acpartner.add.upload.brand" = "品牌";
    //    "mydevice.gateway.sensor.acpartner.add.upload.model" = "模型";
    //    "mydevice.gateway.sensor.acpartner.add.upload.succeed" = "上传成功";
   
    
    _succeedView = [[UIImageView alloc] init];
    [_succeedView setImage:[UIImage imageNamed:@"gateway_addsub_succeed"]];
    [self.view addSubview:_succeedView];
    
    
    _failedView = [[UIImageView alloc] init];
    [_failedView setImage:[UIImage imageNamed:@"gateway_addsub_failed"]];
    [self.view addSubview:_failedView];
    
    self.tipsLabel = [[UILabel alloc] init];
    self.tipsLabel.textAlignment = NSTextAlignmentCenter;
    self.tipsLabel.textColor = [UIColor blackColor];
    self.tipsLabel.font = [UIFont systemFontOfSize:14.0f];
    self.tipsLabel.numberOfLines = 0;
    
    [self.view addSubview:self.tipsLabel];

    
 
    
    
    //    NSString *nextStr =  [NSString stringWithFormat:@"%@(2/3)",NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.nextStep",@"plugin_gateway","下一步")];
    
    self.footerView = [[UIView alloc] init];
    self.footerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.footerView];
    
    self.rematchLabel = [[UILabel alloc] init];
    self.rematchLabel.textAlignment = NSTextAlignmentCenter;
    self.rematchLabel.textColor = [MHColorUtils colorWithRGB:0x030303 alpha:0.3];
    self.rematchLabel.font = [UIFont systemFontOfSize:14.0f];
    self.rematchLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.succeed.tips",@"plugin_gateway","如果当前控制不好用,请在更多设置中重新匹配空调");
    [self.view addSubview:self.rematchLabel];
    self.rematchLabel.hidden = YES;
    

    _uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _uploadButton.frame = CGRectMake(30, WIN_HEIGHT - 56, (WIN_WIDTH - 60) / 2, 46);
    [_uploadButton addTarget:self action:@selector(onDetermine:) forControlEvents:UIControlEventTouchUpInside];
    _uploadButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_uploadButton setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:UIControlStateNormal];
    [_uploadButton setBackgroundImage:[UIImage imageNamed:@"acpartner_btn_left"] forState:UIControlStateNormal];
        [_uploadButton setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.remotematch.failure",@"plugin_gateway","尝试其他方法") forState:UIControlStateNormal];
    _uploadButton.hidden = YES;
    
    
    [self.view addSubview:_uploadButton];
    
    _retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _retryButton.frame = CGRectMake(30 + (WIN_WIDTH - 60) / 2, WIN_HEIGHT - 56, (WIN_WIDTH - 60) / 2, 46);
    [_retryButton addTarget:self action:@selector(onUpload:) forControlEvents:UIControlEventTouchUpInside];
    _retryButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_retryButton setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:UIControlStateNormal];
    [_retryButton setBackgroundImage:[UIImage imageNamed:@"acpartner_btn_right"] forState:UIControlStateNormal];
        [_retryButton setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.upload",@"plugin_gateway","上传") forState:UIControlStateNormal];
    _retryButton.hidden = YES;
    [self.view addSubview:_retryButton];
    
    
    _determineBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *nextStr = NSLocalizedStringFromTable(@"done",@"plugin_gateway","完成");
    switch (self.type) {
        case ADD_SUCCESS_INDEX: {
            self.succeedView.hidden = NO;
            self.failedView.hidden = YES;
            self.rematchLabel.hidden = NO;
            self.tipsLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.succeed.title",@"plugin_gateway","恭喜,您已经成功匹配空调");
            self.title  = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.succeed",@"plugin_gateway","匹配成功");

        }
            
            break;
        case ADD_AUTO_FAILURE_INDEX: {
            self.succeedView.hidden = YES;
            self.failedView.hidden = NO;
//            nextStr = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.upload",@"plugin_gateway","尝试其他匹配方式");
            nextStr = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.remotematch.failure",@"plugin_gateway","尝试其他方法");
            self.tipsLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.failure.tips",@"plugin_gateway","实在抱歉 , 没有匹配的空调类型. 请尝试其他匹配方式");
            self.title  = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.failure",@"plugin_gateway","匹配失败");

        }
            
            break;
        case ADD_OTHER_FAILURE_INDEX: {
            self.succeedView.hidden = YES;
            self.failedView.hidden = NO;
//            nextStr = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.upload",@"plugin_gateway","上传");
            
//            self.tipsLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.failure.title",@"plugin_gateway","是在抱歉,没有匹配的空调类型.请尝试其他匹配方式");
            self.determineBtn.hidden = YES;
            self.retryButton.hidden = NO;
            self.uploadButton.hidden = NO;
            self.tipsLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.failure.tips",@"plugin_gateway","实在抱歉 , 没有匹配的空调类型. 请尝试其他匹配方式");
            self.title  = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.failure",@"plugin_gateway","匹配失败");
            
        }
            
            break;
        case UPLOAD_INDEX: {
            self.succeedView.hidden = NO;
            self.failedView.hidden = YES;
            self.title  = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.upload.succeed",@"plugin_gateway","上传成功");
            self.tipsLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.add.upload.succeed",@"plugin_gateway","上传成功");
        }
            break;
            
        default:
            break;
    }

    NSMutableAttributedString *nextTitleAttribute = [[NSMutableAttributedString alloc] initWithString:nextStr];
    [nextTitleAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x858585] range:NSMakeRange(0, nextStr.length)];
    [nextTitleAttribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0f] range:NSMakeRange(0, nextStr.length)];
    [_determineBtn setAttributedTitle:nextTitleAttribute forState:UIControlStateNormal];
    [_determineBtn addTarget:self action:@selector(onDetermine:) forControlEvents:UIControlEventTouchUpInside];
    _determineBtn.layer.cornerRadius = 20.0f;
    _determineBtn.layer.borderWidth = 0.5f;
    _determineBtn.layer.borderColor = [[MHColorUtils colorWithRGB:0xBCBCBC] CGColor];
    [self.view addSubview:_determineBtn];
    
    


    
    

}

- (void)buildConstraints {
    [super buildConstraints];
    
    XM_WS(weakself);
    
    CGFloat leadSpacing = 200 * ScaleHeight;
    

    [self.failedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.view).with.offset(leadSpacing);
        make.centerX.equalTo(weakself.view);
    }];
    
    [self.succeedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.view).with.offset(leadSpacing);
        make.centerX.equalTo(weakself.view);
    }];
    
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.succeedView.mas_bottom).with.offset(50);
        make.centerX.equalTo(weakself.view);
        make.width.mas_equalTo(WIN_WIDTH - 60);
    }];
    
    
    [self.footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(weakself.view);
        make.height.mas_equalTo(70);
    }];
    
    
    [self.rematchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakself.view.mas_bottom).with.offset(-110);
        make.centerX.equalTo(weakself.view);
        make.width.mas_equalTo(WIN_WIDTH - 60);
    }];
    
    
    [self.determineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakself.view.mas_bottom).with.offset(-15);
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(WIN_WIDTH - 60, 46));
    }];
    
    

    
}

- (void)onDetermine:(id)sender {
    XM_WS(weakself);
    switch (self.type) {
        case ADD_SUCCESS_INDEX: {
            [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([NSStringFromClass([obj class]) isEqualToString:@"MHACPartnerMainViewController"]) {
                    [weakself.navigationController popToViewController:obj animated:YES];
                    *stop = YES;
                }
            }];
            [self gw_clickMethodCountWithStatType:@"matchSucceed:"];
        }
            
            break;
        case ADD_AUTO_FAILURE_INDEX: {
            MHACPartnerReMatchViewController *uploadVC = [[MHACPartnerReMatchViewController alloc] initWithAcpartner:self.acpartner type:MATCH_FAILURE_INDEX];
            [self.navigationController pushViewController:uploadVC animated:YES];
            [self gw_clickMethodCountWithStatType:@"tryAnotherWay:"];
        }
            break;
        case ADD_OTHER_FAILURE_INDEX: {
            MHACPartnerReMatchViewController *uploadVC = [[MHACPartnerReMatchViewController alloc] initWithAcpartner:self.acpartner type:MATCH_FAILURE_INDEX];
            [self.navigationController pushViewController:uploadVC animated:YES];
            [self gw_clickMethodCountWithStatType:@"tryAnotherWay:"];
        }
            break;
        case UPLOAD_INDEX: {
            [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([NSStringFromClass([obj class]) isEqualToString:@"MHACPartnerMainViewController"]) {
                    [weakself.navigationController popToViewController:obj animated:YES];
                    *stop = YES;
                }
            }];
        }
            break;
            
        default:
            break;
    }

}

- (void)onUpload:(id)sender {
    MHACPartnerUploadViewController *uploadVC = [[MHACPartnerUploadViewController alloc] init];
    [self.navigationController pushViewController:uploadVC animated:YES];
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
