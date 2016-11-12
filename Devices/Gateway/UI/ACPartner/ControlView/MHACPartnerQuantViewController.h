//
//  MHACPartnerQuantViewController.h
//  MiHome
//
//  Created by ayanami on 16/6/4.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceAcpartner.h"

@interface MHACPartnerQuantViewController : MHLuViewController

@property (nonatomic,assign) NSInteger selectedType;

- (id)initWithSensor:(MHDeviceAcpartner* )acpartner ;
@end
