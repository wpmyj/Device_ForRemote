//
//  MHACPartnerAddControlView.h
//  MiHome
//
//  Created by ayanami on 16/7/1.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHDeviceAcpartner.h"


@interface MHACPartnerAddControlView : UIControl

@property (nonatomic, copy) void (^addACClicked)(void);
@property (nonatomic, copy) void (^acDetailClicked)(void);


- (id)initWithFrame:(CGRect)frame sensor:(MHDeviceAcpartner *)acpartner;
- (void)updateMainPageStatus;

@end
