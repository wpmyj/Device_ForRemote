//
//  MHLuTimerDetailViewController.h
//  MiHome
//
//  Created by Lynn on 10/16/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import <MiHomeKit/MHDataDeviceTimer.h>

@interface MHLuTimerDetailViewController : MHLuViewController <UIActionSheetDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>
- (id)initWithTimer:(MHDataDeviceTimer* )timer;
- (id)initWithTimer:(MHDataDeviceTimer* )timer andIdentifier:(NSString *)identifier;
@property (nonatomic, copy) void(^onDone)(MHDataDeviceTimer*);

@end
