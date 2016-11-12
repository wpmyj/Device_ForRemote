//
//  MHGatewayBindSceneManager.h
//  MiHome
//
//  Created by Lynn on 1/11/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MiHomeKit/MiHomeKit.h>
#import "MHDeviceGatewayBase.h"
#import "MHDeviceGateway.h"
#import "MHDataScene.h"

@interface MHGatewayBindSceneManager : NSObject

+ (id)sharedInstance ;

/**
 *  获取绑定列表（自动化列表，转成绑定表）
 *
 *  @param device  gateway
 *  @param success
 *  @param failure
 */
- (void)fetchBindSceneList:(MHDeviceGateway *)device
               withSuccess:(SucceedBlock)success ;

/**
 *  获取缓存的自动化
 *
 *  @param deviceDid
 *  @param success   
 */
- (void)restoreBindList:(MHDeviceGateway *)device ;

/**
 *  获取远程自动化
 *
 *  @param gateway
 *  @param success
 *  @param failure 
 */
- (void)fetchRemote:(MHDeviceGateway *)gateway
        withSuccess:(SucceedBlock)success
            failure:(FailedBlock)failure;
/**
 *  新增绑定自动化
 *
 *  @param item    绑定
 *  @param gateway 网关
 *  @param success
 *  @param failure 
 */
- (void)addScene:(MHLumiBindItem *)item
     withGateway:(MHDeviceGateway *)gateway
         success:(SucceedBlock)success
         failure:(FailedBlock)failure ;

/**
 *  移除绑定自动化
 *
 *  @param item    绑定
 *  @param gateway 网关
 *  @param success
 *  @param failure 
 */
- (void)removeScene:(MHLumiBindItem *)item
        withGateway:(MHDeviceGateway *)gateway
            success:(SucceedBlock)success
            failure:(FailedBlock)failure ;
@end
