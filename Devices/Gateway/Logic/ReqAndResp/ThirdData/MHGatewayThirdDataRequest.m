//
//  MHGatewayMusicConfig.m
//  MiHome
//
//  Created by Lynn on 8/17/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayThirdDataRequest.h"
#import "MHDeviceGateway.h"

#define Gateway_Music_Key @"lumi_cloud_music_list_"

@implementation MHGatewayThirdDataRequest

- (NSString *)api
{
    return @"/third/getappdata";
}

- (id)jsonObject
{
    if (!self.keyString.length)
        self.keyString = Gateway_Music_Key;
    
    NSDictionary *json = @{};
    if (!self.pageIndex.length){
        json = @{ @"key" : self.keyString , @"model" : DeviceModelGateWay };

    }
    else {
        json = @{ @"key" : [NSString stringWithFormat:@"%@%d",self.keyString , self.pageIndex.intValue + 1] , @"model" : DeviceModelGateWay };
    }
        
    return json;
}

@end
