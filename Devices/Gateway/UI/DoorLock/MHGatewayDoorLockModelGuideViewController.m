//
//  MHGatewayDoorLockModelGuideViewController.m
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/7.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayDoorLockModelGuideViewController.h"
#import "MHWeakTimerFactory.h"

@interface MHGatewayDoorLockModelGuideViewController()
@property (nonatomic, strong) UIImageView *guideImageView;
@property (nonatomic, strong) UILabel *guideLabel;
@property (nonatomic, strong) NSTimer *loopTimer;
@property (nonatomic, assign) BOOL result;
@end

@implementation MHGatewayDoorLockModelGuideViewController

- (void)dealloc{
    [_loopTimer invalidate];
    _loopTimer = nil;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.isTabBarHidden = YES;
    self.result = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self fireTimer];
}

#pragma mark - private function
- (void)fireTimer{
    if (self.loopTimer){
        [self.loopTimer invalidate];
    }
    __weak typeof(self) weakself = self;
    self.loopTimer = [MHWeakTimerFactory scheduledTimerWithBlock:5 callback:^{
        [weakself invalidateTimer];
    }];
}

- (void)invalidateTimer{
    [self.loopTimer invalidate];
    self.loopTimer = nil;
    if ([self.delegate respondsToSelector:@selector(doorLockModelGuideViewController:handlerWithResult:)]){
        [self.delegate doorLockModelGuideViewController:self handlerWithResult:self.result];
    }
}

#pragma mark -

- (void)buildSubviews{
    [super buildSubviews];
    [self.view addSubview:self.guideImageView];
    [self.view addSubview:self.guideLabel];
    [self addLayout];
}

- (void)addLayout{
    [self.guideImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_centerY).mas_offset(-5);
    }];
    
    [self.guideLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_centerY).mas_offset(5);
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view).multipliedBy(0.8);
    }];
}

#pragma mark - getter and setter
- (UILabel *)guideLabel{
    if (!_guideLabel) {
        NSString *test = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_add_singleNeutral.color",@"plugin_gateway", "蓝灯闪烁");
        NSString *str = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide_add_singleNeutral",@"plugin_gateway","请按一下设备按钮后松开");
        NSMutableAttributedString *todayCountTailAttribute = [[NSMutableAttributedString alloc] initWithString:str];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        
        [paragraphStyle setLineSpacing:5];//调整行间距
        
        [todayCountTailAttribute addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
        [todayCountTailAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x1084c1] range:[str rangeOfString:test]];
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:15 * ScaleWidth];
        label.textColor = [MHColorUtils colorWithRGB:0x333333];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.attributedText = todayCountTailAttribute;
        _guideLabel = label;
    }
    return _guideLabel;
}

- (UIImageView *)guideImageView{
    if (!_guideImageView) {
        UIImageView *aImv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gateway_singleNeutral_reset"]];
        _guideImageView = aImv;
    }
    return _guideImageView;
}

@end
