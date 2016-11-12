//
//  MHDeviceGatewaySensorAdder.m
//  MiHome_gateway
//
//  Created by Lynn on 7/23/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHDeviceGatewaySensorAdder.h"

@implementation MHDeviceGatewaySensorAdder

- (id)initWithData:(MHDataDevice* )data {
    if (self = [super initWithData:data]) {
    }
    return self;
}

//- (id)initWithDevice:(MHDevice* )device {
//    if (self = [super initWithDevice:device]) {
//        
//    }
//    return self;
//}

+ (NSUInteger)getDeviceType {
    return MHDeviceType_Unknown;
}

+ (NSString* )getIconImageName {
    return @"icon_add_normal";
}

- (NSInteger)category
{
    return MHDeviceCategoryZigbee;
}

@end
