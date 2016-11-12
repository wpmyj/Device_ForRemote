//
//  MHLMOperationQueueTools.m
//  MiHome
//
//  Created by Lynn on 2/1/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLMOperationQueueTools.h"

@interface MHLMOperationQueueTools ()

@property (nonatomic,strong) NSMutableArray *operationBlockGroup;

@end

@implementation MHLMOperationQueueTools
{

}

+ (id)sharedInstance {
    static MHLMOperationQueueTools *obj = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        obj = [[MHLMOperationQueueTools alloc] init];
    });
    return obj;
}

- (id)initWithOperationGroup:(NSMutableArray *)operationGroup {
    if (self = [super init]) {
        _operationBlockGroup = operationGroup;
    }
    return self;
}

- (void)addToOperationGroup:(id)operation {
    [self.operationBlockGroup addObject:operation];
}

- (void)asyncSerialQueueOperate {

    NSString *queueId = [NSString stringWithFormat:@"com.xiaomi.mihome.lumi.operationqueue"];
    dispatch_queue_t queue1 = dispatch_queue_create([queueId UTF8String], DISPATCH_QUEUE_SERIAL);
    
    NSMutableArray *taskGroup = [NSMutableArray new];
    NSMutableArray *semaphoreGroup = [NSMutableArray new];
    
    for (int i = 0 ; i < _operationBlockGroup.count ; i ++) {
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        [semaphoreGroup addObject:sem];

        void (^ tmpOperation)() = _operationBlockGroup[i];
        dispatch_block_t task = ^(){
            //等待上一个任务执行完毕
            if (i != 0 ){
                dispatch_semaphore_wait(semaphoreGroup[i-1], DISPATCH_TIME_FOREVER);
                sleep(self.delayTime);
            }
            tmpOperation();
            NSLog(@"%@ operate %d", [NSThread currentThread] , i);
            dispatch_semaphore_signal(semaphoreGroup[i]); //任务执行完毕，信号量＋1
        };
        [taskGroup addObject:task];
    }
    
    for (int i = 0 ; i < taskGroup.count ; i ++ ){
        dispatch_async(queue1,taskGroup[i]);
    }
}

@end
