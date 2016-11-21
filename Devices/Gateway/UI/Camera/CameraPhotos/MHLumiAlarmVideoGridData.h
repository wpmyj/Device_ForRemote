//
//  MHLumiAlarmVideoGridData.h
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/15.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHLumiAlarmVideoGridData : NSObject
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, assign) NSInteger duration;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign) NSUInteger *videoHeight;
@property (nonatomic, assign) NSUInteger *videoWidth;
@property (nonatomic, assign) NSData *rawData;
@end
