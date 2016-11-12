//
//  MHACPartnerMainViewController.h
//  MiHome
//
//  Created by ayanami on 16/5/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLuDeviceViewControllerBase.h"
typedef enum : NSInteger{
    Gateway_ALARM = 0,//警戒
    Gateway_FM,//FM
}GatewayBannerType;
@interface MHACPartnerMainViewController : MHLuDeviceViewControllerBase
/**
 *  设置网关页banner显示的页面
 *
 *  @param headerType headerType description
 */
- (void)setDefaultBanner:(GatewayBannerType)headerType;
@end
