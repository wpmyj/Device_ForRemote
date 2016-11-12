//
//  MHGatewayPlugQuantEngine.m
//  MiHome
//
//  Created by Lynn on 12/17/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLumiPlugQuantEngine.h"
#import "MHLumiCache.h"
#import "MHLumiPlugDataManager.h"
#import "MHLumiPlugQuant.h"
#import "MHLumiPlugQuantCache.h"

#define PlugDataCampareDate   @"2016-01-01 00:00:00"

@interface MHLumiPlugQuantEngine ()

@property (nonatomic,strong) MHLumiCache *cache;
@property (nonatomic,strong) MHLumiPlugDataManager *remoteDataManager;

@end

@implementation MHLumiPlugQuantEngine

+ (id)sharedEngine {
    static MHLumiPlugQuantEngine *obj = nil;
    @synchronized([MHLumiPlugQuantEngine class]) {
        if(!obj)
            obj = [[MHLumiPlugQuantEngine alloc] init];
    }
    return obj;
}

#pragma mark - 计算timeString
- (NSString *)fetchUnixTimeStamp:(NSString *)dateString {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    dateFormatter.timeZone = [NSTimeZone systemTimeZone];
    
    NSDate *dateDate = [dateFormatter dateFromString:dateString];
    
    NSTimeInterval unixTime= [dateDate timeIntervalSince1970];
    long long int unixTimeStamp = (long long int)unixTime;
    
    NSString *timeStamp = [NSString stringWithFormat:@"%lld",unixTimeStamp];

    return timeStamp;
}

- (NSString *)fetchTimeString:(NSString *)unixStamp {
    
    long long int unixTimeStamp = [unixStamp longLongValue];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    dateFormatter.timeZone = [NSTimeZone systemTimeZone];

    NSDate *dateDate = [NSDate dateWithTimeIntervalSince1970:unixTimeStamp];
    NSString *dateString = [dateFormatter stringFromDate:dateDate];
    
    return dateString;
}

//获取当前日（yyyy-MM-dd）和月（yyyy-MM-01）的dateString
- (NSString *)dateString:(NSDate *)date withDateType:(NSString *)dateType {
    
    
    
    NSDateFormatter *dayDateFormatter = [[NSDateFormatter alloc] init];
    dayDateFormatter.dateFormat = @"yyyy-MM-dd";
    dayDateFormatter.timeZone = [NSTimeZone systemTimeZone];

    if([dateType isEqualToString:@"day"]) {
        NSString *dayString = [dayDateFormatter stringFromDate:date];
        dayString = [NSString stringWithFormat:@"%@ 00:00:00", dayString];
        return dayString;
    }
    
    NSDateFormatter *monthDateFormatter = [[NSDateFormatter alloc] init];
    monthDateFormatter.dateFormat = @"yyyy-MM";
    monthDateFormatter.timeZone = [NSTimeZone systemTimeZone];

    if([dateType isEqualToString:@"month"]) {
        NSString *monthString = [monthDateFormatter stringFromDate:date];
        monthString = [NSString stringWithFormat:@"%@-01 00:00:00", monthString];
        return monthString;
    }
    
    return @"没有传入datetype";
}

- (NSString *)fullStringFromDate :(NSDate *)date {
    NSDateFormatter *dayDateFormatter = [[NSDateFormatter alloc] init];
    dayDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    dayDateFormatter.timeZone = [NSTimeZone systemTimeZone];
    
    return [dayDateFormatter stringFromDate:date];
}

- (NSDate *)dateFromString :(NSString *)string {
    NSDateFormatter *dayDateFormatter = [[NSDateFormatter alloc] init];
    dayDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    dayDateFormatter.timeZone = [NSTimeZone systemTimeZone];
    
    return [dayDateFormatter dateFromString:string];
}

