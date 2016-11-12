//
//  MHLumiCache.m
//  MiHome
//
//  Created by Lynn on 12/23/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLumiCache.h"
#import <MiHomeKit/MiHomeKit.h>
#import "MHCacheStorage.h"

@interface MHLumiCache ()

@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation MHLumiCache
{
    NSString *          _currentAccount;
    BOOL                _isReady;
    
    NSArray *           _uniquenessConstraints;
}


+ (instancetype)sharedInstance
{
    static MHLumiCache* g_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_instance = [[MHLumiCache alloc] init];
    });
    return g_instance;
}

#pragma mark - 1,先设置mom，创建entity
- (void)buildMOM
{
    if (_managedObjectModel != nil) {
        return ;
    }
    self.managedObjectModel = [[NSManagedObjectModel alloc] init];
}

- (void)createLumiPlugQuantEntity {
    if(!self.managedObjectModel){
        [self buildMOM];
    }
    
    NSEntityDescription *quantEntity = [[NSEntityDescription alloc] init];
    [quantEntity setName:kEntityNamePlugQuant];
    [quantEntity setManagedObjectClassName:kEntityNamePlugQuant];
    
    [self.managedObjectModel setEntities:[NSArray arrayWithObject:quantEntity]];
 
    NSAttributeDescription *deviceIdAttribute = [[NSAttributeDescription alloc] init];
    [deviceIdAttribute setName:@"deviceId"];
    [deviceIdAttribute setAttributeType:NSStringAttributeType];
    [deviceIdAttribute setOptional:NO];
    
    NSAttributeDescription *dateAttribute = [[NSAttributeDescription alloc] init];
    [dateAttribute setName:@"dateString"];
    [dateAttribute setAttributeType:NSStringAttributeType];
    [dateAttribute setOptional:NO];
    
    NSAttributeDescription *dateTypeAttribute = [[NSAttributeDescription alloc] init];
    [dateTypeAttribute setName:@"dateType"];
    [dateTypeAttribute setAttributeType:NSStringAttributeType];
    [dateTypeAttribute setOptional:NO];

    NSAttributeDescription *quantAttribute = [[NSAttributeDescription alloc] init];
    [quantAttribute setName:@"quantValue"];
    [quantAttribute setAttributeType:NSStringAttributeType];
    [quantAttribute setOptional:NO];
    [quantAttribute setDefaultValue:@"0"];
    
    //设置属性集合
    NSArray *properties = @[ deviceIdAttribute, dateAttribute, dateTypeAttribute, quantAttribute ];
    [quantEntity setProperties:properties];
    
    //设置唯一性校验
//    NSArray *uniquenessConstraints = @[ dateAttribute , dateTypeAttribute];
//    if ([quantEntity respondsToSelector:@selector(setUniquenessConstraints:)]){
//        [quantEntity setUniquenessConstraints:@[ uniquenessConstraints ]];
//    }
    _uniquenessConstraints = @[ @"deviceId" , @"dateString" , @"dateType" ];
    
    //设置本地描述
    NSMutableDictionary *localizationDictionary = [NSMutableDictionary dictionary];
    [localizationDictionary setObject:@"Date" forKey:@"Property/date/Entity/LumiPlugQuant"];
    [localizationDictionary setObject:@"Quant Value" forKey:@"Property/quantValue/Entity/LumiPlugQuant"];
    
    [self.managedObjectModel setLocalizationDictionary:localizationDictionary];
}

#pragma mark - 2,再初始化，psc，moc
- (void)resetWithAccount:(NSString *)account {
    _currentAccount = account;

    [self buildPSC];
    [self buildMOC];
    
    _isReady = YES;
}

- (void)buildPSC
{
    NSString* storeUrlStr = [NSString stringWithFormat:@"%@_%@", _currentAccount ,kStoreFileName];
    NSURL* storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:storeUrlStr];
    
    NSDictionary* options = @{NSMigratePersistentStoresAutomaticallyOption:@YES,NSInferMappingModelAutomaticallyOption:@YES};
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    NSError *error = nil;
    if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"peristentStoreCoordinator error %@, %@", error, [error userInfo]);
    }
}

