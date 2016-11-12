//
//  MHLumiCache.h
//  MiHome
//
//  Created by Lynn on 12/23/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

//PlugQuant存储的Entity名称
#define kEntityNamePlugQuant    @"plugquant"
#define kStoreFileName          @"lumihome.sqlite"


@interface MHLumiCache : NSObject

@property (nonatomic,strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;

+ (instancetype)sharedInstance;

//1,为lumiplug电量统计 创建Entity
- (void)createLumiPlugQuantEntity ;

//2,初始化
- (void)resetWithAccount:(NSString *)account;

/**
 *  异步存储数据
 *
 *  @param entityName      entityName
 *  @param dataArray       dataArray
 *  @param fillBlock       数据填充block，在相关的entity，cachebase里面实现
 *  @param completionBlock completionBlock
 */
- (void)asyncSaveItemsByEntityDescriptionName:(NSString*)entityName
                                    dataArray:(NSArray*)dataArray
               fillManagedObjectWithDataBlock:(void (^)(NSManagedObject* mo, id data))fillBlock
                          withCompletionBlock:(void (^)())completionBlock;
/**
 *  @brief 异步获取数据
 *
 *  @param entityName                 数据存储entity
 *  @param fetchRequestChangeBlock    该block用于设置fetchRequest的查询属性，为NULL时fetchRequest会取出表中全部数据
 *  @param dataWithManagedObjectBlock 该block用ManagedObject填充对应的数据类型，为NULL时返回ManagedObject列表
 *  @param completionBlock            完成异步数据读取后调用该block
 */
- (void)asyncFetchItemsByEntityDescriptionName:(NSString *)entityName
                   withFetchRequestChangeBlock:(NSFetchRequest *(^)(NSFetchRequest *))fetchRequestChangeBlock
                    dataWithManagedObjectBlock:(id (^)(NSManagedObject *))dataWithManagedObjectBlock
                           withCompletionBlock:(void (^)(NSArray *))completionBlock ;

/**
 *  异步删除
 *
 *  @param entityName              
 *  @param fetchRequestChangeBlock 该block用于设置fetchRequest的属性
 *  @param completionBlock         完成后调用该block
 */
- (void)asyncDeleteItemsByEntityDescriptionName:(NSString *)entityName
                    withFetchRequestChangeBlock:(NSFetchRequest *(^)(NSFetchRequest *))fetchRequestChangeBlock
                            withCompletionBlock:(void (^)())completionBlock ;

@end