#pragma mark - 获取DB电量
//startDate 选填，填写后从这个往后查询
- (NSFetchRequest *)makeFetchRequest:(BOOL)isAscending
                        withDateType:(NSString *)dateType
                          limitedNum:(NSInteger)limitedNum
                          dateString:(NSString *)startDate {
    [self cacheInit];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kEntityNamePlugQuant inManagedObjectContext:_cache.managedObjectContext];
    [fetchRequest setEntity:entity];

    //排序
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"dateString" ascending:isAscending];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sort, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    //查询
    NSString *predicateString = [NSString stringWithFormat:@"deviceId = '%@' ",_remoteDataManager.quantDevice.did];
    if (startDate) {
        NSString *tmpString = [NSString stringWithFormat:@"dateType = '%@' and dateString < '%@'",dateType,startDate];
        predicateString = [NSString stringWithFormat:@"%@ and %@",predicateString, tmpString];
    }
    else {
        //查询
        NSString *tmpString = [NSString stringWithFormat:@"dateType = '%@'",dateType];
        predicateString = [NSString stringWithFormat:@"%@ and %@",predicateString, tmpString];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setFetchLimit:limitedNum];
    
    return fetchRequest;
}

- (MHLumiPlugQuant *)fetchLargestQuantData:(NSArray *)quantArray {
//    NSLog(@"排序之前的%@", quantArray);
    /**
     *  显示当前月份的电量后，下面的排序出现了问题，6p,9.3.1系统，先解决过后再排查问题
     */
    __block MHLumiPlugQuant *largestQuant = nil;
    __block CGFloat elc = 0;
    [quantArray enumerateObjectsUsingBlock:^(MHLumiPlugQuant *quant, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSLog(@"%@", quant.quantValue);
        if ([quant.quantValue floatValue] >= elc) {
            elc = [quant.quantValue floatValue];
            largestQuant = quant;
        }
    }];
//    NSLog(@"最大值%@", largestQuant.quantValue);
    return largestQuant;
    //排序
//    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"quantValue" ascending:NO];
//    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sort, nil];
//    
//    NSArray *copyedArray = [quantArray sortedArrayUsingDescriptors:sortDescriptors];
//    NSLog(@"排序之后的%@", copyedArray);
//    [copyedArray enumerateObjectsUsingBlock:^(MHLumiPlugQuant *after, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSLog(@"%@", after.quantValue);
//    }];
//
//    return copyedArray.firstObject;
}

//获取最近的电量
- (void)fethQuantData:(NSString *)dateType withLatest:(void (^)(MHLumiPlugQuant *))latestQuant {
    //获取最近的电量
    NSFetchRequest *fetchRequest = [self makeFetchRequest:NO withDateType:dateType limitedNum:1 dateString:nil];
    [self fetchCacheListWithFetchRequest:fetchRequest
                      andCompletionBlock:^(NSArray *array) {
                          NSLog(@"%@",array);
                          if(latestQuant) latestQuant(array.firstObject);
                      }];
}

//获取最早的电量
- (void)fethQuantData:(NSString *)dateType withEarliest:(void (^)(MHLumiPlugQuant *))earliestQuant{
    NSFetchRequest *fetchRequest = [self makeFetchRequest:YES withDateType:dateType limitedNum:1 dateString:nil];
    [self fetchCacheListWithFetchRequest:fetchRequest
                      andCompletionBlock:^(NSArray *array) {
                          NSLog(@"%@",array);
                          if(earliestQuant) earliestQuant(array.firstObject);
                      }];
}


//获取指定条目数量的quant，用于显示
- (void)fetchQuantData:(NSString *)startString
            LimitedNum:(NSInteger)limitedNum
              DateType:(NSString *)dateType
   withCompletionBlock:(void (^)(NSArray *array))completionBlock {
    
    NSFetchRequest *fetchRequest = [self makeFetchRequest:NO withDateType:dateType limitedNum:limitedNum dateString:startString];
    [self fetchCacheListWithFetchRequest:fetchRequest
                      andCompletionBlock:^(NSArray *array) {
                          NSLog(@"%@",array);
                          if(completionBlock) completionBlock(array);
                      }];
}

- (void)rebuildDBData:(NSArray *)DBData
             dateType:(NSString *)dateType
       withFinishData:(void (^)(NSArray *displayData , NSArray *timeLineData, MHLumiPlugQuant *largetsQuant))displayData {
    
    NSMutableArray *timeLineData = [NSMutableArray array];
    NSMutableArray *quantData = [NSMutableArray array];
    MHLumiPlugQuant *quant = [self fetchLargestQuantData:DBData];
    
    [DBData enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(MHLumiPlugQuant *quant, NSUInteger idx, BOOL *stop) {
        [timeLineData addObject: quant.dateString ];
        [quantData addObject: @([quant.quantValue doubleValue]) ];
    }];
    if (displayData)displayData([quantData mutableCopy], [timeLineData mutableCopy],quant);
}

