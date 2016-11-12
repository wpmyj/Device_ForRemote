//
//  MHGatewayMainViewController.h
//  MiHome
//
//  Created by Lynn on 2/16/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLuDeviceViewControllerBase.h"
typedef enum : NSInteger{
    MainPage_ALARM = 0,//警戒
    MainPage_FM,//FM
    MainPage_Light,//夜灯
}MaiPageHeaderType;

@interface MHGatewayMainViewController : MHLuDeviceViewControllerBase
/**
 *  设置首页banner显示的页面
 *
 *  @param headerType headerType description
 */
- (void)setDefaultMainPageHeader:(MaiPageHeaderType)headerType;

@end
