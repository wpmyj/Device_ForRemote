//
//  MHGatewayHTUnusualeView.m
//  MiHome
//
//  Created by ayanami on 16/6/3.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayHTUnusualeView.h"

@interface MHGatewayHTUnusualeView ()

@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UIImageView *closeImageView;

@end

@implementation MHGatewayHTUnusualeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self buildSubviews];
    }
    return self;
}

- (void)buildSubviews {
    
    self.backgroundColor = [MHColorUtils colorWithRGB:0x000000 alpha:0.2];
    
    XM_WS(weakself);
    _closeImageView = [[UIImageView alloc] init];
    UIImage *image = [UIImage imageNamed:@"ht_unusual_error"];
    _closeImageView.image = image;
    UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClose:)];
    [self.closeImageView addGestureRecognizer:closeTap];
    _closeImageView.userInteractionEnabled = YES;
    
    [self addSubview:_closeImageView];
    [self.closeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(image.size);
        make.right.mas_equalTo(weakself.mas_right).with.offset(-20);
        make.centerY.equalTo(weakself);
    }];
    
    
    _tipsLabel = [[UILabel alloc] init];
    _tipsLabel.font = [UIFont systemFontOfSize:16];
    _tipsLabel.textColor = [MHColorUtils colorWithRGB:0xffffff];
    _tipsLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.unusualtips",@"plugin_gateway","电池将很快耗尽,因超出-20~60℃的工作范围");
    [self addSubview:_tipsLabel];
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakself);
        make.left.mas_equalTo(weakself.mas_left).with.offset(20);
        make.right.mas_equalTo(weakself.closeImageView.mas_left).with.offset(10);
    }];
}


- (void)updateTipsText:(HT_TIPSTEXT_TYPE)type {
    self.type = type;
    _tipsLabel.text = type ? NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.unusualtips",@"plugin_gateway","电池将很快耗尽,因超出-20~60℃的工作范围") : NSLocalizedStringFromTable(@"mydevice.gateway.sensor.humiture.unusualtips.network",@"plugin_gateway","网络异常，请按下设备开关键并重新刷新");

}

- (void)onClose:(id)sender {
    if (self.type) {
        [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:[NSString stringWithFormat:@"unusuale_ht_%@_type%ld", self.htDid , self.type]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self removeFromSuperview];
}
@end
