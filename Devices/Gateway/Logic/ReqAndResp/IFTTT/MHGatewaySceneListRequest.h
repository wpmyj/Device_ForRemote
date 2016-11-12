//
//  MHGatewayScenListRequest.h
//  MiHome
//
//  Created by Lynn on 9/4/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>
#import "MHDeviceGatewayBase.h"

@interface MHGatewaySceneListRequest : MHBaseRequest

@property (nonatomic,strong) MHDeviceGatewayBase *sensor;
@property (nonatomic,strong) NSString *st_id;

@end
