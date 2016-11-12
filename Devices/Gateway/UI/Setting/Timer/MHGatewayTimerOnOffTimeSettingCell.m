//
//  MHGatewayTimerOnOffTimeSettingCell.m
//  MiHome
//
//  Created by guhao on 3/28/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayTimerOnOffTimeSettingCell.h"

@interface MHGatewayTimerOnOffTimeSettingCell ()

@property (nonatomic, strong) UIButton *cleanBtn;
@property (nonatomic, strong) NSString *identifier;

@end

@implementation MHGatewayTimerOnOffTimeSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:[self cellStyle] reuseIdentifier:reuseIdentifier];
    if (self) {
        [self buildSubViews];
    }
    return self;
}
- (UITableViewCellStyle)cellStyle
{
    return UITableViewCellStyleSubtitle;
}


+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    
    [self buildConstraints];
    [super updateConstraints];
}

- (void)buildSubViews
{
//    SettingAccessoryKey_CaptionFontSize : @(14), SettingAccessoryKey_CaptionFontColor : [MHColorUtils colorWithRGB:0x333333], SettingAccessoryKey_CommentFontSize : @(10), SettingAccessoryKey_CommentFontColor : [MHColorUtils colorWithRGB:0x5f5f5f]}];

    self.textLabel.textColor = [MHColorUtils colorWithRGB:0x333333];
    self.textLabel.font = [UIFont systemFontOfSize:14.0f];
    
    self.detailTextLabel.textColor = [MHColorUtils colorWithRGB:0x5f5f5f];
    self.detailTextLabel.font = [UIFont systemFontOfSize:10.0f];

    self.cleanBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.cleanBtn.layer.borderColor = [MHColorUtils colorWithRGB:0x5f5f5f alpha:0.5].CGColor;
    self.cleanBtn.layer.borderWidth = 1.0f;
    self.cleanBtn.layer.cornerRadius = 5.0f;//
    [self.cleanBtn addTarget:self action:@selector(cleanDetailText:) forControlEvents:UIControlEventTouchUpInside];
    [self.cleanBtn setTitle:NSLocalizedStringFromTable(@"mydevice.timersetting.clean",@"plugin_gateway","清除") forState:UIControlStateNormal];
    [self.cleanBtn setTitleColor:[MHColorUtils colorWithRGB:0x333333] forState:UIControlStateNormal];
    [self.contentView addSubview:self.cleanBtn];
    
//    [self.detailTextLabel setTextColor:[MHColorUtils colorWithRGB:0x888888]];
}

- (void)buildConstraints {
    XM_WS(weakself);
    [self.cleanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakself.contentView);
        make.right.equalTo(weakself.contentView).with.offset(-20);
        make.size.mas_equalTo(CGSizeMake(60, 35));
    }];
}



- (void)cleanDetailText:(id)sender {
    if (self.cleanCallBack) {
        self.cleanCallBack(self.identifier);
    }
}

- (void)configIdentifier:(NSString *)identifier withTimer:(MHDataDeviceTimer *)timer {
    if ([identifier isEqualToString:ItemIdentifierOn]) {
        self.textLabel.text = NSLocalizedStringFromTable(@"mydevice.timersetting.on",@"plugin_gateway","开启时间");
        self.detailTextLabel.text = [timer getOnTimeString];//mydevice.timersetting.empty
        NSLog(@"开启时间%@", [timer getOffTimeString]);
        self.identifier = ItemIdentifierOn;
    }
    else {
        self.textLabel.text = NSLocalizedStringFromTable(@"mydevice.timersetting.off",@"plugin_gateway","关闭时间");
        self.detailTextLabel.text = [timer getOffTimeString];
        NSLog(@"关闭时间%@", [timer getOffTimeString]);
        self.identifier = ItemIdentifierOff;
    }
}

- (void)configIdentifier:(NSString *)identifier withTime:(NSArray *)time {
    if ([identifier isEqualToString:ItemIdentifierOn]) {
        self.textLabel.text = NSLocalizedStringFromTable(@"mydevice.timersetting.on",@"plugin_gateway","开启时间");
//        self.detailTextLabel.text = [timer getOnTimeString];//
//        NSLog(@"开启时间%@", [timer getOffTimeString]);
        if (time.count > 0) {
            self.detailTextLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", [time[0] integerValue] , [time[1] integerValue]];//mydevice.timersetting.empty
        }
        else {
           self.detailTextLabel.text = NSLocalizedStringFromTable(@"mydevice.timersetting.empty",@"plugin_gateway","未设置");
        }
        self.identifier = ItemIdentifierOn;
    }
    else {
        self.textLabel.text = NSLocalizedStringFromTable(@"mydevice.timersetting.off",@"plugin_gateway","关闭时间");
//        self.detailTextLabel.text = [timer getOffTimeString];
//        NSLog(@"关闭时间%@", [timer getOffTimeString]);
        if (time.count > 0) {
            self.detailTextLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", [time[0] integerValue] , [time[1] integerValue]];//mydevice.timersetting.empty
        }
        else {
            self.detailTextLabel.text = NSLocalizedStringFromTable(@"mydevice.timersetting.empty",@"plugin_gateway","未设置");
        }
        self.identifier = ItemIdentifierOff;
    }
}

@end
