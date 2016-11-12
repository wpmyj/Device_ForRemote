//
//  MHGatewayExtraSceneManager.h
//  MiHome
//
//  Created by Lynn on 1/25/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MiHomeKit/MiHomeKit.h>
#import "MHDataIFTTTAction.h"

@interface MHGatewayExtraSceneManager : NSObject

+ (id)sharedInstance;

/**
 *  获取本地化自动化逻辑信息配置表
 *
 *  @param success
 *  @param failure 
 */
- (void)fetchExtraMapTableWithSuccess:(SucceedBlock)success failure:(FailedBlock)failure ;

/**
 *  重造自动化数据
 *
 *  @param scene
 *  @param success 
 */
- (void)mapExtraInfoWithScene:(NSDictionary *)scene andSuccess:(SucceedBlock)success ;


/**
 *  计算延时自动化extra
 *
 *  @param delayActions 延时action列表
 *  @param success      success description
 */
- (NSArray *)extraInfoForDelayAction:(NSArray *)delayActions DEPRECATED_ATTRIBUTE;
/**
 *  计算延时自动化extra
 *
 *  @param delayAction 需要加延时的action
 *  @param adt         延时时间
 *
 */
- (void)extraInfoForDelayAction:(MHDataIFTTTAction *)delayAction withAbsoluteDelaytime:(NSUInteger)adt;


@end
