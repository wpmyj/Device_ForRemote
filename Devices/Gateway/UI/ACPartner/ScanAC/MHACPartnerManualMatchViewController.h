//
//  MHACPartnerManualMatchViewController.h
//  MiHome
//
//  Created by ayanami on 16/6/7.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceAcpartner.h"

@interface MHACPartnerManualMatchViewController : MHLuViewController

@property (nonatomic, copy) NSString *oldRemoteid;
@property (nonatomic, assign) NSInteger oldBrandid;

- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner;

@end
