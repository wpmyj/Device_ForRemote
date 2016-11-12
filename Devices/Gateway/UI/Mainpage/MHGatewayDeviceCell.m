//
//  MHGatewayDeviceCell.m
//  MiHome
//
//  Created by Lynn on 2/22/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayDeviceCell.h"
#import "MHDeviceGatewayBase.h"

#define TableViewCellHeight 65.f
#define kBadgeSide 8.f

@interface MHGatewayDeviceCell ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *offlineLabel;
@property (nonatomic, strong) UIView *badgeView;
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UIView *bottomeLine;
@property (nonatomic, strong) MHDeviceGatewayBase *sensor;
@end

@implementation MHGatewayDeviceCell
{
    BOOL                        _isNewFlag;
}


- (void)configureWithDataObject:(id)object {
    _sensor = object;
    [self buildSubviews];
    [self buildConstraints];
}


- (void)buildSubviews {
    self.backgroundColor = [UIColor whiteColor];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
        _icon = [[UIImageView alloc] init];
        [self.contentView addSubview:_icon];
    _icon.image = [UIImage imageNamed:[[_sensor class] largeIconNameOfStatus:MHDeviceStatus_Open]];

    
        _badgeView = [[UIView alloc] initWithFrame:CGRectMake(78, 8, kBadgeSide, kBadgeSide)];
        _badgeView.translatesAutoresizingMaskIntoConstraints = NO;
        _badgeView.backgroundColor = [UIColor redColor];
        _badgeView.layer.cornerRadius = kBadgeSide / 2.0;
        [self.contentView addSubview:_badgeView];
    _badgeView.hidden = !_sensor.isNewAdded;

    
        _nameLabel = [[UILabel alloc] init];
        //        _nameLabel.font = [UIFont systemFontOfSize:14.f * ScaleWidth];
        _nameLabel.font = [UIFont systemFontOfSize:15.0f];
        _nameLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
        [self.contentView addSubview:_nameLabel];
    if ([NSStringFromClass([_sensor class]) isEqualToString:@"MHDeviceGatewaySensorDoubleNeutral"]) {
//        NSLog(@"%@", self.sensor.name);
//        NSLog(@"是否新添加mihome%d", self.sensor.isNew);
//        NSLog(@"是否新添加lumi%d", self.sensor.isNewAdded);
        NSArray *names = [self.sensor.name componentsSeparatedByString:@"/"];
        if (names.count > 1) {
            _nameLabel.text = [NSString stringWithFormat:@"%@ / %@", names[0], names[1]];
        }
        else {
            _nameLabel.text = self.sensor.name;
        }
    }
    else {
        _nameLabel.text = _sensor.name;
    }

    
        _offlineLabel = [[UILabel alloc] init];
        _offlineLabel.font = [UIFont systemFontOfSize:13.f];
        _offlineLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        [self.contentView addSubview:_offlineLabel];
    _offlineLabel.text = NSLocalizedStringFromTable(@"mydevice.label.offline", @"plugin_gateway", nil);;


    
    if(_sensor.isOnline){
        _nameLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
        _offlineLabel.hidden = YES;
    }
    else {
        _nameLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        _offlineLabel.hidden = NO;
    }
        _bottomeLine = [[UIView alloc] init];
        _bottomeLine.backgroundColor = [MHColorUtils colorWithRGB:0xD1D1D1];
        [self addSubview:_bottomeLine];

}

//+ (BOOL)requiresConstraintBasedLayout {
//    return YES;
//}
//
//- (void)updateConstraints {
//    [self buildConstraints];
//    
//    [super updateConstraints];
//}

- (void)buildConstraints {
    XM_WS(weakself);
    
    /*
     WithFrame:CGRectMake(20, 5, 60, 60)
     WithFrame:CGRectMake(90, 34, WIN_WIDTH - 120, 20)
     WithFrame:CGRectMake(20.0f, TableViewCellHeight - 1, WIN_WIDTH - 40.f, 0.7)
     */
    
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakself.contentView);
        make.left.mas_equalTo(weakself.contentView.mas_left).with.offset(20);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    if (self.sensor.isOnline) {
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(weakself.icon.mas_centerY);
            make.width.mas_equalTo(WIN_WIDTH - 120);
//            make.centerX.equalTo(weakself.contentView);
            make.left.mas_equalTo(weakself.icon.mas_right).with.offset(10);
        }];
    }
    else {
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(weakself.icon.mas_centerY).with.offset(-10);
                    make.width.mas_equalTo(WIN_WIDTH - 120);
//                    make.centerX.equalTo(weakself.contentView);
            make.left.mas_equalTo(weakself.icon.mas_right).with.offset(10);
                }];
            
        [self.offlineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(weakself.nameLabel.mas_bottom);
                    make.width.mas_equalTo(WIN_WIDTH - 120);
//                    make.centerX.equalTo(weakself.contentView);
            make.left.mas_equalTo(weakself.icon.mas_right).with.offset(10);
        }];

    }
   
    
    
    [self.bottomeLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(WIN_WIDTH - 40, 0.7));
        make.centerX.equalTo(weakself);
        make.bottom.mas_equalTo(weakself.mas_bottom);
    }];
    
    
}


@end
