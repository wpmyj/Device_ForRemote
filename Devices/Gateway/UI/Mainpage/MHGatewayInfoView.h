//
//  MHGatewayInfoView.h
//  MiHome
//
//  Created by Lynn on 2/16/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHDeviceGateway.h"

@interface MHGatewayInfoView : UIView

@property (nonatomic,copy) void (^openDevicePageCallback)(MHDeviceGatewayBase *sensor);
@property (nonatomic,copy) void (^openDeviceLogPageCallback)(MHDeviceGatewayBase *sensor);
@property (nonatomic,copy) void (^chooseServiceIcon)(MHDeviceGatewayBaseService *service);

@property (nonatomic,strong) UITableView *tableView;
//@property (nonatomic,assign) BOOL shouldKeepRunning;

- (id)initWithFrame:(CGRect)frame
             sensor:(MHDeviceGateway* )gateway
         subDevices:(NSArray *)subDevices
     callbackHeight:(void (^)(CGFloat height))callbackHeight;

//- (void)startWatchingLatestLog;
//- (void)stopWatchingLatestLog;

@end
