//
//  MHLumiLogGraphTool.h
//  MiHome
//
//  Created by guhao on 3/21/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHGatewayWebViewController.h"

@interface MHLumiLogGraphManager : NSObject

+ (id)sharedInstance;
/**
 *  温湿度,插座功率,日志图表
 *
 *  @param did                设备did
 *  @param url                webURL
 *  @param identifier         标题字段(NSLocalizedStringFromTable(identifier, @"plugin_gateway", nil))
 *  @param segeViewController 当前带导航的视图控制器
 */
- (void)getLogListGraphWithDeviceDid:(NSString *)did
                       andDeviceType:(GraphDeviceType)deviceType
                              andURL:(NSString *)url
                            andTitle:(NSString *)title
               andSegeViewController:(UIViewController *)segeViewController;
@end
