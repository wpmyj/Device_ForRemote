//
//  MHGatewayAddSubDeviceCell.m
//  MiHome
//
//  Created by guhao on 16/5/4.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayAddSubDeviceCell.h"
#import "MHGatewayAddSubDeviceViewController.h"

@interface MHGatewayAddSubDeviceCell ()

@property (nonatomic, strong) UILabel *congratulationLabel;
@property (nonatomic, strong) UILabel *shareTipsLabel;
@property (nonatomic, strong) UILabel *precautionsLabel;//Installation Precautions

@property (nonatomic, strong) UILabel *precautionsOne;
@property (nonatomic, strong) UILabel *precautionsTwo;
@property (nonatomic, strong) UILabel *precautionsThree;

@property (nonatomic, strong) UIImageView *tipsImageView;
@property (nonatomic, strong) UIImageView *smallImageOne;
@property (nonatomic, strong) UIImageView *smallImageTwo;
@property (nonatomic, strong) UIImageView *smallImageThree;

@property (nonatomic, strong) UILabel *imageNameOne;
@property (nonatomic, strong) UILabel *imageNameTwo;
@property (nonatomic, strong) UILabel *imageNameThree;

@property (nonatomic, assign) BOOL isShare;
@property (nonatomic, copy) NSString *deviceType;
@end

@implementation MHGatewayAddSubDeviceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self buildSubviews];
//        [self buildConstraints];
    }
    return self;
}


- (void)buildSubviews {
    //添加成功
    self.congratulationLabel = [[UILabel alloc] init];
    self.congratulationLabel.textAlignment = NSTextAlignmentCenter;
    self.congratulationLabel.textColor = [MHColorUtils colorWithRGB:0x000000];
    self.congratulationLabel.font = [UIFont systemFontOfSize:18.0f];
    self.congratulationLabel.backgroundColor = [UIColor clearColor];
    self.congratulationLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.congratulation",@"plugin_gateway","设备名称");
    [self.contentView addSubview:self.congratulationLabel];
    
    //网关分享提示
    self.shareTipsLabel = [[UILabel alloc] init];
    self.shareTipsLabel.textAlignment = NSTextAlignmentCenter;
    self.shareTipsLabel.textColor = [MHColorUtils colorWithRGB:0xBCBCBC];
    self.shareTipsLabel.font = [UIFont systemFontOfSize:16.0f];
    self.shareTipsLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.shareTips",@"plugin_gateway","");
    self.shareTipsLabel.hidden = !self.isShare;
    [self.contentView addSubview:self.shareTipsLabel];
    
    //安装注意事项
    self.precautionsLabel = [[UILabel alloc] init];
    //    self.precautionsLabel.textColor = [MHColorUtils colorWithRGB:0xBCBCBC];
    self.precautionsLabel.textColor = [UIColor orangeColor];
    self.precautionsLabel.font = [UIFont systemFontOfSize:16.0f];
    self.precautionsLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.precautions",@"plugin_gateway","");
    self.precautionsLabel.hidden = YES;
    [self.contentView addSubview:self.precautionsLabel];
    
    //注意事项1
    self.precautionsOne = [[UILabel alloc] init];
    self.precautionsOne.textColor = [MHColorUtils colorWithRGB:0x000000];
    self.precautionsOne.font = [UIFont systemFontOfSize:16.0f];
    self.precautionsOne.numberOfLines = 0;
    self.precautionsOne.text = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.precautions.one",@"plugin_gateway","");
    self.precautionsOne.hidden = YES;
    
    [self.contentView addSubview:self.precautionsOne];
    
    //注意事项2
    self.precautionsTwo = [[UILabel alloc] init];
    self.precautionsTwo.textColor = [MHColorUtils colorWithRGB:0x000000];
    self.precautionsTwo.font = [UIFont systemFontOfSize:16.0f];
    self.precautionsTwo.numberOfLines = 0;
    self.precautionsTwo.text = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.precautions.two",@"plugin_gateway","");
    self.precautionsTwo.hidden = YES;
    [self.contentView addSubview:self.precautionsTwo];
    
    self.precautionsThree = [[UILabel alloc] init];
    self.precautionsThree.textColor = [MHColorUtils colorWithRGB:0x000000];
    self.precautionsThree.font = [UIFont systemFontOfSize:16.0f];
    self.precautionsThree.text = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.imagename.one",@"plugin_gateway","远离金属");
    self.precautionsThree.hidden = YES;
    [self.contentView addSubview:self.precautionsThree];
    
    //实物图
    _tipsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lumi_guidePage_magnet_real"]];
    [self.contentView addSubview:_tipsImageView];
    
    //小图左1
    _smallImageOne = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lumi_guidePage_switch_warning"]];
    //    _smallImageOne.contentMode = UIViewContentModeCenter;
    _smallImageOne.hidden = YES;
    [self.contentView addSubview:_smallImageOne];
    
    //小图左2
    _smallImageTwo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lumi_guidePage_magnet_warning"]];
    //    _smallImageTwo.contentMode = UIViewContentModeCenter;
    _smallImageTwo.hidden = YES;
    [self.contentView addSubview:_smallImageTwo];
    
    //小图左3
    _smallImageThree = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lumi_guidePage_magnet_warning2"]];
    //    _smallImageThree.contentMode = UIViewContentModeCenter;
    _smallImageThree.hidden = YES;
    [self.contentView addSubview:_smallImageThree];
    
    //图片说明1
    self.imageNameOne = [[UILabel alloc] init];
    self.imageNameOne.textAlignment = NSTextAlignmentCenter;
    self.imageNameOne.textColor = [MHColorUtils colorWithRGB:0x000000];
    self.imageNameOne.font = [UIFont systemFontOfSize:14.0f];
    self.imageNameOne.text = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.imagename.one",@"plugin_gateway","远离金属");
    self.imageNameOne.hidden = YES;
    self.imageNameOne.numberOfLines = 0;
    [self.contentView addSubview:self.imageNameOne];
    
    //图片说明2
    self.imageNameTwo = [[UILabel alloc] init];
    self.imageNameTwo.textAlignment = NSTextAlignmentCenter;
    self.imageNameTwo.textColor = [MHColorUtils colorWithRGB:0x000000];
    self.imageNameTwo.font = [UIFont systemFontOfSize:14.0f];
    self.imageNameTwo.text = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.imagename.two",@"plugin_gateway","");
    self.imageNameTwo.hidden = YES;
    [self.contentView addSubview:self.imageNameTwo];
    
    
    //图片说明3
    self.imageNameThree = [[UILabel alloc] init];
    self.imageNameThree.textAlignment = NSTextAlignmentCenter;
    self.imageNameThree.textColor = [MHColorUtils colorWithRGB:0x000000];
    self.imageNameThree.font = [UIFont systemFontOfSize:14.0f];
    self.imageNameThree.text = NSLocalizedStringFromTable(@"mydevice.gateway.addsub_guide.imagename.three",@"plugin_gateway","");
    self.imageNameThree.hidden = YES;
    [self.contentView addSubview:self.imageNameThree];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    [self buildConstraints];
    
    [super updateConstraints];
}

