//
//  MHACPartnerTimerDetailViewController.h
//  MiHome
//
//  Created by ayanami on 16/5/20.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import <MiHomeKit/MHDataDeviceTimer.h>
#import "MHDeviceAcpartner.h"

@interface MHACPartnerTimerDetailViewController : MHLuViewController<UIActionSheetDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>

- (id)initWithTimer:(MHDataDeviceTimer* )timer andAcpartner:(MHDeviceAcpartner *)acpartner;
@property (nonatomic, copy) void(^onDone)(MHDataDeviceTimer*);
@end
