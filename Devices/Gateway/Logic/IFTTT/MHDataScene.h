//
//  MHDataScene.h
//  MiHome
//
//  Created by Lynn on 9/9/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHDataAction.h"
#import "MHDataLaunch.h"

@interface MHDataScene : MHDataBase <NSCopying,NSCoding>

@property (nonatomic,strong) NSString *uid; //user id
@property (nonatomic,strong) NSString *usId; //scene id
@property (nonatomic,strong) NSString *std_id;//8,15,22已知三种
@property (nonatomic,strong) NSString *identify;//还不知道什么卵用的，先留着吧(后面原路回，不然不传)
@property (nonatomic,strong) NSString *name; //scene name
@property (nonatomic,strong) NSMutableArray *actionList; //执行任务列表
@property (nonatomic,strong) NSMutableArray *launchList; //启动条件列表
@property (nonatomic,strong) NSNumber *express; //大师说联动报警要加这个表示或

@property (nonatomic,assign) BOOL enable;

@property (nonatomic,strong) NSMutableArray *authed;
@property (nonatomic,strong) NSMutableDictionary *setting;

- (void)initLaunchList:(NSArray *)launchList withDevice:(MHDevice *)sensor;
- (void)initActionList:(NSArray *)actionList withDevice:(MHDevice *)sensor;

- (NSMutableDictionary *)sceneToDictionary;

/**
 *  删除自动化
 *
 *  @param success 
 *  @param failure
 */
- (void)deleteSceneWithSuccess:(SucceedBlock)success andFailure:(FailedBlock)failure;

/**
 *  添加或保存自动化
 *
 *  @param success
 *  @param failure
 */
- (void)saveSceneWithSuccess:(SucceedBlock)success andFailure:(FailedBlock)failure;

@end