- (void)buildConstraints {
    XM_WS(weakself);
    CGFloat labelSpacingV = 20 * ScaleHeight;
    CGFloat labelSpacingH = 20 * ScaleWidth;
    
    CGFloat fieldSpacingV = 10 * ScaleHeight;    
    CGFloat tipsImageSpacingV = 10 * ScaleHeight;
    CGFloat iamgeSpacingV = 40 * ScaleHeight;
    CGFloat imageNameSpacingV = 10 * ScaleHeight;
    
    CGFloat smallImageSize = 70 * ScaleWidth;
    CGFloat imageSpacingH = 40 * ScaleWidth;
    
    [self.congratulationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.contentView).with.offset(labelSpacingV);
        make.centerX.equalTo(weakself.contentView);
    }];
    
    [self.shareTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.congratulationLabel.mas_bottom).with.offset(fieldSpacingV);
        make.centerX.equalTo(weakself.contentView);
    }];
    
    [self.precautionsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.shareTipsLabel.mas_bottom).with.offset(fieldSpacingV);
        make.left.equalTo(weakself.contentView).with.offset(labelSpacingH);
    }];
    
    [self.precautionsOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.precautionsLabel.mas_bottom).with.offset(fieldSpacingV);
        make.centerX.equalTo(weakself.contentView);
        make.width.mas_equalTo(WIN_WIDTH - labelSpacingH * 2);
    }];
    [self.precautionsTwo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.precautionsOne.mas_bottom).with.offset(fieldSpacingV);
        make.left.equalTo(weakself.contentView).with.offset(labelSpacingH);
        make.width.mas_equalTo(WIN_WIDTH - labelSpacingH * 2);
    }];
    
    [self.tipsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.precautionsTwo.mas_bottom).with.offset(tipsImageSpacingV);
        make.centerX.equalTo(weakself.contentView);
        make.size.mas_equalTo(CGSizeMake(200, 200));
    }];
    
    [self.precautionsThree mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.tipsImageView.mas_bottom).with.offset(fieldSpacingV);
        make.centerX.equalTo(weakself.contentView);
    }];
    
    
    [self.smallImageTwo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.tipsImageView.mas_bottom).with.offset(iamgeSpacingV);
        make.centerX.equalTo(weakself.contentView);
        make.size.mas_equalTo(CGSizeMake(smallImageSize, smallImageSize));
    }];
    [self.smallImageThree mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.tipsImageView.mas_bottom).with.offset(iamgeSpacingV);
        make.centerY.equalTo(weakself.smallImageTwo);
        make.size.mas_equalTo(CGSizeMake(smallImageSize, smallImageSize));
        make.left.mas_equalTo(weakself.smallImageTwo.mas_right).with.offset(imageSpacingH);
    }];
    
    [self.smallImageOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.tipsImageView.mas_bottom).with.offset(iamgeSpacingV);
        make.centerY.equalTo(weakself.smallImageTwo);
        make.size.mas_equalTo(CGSizeMake(smallImageSize, smallImageSize));
        make.right.mas_equalTo(weakself.smallImageTwo.mas_left).with.offset(-imageSpacingH);
    }];
    
    
    [self.imageNameTwo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.smallImageTwo.mas_bottom).with.offset(imageNameSpacingV);
        make.centerX.equalTo(weakself.smallImageTwo);
    }];
    
    [self.imageNameThree mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.smallImageThree.mas_bottom).with.offset(imageNameSpacingV);
        make.centerX.equalTo(weakself.smallImageThree);
    }];
    
    [self.imageNameOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.smallImageOne.mas_bottom).with.offset(imageNameSpacingV);
        make.centerX.equalTo(weakself.smallImageOne);
        make.width.mas_equalTo(100);
    }];

}