- (void)buildMOC
{
    if (self.persistentStoreCoordinator)
    {
        self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [self.managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
}

#pragma mark - 公开，数据操作
- (void)asyncSaveItemsByEntityDescriptionName:(NSString*)entityName
                                    dataArray:(NSArray*)dataArray
               fillManagedObjectWithDataBlock:(void (^)(NSManagedObject* mo, id data))fillBlock
                          withCompletionBlock:(void (^)())completionBlock {
    
    [self.managedObjectContext performBlock:^{
                
        //存储
        NSArray* originArr = [NSArray arrayWithArray:dataArray];
        [self saveItemsByEntityDescriptionName:entityName dataArray:originArr fillManagedObjectWithDataBlock:fillBlock];
        
        //生效
        [self saveContext];
        
        dispatch_async(dispatch_get_main_queue(),^{
            if (completionBlock)
            {
                completionBlock();
            }
        });
    }];
}

- (void)asyncFetchItemsByEntityDescriptionName:(NSString *)entityName withFetchRequestChangeBlock:(NSFetchRequest *(^)(NSFetchRequest *))fetchRequestChangeBlock dataWithManagedObjectBlock:(id (^)(NSManagedObject *))dataWithManagedObjectBlock withCompletionBlock:(void (^)(NSArray *))completionBlock
{
    [self.managedObjectContext performBlock:^{
        NSArray *result = [self fetchItemsByEntityDescriptionName:entityName withFetchRequestChangeBlock:fetchRequestChangeBlock];
        if (!result)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock)
                {
                    completionBlock(nil);
                }
            });
            return;
        }
        
        // convert managed objects to data objects
        if (dataWithManagedObjectBlock)
        {
            __block NSMutableArray* dataList = [[NSMutableArray alloc] init];
            [result enumerateObjectsUsingBlock:^(NSManagedObject* managedObject, NSUInteger idx, BOOL *stop) {
                // 把ManagedObject转换成data
                id data = dataWithManagedObjectBlock(managedObject);
                [dataList addObject:data];
            }];
            result = [NSArray arrayWithArray:dataList];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock)
            {
                completionBlock(result);
            }
        });
    }];
}

// 异步删除
- (void)asyncDeleteItemsByEntityDescriptionName:(NSString *)entityName withFetchRequestChangeBlock:(NSFetchRequest *(^)(NSFetchRequest *))fetchRequestChangeBlock withCompletionBlock:(void (^)())completionBlock
{
    [self.managedObjectContext performBlock:^{
        NSArray *result = [self fetchItemsByEntityDescriptionName:entityName withFetchRequestChangeBlock:fetchRequestChangeBlock];
        if (!result)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock)
                {
                    completionBlock();
                }
            });
            return;
        }
        
        [self deleteDataItems:result];
        [self saveContext];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock)
            {
                completionBlock();
            }
        });
    }];
}

#pragma mark - 私有，存储
/**
 *  唯一性校验
 *
 *  @param constraintsValue 校验条件
 *  @param entityName
 *
 *  @return YES＝通过，NO＝不通过
 */
