//
//  MHACPartnerAddListCell.m
//  MiHome
//
//  Created by ayanami on 16/5/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerAddListCell.h"
#import "MHACTypeModel.h"
#import "MHLumiHtmlHandleTools.h"

@interface MHACPartnerAddListCell  ()


@property (nonatomic, strong) UIView *separatorLine;
@property (nonatomic, strong) MHACTypeModel *model;
@end

@implementation MHACPartnerAddListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self buildSubviews];
    }
    return self;
}


- (void)configureWithDataObject:(id)object {
    // to be implemented in subclass
    self.model = object;
    [self buildSubviews];
}

- (void)buildSubviews {
    // to be implemented in subclass
    XM_WS(weakself);

    if (self.nameLabel == nil) {
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.textColor = [MHColorUtils colorWithRGB:0x333333];
        self.nameLabel.font = [UIFont systemFontOfSize:20.0f];
        [self.contentView addSubview:self.nameLabel];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakself.contentView).with.offset(10);
//            make.centerY.equalTo(weakself.contentView);
            make.left.mas_equalTo(weakself.contentView.mas_left).with.offset(40);
        }];
    }
    NSString *currentLanguage = [[MHLumiHtmlHandleTools sharedInstance] currentLanguage];
    if ([currentLanguage hasPrefix:@"zh-Hans"]) {
        self.nameLabel.text = self.model.name;
    }
    else {
        self.nameLabel.text = self.model.eng_name;
    }
    if (self.arrowImage == nil) {
        self.arrowImage = [[UIImageView alloc] init];
        UIImage *image = [UIImage imageNamed:@"acpartner_typeselected_arrow"];
        self.arrowImage.image = image;
        [self.contentView addSubview:self.arrowImage];
        [self.arrowImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(weakself.nameLabel);
            make.right.mas_equalTo(weakself.nameLabel.mas_left).with.offset(-10);
            make.size.mas_equalTo(image.size);
        }];
    }

    if (self.separatorLine == nil) {
        self.separatorLine = [[UIView alloc] initWithFrame:CGRectMake(20, 46, WIN_WIDTH - 40, 1)];
        self.separatorLine.backgroundColor = [MHColorUtils colorWithRGB:0xf1f1f1];
        [self addSubview:self.separatorLine];
    }
   
    
}

//- (void)buildConstraints {
//    // to be implemented in subclass
//    
//  
//   
//    
//}
//
//+ (BOOL)requiresConstraintBasedLayout {
//    return YES;
//}
//
//- (void)updateConstraints {
//    [self buildConstraints];
//    
//    [super updateConstraints];
//}

@end
