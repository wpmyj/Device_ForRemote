//
//  MHGatewayPopMenuCell.m
//  MiHome
//
//  Created by guhao on 4/14/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayPopMenuCell.h"

@implementation MHGatewayPopMenuCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self buildSubViews];
    }
    return self;
}


- (void)buildSubViews {
    
    self.backgroundColor = [UIColor clearColor];
    
    _titleLbl = [[UILabel alloc] init];
    _titleLbl.textAlignment = NSTextAlignmentCenter;
    _titleLbl.font = [UIFont systemFontOfSize:16.0f];
    _titleLbl.textColor = [UIColor whiteColor];
    [self.contentView addSubview:_titleLbl];

    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = [MHColorUtils colorWithRGB:0x858585];
    [self.contentView addSubview:_lineView];
    
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
    [_titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakself.contentView);
    }];
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakself.contentView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(60, 1 * ScaleHeight));
        make.centerX.equalTo(weakself.contentView);
    }];
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
