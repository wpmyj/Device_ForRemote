//
//  MHDeviceSettingColorVolumeCell.m
//  MiHome
//
//  Created by Lynn on 7/28/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHDeviceSettingColorVolumeCell.h"
#import "MHColorBarView.H"
#import "InfHSBSupport.h"

@implementation MHDeviceSettingColorVolumeCell
{
    CGFloat _curValue;
    MHGatewayPickColorView *_colorBar;
}

- (void)buildSubViews {
    [super buildSubViews];
    
    UIImage *indicatorImage = [UIImage imageNamed:@"gateway_slider_thumb"];
    CGFloat kIndicatorSize = indicatorImage.size.width+5;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    __weak typeof(self) weakSelf = self;
    
    if(_colorBar == nil){
        _colorBar = [[MHGatewayPickColorView alloc] initWithFrame:CGRectMake(0, 30, self.frame.size.width, kIndicatorSize)];
        _colorBar.callbackBlock = ^(CGFloat value) {
            [weakSelf pickedColor:value];
        };
        [self.contentView addSubview:_colorBar];
    }
    [self.detailTextLabel setTextColor:[MHColorUtils colorWithRGB:0x888888]];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGRect frame = self.textLabel.frame;
    frame.origin.y -= 15;
    [self.textLabel setFrame:frame];
    
    [_colorBar setFrame:CGRectMake(0, 30, self.frame.size.width, _colorBar.frame.size.height)];
    _colorBar.barStartXPoint = self.textLabel.frame.origin.x;
}

- (void)fillWithItem:(MHDeviceSettingItem *)item {
    [super fillWithItem:item];
    _curValue = [[item.accessories valueForKey:CurValue class:[NSNumber class]] doubleValue];
    _colorBar.value = [self fetchHSV:_curValue];
}

- (CGFloat)fetchHSV:(NSInteger)color
{
    int r = color >> 16 & 0xff;
    int g = color >> 8 & 0xff;
    int b = color & 0xff;
    int a = color >> 24;
    
    UIColor *c = [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:a/100.0f];
    
    CGFloat hue, sat, brightness, alpha;
    [c getHue:&hue saturation:&sat brightness:&brightness alpha:&alpha];
    if(sat == 1.0){
    
    }
    else if (sat == 0){
        //白色区间
        hue = 55 / 256.0;
        return hue;
    }
    else{
        //如果不是纯色的，需要对透明度进行转化
        
    }
    hue = pin( 0.0f, hue, 1.0f );
    return hue;
}

- (void)finish
{
    [super finish];
}

-(void)pickedColor:(CGFloat)value
{
    [self.item.accessories setValue:@(value) forKey:CurValue];
    if (self.item.callbackBlock){
        self.item.callbackBlock(self);
    }
}

@end
