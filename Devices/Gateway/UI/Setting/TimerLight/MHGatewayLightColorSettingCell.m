//
//  MHGatewayLightColorSettingCell.m
//  MiHome
//
//  Created by guhao on 16/1/15.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayLightColorSettingCell.h"

#define kBtnSize 38
#define kSpacing 22
#define kVertialSpacing 10

#define kBtnTag_Color 1000

typedef enum : NSInteger {
    PinkColor,
    YellowColor,
    ForestColor,
    RomanticColor,
    WhiteColor,
    BlueColor,
}   ColorNames;

#define kRomantic NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.scenes.romantic",@"plugin_gateway", "romantic")
#define kPink     NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.scenes.pink", @"plugin_gateway","pink")
#define kGolden   NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.scenes.golden", @"plugin_gateway","golden")
#define kWhite    NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.scenes.white", @"plugin_gateway","white")
#define kForest   NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.scenes.forest",@"plugin_gateway", "forest")
#define kBlue     NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.scenes.charmblue", @"plugin_gateway","blue")
static NSArray *labelNames = nil;
static NSArray *colorNames = nil;
static NSArray *colorSelectedNames = nil;
//static NSArray *colorSences = @[@(0x2b9400d3),@(0x2beb6877),@(0x2bffd700),@(0x2b7dd2f0),@(0x2b00ff7f),@(0x2b0900fa)];
//                                //浪漫            //粉系        //麦田        //天空            //森林        //静谧
static NSDictionary *colorNumber = nil;
//736847991, 738187008, 721485695, 731119827, 722010362, 729666288
static NSDictionary *colorString = nil;

@interface MHGatewayLightColorSettingCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSMutableArray *btnArray;
@property (nonatomic, strong) NSMutableArray *labArray;

@property (nonatomic, strong) UIButton *pinkBtn;
@property (nonatomic, strong) UIButton *yellowBtn;
@property (nonatomic, strong) UIButton *forestBtn;
@property (nonatomic, strong) UIButton *romanticBtn;
@property (nonatomic, strong) UIButton *blueBtn;
@property (nonatomic, strong) UIButton *whiteBtn;

@property (nonatomic, strong) UILabel *pinkLabel;
@property (nonatomic, strong) UILabel *yellowLabel;
@property (nonatomic, strong) UILabel *forestLabel;
@property (nonatomic, strong) UILabel *romanticLabel;
@property (nonatomic, strong) UILabel *blueLabel;
@property (nonatomic, strong) UILabel *whiteLabel;


@property (nonatomic, strong) UIButton *oldBtn;
@end

@implementation MHGatewayLightColorSettingCell

- (NSMutableArray *) btnArray {
    if (_btnArray == nil) {
        _btnArray = [[NSMutableArray alloc] init];
    }
    return _btnArray;
}

- (NSMutableArray *) labArray {
    if (_labArray == nil) {
        _labArray = [[NSMutableArray alloc] init];
    }
    return _labArray;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        labelNames =  @[ kPink, kGolden, kForest, kRomantic, kWhite, kBlue ];
        colorNames = @[ @"light_scene_color_xml_pink_normal", @"light_scene_color_xml_yellow_normal", @"light_scene_color_xml_forest_normal", @"light_scene_color_xml_romantic_normal", @"light_scene_color_xml_white_normal", @"light_scene_color_xml_blue_normal" ];
        colorSelectedNames = @[ @"light_scene_color_xml_pink_selected", @"light_scene_color_xml_yellow_selected", @"light_scene_color_xml_forest_selected", @"light_scene_color_xml_romantic_selected", @"light_scene_color_xml_white_selected", @"light_scene_color_xml_blue_selected" ];
        colorNumber = @ { @(0x2beb6877):@(PinkColor), @(0x2bffd700):@(YellowColor), @(0x2b00ff7f):@(ForestColor), @(0x2b9400d3):@(RomanticColor), @(0x2b0900fa):@(BlueColor), @(0x2b7dd2f0):@(WhiteColor) };
        colorString = @ { @"736847991":@(PinkColor), @"738187008":@(YellowColor), @"721485695":@(ForestColor), @"731119827":@(RomanticColor), @"722010362":@(BlueColor), @"729666288":@(WhiteColor) };
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self buildSubviews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self buildConstraints];
}

