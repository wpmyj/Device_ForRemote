//
//  MHLuTimerSelfDefineViewController.h
//  MiHome
//
//  Created by Lynn on 10/16/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import <MiHomeKit/MiHomeKit.h>

@interface MHLuTimerSelfDefineViewController : MHLuViewController<UITableViewDelegate, UITableViewDataSource>
- (id)initWithTimer:(MHDataDeviceTimer* )timer;

@end