#pragma mark - 获取电量,并写入DB
- (NSDate *)fetchOneMonthData:(NSDate *)enDate {
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    calendar.timeZone = [NSTimeZone systemTimeZone];
    
    NSString *endDayDateString = [self dateString:enDate withDateType:@"day"];
    NSDate *endDayDate = [self dateFromString:endDayDateString];

    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    [adcomps setMonth:-1];
    NSDate *startDate = [calendar dateByAddingComponents:adcomps toDate:enDate options:0];
    NSString *startDateString = [self dateString:startDate withDateType:@"day"];
    
    adcomps = [[NSDateComponents alloc] init];
    [adcomps setSecond:-1];
    endDayDate = [calendar dateByAddingComponents:adcomps toDate:endDayDate options:0];
    endDayDateString = [self fullStringFromDate:endDayDate];

    NSLog(@"current(end) = %@ , one month = %@",endDayDateString, startDateString);
    
    NSDictionary *params = @{ @"groupType"       : @"day",
                              @"startDateString" : [self fetchUnixTimeStamp:startDateString],
                              @"endDateString"   : [self fetchUnixTimeStamp:endDayDateString],
                              };
    [self fetchData:params withGroupType:@"day"];
    
    return startDate;
}

- (NSDate *)fetchOneYearData:(NSDate *)enDate {
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    calendar.timeZone = [NSTimeZone systemTimeZone];

    NSString *endDayDateString = [self dateString:enDate withDateType:@"month"];
    NSDate *endDayDate = [self dateFromString:endDayDateString];
    
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    [adcomps setYear:-1];
    
    NSDate *startDate = [calendar dateByAddingComponents:adcomps toDate:enDate options:0];
    NSString *startDateString = [self dateString:startDate withDateType:@"month"];
    
    adcomps = [[NSDateComponents alloc] init];
    [adcomps setSecond:-1];
    endDayDate = [calendar dateByAddingComponents:adcomps toDate:endDayDate options:0];
    endDayDateString = [self fullStringFromDate:endDayDate];
    
    NSLog(@"current(end) = %@ , one month = %@",endDayDateString, startDateString);
    
    NSDictionary *params = @{ @"groupType"       : @"month",
                              @"startDateString" : [self fetchUnixTimeStamp:startDateString],
                              @"endDateString"   : [self fetchUnixTimeStamp:endDayDateString],
                              };
    [self fetchData:params withGroupType:@"month"];
    
    return startDate;
}

//从数据库中的某个点，获取数据到直至今日/当月的
- (void)fetchQuantData:(NSDate *)startDate WithDateType:(NSString *)dateType {
    NSDate *endDate = [NSDate date];
    NSLog(@"startDate%@ endDate%@, dataType%@", startDate, endDate, dateType);

    
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    calendar.timeZone = [NSTimeZone systemTimeZone];
    
    //month TypeData
    if ([dateType isEqualToString:@"month"]){
        NSString *endMonthDateString = [self dateString:endDate withDateType:@"month"];
        NSDate *endMonthDate = [self dateFromString:endMonthDateString];
        
        NSString *startDateString = [self dateString:startDate withDateType:@"month"];
        
        NSDateComponents *adcomps = [[NSDateComponents alloc] init];
        [adcomps setSecond:-1];
        endMonthDate = [calendar dateByAddingComponents:adcomps toDate:endMonthDate options:0];
        endMonthDateString = [self fullStringFromDate:endMonthDate];
        
        NSLog(@"current(end) = %@ , one month = %@",endMonthDateString, startDateString);
        
        NSDictionary *params = @{ @"groupType"       : @"month",
                                  @"startDateString" : [self fetchUnixTimeStamp:startDateString],
                                  @"endDateString"   : [self fetchUnixTimeStamp:endMonthDateString],
                                  };
        [self fetchData:params withGroupType:@"month"];
    }
    
    //day type data
    if ([dateType isEqualToString:@"day"]){
        NSString *endDayDateString = [self dateString:endDate withDateType:@"day"];
        NSDate *endDayDate = [self dateFromString:endDayDateString];
        
        NSString *startDateString = [self dateString:startDate withDateType:@"day"];
        
        NSDateComponents *adcomps = [[NSDateComponents alloc] init];
        [adcomps setSecond:-1];
        endDayDate = [calendar dateByAddingComponents:adcomps toDate:endDayDate options:0];
        endDayDateString = [self fullStringFromDate:endDayDate];
        
        NSLog(@"current(end) = %@ , one day = %@",endDayDateString, startDateString);
        
        NSDictionary *params = @{ @"groupType"       : @"day",
                                  @"startDateString" : [self fetchUnixTimeStamp:startDateString],
                                  @"endDateString"   : [self fetchUnixTimeStamp:endDayDateString],
                                  };
        [self fetchData:params withGroupType:@"day"];
    }
}

