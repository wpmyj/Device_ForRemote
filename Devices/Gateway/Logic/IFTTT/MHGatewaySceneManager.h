//
//  MHGatewaySceneListManager.h
//  MiHome
//
//  Created by Lynn on 9/4/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>
#import "MHDeviceGatewayBase.h"

@interface MHGatewaySceneManager : MHDataListManagerBase

+ (id)sharedInstance;

- (void)getRecordsListSuccess:(SucceedBlock)success
                  failure:(FailedBlock)failure ; //指定设备的系统场景


/**
 *  拉取特定类型的自动化
 *
 *  @param device  特定设备
 *  @param stid    自动化类型，8 ， 15 ， 21 ， 22
 *  @param success
 *  @param failure
 */
- (void)fetchSceneListWithDevice:(MHDeviceGatewayBase *)device
                            stid:(NSString *)stid
                      andSuccess:(SucceedBlock)success
                         failure:(FailedBlock)failure ;

/**
 *  拉取设备自动化（用户设定自动化），st_id = 15
 *
 *  @param device  特定设备
 *  @param success
 *  @param failure
 */
- (void)fetchSceneListWithDevice:(MHDeviceGatewayBase *)device
                         success:(SucceedBlock)success
                      andfailure:(FailedBlock)failure ;

/**
 *  获取自动化模版
 *
 *  @param success
 *  @param failure
 */
- (void)fetchSceneTplWithSuccess:(SucceedBlock)success
                      andfailure:(FailedBlock)failure ;

/**
 *  编辑自动化
 *
 *  @param parmas  自动化数据
 *  @param success
 *  @param failure
 */
- (void)saveSceneEditWithParms:(NSMutableDictionary *)parmas
                    andSuccess:(SucceedBlock)success
                    andfailure:(FailedBlock)failure ;

/**
 *  删除自动化
 *
 *  @param usid    scene.id
 *  @param success
 *  @param failure
 */
-(void)deleteSceneWithUsid:(NSString *)usid
                andSuccess:(SucceedBlock)success
                andFailure:(FailedBlock)failure ;

/**
 *  获取推荐自动化
 *
 *  @param device  特定设备
 *  @param success
 *  @param failure
 */
- (void)fetchSceneRecomWithDevice:(MHDeviceGatewayBase *)device
                          success:(SucceedBlock)success
                       andfailure:(FailedBlock)failure ;

+ (NSMutableArray *)reBuildActionData:(NSMutableArray *)actionList;
+ (NSMutableArray *)reBuildLaunchData:(NSMutableArray *)launchList;

@end
