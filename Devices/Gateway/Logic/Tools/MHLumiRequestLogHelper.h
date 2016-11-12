//
//  MHLumiRequestLogHelper.h
//  MiHome
//
//  Created by LM21Mac002 on 16/10/10.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger,MHLumiRequestLogStepStatus){
    MHLumiRequestLogStepStatusDefault            = 0,
    MHLumiRequestLogStepStatusSuccess            = 1,
    MHLumiRequestLogStepStatusFailure            = -1
};

typedef NS_ENUM(NSInteger,MHLumiActivitiesType){
    MHLumiActivitiesTypeDouble11                = 1111,
};

extern const NSString *kStepKeyA;
extern const NSString *kStepKeyB;
extern const NSString *kStepKeyC;
extern const NSString *kStepKeyD;

@interface MHLumiRequestLogHelper : NSObject
- (instancetype)initWithType:(MHLumiActivitiesType)type andIdentifier:(NSString *)identifier;
- (bool)isCompleted;
- (bool)isLogExisted;
- (bool)removeLogDic;
- (void)resetLogDic;
- (void)markToSuccess;
- (void)markToFailue;
- (void)setRequestStatus:(MHLumiRequestLogStepStatus)status indexKey:(NSInteger)indexKey;
- (NSArray *)todoIndexArray;
@end
