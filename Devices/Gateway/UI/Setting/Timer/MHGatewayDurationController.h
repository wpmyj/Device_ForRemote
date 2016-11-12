//
//  MHGatewayDurationController.h
//  MiHome
//
//  Created by Lynn on 8/12/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import <MiHomeKit/MiHomeKit.h>

typedef enum{
    FiveMinType,
    TenMinType,
    FifteenMinType,
    HalfHourType,
    ForverType
}DurationType;

@class MHGatewayDurationController;
typedef void(^MHGatewayDurationControllerCallBack)(DurationType type);

@interface MHGatewayDurationController : MHLuViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,strong) MHGatewayDurationControllerCallBack callback;
@property (nonatomic,assign) DurationType selectionType;

@end
