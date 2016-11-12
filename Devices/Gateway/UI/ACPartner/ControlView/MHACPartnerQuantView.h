//
//  MHACPartnerQuantView.h
//  MiHome
//
//  Created by ayanami on 16/5/21.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHDeviceAcpartner.h"

@interface MHACPartnerQuantView : UIView

@property (nonatomic, copy) void(^todayCallback)(void);
@property (nonatomic, copy) void(^monthCallback)(void);
@property (nonatomic, copy) void(^quantCallback)(void);

- (void)updateQuant:(float)day month:(float)month power:(float)power;

//- (id)initWithACPartner:(MHDeviceAcpartner* )acpartner;

@end