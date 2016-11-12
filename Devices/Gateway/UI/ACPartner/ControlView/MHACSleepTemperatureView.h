//
//  MHACSleepTemperatureView.h
//  MiHome
//
//  Created by ayanami on 16/7/21.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHDeviceAcpartner.h"

@interface MHACSleepTemperatureView : UIView

@property (nonatomic, copy) void(^beginTemp)(int);
@property (nonatomic, copy) void(^afterTemp)(int);
@property (nonatomic, copy) void(^endBeforeTemp)(int);
@property (nonatomic, copy) void(^endTemp)(int);


- (id)initWithFrame:(CGRect)frame acpartner:(MHDeviceAcpartner *)acpartner;


- (void)reloadView:(NSArray *)tempArray timeArray:(NSArray *)timeArray;

@end
