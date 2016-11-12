//
//  MHGatewayNetworkStatusView.m
//  MiHome
//
//  Created by Lynn on 3/15/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayNetworkStatusView.h"
#import "NSString+WeiboStringDrawing.h"

@implementation MHGatewayNetworkStatusView
{
    UIImageView     *_stateImageView;
    UILabel         *_titleLabel;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self buildSubViews];
    }
    return self;
}

- (void)buildSubViews {
    
    self.backgroundColor = [UIColor colorWithRed:233/255.f green:220/255.f blue:171/255.f alpha:1];
    
    _stateImageView = [[UIImageView alloc] init];
    _stateImageView.image = [UIImage imageNamed:@"lumi_error"];
    [self addSubview:_stateImageView];
    
    //info text
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = NSLocalizedStringFromTable(@"network.unconnect", @"plugin_gateway", "自网络连接不可用");
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [MHColorUtils colorWithRGB:0xf0b023];
    _titleLabel.font = [UIFont systemFontOfSize:15.0f];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize contentViewSize = self.bounds.size;
    CGSize sizeMsg = [_titleLabel.text sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToWidth:CGRectGetWidth(self.bounds)];
    CGFloat imageX = 20;
    _stateImageView.frame = CGRectMake(imageX, (contentViewSize.height-15)/2.0, 15, 15);
    _titleLabel.frame = CGRectMake(imageX+15+5, (contentViewSize.height-sizeMsg.height)/2.0, sizeMsg.width, sizeMsg.height);
}

@end