- (void)configureWithDataObject:(id)object {
    NSLog(@"%@", object);
    if ([object[0] isKindOfClass:[NSString class]]) {
        if (![object[0] isEqualToString:@"on"] && ![object[0] isEqualToString:@"off"]) {
            NSInteger index = [colorString[object[0]] integerValue];
            for (UIView *subView in self.contentView.subviews) {
                if (subView.tag == (kBtnTag_Color + index) ) {
                    UIButton *selectedBtn = (UIButton *)subView;
                    if (selectedBtn == self.oldBtn) {
                        return;
                    }
                    selectedBtn.selected = YES;
                    self.oldBtn.selected = NO;
                    self.oldBtn = selectedBtn;
                }
            }
        }
    }
    else {
        NSInteger index = [colorNumber[object[0]] integerValue];
        for (UIView *subView in self.contentView.subviews) {
            if (subView.tag == (kBtnTag_Color + index) ) {
                UIButton *selectedBtn = (UIButton *)subView;
                if (selectedBtn == self.oldBtn) {
                    return;
                }
                selectedBtn.selected = YES;
                self.oldBtn.selected = NO;
                self.oldBtn = selectedBtn;
            }
        }

    }
}

- (void)buildSubviews {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.setting.nightlight.timer.scene", @"plugin_gateway","情景色");

    self.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.contentView addSubview:self.titleLabel];
    
    self.pinkBtn = [[UIButton alloc] init];
    [self.pinkBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.pinkBtn setImage:[UIImage imageNamed:colorNames[PinkColor]] forState:UIControlStateNormal];
    [self.pinkBtn setImage:[UIImage imageNamed:colorSelectedNames[PinkColor]] forState:UIControlStateSelected];
    self.pinkBtn.tag = kBtnTag_Color + PinkColor;
    [self.contentView addSubview:self.pinkBtn];
    
    
    self.yellowBtn = [[UIButton alloc] init];
    [self.yellowBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.yellowBtn setImage:[UIImage imageNamed:colorNames[YellowColor]] forState:UIControlStateNormal];
    [self.yellowBtn setImage:[UIImage imageNamed:colorSelectedNames[YellowColor]] forState:UIControlStateSelected];
    self.yellowBtn.tag = kBtnTag_Color + YellowColor;
    [self.contentView addSubview:self.yellowBtn];
    
    self.forestBtn = [[UIButton alloc] init];
    [self.forestBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.forestBtn setImage:[UIImage imageNamed:colorNames[ForestColor]] forState:UIControlStateNormal];
    [self.forestBtn setImage:[UIImage imageNamed:colorSelectedNames[ForestColor]] forState:UIControlStateSelected];
    self.forestBtn.tag = kBtnTag_Color + ForestColor;
    [self.contentView addSubview:self.forestBtn];

    self.romanticBtn = [[UIButton alloc] init];
    [self.romanticBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.romanticBtn setImage:[UIImage imageNamed:colorNames[RomanticColor]] forState:UIControlStateNormal];
    [self.romanticBtn setImage:[UIImage imageNamed:colorSelectedNames[RomanticColor]] forState:UIControlStateSelected];
    self.romanticBtn.tag = kBtnTag_Color + RomanticColor;
    [self.contentView addSubview:self.romanticBtn];

    //默认选中浪漫
    self.romanticBtn.selected = YES;
    self.oldBtn = self.romanticBtn;
    
    self.whiteBtn = [[UIButton alloc] init];
    [self.whiteBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.whiteBtn setImage:[UIImage imageNamed:colorNames[WhiteColor]] forState:UIControlStateNormal];
    [self.whiteBtn setImage:[UIImage imageNamed:colorSelectedNames[WhiteColor]] forState:UIControlStateSelected];
    self.whiteBtn.tag = kBtnTag_Color + WhiteColor;
    [self.contentView addSubview:self.whiteBtn];
    
    self.blueBtn = [[UIButton alloc] init];
    [self.blueBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.blueBtn setImage:[UIImage imageNamed:colorNames[BlueColor]] forState:UIControlStateNormal];
    [self.blueBtn setImage:[UIImage imageNamed:colorSelectedNames[BlueColor]] forState:UIControlStateSelected];
    self.blueBtn.tag = kBtnTag_Color + BlueColor;
    [self.contentView addSubview:self.blueBtn];

    
    self.pinkLabel = [[UILabel alloc] init];
    self.pinkLabel.text = labelNames[PinkColor];
    self.pinkLabel.font = [UIFont systemFontOfSize:14.0f];
    self.pinkLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.pinkLabel];
    
    self.yellowLabel = [[UILabel alloc] init];
    self.yellowLabel.text = labelNames[YellowColor];
    self.yellowLabel.font = [UIFont systemFontOfSize:14.0f];
    self.yellowLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.yellowLabel];
    
    self.forestLabel = [[UILabel alloc] init];
    self.forestLabel.text = labelNames[ForestColor];
    self.forestLabel.font = [UIFont systemFontOfSize:14.0f];
    self.forestLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.forestLabel];
    
    self.romanticLabel = [[UILabel alloc] init];
    self.romanticLabel.text = labelNames[RomanticColor];
    self.romanticLabel.font = [UIFont systemFontOfSize:14.0f];
    self.romanticLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.romanticLabel];
    
    self.whiteLabel = [[UILabel alloc] init];
    self.whiteLabel.text = labelNames[WhiteColor];
    self.whiteLabel.font = [UIFont systemFontOfSize:14.0f];
    self.whiteLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.whiteLabel];

    self.blueLabel = [[UILabel alloc] init];
    self.blueLabel.text = labelNames[BlueColor];
    self.blueLabel.font = [UIFont systemFontOfSize:14.0f];
    self.blueLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.blueLabel];
    
}

