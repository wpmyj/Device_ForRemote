//
//  MHGatewayBuyingLinksThirdDataRequest.m
//  MiHome
//
//  Created by guhao on 16/4/28.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHGatewayBuyingLinksThirdDataRequest.h"
#import "MHDeviceGateway.h"

#define kBuyingKey     @"lumi_buying_links"

@implementation MHGatewayBuyingLinksThirdDataRequest

- (NSString *)api
{
    return @"/third/getappdata";
}
- (id)jsonObject
{
    NSDictionary *json = @{ @"key" : kBuyingKey, @"model" : DeviceModelGateWay };
    
    return json;
}
@end
