//
//  MHGatewaySceneLogFooterView.m
//  MiHome
//
//  Created by ayanami on 16/5/17.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewaySceneLogFooterView.h"

@interface MHGatewaySceneLogFooterView ()

@property (nonatomic, strong) UIButton *specialDayBtn;
@property (nonatomic, strong) UIImageView *arrowImage;

@end

@implementation MHGatewaySceneLogFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self buildSubViews];
    }
    return self;
}

- (void)buildSubViews {
    self.backgroundColor = [MHColorUtils colorWithRGB:0xefeff0];
//        self.backgroundColor = [UIColor whiteColor];
    
    self.specialDayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.specialDayBtn addTarget:self action:@selector(onChooseDate:) forControlEvents:UIControlEventTouchUpInside];
    NSString *str = [NSString stringWithFormat:@"%@",NSLocalizedStringFromTable(@"ifttt.scene.local.scene.log.title.datepicker", @"plugin_gateway", "跳转到指定日期")];
    NSMutableAttributedString *titleAttribute = [[NSMutableAttributedString alloc] initWithString:str];
    [titleAttribute addAttribute:NSForegroundColorAttributeName value:[MHColorUtils colorWithRGB:0x000000 alpha:0.8] range:NSMakeRange(0, str.length)];
    [titleAttribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0f] range:NSMakeRange(0, str.length)];
    [self.specialDayBtn setAttributedTitle:titleAttribute forState:UIControlStateNormal];
    self.specialDayBtn.frame = CGRectMake((WIN_WIDTH - 100) / 2, 10, 100, 40);
    [self addSubview:self.specialDayBtn];
    
    self.arrowImage = [[UIImageView alloc] init];
    UIImage *arrow = [UIImage imageNamed:@"gateway_up_arrow"];
    self.arrowImage.image = arrow;
    self.arrowImage.frame = CGRectMake(WIN_WIDTH / 2 + 50, 25, 20, 10);
    UITapGestureRecognizer *arrowTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onChooseDate:)];
    [self.arrowImage addGestureRecognizer:arrowTap];
    self.arrowImage.userInteractionEnabled = YES;
    [self addSubview:self.arrowImage];
    
    
    UIControl *bgControl = [[UIControl alloc] initWithFrame:CGRectMake((WIN_WIDTH - 100) / 2, 10, 140, 40)];
//    bgControl
    
}



- (void)onChooseDate:(id)sender {
    if (self.selectDateClick) {
        self.selectDateClick();
    }
}

@end
