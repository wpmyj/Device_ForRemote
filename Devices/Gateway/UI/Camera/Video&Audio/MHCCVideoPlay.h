//
//  MHCCVideoPlay.h
//  MiHome
//
//  Created by ayanami on 8/25/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHDeviceCamera.h"

@interface MHCCVideoPlay : NSObject

- (instancetype)initWithSensor:(MHDeviceCamera *)camera;

- (void)startFetchData;


@end