- (BOOL)syncUniqueConstraintsCheck:(NSDictionary *)constraintsValue
                    withEntityName:(NSString *)entityName
{
    //设置唯一性校验条件
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSString *predicateString = @"";
    for (NSString *attribute in _uniquenessConstraints) {
        if (predicateString.length) {
            predicateString = [NSString stringWithFormat:@"%@ and %@ = '%@' " ,
                               predicateString ,
                               attribute,
                               [constraintsValue valueForKey:attribute]];
        }
        else {
            predicateString = [NSString stringWithFormat:@"%@ = '%@'" , attribute, [constraintsValue valueForKey:attribute]];
        }
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
    [fetchRequest setPredicate:predicate];
    
    __block NSArray *result = nil;
    [self.managedObjectContext performBlockAndWait:^{
        result = [self fetchItemsByEntityDescriptionName:entityName
                             withFetchRequestChangeBlock:^NSFetchRequest *(NSFetchRequest *r) {
                                 return fetchRequest;
                             }];
    }];
    
    if (result.count) return NO;
    else return YES;
}

// 查询，返回NSManagedObject数组
- (NSArray *)fetchItemsByEntityDescriptionName:(NSString *)entityName withFetchRequestChangeBlock:(NSFetchRequest *(^)(NSFetchRequest *))fetchRequestChangeBlock
{
    if (!_isReady)
    {
        return nil;
    }
    
    NSArray *result = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    if (!fetchRequest)
    {
        @throw [NSException exceptionWithName:@"CoreDataException" reason:@"EntityType does not exist" userInfo:nil];
    }
    
    if (fetchRequestChangeBlock)
    {
        fetchRequest = fetchRequestChangeBlock(fetchRequest);
    }
    
    NSError *error = nil;
    result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error)
    {
        NSLog(@"Error while fetching results: %@", error);
        result = nil;
    }
    
    return result;
}

//存一批
- (void)saveItemsByEntityDescriptionName:(NSString*)entityName
                               dataArray:(NSArray*)dataArray
          fillManagedObjectWithDataBlock:(void (^)(NSManagedObject* mo, id data))fillBlock {
    if (!_isReady)
    {
        return;
    }
    
    @try
    {
        [dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            BOOL uniqueChecked ;
            if (self->_uniquenessConstraints.count){
                NSDictionary *check = [self checkDictionary:obj];
                uniqueChecked = [self syncUniqueConstraintsCheck:check
                                                  withEntityName:entityName];
            }
            else {
                uniqueChecked = YES;
            }
            if (uniqueChecked){
                NSManagedObject* mo = [self buildManagedObjectByName:entityName];
                fillBlock(mo, obj);
            }
            else {
                NSLog(@"不符合唯一性，这条不存");
            }
        }];
    }
    @catch (NSException *exception)
    {
        NSLog(@"saveItemsByEntityDescriptionName exception:%@", [exception description]);
    }
    @finally
    {
        
    }
}

//删除一组数据
- (void)deleteDataItems:(NSArray *)itemArray
{
    if (!_isReady)
    {
        return;
    }
    
    [itemArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSManagedObject* item = (NSManagedObject *)obj;
        NSManagedObject *getObject = item;
        if (item.isFault)
        {
            getObject = [self dataItemWithID:item.objectID];
        }
        if (getObject)
        {
            @try
            {
                [self.managedObjectContext deleteObject:getObject];
            }
            @catch (NSException *exception)
            {
                NSLog(@"deleteDataItems exception :%@", [exception description]);
            }
            @finally
            {
                
            }
        }
        
    }];
}

// 根据ID取一条指定data
- (id)dataItemWithID:(NSManagedObjectID *)objectId
{
    if (objectId && self.managedObjectContext)
    {
        NSManagedObject *item = nil;
        @try
        {
            item = [self.managedObjectContext objectWithID:objectId];
        }
        @catch (NSException *exception)
        {
            NSLog(@"dataItemWithID exception:%@", [exception description]);
            item = nil;
        }
        @finally {
            
        }
        return item;
    }
    return nil;
}

// insert object
- (NSManagedObject *)buildManagedObjectByName:(NSString *)entityName
{
    NSManagedObject * object = nil;
    object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
    return object;
}

// 存储当前context
- (void)saveContext
{
    @try
    {
        if ([self.managedObjectContext hasChanges])
        {
            NSError *error = nil;
            if (![self.managedObjectContext save:&error])
            {
                NSLog(@"saveContext error %@,%@",error,[error userInfo]);
            }
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"saveContext exception %@,%@",exception,[exception userInfo]);
    }
    @finally
    {
        
    }
}

#pragma mark - 通用方法
- (NSDictionary *)checkDictionary:(id)data {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (NSString *attribute in _uniquenessConstraints) {
        [dic setObject:[data valueForKey:attribute] forKey:attribute];
    }
    return dic;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
