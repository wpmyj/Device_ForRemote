//
//  MHGatewayDriftView.h
//  MiHome
//
//  Created by guhao on 16/2/2.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPopupWidth 45 * ScaleWidth
#define kPopupHeight 50 * ScaleWidth

@interface MHGatewayPopupView : UIView

@property (nonatomic) float value;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, retain) UIColor *color;
@property (nonatomic, copy) NSString *text;

@end
