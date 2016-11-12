//
//  MHLMOperationQueueTools.h
//  MiHome
//
//  Created by Lynn on 2/1/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MHLMOperationQueueTools : NSObject

@property (nonatomic,assign) CGFloat delayTime;

+ (id)sharedInstance ;

/**
 *  初始化
 *
 *  @param operationGroup 操作队列block
 *
 *  @return
 */
- (id)initWithOperationGroup:(NSMutableArray *)operationGroup ;

/**
 *  添加操作队列
 *
 *  @param operation block
 */
- (void)addToOperationGroup:(id)operation;

/**
 *  串行执行队列
 */
- (void)asyncSerialQueueOperate ;

@end