- (void)fetchData:(NSDictionary *)params withGroupType:(NSString *)groupType {
    XM_WS(weakself);
    [_remoteDataManager fetchPlugQuantHistoryDataWithParams:params
                                                    Success:^(id obj){
                                                        [weakself rebuildData:obj withGroupType:groupType];
                                                        
                                                    } andFailure:^(NSError *error){
                                                        NSLog(@"%@",error);
                                                    }];
}

- (void)rebuildData:(id)value withGroupType:(NSString *)groupType {

    NSString *resultString = [value substringWithRange:NSMakeRange(1, [value length] - 2)];
    resultString = [resultString stringByReplacingOccurrencesOfString:@"\"" withString:@""];

    NSMutableArray *rawArray = [[resultString componentsSeparatedByString:@","] mutableCopy];
    [rawArray removeObjectAtIndex:0];
    [rawArray removeObjectAtIndex:0];
    
    NSMutableArray *resultValueArray = [NSMutableArray array];
    for (int i = 0 ; i < rawArray.count ; i = i + 2){
        NSString *timeString = [rawArray[i] stringValue];
        NSString *quantString = [rawArray[i + 1] stringValue];
        
        timeString = [self stringRemove:timeString];
        quantString = [self stringRemove:quantString];
        
        NSDictionary *obj = @{ @"dateString" : [self fetchTimeString:timeString],
                               @"quantValue" : [NSString stringWithFormat:@"%.3f",[quantString doubleValue] / 1000],
                               @"dateType"   : groupType ,
                               @"deviceId"   : _remoteDataManager.quantDevice.did,
                               };
        
        [resultValueArray addObject:obj];
    }
    
    NSArray *quantList = [MHLumiPlugQuant dataListWithJSONObjectList:resultValueArray];
    
    //存入数据
    [self cacheDataList:quantList];
}

- (NSString *)stringRemove:(NSString *)raw {
    [raw stringByReplacingOccurrencesOfString:@"," withString:@""];
    return raw;
}

#pragma mark - 循环获取远程数据，写入
//首先获取当前数据库中的状态，如果没有，就从当前时间往后去数据
- (void)findStartPoint:(NSString *)dateType {
    NSDate *comparedDate = [self dateFromString:PlugDataCampareDate];

    __block void (^fetchlatestQuantSuccess)();
    __block void (^fetchlatestQuantFailure)();

    XM_WS(weakself);
    [self fethQuantData:dateType withLatest:^(MHLumiPlugQuant *latestQuant) {

        if (latestQuant) {
            //如果有再执行查找最晚的
            fetchlatestQuantSuccess();
            //获取DB中最近的数据
            NSString *dateString = latestQuant.dateString;
            NSDate *date = [weakself dateFromString:dateString];
            
            NSString *currentDateString = [self dateString:[NSDate date] withDateType:dateType];
            NSDate *currentDate = [self dateFromString:currentDateString];
            //少一天/一月，当前天还没有过完，不在数据库里面存储
            NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            calendar.timeZone = [NSTimeZone systemTimeZone];
            NSDateComponents *adcomps = [[NSDateComponents alloc] init];
            if ([dateType isEqualToString:@"month"]) [adcomps setMonth:-1];
            if ([dateType isEqualToString:@"day"]) [adcomps setDay:-1];
            currentDate = [calendar dateByAddingComponents:adcomps toDate:currentDate options:0];
            
            if ([date timeIntervalSinceDate:currentDate] < 0 ) {
                [weakself fetchQuantData:date WithDateType:dateType];
            }
        }
        else {
            fetchlatestQuantFailure();
        }
    }];
    
    fetchlatestQuantSuccess = ^(){
        //获取最早的数据
        [self fethQuantData:dateType withEarliest:^(MHLumiPlugQuant *earlistQuant){
            NSString *dateString = earlistQuant.dateString;
            NSDate *date = [weakself dateFromString:dateString];
            if ([date timeIntervalSinceDate:comparedDate] >= 0 ){
                [weakself fetchRemoteQuantContinuesly:dateString withDateType:dateType];
            }
        }];
    };

    //如果都是空，则从今天开始循环向后取
    fetchlatestQuantFailure = ^{
        //从今天的零点开始，不计算当日
        NSString *dateDayString = [weakself dateString:[NSDate date] withDateType:dateType];
        [weakself fetchRemoteQuantContinuesly:dateDayString withDateType:dateType];
    };
//    NSString *dateDayString = [weakself dateString:[NSDate date] withDateType:dateType];
//    [weakself fetchRemoteQuantContinuesly:dateDayString withDateType:dateType];
}

