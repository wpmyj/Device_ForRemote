//
//  MHLumiCameraTimeLineDataUnit.h
//  Lumi_demo_OC
//
//  Created by LM21Mac002 on 16/10/22.
//  Copyright © 2016年 LM21Mac002. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHLumiCameraTimeLineDataUnit : NSObject
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (copy, nonatomic) NSString *timeRepresentString;
@property (copy, nonatomic) NSString *dateRepresentString;
@property (assign, nonatomic, getter=isNeedShowTimeNoteLabel) BOOL needShowTimeNoteLabel;
@property (assign, nonatomic) CGFloat countOfSeparated;
@property (strong, nonatomic) NSSet<NSNumber *> *enableRange;
@property (strong, nonatomic) NSSet<NSNumber *> *disableRange;
- (NSTimeInterval)timeIntervalBetweenStartDateAndEndDate;
+ (MHLumiCameraTimeLineDataUnit *)data;
@end
