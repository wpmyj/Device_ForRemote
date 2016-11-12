//
//  MHLumiChangeIconManager.h
//  MiHome
//
//  Created by Lynn on 3/18/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MiHomeKit/MiHomeKit.h>
#import "MHLMDownLoadFileTools.h"
#import "MHDeviceGatewayBaseService.h"

#define Lumi_Device_Icons_Path  @"lumi/icons/"

NS_ASSUME_NONNULL_BEGIN

@interface MHLumiChangeIconManager : NSObject

+ (id)sharedInstance ;

/**
 *  根据iconid 获取iconURL，并下载
 *
 *  @param iconId            iconId description
 *  @param service           service description
 *  @param completionHandler completionHandler description
 */
- (void)fetchIconUrlsByIconId:(NSString *)iconId
                  withService:(MHDeviceGatewayBaseService *)service
            completionHandler:(CompletionHandler)completionHandler;

/**
 *  图片下载请求接收
 *
 *  @param service           设备Service
 *  @param iconId            iconId
 *  @param iconUrlArray      iconUrlArray @[ @"mainpage_on", @"mainpage_off", @"device_on", @"device_off"]
 *  @param completionHandler completionHandler description
 */
- (void)deviceIconByService:(MHDeviceGatewayBaseService *)service
                     iconId:(NSString *)iconId
               iconUrlArray:(NSArray  *)iconUrlArray
      withCompletionHandler:(CompletionHandler)completionHandler;

/**
 *  设置图片
 *
 *  @param service           设备Service
 *  @param iconId            iconId description
 *  @param aliasName         aliasName description
 *  @param completionHandler result = icons , @[ @"mainpage_on", @"mainpage_off", @"device_on", @"device_off" ] 按此顺序的四张图
 */
- (void)setDeviceIconWith:(MHDeviceGatewayBaseService *)service
               withIconId:(NSString *)iconId
        completionHandler:(CompletionHandler)completionHandler;

- (void)fetchNewPdataByService:(MHDeviceGatewayBaseService *)service
         withCompletionHandler:(CompletionHandler)completionHandler;

/**
 *  从缓存 分类获取用户自定义图标数据
 *
 *  @param service              设备 service
 *  @param completionHandler    如果返回nil，则会读远程数据
 *
 *  @return icon Id
 */
- (NSString *)restorePdataByService:(MHDeviceGatewayBaseService *)service
              withCompletionHandler:(CompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