- (void)configureWithShare:(BOOL)isShare deviceType:(NSString *)deviceType {
    self.shareTipsLabel.hidden = !isShare;
    if ([deviceType isEqualToString:DeviceModelMagnetClassName]) {
        _precautionsLabel.hidden = NO;
        _precautionsOne.hidden = NO;
        _precautionsTwo.hidden = NO;
        
        _smallImageOne.hidden = NO;
        _smallImageTwo.hidden = NO;
        _smallImageThree.hidden = NO;
        _imageNameOne.hidden = NO;
        _imageNameTwo.hidden = NO;
        _imageNameThree.hidden = NO;
        
    }
    else if ([deviceType isEqualToString:DeviceModelSwitchClassName]) {
        _tipsImageView.image = [UIImage imageNamed:@"lumi_guidePage_switch_warning"];
        _precautionsLabel.hidden = NO;
        _precautionsOne.hidden = NO;
        _precautionsTwo.hidden = NO;
        _precautionsThree.hidden = NO;
    }
    else if ([deviceType isEqualToString:DeviceModelMotionClassName]) {
        _tipsImageView.image = [UIImage imageNamed:@"lumi_guidePage_switch_warning"];
        _precautionsLabel.hidden = NO;
        _precautionsOne.hidden = NO;
        _precautionsTwo.hidden = NO;
        _precautionsThree.hidden = NO;
    }
    else if ([deviceType isEqualToString:DeviceModelSmokeClassName] ||
             [deviceType isEqualToString:DeviceModelNatgasClassName]) {
        _tipsImageView.image = [UIImage imageNamed:@"lumi_guidePage_switch_warning"];
        _precautionsLabel.hidden = NO;
        _precautionsOne.hidden = NO;
        _precautionsTwo.hidden = NO;
        _precautionsOne.text = @"1.为了避免型号衰减, 请不要将设备粘贴在铁器上";
        _precautionsTwo.text = @"2.粘贴前, 快速按一下按键, 如果网关提示“连接正常”，说明位置合适， 否则需将设备靠近网关， 再试一次";
        _precautionsThree.hidden = NO;
    }
    else {
        _tipsImageView.hidden = YES;
    }

}

@end
