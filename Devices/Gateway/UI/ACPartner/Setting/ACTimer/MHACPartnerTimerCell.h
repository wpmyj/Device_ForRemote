//
//  MHACPartnerTimerCell.h
//  MiHome
//
//  Created by ayanami on 16/5/20.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHTableViewCell.h"
#import "MHDeviceAcpartner.h"

@interface MHACPartnerTimerCell : MHTableViewCell

@property (nonatomic, retain) UISwitch* switcher;
@property (nonatomic, copy) void(^onSwitch)(MHDataDeviceTimer* timer);

- (void)configureWithDataObject:(MHDataDeviceTimer *)timer acpartner:(MHDeviceAcpartner *)acpartner;


@end
