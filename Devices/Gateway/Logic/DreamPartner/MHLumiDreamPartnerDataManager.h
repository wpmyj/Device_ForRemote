//
//  MHLumiDreamPartnerDataManager.h
//  MiHome
//
//  Created by guhao on 3/18/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHDeviceGatewaySensorHumiture.h"

#define kSensor_motion @"sensor_motion"
#define kSensor_magnet @"sensor_magnet"
#define kSensor_switch @"sensor_switch"

@interface MHLumiDreamPartnerDataManager : NSObject

+ (id)sharedInstance;

- (void)fetchDreamPartnerDataSuccess:(SucceedBlock)success
                              andFailure:(FailedBlock)failure;

- (void)fetchBuyingLinksDataSuccess:(SucceedBlock)success
                          andFailure:(FailedBlock)failure;
@end
