//
//  MHGatewayLightTimeSettingViewController.h
//  MiHome
//
//  Created by guhao on 4/13/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import <MiHomeKit/MHDataDeviceTimer.h>

@interface MHGatewayLightTimeSettingViewController : MHLuViewController<UIActionSheetDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>

- (id)initWithTimer:(NSArray * )timer andIdentifier:(NSString *)identifier;

@property (nonatomic, copy) void(^onDone)(NSArray *time);
@end