- (void)buildConstraints {
    XM_WS(weakself);
    CGFloat spacing = (WIN_WIDTH - kBtnSize * 6) / 7.0f;
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.contentView).with.offset(kSpacing * ScaleWidth);
        make.top.equalTo(weakself.contentView).with.offset(kVertialSpacing * ScaleHeight);
    }];
    
    [self.romanticBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.contentView).with.offset(self.contentView.bounds.size.width / 2 + spacing / 2);
        make.top.equalTo(weakself.titleLabel.mas_bottom).with.offset(kVertialSpacing);
        make.size.mas_equalTo(CGSizeMake(kBtnSize, kBtnSize));
    }];
    [self.romanticLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.romanticBtn.mas_bottom).with.offset(kVertialSpacing);
            make.centerX.mas_equalTo(self.romanticBtn.mas_centerX);
        }];
    
    [self.forestBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakself.romanticBtn.mas_left).with.offset(-spacing);
        make.top.equalTo(weakself.titleLabel.mas_bottom).with.offset(kVertialSpacing);
        make.size.mas_equalTo(CGSizeMake(kBtnSize, kBtnSize));
    }];
    [self.forestLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.forestBtn.mas_bottom).with.offset(kVertialSpacing);
        make.centerX.mas_equalTo(self.forestBtn.mas_centerX);
    }];
    
    [self.yellowBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakself.forestBtn.mas_left).with.offset(-spacing);
        make.top.equalTo(weakself.titleLabel.mas_bottom).with.offset(kVertialSpacing);
        make.size.mas_equalTo(CGSizeMake(kBtnSize, kBtnSize));
    }];
    [self.yellowLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.yellowBtn.mas_bottom).with.offset(kVertialSpacing);
        make.centerX.mas_equalTo(self.yellowBtn.mas_centerX);
    }];
    
    [self.pinkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakself.yellowBtn.mas_left).with.offset(-spacing);
        make.top.equalTo(weakself.titleLabel.mas_bottom).with.offset(kVertialSpacing);
        make.size.mas_equalTo(CGSizeMake(kBtnSize, kBtnSize));
    }];
    [self.pinkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pinkBtn.mas_bottom).with.offset(kVertialSpacing);
        make.centerX.mas_equalTo(self.pinkBtn.mas_centerX);
    }];
    
    [self.whiteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.romanticBtn.mas_right).with.offset(spacing);
        make.top.equalTo(weakself.titleLabel.mas_bottom).with.offset(kVertialSpacing);
        make.size.mas_equalTo(CGSizeMake(kBtnSize, kBtnSize));
    }];
    [self.whiteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.whiteBtn.mas_bottom).with.offset(kVertialSpacing);
        make.centerX.mas_equalTo(self.whiteBtn.mas_centerX);
    }];

    [self.blueBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.whiteBtn.mas_right).with.offset(spacing);
        make.top.equalTo(weakself.titleLabel.mas_bottom).with.offset(kVertialSpacing);
        make.size.mas_equalTo(CGSizeMake(kBtnSize, kBtnSize));
    }];
    [self.blueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.blueBtn.mas_bottom).with.offset(kVertialSpacing);
        make.centerX.mas_equalTo(self.blueBtn.mas_centerX);
    }];
    
    

}

- (void)buttonClick:(UIButton *)sender {
//    if (sender == self.oldBtn) {
//    }
//    else {
//        self.oldBtn.selected = NO;
//        sender.selected = YES;
//        self.oldBtn = sender;
//    }
    self.oldBtn.selected = NO;
    sender.selected = YES;
    self.oldBtn = sender;
    NSString *name = labelNames[sender.tag - kBtnTag_Color];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedColorName:)]) {
        [self.delegate didSelectedColorName:name];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
