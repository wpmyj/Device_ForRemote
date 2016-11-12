//
//  MHACPartnerInfoView.h
//  MiHome
//
//  Created by ayanami on 16/5/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHDeviceAcpartner.h"

@interface MHACPartnerInfoView : UIView

@property (nonatomic,strong) void (^openDevicePageCallback)(MHDeviceGatewayBase *sensor);
@property (nonatomic,strong) void (^openDeviceLogPageCallback)(MHDeviceGatewayBase *sensor);
@property (nonatomic,strong) void (^chooseServiceIcon)(MHDeviceGatewayBaseService *service);

@property (nonatomic,strong) UITableView *tableView;
//@property (nonatomic,assign) BOOL shouldKeepRunning;

- (id)initWithFrame:(CGRect)frame
             sensor:(MHDeviceAcpartner* )acpartner
         subDevices:(NSArray *)subDevices
     callbackHeight:(void (^)(CGFloat height))callbackHeight;
@end
