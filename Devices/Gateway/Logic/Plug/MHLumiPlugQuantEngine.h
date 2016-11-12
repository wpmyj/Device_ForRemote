//
//  MHGatewayPlugQuantEngine.h
//  MiHome
//
//  Created by Lynn on 12/17/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHDeviceGatewaySensorPlug.h"
#import "MHLumiPlugQuant.h"
#define kQuantDay                            @"day"
#define kQuantMonth                          @"month"

@interface MHLumiPlugQuantEngine : NSObject

+ (id)sharedEngine ;

//请初始化device
@property (nonatomic,strong) MHDeviceGatewaySensorPlug *devicePlug;
@property (nonatomic, strong) MHLumiPlugQuant *currentDay;
@property (nonatomic, strong) MHLumiPlugQuant *currentMonth;

- (NSString *)dateString:(NSDate *)date withDateType:(NSString *)dateType;
- (NSString *)fetchUnixTimeStamp:(NSString *)dateString;
- (NSString *)fullStringFromDate :(NSDate *)date ;

#pragma mark - 获取DB电量
- (void)fetchQuantData:(NSString *)startString
            LimitedNum:(NSInteger)limitedNum
              DateType:(NSString *)dateType
   withCompletionBlock:(void (^)(NSArray *array))completionBlock;

- (void)rebuildDBData:(NSArray *)DBData
             dateType:(NSString *)dateType
       withFinishData:(void (^)(NSArray *displayData , NSArray *timeLineData, MHLumiPlugQuant *largetsQuant))displayData;

#pragma mark - 获取Remote电量,并写入DB
- (void)findStartPoint:(NSString *)dateType ;

@end
