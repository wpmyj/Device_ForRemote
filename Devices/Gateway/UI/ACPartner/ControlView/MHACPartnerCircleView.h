//
//  MHACPartnerCircleView.h
//  MiHome
//
//  Created by ayanami on 16/5/19.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHACPartnerCircleView : UIView

@property (nonatomic, strong) CAShapeLayer *circle;
@property (nonatomic, assign) float radius;

- (void)animScaleUp;
- (void)animScaleDown;

@end

