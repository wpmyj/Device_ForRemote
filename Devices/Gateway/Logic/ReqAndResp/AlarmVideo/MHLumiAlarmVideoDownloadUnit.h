//
//  MHLumiAlarmVideoDownloadUnit.h
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/23.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface MHLumiAlarmVideoDownloadUnit : NSObject
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *did;
@property (nonatomic, assign) NSInteger time;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, assign) NSInteger videoDuration;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *type;
- (instancetype)initWithDic:(NSDictionary *)dic;
- (NSString *)suffix;
@end
