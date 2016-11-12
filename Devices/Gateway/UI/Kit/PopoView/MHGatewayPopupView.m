//
//  MHGatewayDriftView.m
//  MiHome
//
//  Created by guhao on 16/2/2.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayPopupView.h"


@interface MHGatewayPopupView ()
@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation MHGatewayPopupView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self buildSubViews];
    }
    return self;
}

- (void)buildSubViews {
    self.font = [UIFont boldSystemFontOfSize:15.0f];
    
    UIImageView *popoverView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gateway_volumeSetting_icon"]];
    popoverView.frame = CGRectMake(0, 0, kPopupWidth, kPopupHeight);
    [self addSubview:popoverView];
    
    _textLabel = [[UILabel alloc] init];
    _textLabel.backgroundColor = [UIColor clearColor];
    _textLabel.font = self.font;
    _textLabel.text = self.text;
    _textLabel.textColor = self.color ? self.color : [MHColorUtils colorWithRGB:0x000000 alpha:0.7];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.frame = CGRectMake(0, 0, kPopupWidth, kPopupWidth);
    [self addSubview:_textLabel];
}

-(void)setValue:(float)aValue {
    _value = aValue;
    _text = [NSString stringWithFormat:@"%.0f", aValue];
    _textLabel.text = _text;
}

- (void)setColor:(UIColor *)color {
    _color = color;
}


@end
