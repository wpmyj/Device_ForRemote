//
//  MHGatewayAlarmProgressView.h
//  MiHome
//
//  Created by guhao on 2/16/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kLineWidth 5.5 * ScaleWidth

@interface MHGatewayAlarmProgressView : UIView

@property (nonatomic,assign) int total;
@property (nonatomic,strong) UIColor *color;
@property (nonatomic,assign) int completed;
@property (nonatomic,strong) UIColor *completedColor;

@property (nonatomic,assign) CGFloat radius;
@property (nonatomic,assign) CGFloat innerRadius;
@property (nonatomic, assign) CGFloat padding;

@property (nonatomic,assign) CGFloat startAngle;
@property (nonatomic,assign) CGFloat endAngle;


@property (nonatomic) id delegate;

- (void)setCompleted:(int)completed;

@end
