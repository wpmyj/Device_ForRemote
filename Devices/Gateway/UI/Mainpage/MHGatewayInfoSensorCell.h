//
//  MHGatewayInfoSensorCell.h
//  MiHome
//
//  Created by Lynn on 2/17/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHTableViewCell.h"

@interface MHGatewayInfoSensorCell : MHTableViewCell

@property (nonatomic,strong) NSDictionary *sensorInfo;
@property (nonatomic,copy) void (^longPressed)(MHGatewayInfoSensorCell *cell);

@end
