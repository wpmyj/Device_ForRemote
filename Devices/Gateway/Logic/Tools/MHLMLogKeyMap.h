//
//  MHLMLogKeyMap.h
//  MiHome
//
//  Created by Lynn on 2/1/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHDeviceGateway.h"

@interface MHLMLogKeyMap : NSObject

+ (NSString *)LMDeviceLogKeyMap:(NSString *)currentString log:(MHDataGatewayLog *)log ;

+ (NSString *)LMGatewayMusicNameMapWithGroup:(BellGroup)group
                                       index:(NSInteger)index;

@end
