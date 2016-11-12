//
//  MHLMGuidePage.m
//  MiHome
//
//  Created by ayanami on 8/22/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLMGuidePage.h"


@interface MHLMGuidePage ()
@property (nonatomic, retain) UIView* panelView;
@property (nonatomic, strong) UILabel *tipsLabel;

@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *pauseBtn;


@end

@implementation MHLMGuidePage

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self buildSubViews];
    }
    return self;
}


- (void)buildSubViews  {
    self.backgroundColor = [MHColorUtils colorWithRGB:0 alpha:0.7];
    self.userInteractionEnabled = YES;
    
    
    _panelView = [UIView new];
    _panelView.backgroundColor = [UIColor whiteColor];
    _panelView.layer.cornerRadius = 15;
    [self addSubview:_panelView];
    
    _tipsLabel = [[UILabel alloc] init];
    _tipsLabel.font = [UIFont systemFontOfSize:18.0f];
    _tipsLabel.textAlignment = NSTextAlignmentCenter;
    _tipsLabel.textColor = [MHColorUtils colorWithRGB:0x000000 alpha:0.8];
    _tipsLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.acpartner.actionsheet.life",@"plugin_gateway","生活场景");
    [_panelView addSubview:_tipsLabel];

    
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *closeImage = [UIImage imageNamed:@"lumi_cube_closeguide"];
    [_closeBtn setImage:closeImage forState:UIControlStateNormal];
//    [_closeBtn setBackgroundImage:closeImage forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(closeGuidepage:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_closeBtn];
    
    _pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *pauseImage = [UIImage imageNamed:@"lumi_guide_play"];
//    [_pauseBtn setBackgroundImage:pauseImage forState:UIControlStateNormal];
    [_pauseBtn setImage:pauseImage forState:UIControlStateNormal];
    [_pauseBtn addTarget:self action:@selector(playGuide:) forControlEvents:UIControlEventTouchUpInside];
    [_panelView addSubview:_pauseBtn];
    
    
    CGFloat tipsSpacing = 20 * ScaleHeight;
 
    
    XM_WS(weakself);
    
    [self.panelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakself);
        make.size.mas_equalTo(CGSizeMake(200 * ScaleWidth, 220 * ScaleHeight));
    }];
    
 
  
    [_pauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(weakself.panelView);
        make.centerX.equalTo(weakself.panelView);
        make.top.mas_equalTo(weakself.panelView.mas_top).with.offset(tipsSpacing);
        make.size.mas_equalTo(pauseImage.size);
    }];
    
    [_tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.pauseBtn.mas_bottom).with.offset(tipsSpacing);
        make.centerX.equalTo(weakself.panelView);
    }];
    
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(closeImage.size);
        make.centerX.equalTo(weakself);
        make.top.mas_equalTo(weakself.panelView.mas_bottom).with.offset(50);
    }];

}


#pragma mark - touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isExitOnClickBg) {
        return;
    }
    
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)playGuide:(id)sender {
    if (self.okBlock) {
        self.okBlock();
    }
    [self removeFromSuperview];
}

- (void)closeGuidepage:(id)sender {
    if (self.closeBlock) {
        self.closeBlock();
    }
    [self removeFromSuperview];
}


@end
