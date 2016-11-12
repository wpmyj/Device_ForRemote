//
//  MHDataGatewaySceneLog.h
//  MiHome
//
//  Created by guhao on 16/5/16.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>

@interface MHDataGatewaySceneLog : MHDataBase

@property (nonatomic, copy) NSString* recordId;
@property (nonatomic, copy) NSString* recordName;
@property (nonatomic, copy) NSString* recordType;
@property (nonatomic, copy) NSString* recordIdentifier;
@property (nonatomic, assign) NSTimeInterval executeTime;
@property (nonatomic, retain) NSArray* messages;

// 将log按日期分组时用到
@property (nonatomic, assign) BOOL hasPrev;
@property (nonatomic, assign) BOOL hasNext;
@property (nonatomic, assign) BOOL isFirst;

- (UIImage *)historyIcon;
- (BOOL)isSucceedExecuted;
- (BOOL)isShowFaiedDetails;



@end
