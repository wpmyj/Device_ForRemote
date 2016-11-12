//
//  MHGatewaySceneTitleView.m
//  MiHome
//
//  Created by ayanami on 16/5/17.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewaySceneTitleView.h"

@interface MHGatewaySceneTitleView ()

@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation MHGatewaySceneTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self buildSubViews];
        UIGestureRecognizer *tapBgViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDeviceMenu:)];
        [self addGestureRecognizer:tapBgViewGesture];
    }
    return self;
}

- (void)buildSubViews {
//    self.backgroundColor = [UIColor whiteColor];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [MHColorUtils colorWithRGB:0x000000 alpha:0.8];
    self.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    self.titleLabel.text = NSLocalizedStringFromTable(@"ifttt.scene.log", @"plugin_gateway", "自动化日志");
    [self addSubview:self.titleLabel];
    
    XM_WS(weakself);
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(weakself);
            make.height.equalTo(weakself);
        }];
    

    
    
    self.arrowImageView = [[UIImageView alloc] init];
    self.arrowImageView.image = [UIImage imageNamed:@"lumi_scene_log_bottomarrow"];
    [self addSubview:self.arrowImageView];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(weakself.titleLabel.mas_right).with.offset(3);
                make.centerY.equalTo(weakself);
                make.size.mas_equalTo(CGSizeMake(13, 9));
            }];
}



- (void)onDeviceMenu:(id)sender {
    if (self.chooseDeviceClick) {
        self.chooseDeviceClick();
    }
}

- (void)updateDeviceName:(NSString *)name arrowImage:(NSString *)imageName {
    if (name) {
        self.titleLabel.text = name;
    }
    self.arrowImageView.image = [UIImage imageNamed:imageName];
    [self setNeedsLayout];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.center = CGPointMake(self.superview.center.x, self.center.y);
}

@end
