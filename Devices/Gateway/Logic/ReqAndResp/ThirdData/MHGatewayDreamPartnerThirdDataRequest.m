//
//  MHGatewayDreamPartnerThirdDataRequest.m
//  MiHome
//
//  Created by guhao on 3/18/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayDreamPartnerThirdDataRequest.h"
#import "MHDeviceGateway.h"


#define Gateway_dream     @"lumi_dream_partner_flag"


@implementation MHGatewayDreamPartnerThirdDataRequest
- (NSString *)api
{
    return @"/third/getappdata";
}
- (id)jsonObject
{
    NSDictionary *json = @{ @"key" : Gateway_dream , @"model" : DeviceModelGateWay };
    
    return json;
}
@end
