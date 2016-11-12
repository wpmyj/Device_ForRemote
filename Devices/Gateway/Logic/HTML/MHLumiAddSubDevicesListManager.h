//
//  MHLumiAddSubDevicesTool.h
//  MiHome
//
//  Created by guhao on 3/21/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHDeviceGateway.h"
#import "MHLumiHtmlHandleTools.h"

@interface MHLumiAddSubDevicesListManager : NSObject

+ (id)sharedInstance;
/**
 *  添加子设备列表
 *
 *  @param gatewayDevice      网关
 *  @param identifier         标题字段(NSLocalizedStringFromTable(identifier, @"plugin_gateway", nil))
 *  @param segeViewController 当前带导航的视图控制器
 */
- (void)chooseAddSubDeviceListWithGatewayDevice:(MHDeviceGateway *)gatewayDevice
                             andTitleIdentifier:(NSString *)identifier
                          andSegeViewController:(UIViewController *)segeViewController;
/**
 *  添加子设备
 *
 *  @param subdeviceModelClassName 子设备model类名
 *  @param deviceName              子设备名称
 */
- (void)addSubdeviceWithSubDeviceType:(NSString *)deviceType andDeviceName:(NSString *)deviceName;
@end