//endDate 格式必须是 ‘yyyy-MM-dd HH:mm:ss’
- (void)fetchRemoteQuantContinuesly:(NSString *)endDateString withDateType:(NSString *)dateType{
    
    //从endDate开始，向前循环获取，day的一次获取一个月的数据，month的一次获取一年的数据
    //直到startDate 小于2015-10-01 00:00:00（如果这里有获取结束标志也行，但是现在先这样了）
    NSDate *endDate = [self dateFromString:endDateString];
    
    NSDate *comparedDate = [self dateFromString:PlugDataCampareDate];
    
    NSDate *startDayDate = [self fetchOneMonthData:endDate];
    while ([startDayDate timeIntervalSinceDate:comparedDate] > 0) {
        startDayDate = [self fetchOneMonthData:startDayDate];
    }
    //终止循环 if ([startDayDate timeIntervalSinceDate:comparedDate] < 0) {
    
    NSDate *startMonthDate = [self fetchOneYearData:endDate];
    while ([startMonthDate timeIntervalSinceDate:comparedDate] >= 0) {
        startMonthDate = [self fetchOneYearData:endDate];
    }
    //终止循环
}

#pragma mark - cache 
//初始化
- (void)cacheInit {
    if (!_cache) {
        _cache = [MHLumiCache sharedInstance];
        [_cache createLumiPlugQuantEntity];

        NSString *userid = [MHPassportManager sharedSingleton].currentAccount.userId;
        [_cache resetWithAccount:userid];
    }
    
    _remoteDataManager = [MHLumiPlugDataManager sharedInstance];
}

//写入
- (void)cacheDataList:(NSArray *)datalist {
    [self cacheInit];
    
    MHLumiPlugQuantCache *plugCache = [[MHLumiPlugQuantCache alloc] init];
    
    [_cache asyncSaveItemsByEntityDescriptionName:kEntityNamePlugQuant
                                       dataArray:datalist
                  fillManagedObjectWithDataBlock:^(NSManagedObject *mo, id data) {
                      [plugCache fillManagedObject:mo withData:data];
                      
                  } withCompletionBlock:^{
                      NSLog(@"success");
    }];
}

//读取
- (void)fetchCacheListWithFetchRequest:(NSFetchRequest *)fetchRequest
                    andCompletionBlock:(void (^)(NSArray *))completionBlock {
    
    MHLumiPlugQuantCache *plugCache = [[MHLumiPlugQuantCache alloc] init];
    [self cacheInit];
    [_cache asyncFetchItemsByEntityDescriptionName:kEntityNamePlugQuant
                      withFetchRequestChangeBlock:^NSFetchRequest *(NSFetchRequest *request) {
                          
                          return fetchRequest;
                          
                      } dataWithManagedObjectBlock:^id(NSManagedObject *mo) {
                          
                          return [plugCache fillDataWithManagedObject:mo];

                      } withCompletionBlock:^(NSArray *resultArray) {
                          
                          completionBlock(resultArray);
    }];
}

@end
