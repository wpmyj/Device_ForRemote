//
//  MHGatewayTimerOnOffTimeSettingCell.h
//  MiHome
//
//  Created by guhao on 3/28/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHTableViewCell.h"
#import <MiHomeKit/MHDataDeviceTimer.h>

typedef void (^CleanBtnCallBack)(NSString *itemIdentifier);

#define ItemIdentifierOn  @"mydevice.timersetting.on"
#define ItemIdentifierOff @"mydevice.timersetting.off"


@interface MHGatewayTimerOnOffTimeSettingCell : MHTableViewCell

@property (nonatomic, strong) CleanBtnCallBack cleanCallBack;
- (void)configIdentifier:(NSString *)identifier withTimer:(MHDataDeviceTimer *)timer;

- (void)configIdentifier:(NSString *)identifier withTime:(NSArray *)time;

@end
